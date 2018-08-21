# real-executable-path-callback

[![npm version](https://img.shields.io/npm/v/real-executable-path-callback.svg)](https://www.npmjs.com/package/real-executable-path-callback)
[![Build Status](https://travis-ci.org/shinnn/real-executable-path-callback.svg?branch=master)](https://travis-ci.org/shinnn/real-executable-path-callback)
[![Build status](https://ci.appveyor.com/api/projects/status/ap6060wrs8xlja88/branch/master?svg=true)](https://ci.appveyor.com/project/ShinnosukeWatanabe/real-executable-path-callback/branch/master)
[![Coverage Status](https://img.shields.io/coveralls/shinnn/real-executable-path-callback.svg)](https://coveralls.io/github/shinnn/real-executable-path-callback)

[Callback](http://thenodeway.io/posts/understanding-error-first-callbacks/)-style version of [real-executable-path]:

> Find the first instance of an executable in the PATH, with expanding all symbolic links

```javascript
const realExecutablePathCallback = require('real-executable-path-callback');
const which = require('which');

which('npm', (err, binPath) => {
  binPath; //=> '/usr/local/bin/npm'
});

realExecutablePathCallback('npm', (err, binPath) => {
  binPath; //=> '/usr/local/lib/node_modules/npm/bin/npm-cli.js'
});
```

## Installation

[Use](https://docs.npmjs.com/cli/install) [npm](https://docs.npmjs.com/getting-started/what-is-npm).

```
npm install real-executable-path-callback
```

## API

```javascript
const realExecutablePathCallback = require('real-executable-path-callback');
```

### realExecutablePathCallback(*binName* [, *options*], *callback*)

*binName*: `string` (an executable name in the PATH)  
*options*: `Object` ([`node-which` options](https://github.com/npm/node-which#options) except for `all`)  
*callback*: `Function` (called after the path is resolved)

It finds the first instance of the given executable in the [PATH](http://pubs.opengroup.org/onlinepubs/000095399/basedefs/xbd_chap08.html#tag_08_03) environment variable, expands all symbolic links and resolves the canonicalized absolute pathname.

```javascript
const realExecutablePathCallback = require('real-executable-path-callback');

realExecutablePathCallback('this_cmd_is_not_installed', err => {
  err.message; //=> 'not found: this_cmd_is_not_installed'
  err.code; //=> 'ENOENT'
});
```

## Related project

* [real-executable-path] — [Promise](https://promisesaplus.com/) version

## License

[ISC License](./LICENSE) © 2017 Shinnosuke Watanabe

[real-executable-path]: https://github.com/shinnn/real-executable-path
