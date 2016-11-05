path   = require 'path'
assert = require 'assert'

Robot         = require 'hubot/src/robot'
{TextMessage} = require 'hubot/src/message'
FileBrain     = require 'hubot-scripts/src/scripts/file-brain'

testStoragePath = path.resolve __dirname, 'storage'

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
      FileBrain robot

      user = robot.brain.userForId '1',
        name: 'mocha'
        room: '#mocha'

      adapter = robot.adapter

      done()

    robot.run()

  afterEach ->
    robot.shutdown()

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
