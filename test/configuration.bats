#!/usr/bin/env bats

load test_helper

setup() {
  cd test/configuration
}

@test "defaults + bin/bonvars.sh" {
  run bonumeant
  assert_success
  assert_output_contains "bonumeant with bin/bonvars.sh"
  assert_output_contains "https://github.com/orlin/bon"
}

@test "bonbond define #commander command" {
  run bonbond define
  assert_success
  assert_output_contains "bonbond is bond.coffee via bond.sh bon"
}

@test "bonbond --help #commander's + custom text" {
  # notice how bon enables more ways to get help
  run bonbond -?
  assert_success
  assert_output_contains "made to illustrate use of bon"
}

@test "bonbond #same as bonbond --help" {
  # because BON_HELP is set, no args causes --help
  run bonbond
  assert_success
  assert_output_contains "made to illustrate use of bon"
}

@test "bonbond four #produces a command to auto-eval" {
  run bonbond four
  assert_success
  assert_output "4"
}
