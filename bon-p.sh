#!/usr/bin/env bash

if [[ -n "$NODE_PATH" ]]; then
  echo $NODE_PATH
else
  temp=$(dirname $(which bon))
  echo ${temp//bin/lib\/node_modules}
fi
