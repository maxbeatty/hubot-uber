# Description:
#   Get Uber estimates for price and time
#
# Dependencies:
#   cli-table
#
# Configuration:
#   HUBOT_UBER_TOKEN - server token from https://developer.uber.com/apps/
#
# Commands:
#   hubot uber add <location> <lat>, <lon> - add a location
#   hubot uber default - get default location name
#   hubot uber default <location> - set location as the default to use
#   hubot uber locations - get list of locations
#   hubot uber products <location> - get products available for location
#   hubot uber prices <location> - get price estimates for location
#   hubot uber times <location> - get time estimates for location
#   hubot uber promo <location> - get promotion for new user at location
#
# Author:
#   maxbeatty

Table = require 'cli-table'

UBER_API_URL = 'https://api.uber.com/v1/'

module.exports = (robot) ->

  getLoc = (msg, cb) ->
    loc = msg.match[1]
    loc ?= robot.brain.get 'uberDefault'
    locations = robot.brain.get 'uberLocations'
    locations ?= {}

    if locations[loc]
      cb locations[loc]
    else
      msg.send 'No location provided. Try "help uber" to learn how to add'

  makeApiCall = (path, lat, lon, cb) ->
    params = server_token: process.env.HUBOT_UBER_TOKEN

    switch path
      when 'products'
        params.latitude = lat
        params.longitude = lon
      when 'estimates/price', 'promotions'
        params.start_latitude = lat
        params.start_longitude = lon
        params.end_latitude = lat
        params.end_longitude = lon
      when 'estimates/time'
        params.start_latitude = lat
        params.start_longitude = lon
      else
        cb new Error('Unknown path')

    robot.http("#{UBER_API_URL}#{path}").query(params).get() cb

  # "hubot uber add office 12.345 67.890"
  # match lat and lon http://stackoverflow.com/a/3518546/613588
  robot.respond /uber add (.+) (\-?\d+(\.\d+)?),\s*(\-?\d+(\.\d+)?)/i, (msg) ->
    loc = msg.match[1]
    lat = msg.match[2]
    lon = msg.match[4]

    locations = robot.brain.get 'uberLocations'
    locations ?= {}
    locations[loc] =
      lat: parseFloat lat
      lon: parseFloat lon
    robot.brain.set 'uberLocations', locations

    msg.send "Saved #{loc} at #{lat}, #{lon} for Uber lookups"

  # "hubot uber default office"
  robot.respond /uber default\s?(.+)?/i, (msg) ->
    loc = msg.match[1]

    if loc
      locations = robot.brain.get 'uberLocations'
      locations ?= {}

      if locations[loc]
        robot.brain.set 'uberDefault', loc

        msg.send "Saved #{loc} as default location"

      else
        msg.send "#{loc} hasn't been added yet"
    else
      if name = robot.brain.get 'uberDefault'
        msg.send 'Default location is ' + name
      else
        msg.send 'No default set yet'

  # "hubot uber show locations"
  robot.respond /uber locations/i, (msg) ->
    table = new Table
      head: ['Location', 'Latitude', 'Longitude']

    locations = robot.brain.get 'uberLocations'
    locations ?= {}

    for loc, coord of locations
      table.push [loc, coord.lat, coord.lon]

    msg.send "#{table}"

  # "hubot uber products office"
  robot.respond /uber products\s?(.+)?/i, (msg) ->
    getLoc msg, (loc) ->
      makeApiCall 'products', loc.lat, loc.lon, (err, res, body) ->
        robot.emit 'error', err if err

        table = new Table
          head: ['Product', 'Description']

        json = JSON.parse body
        for product in json.products
          table.push [product.display_name, product.description]

        msg.send "#{table}"

  robot.respond /uber prices\s?(.+)?/i, (msg) ->
    getLoc msg, (loc) ->
      makeApiCall 'estimates/price', loc.lat, loc.lon, (err, res, body) ->
        robot.emit 'error', err if err

        table = new Table
          head: ['Product', 'Price']

        json = JSON.parse body
        for product in json.prices
          table.push [product.display_name, product.estimate]

        msg.send "#{table}"

  robot.respond /uber times?\s?(.+)?/i, (msg) ->
    getLoc msg, (loc) ->
      makeApiCall 'estimates/time', loc.lat, loc.lon, (err, res, body) ->
        robot.emit 'error', err if err

        table = new Table
          head: ['Product', 'Time']

        json = JSON.parse body
        for product in json.times
          time = Math.round(product.estimate / 60).toString() + ' min'
          table.push [product.display_name, time]

        msg.send "#{table}"

  robot.respond /uber promo\s?(.+)?/i, (msg) ->
    getLoc msg, (loc) ->
      makeApiCall 'promotions', loc.lat, loc.lon, (err, res, body) ->
        robot.emit 'error', err if err

        try
          msg.send JSON.parse(body).display_text
        catch e
          msg.send 'Uber experienced a problem'
