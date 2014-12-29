#
# メインコントローラモジュール
#

debug    = require('debug')('gyazo:controller:main')
mongoose = require 'mongoose'
RSS      = require 'rss'

Attr  = mongoose.model 'Attr'
Similarities = mongoose.model 'Similarities'

module.exports = (app) ->

  app.get '/similarimages', (req, res) ->
    query = req.query.q
    return res.render 'index',
      text: query
    # return res.redirect "/index.html"

  #app.get '/sss', (req, res) ->
  #  return res.render 'index',
  #    title: 'index'
  #    attr: [1, 2, 3]

  # Gyazo画像属性のJSONデータを得る
  app.get '/attr/:gyazoid', (req, res) ->
    gyazoid = req.params.gyazoid
    Attr.attr gyazoid, (err, result) ->
      res.send
        text: result.text
        keywords: result.keywords

  # 類似画像リストを得る
  app.get '/similar/:gyazoid', (req, res) ->
    gyazoid = req.params.gyazoid
    Similarities.search gyazoid, (err, result) ->
      res.send
        ids: if result then result.ids else []

  # キーワードを含む画像リストを得る
  app.get '/search/:query', (req, res) ->
    query = req.params.query
    Attr.search query, (err, result) ->
      res.send
        ids: result

