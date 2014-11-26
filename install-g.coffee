#!/usr/bin/env coffee

npm = require("npm")
pkg = process.env.npm_package_config_installg_pkg || process.env.npm_package_name

unless pkg
  console.error "Must use via package.json's scripts.install - defaults to name."
  process.exit(1)

# calls cb if a pkg isn't installed globally
unlessGloballyInstalled = (pkg, cb) ->
  npm.load (err, npm) ->
    console.error err if err?
    npm.config.set("json", true)
    npm.config.set("global", true)
    npm.config.set("depth", 0) # just top level, no other package deps
    npm.commands.ls [pkg], true, (err, data, lite) ->
      console.error err if err?
      # if the object is empty then pkg is not installed globally
      if Object.keys(lite).length is 0 then cb(npm)

unlessGloballyInstalled pkg, (npm) ->
  console.log "Package #{pkg} insists to be globally installed, please wait..."
  npm.config.set("global", true)
  npm.config.set("json", false)
  npm.commands.install [pkg], (err, data, lite) ->
    console.error err if err?
    console.log()
