# download-purescript-source

[![npm version](https://img.shields.io/npm/v/download-purescript-source.svg)](https://www.npmjs.com/package/download-purescript-source)
[![Build Status](https://travis-ci.com/shinnn/download-purescript-source.svg?branch=master)](https://travis-ci.com/shinnn/download-purescript-source)
[![Coverage Status](https://img.shields.io/coveralls/shinnn/download-purescript-source.svg)](https://coveralls.io/github/shinnn/download-purescript-source?branch=master)

A [Node.js](https://nodejs.org) module to download [PureScript](https://github.com/purescript/purescript) source from [GitHub](https://github.com/)

```javascript
const {readdir} = require('fs').promises;
const downloadPurescript = require('download-purescript-source');

downloadPurescript('./dest/').subscribe({
  async complete() {
    await readdir('./dest/'); /*=> [
      'LICENSE',
      'Makefile',
      'Setup.hs',
      'app',
      'bundle',
      'core-tests',
      'license-generator',
      'package.yaml',
      'src',
      'stack.yaml',
      'tests'
    ] */
  }
});
```

## Installation

[Use](https://docs.npmjs.com/cli/install) [npm](https://docs.npmjs.com/about-npm/).

```
npm install download-purescript-source
```

## API

```javascript
const downloadPurescriptSource = require('download-purescript-source');
```

### downloadPurescriptSource(*dir* [, *options*])

*dir*: `string` (a directory path where the PureScript source will be downloaded)  
*options*: `Object`  
Return: [`Observable`](https://github.com/tc39/proposal-observable#observable) ([Kevin Smith's implementation](https://github.com/zenparsing/zen-observable))

When the `Observable` is [subscribe](https://tc39.github.io/proposal-observable/#observable-prototype-subscribe)d, it starts to download a `tar.gz` archive from the [PureScript GitHub repository](https://github.com/purescript/purescript), extract it and successively send [dl-tar](https://github.com/shinnn/dl-tar)'s [`progress` objects](https://github.com/shinnn/dl-tar#progress) to its [`Observer`](https://github.com/tc39/proposal-observable#observer).

```javascript
downloadPurescriptSource('my/dir')
.filter(({entry}) => entry.remain === 0)
.forEach(({entry}) => console.log(`✓ ${entry.header.path.replace(/^[^/]*\//, '')}`))
.then(() => console.log('\nCompleted.'));
```

```
✓ LICENSE
✓ Makefile
✓ Setup.hs
✓ app/
✓ app/Command/
✓ app/Command/Bundle.hs
✓ app/Command/Compile.hs
✓ app/Command/Docs.hs
✓ app/Command/Docs/
✓ app/Command/Docs/Html.hs
︙
✓ tests/support/pscide/src/RebuildSpecWithDeps.purs
✓ tests/support/pscide/src/RebuildSpecWithForeign.js
✓ tests/support/pscide/src/RebuildSpecWithForeign.purs
✓ tests/support/pscide/src/RebuildSpecWithHiddenIdent.purs
✓ tests/support/pscide/src/RebuildSpecWithMissingForeign.fail
✓ tests/support/setup-win.cmd

Completed.
```

## Options

You can pass options to [Request](https://github.com/request/request#requestoptions-callback) and [node-tar](https://github.com/npm/node-tar)'s [`Unpack` constructor](https://github.com/npm/node-tar#class-tarunpack). Note that:

* [`strip` option](https://github.com/npm/node-tar#constructoroptions-1) defaults to `1` and can't be changed. That means the top level directory is always stripped off.
* By default it won't download any `*{md,yml}` files, some specific [files](https://github.com/shinnn/download-purescript-source/blob/33c2212958b87b33f9ba9a35c5dfc5ce748bb3e8/index.js#L27-L29) and [directories](https://github.com/shinnn/download-purescript-source/blob/03e76031d6e322bc07c0290df2d7e0f3040239ee/index.js#L20-L22) that are unnecessary for building the binary. Pass `() => true` to the `filter` option if you want to download all files included in the archive.
* `onentry` option is not supported.

Additionally, you can use the following:

### revision

Type: `string`  
Default: [`v0.12.5`](https://github.com/purescript/purescript/tree/v0.12.5)

Specify the commit hash, tag or branch name you want to download.

## License

[ISC License](./LICENSE) © 2017 - 2019 Shinnosuke Watanabe
