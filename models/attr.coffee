#
# Gyazoの属性
#

debug = require('debug')('gyazo:attr')

mongoose = require 'mongoose'
_        = require 'underscore'

module.exports = (app) ->

  attrSchema = new mongoose.Schema
    gyazoid:
      type: String
    text:
      type: Array
    keywords:
      type: Array

  attrSchema.statics.attr = (gyazoid, callback) ->
    @findOne
      gyazoid:gyazoid
    .exec (err, result) ->
      return callback err if err
      return callback "not found" unless result
      callback null, result

  attrSchema.statics.search = (query, callback) ->
    @find {}
    .exec (err,result) ->
      res = _.filter result, (entry) ->
        entry.keywords.join('').indexOf(query) >= 0
      .map (entry) ->
        entry.gyazoid
      callback null, res

  mongoose.model 'Attr', attrSchema
