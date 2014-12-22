#!/usr/bin/env bash

# install test projects
for project in convention configuration; do
  pushd "test/$project"
  npm install
  npm link
  popd
done
