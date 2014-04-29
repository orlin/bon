#!/usr/bin/env bats

@test "bon by itself does not do anything" {
  run bon
  [ "$status" -eq 1 ]
  # TODO: assert that $output contains "Bon needs target implementation."
}
