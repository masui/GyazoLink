mongo:
	ruby mongo.rb  | jq . > mongo.json
presen:
	ruby presen.rb  | jq . > presen.json
gyazz:
	ruby gyazz.rb  | jq . > gyazz.json
alldata:
	ruby alldata.rb | jq . > data.json


ids:
	ruby ids.rb | jq . > ids.json
tfidf:
	ruby tfidf.rb | jq . > tfidf.json
sim:
	ruby sim.rb | jq . > sim.json
