# Hubot Uber

A [Hubot](https://hubot.github.com/) script to get estimates and promos from [Uber](https://www.uber.com/invite/rtjmz)

## Install

In hubot project repo, run:

```
npm install hubot-uber --save
```

Then add **hubot-uber** to your `external-scripts.json`:

```
["hubot-uber"]
```

## Usage

### add

Add a location to use as base for Uber estimates.

> hubot uber add office 37.782093, -122.391580

### default

Set a location as the default.

> hubot uber default office

Get the default

> hubot uber default

### locations

List locations added

> hubot uber locations

### products

Get list of products available for a location.

> hubot uber products office

_Location is optional if you've set a default_

> hubot uber products

### prices

Get list of prices (surge included) available for a location.

> hubot uber prices office

_Location is optional if you've set a default_

> hubot uber prices

### times

Get list of wait times for a location.

> hubot uber times office

_Location is optional if you've set a default_

> hubot uber times

### promo

Get promotion available to new users for a location.

> hubot uber promo office

_Location is optional if you've set a default_

> hubot uber promo

## Help

- [Get the coordinates of a place from Google Maps](https://support.google.com/maps/answer/18539?hl=en)

## Credits

- [@holman](https://github.com/holman)'s [gist](https://gist.github.com/holman/55130df8c9ba9fbce085) inspired this
