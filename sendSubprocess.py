#!/usr/bin/env python3.12
import subprocess
from argparse import ArgumentParser, Namespace

# ssh kai@192.168.50.154 'export DISPLAY=:1; xdotool key alt+Left'

"""#py
import zmq
import json
import threading
import paramiko
import logging
from typing import Optional, Callable
from dataclasses import dataclass
from logging import getLogger, Logger

@dataclass
class KeystrokeRequest:
    api_key: str
    keys: str

class SSHController:
    def __init__(self, hostname: str, username: str, logger: Optional[Logger] = None):
        self.hostname = hostname
        self.username = username
        self.ssh: Optional[paramiko.SSHClient] = None
        self.logger = logger or getLogger(__name__)

    def connect(self) -> None:
        #Initialize SSH connection
        try:
            self.ssh = paramiko.SSHClient()
            self.ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            self.ssh.connect(self.hostname, username=self.username)
            self.ssh.get_transport().set_keepalive(60)
            self.ssh.exec_command('export DISPLAY=:0')
            self.logger.info("SSH connection established")
        except Exception as e:
            self.logger.error(f"Failed to establish SSH connection: {e}")
            raise

    def send_keystroke(self, keys: str) -> None:
        #Send keystroke via xdotool
        if not self.ssh or not self.ssh.get_transport().is_active():
            self.logger.warning("SSH connection lost, reconnecting...")
            self.connect()
        try:
            self.ssh.exec_command(f'xdotool key {keys}')
            self.logger.debug(f"Sent keystroke: {keys}")
        except Exception as e:
            self.logger.error(f"Failed to send keystroke: {e}")
            raise

    def close(self) -> None:
        #Close SSH connection#
        if self.ssh:
            self.ssh.close()
            self.logger.info("SSH connection closed")

class KeystrokeListener:
    def __init__(self, 
                 port: int, 
                 api_key: str, 
                 keystroke_handler: Callable[[str], None],
                 logger: Optional[Logger] = None):
        self.port = port
        self.api_key = api_key
        self.keystroke_handler = keystroke_handler
        self.logger = logger or getLogger(__name__)
        self.context: Optional[zmq.Context] = None
        self.socket: Optional[zmq.Socket] = None
        self.running = False
        self._setup_zmq()

    def _setup_zmq(self) -> None:
        #Initialize ZMQ context and socket#
        try:
            self.context = zmq.Context()
            self.socket = self.context.socket(zmq.REP)
            self.socket.bind(f"tcp://127.0.0.1:{self.port}")
            self.logger.info(f"ZMQ socket bound to port {self.port}")
        except Exception as e:
            self.logger.error(f"Failed to setup ZMQ: {e}")
            self.cleanup()
            raise

    def _handle_message(self, message: dict) -> str:
        #Process incoming message and return response#
        try:
            request = KeystrokeRequest(**message)
            if request.api_key != self.api_key:
                self.logger.warning("Invalid API key received")
                return "Invalid API key"
            
            self.keystroke_handler(request.keys)
            return "Success"
        except Exception as e:
            self.logger.error(f"Error handling message: {e}")
            return f"Error: {str(e)}"

    def start(self) -> None:
        #Start listening for messages#
        self.running = True
        self.logger.info("Starting keystroke listener")
        
        while self.running:
            try:
                if not self.socket:
                    raise RuntimeError("ZMQ socket not initialized")
                
                message = self.socket.recv_json(flags=zmq.NOBLOCK)
                response = self._handle_message(message)
                self.socket.send_string(response)
                
            except zmq.Again:
                # No message available, continue polling
                continue
            except Exception as e:
                self.logger.error(f"Error in message loop: {e}")
                if self.running:  # Only try to reconnect if we're still supposed to be running
                    self._setup_zmq()

    def stop(self) -> None:
        #Stop the listener#
        self.running = False
        self.cleanup()
        self.logger.info("Keystroke listener stopped")

    def cleanup(self) -> None:
        #Clean up ZMQ resources#
        if self.socket:
            self.socket.close()
        if self.context:
            self.context.term()
        self.socket = None
        self.context = None

class KeystrokeService:
    def __init__(self,
                 hostname: str,
                 username: str,
                 port: int,
                 api_key: str,
                 logger: Optional[Logger] = None):
        self.logger = logger or getLogger(__name__)
        self.ssh_controller = SSHController(hostname, username, self.logger)
        self.listener = KeystrokeListener(
            port=port,
            api_key=api_key,
            keystroke_handler=self.ssh_controller.send_keystroke,
            logger=self.logger
        )
        self.listener_thread: Optional[threading.Thread] = None

    def start(self) -> None:
        #Start the keystroke service#
        try:
            # Initialize SSH connection
            self.ssh_controller.connect()
            
            # Start listener in separate thread
            self.listener_thread = threading.Thread(target=self.listener.start)
            self.listener_thread.daemon = True
            self.listener_thread.start()
            
            self.logger.info("Keystroke service started successfully")
        except Exception as e:
            self.logger.error(f"Failed to start keystroke service: {e}")
            self.stop()
            raise

    def stop(self) -> None:
        #Stop the keystroke service#
        try:
            if self.listener:
                self.listener.stop()
            if self.ssh_controller:
                self.ssh_controller.close()
            self.logger.info("Keystroke service stopped")
        except Exception as e:
            self.logger.error(f"Error stopping keystroke service: {e}")
            raise

def main():
    
    
    logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    logger = logging.getLogger('keystroke_service')

    config = {
        'hostname': 'your_host',
        'username': 'your_username',
        'port': 5555,
        'api_key': 'your_secret_key'
    }

    service = KeystrokeService(**config, logger=logger)
    
    try:
        service.start()
        # Keep main thread alive
        while True:
            input()
    except KeyboardInterrupt:
        logger.info("Shutting down...")
        service.stop()
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        service.stop()
        raise

if __name__ == "__main__":
    main()
"""  # ENDS HERE #


def get_args() -> Namespace:
    parser = ArgumentParser()
    parser.add_argument("key", type=str, help="The key to send to ssh command")
    return parser.parse_args()


if __name__ == "__main__":
    args = get_args()
    key = args.key
    cmd = f"ssh kai@192.168.50.154 'export DISPLAY=:1; xdotool key {key}'"

    result = subprocess.run(cmd, shell=True, capture_output=True)

    print(result.stdout.decode())
    print(result.stderr.decode())
