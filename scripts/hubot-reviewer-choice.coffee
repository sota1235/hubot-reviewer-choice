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
Chooser    = require path.join __dirname, '../libs/chooser'

module.exports = (robot) ->

  choiceBrain = new ChoiceData robot
  chooser     = new Chooser choiceBrain
  commandList = ['set', 'dump', 'delete', 'reset', 'list']

  # choice
  robot.respond /choice (.+)/i, (msg) ->
    members = msg.match[1].split(/\s+/)
    room    = msg.message.room
    user    = msg.message.user.name

    # return when other commands
    if _.indexOf(commandList, members[0]) >= 0
      return

    # check group name
    invalidGroups = []
    groups = _.filter members, (member) ->
      return /\$(.+)/.test member
    _.each groups, (member) ->
      if !chooser.groupExist room, member
        invalidGroups.push member

    if _.size(invalidGroups) > 0
      msg.send "#{invalidGroups.join ', '}は無効なグループ名です"
      return

    # judge it is groupenams
    candidacies = chooser.getCandidacies msg.message.room, members, user, true

    # message
    msg.send chooser.choice candidacies

  # list all groups
  robot.respond /choice list/i, (msg) ->
    msg.send chooser.list msg.message.room

  # register new group
  robot.respond /choice set (.+)/i, (msg) ->
    members = msg.match[1].split(/\s+/)
    room    = msg.message.room
    name    = members.shift()

    msg.send chooser.set room, name, members

  # delete group
  robot.respond /choice delete (.+)/i, (msg) ->
    room = msg.message.room
    name = msg.match[1].split(/\s+/)[0]
    msg.send chooser.delete room, name

  # for debugging
  robot.respond /choice dump/i, (msg) ->
    msg.send chooser.dump()

  # reset all data
  robot.respond /choice reset/i, (msg) ->
    msg.send chooser.reset()
