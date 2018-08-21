'use strict';

const {inspect} = require('util');
const {basename, dirname} = require('path');
const {PassThrough, Transform} = require('stream');

const cancelablePump = require('cancelable-pump');
const Extract = require('tar-stream').extract;
const fsExtract = require('tar-fs').extract;
const gracefulFs = require('graceful-fs');
const inspectWithKind = require('inspect-with-kind');
const isPlainObj = require('is-plain-obj');
const isStream = require('is-stream');
const Observable = require('zen-observable');

class SingleFileExtract extends Extract {
	constructor(option) {
		super();

		this.errorMessage = `Expected the archive ${
			option.tarPath
		} to contain only a single file`;
	}

	emit(eventName, header, stream, next) {
		if (eventName !== 'entry') {
			super.emit(eventName, header);
			return;
		}

		super.emit('entry', header, stream, err => {
			if (err) {
				next(err);
				return;
			}

			if (this.firstEntryName) {
				next(new Error(`${
					this.errorMessage
				}, but actually contains multiple entries ${inspect(this.firstEntryName)} and ${inspect(header.name)}.`));

				return;
			}

			this.firstEntryName = header.name;

			if (header.type !== 'file') {
				next(new Error(`${
					this.errorMessage
				}, but actually contains a non-file entry ${inspect(header.name)} (${header.type}).`));

				return;
			}

			next();
		});
	}
}

const functionOptions = new Set(['map', 'mapStream']);
const unsupportedOptions = new Set([
	'entries',
	'filter',
	'ignore',
	'strip'
]);

function echo(val) {
	return val;
}

const DEST_ERROR = 'Expected a destination file path';
const TAR_TRANSFORM_ERROR = '`tarTransform` option must be a transform stream ' +
                            'that modifies the tar archive before extraction';
const MAP_STREAM_ERROR = 'The function passed to `mapStream` option must return a stream';

module.exports = function tarToFile(...args) {
	return new Observable(observer => {
		const argLen = args.length;

		if (argLen !== 2 && argLen !== 3) {
			throw new RangeError(`Expected 2 or 3 arguments (<string>, <string>[, <Object>]), but got ${
				argLen === 0 ? 'no' : argLen
			} arguments instead.`);
		}

		const [tarPath, filePath] = args;

		if (typeof tarPath !== 'string') {
			throw new TypeError(`Expected a path of a tar archive (string), but got ${inspectWithKind(tarPath)}.`);
		}

		if (tarPath.length === 0) {
			throw new Error('Expected a path of a tar archive, but got \'\' (empty string).');
		}

		if (typeof filePath !== 'string') {
			throw new TypeError(`${DEST_ERROR} (string), but got ${inspectWithKind(filePath)}.`);
		}

		if (filePath.length === 0) {
			throw new Error(`${DEST_ERROR}, but got '' (empty string).`);
		}

		const options = argLen === 3 ? args[2] : {};

		if (argLen === 3) {
			if (!isPlainObj(options)) {
				throw new TypeError(`Expected an object to specify \`tar-to-file\` options, but got ${inspectWithKind(options)}.`);
			}

			for (const optionName of functionOptions) {
				const val = options[optionName];

				if (val !== undefined && typeof val !== 'function') {
					throw new TypeError(`\`${optionName}\` option must be a function, but ${
						inspectWithKind(val)
					} was provided to it.`);
				}
			}

			for (const optionName of unsupportedOptions) {
				const val = options[optionName];

				if (val !== undefined) {
					throw new TypeError(`\`tar-to-file\` doesn't support \`${optionName}\` option , but ${
						inspectWithKind(val)
					} was provided to it.`);
				}
			}

			if (options.tarTransform !== undefined) {
				if (!isStream(options.tarTransform)) {
					throw new TypeError(`${TAR_TRANSFORM_ERROR}, but got a non-stream value ${
						inspectWithKind(options.tarTransform)
					}.`);
				}

				if (!isStream.transform(options.tarTransform)) {
					throw new TypeError(`${TAR_TRANSFORM_ERROR}, but got a ${
						['duplex', 'writable', 'readable'].find(type => isStream[type](options.tarTransform))
					} stream instead.`);
				}
			}
		}

		const extract = new SingleFileExtract({tarPath});
		const mapStream = options.mapStream || echo;
		let ended = false;

		const fsExtractStream = fsExtract(dirname(filePath), {
			extract,
			fs: gracefulFs,
			...options,
			map(header) {
				if (header.type !== 'file') {
					return header;
				}

				header = {...header, name: basename(filePath)};

				if (options.map) {
					return options.map(header);
				}

				return header;
			},
			mapStream(fileStream, header) {
				const newStream = mapStream(fileStream, header);

				if (!isStream.readable(newStream)) {
					fsExtractStream.emit(
						'error',
						new TypeError(`${MAP_STREAM_ERROR}${
							isStream(newStream) ?
								' that is readable, but returned a non-readable stream' :
								`, but returned a non-stream value ${inspect(newStream)}`
						}.`)
					);

					return new PassThrough();
				}

				let bytes = 0;

				if (header.size !== 0) {
					observer.next({header, bytes});
				}

				return newStream.pipe(new Transform({
					transform(chunk, encoding, cb) {
						bytes += chunk.length;
						observer.next({header, bytes});
						cb(null, chunk);
					}
				}));
			}
		});

		const pipe = [
			gracefulFs.createReadStream(tarPath),
			fsExtractStream
		];

		if (options.tarTransform) {
			pipe.splice(1, 0, options.tarTransform);
		}

		const cancel = cancelablePump(pipe, err => {
			ended = true;

			if (err) {
				observer.error(err);
				return;
			}

			observer.complete();
		});

		return function cancelExtract() {
			if (ended) {
				return;
			}

			cancel();
		};
	});
};
