# win-user-installed-npm-cli-path

[![npm version](https://img.shields.io/npm/v/win-user-installed-npm-cli-path.svg)](https://www.npmjs.com/package/win-user-installed-npm-cli-path)
[![Build Status](https://travis-ci.org/shinnn/win-user-installed-npm-cli-path.svg?branch=master)](https://travis-ci.org/shinnn/win-user-installed-npm-cli-path)
[![Build status](https://ci.appveyor.com/api/projects/status/2sp4jxe2rp48lnk2/branch/master?svg=true)](https://ci.appveyor.com/project/ShinnosukeWatanabe/win-user-installed-npm-cli-path/branch/master)
[![Coverage Status](https://img.shields.io/coveralls/shinnn/win-user-installed-npm-cli-path.svg)](https://coveralls.io/github/shinnn/win-user-installed-npm-cli-path)

Resolve the path of [`npm-cli.js`][npm-cli] included in [user-installed](https://docs.npmjs.com/getting-started/installing-node#updating-npm) [npm](https://www.npmjs.com/) on [Windows](https://www.microsoft.com/windows)

```javascript
const winUserInstalledNpmCliPath = require('win-user-installed-npm-cli-path');

(async () => {
  const cliPath = await winUserInstalledNpmCliPath();
  //=> 'C:\\Users\\me\\AppData\\Roaming\\npm\\node_modules\\npm\\bin\\npm-cli.js'
  });
})();
```

## Installation

[Use](https://docs.npmjs.com/cli/install) [npm](https://docs.npmjs.com/getting-started/what-is-npm).

```
npm install win-user-installed-npm-cli-path
```

## API

```javascript
const winUserInstalledNpmCliPath = require('win-user-installed-npm-cli-path');
```

### winUserInstalledNpmCliPath()

Return: `Promise<string>`

It resolves the path of [`npm-cli.js`][npm-cli] included in the user-installed [`npm` CLI](https://github.com/npm/npm) on Windows. *"User-installed"* means that it has been installed with [`npm install --global npm`](https://docs.npmjs.com/getting-started/installing-node#updating-npm) command by the user, and it might be located on the path different from where the default Node.js-bundled npm has been installed.

It uses global [`prefix`](https://docs.npmjs.com/files/folders#prefix-configuration) [config](https://docs.npmjs.com/misc/config#prefix) as a base path for searching npm CLI location.

```javascript
// npm config set prefix tmp --global

(async () => {
  await winUserInstalledNpmCliPath();
  //=> 'C:\projects\your_project\tmp\node_modules\npm\bin\npm-cli.js'
})();
```

## For [POSIX](http://standards.ieee.org/develop/wg/POSIX.html)

Use [real-executable-path](https://github.com/shinnn/real-executable-path) instead.

```javascript
const realExecutablePath = require('real-executable-path');

(async () => {
  await realExecutablePath('npm');
  //=> '/usr/local/lib/node_modules/npm/bin/npm-cli.js'
})();
```

## License

[ISC License](./LICENSE) © 2017 - 2018 Shinnosuke Watanabe

[npm-cli]: https://github.com/npm/npm/blob/master/bin/npm-cli.js
