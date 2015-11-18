path  = require 'path'
chai  = require 'chai'
sinon = require 'sinon'

ChoiceBrain = require path.resolve '.', 'libs', 'choice-data.coffee'
Chooser     = require path.resolve '.', 'libs', 'chooser.coffee'

assert = chai.assert

describe 'unit test for chooser.coffee', ->
  describe '[choice] method test', ->
    it 'candidacies is empty', (done) ->
      failedMsg = "有効な抽選相手がいません…そんなにレビューがしたいんです？"
      chooser = new Chooser
      assert.isString chooser.choice []
      assert.equal(
        '有効な抽選相手がいません…そんなにレビューがしたいんです？',
        chooser.choice []
      )
      done()

    it 'some candidacies', (done) ->
      chooser = new Chooser
      assert.equal(
        "厳正な抽選の結果、「@a」に決まりました",
        chooser.choice ['a']
      )
      assert.match(
        chooser.choice ['a', 'b', 'c']
        /^厳正な抽選の結果、「@(a|b|c)」に決まりました$/,
      )
      done()
