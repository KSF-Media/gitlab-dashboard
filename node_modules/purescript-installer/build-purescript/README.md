# build-purescript

[![npm version](https://img.shields.io/npm/v/build-purescript.svg)](https://www.npmjs.com/package/build-purescript)
[![Build Status](https://travis-ci.com/shinnn/build-purescript.svg?branch=master)](https://travis-ci.com/shinnn/build-purescript)
[![Coverage Status](https://img.shields.io/coveralls/shinnn/build-purescript.svg)](https://coveralls.io/github/shinnn/build-purescript?branch=master)

A [Node.js](https://nodejs.org) module to build a [PureScript](http://www.purescript.org/) binary from source

```javascript
const {execFile} = require('child_process');
const buildPurescript = require('build-purescript');

buildPurescript().subscribe({
  complete() {
    console.log('Build completed.');

    execFile('./purs', ['--help'], (err, stdout) => {
      stdout.toString(); //=> 'Usage: purs COMMAND\n  The PureScript compiler and tools ...'
    });
  }
});
```

## Installation

Make sure [`stack`](https://github.com/commercialhaskell/stack) command is [installed](https://docs.haskellstack.org/en/stable/README/#how-to-install) in your `$PATH`, then [install](https://docs.npmjs.com/cli/install) `build-purescript` via [npm](https://docs.npmjs.com/getting-started/what-is-npm) CLI.

```
npm install build-purescript
```

## API

```javascript
const buildPurescript = require('build-purescript');
```

### buildPurescript([*options*])

*options*: `Object`  
Return: [`Observable`](https://github.com/tc39/proposal-observable#observable) ([Kevin Smith's implementation](https://github.com/zenparsing/zen-observable))

When the `Observable` is [subscribe](https://tc39.github.io/proposal-observable/#observable-prototype-subscribe)d, it starts to download PureScript source from [the GitHub repository](https://github.com/purescript/purescript), build it and put a built binary onto [the current working directory](https://nodejs.org/api/process.html#process_process_cwd), successively sending event objects to its [`Observer`](https://github.com/tc39/proposal-observable#observer).

#### Events

Each event object has `id` property with one of these values:

* [`download`](https://github.com/shinnn/build-purescript#download)
* [`download:complete`](https://github.com/shinnn/build-purescript#downloadcomplete)
* [`setup`](https://github.com/shinnn/build-purescript#setup)
* [`setup:complete`](https://github.com/shinnn/build-purescript#setupcomplete)
* [`build`](https://github.com/shinnn/build-purescript#build)
* [`build:complete`](https://github.com/shinnn/build-purescript#buildcomplete)

##### `download`

Sent to the `Observer` while downloading and extracting the PureScript source archive to [the default temporary directory of the current OS](https://nodejs.org/api/os.html#os_os_tmpdir).

[`entry`](https://github.com/shinnn/dl-tar#entry) and [`response`](https://github.com/shinnn/dl-tar#response) properties are derived from [`dl-tar`](https://github.com/shinnn/dl-tar).

```javascript
{
  id: 'download',
  entry: <ReadEntry>,
  response: {
    bytes: <number>,
    headers: <Object>,
    url: <string>
  }
}
```

##### `download:complete`

Sent to the `Observer` when the PureScript source is completely downloaded.

```javascript
{
  id: 'download:complete'
}
```

##### `setup`

Sent to the `Observer` while running [`stack setup`](https://docs.haskellstack.org/en/stable/GUIDE/#stack-setup) command.

`command` property is the command currently running, and `output` property is each line of stderr.

```javascript
{
  id: 'setup',
  command 'stack setup ...',
  output: <string>
}
```

##### `setup:complete`

Sent to the `Observer` when `stack setup` command exits with code `0`.

```javascript
{
  id: 'setup:complete'
}
```

##### `build`

Sent to the `Observer` while running [`stack install`](https://docs.haskellstack.org/en/stable/GUIDE/#stack-build) command.

`command` property is the command currently running, and `output` property is each line of stderr.

```javascript
{
  id: 'build',
  command 'stack install ...',
  output: <string>
}
```

##### `build:complete`

Sent to the `Observer` when `stack install` command exits with code `0`.

```javascript
{
  id: 'build:complete'
}
```

```javascript
(async () => {
  await downloadPurescript().filter(({id}) => id.endsWith(':complete')).forEach(({id}) => {
    console.log(`✓ ${id.replace(':complete', '')}`);
  });

  console.log('\nCompleted.');
})();
```

```
✓ download
✓ setup
✓ build

Completed.
```

#### Errors

Each error passed to the `Observer` have `id` property that indicates which step the error occurred at.

```javascript
// When your machine have no network connection
buildPureScript().subscribe({
  error(err) {
    err.message; //=> 'getaddrinfo ENOTFOUND github.com github.com:443'
    err.id; //=> 'download'
  }
});

// When the `stack` command is not installed
buildPureScript().subscribe({
  error(err) {
    err.message; //=> '`stack` command is not found in your PATH ...'
    err.id; //=> 'setup'
  }
});
```

#### Options

Options are directly passed to the underlying [`donwload-purescript-source`](https://github.com/shinnn/download-purescript-source) and [`spawn-stack`](https://github.com/shinnn/spawn-stack). Also you can use the following:

##### args

Type: `Array<string>`  

Additional command-line arguments passed to `stack setup` and `stack install`. Note:

* `--local-bin-path` is automatically set to the first argument of `buildPurescript`.
* Build-only flags, for example `--fast` and `--pedantic`, won't be passed to `stack setup`.

## License

[ISC License](./LICENSE) © 2017 - 2019 Shinnosuke Watanabe
