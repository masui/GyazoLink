# -*- coding: emacs-mule -*-
require 'mongo'
require 'tf_idf'
require 'mecab'

m = MeCab::Tagger.new ("-Ochasen")

connection = Mongo::Connection.new

gyazodb = connection.db('gyazo')
STDERR.puts "Gyazo connection established"

attrs = gyazodb.collection('attrs')
sim = gyazodb.collection('similarities')
sim.remove # ’¸Å’¤¤’¤Î’¤Ï’¾Ã’¤¹

gyazoids = []
words = []

attrs.find.each_with_index { |entry,index|
  gyazoid = entry['gyazoid']
  STDERR.puts "#{index} #{gyazoid}"
  keywords = entry['keywords']
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
  gyazoids[index] = gyazoid
}

STDERR.puts "calculating TF-IDF...."
tfidf = TfIdf.new(words).tf_idf

STDERR.puts "calculating similar list...."
norm = []
(0...words.length).each { |ind|
  d = tfidf[ind]
  v = 0.0
  d.each { |key,val|
    v += val * val
  }
  norm[ind] = Math.sqrt(v)
}

def sim(ind1,ind2,tfidf,norm)
  doc1 = tfidf[ind1]
  doc2 = tfidf[ind2]
  keywords = doc1.keys & doc2.keys
  cos = 0.0
  keywords.each { |keyword|
    cos += doc1[keyword] * doc2[keyword]
  }
  cos / (norm[ind1] * norm[ind2])
end

(0...words.length).each { |ind1|
  sims = {}
  (0...words.length).each { |ind2|
    sims[ind2] = sim(ind1,ind2,tfidf,norm)
  }
  b = sims.keys.sort { |x,y|
    sims[y] <=> sims[x]
  }
  b.delete(ind1) # ’¼«’Ê¬’¤ò’ºï’½ü

  data = {}
  data['gyazoid'] = gyazoids[ind1]
  data['ids'] = b.collect { |i| gyazoids[i] }[0...40]
  sim.insert(data)
}
