#!/usr/bin/env bats

@test "bon by itself does not do anything" {
  run bon
  [ "$status" -eq 1 ]
  [ "$output" = "bon needs target implementation" ]
}
