# purescript-installer

A command-line tool to install [PureScript](https://github.com/purescript/purescript) to the current working directory

1. First, it checks if a PureScript binary has been already cached in a disk, and restores that if available
2. The second plan: if no cache is available, it downloads a prebuilt binary from [the PureScript release page](https://github.com/purescript/purescript/releases).
3. The last resort: if no prebuilt binary is provided for the current platform or the downloaded binary doesn't work correctly, it downloads [the PureScript source code](https://github.com/purescript/purescript/tree/master) and compile it with [Stack](https://docs.haskellstack.org/).

*In most cases users don't need to install this CLI directly, but would rather use the [`purescript` npm package](https://npmjs.com/package/purescript).*

## Installation

[Use](https://docs.npmjs.com/cli/install) [npm](https://docs.npmjs.com/about-npm/).

```
npm install purescript-installer
```

## CLI

Once this package is installed to the project directory, users can execute `install-purescript` command inside [npm scripts](https://docs.npmjs.com/misc/scripts#description).

```
Usage:
install-purescript [options]

Options:
--purs-ver <string> Specify PureScript version
--name     <string> Change a binary name
                        Default: 'purs.exe' on Windows, 'purs' on others
                        Or, if the current working directory contains package.json
                        with `bin` field specifying a path of `purs` command,
                        this option defaults to its value
--help,             Print usage information
--version           Print version

Also, these flags are passed to `stack install` command if provided:
--dry-run
--pedantic
--fast
--only-snapshot
--only-dependencies
--only-configure
--trace
--profile
--no-strip
--coverage
--no-run-tests
--no-run-benchmarks
```

## Developer Guide

If you'd like to contribute to this project, here are instructions for testing your changes locally:

Checkout code and create global link to PS installer package:
```
git clone https://github.com/purescript/npm-installer.git
cd npm-installer
npm link
```

Create another project for testing, and add linked PS installer:
```
cd ..
mkdir test-installer
cd test-installer
npm init -y
npm link purescript-installer
```

Test PS installer. You may re-run this command without repeating any of the above steps to pick-up new PS installer changes.
```
npx install-purescript
```

## License

[ISC License](./LICENSE) © 2017 - 2019 Watanabe Shinnosuke
