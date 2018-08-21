# dl-tgz

[![npm version](https://img.shields.io/npm/v/dl-tgz.svg)](https://www.npmjs.com/package/dl-tgz)
[![Build Status](https://travis-ci.org/shinnn/dl-tgz.svg?branch=master)](https://travis-ci.org/shinnn/dl-tgz)
[![Coverage Status](https://img.shields.io/coveralls/shinnn/dl-tgz.svg)](https://coveralls.io/github/shinnn/dl-tgz?branch=master)

A [Node.js](https://nodejs.org/) module to download and extract a [gzipped](https://tools.ietf.org/html/rfc1952) [tar](https://www.gnu.org/software/tar/) (`tar.gz`) archive with the [Observable](https://tc39.github.io/proposal-observable/) API

```javascript
const {readdirSync} = require('fs');
const dlTgz = require('.');

const url = 'https://github.com/github/hub/releases/download/v2.2.9/hub-darwin-amd64-2.2.9.tgz';

dlTgz(url, 'my/dir').subscribe({
  next({entry: {bytes, header}}) {
    if (bytes !== header.size || !header.name) {
      return;
    }

    console.log(`✓ ${header.name}`);
  },
  complete() {
    readdirSync('my/dir'); //=> [ 'LICENSE', 'README.md', 'bin', 'etc', ...]

    console.log('\nCompleted.')
  }
});
```

```
✓ bin/
✓ bin/hub
✓ README.md
✓ LICENSE
✓ etc/
✓ etc/README.md
✓ etc/hub.bash_completion.sh
✓ etc/hub.zsh_completion
✓ share/
✓ share/man/
✓ share/man/man1/
✓ share/man/man1/hub.1
✓ install

Completed.
```

## Installation

[Use](https://docs.npmjs.com/cli/install) [npm](https://docs.npmjs.com/getting-started/what-is-npm).

```
npm install dl-tgz
```

## API

```javascript
const dlTgz = require('dl-tgz');
```

### dlTgz(*tgzArchiveUrl*, *extractDir* [, *options*])

*tgzArchiveUrl*: `string`  
*extractDir*: `string` (a path where the archive will be extracted)  
*options*: `Object`  
Return: [`Observable`](https://github.com/tc39/proposal-observable#observable) ([zenparsing's implementation](https://github.com/zenparsing/zen-observable))

It works just like [dl-tar](https://github.com/shinnn/dl-tar), except that [`tarTransform` option](https://github.com/shinnn/dl-tar#tartransform) defaults to a [`zlib.Gunzip` stream](https://nodejs.org/api/zlib.html#zlib_class_zlib_gunzip) and unchangeable.

## License

[ISC License](./LICENSE) © 2017 - 2018 Shinnosuke Watanabe
