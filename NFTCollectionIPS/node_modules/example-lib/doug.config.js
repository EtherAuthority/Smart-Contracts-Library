'use strict'

const path = require('path')

module.exports = {
  src: path.resolve('.', 'src'),
  test: path.resolve('.', 'lib', '**/*.test.js'),
}
