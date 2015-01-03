#! /usr/bin/env ruby
# -*- coding: utf-8 -*-
#
# カスタムデータ(custom.json)をGyazoLinkで使うMongoデータに変換
# collectionは "attr"
#
require 'mongo'
require 'json'

connection = Mongo::Connection.new

gyazodb = connection.db('gyazo')
STDERR.puts "Gyazo connection established"

attrs = gyazodb.collection('attrs')

customdata = JSON.parse(File.read("custom.json"))

customdata.each { |gyazoid, attr|
  p attr
  data = {
    'text' => attr['text'],
    'keywords' => attr['keywords'],
    'gyazoid' => gyazoid
  }
  attrs.insert(data)
}
