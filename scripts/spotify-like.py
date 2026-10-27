"""Save one captured Spotify track using the existing spotify-cli login.

Called by spotify.lua with ~/.venv/3.12/bin/python. Exit codes are the
Lua interface: 0 saved, 2 request failed/invalid, 3 authorization needed,
4 dependency missing. Never print credentials or exception messages.
"""

import re
import socket
import sys
from urllib.parse import urlencode


def main(argv):
    if len(argv) != 1 or not re.fullmatch(r"spotify:track:[A-Za-z0-9]{22}", argv[0]):
        return 2
    try:
        from cli.utils import Spotify
        from cli.utils.exceptions import AuthorizationError, SpotifyAPIError, TokenExpired
    except ImportError:
        return 4

    # Covers the CLI's API requests and token refresh; Lua also bounds the
    # entire process. Use the CLI's authentication rather than copying tokens.
    socket.setdefaulttimeout(8)
    try:
        credentials = Spotify.get_credentials()
        if not credentials.get("access_token") or "user-library-modify" not in credentials.get("scope", "").split():
            return 3
        Spotify.request("me/library?" + urlencode({"uris": argv[0]}), method="PUT")
    except (AuthorizationError, TokenExpired):
        return 3
    except SpotifyAPIError as error:
        return 3 if error.status in (401, 403) else 2
    except Exception:
        # Network and local credential-file errors are deliberately sanitized.
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
