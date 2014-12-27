require 'json'

tfidf = JSON.parse(File.read('tfidf.json'))
ids = JSON.parse(File.read('ids.json'))

def sim(doc1, doc2)
  keywords = doc1.keys & doc2.keys
  cos = 0.0
  keywords.each { |keyword|
    cos += doc1[keyword] * doc2[keyword]
  }
  t1 = 0.0
  doc1.each { |key,val|
    t1 += val * val
  }
  t2 = 0.0
  doc2.each { |key,val|
    t2 += val * val
  }
  cos / (Math.sqrt(t1) * Math.sqrt(t2))
end

(400..400).each { |ind1|
  doc1 = tfidf[ind1]
  sims = {}
  (0...ids.length).each { |ind2|
    doc2 = tfidf[ind2]
    sims[ind2] = sim(doc1,doc2)
  }
  b = sims.keys.sort { |x,y|
    sims[y] <=> sims[x]
  }
  b.each { |ind|
    puts "#{ids[ind]} => #{sims[ind]}"
  }




    # puts "sim(#{ids[ind1]},#{ids[ind2]}) = #{sim(doc1,doc2)}"

}
