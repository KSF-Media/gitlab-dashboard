# spawn-stack

[![npm version](https://img.shields.io/npm/v/spawn-stack.svg)](https://www.npmjs.com/package/spawn-stack)
[![Build Status](https://travis-ci.org/shinnn/spawn-stack.svg?branch=master)](https://travis-ci.org/shinnn/spawn-stack)
[![Build status](https://ci.appveyor.com/api/projects/status/stybf1ffx07eejur/branch/master?svg=true)](https://ci.appveyor.com/project/ShinnosukeWatanabe/spawn-stack/branch/master)
[![Coverage Status](https://coveralls.io/repos/github/shinnn/spawn-stack/badge.svg?branch=master)](https://coveralls.io/github/shinnn/spawn-stack?branch=master)

[Spawn](https://en.wikipedia.org/wiki/Spawn_(computing)) a new process using [`stack`](https://docs.haskellstack.org/en/stable/README/) command with the given arguments

```javascript
const spawnStack = require('spawn-stack');

spawnStack(['--version']).then(result => {
  result.output; //=> 'Version 1.7.1 x86_64 ...'
});
```

## Installation

Make sure [`stack`](https://github.com/commercialhaskell/stack) command is [installed](https://docs.haskellstack.org/en/stable/README/#how-to-install) in your `$PATH`, then [install](https://docs.npmjs.com/cli/install) `spawn-stack` via [npm](https://docs.npmjs.com/getting-started/what-is-npm) CLI.

```
npm install spawn-stack
```

## API

```javascript
const spawnStack = require('spawn-stack');
```

### spawnStack(*args* [, *options*])

*args*: `Array<string>` (command line arguments passed to `stack` command)  
*options*: `Object` (`execa` options, with [`preferLocal`](https://github.com/sindresorhus/execa#preferlocal) defaulting to `false`)  
Return: [`ChildProcess`](https://nodejs.org/api/child_process.html#child_process_class_childprocess)

It returns the same value as [`execa`](https://github.com/sindresorhus/execa#execafile-arguments-options)'s:

> a `child_process` instance, which is enhanced to also be a `Promise` for a result `Object` with `stdout` and `stderr` properties.

On POSIX, [`--allow-different-user`](https://github.com/commercialhaskell/stack/blob/v1.5.1/doc/yaml_configuration.md#allow-different-user) flag will be automatically enabled to prevent file permission problems, unless `--no-allow-different-user` flag is explicitly provided.

```javascript
process.platform !== 'win32'; //=> true

spawnStack(['--numeric-version']).then(result => {
  result.cmd; // 'stack --allow-different-user --numeric-version'
});

spawnStack(['--no-allow-different-user', '--numeric-version']).then(result => {
  result.cmd; // 'stack --no-allow-different-user --numeric-version'
});
```

The return value also has [`Symbol.observable`](https://tc39.github.io/proposal-observable/#observable-prototype-@@observable) method that returns a [zen-observable](https://github.com/zenparsing/zen-observable) instance passing each line of `stderr` to its [`Subscription`](https://tc39.github.io/proposal-observable/#subscription-objects). That means you can convert the return value into an [`Observable`](https://github.com/tc39/proposal-observable#observable) by using [`Observable.from`](https://github.com/tc39/proposal-observable#observablefrom).

```javascript
const Observable = require('zen-observable');
const spawnStack = require('spawn-stack');

const cp = spawnStack(['setup', '8.2.1']);

Observable.from(cp).subscribe({
  next(line) {
    console.log(line);
    // stack will use a sandboxed GHC it installed ...
  },
  complete() {
    console.log('Done.')
  }
});
```

## License

[ISC License](./LICENSE) © 2017 - 2018 Shinnosuke Watanabe
