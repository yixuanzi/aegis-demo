const test = require('node:test')
const assert = require('node:assert')
const orders = require('../data/orders.sample.json')

test('sample orders are well-formed', () => {
  for (const o of orders) {
    assert.ok(o.id && o.customer && o.total > 0)
  }
})
