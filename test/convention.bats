#!/usr/bin/env bats

load test_helper

@test "coventional implementation + coffee-script" {
  cd test/convention && run bonvent
  assert_success
  assert_output "bonvented"
}
