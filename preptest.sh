#!/bin/bash

# use ./bats/bin/bats or install it somewhere else
rm -rf bats
git clone https://github.com/sstephenson/bats.git
# ./bats/install.sh /usr/local

# install test projects
for project in "convention"; do
  pushd "test/$project"
  npm install
  npm link
  popd
done
