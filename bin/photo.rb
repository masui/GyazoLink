# -*- coding: utf-8 -*-
# [
#   ["19950327000100", "9959a0063a708422bb8711e772402ae9", "http://masui.sfc.keio.ac.jp/Photos/40986c4c4a309ecca49edacfdf8d8798.jpg", 33.1013202640288, 131.223277042406, "建斗, やまなみハイウェイ", ""],
#   ["19960820000100", "04bd917417951b9cb0147ab744e387a7", "http://masui.sfc.keio.ac.jp/Photos/16a945c8d6b311160ae7f727b4f97efe.jpg", 35.6259460468893, 139.730376512521, "原田", ""],
#   ["19970221000100", "4a0938b973849f3331e997c38889ef3a", "http://masui.sfc.keio.ac.jp/Photos/89b3a210f014df14bf5f583ae6c4a99b.jpg", 35.6481223540639, 140.036424240918, "", ""],
#   ["19970221000101", "d6f9a7db81b180b3d68470b96112c163", "http://masui.sfc.keio.ac.jp/Photos/7a821beb3354a04ef1298b59d73376c5.jpg", null, null, "大平徹", ""],
#   ["19970221000102", "6861f32f2965d4bf0b4ea4445141e93d", "http://masui.sfc.keio.ac.jp/Photos/9a443a72ef59ef9c07a57cbe268d1859.jpg", 35.6498849540481, 140.037038830945, "増井 俊之", ""],
#   ["19970826190050", "4fecf0e1904d04cc22c192ccd00cdd96", "http://masui.sfc.keio.ac.jp/Photos/53bc9d34d0c8c783e4994b78a962f232.jpg", null, null, "", ""],
#   ["19970830005454", "eb51b2e25a5693f1b5807ca21335dc7b", "http://masui.sfc.keio.ac.jp/Photos/4118c63d3b03b22830f0581a1af95096.jpg", null, null, "", ""],
#   ["19970830005542", "3d802aeec46dc09c721b0f55ca5dce0e", "http://masui.sfc.keio.ac.jp/Photos/352f434478240b317484ecae772464e7.jpg", null, null, "", ""],
#   ["19970830012302", "fce0f757350878e8740080d112670ef1", "http://masui.sfc.keio.ac.jp/Photos/599d23a879f56823ea040b8ca7975166.jpg", 35.3128043014817, 139.557652497072, "", ""],
#

require 'mongo'
require 'json'

connection = Mongo::Connection.new

gyazodb = connection.db('gyazo')
STDERR.puts "Gyazo connection established"

attrs = gyazodb.collection('attrs')

data = JSON.parse(File.read('photodata.json'))
data.each_with_index { |line,index|
  STDERR.puts index if index > 0 && index % 100 == 0
  date = line[0]
  gyazoid = line[1]
  url = line[2]
  latitude = line[3]
  longitude = line[4]
  comment = line[5]

  if gyazoid =~ /^[0-9a-f]{32}/ then # Gyazoにコピーされた写真
    date =~ /^((......)..)/
    date_month = $2
    date_day = $1
    keywords = []
    keywords << date
    keywords << date_day
    keywords << date_month
    keywords << "latitude: #{latitude}"
    keywords << "longitude: #{longitude}"
    keywords << url
    keywords << comment unless comment.to_s =~ /^\s*$/
    data = {}
    data['gyazoid'] = gyazoid
    data['keywords'] = keywords
    attrs.insert(data)
  end
}

