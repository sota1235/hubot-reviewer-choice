chai = require 'chai'
path = require 'path'

assert = chai.assert

describe 'unit test for chooser.coffee', ->
  describe 'test', ->
    it 'test', (done) ->
      assert.typeOf 'test', 'string'
      done()
