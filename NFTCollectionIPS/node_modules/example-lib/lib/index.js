'use strict';

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _math = require('./math');

Object.keys(_math).forEach(function (key) {
  if (key === "default" || key === "__esModule") return;
  Object.defineProperty(exports, key, {
    enumerable: true,
    get: function get() {
      return _math[key];
    }
  });
});

var _combinators = require('./combinators');

Object.keys(_combinators).forEach(function (key) {
  if (key === "default" || key === "__esModule") return;
  Object.defineProperty(exports, key, {
    enumerable: true,
    get: function get() {
      return _combinators[key];
    }
  });
});