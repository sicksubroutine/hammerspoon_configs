from typing import Optional, Dict, Any, Union
from . import screen, styledtext

class Alert:
    """Show alerts centered on screen"""

    defaultStyle: Dict[str, Any] = {
        "fillColor": {"white": 0, "alpha": 0.75},
        "strokeColor": {"white": 1, "alpha": 1},
        "textColor": {"white": 1, "alpha": 1},
        "textFont": ".AppleSystemUIFont",
        "textSize": 27,
        "strokeWidth": 2,
        "radius": 27,
        "padding": None,  # defaults to textSize/2
        "atScreenEdge": 0,
        "fadeInDuration": 0.15,
        "fadeOutDuration": 0.15,
    }

    @staticmethod
    def show(
        message: Union[str, "styledtext.StyledText"],
        style: Optional[Dict[str, Any]] = None,
        screen: Optional["screen.Screen"] = None,
        seconds: Optional[float] = 2.0,
    ) -> str:
        """Shows an image and a message in large words briefly in the middle of the screen; does tostring() on its argument for convenience.

        Args:
            message: Text to display in the alert
            style: Optional styling parameters (see defaultStyle)
            screen: Optional screen to show alert on
            seconds: Duration to show alert (default 2.0)

        Returns:
            str: Identifier for the alert
        """

    @staticmethod
    def closeAll(seconds: Optional[float] = None) -> None:
        """Closes all alerts currently open on the screen.

        Args:
            seconds: Optional fade out duration
        """

    @staticmethod
    def closeSpecific(uuid: str, seconds: Optional[float] = None) -> None:
        """Closes a specific alert.

        Args:
            uuid: Identifier of alert to close
            seconds: Optional fade out duration
        """
