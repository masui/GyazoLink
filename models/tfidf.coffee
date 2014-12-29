#
# TF-IDF
#

debug = require('debug')('gyazo:tfidf')
_     = require 'underscore'

mongoose = require 'mongoose'

module.exports = (app) ->
  norm = []
  
  keys = (hash) ->
    _.map hash, (value, key) -> key
  
  values = (hash) ->
    _.map hash, (value, key) -> value
    
  sim = (ind1, ind2, data) -> # ind1番目のエントリとind2番目のエントリの類似度計算
    a1 = keys data[ind1].tfidf
    a2 = keys data[ind2].tfidf
    commonkeys = _.intersection a1, a2
    cos =  _.reduce commonkeys, (a,b) ->
      a + data[ind1].tfidf[b] * data[ind2].tfidf[b]
    , 0
    cos / norm[ind1] / norm[ind2]
  
  sims = (n, data) -> # n番目のエントリと他のエントリがどれだけ近いか
    #console.log "calc sims"
    _.map [0..data.length-1], (ind) -> [
      sim n, ind, data
      data[ind].gyazoid
    ]
  
  findindex = (gyazoid, data) ->
    a = _.map data, (d) ->
     d.gyazoid
    _.indexOf a, gyazoid
  
  similar = (gyazoid, data) ->
    #console.log "calc similar"
    ind = findindex(gyazoid, data)
    #console.log "index=#{ind}"
    sorted = _.sortBy sims(ind, data), (a) -> -a[0]
      .map (a) -> a[1]
    #console.log "sorted end"
    #console.log sorted[0..10]
    _.without sorted[0..40], gyazoid
    
  tfidfSchema = new mongoose.Schema

    gyazoid:
      type: String
    tfidf:
      type: Object

  tfidfSchema.statics.search = (gyazoid, callback) ->
    @find {}
    .exec (err, result) ->
      return callback err if err
      return callback "not found" unless result
      #console.log "xxxxx"
      data = result
      #console.log "calc norm"
      norm = _.map data, (d) ->
        Math.sqrt _.reduce d.tfidf, (a,b) ->
          a + b * b
        , 0

      #console.log "norm calculated"
      res = similar(gyazoid, data)
      #console.log res
      callback null, res

  mongoose.model 'Tfidf', tfidfSchema
