#!/usr/bin/env coffee

bond = require("commander")

bond.version(require("../package.json").version)

bond
  .command("define")
  .description("says what bonbond is about - nothing substantial, just a test")
  .action -> console.log "bonbond is bond.coffee via bond.sh bon"

bond.parse(process.argv)
