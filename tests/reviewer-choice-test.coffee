fs     = require 'fs'
path   = require 'path'
assert = require 'assert'

Robot         = require 'hubot/src/robot'
{TextMessage} = require 'hubot/src/message'
FileBrain     = require 'hubot-scripts/src/scripts/file-brain'

testStoragePath = path.resolve __dirname, 'storage'
testBrainFilePath = path.resolve testStoragePath, 'brain-dump.json'

process.env.FILE_BRAIN_PATH = testStoragePath

describe 'Integration test for hubot-reviewer-choice', ->
  robot = null
  user = null
  adapter = null

  beforeEach (done) ->
    robot = new Robot null, 'mock-adapter', false, 'hubot'

    robot.adapter.on 'connected', ->

      robot.loadFile path.resolve path.join 'node_modules/hubot/src/scripts'
      robot.loadFile path.resolve '..', 'scripts', 'hubot-reviewer-choice.coffee'

      require('../scripts/hubot-reviewer-choice') robot

      # mock hubot brain
      FileBrain robot

      user = robot.brain.userForId '1',
        name: 'mocha'
        room: '#mocha'

      adapter = robot.adapter

      done()

    robot.run()

  afterEach () ->
    robot.shutdown()
    adapter.removeAllListeners()
    fs.writeFileSync testBrainFilePath, '', 'utf-8'

  it '"hubot choice a" -> a', (done) ->
    adapter.on 'send', (envelope, strings) ->
      assert.equal strings[0], '厳正な抽選の結果、「@a」に決まりました'
      done()

    adapter.receive new TextMessage user, 'hubot choice a'

  it '"hubot choice self" -> not choicing', (done) ->
    adapter.on 'send', (envelope, strings) ->
      assert.equal strings[0], '有効な抽選相手がいません…そんなにレビューがしたいんです？'
      done()

    adapter.receive new TextMessage user, 'hubot choice mocha'

  it '"hubot choice $group" -> group not found', (done) ->
    adapter.on 'send', (envelope, strings) ->
      assert.equal strings[0], '$groupは無効なグループ名です'
      done()

    adapter.receive new TextMessage user, 'hubot choice $group'

  it '"hubot choice $group" -> choice from group', (done) ->
    groupName = 'sampleGroup'
    groupMember = ['a', 'b', 'c']

    counter = 0

    adapter.on 'send', (envelope, strings) ->
      # HACK 毎回リスナーに飛んで来るので何回目かで判定してassertionする
      switch counter
        when 0
          assert.equal strings[0], "グループ：#{groupName}を設定しました"
        when 1
          assert strings[0].match /^厳正な抽選の結果、「@(a|b|c)」に決まりました$/
      counter++
      if counter is 2
        done()

    adapter.receive new TextMessage user, "hubot choice set #{groupName} #{groupMember.join ' '}"
    setTimeout () ->
      adapter.receive new TextMessage user, "hubot choice $#{groupName}"
    , 100

  it 'データが登録されていない時のメッセージテスト', (done) ->
    adapter.on 'send', (envelope, strings) ->
      assert.equal strings[0], '現在登録されているグループはありません'
      done()

    adapter.receive new TextMessage user, 'hubot choice dump'

  it 'データが登録されていない時のメッセージテスト', (done) ->
    adapter.on 'send', (envelope, strings) ->
      assert.equal strings[0], '現在登録されているグループはありません'
      done()

    adapter.receive new TextMessage user, 'hubot choice dump'

