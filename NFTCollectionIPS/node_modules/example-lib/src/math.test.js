import test from 'ava'
import * as math from './math'

test('add', t => {
  t.is(math.add(1)(2), 3)
})

test('multiply', t => {
  t.is(math.multiply(1)(2), 2)
})

test('subtract', t => {
  t.is(math.subtract(1)(2), 1)
})

test('divide', t => {
  t.is(math.divide(2)(1), 0.5)
})
