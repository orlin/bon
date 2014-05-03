#!/usr/bin/env bash

# Vars that are exported will show in `process.env` of the target `node` script.
# Either way is fine with bon.

export BON_NAME="bonumeant"
export BON_SCRIPT="bin/bonbond"
export BON_HELP="--help"
export BON_HELP_FILE="bin/bond.help.txt" # matching commander's `--help` style
export BON_EVALIST="four"

source bon "$@"
