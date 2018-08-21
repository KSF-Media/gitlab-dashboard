/*!
 * to-executable-name | MIT (c) Shinnosuke Watanabe
 * https://github.com/shinnn/to-executable-name
*/
module.exports = function toExecutableName(binName, options) {
  'use strict';

  options = options || {};

  if (typeof binName !== 'string') {
    throw new TypeError(
      String(binName) +
      ' is not a string. The first argument to to-executable-name must be a string.'
    );
  }

  if (options.win32Ext) {
    if (typeof options.win32Ext !== 'string') {
      throw new TypeError(
        String(options.win32Ext) +
        ' is not a string. `win32Ext` option must be a file extension for Windows executables' +
        ' (`.exe` by default).'
      );
    }
  }

  if (process.platform === 'win32') {
    if (options.win32Ext) {
      return binName + options.win32Ext;
    }

    return binName + '.exe';
  }

  return binName;
};
