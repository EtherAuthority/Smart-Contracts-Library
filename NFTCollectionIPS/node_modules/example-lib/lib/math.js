"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
var add = exports.add = function add(a) {
  return function (b) {
    return a + b;
  };
};
var multiply = exports.multiply = function multiply(a) {
  return function (b) {
    return a * b;
  };
};
var subtract = exports.subtract = function subtract(a) {
  return function (b) {
    return b - a;
  };
};
var divide = exports.divide = function divide(a) {
  return function (b) {
    return b / a;
  };
};