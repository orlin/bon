#!/usr/bin/env bash

echo #\n

if which bon >/dev/null; then
  echo "Note: bon is already globally installed."
  echo
else
  npm i -g bon
fi
