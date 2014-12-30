##
## Gyazo画像を含むGyazzページやプレゼン資料などをもとにして
## Gyazoとコメントテキストの組のデータベースを作成し、
## そのTF-IDFを計算する
##
## 2014/12/30 23:14:30 増井
##

#
# TF-IDFの計算
#
tfidf: removedb createdb
	ruby tfidf.rb

#
# MongoDBのgyazz, gyazoデータベースを削除
#
removedb:
	ruby remove_gyazz.rb
	ruby remove_gyazo.rb
#
# データベース作成
#
createdb: photo custom mongo gyazz presen

#
# Mongoの gyazo/attrコレクションにデータを格納する
#

#  ../data/photodata2.jsからMongoデータ生成
photo:
	ruby photo.rb

# custom.jsonからMongoデータ生成(attr)
custom:
	ruby custom.rb

# 新GyazzデータからMongoデータ生成
mongo: datacopy
	ruby mongo.rb

#  旧GyazzデータからMongoデータ生成
gyazz:
	ruby gyazz.rb

# プレゼン資料からMongoデータ生成
presen:
	ruby presen.rb

#
# gyazz.masuilab.org からデータをコピーしてローカルのMongoDBに入れる
#
datacopy:
	ssh masui.sfc.keio.ac.jp 'cd Gyazz; /usr/local/bin/mongodump -d gyazz'
	scp -r masui.sfc.keio.ac.jp:/Users/masui/Gyazz/dump/gyazz /Users/masui/GyazzCoffee/dump
	cd /Users/masui/GyazzCoffee; /usr/local/bin/mongorestore -d gyazz dump/gyazz
