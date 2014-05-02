#!/usr/bin/env bash

# Vars that are exported will show in `process.env` of the target `node` script.
# Either way is fine with bon.

export BON_NAME="bonumeant"
export BON_SCRIPT="bin/bond.coffee"
export BON_HELP_FILE="bin/bond.help.txt"

source bon "$@"
