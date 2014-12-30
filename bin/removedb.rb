#
# MongoDBの gyazz, gyazoデータベース削除
#
require 'mongo'

connection = Mongo::Connection.new

connection.drop_database('gyazz')
connection.drop_database('gyazo')

