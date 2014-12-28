require 'tf_idf'
require 'json'
require 'mecab'

data = JSON.parse(File.read('data.json'))
ids = data.keys.sort

m = MeCab::Tagger.new ("-Ochasen")

words = []
ids.each_with_index { |id,index|
  keywords = data[id]['keywords']
  newkeywords = []
  keywords.each { |keyword|
    mecabout = m.parse(keyword).to_s
    mecabout.split(/\n/).each { |line|
      line.chomp!
      next if line == 'EOS'
      a = line.split(/\s+/)
      newkeywords << a[0]
    }
  }
  words[index] = newkeywords
}

tfidf = TfIdf.new(words).tf_idf

puts tfidf.to_json
