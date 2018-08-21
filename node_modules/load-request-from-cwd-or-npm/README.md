# load-request-from-cwd-or-npm

[![npm version](https://img.shields.io/npm/v/load-request-from-cwd-or-npm.svg)](https://www.npmjs.com/package/load-request-from-cwd-or-npm)
[![Build Status](https://travis-ci.org/shinnn/load-request-from-cwd-or-npm.svg?branch=master)](https://travis-ci.org/shinnn/load-request-from-cwd-or-npm)
[![Build status](https://ci.appveyor.com/api/projects/status/6iihj63cx8t3pkf6/branch/master?svg=true)](https://ci.appveyor.com/project/ShinnosukeWatanabe/load-request-from-cwd-or-npm/branch/master)
[![Coverage Status](https://img.shields.io/coveralls/shinnn/load-request-from-cwd-or-npm.svg)](https://coveralls.io/github/shinnn/load-request-from-cwd-or-npm)

Load [`request`](https://www.npmjs.com/package/request) module from either CWD or [npm](https://www.npmjs.com/) CLI directory.

## Why?

To keep project dependencies smaller.

```console
$ npm install request@2.83.0
$ du -sh ./node_modules
5.6M	./node_modules
```

```console
$ npm install load-request-from-cwd-or-npm@2.0.0
$ du -sh ./node_modules
> 300K	./node_modules
```

If `load-request-from-cwd-or-npm` is installed to your project directory, you can use `request` module in your program even though it's not actually installed.

Also we have an option to use one of the [`request` alternatives](https://www.npmjs.com/browse/keyword/request) with smaller file size, but none of them can deal with [a lot of edge cases related to networking and HTTP](https://github.com/request/request/tree/master/tests) as `request` does.

## Installation

[Use](https://docs.npmjs.com/cli/install) [npm](https://docs.npmjs.com/getting-started/what-is-npm).

```
npm install load-request-from-cwd-or-npm
```

## API

```javascript
const loadRequestFromCwdOrNpm = require('load-request-from-cwd-or-npm');
```

### loadRequestFromCwdOrNpm()

Return: `Promise<Function>`

It loads [`request`](https://github.com/request/request) module from either of these two directories:

1. [`node_modules`](https://docs.npmjs.com/files/folders#node-modules) in the [current working directory](https://nodejs.org/api/process.html#process_process_cwd)
2. `node_modules` in the directory where [`npm` CLI](https://github.com/npm/npm) [dependencies](https://github.com/npm/npm/blob/v5.6.0/package.json#L36-L131) are installed.

If `request` ins't installed in CWD, it loads `request` from npm CLI directory.

```javascript
// $ npm ls request
// > └── (empty)

(async () => {
  const request = await loadRequestFromCwdOrNpm();
  //=> {[Function: request] get: [Function], head: [Function], ...}
})();
```

If `request` is installed in CWD, it compares [package versions](https://docs.npmjs.com/files/package.json#version) of the CWD one and the npm dependency one, then loads the newer one.

```javascript
// $ npm ls request
// > └── request@1.9.9

(async () => {
  // Loaded from npm CLI directory because the CWD version is older
  const request = await loadRequestFromCwdOrNpm();
})();
```

The returned promise will be [fulfilled](https://promisesaplus.com/#point-26) with `request`, or [rejected](https://promisesaplus.com/#point-30) when it fails to find the module from either directories.

## License

[ISC License](./LICENSE) © 2017 Shinnosuke Watanabe
