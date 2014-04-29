#!/bin/bash

# This `bon` mostly delegates to `$script <commands>`, easily node cli.
# The few extras are location-independence, automated meta-command eval,
# a small safety mechanism, and a `$script line ...` - for cli dev.


# HELPERS:

# Exits if a newline is found - a trailing \n is ok.
oneline() {
  if [[ $1 == *$'\n'* ]]; then
    echo "The '$name $2' should yield exactly one line to eval, exiting instead."
    echo "FYI, here is what was got:"
    echo "$1"
    exit 1
  else
    return 0 # true
  fi
}

# Determine if a list $1 contains an item $2.
contains() {
  for word in $1; do
    [[ $word = "$2" ]] && return 0 # = true
  done
  return 1 # = false
}

# Source a file if it exists.
include () {
  [[ -f "$1" ]] && source "$1"
}


# SETUP:

# Variables, with assumptions...
bon="bon" # the command of the bon script - matching package.json
base=$(basename "${0##*/}") # ${BASH_SOURCE[0]} would always be $bon
name=${BON_NAME:-$base} # of the node package that is using bon
script="./bin/$name.${BON_EXT:-js}" # relative to the $name package
[ -n "${BON_SCRIPT}" ] && script="${BON_SCRIPT}" # override entirely
PATH="./node_modules/bon/node_modules/.bin:$PATH" # depend on coffee

# Go to the right path - this is verified further down.
path=$(coffee -e "\
process.stdout.write (\
  if process.env.NODE_PATH is undefined then '.'\
  else process.env.NODE_PATH.split(':')[0] + '/$name')"
)
cd "$path"

# Make sure we are in the right place, or don't run anything.
if [[ "$BON_CHECK" == "no" ]]; then
  path_ok="yes" # is it ok not to check?  yes, in some cases.
else
  [ -z "$BON_CHECK_FILE" ] && BON_CHECK_FILE=$path/package.json
  if [[ -f "$BON_CHECK_FILE" ]]; then
    if [ -z "$BON_CHECK_GREP" ]; then
      package=$(coffee -e "process.stdout.write \
        require('$path/package.json').name")
      if [[ $name == "$package" ]]; then
        path_ok="yes"
      fi
    elif grep -q "$BON_CHECK_GREP" "$path/$BON_CHECK_FILE"; then
      path_ok="yes"
    fi
  fi
fi

# The moment of $path_ok truth.
if [[ "$path_ok" == "yes" ]]; then
    # If this was run via $bon, provide an easy way to load more vars.
    [[ $base == "$bon" ]] && include ./bin/bonvars.sh

    # Space-separated list of commands that produce commands to eval.
    # Be careful what goes here - running arbitrary strings can be bad!
    # Try `<name> line <command>` and add to the list once it looks good.
    evalist="${BON_EVALIST}"
else
  echo
  echo "This '$path' path is not the root directory of $name."
  help="error"
fi

# Cannot do anything withhout a $script to run - except echo more help -
# check this far down because it may depend on $path or *bonvars*.
if [[ ! -x "$script" ]]; then
  echo
  if [[ $script == "./bin/bon.js" ]]; then
    # usually means that nothing has been implemented
    echo "Bon needs target implementation."
  else
    echo "Script '$script' not found."
  fi
  help="error"
fi


# RUN: The sequence of if and elifs is not arbitrary - so don't rearrange!

if [[ $1 == "" || $1 == "help" || $help == "error" ]]; then
  # help comes first
  if [[ $help == "error" ]]; then
    echo # vertical spacing follows prior messages
  else
    # show $script help only if there was no error and the script can be run
    [[ -x "$script" ]] && $script --help
  fi
  # help specific to bon, formatted to match `commander`'s style
  echo "  Configuration:"
  echo
  echo "    Set \$NODE_PATH to run $name from anywhere,"
  echo "    given that $name is a node module / script."
  echo
  [[ $help == "error" ]] && exit 1

elif [[ $1 == "line" ]]; then
  # use it to dev commands with (before adding them to the $evalist)
  shift # removes line from the argv
  line=$($script "$@")
  if oneline "$line" "$@" ; then
    echo "$line" # the command to be
  fi

elif contains "$evalist" "$1" ; then
  # `$script <command> ...` writes a string to stdout - to eval
  command=$($script "$@")
  oneline "$command" "$@"
  eval "$command"

else
  # delegate the rest
  $script "$@"
fi
