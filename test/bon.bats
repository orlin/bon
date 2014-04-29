#!/usr/bin/env bats

load test_helper

@test "bon by itself does not do anything" {
  run bon
  assert_failure
  assert_output_contains "Bon needs target implementation."
}
