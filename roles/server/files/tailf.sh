#!/bin/bash

# Arrays to store options and log paths
options=()
log_paths=()

# Loop through all the arguments
for ((i = 1; i <= $#; i++)); do
    arg="${!i}"

    if [[ "$arg" == -* ]]; then
        # Check if the option requires a value (like -n 100)
        next_index=$((i + 1))
        next_arg="${!next_index}"

        if [[ "$arg" == -n && "$next_arg" =~ ^[0-9]+$ ]]; then
            # Handle -n option with its value
            options+=("$arg" "$next_arg")
            i=$next_index  # Skip the next argument since it's part of the -n option
        else
            # Collect other options (e.g., --follow, -f)
            options+=("$arg")
        fi
    elif [[ "$arg" == *.log ]]; then
        # Check if it's a full path or just a filename
        if [[ -f "$arg" ]]; then
            # It's a valid path, use it directly
            log_paths+=("$arg")
        else
            # Try to find the full path for the filename under /opt/
            path=$(find /opt/ -type f -path "*/log/*.log" -name "$arg" 2>/dev/null)

            if [[ -n "$path" ]]; then
                log_paths+=("$path")
            else
                echo "Error: File '$arg' not found in /opt/"
                exit 1
            fi
        fi
    else
        echo "Warning: Ignoring unknown argument '$arg'."
    fi
done

# Validate if at least one valid log path is found
if [[ ${#log_paths[@]} -eq 0 ]]; then
    echo "Usage: $(basename "$0") [OPTIONS] <log_file(s)>"
    exit 1
fi

# Start tailing the file(s) and apply sed to colorize log levels
tail -f "${options[@]}" "${log_paths[@]}" | sed -E '
    s/\x1B\[[0-9;]*m//g;  # Remove existing ANSI codes

    # Apply color based on the first matching log level (case-insensitive)
    /(^|[^a-zA-Z])(DEBUG|DBG)([^a-zA-Z]|$)/I {
        s/^/\x1B[36m/;  # Cyan for DEBUG
        s/$/\x1B[39m/;  # Reset color at the end
        b end  # Stop further processing for this line
    }
    /(^|[^a-zA-Z])(INFO|INF)([^a-zA-Z]|$)/I {
        s/^/\x1B[32m/;  # Green for INFO
        s/$/\x1B[39m/;  # Reset color at the end
        b end  # Stop further processing for this line
    }
    /(^|[^a-zA-Z])(ERROR|ERR)([^a-zA-Z]|$)/I {
        s/^/\x1B[31m/;  # Red for ERROR
        s/$/\x1B[39m/;  # Reset color at the end
        b end  # Stop further processing for this line
    }
    /(^|[^a-zA-Z])(WARN|WRN)([^a-zA-Z]|$)/I {
        s/^/\x1B[33m/;  # Yellow for WARN
        s/$/\x1B[39m/;  # Reset color at the end
        b end  # Stop further processing for this line
    }
    /(^|[^a-zA-Z])(TRACE|TRC)([^a-zA-Z]|$)/I {
        s/^/\x1B[35m/;  # Magenta for TRACE
        s/$/\x1B[39m/;  # Reset color at the end
        b end  # Stop further processing for this line
    }

    :end  # Label to stop further processing for the current line
'
