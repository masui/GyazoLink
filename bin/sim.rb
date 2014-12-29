# -*- coding: utf-8 -*-
require 'mongo'
# require 'tf_idf'
require 'mecab'

require './tf_idf'

require 'json'

m = MeCab::Tagger.new ("-Ochasen")

connection = Mongo::Connection.new

gyazodb = connection.db('gyazo')
STDERR.puts "Gyazo connection established"

attrs_db = gyazodb.collection('attrs')
sim_db = gyazodb.collection('similarities')
sim_db.remove # 古いのは消す
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
exit

STDERR.puts "calculating similar list...."
STDERR.puts "calculating Norm...."
norm = []
(0..ndocuments).each { |ind|
  d = tfidf[ind]
  v = 0.0
  d.each { |key,val|
    v += val * val
  }
  norm[ind] = Math.sqrt(v)
}
STDERR.puts "end calculating Norm."

def sim(ind1,ind2,tfidf,norm)
  tfidf1 = tfidf[ind1]
  tfidf2 = tfidf[ind2]
  keywords = tfidf1.keys & tfidf2.keys
  cos = 0.0
  keywords.each { |keyword|
    cos += tfidf1[keyword] * tfidf2[keyword]
  }
  cos / (norm[ind1] * norm[ind2])
end

(0..ndocuments).each { |ind1|
  STDERR.puts "  document #{ind1}" if ind1 > 0 && ind1 % 1 == 0
  sims = {}
  (0..ndocuments).each { |ind2|
    v = sim(ind1,ind2,tfidf,norm)
    sims[ind2] = v if v > 0
  }
  b = sims.keys.sort { |x,y|
    sims[y] <=> sims[x]
  }
  #STDERR.puts "b.length = #{b.length}"
  #if b.length > 10000 then
  #  data = attrs_db.find_one({'gyazoid' => gyazoids[ind1]})
  #  puts data['keywords']
  #  puts data['gyazoid']
  #end
  b.delete(ind1) # 自分を削除

  data = {}
  data['gyazoid'] = gyazoids[ind1]
  data['ids'] = b.collect { |i| gyazoids[i] }[0...40]
  sim_db.insert(data)
}
