# Description
#   choice one element from given arguments
#
# Commands:
#   hubot choice hoge moge fuga -- choice one element from arguments at random
#   hubot choice $<groupname> -- choice one element in <groupname> group
#   hubot choice set <group name> <group elements> -- register new group
#   hubot choice delete <group name> -- delete group
#   hubot choice dump -- show all data in 'CHOICE' table (for debugging)
#
# Author:
#   @sota1235
#
# Thanks:
#   https://github.com/masuilab/slack-hubot/blob/master/scripts/choice.coffee

_ = require 'lodash'

module.exports = (robot) ->
  CHOICE = 'choice_data'

  # get all data
  getData = () ->
    data = robot.brain.get(CHOICE) or {}
    return data

  # set data
  setData = (data) ->
    robot.brain.set CHOICE, data

  # delete all data
  deleteData = () ->
    setData {}

  # set group
  setGroup = (room, groupName, groupElement) ->
    data     = getData()
    roomData = data[room] or {}
    roomData[groupName] = groupElement
    data[room] = roomData
    setData data
    return

  # delete group
  deleteGroup = (room, groupName) ->
    data     = getData()
    roomData = data[room] or {}
    if roomData[groupName] is undefined
      return false
    delete roomData[groupName]
    console.log _.size data[room]
    # TODO:空っぽのroom削除
    # なぜか動かない
    if _.size data[room] is 0
      delete data[room]
    return true

  # get group member
  getGroupElem = (room, groupName) ->
    data     = getData()
    roomData = data[room] or {}
    if roomData[groupName] is undefined
      return false
    else
      return roomData[groupName]

  ###
  # choice one from arguments
  ###
  robot.respond /choice (.+)/i, (msg) ->
    items = msg.match[1].split(/\s+/)
    room  = msg.message.room
    head  = items[0] # for judge command is choice or not

    # return when other commands
    if head is 'set' or head is 'dump' or head is 'delete' or head is 'reset'
      return

    # judge it is groupename
    elements = []
    for i in items
      if /\$(.+)/.test i
        element = getGroupElem room, i.substring 1
        if not element
          msg.send "#{i}は無効なグループ名です"
          return
        elements = elements.concat element
      else
        elements = elements.concat [i]

    choice = _.sample elements
    msg.send "厳正な抽選の結果、「#{choice}」に決まりました"

  ###
  # register new group
  ###
  robot.respond /choice set (.+)/i, (msg) ->
    items = msg.match[1].split(/\s+/)
    room  = msg.message.room
    groupName    = items[0]
    items.shift()
    if items.length is 0
      msg.send "グループの中身が空っぽだよぉ(´・ω・｀)"
      return
    groupElement = items
    setGroup room, groupName, groupElement
    msg.send "グループ：#{groupName}を設定しました"

  ###
  # delete group
  ###
  robot.respond /choice delete (.+)/i, (msg) ->
    groupName = msg.match[1].split(/\s+/)[0]
    room      = msg.message.room
    if deleteGroup room, groupName
      msg.send "グループ：#{groupName}を削除しました。"
    else
      msg.send "グループ：#{groupName}は存在しません。"

  ###
  # for debugging
  ###
  robot.respond /choice dump/i, (msg) ->
    data = getData()
    if _.size(data) is 0
      msg.send "現在登録されているグループはありません"
      return
    msg.send JSON.stringify data, null, 2

  ###
  # reset all data
  ###
  robot.respond /choice reset/i, (msg) ->
    deleteData()
    msg.send "登録されている全データを削除しました"
