require 'mongo'

connection = Mongo::Connection.new

gyazodb = connection.db('gyazo')
STDERR.puts "Gyazo connection established"

sim = gyazodb.collection('similarity')

sim.find.each { |entry|
  puts entry['gyazoid']
  entry['ids'].each { |id|
    puts "  #{id}"
  }
}

#attrs = gyazodb.collection('attrs')
#
#attrs.find.each { |entry|
#  puts entry['gyazoid']
#  entry['keywords'].each { |keyword|
#    puts "  #{keyword}"
#  }
#}


