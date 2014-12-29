# GyazoLink

Gyazo画像のコメント/属性を利用して芋蔓検索を行なう。

* JSONデータを使うものはLocalディレクトリに入れてしまった
* expressサーバ + Mongo を使うように修正
* gyazo.masuilab.org で運用

http://gyazo.masuilab.org/ で運用中

* 約5万枚の写真やGyazoデータのコメントを利用
* 画像の類似度はTF-IDFで計算
* クリックした画像に近いものをリストする
* コメントからテキスト検索も可能
