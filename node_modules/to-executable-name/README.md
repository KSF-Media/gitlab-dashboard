# to-executable-name

[![NPM version](https://img.shields.io/npm/v/to-executable-name.svg)](https://www.npmjs.com/package/to-executable-name)
[![Build Status](https://travis-ci.org/shinnn/to-executable-name.svg?branch=master)](https://travis-ci.org/shinnn/to-executable-name)
[![Build status](https://ci.appveyor.com/api/projects/status/tesr30vmgccrb138/branch/master?svg=true)](https://ci.appveyor.com/project/ShinnosukeWatanabe/to-executable-name/branch/master)
[![Coverage Status](https://img.shields.io/coveralls/shinnn/to-executable-name.svg)](https://coveralls.io/github/shinnn/to-executable-name)
[![devDependencies Status](https://david-dm.org/shinnn/to-executable-name/dev-status.svg)](https://david-dm.org/shinnn/to-executable-name?type=dev)

Append `.exe` to a given string if the program is running on a [Windows](http://windows.microsoft.com/) environment

```javascript
const toExecutableName = require('to-executable-name');

// On Windows
toExecutableName('node'); //=> 'node.exe'

// Otherwise
toExecutableName('node'); //=> 'node'
```

## Installation

[Use npm.](https://docs.npmjs.com/cli/install)

```
npm install to-executable-name
```

## API

```javascript
const toExecutableName = require('to-executable-name');
```

### toExecutableName(*binName* [, *option*])

*binName*: `String`  
*option*: `Object`  
Return: `String`

#### options.win32Ext

Type: `String`  
Default: `.exe`

A file extension that will be appended to the string on Windows.

```javascript
// On Windows

toExecutableName('foo'); //=> 'foo.exe'
toExecutableName('foo', {win32Ext: '.bat'}); //=> 'foo.bat'
```

## License

Copyright (c) 2015 - 2016 [Shinnosuke Watanabe](https://github.com/shinnn)

Licensed under [the MIT License](./LICENSE).
