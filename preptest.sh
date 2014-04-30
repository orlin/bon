#!/bin/bash

rm -rf bats
git clone https://github.com/sstephenson/bats.git
pushd test/convention
npm install
npm link
popd
