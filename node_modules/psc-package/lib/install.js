'use strict';

const path = require('path');

const binBuild = require('bin-build');
const BinWrapper = require('bin-wrapper');
const log = require('logalot');
const pscPackagePath = require('..');
const rimraf = require('rimraf');
const {BASE_URL, SOURCE_URL} = require('.');

const bin = new BinWrapper()
.src(`${BASE_URL}macos.tar.gz`, 'darwin')
.src(`${BASE_URL}linux64.tar.gz`, 'linux')
.src(`${BASE_URL}win64.tar.gz`, 'win32')
.dest(path.dirname(pscPackagePath));

const allowDifferentUserFlag = ' --allow-different-user'.repeat(Number(process.platform !== 'win32'));

const removeUnnecessaryFiles = cb => {
  rimraf('*', {
    glob: {
      cwd: bin.dest(),
      ignore: ['psc-package'],
      absolute: true
    }
  }, cb);
};

bin.use(path.basename(pscPackagePath)).run(['--help'], runErr => {
  if (runErr) {
    log.warn(runErr.message);
    log.warn('pre-build test failed');
    log.info('compiling from source');

    binBuild()
    .src(SOURCE_URL)
    .cmd(`stack setup${allowDifferentUserFlag}`)
    .cmd(`stack install${allowDifferentUserFlag} --local-bin-path ${bin.dest()}`)
    .run(buildErr => {
      if (buildErr) {
        log.error(buildErr.stack);
        return;
      }

      removeUnnecessaryFiles(() => log.success('built successfully'));
    });

    return;
  }

  removeUnnecessaryFiles(() => log.success('pre-build test passed successfully'));
});
