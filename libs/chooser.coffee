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

  choice = (elements) ->
    return _.sample elements

  list: (room) ->
    groups = @choiceBrain.getGroups room
    responds = []
    for name, members of groups
      responds.push "#{name}: #{members.join ', '}"

    if _.size(responds) is 0
      'このchannelのグループは未設定です'
    else
      responds.join '\n'
