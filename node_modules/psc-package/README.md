# [psc-package](https://github.com/purescript/psc-package) wrapper for [Node.js](https://nodejs.org/)

[![NPM version](http://img.shields.io/npm/v/psc-package.svg)](https://www.npmjs.com/package/psc-package)
[![Build Status](http://img.shields.io/travis/joneshf/node-psc-package-bin.svg)](http://travis-ci.org/joneshf/node-psc-package-bin)
[![Coverage Status](https://img.shields.io/coveralls/joneshf/node-psc-package-bin.svg)](https://coveralls.io/github/joneshf/node-psc-package-bin?branch=master)
[![dependencies Status](https://david-dm.org/joneshf/node-psc-package-bin/status.svg)](https://david-dm.org/joneshf/node-psc-package-bin)
[![devDependencies Status](https://david-dm.org/joneshf/node-psc-package-bin/dev-status.svg)](https://david-dm.org/joneshf/node-psc-package-bin?type=dev)

[psc-package](https://github.com/purescript/psc-package) binary wrapper that makes it seamlessly available via [npm](https://www.npmjs.com/)

## Installation

[Use npm](https://docs.npmjs.com/cli/install) after making sure your development environment satisfies [the requirements](https://github.com/purescript/purescript/blob/ab5f139336c7343009e88c13b29c9cdf566b1713/INSTALL.md#the-curses-library).

```
npm install psc-package
```

## API

### require('psc-package')

Type: `String`

The path to the `psc-package` binary.

## CLI

You can use it via CLI by installing it [globally](https://docs.npmjs.com/files/folders#global-installation).

```
npm install -g psc-package

psc-package --help
```

## License

Copyright (c) 2015 - 2017 [Shinnosuke Watanabe](https://github.com/shinnn)

Licensed under [the MIT License](./LICENSE).
