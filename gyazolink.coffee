#
# ExpressによるGyazo検索システムのメインプログラム
#

dotenv   = require 'dotenv'
express  = require 'express'
favicon  = require 'serve-favicon'
mongoose = require 'mongoose'
path     = require 'path'
debug    = require('debug')('GyazoLink')

## load environments from '.env'
dotenv.load()

## express modules
bodyParser = require 'body-parser'
multer     = require 'multer'
rollbar    = require 'rollbar'

## Config
package_json = require path.resolve 'package.json'
process.env.PORT ||= 3000

## server setup ##
module.exports = app = express()
app.disable 'x-powered-by'
# app.use favicon path.resolve 'public/favicon.ico'
app.use express.static path.resolve 'public'  # public以下のファイルはWikiデータとみなさないようにする
app.set 'view engine', 'jade'
app.use bodyParser.json limit: '100mb'
app.use bodyParser.urlencoded extended: true, limit: '100mb'
app.use multer dest: path.resolve 'public', 'upload'
app.use rollbar.errorHandler process.env.ROLLBAR_TOKEN if process.env.ROLLBAR_TOKEN

if process.env.NODE_ENV isnt 'production'
  app.locals.pretty = true  # jade出力を整形

http = require('http').Server(app)
io = require('socket.io')(http)
app.set 'socket.io', io
app.set 'package', package_json

## load controllers, models, socket.io ##
components =
  models:      [ 'attr', 'tfidf' ]
  controllers: [ 'main' ]

for type, items of components
  for item in items
    debug "load #{type}/#{item}"
    require(path.resolve type, item)(app)

mongodb_uri = process.env.MONGOLAB_URI or
              process.env.MONGOHQ_URL or
              'mongodb://localhost/gyazo'

mongoose.connect mongodb_uri, (err) ->
  if err
    debug "mongoose connect failed"
    debug err
    process.exit 1
    return
  debug "connect MongoDB"

  if process.argv[1] isnt __filename
    return   # if load as a module, do not start HTTP server

  ## start server ##
  http.listen process.env.PORT, ->
    console.log "listening on *:#{process.env.PORT}..."
