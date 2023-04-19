# install-purescript

[![npm version](https://img.shields.io/npm/v/install-purescript.svg)](https://www.npmjs.com/package/install-purescript)
[![Build Status](https://travis-ci.com/shinnn/install-purescript.svg?branch=master)](https://travis-ci.com/shinnn/install-purescript)
[![codecov](https://codecov.io/gh/shinnn/install-purescript/branch/master/graph/badge.svg)](https://codecov.io/gh/shinnn/install-purescript)

Install [PureScript](https://github.com/purescript/purescript) to a given directory

```javascript
cconst {execFile} = require('child_process');
const installPurescript = require('install-purescript');

installPurescript({version: '0.13.0'}).subscribe({
  next(event) {
    if (event.id === 'search-cache' && event.found) {
      console.log('✓ Found a cache.');
      return;
    }

    if (event.id === 'restore-cache:complete') {
      console.log('✓ Cached binary restored.');
      return;
    }

    if (event.id === 'check-binary:complete') {
      console.log('✓ Binary works correctly.');
      return;
    }
  }
  complete() {
    execFile('./purs', ['--version'], (err, stdout) => {
      stdout.toString(); //=> '0.13.0\n'
    });
  }
});
```

## Installation

[Use](https://docs.npmjs.com/cli/install) [npm](https://docs.npmjs.com/about-npm/).

```
npm install install-purescript
```

## API

```javascript
const installPurescript = require('install-purescript');
```

### installPurescript([*options*])

*options*: `Object`  
Return: [`Observable`](https://github.com/tc39/proposal-observable#observable) ([Kevin Smith's implementation](https://github.com/zenparsing/zen-observable))

When the `Observable` is [subscribe](https://tc39.github.io/proposal-observable/#observable-prototype-subscribe)d,

1. it searches [the standard cache directory](https://github.com/shinnn/app-cache-dir) for an already cached PureScript binary, and restores the cache if available
3. if a cached binary is not available, it downloads a prebuilt binary from the [PureScript release page](https://github.com/purescript/purescript/releases)
4. if a prebuilt binary is not available, it downloads [the PureScript source code](https://github.com/purescript/purescript) and [builds](https://github.com/purescript/purescript/blob/master/INSTALL.md#compiling-from-source) a binary form it
5. Cache the downloaded or built binary to the [npm cache directory](https://docs.npmjs.com/files/folders#cache)

while successively sending [events](#events) to its [`Observer`](https://github.com/tc39/proposal-observable#observer).

#### Events

Every event object has `id` property with one of these values:

[group1]: #head-headfail-headcomplete-download-binary-download-binaryfail-download-binarycomplete-check-stack-check-stackcomplete-download-source-download-sourcecomplete
[group2]: #setup-setupcomplete-build-buildcomplete

* [`search-cache`](#search-cache)
* [`restore-cache`](#restore-cache)
* [`restore-cache:fail`](#restore-cachefail)
* [`restore-cache:complete`](#restore-cachecomplete)
* [`check-binary`](#check-binary)
* [`check-binary:fail`](#check-binaryfail)
* [`check-binary:complete`](#check-binarycomplete)
* [`head`][group1]
* [`head:fail`][group1]
* [`head:complete`][group1]
* [`download-binary`][group1]
* [`download-binary:fail`][group1]
* [`download-binary:complete`][group1]
* [`check-stack`][group1]
* [`check-stack:complete`][group1]
* [`download-source`][group1]
* [`download-source:complete`][group1]
* [`setup`][group2]
* [`setup:complete`][group2]
* [`build`][group2]
* [`build:complete`][group2]
* [`write-cache`](#write-cache)
* [`write-cache:fail`](#write-cachefail)
* [`write-cache:complete`](#write-cachecomplete)

```
 |
search-cache -- x -+- head ------------ x -+- check-stack ----- x -+
 |                 |   |                   |   |                   |
 o                 |   o                   |   o                   |
 |                 |   |                   |   |                   |
restore-cache - x -+  download-binary - x -+  download-source - x -+
 |                 |   |                   |   |                   |
 o                 |   o                   |   o                   |
 |                 |   |                   |   |                   |
check-binary -- x -+  check-binary ---- x -+  setup ----------- x -+
 |                     |                       |                   |
 o                     |                       o                   |
 |                     |                       |                   |
 |                     |                      build ----------- x -+
 |                     |                       |                   |
 |                     o                       o                   |
 |                     |                       |                   |
*******************   *****************       *****************   ^^^^^^^
 Restored a            Downloaded a            Built a binary      Error
 binary from cache     prebuilt binary         from the source    ^^^^^^^
*******************   *****************       *****************
                       |                       |
                      write-cache             write-cache
```

##### `search-cache`

Fires when it checks if a `tgz` archive of the required PureScript binary exists in the cache directory.

```javascript
{
  id: 'search-cache',
  path: <string>, // path to the cache file
  found: <boolean> // whether a cache is found or not
}
```

##### `restore-cache`

Fires when it starts to extract a binary from the cached `tgz` archive.

```javascript
{
  id: 'restore-cache'
}
```

##### `restore-cache:fail`

Fires when it fails to restore the binary from cache.

```javascript
{
  id: 'restore-cache:fail',
  error: <Error>
}
```

##### `restore-cache:complete`

Fires when the cached binary is successfully restored.

```javascript
{
  id: 'restore-cache:complete'
}
```

##### `check-binary`

Fires when it starts to verify the cached or downloaded binary works correctly, by running `purs --version`.

```javascript
{
  id: 'check-binary'
}
```

##### `check-binary:fail`

Fires when the cached or downloaded binary doesn't work correctly.

```javascript
{
  id: 'check-binary:fail',
  error: <Error>
}
```

##### `check-binary:complete`

Fires when it verifies the cached or downloaded binary works correctly.

```javascript
{
  id: 'check-binary:complete'
}
```

##### [`head`](https://github.com/shinnn/download-or-build-purescript#head) [`head:fail`](https://github.com/shinnn/download-or-build-purescript#headfail) [`head:complete`](https://github.com/shinnn/download-or-build-purescript#headcomplete) [`download-binary`](https://github.com/shinnn/download-or-build-purescript#download-binary) [`download-binary:fail`](https://github.com/shinnn/download-or-build-purescript#download-binaryfail) [`download-binary:complete`](https://github.com/shinnn/download-or-build-purescript#download-binarycomplete) [`check-stack`](https://github.com/shinnn/download-or-build-purescript#check-stack) [`check-stack:complete`](https://github.com/shinnn/download-or-build-purescript#check-stackcomplete) [`download-source`](https://github.com/shinnn/download-or-build-purescript#download-source) [`download-source:complete`](https://github.com/shinnn/download-or-build-purescript#download-sourcecomplete)

Inherited from [`download-or-build-purescript`](https://github.com/shinnn/download-or-build-purescript#events).

##### [`setup`](https://github.com/shinnn/build-purescript#setup) [`setup:complete`](https://github.com/shinnn/build-purescript#setupcomplete) [`build`](https://github.com/shinnn/build-purescript#build) [`build:complete`](https://github.com/shinnn/build-purescript#buildcomplete)

Inherited from [`build-purescript`](https://github.com/shinnn/build-purescript#events).

##### `write-cache`

Fires when it starts to create a cache.

```javascript
{
  id: 'write-cache',
}
```

##### `write-cache:fail`

Fires when it fails to create the cache.

```javascript
{
  id: 'write-cache:fail',
  error: <Error>
}
```

##### `write-cache:complete`

Fires when the cache is successfully created.

```javascript
{
  id: 'write-cache:complete'
}
```

#### Errors

Every error passed to the `Observer` has `id` property that indicates which step the error occurred at.

```javascript
// When the `stack` command is not installed
installPurescript('.').subscribe({
  error(err) {
    err.message; //=> '`stack` command is not found in your PATH ...'
    err.id; //=> 'check-stack'
  }
});

// When your machine lose the internet connection while downloading the source
installPurescript('.').subscribe({
  error(err) {
    err.message; //=> 'socket hang up'
    err.id; //=> 'download-source'
  }
});
```

#### Options

Options are directly passed to [`download-or-build-purescript`](https://github.com/shinnn/download-or-build-purescript#options).

Additionally, you can use the following:

##### forceReinstall

Type: `boolean`  
Default: `false`

Force reinstalling a binary even if an appropriate cache already exists.

## Related projects

* [install-purescript-cli](https://github.com/shinnn/install-purescript-cli) — CLI for this module
* [download-or-build-purescript](https://github.com/shinnn/download-or-build-purescript) — Almost the same as this module, but has no cache feature

## License

[ISC License](./LICENSE) © 2017 - 2019 Watanabe Shinnosuke
