# npm-cli-path

[![npm version](https://img.shields.io/npm/v/npm-cli-path.svg)](https://www.npmjs.com/package/npm-cli-path)
[![Build Status](https://travis-ci.org/shinnn/npm-cli-path.svg?branch=master)](https://travis-ci.org/shinnn/npm-cli-path)
[![Build status](https://ci.appveyor.com/api/projects/status/8osd3at404d3jrxi/branch/master?svg=true)](https://ci.appveyor.com/project/ShinnosukeWatanabe/npm-cli-path/branch/master)
[![Coverage Status](https://img.shields.io/coveralls/shinnn/npm-cli-path.svg)](https://coveralls.io/github/shinnn/npm-cli-path?branch=master)

Resolve the path of [`npm-cli.js`][npm-cli] included in the globally installed [npm](https://www.npmjs.com/) CLI

```javascript
const npmCliPath = require('npm-cli-path');

(async () => {
  const path = npmCliPath(); //=> '/usr/local/lib/node_modules/npm/bin/npm-cli.js'
})();
```

## Installation

[Use](https://docs.npmjs.com/cli/install) [npm](https://docs.npmjs.com/getting-started/what-is-npm).

```
npm install npm-cli-path
```

## API

```javascript
const npmCliPath = require('npm-cli-path');
```

### npmCliPath()

Return: `Promise<string>`

It resolves the path of [`npm-cli.js`][npm-cli] which is the entry point of [npm](https://github.com/npm/npm) CLI.

## License

[ISC License](./LICENSE) © 2017 - 2018 Shinnosuke Watanabe

[npm-cli]: https://github.com/npm/npm/blob/master/bin/npm-cli.js
