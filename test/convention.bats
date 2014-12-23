#!/usr/bin/env batshit

load ../node_modules/batshit/bin/batshit-helpers

@test "coventional implementation + coffee-script" {
  cd test/convention && run bonvent
  assert_success
  assert_output "bonvented"
}
