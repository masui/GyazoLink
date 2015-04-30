#
# メインコントローラモジュール
#

debug    = require('debug')('gyazo:controller:main')
mongoose = require 'mongoose'
RSS      = require 'rss'

Attr  = mongoose.model 'Attr'
Tfidf = mongoose.model 'Tfidf'

module.exports = (app) ->

  app.get '/',  (req, res) ->
    res.redirect "/similar?id=13809a42c06c10be8bcf22a0f81e5a69"

  app.get '/similar', (req, res) ->
    gyazoid = req.query.id
    return res.render 'similar',
      gyazoid: gyazoid

  app.get '/search', (req, res) ->
    query = req.query.query
    return res.render 'search',
      query: query

  #####  API ######

  # Gyazo画像属性のJSONデータを得る
  app.get '/__attr/:gyazoid', (req, res) ->
    gyazoid = req.params.gyazoid
    Attr.attr gyazoid, (err, result) ->
      res.send
        text: result.text
        keywords: result.keywords

  # 類似画像リストを得る
  app.get '/__similar/:gyazoid', (req, res) ->
    gyazoid = req.params.gyazoid
    Tfidf.search gyazoid, (err, result) ->
      res.send
        ids: if result then result else []
    
  # キーワードを含む画像リストを得る
  app.get '/__search/:query', (req, res) ->
    query = req.params.query
    Attr.search query, (err, result) ->
      res.send
        ids: result

