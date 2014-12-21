#!/usr/bin/env bats

load test_helper

@test "bon is available globally, thanks to install-g" {
  pushd ..
  run which bon
  assert_success
  assert_output_contains "/bon"
  popd
}

@test "coventional implementation + coffee-script" {
  cd test/convention && run bonvent
  assert_success
  assert_output "bonvented"
}
