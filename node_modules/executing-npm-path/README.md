# executing-npm-path

[![npm version](https://img.shields.io/npm/v/executing-npm-path.svg)](https://www.npmjs.com/package/executing-npm-path)
[![Build Status](https://travis-ci.com/shinnn/executing-npm-path.svg?branch=master)](https://travis-ci.com/shinnn/executing-npm-path)
[![Build status](https://ci.appveyor.com/api/projects/status/mx900j0cj5qfv62a/branch/master?svg=true)](https://ci.appveyor.com/project/ShinnosukeWatanabe/executing-npm-path/branch/master)
[![Coverage Status](https://img.shields.io/coveralls/shinnn/executing-npm-path.svg)](https://coveralls.io/github/shinnn/executing-npm-path?branch=master)

A path of the currently executed [npm CLI](https://github.com/npm/npm)

```javascript
require('executing-npm-path'); //=> /usr/local/lib/node_modules/npm/bin/npm-cli.js
```

## Installation

[Use](https://docs.npmjs.com/cli/install) [npm](https://docs.npmjs.com/getting-started/what-is-npm).

```
npm install executing-npm-path
```

## API

```javascript
const executingNpmPath = require('executing-npm-path');
```

### executingNpmPath

Type: `string` or `null`

If the program is executed by an [npm script](https://docs.npmjs.com/misc/scripts), it exposes a path of [`npm-cli.js`](https://github.com/npm/npm/blob/v6.1.0/bin/npm-cli.js), an entry point of npm CLI.

If the program is not executed by any package managers or executed by a non-npm package manager, for example [Yarn](https://github.com/yarnpkg/yarn), it exposes `null`.

## License

[ISC License](./LICENSE) © 2018 Shinnosuke Watanabe
