#!/bin/bash

tail -f "$@" | sed -E '
    s/\x1B\[[0-9;]*m//g;
    /INFO|INF/I {s/^/\x1B[32m/; s/$/\x1B[39m/}
    /ERROR|ERR/I {s/^/\x1B[31m/; s/$/\x1B[39m/}
    /DEBUG|DBG/I {s/^/\x1B[36m/; s/$/\x1B[39m/}
    /WARN|WRN/I {s/^/\x1B[33m/; s/$/\x1B[39m/}
    /TRACE|TRC/I {s/^/\x1B[35m/; s/$/\x1B[39m/}
'