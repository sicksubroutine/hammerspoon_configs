#!/usr/bin/env python3
from __future__ import annotations  # type: ignore
import io
import os
import cmd
import sys
import time
import shlex
import threading
import subprocess
from os import getenv
from pathlib import Path
from rich.text import Text
from rich.theme import Theme
from rich.panel import Panel
from rich.table import Table
from rich.syntax import Syntax
from rich.console import Console
from dataclasses import dataclass, field
from typing import Optional, Dict, Callable

SHELL = getenv("SHELL", "/bin/zsh")


@dataclass
class ThreadSafeTailer:
    """Thread-safe file tailer with rotation support."""

    filename: Path
    callback: Callable[[str], None] = print
    encoding: str = "utf-8"
    _stop_event: threading.Event = field(default_factory=threading.Event)
    _file: Optional[io.TextIOWrapper] = None
    _last_inode: Optional[int] = None
    _last_size: int = 0
    _thread: Optional[threading.Thread] = None

    def __post_init__(self) -> None:
        if isinstance(self.filename, str):
            self.filename = Path(self.filename)

    def _open_file(self) -> bool:
        try:
            stat = self.filename.stat()

            if self._last_inode != stat.st_ino or self._last_size > stat.st_size:
                if self._file:
                    self._file.close()

                self._file = self.filename.open("r", encoding=self.encoding)
                self._last_inode = stat.st_ino

                self._file.seek(0, 2)
                self._last_size = self._file.tell()

            return True
        except FileNotFoundError:
            self.callback(f"Log file {self.filename} not found. Waiting...")
            return False
        except PermissionError:
            self.callback(f"Permission denied accessing {self.filename}")
            return False
        except Exception as e:
            self.callback(f"Error opening log file: {e}")
            return False

    def _tail(self) -> None:
        while not self._stop_event.is_set():
            if not self._file and not self._open_file():
                time.sleep(1)
                continue

            try:
                line = self._file.readline()

                if not line:
                    try:
                        current_stat = self.filename.stat()
                    except (FileNotFoundError, PermissionError) as e:
                        self.callback(f"Error checking file: {e}")
                        if self._file:
                            self._file.close()
                            self._file = None
                        time.sleep(1)
                        continue

                    if current_stat.st_size < self._last_size:
                        self._file.close()
                        self._file = None
                        continue

                    time.sleep(0.1)
                    continue

                self.callback(line.rstrip())
                self._last_size = self._file.tell()

            except Exception as e:
                self.callback(f"Error tailing log: {e}")
                if self._file:
                    self._file.close()
                    self._file = None
                time.sleep(1)

    def start(self) -> None:
        """Start tailing in a thread."""
        if self._thread and self._thread.is_alive():
            raise RuntimeError("Tailer already running")

        self._stop_event.clear()
        self._thread = threading.Thread(target=self._tail, daemon=True)
        self._thread.start()

    def stop(self) -> None:
        """Stop tailing."""
        self._stop_event.set()
        if self._thread:
            self._thread.join(timeout=2)
            if self._thread.is_alive():
                self.callback("Warning: Tailing thread did not stop cleanly")

        if self._file:
            self._file.close()
            self._file = None


class RichLogger:
    def __init__(self, console: Console, theme: Theme) -> None:
        self.console = console
        self.theme = theme

    def info(self, message: str) -> None:
        self.console.print(f"[info]{message}[/info]")

    def warning(self, message: str) -> None:
        self.console.print(f"[warning]{message}[/warning]")

    def error(self, message: str) -> None:
        self.console.print(f"[error]{message}[/error]")

    def success(self, message: str) -> None:
        self.console.print(f"[success]{message}[/success]")

    def log(self, message: str) -> None:
        self.console.print(f"[log]{message}[/log]")

    def hs(self, message: str) -> None:
        self.console.print(f"[hs]{message}[/hs]")


class HammerspoonConsole(cmd.Cmd):
    """Advanced Hammerspoon interactive console using shlex for robust parsing."""

    def __init__(self, log_path: Optional[Path] = None, history_file: Optional[Path] = None) -> None:
        super().__init__()

        self.prompt = ""
        self.intro = ""
        theme = Theme(
            {
                "info": "cyan",
                "warning": "yellow",
                "error": "red",
                "success": "green",
                "log": "blue",
                "hs": "magenta",
            }
        )
        self.console = Console(theme=theme)
        self.logger = RichLogger(self.console, theme)

        self.log_path = log_path or Path.home() / ".hammerspoon/hammerspoon.log"
        self.history_file = history_file or Path.home() / ".hammerspoon_history"

        self._aliases: Dict[str, str] = {
            "q": "quit",
            "r": "reload",
            "h": "help",
            "e": "exec",
            "t": "tail",
            "c": "clear",
            "f": "food",
        }

        self.tailer: Optional[ThreadSafeTailer] = None
        self._load_history()

    def preloop(self) -> None:
        """Hook method executed once when cmdloop() is called."""
        super().preloop()
        self.console.print(
            Panel(
                "[bold cyan]Hammerspoon Interactive Console[/bold cyan]\n[dim]Type 'help' for commands, 'quit' to exit.[/dim]",
                border_style="cyan",
                title="Welcome",
            )
        )
        self.do_tail("start")
        self.console.print()
        self.console.print("[bold green]hs >[/bold green] ", end="")

    def _load_history(self) -> None:
        try:
            if self.history_file.exists():
                with self.history_file.open("r", encoding="utf-8") as f:
                    for line in f:
                        self.cmdqueue.append(line.strip())
        except Exception as e:
            self.logger.error(f"Error loading history: {e}")

    def _save_history(self) -> None:
        try:
            with self.history_file.open("w", encoding="utf-8") as f:
                for line in self.cmdqueue:
                    f.write(f"{line}\n")
        except Exception as e:
            self.logger.error(f"Error saving history: {e}")

    def precmd(self, line: str) -> str:
        try:
            if not line.strip():
                return ""

            lexer = shlex.shlex(line, posix=True)
            lexer.whitespace_split = True
            lexer.commenters = "#"

            tokens = list(lexer)

            if not tokens:
                return ""

            cmd = tokens[0].lower()
            cmd = self._aliases.get(cmd, cmd)

            return f"{cmd} {' '.join(tokens[1:])}" if len(tokens) > 1 else cmd

        except ValueError as e:
            self.logger.error(f"Parsing error: {e}")
            return ""

    def postcmd(self, stop: bool, line: str) -> bool:
        """Hook method executed after a command is processed."""
        self.console.print("[bold green]hs>[/bold green] ", end="")
        return stop

    def do_food(self, arg: str) -> None:
        """STOP CODING AND GO EAT SOMETHING"""

        def center_markup(text: str, width: int = None) -> str:
            visible_text = (
                text.replace("[bold red]", "")
                .replace("[/bold red]", "")
                .replace("[yellow]", "")
                .replace("[/yellow]", "")
                .replace("[white]", "")
                .replace("[/white]", "")
                .replace("[red]", "")
                .replace("[/red]", "")
                .replace("[bold green]", "")
                .replace("[/bold green]", "")
            )
            padding = (width - len(visible_text)) // 2
            return " " * padding + text

        width = 40
        content = "\n".join(
            [
                center_markup("[yellow]Time since last meal: TOO LONG[/yellow]", width),
                center_markup("[white]Current status: [/white][red]HANGRY[/red]", width),
                "",
                center_markup("[bold green]RECOMMENDED ACTION:[/bold green]", width),
                center_markup("🍔[yellow]PUT DOWN THE KEYBOARD[/yellow]", width),
                center_markup("🏃[yellow]GO TO KITCHEN[/yellow]", width),
                center_markup("🍕[yellow]ACQUIRE SUSTENANCE[/yellow]", width),
            ]
        )

        self.console.print(
            Panel(
                center_markup("[bold red]🚨 PROGRAMMER ALERT 🚨[/bold red]", width),
                title="Food Emergency Protocol",
                border_style="red",
                width=50,
            )
        )
        self.console.print(Panel(content, border_style="magenta"), width=50)

    def do_reload(self, arg: str) -> None:
        """Reload Hammerspoon configuration."""
        try:
            result = subprocess.run(
                'hs -c "hs.reload()"',
                capture_output=True,
                text=True,
                check=True,
                shell=True,
                executable=SHELL,
            )
            self.logger.success("Hammerspoon config reloaded.")
            if result.stdout:
                print(result.stdout)
        except subprocess.CalledProcessError as e:
            print(f"Reload failed: {e}")
            if e.stderr:
                print(e.stderr)
        except FileNotFoundError:
            print("Error: Hammerspoon CLI not found. Is it installed?")

    def do_tail(self, arg: str) -> None:
        """Tail the Hammerspoon log file.

        Usage:
            tail [lines] [pattern]
            tail stop  # Stop tailing"""

        if arg.lower() == "stop":
            if self.tailer:
                self.tailer.stop()
                self.tailer = None
                self.console.print("[success]Stopped tailing log[/success]")
            return

        try:
            if self.tailer:
                self.console.print("[warning]Tail already running. Use 'tail stop' first.[/warning]")
                return

            class LineHandler:
                def __init__(self, console):
                    self.first_line = True
                    self.console = console

                def __call__(self, line: str) -> None:
                    if self.first_line:
                        self.console.print()
                        self.first_line = False
                    self.console.print(f"\r[log][HS][/log] [hs]{line}[/hs]")

            self.tailer = ThreadSafeTailer(self.log_path, callback=LineHandler(self.console))
            self.tailer.start()
            self.console.print(f"[info]Tailing log file: {self.log_path}[/info]")

        except Exception as e:
            self.console.print(f"[error]Error starting tail: {e}[/error]")

    def do_clear(self, arg: str) -> None:
        """Clear the Hammerspoon log file."""
        try:
            if self.tailer:
                self.tailer.stop()
                self.tailer = None

            self.log_path.write_text("")
            self.console.print("[success]Log file cleared[/success]")

            def print_line(line: str) -> None:
                self.console.print(f"\r[log][[LOG]][/log] {line}")

            self.tailer = ThreadSafeTailer(self.log_path, callback=print_line)
            self.tailer.start()

        except Exception as e:
            self.console.print(f"[error]Error clearing log file: {e}[/error]")

    def do_exec(self, arg: str) -> None:
        """Execute a Lua command in Hammerspoon."""
        if not arg:
            self.console.print("[warning]Usage: exec <lua command>[/warning]")
            return

        try:
            self.console.print(Panel(Syntax(arg, "lua", theme="monokai"), title="Executing Lua", border_style="cyan"))

            result = subprocess.run(["hs", "-c", arg], env=os.environ, capture_output=True, text=True, check=True)

            if result.stdout:
                self.console.print(Panel(result.stdout.rstrip(), title="Output", border_style="green"))
            if result.stderr:
                self.console.print(Panel(result.stderr.rstrip(), title="Error", border_style="red"))

        except subprocess.CalledProcessError as e:
            self.console.print("[error]Lua execution error:[/error]", e)
            if e.stdout:
                self.console.print(e.stdout.rstrip())
            if e.stderr:
                self.console.print(Panel(e.stderr.rstrip(), title="Error", border_style="red"))

    def do_quit(self, arg: str) -> bool:
        """Quit the console."""
        if self.tailer:
            self.tailer.stop()
        self._save_history()
        print("Exiting Hammerspoon monitor...")
        return True

    def default(self, line: str) -> None:
        """Handle unknown commands."""
        print(f"Unknown command: {line}")
        print("Type 'help' for available commands.")

    def emptyline(self) -> bool:
        """Do nothing on empty line."""
        return False

    def do_help(self, arg: str) -> None:
        """Show help for commands."""
        if arg:
            try:
                func = getattr(self, "do_" + arg)
                self.console.print(
                    Panel(func.__doc__ or "No help available", title=f"Help: {arg}", border_style="cyan")
                )
                return
            except AttributeError:
                self.console.print(f"[error]No help available for '{arg}'[/error]")
                return

        table = Table(title="Available Commands", border_style="cyan")
        table.add_column("Command", style="green")
        table.add_column("Description", style="white")
        table.add_column("Aliases", style="dim cyan")

        commands = [
            (name[3:], func.__doc__.split("\n")[0] if func.__doc__ else "No description")
            for name, func in self.__class__.__dict__.items()
            if name.startswith("do_")
        ]

        for cmd, desc in sorted(commands):
            aliases = [k for k, v in self._aliases.items() if v == cmd]
            alias_str = ", ".join(aliases) if aliases else ""
            table.add_row(cmd, desc, alias_str)

        self.console.print(table)
        self.console.print("\n[dim]Use 'help <command>' for detailed help.[/dim]")


def main() -> None:
    """Main entry point."""
    try:
        console = HammerspoonConsole()
        console.cmdloop()
    except KeyboardInterrupt:
        print("\nExiting...")
    except Exception as e:
        print(f"Fatal error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
