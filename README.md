# bon -- bash on node

This is a bash meta-cli script that helps run node.js or any other cli scripts.

[![NPM](https://nodei.co/npm/bon.png?compact=true)](https://www.npmjs.org/package/bon)


## Why

Node.js is great for cli scripts.  Sometimes bash is an easier fit.
This script is great for running commands generated by another script / cli.
It pretends to be the script it delegates to.  It also changes directory
before running the target script, assuming its identity and source location.

The former helps with commands that need being run in a tty shell / context,
for example if the target cli generated an ssh connection / command string.
The latter, for any extra files the script may need, such as configuration.


## Use

Bon works best when paired with node.js cli scripts. It makes use of
the `$NODE_MODULES` env var to `cd` into the target module's source directory.
Being packaged as a module itself helps with making it a dependency.
It offers convenient *convention over configuration* with node.js assumptions.

The target script needs not implement any commands / options - nor parse args.
That would mean most of the features remain unused, except for the path / check.


### Install

In order to run your commands from anywhere, install `bon` globally with
`npm install bon -g`.  If you want to make this automatic,
add the following to `package.json`:

```js
"scripts": {
  "preinstall": "npm i -g bon"
}
```

Of-course, your bon-enabled module should also be installed globally
so that its cli scripts can be found on the $PATH.

Bon depends on `coffee-script`.  If you rather not have that installed globally
as well, you'd have to add bon as a dependency so that `coffee` can be found.


### Convention

Naming the script command the same as its module name is expected as default.
Suppose your module is called `clier`, the entry in `package.json` should be
`"bin": { "clier" : "./node_modules/.bin/bon" }`, which looks for
`bin/clier.js`.  JavaScript is the default language, making the majority happy.
If CoffeeScript is preferred, just put the following code in it:

```js
#!/usr/bin/env node

require('coffee-script/register')
require('./clier.coffee')
```

Here is [an example](https://github.com/orlin/bon/tree/active/test/convention).


### Configuration

There are config vars that override `bon`'s defaults.
If bon is exclusively paired with a single node script,
exporting them to the shell environment is fine,
certainly fine to first try it this way.

The easier option for serious work is to have the vars set with the aid of
`bin/bonvars.sh` - bon will source it, making available whatever is `export`ed.
This comes with limitations. There can only be one bin script in `package.json`
that has to be named same as the module and again `bin/<name>.js` presence
is expected.  There are very few vars that can be customized - `BON_EVALIST`
and `BON_HELP` come to mind.

To customize anything, including all the paths / file names, refer to your own
script in `package.json` - e.g. `"bin": { "clirest" : "./bin/clier.sh" }`, and
source bon with it.  Here is how that is done:

```bash
#!/usr/bin/env bash

BON_NAME="clier" # must match module's name
BON_EXT="coffee" # $BON_SCRIPT would be "./bin/clier.coffee"
BON_SCRIPT="./bin/cli.coffee" #any path - ignoring BON_NAME and BON_EXT

source bon "$@" # provided bon is installed globally
```

The [configuration](https://github.com/orlin/bon/tree/active/test/configuration)
project contains some examples - testing what is described above as well as
illustrating use of the features below.


## Features

### Path Check

By default bon checks if it changed directory to the right place.
It assumes there is a `package.json` with its `name` matching `$BON_NAME`.

Perhaps your script is not a node.js one.  Check any `$BON_CHECK_FILE`,
perhaps set to "README.md", and provide a `$BON_CHECK_GREP`
text or regex to match / verify with.

If you choose to trust where bon takes you to,
or else if your script is location-independent - then
set `BON_CHECK="no"`, and the path check will be skipped.


### Meta Commands

This was the reason bon was created to begin with.
Set `$BON_EVALIST` to a list of space-separated commands.
These are commands that generate commands to to be `eval`led.
The `$BON_EVALIST` perhaps could be shared among scripts via global `export`,
thus it would be possible to skip configuration in favor of convention.

The generated commands are verified to be *one line* long.
This is to prevent accidental errors that may cause damage.
A trailing `\n` is ok, even several trailing newlines are ok -
bash simply ignores it as a feature.

To develop commands with the target script, and skip the eval, run
`<cli> line <evalgen> ...` where `<evalgen>` is a meta-command that is
being developed as part of a <cli> and `...` are some optional args it may take.


### Help

Set `$BON_HELP` to whatever option or command is to be used in place of no args.
For example `export BON_HELP="--help"` will turn a bon-enabled `<command>`
into `<command> --help`, as well as enable `command -?` to have the same effect.

If you want to show just `bon`'s help when calling your bin script without args,
use `BON_HELP=" "` - the empty space doesn't affect the target - no help option.
Even if the target has a help option, here it would have to be passed explicitly.

If you want to show your own help text instead of bon's default, set
`$BON_HELP_FILE` to a text file path, relative to the project's root directory.


## Test

[Bats](https://github.com/sstephenson/bats) is used for testing.
Do `npm run preptest` once, so that `npm test` will work.


## LICENSE

This is free and unencumbered public domain software.
For more information, see [UNLICENSE](http://unlicense.org).
