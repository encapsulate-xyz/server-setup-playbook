#!/bin/bash

tail -f "$@" | sed -r 's/\x1B\[[0-9;]*[mK]//g' | sed \
    -e 's/.*\(INFO\|INF\).*/\x1B[32m&\x1B[39m/I' \
    -e 's/.*\(ERROR\|ERR\).*/\x1B[31m&\x1B[39m/I' \
    -e 's/.*\(DEBUG\|DBG\).*/\x1B[36m&\x1B[39m/I' \
    -e 's/.*\(WARN\|WRN\).*/\x1B[33m&\x1B[39m/I' \
    -e 's/.*\(TRACE\|TRC\).*/\x1B[35m&\x1B[39m/I'