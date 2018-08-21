'use strict';

const {basename, dirname, resolve} = require('path');
const {lstat} = require('fs');
const {PassThrough, Transform} = require('stream');

const fs = require('graceful-fs');
const inspectWithKind = require('inspect-with-kind');
const isPlainObj = require('is-plain-obj');
const isStream = require('is-stream');
const mkdirp = require('mkdirp');
const Observable = require('zen-observable');
const {pack} = require('tar-fs');
const cancelablePump = require('cancelable-pump');

const FILE_PATH_ERROR = 'Expected a file path to be compressed as an archive';
const TAR_PATH_ERROR = 'Expected a file path where an archive file will be created';
const TAR_TRANSFORM_ERROR = '`tarTransform` option must be a transform stream that modifies the tar archive before writing';
const MAP_STREAM_ERROR = 'The function passed to `mapStream` option must return a stream';

const unsupportedOptions = [
	'entries',
	'filter',
	'ignore',
	'strip'
];

module.exports = function fileToTar(...args) {
	return new Observable(observer => {
		const argLen = args.length;

		if (argLen === 0 || argLen > 3) {
			throw new RangeError(`Expected 1, 2 or 3 arguments (<string>, <string>[, <Object>]), but got ${
				argLen === 0 ? 'no' : argLen
			} arguments.`);
		}

		const [filePath, tarPath] = args;

		if (typeof filePath !== 'string') {
			throw new TypeError(`${FILE_PATH_ERROR}, but got a non-string value ${inspectWithKind(filePath)}.`);
		}

		if (filePath.length === 0) {
			throw new Error(`${FILE_PATH_ERROR}, but got '' (empty string).`);
		}

		if (typeof tarPath !== 'string') {
			throw new TypeError(`${TAR_PATH_ERROR}, but got a non-string value ${inspectWithKind(tarPath)}.`);
		}

		if (tarPath.length === 0) {
			throw new Error(`${TAR_PATH_ERROR}, but got '' (empty string).`);
		}

		const absoluteFilePath = resolve(filePath);
		const absoluteTarPath = resolve(tarPath);
		const dirPath = dirname(absoluteFilePath);

		if (absoluteFilePath === absoluteTarPath) {
			throw new Error(`Source file path must be different from the archive path. Both were specified to ${
				absoluteFilePath
			}.`);
		}

		const options = argLen === 3 ? args[2] : {};

		if (argLen === 3) {
			if (!isPlainObj(options)) {
				throw new TypeError(`Expected a plain object to set file-to-tar options, but got ${
					inspectWithKind(options)
				}.`);
			}

			for (const optionName of unsupportedOptions) {
				const val = options[optionName];

				if (val !== undefined) {
					throw new Error(`file-to-tar doesn't support \`${optionName}\` option, but ${
						inspectWithKind(val)
					} was provided.`);
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

		let cancel;

		lstat(absoluteFilePath, (lstatErr, stat) => {
			if (lstatErr) {
				observer.error(lstatErr);
				return;
			}

			if (!stat.isFile()) {
				observer.error(new Error(`Expected ${absoluteFilePath} to be a file path, but it was a ${
					stat.isDirectory() ? 'directory' : 'symbolic link'
				}.`));

				return;
			}

			let firstWriteError = null;

			const firstWriteStream = fs.createWriteStream(tarPath, options).on('error', err => {
				if (err.code === 'EISDIR') {
					err.message = `Tried to write an archive file to ${absoluteTarPath}, but a directory already exists there.`;
					firstWriteError = err;
					observer.error(err);

					return;
				}

				firstWriteError = err;
			});

			mkdirp(dirname(tarPath), Object.assign({fs}, options), mkdirpErr => {
				if (firstWriteError && firstWriteError.code === 'EISDIR') {
					return;
				}

				if (mkdirpErr) {
					observer.error(mkdirpErr);
					return;
				}

				const packStream = pack(dirPath, Object.assign({fs}, options, {
					entries: [basename(filePath)],
					map(header) {
						if (options.map) {
							header = options.map(header);
						}

						return header;
					},
					mapStream(fileStream, header) {
						const newStream = options.mapStream ? options.mapStream(fileStream, header) : fileStream;

						if (!isStream.readable(newStream)) {
							packStream.emit('error', new TypeError(`${MAP_STREAM_ERROR}${
								isStream(newStream) ?
									' that is readable, but returned a non-readable stream' :
									`, but returned a non-stream value ${inspectWithKind(newStream)}`
							}.`));

							return new PassThrough();
						}

						let bytes = 0;

						observer.next({bytes, header});

						return newStream.pipe(new Transform({
							transform(chunk, encoding, cb) {
								bytes += chunk.length;

								observer.next({bytes, header});
								cb(null, chunk);
							}
						}));
					}
				}));

				cancel = cancelablePump([
					packStream,
					...options.tarTransform ? [options.tarTransform] : [],
					firstWriteError ? fs.createWriteStream(tarPath, options) : firstWriteStream
				], err => {
					if (err) {
						observer.error(err);
						return;
					}

					observer.complete();
				});
			});
		});

		return function cancelCompression() {
			if (cancel) {
				cancel();
			}
		};
	});
};
