require 'mongo'

connection = Mongo::Connection.new

gyazodb = connection.db('gyazo')
STDERR.puts "Gyazo connection established"

attrs = gyazodb.collection('attrs')

attrs.find({'gyazoid' => '15991ca9297573763814be0869d29bf7'}).each { |entry|
  puts entry
}

