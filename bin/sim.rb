# -*- coding: utf-8 -*-
require 'mongo'
require 'mecab'

require './tf_idf'

require 'json'

m = MeCab::Tagger.new ("-Ochasen")

connection = Mongo::Connection.new

gyazodb = connection.db('gyazo')
STDERR.puts "Gyazo connection established"

attrs_db = gyazodb.collection('attrs')
tfidf_db = gyazodb.collection('tfidfs')
tfidf_db.remove # 古いのは消す

gyazoids = []
words = []
totalwords = {}
ndocuments = 0

STDERR.puts "Extracting keywords using MeCab..."
attrs_db.find.each_with_index { |document,index|
  gyazoid = document['gyazoid']
  # STDERR.puts "#{index} #{gyazoid}"
  STDERR.puts "  document #{index}" if index > 0 && index % 10000 == 0
  keywords = document['keywords']
  newkeywords = []
  keywords.each { |keyword|
    hashkeywords = []
    while keyword.sub!(/[0-9a-f]{32}/,'') do
      hashkeywords << $&
    end
    mecabout = m.parse(keyword).to_s
    mecabout.split(/\n/).each { |line|
      line.chomp!
      next if line == 'EOS'
      a = line.split(/\s+/)
      newkeywords << a[0]
      totalwords[a[0]] = totalwords[a[0]].to_i + 1
    }
    hashkeywords.each { |hashkeyword|
      newkeywords << hashkeyword
      totalwords[hashkeyword] = totalwords[hashkeyword].to_i + 1
    }
  }
  words[index] = newkeywords
  # STDERR.puts index
  # STDERR.puts newkeywords.join(',')
  gyazoids[index] = gyazoid
  ndocuments = index
}
STDERR.puts "Total #{gyazoids.length} images, #{totalwords.keys.length} words."

STDERR.puts "calculating TF-IDF...."
tfidf = TfIdf.new(words).tf_idf

STDERR.puts "ssaving TF-IDF to mongoDB...."
tfidf.each_with_index { |entry,index|
  data = {}
  data['gyazoid'] = gyazoids[index]
  entry.each { |key,val| # ".", "$" を含むものはMongoで使えない模様
    if key =~ /\./ || key =~ /^\$/ then
      entry.delete(key)
    end
  }
  data['tfidf'] = entry
  tfidf_db.insert(data)
}
