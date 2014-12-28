#
# Gyazoの類似画像
#

debug = require('debug')('gyazo:similarity')

mongoose = require 'mongoose'

module.exports = (app) ->

  similaritySchema = new mongoose.Schema
    gyazoid:
      type: String
    ids:
      type: Array

  similaritySchema.statics.search = (gyazoid, callback) ->
    @findOne
      gyazoid:gyazoid
    .exec (err, result) ->
      return callback err if err
      return callback "not found" unless result
      callback null, result

  mongoose.model 'Similarities', similaritySchema
