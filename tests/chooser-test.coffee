path  = require 'path'
chai  = require 'chai'
sinon = require 'sinon'

ChoiceBrain = require path.resolve '.', 'libs', 'choice-data.coffee'
Chooser     = require path.resolve '.', 'libs', 'chooser.coffee'

assert = chai.assert

class MockClass
  getGroupElm: ->
  getGroups: ->
  setGroup: ->
  deleteGroup: ->

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

  describe '[list] method test', ->
    it 'no group settings', (done) ->
      mock = sinon.stub MockClass.prototype, 'getGroups'
        .returns []
      chooser = new Chooser new MockClass
      assert.equal 'このchannelのグループは未設定です', chooser.list()
      mock.restore()
      done()

    it 'some groups', (done) ->
      mock = sinon.stub MockClass.prototype, 'getGroups'
        .returns
          a: ['1', '2', '3']
          b: ['4', '5']
      chooser = new Chooser new MockClass
      assert.equal 'a: 1, 2, 3\nb: 4, 5', chooser.list()
      mock.restore()
      done()

  describe '[set] method test', ->
    it 'when group elements is empty', (done) ->
      chooser = new Chooser
      assert.equal(
        'グループの中身が空っぽだよぉ(´・ω・｀)',
        chooser.set 'room', 'name', []
      )
      done()

    it 'set group elements', (done) ->
      mock = sinon.stub MockClass.prototype, 'setGroup'
      chooser = new Chooser new MockClass
      assert.equal(
        'グループ：groupを設定しました',
        chooser.set 'room', 'group', ['a', 'b']
      )
      mock.restore()
      done()

  describe '[delete] method test', ->
    it 'delete success', (done) ->
      mock = sinon.stub MockClass.prototype, 'deleteGroup'
        .returns true
      chooser = new Chooser new MockClass
      assert.equal 'グループ：groupを削除しました。', chooser.delete 'room', 'group'
      mock.restore()
      done()

    it 'group not exist', (done) ->
      mock = sinon.stub MockClass.prototype, 'deleteGroup'
        .returns false
      chooser = new Chooser new MockClass
      assert.equal 'グループ：groupは存在しません。', chooser.delete 'room', 'group'
      mock.restore()
      done()
