#!/usr/bin/env bash

npm install -g batshit

# install test projects
for project in convention configuration; do
  pushd "test/$project"
  npm install
  npm link
  popd
done
