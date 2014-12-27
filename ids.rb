require 'json'

data = JSON.parse(File.read('data.json'))
ids = data.keys.sort

puts ids.to_json
