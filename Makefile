mongo:
	ruby mongo.rb  | jq . > mongo.json
presen:
	ruby presen.rb  | jq . > presen.json
gyazz:
	ruby gyazz.rb  | jq . > gyazz.json
alldata:
	ruby alldata.rb | jq . > data.json
