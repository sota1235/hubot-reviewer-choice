# Description:
#   choice one element from given arguments
#
# Commands:
#   hubot choice hoge moge fuga -- choice one element from arguments at random
#   hubot choice $<groupname> -- choice one element in <groupname> group
#   hubot choice set <group name> <group elements> -- register new group
#   hubot choice list -- list all group in room
#   hubot choice delete <group name> -- delete group
#
# Author:
#   @sota1235
#
# Thanks:
#   https://github.com/masuilab/slack-hubot/blob/master/scripts/choice.coffee

path       = require 'path'
_          = require 'lodash'
ChoiceData = require path.join __dirname, '../libs/choice-data'

module.exports = (robot) ->

  choiceBrain = new ChoiceData robot
  commandList = ['set', 'dump', 'delete', 'reset', 'list']

  # choice
  robot.respond /choice (.+)/i, (msg) ->
    items = msg.match[1].split(/\s+/)
    head  = items[0] # for judge command is choice or not

    # return when other commands
    if _.indexOf(commandList, head) >= 0
      return

    # judge it is groupename
    elements = []
    for i in items
      if /\$(.+)/.test i
        element = choiceBrain.getGroupElem msg.message.room, i.substring 1
        if not element
          msg.send "#{i}は無効なグループ名です"
          return
        elements = elements.concat element
      else
        elements = elements.concat [i]
    # 自分を除外
    elements = _.without elements, msg.message.user.name
    if (_.size elements) is 0 then return

    choice = _.sample elements
    msg.send "厳正な抽選の結果、「@#{choice}」に決まりました"

  # list all groups
  robot.respond /choice list/i, (msg) ->
    groups  = choiceBrain.getGroups(msg.message.room)
    responds = []
    for groupName, elements of groups
      elms = elements.join ', '
      responds.push "#{groupName}: #{elms}"
    res = responds.join '\n'
    msg.send if (_.size responds) is 0 then 'このchannelのグループは未設定です' else res

  # register new group
  robot.respond /choice set (.+)/i, (msg) ->
    items = msg.match[1].split(/\s+/)
    room  = msg.message.room
    groupName = items[0]
    items.shift()
    if items.length is 0
      msg.send "グループの中身が空っぽだよぉ(´・ω・｀)"
      return
    groupElement = items
    choiceBrain.setGroup room, groupName, groupElement
    msg.send "グループ：#{groupName}を設定しました"

  # delete group
  robot.respond /choice delete (.+)/i, (msg) ->
    groupName = msg.match[1].split(/\s+/)[0]
    room      = msg.message.room
    if choiceBrain.deleteGroup room, groupName
      msg.send "グループ：#{groupName}を削除しました。"
    else
      msg.send "グループ：#{groupName}は存在しません。"

  # for debugging
  robot.respond /choice dump/i, (msg) ->
    data = choiceBrain.dump()
    if _.size(data) is 0
      msg.send "現在登録されているグループはありません"
      return
    msg.send JSON.stringify data, null, 2

  # reset all data
  robot.respond /choice reset/i, (msg) ->
    choiceBrain.deleteData()
    msg.send "登録されている全データを削除しました"
