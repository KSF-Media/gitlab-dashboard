# download-purescript

[![npm version](https://img.shields.io/npm/v/download-purescript.svg)](https://www.npmjs.com/package/download-purescript)
[![Build Status](https://travis-ci.com/shinnn/download-purescript.svg?branch=master)](https://travis-ci.com/shinnn/download-purescript)
[![Coverage Status](https://img.shields.io/coveralls/shinnn/download-purescript.svg)](https://coveralls.io/github/shinnn/download-purescript?branch=master)

A [Node.js](https://nodejs.org) module to download a prebuilt [PureScript](https://github.com/purescript/purescript) binary

```javascript
const {readdir} = require('fs').promises;
const downloadPurescript = require('download-purescript');

downloadPurescript().subscribe({
  async complete() {
    (await readdir('.')).includes('purs'); //=> true
  }
});
```

## Installation

[Use](https://docs.npmjs.com/cli/install) [npm](https://docs.npmjs.com/about-npm/).

```
npm install download-purescript
```

## API

```javascript
const downloadPurescript = require('download-purescript');
```

### downloadPurescript([*options*])

*options*: `Object`  
Return: [`Observable`](https://github.com/tc39/proposal-observable#observable) ([Kevin Smith's implementation](https://github.com/zenparsing/zen-observable))

When the `Observable` is [subscribe](https://tc39.github.io/proposal-observable/#observable-prototype-subscribe)d, it starts to download a `tar.gz` archive of a PureScript binary for the current platform from the [release page](https://github.com/purescript/purescript/releases), extract it to [the current working directory](https://nodejs.org/api/process.html#process_process_cwd) and successively send [dl-tar](https://github.com/shinnn/dl-tar)'s [`progress` objects](https://github.com/shinnn/dl-tar#progress) to its [`Observer`](https://github.com/tc39/proposal-observable#observer).

## Options

You can pass options to [Request](https://github.com/request/request#requestoptions-callback) and [node-tar](https://github.com/npm/node-tar)'s [`Unpack` constructor](https://github.com/npm/node-tar#class-tarunpack). Note that:

* [`strip` option](https://github.com/npm/node-tar#constructoroptions-1) defaults to `1` and can't be changed.
* All files except for `purs` and `purs.exe`, for example `README`, won't be downloaded by default. Pass `() => true` to `filter` option if you want to download all files included in the archive.
* `followRedirect` option defaults to `true` and cannot be disabled.

Additionally, you can use the following:

### version

Type: `string`  
Default: [`0.12.5`](https://github.com/purescript/purescript/releases/tag/v0.12.5)

Specify the version you want to download.

```javascript
const {execFileSync} = require('child_process');

downloadPurescript({version: '0.12.4'}).subscribe({
  complete() {
    execFileSync('./purs', ['--version'], {encoding: 'utf8'}).trim(); //=> '0.12.4' (not '0.12.5')
  }
});
```

## Error codes

Some errors emitted by this function have a peculiar [`code`](https://nodejs.org/api/errors.html#errors_error_code) property.

### ERR_UNSUPPORTED_ARCH

The CPU architecture of the currently running operating system is not 64-bit.

### ERR_UNSUPPORTED_PLATFORM

No prebuilt binary is provided for the current platform.

## License

[ISC License](./LICENSE) © 2017 - 2019 Shinnosuke Watanabe
