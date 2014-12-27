require 'json'

tfidf = JSON.parse(File.read('tfidf.json'))
ids = JSON.parse(File.read('ids.json'))

norm = []
(0...ids.length).each { |ind|
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

out = {}
(0...ids.length).each { |ind1|
  sims = {}
  (0...ids.length).each { |ind2|
    sims[ind2] = sim(ind1,ind2,tfidf,norm)
  }
  b = sims.keys.sort { |x,y|
    sims[y] <=> sims[x]
  }
  b.delete(ind1)
  out[ids[ind1]] = b.collect { |i| ids[i] }[0...40]
}

puts out.to_json

