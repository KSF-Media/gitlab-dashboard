import appendType from 'append-type';

export default function createFeintFunction(fn) {
	if (typeof fn !== 'function') {
		throw new TypeError('Expected a function, but got ' + appendType(fn) + '.');
	}

	var called = false;

	return function feint() {
		if (!called) {
			called = true;
			return undefined;
		}

		return fn.apply(this, arguments);
	};
}
