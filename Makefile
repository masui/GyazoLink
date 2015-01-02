#
# データ作成は bin ディレクトリで行なう
#

# Expressサーバをローカルに立てる
run:
	cd public/javascripts; coffee -c -b similar.coffee
	cd public/javascripts; coffee -c -b search.coffee
	npm start

# 現在のデータベースをdumpにダンプする
dump_db:
	mongodump -d gyazo

# TF-IDF値を計算。計算プログラムはbin以下にある
tfidf:
	cd bin; make tfidf

#  gyazo.masuilab.org で運用するためにTF-IDFデータを送る
senddb:
	scp -r dump masui.sfc.keio.ac.jp:/Users/masui/GyazoLink
	ssh masui.sfc.keio.ac.jp 'cd GyazoLink/bin; ruby remove_gyazo.rb'
	ssh masui.sfc.keio.ac.jp 'cd GyazoLink; /usr/local/bin/mongorestore -d gyazo dump/gyazo'

# gyazz.masuilab.orgの最新データを取得
getdb:
	cd bin; make getdb

#
# TF-IDFデータベースを再構築してから送る
#
calc_send: getdb tfidf dump_db senddb
all: calc_send
#
# 現在のデータベースをコピー
#
simple_send: dump_db senddb

