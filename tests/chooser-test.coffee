path  = require 'path'
chai  = require 'chai'
sinon = require 'sinon'

ChoiceBrain = require path.resolve '.', 'libs', 'choice-data.coffee'
Chooser     = require path.resolve '.', 'libs', 'chooser.coffee'

assert = chai.assert

class MockClass
  getGroupElm: ->

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

  describe '[groupExist] method test', ->
    it 'group exist', (done) ->
      mock = sinon.stub MockClass.prototype, 'getGroupElm'
        .returns ['a']
      chooser = new Chooser new MockClass
      assert.isTrue chooser.groupExist 'room', '$groupName'
      mock.restore()
      done()

    it 'group not exist', (done) ->
      mock = sinon.stub MockClass.prototype, 'getGroupElm'
        .returns []
      chooser = new Chooser new MockClass
      assert.isFalse chooser.groupExist 'room', '$groupName'
      mock.restore()
      done()

  describe '[getCandidacies] method test', ->
    describe '- normal elements', ->
      it 'not existing own', (done) ->
        elms = ['a', 'b', 'c']
        chooser = new Chooser
        candidacies = chooser.getCandidacies 'room', elms, 'user'
        assert.isArray candidacies
        assert.sameMembers elms, candidacies
        done()

      it 'existing own with self option false', (done) ->
        elms = ['a', 'b', 'c']
        chooser = new Chooser
        candidacies = chooser.getCandidacies 'room', elms, 'a'
        assert.sameMembers elms, candidacies
        done()

      it 'existing own with self option true', (done) ->
        elms = ['a', 'b', 'c']
        chooser = new Chooser
        candidacies = chooser.getCandidacies 'room', elms, 'a', true
        assert.sameMembers ['b', 'c'], candidacies
        done()

    describe '- contains group name', ->
      it 'single valid group name', (done) ->
        mock = sinon.stub MockClass.prototype, 'getGroupElm'
          .returns ['a', 'b']
        chooser = new Chooser new MockClass
        candidacies = chooser.getCandidacies 'room', ['$a'], 'c'
        assert.sameMembers ['a', 'b'], candidacies
        mock.restore()
        done()


      it 'single invalid group name', (done) ->
        mock = sinon.stub MockClass.prototype, 'getGroupElm'
          .returns []
        chooser = new Chooser new MockClass
        candidacies = chooser.getCandidacies 'room', ['$a'], 'c'
        assert.sameMembers [], candidacies
        mock.restore()
        done()

      it 'mix groups', (done) ->
        mock = sinon.stub MockClass.prototype, 'getGroupElm'
        mock.withArgs('room', 'a').returns ['a', 'b']
        mock.withArgs('room', 'b').returns ['c', 'd']
        chooser = new Chooser new MockClass
        candidacies = chooser.getCandidacies 'room', ['$a', '$b'], 'e'
        assert.sameMembers ['a', 'b', 'c', 'd'], candidacies
        mock.restore()
        done()

      it 'mix groups and normal elements', (done) ->
        mock = sinon.stub MockClass.prototype, 'getGroupElm'
        mock.withArgs('room', 'a').returns ['a', 'b']
        mock.withArgs('room', 'b').returns ['c', 'd']
        chooser = new Chooser new MockClass
        candidacies = chooser.getCandidacies 'room', ['$a', '$b', 'e', 'f'], 'g'
        assert.sameMembers ['a', 'b', 'c', 'd', 'e', 'f'], candidacies
        mock.restore()
        done()
