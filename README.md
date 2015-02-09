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


新しい近傍検索のやり方
http://docs.mongodb.org/manual/reference/operator/query/near/
http://stackoverflow.com/questions/22881401/mongodb-find-query-with-near-and-coordinates-not-working
GeoJSON
http://s.kitazaki.name/docs/geojson-spec-ja.html
2Dshpere index
http://docs.mongodb.org/manual/core/2dsphere/