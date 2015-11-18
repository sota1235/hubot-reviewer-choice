# Description:
#   Hubot brain interface for hubot-reviewer-choice
#
# Author:
#   @sota1235

'use strict'

_ = require 'lodash'

module.exports = class ChoiceData
  CHOICE = 'CHOICE'

  constructor: (@robot) ->
    return

  # set data
  setData = (robot, data) ->
    robot.brain.set CHOICE, data

  # get all data
  getData = (robot) ->
    data = robot.brain.get(CHOICE) or {}
    return data

  # dump data
  dump: ->
    return getData(@robot)

  # delete all data
  deleteData: ->
    setData @robot, {}

  # set group
  setGroup: (room, groupName, groupElement) ->
    data     = getData(@robot)
    roomData = data[room] or {}
    roomData[groupName] = groupElement
    data[room] = roomData
    setData @robot, data
    return

  # delete group
  deleteGroup: (room, groupName) ->
    data     = getData(@robot)
    roomData = data[room] or {}
    if roomData[groupName] is undefined
      return false
    delete roomData[groupName]
    if (_.size data[room]) is 0
      delete data[room]
    return true

  # get group member
  getGroupElem: (room, groupName) ->
    data     = getData(@robot)
    roomData = data[room] or {}
    if roomData[groupName] is undefined
      return false
    roomData[groupName]

  # get group list
  getGroups: (room) ->
    roomData = getData(@robot)[room] or {}
    if (_.size roomData) is 0
      return false
    roomData
