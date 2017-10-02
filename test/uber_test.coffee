Helper = require 'hubot-test-helper'
chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

helper = new Helper '../src/uber.coffee'

# describe 'config', ->
#   it 'warns about token missing', ->
#     delete process.env.HUBOT_UBER_TOKEN
#
#     room = helper.createRoom()
#
#     # TODO spy on robot logger
#
#     room.destroy()

describe 'uber', ->
  before ->
    process.env.HUBOT_UBER_TOKEN = 'UNITTEST'

  beforeEach ->
    @room = helper.createRoom()

  afterEach ->
    @room.destroy()

  it 'gets default', ->
    @room.user.say('alice', '@hubot uber default').then =>
      expect(@room.messages).to.eql [
        ['alice', '@hubot uber default']
        ['hubot', 'No default set yet']
      ]

  it 'lists locations', ->
    @room.user.say('bob', '@hubot uber locations').then =>
      expect(@room.messages).to.eql [
        ['bob', '@hubot uber locations']
        ['hubot', ''] # because no locations added yet
      ]

  it 'lists promotions', ->
    @room.user.say('alice', '@hubot uber promo').then =>
      expect(@room.messages).to.eql [
        ['alice', '@hubot uber promo']
        ['hubot', 'No location provided. Try "help uber" to learn how to add'] # because no locations added yet
      ]

  it 'adds a location', ->
    @room.user.say('charlie', '@hubot uber add office 12.345, 67.890').then =>
      expect(@room.messages).to.eql [
        ['charlie', '@hubot uber add office 12.345, 67.890']
        ['hubot', 'Saved office at 12.345, 67.890 for Uber lookups']
      ]

  it 'adds a location with a quoted, single word location name', ->
    @room.user.say('charlie', '@hubot uber add "home" -33.9258400, 18.4232200').then =>
      expect(@room.messages).to.eql [
        ['charlie', '@hubot uber add "home" -33.9258400, 18.4232200']
        ['hubot', 'Saved "home" at -33.9258400, 18.4232200 for Uber lookups']
      ]

  it 'adds a location with a quoted, multiple word location name', ->
    @room.user.say('charlie', '@hubot uber add "home sweet home" -33.9258400, 18.4232200').then =>
      expect(@room.messages).to.eql [
        ['charlie', '@hubot uber add "home sweet home" -33.9258400, 18.4232200']
        ['hubot', 'Saved "home sweet home" at -33.9258400, 18.4232200 for Uber lookups']
      ]
