<img alt="logo" src="./media/logo.png" width="330px" align="right">

# PureScript npm package

[![npm version](http://img.shields.io/npm/v/purescript.svg)](https://www.npmjs.com/package/purescript)
[![Build Status](https://travis-ci.org/purescript-contrib/node-purescript.svg?branch=master)](https://travis-ci.org/purescript-contrib/node-purescript)
[![Build status](https://ci.appveyor.com/api/projects/status/63vhekj9utfg9nxy/branch/master?svg=true)](https://ci.appveyor.com/project/ShinnosukeWatanabe/node-purescript/branch/master)

[PureScript](http://www.purescript.org/) binary wrapper that makes it seamlessly available via [npm](https://www.npmjs.com/)

## Installation

[Use](https://docs.npmjs.com/cli/install) [npm](https://docs.npmjs.com/getting-started/what-is-npm).

```
npm install purescript
```

Note that this package makes maximum use of `postinstall` [script](https://docs.npmjs.com/misc/scripts), so please make sure that [`ignore-scripts` npm-config](https://docs.npmjs.com/misc/config#ignore-scripts) is not enabled before installation.

Once the command above is executed,

__1.__ First, it checks if a PureScript binary has been already cached in your machine, and restores that if available.

<img alt="screencast: restoring a cache" src="./media/screencast0.gif" width="650px">

__2.__ The second plan: if no cache is available, it downloads a prebuilt binary from [the PureScript release page](https://github.com/purescript/purescript/releases).

<img alt="screencast: downloading a binary" src="./media/screencast1.gif" width="650px">

__3.__ The last resort: if no prebuilt binary is provided for your platform or the downloaded binary doesn't work correctly, it downloads [the PureScript source code](https://github.com/purescript/purescript/tree/master) and compile it with [Stack](https://docs.haskellstack.org/).

<img alt="screencast: compile a source" src="./media/screencast2.gif" width="650px">

## API

### `require('purescript')`

Type: `string`

An absolute path to the installed PureScript binary, which can be used with [`child_process`](https://nodejs.org/api/child_process.html) functions.

```javascript
const {exec} = require('child_process');
const purs = require('purescript'); //=> 'Users/you/example/node_modules/purescript/purs.bin'

exec(purs, ['compile', 'input.purs', '--output', 'output.purs'], () => {
  console.log('Compiled.');
});
```

## CLI

You can use it via CLI by installing it [globally](https://docs.npmjs.com/files/folders#global-installation).

```
npm install --global purescript

purs --help
```

## License

[ISC License](./LICENSE) © 2017 - 2018 Shinnosuke Watanabe

The original PureScript logo is included in [purescript/purescript](https://github.com/purescript/purescript) repository which is licensed under [the 3-Clause BSD License](https://github.com/purescript/purescript/blob/master/LICENSE).
