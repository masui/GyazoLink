backup:
	mongodump -d gyazo

datacopy: backup
	scp -r dump masui.sfc.keio.ac.jp:/Users/masui/GyazoLink
	ssh masui.sfc.keio.ac.jp 'cd GyazoLink; /usr/local/bin/mongorestore -d gyazo dump/gyazo'
