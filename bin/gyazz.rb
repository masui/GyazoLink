#! /usr/bin/env ruby
# -*- coding: utf-8 -*-
#
# 古いGyazzデータをGyazoLinkで使うMongoデータに変換
# collectionは "attr"
#
require 'mongo'
require 'find'
require 'sdbm'
require 'digest/md5'
require 'nkf'

connection = Mongo::Connection.new

gyazodb = connection.db('gyazo')
STDERR.puts "Gyazo connection established"

attrs = gyazodb.collection('attrs')

def id(s)
  Digest::MD5.new.update(s).to_s
end

# バックアップのファイルを使う
GyazzDir = "/Volumes/Masui/Backups/gyazz.com/Gyazz/data"

id2title = SDBM.open("#{GyazzDir}/id2title",0666)

def find(wiki,attrs,id2title)
  pair = SDBM.open("#{GyazzDir}/#{id(wiki)}/pair",0666)
  links = {}
  pair.each { |key,val|
    (key1,key2) = key.split(/\t/)
    links[key1] = {} unless links[key1]
    links[key1][key2] = true
    links[key2] = {} unless links[key2]
    links[key2][key1] = true
  }
  Find.find("#{GyazzDir}/#{id(wiki)}") do |f|
    title = ""
    if f =~ /\/([0-9a-f]{32})\/([0-9a-f]{32})\/curfile$/ then
      wikiid = $1
      titleid = $2
      wiki = id2title[wikiid].to_s
      title = id2title[titleid].to_s
      if wiki != 'test' && title != 'test' && title != '' then
        if wiki && wiki != '' then
          STDERR.puts "#{wiki}/#{title}"
          text = NKF.nkf('-w', File.read(f))
          gyazoids = text.scan(/\[\[.*gyazo.*\/([0-9a-f]{32})/).map { |matches|
            matches[0]
          }
          if gyazoids.length > 0
            keywords = text.scan(/\[\[([^\s\[\]]+)\]\]/).find_all { |matches|
              matches[0] !~ /gyazo.*[0-9a-f]{32}/i
            }.map { |matches|
              matches[0]
            } + links[title].to_h.keys
            # 出力
            gyazoids.each { |gyazoid|
              data = attrs.find_one('gyazoid' => gyazoid).to_h
              data['text'] = data['text'].to_a + [text]
              data['keywords'] = data['keywords'].to_a + keywords
              STDERR.puts "#{data['keywords'].join('/')}"
              data['gyazoid'] = gyazoid
              if data['_id'] then
                attrs.update({'_id' => data['_id']}, data)
              else
                id = attrs.insert(data)
              end
            }
          end
        end
      end
    end
  end
end

find("masui",attrs,id2title)
