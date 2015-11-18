# Description:
#   class for hubot-reviewer-choice
#   offering logic of choice
#
# Author:
#   @sota1235

'use strict'

_ = require 'lodash'

module.exports = class Chooser

  constructor: (@choiceBrain) ->
    return

  choice: (elements) ->
    _.sample elements

  groupExist: (room, groupName) ->
    if not /\$(.+)/.test groupName then return

    members = @choiceBrain.getGroupElm room, groupName.substring 1
    if _.size(members) is 0
      return false
    true

  getCandidacies: (room, elms, user) ->
    candidacies = []
    for elm in elms
      if /\$(.+)/.test elm
        candidacies =
          candidacies.concat @choiceBrain.getGroupElm room, elm.substring 1
      else
        candidacies.push elm
    _.without candidacies, user

  list: (room) ->
    groups = @choiceBrain.getGroups room
    responds = []
    for name, members of groups
      responds.push "#{name}: #{members.join ', '}"

    if _.size(responds) is 0
      'このchannelのグループは未設定です'
    else
      responds.join '\n'

  set: (room, name, members) ->
    if _.size(members) is 0
      return "グループの中身が空っぽだよぉ(´・ω・｀)"

    @choiceBrain.setGroup room, name, members
    "グループ：#{name}を設定しました"

  delete: (room, name) ->
    if @choiceBrain.deleteGroup room, name
      "グループ：#{name}を削除しました。"
    else
      "グループ：#{name}は存在しません。"

  dump: () ->
    data = @choiceBrain.dump()
    if _.size(data) is 0
      "現在登録されているグループはありません"
    else
      JSON.stringify data, null, 2

  reset: () ->
    @choiceBrain.deleteData()
    "登録されている全データを削除しました"
