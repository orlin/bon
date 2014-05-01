#!/usr/bin/env bats

load test_helper

@test "defaults + bin/bonvars.sh" {
  cd test/configuration && run bonumeant
  assert_success
  assert_output_contains "bonumeant with bin/bonvars.sh"
}

@test "bonbond bond bon" {
  cd test/configuration && run bonbond
  assert_success
  assert_output_contains "bonbond is bond.coffee via bond.sh bon"
}
