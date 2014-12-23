#!/usr/bin/env batshit

load ../node_modules/batshit/bin/batshit-helpers

@test "bon by itself does not do anything" {
  run bon
  assert_failure
  assert_output_contains "Bon needs target implementation."
  assert_output_contains "See https://github.com/orlin/bon"
}

@test "bon is available globally, thanks to install-g" {
  pushd ..
  run which bon
  assert_success
  assert_output_contains "/bon"
  popd
}
