#!/bin/bash

# Start tailing the file(s) and apply sed to colorize log levels
tail -f "$@" | sed -E '
    # Remove any existing ANSI color codes (to avoid color code stacking)
    s/\x1B\[[0-9;]*m//g;

    # Colorize INFO (green)
    /INFO|INF/I {
        s/^/\x1B[32m/;    # Add green color to the beginning
        s/$/\x1B[39m/     # Reset color at the end
    }

    # Colorize ERROR (red)
    /ERROR|ERR/I {
        s/^/\x1B[31m/;    # Add red color
        s/$/\x1B[39m/     # Reset color
    }

    # Colorize DEBUG (cyan)
    /DEBUG|DBG/I {
        s/^/\x1B[36m/;    # Add cyan color
        s/$/\x1B[39m/     # Reset color
    }

    # Colorize WARNING (yellow)
    /WARN|WRN/I {
        s/^/\x1B[33m/;    # Add yellow color
        s/$/\x1B[39m/     # Reset color
    }

    # Colorize TRACE (magenta)
    /TRACE|TRC/I {
        s/^/\x1B[35m/;    # Add magenta color
        s/$/\x1B[39m/     # Reset color
    }
'