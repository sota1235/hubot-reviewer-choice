# Description
#   1つランダムに選ぶ
#
# Commands:
#   hubot choice ほげ もげ ふが -- 引数からランダムにchoice
#   hubot choice $<groupname> -- 登録されたグループの要素の中からランダムにchoice
#   hubot choice set <group name> <group elements> -- グループを設定
#   hubot choice delete <group name> -- グループを削除
#   hubot choice dump -- 登録されているグループ一覧を表示
#
# Author:
#   @sota1235
#
# Thanks:
#   https://github.com/masuilab/slack-hubot/blob/master/scripts/choice.coffee

_ = require 'lodash'

module.exports = (robot) ->
  CHOICE = 'choice_data'

  # データ取得
  getData = () ->
    data = robot.brain.get(CHOICE) or {}
    return data

  # データセット
  setData = (data) ->
    robot.brain.set CHOICE, data

  # グループをセット
  setGroup = (room, groupName, groupElement) ->
    data     = getData()
    roomData = data[room] or {}
    roomData[groupName] = groupElement
    data[room] = roomData
    setData data
    return

  # グループを削除
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

  # グループ要素を取得
  getGroupElem = (room, groupName) ->
    data     = getData()
    roomData = data[room] or {}
    if roomData[groupName] is undefined
      return false
    else
      return roomData[groupName]

  ###
  # 引数からランダムにchoice
  ###
  robot.respond /choice (.+)/i, (msg) ->
    items = msg.match[1].split(/\s+/)
    room  = msg.message.room
    head  = items[0] # for judge command is choice or not

    # set, dump,deleteの場合、return
    if head is 'set' or head is 'dump' or head is 'delete'
      return

    # 変数かどうか判別
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
  # グループを設定
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
  # グループを削除
  ###
  robot.respond /choice delete (.+)/i, (msg) ->
    groupName = msg.match[1].split(/\s+/)[0]
    room      = msg.message.room
    if deleteGroup room, groupName
      msg.send "グループ：#{groupName}を削除しました。"
    else
      msg.send "グループ：#{groupName}は存在しません。"

  ###
  # for debug
  ###
  robot.respond /choice dump/i, (msg) ->
    data = getData()
    if _.size(data) is 0
      msg.send "現在登録されているグループはありません"
      return
    msg.send JSON.stringify data, null, 2
