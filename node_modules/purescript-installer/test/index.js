'use strict';

const fs = require('fs');
const {execFile} = require('child_process');
const util = require('util');
const tap = require('tap');
const rimraf = require('rimraf');

const installPurescript = require('../install-purescript/index.js');

const cacheRootDir = ".test-cache";

// Set a timeout of 60s (default is 30s)
tap.setTimeout(1000 * 60);

rimraf.sync(cacheRootDir);

// Given an installPurescript observable, return a promise which resolves to a
// summary of the events which occurred during installation (i.e. without
// repeated events).
function summarizeEvents(observable) {
	let lastEventId;
	const uniqEvents = [];

	return new Promise((resolve, reject) => {
		observable.subscribe({
			next(event) {
				if (event.id !== lastEventId) {
					uniqEvents.push(event);
				}
				lastEventId = event.id;
			},
			error(err) {
				reject(err);
			},
			complete() {
				resolve(uniqEvents);
			}
		});
	});
};

function assertEvents(t, _found, _expected) {
	const found = _found.slice();
	const expected = _expected.slice();

	while (found.length > 0 && expected.length > 0) {
		const next = found.shift();
		if (next.id == expected[0].id) {
			const nextExpected = expected.shift();
			t.match(next, nextExpected, "received " + next.id + " event");
		}
	}

	if (expected.length > 0) {
		t.fail("expected the following events, but did not receive them: " + expected.map(x => x.id).join(", "));
	} else {
		t.ok(true, "received all expected events")
	}
}

// return a promise which resolves once the given file has been unlinked,
// swallowing ENOENT errors (which indicate the file never existed in the first
// place).
async function unlinkIfExists(path) {
	try {
		await util.promisify(fs.unlink)('./purs');
	} catch(err) {
		if (err.code !== 'ENOENT') {
			throw err;
		}
	}
}

function testInstall(version, expectedEvents) {
	return (async t => {
		await unlinkIfExists('./purs');
		const events = await summarizeEvents(installPurescript({
			cacheRootDir,
			version
		}));
		assertEvents(t, events, expectedEvents);
		const {stdout} = await util.promisify(execFile)('./purs', ['--version'], {timeout: 1000});
		t.match(stdout.toString(), version);
	});
}

tap.test('clean install', testInstall('0.13.0', [
	{ id: 'search-cache', found: false },
	{ id: 'download-binary' },
	{ id: 'check-binary' },
	{ id: 'write-cache' }
]));

tap.test('install from cache', testInstall('0.13.0', [
	{ id: 'search-cache', found: true },
	{ id: 'restore-cache' },
	{ id: 'check-binary' }
]));

tap.test('install a different version', testInstall('0.12.5', [
	{ id: 'search-cache', found: false },
	{ id: 'download-binary' },
	{ id: 'check-binary' },
	{ id: 'write-cache' }
]));

tap.test('install a different version from cache', testInstall('0.12.5', [
	{ id: 'search-cache', found: true },
	{ id: 'restore-cache' },
	{ id: 'check-binary' }
]));

tap.test('clean install', testInstall('0.15.0-alpha-06', [
	{ id: 'search-cache', found: false },
	{ id: 'download-binary' },
	{ id: 'check-binary' },
	{ id: 'write-cache' }
]));