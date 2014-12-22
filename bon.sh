#!/usr/bin/env bash

# This `bon` impersonates another `<script> ...` - the (node.js) implementation.
# The few extras are location-independence, automated meta-command eval,
# a small safety mechanism, and a `$script line ...` - for easy cli dev.
# It also helps a little with some extra help options.


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

# Change working directory if requested.
cwd () {
  [[ -n "$BON_CWD" ]] && cd "$BON_CWD"
}


# SETUP:

# Variables, with assumptions...
bon="bon" # the command of the bon script - matching package.json
base=$(basename "${0##*/}") # ${BASH_SOURCE[0]} is sometimes $bon
name=${BON_NAME:-$base} # of the node package that is using bon
script="./bin/$name.${BON_EXT:-js}" # relative to the $name package
[ -n "${BON_SCRIPT}" ] && script="${BON_SCRIPT}" # override entirely

# There can only be one `bon`.
if [[ $name == "bon" ]]; then
  echo "Bon needs target implementation."
  echo "See https://github.com/orlin/bon#readme"
  exit 1
fi

path='.' # default - a last resort
# The $path is preferably a subdir of one of the following, to run from anywhere.
if [[ -n "${NODE_PATH}" ]]; then
  NODE_PATH_TEST="${NODE_PATH}"
else
  NODE_PATH_TEST="/usr/lib/node_modules:/usr/local/lib/node_modules"
  NODE_PATH_TEST="${NODE_PATH_TEST}:$(dirname $(which npm))/../lib/node_modules"
fi

# Find the first NODE_PATH that contains the module.
IFS=':' read -ra node_paths <<< "${NODE_PATH_TEST}"
for path_test in "${node_paths[@]}"; do
  if [[ -d "${path_test}/${name}" ]]; then
    path="${path_test}/${name}"
    [[ "$BON_CWD" == "." ]] && BON_CWD="$(pwd)"
    cd "$path"
    break
  fi
done

# Make sure we are in the right place, or don't run anything.
if [[ "$BON_CHECK" == "no" ]]; then
  path_ok="yes" # is it ok not to check?  yes, in some cases.
else
  [ -z "$BON_CHECK_FILE" ] && BON_CHECK_FILE=$path/package.json
  if [[ -f "$BON_CHECK_FILE" ]]; then
    if [ -z "$BON_CHECK_GREP" ]; then
      package=$(node -e "process.stdout.write(require('${path}/package.json').name)")
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
    # If all the names match, provide an easy way to load more vars.
    [[ $base == "$name" ]] && include ./bin/bonvars.sh

    # Space-separated list of commands that produce commands to eval.
    # Be careful what goes here - running arbitrary strings can be bad!
    # Try `<name> line <command>` and add to the list once it looks good.
    evalist="${BON_EVALIST}"
else
  echo
  echo "This '$path' path is not the root directory of $name."
  if [[ -z "${NODE_PATH}" ]]; then
    echo "Please set \$NODE_PATH - where global node_modules are installed."
  fi
  help="error"
fi

# Cannot do anything withhout a $script to run - except echo more help -
# check this far down because it may depend on $path or *bonvars*.
if [[ ! -x "$script" ]]; then
  echo
  if [[ ! -f "$script" ]]; then
    echo "Script '$script' not found."
  else
    echo "Script '$script' not executable."
  fi
  help="error"
fi


# RUN: The sequence of if and elifs is not arbitrary - so don't rearrange!

if [[ $# -eq 0
   || $1 == "-?"
   || $1 == "-h"
   || $1 == "--help"
   || $help == "error"
   ]]; then
  # help comes first
  if [[ $help == "error" ]]; then
    echo # vertical spacing follows prior messages
  else
    # show $script help only if there was no error and the script can be run
    [[ -x "$script" ]] && $script ${BON_HELP:-$1}
  fi
  # help specific to bon is not always shown
  if [[ $# -ne 0 || -n $BON_HELP ]]; then
    # if we got here witn non-zero arguments, or non-zero-length of $BON_HELP
    if [[ -z $BON_HELP_FILE ]]; then
      echo "See https://github.com/orlin/bon#readme for more info."
      echo
    elif [[ $help != "error" ]]; then
      # the error could mean bad path - so the help file won't be found
      help_txt=$(cat $BON_HELP_FILE)
      if [[ ! $help_txt == "" ]]; then
        # only if the file wasn't empty
        echo "$help_txt" # the quotes are necessary to keep `\n`s and the spaces
        echo # because sometimes extra trailing newlines get auto-trimmed
      fi
    fi
  fi
  # errors reflect on the script's exit status
  if [[ $help == "error" ]]; then exit 1; fi

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
  cwd
  eval "$command"

else
  # delegate the rest
  cwd
  $script "$@"
fi
