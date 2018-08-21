# download-or-build-purescript

[![npm version](https://img.shields.io/npm/v/download-or-build-purescript.svg)](https://www.npmjs.com/package/download-or-build-purescript)
[![Build Status](https://travis-ci.org/shinnn/download-or-build-purescript.svg?branch=master)](https://travis-ci.org/shinnn/download-or-build-purescript)
[![Build status](https://ci.appveyor.com/api/projects/status/of6y6qg95jyvwylp/branch/master?svg=true)](https://ci.appveyor.com/project/ShinnosukeWatanabe/download-or-build-purescript/branch/master)
[![Coverage Status](https://img.shields.io/coveralls/shinnn/download-or-build-purescript.svg)](https://coveralls.io/github/shinnn/download-or-build-purescript?branch=master)

First try to download a prebuilt [PureScript](http://www.purescript.org/) binary, then build from a source if the prebuilt one is unavailable

```javascript
const {readdirSync} = require('fs');
const {spwan} = require('child_process');
const downloadOrBuildPurescript = require('download-or-build-purescript');

downloadOrBuildPurescript('./dest', {version: '0.11.7'}).subscribe({
  next(event) {
    if (event.id === 'head:complete') {
      console.log('✓ Prebuilt binary exists.');
      return;
    }

    if (event.id === 'download-binary:complete') {
      console.log('✓ Binary downloaded.');
      return;
    }

    if (event.id === 'check-binary:complete') {
      console.log('✓ Binary works correctly.');
      return;
    }
  }
  complete() {
    readdirSync('dest'); //=> ['purs']
    spwan('./dest/purs', ['--version'], (err, stdout) => {
      stdout.toString(); //=> '0.11.7\n'
    });
  }
});
```

## Installation

[Use npm.](https://docs.npmjs.com/cli/install)

```
npm install download-or-build-purescript
```

## API

```javascript
const downloadOrBuildPurescript = require('download-or-build-purescript');
```

### downloadOrBuildPurescript(*dir* [, *options*])

*path*: `String` (a directory path where the PureScript binary will be installed)  
*options*: `Object`  
Return: [`Observable`](https://github.com/tc39/proposal-observable#observable) ([zenparsing's implementation](https://github.com/zenparsing/zen-observable))

When the `Observable` is [subscribe](https://tc39.github.io/proposal-observable/#observable-prototype-subscribe)d,

1. it downloads a prebuilt PureScript binary from the [PureScript release page](https://github.com/purescript/purescript/releases)
2. if a prebuilt binary is not available, it downloads [the PureScript source code](https://github.com/purescript/purescript) and [builds](https://github.com/purescript/purescript/blob/master/INSTALL.md#compiling-from-source) a binary form it

while successively sending [events](#events) to its [`Observer`](https://github.com/tc39/proposal-observable#observer).

#### Events

Each event object has `id` property with one of these values:

* [`head`](#head)
* [`head:fail`](#headfail)
* [`head:complete`](#headcomplete)
* [`download-binary`](#download-binary)
* [`download-binary:fail`](#download-binaryfail)
* [`download-binary:complete`](#download-binarycomplete)
* [`check-binary`](#check-binary)
* [`check-binary:fail`](#check-binaryfail)
* [`check-binary:complete`](#check-binarycomplete)
* [`check-stack`](#check-stack)
* [`check-stack:complete`](#check-stackcomplete)
* [`download-source`](#download-source)
* [`download-source:complete`](#download-sourcecomplete)
* [`setup`](#setup-setupcomplete-build-buildcomplete)
* [`setup:complete`](#setup-setupcomplete-build-buildcomplete)
* [`build`](#setup-setupcomplete-build-buildcomplete)
* [`build:complete`](#setup-setupcomplete-build-buildcomplete)

```
head ------------ x -+- check-stack ----- x -+
 |                   |   |                   |
 o                   |   o                   |
 |                   |   |                   |
download-binary - x -+  download-source - x -+
 |                   |   |                   |
 o                   |   o                   |
 |                   |   |                   |
check-binary ---- x -+  setup ----------- x -+
 |                       |                   |
 |                       o                   |
 |                       |                   |
 |                      build ----------- x -+
 |                       |                   |
 o                       o                   |
 |                       |                   |
*****************       *****************   ^^^^^^^
 Downloaded a            Built a binary      Error
 prebuilt binary         from the source    ^^^^^^^
*****************       *****************
```

##### `head`

Fires when it starts to check if a prebuilt binary is provided for the current platform.

```javascript
{
  id: 'head'
}
```

##### `head:fail`

Fires when it cannot start downloading the binary, for example no prebuilt ones are provided for the current platform.

```javascript
{
  id: 'head:fail',
  error: <Error>
}
```

##### `head:complete`

Fires when it confirms that a prebuilt binary is provided for the current platform.

```javascript
{
  id: 'head:complete'
}
```

##### `download-binary`

Fires many times while downloading and extracting the prebuilt binary.

[`entry`](https://github.com/shinnn/dl-tar#entry) and [`response`](https://github.com/shinnn/dl-tar#response) properties are derived from [`dl-tar`](https://github.com/shinnn/dl-tar).

```javascript
{
  id: 'download-binary',
  entry: {
    bytes: <number>,
    header: <Object>
  },
  response: {
    bytes: <number>,
    headers: <Object>,
    url: <string>
  }
}
```

##### `download-binary:fail`

Fires when it fails to download the binary somehow.

```javascript
{
  id: 'download-binary:fail',
  error: <Error>
}
```

##### `download-binary:complete`

Fires when the prebuilt binary is successfully downloaded.

```javascript
{
  id: 'download-binary:complete'
}
```

##### `check-binary`

Fires when it starts to verify the downloaded prebuilt binary works correctly, by running `purs --version`.

```javascript
{
  id: 'check-binary'
}
```

##### `check-binary:fail`

Fires when the downloaded binary doesn't work correctly.

```javascript
{
  id: 'check-binary:fail',
  error: <Error>
}
```

##### `check-binary:complete`

Fires when it verifies the downloaded binary works correctly.

```javascript
{
  id: 'check-binary:complete'
}
```

##### `check-stack`

Fires after one of these events: [`head:fail`](#headfail) [`download-binary:fail`](download-binaryfail) [`check-binary:fail`](check-binaryfail).

`path` property is the absolute path of the `stack` command, and `version` property is its version.

```javascript
{
  id: 'check-stack',
  path: <string>,
  version: <string>
}
```

##### `check-stack:complete`

Fires after making sure the [`stack`](https://docs.haskellstack.org/en/stable/README/) command is installed in your `$PATH`.

```javascript
{
  id: 'check-binary:complete'
}
```

##### `download-source`

Fires many times while [downloading and extracting the PureScript source code](https://github.com/shinnn/download-purescript-source).

[`entry`](https://github.com/shinnn/dl-tar#entry) and [`response`](https://github.com/shinnn/dl-tar#response) properties are derived from [`dl-tar`](https://github.com/shinnn/dl-tar).

```javascript
{
  id: 'download-source',
  entry: {
    bytes: <number>,
    header: <Object>
  },
  response: {
    bytes: <number>,
    headers: <Object>,
    url: <string>
  }
}
```

##### `download-source:complete`

Fires when the source code is successfully downloaded.

```javascript
{
  id: 'download-source'
}
```

##### [`setup`](https://github.com/shinnn/build-purescript#setup) [`setup:complete`](https://github.com/shinnn/build-purescript#setupcomplete) [`build`](https://github.com/shinnn/build-purescript#build) [`build:complete`](https://github.com/shinnn/build-purescript#buildcomplete)

Inherited from [`build-purescript`](https://github.com/shinnn/build-purescript#progress-object).

#### Errors

Every error passed to the `Observer` has `id` property that indicates which step the error occurred at.

```javascript
// When the `stack` command is not installed
downloadOrBuildPureScript('.').subscribe({
  error(err) {
    err.message; //=> '`stack` command is not found in your PATH ...'
    err.id; //=> 'check-stack'
  }
});

// When your machine lose the internet connection while downloading the source
downloadOrBuildPureScript('.').subscribe({
  error(err) {
    err.message; //=> 'socket hang up'
    err.id; //=> 'download-source'
  }
});
```

#### `onComplete` value

Type: `string` (an absolute path of the created binary)

Unlike [the current draft spec of `Observable`](https://tc39.github.io/proposal-observable/), [`zen-observable` allows an `Observable` to send value to the `complete` fallback](https://github.com/zenparsing/zen-observable/issues/27) and this library follows its behavior.

```javascript
downloadOrBuildPurescript('/my/dir').subscribe({
  complete(path) {
    path; //=> '/my/dir/purs'
  }
});
```

#### Options

Options are directly passed to [`download-purescript`](https://github.com/shinnn/download-purescript) and [`build-purescript`](https://github.com/shinnn/build-purescript).

Note that when the [`platform` option](https://github.com/shinnn/download-purescript#platform) is specified to the different platform:

* `check-binary` and `check-binary:complete` steps will be skipped.
* `*:fail` steps will be skipped and it just pass the error to its `Observer`.

Additionally, you can use the following:

##### rename

Type: `Function`  
Default: `v => v`

Receives the original binary name (`purs` on POSIX, `purs.exe` on Windows) and modifies the binary name to its return value.

```javascript
const {extname} = require('path');

downloadOrBuildPurescript('./dest', {
  rename(originalName) {
    const ext = extname(originalName); //=> '' on POSIX, '.exe' on Windows

    return `foo${ext}`;
  }
}).subscribe({
  complete() {
    // Creates a binary to './dest/foo' on POSIX, './dest/foo.exe' on Windows
  }
});
```

## License

[ISC License](./LICENSE) © 2017 - 2018 Shinnosuke Watanabe
