#
# データ作成は bin ディレクトリで行なう
#

run:
	cd public/javascripts; coffee -c -b similar.coffee
	cd public/javascripts; coffee -c -b search.coffee
	npm start

backup:
	mongodump -d gyazo

data:
	cd bin; make

#
#  gyazo.masuilab.org で運用するためにデータをコピー
#
datacopy: backup
	scp -r dump masui.sfc.keio.ac.jp:/Users/masui/GyazoLink
	ssh masui.sfc.keio.ac.jp 'cd GyazoLink; /usr/local/bin/mongorestore -d gyazo dump/gyazo'

