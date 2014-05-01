#!/usr/bin/env bats

load test_helper

setup() {
  cd test/configuration
}

@test "defaults + bin/bonvars.sh" {
  run bonumeant
  assert_success
  assert_output_contains "bonumeant with bin/bonvars.sh"
}

@test "bonbond bond bon" {
  run bonbond
  assert_success
  assert_output_contains "bonbond is bond.coffee via bond.sh bon"
}
