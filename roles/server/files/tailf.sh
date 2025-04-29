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
tail -f "${options[@]}" "${log_paths[@]}" | perl -pe '
    s/\e\[[0-9;]*m//g;  # Remove existing ANSI codes

    # Define log level color map
    my %colors = (
        TRACE => "\e[35m",
        TRC   => "\e[35m",
        DEBUG => "\e[36m",
        DBG   => "\e[36m",
        INFO  => "\e[32m",
        INF   => "\e[32m",
        WARN  => "\e[33m",
        WRN   => "\e[33m",
        ERROR => "\e[31m",
        ERR   => "\e[31m",
    );

    # Match all log level patterns (case-insensitive)
    my @matches = ();
    while (m/\b(TRACE|TRC|DEBUG|DBG|INFO|INF|WARN|WRN|ERROR|ERR)\b/ig) {
        push @matches, [ $-[0], $1 ];  # store position and match
    }

    if (@matches) {
        my ($pos, $lvl) = @{$matches[0]};  # take first match in line
        my $color = $colors{uc($lvl)};
        $_ = "$color$_\e[39m";
    }
'
