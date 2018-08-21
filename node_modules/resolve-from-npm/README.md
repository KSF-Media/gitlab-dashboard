# resolve-from-npm

[![npm version](https://img.shields.io/npm/v/resolve-from-npm.svg)](https://www.npmjs.com/package/resolve-from-npm)
[![Build Status](https://travis-ci.org/shinnn/resolve-from-npm.svg?branch=master)](https://travis-ci.org/shinnn/resolve-from-npm)
[![Build status](https://ci.appveyor.com/api/projects/status/63lufw43bx54l9wp/branch/master?svg=true)](https://ci.appveyor.com/project/ShinnosukeWatanabe/resolve-from-npm/branch/master)
[![Coverage Status](https://img.shields.io/coveralls/shinnn/resolve-from-npm.svg)](https://coveralls.io/github/shinnn/resolve-from-npm)

Resolve the path of a module from the directory where [npm](https://www.npmjs.com/package/npm) is installed

```javascript
const resolveFromNpm = require('resolve-from-npm');

(async () => {
  require.resolve('npm-registry-client');
  //=> '/path/to/the/current/directory/node_modules/npm-registry-client/index.js'

  await resolveFromNpm('npm-registry-client');
  //=> '/usr/local/lib/node_modules/npm/node_modules/npm-registry-client/index.js'
})();
```

## Installation

[Use](https://docs.npmjs.com/cli/install) [npm](https://docs.npmjs.com/getting-started/what-is-npm).

```
npm install resolve-from-npm
```

## API

```javascript
const resolveFromNpm = require('resolve-from-npm');
```

### resolveFromNpm(*moduleId*)

*moduleId*: `string` (a module ID)  
Return: `Promise<string>`

It resolves the path of a module from the path where [npm-cli-dir](https://github.com/shinnn/npm-cli-dir) resolves.

```javascript
(async () => {
  await resolveFromNpm('./lib/install');
  //=> '/usr/local/lib/node_modules/npm/lib/install.js'

  try {
    await resolveFromNpm('./foo/bar');
  } catch (err) {
    err.message;
    //=> 'Cannot find module: "./foo/bar" from npm directory (/usr/local/lib/node_modules/npm).'
  }
})();
```

## License

[ISC License](./LICENSE) © 2017 Shinnosuke Watanabe
