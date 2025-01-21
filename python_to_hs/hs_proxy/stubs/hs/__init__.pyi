from typing import Optional, Callable, List, Any, Union, overload, ClassVar, Type
from . import alert, screen, console

class HammerSpoon:
    """Hammerspoon core functionality accessed through Python"""

    class alert: ...
    alert: ClassVar[Type[alert.Alert]] = alert.Alert

    class screen: ...
    screen: ClassVar[Type[screen.Screen]] = screen.Screen

    class console: ...
    console: ClassVar[Type[console.Console]] = console.Console

    @staticmethod
    def reload() -> None:
        """Reload Hammerspoon configuration in a fresh Lua environment."""

    @staticmethod
    def focus() -> None:
        """Focus Hammerspoon application window."""

    @staticmethod
    def openConsole() -> None:
        """Open Hammerspoon console window."""

    @staticmethod
    def closeConsole() -> None:
        """Close Hammerspoon console window."""

    @staticmethod
    def toggleConsole() -> None:
        """Toggle Hammerspoon console window visibility."""

    @staticmethod
    def accessibilityState(shouldPrompt: bool = False) -> bool:
        """Check Accessibility Permissions for Hammerspoon.

        Args:
            shouldPrompt: If True, shows dialog to open System Preferences
                         when Accessibility is not enabled.

        Returns:
            bool: True if Accessibility is enabled for Hammerspoon.

        Note:
            Required for keyboard event capturing like keyUp and keyDown.
        """

    @staticmethod
    def allowAppleScript(state: Optional[bool] = None) -> bool:
        """Set/get whether external AppleScript commands are allowed.

        Args:
            state: Optional bool to enable/disable AppleScript support

        Returns:
            bool: True if AppleScript commands are allowed
        """

    @staticmethod
    def autoLaunch(state: Optional[bool] = None) -> bool:
        """Set/get "Launch on Login" status.

        Args:
            state: Optional bool to enable/disable launch on login

        Returns:
            bool: True if set to launch on login
        """

    class hotkey:
        """Global keyboard shortcut management"""

        @staticmethod
        @overload
        def bind(mods: Union[List[str], str], key: str, pressedfn: Optional[Callable[[], None]] = None) -> Any: ...
        @staticmethod
        @overload
        def bind(
            mods: Union[List[str], str],
            key: str,
            pressedfn: Optional[Callable[[], None]] = None,
            releasedfn: Optional[Callable[[], None]] = None,
            repeatfn: Optional[Callable[[], None]] = None,
        ) -> Any:
            """Bind global keyboard shortcuts.

            Args:
                mods: Modifiers like "cmd", "alt", "shift" or list of them
                key: Key to bind like "a", "b", "space"
                pressedfn: Optional callback for key press
                releasedfn: Optional callback for key release
                repeatfn: Optional callback for key repeat

            Returns:
                Hotkey object that can be used to disable/enable the shortcut
            """
