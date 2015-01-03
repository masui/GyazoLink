# GyazoLink

Gyazo画像のコメント/属性を利用して芋蔓検索を行なう。

* (JSONデータを使う旧版はLocalディレクトリに入れた)
* express + Mongo 利用

[gyazo.masuilab.org](http://gyazo.masuilab.org/) で運用中

* 約5万枚の写真やGyazoデータのコメントを利用
* 画像の類似度はTF-IDFで計算
* クリックした画像に近いものをリストする
* コメントからテキスト検索も可能

GeoJSONというのを使う場合

```
> use gyazo
> db.attrs.ensureIndex({'loc': '2dsphere'})
```
とするようなのだがRubyからこれを呼べないので

```
> db.attrs.ensureIndex({'loc': '2d'})
```

という「legacy」なやり方で登録する。

```
db.attrs.find({loc: {$near: [139.73, 35.63]}})
```
のようにして近いデータを検索できる。

