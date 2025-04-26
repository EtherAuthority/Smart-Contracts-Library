'use strict';

var _ava = require('ava');

var _ava2 = _interopRequireDefault(_ava);

var _math = require('./math');

var math = _interopRequireWildcard(_math);

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

(0, _ava2.default)('add', function (t) {
  t.is(math.add(1)(2), 3);
});

(0, _ava2.default)('multiply', function (t) {
  t.is(math.multiply(1)(2), 2);
});

(0, _ava2.default)('subtract', function (t) {
  t.is(math.subtract(1)(2), 1);
});

(0, _ava2.default)('divide', function (t) {
  t.is(math.divide(2)(1), 0.5);
});