#! /usr/bin/env ruby
# -*- coding: utf-8 -*-
#
# GyazzのMongoデータをGyazoLinkで使うMongoデータに変換
# collectionは "attr"
#
require 'mongo'

connection = Mongo::Connection.new

gyazzdb = connection.db('gyazz')
STDERR.puts "Gyazz connection established"
gyazodb = connection.db('gyazo')
STDERR.puts "Gyazo connection established"

pages = gyazzdb.collection('pages')
attrs = gyazodb.collection('attrs')

def convert(wiki,pages,attrs)
  #
  # ページ内容取得
  # 同じWiki名/ページタイトルのデータが複数あるので最新のものだけ選ぶ
  #
  _gyazzdata = pages.find('wiki' => wiki).group_by { |page|
    page['title']
  }.collect { |title,pages|
    [
     title,
     pages.sort { |page1,page2|
       page2['timestamp'] <=> page1['timestamp']
     }.first
    ]
  }
  gyazzdata = Hash[_gyazzdata]
  #
  # リンク解析
  # AというページにBへのリンクがあるときlinks[A] = [B, ...] となる
  #
  _links = gyazzdata.map { |title,entry|
    entry['text'].scan(/\[\[([^\s\[\]]+)\]\]/).find_all { |matches|
      matches[0] !~ /gyazo.*[0-9a-f]{32}/i
    }.map { |matches|
      [[title, matches[0]], [matches[0], title]]
    }.reduce([]){ |a,b| a+b }
  }.reduce([]){ |a,b| a+b
  }.group_by { |entry|
    entry[0]
  }.map { |key,val|
    [key, val.map { |e| e[1] }.uniq]
  }
  links = Hash[_links]

  #
  # Gyazo用データ出力
  #
  gyazzdata.each { |title,entry|
    text = entry['text']
    gyazoids = text.scan(/\[\[.*gyazo.*\/([0-9a-f]{32})/).map { |matches|
      matches[0]
    }
    if gyazoids.length > 0
      keywords = text.scan(/\[\[([^\s\[\]]+)\]\]/).find_all { |matches|
        matches[0] !~ /gyazo.*[0-9a-f]{32}/i
      }.map { |matches|
        matches[0]
      }
      #
      # 出力
      #
      gyazoids.each { |gyazoid|
        data = attrs.find_one('gyazoid' => gyazoid).to_h
        data['text'] = (data['text'].to_a + [text]).uniq
        data['keywords'] = (data['keywords'].to_a + [title] + links[title].to_a + keywords).uniq
        data['gyazoid'] = gyazoid
        if data['_id'] then
          attrs.update({'_id' => data['_id']}, data)
        else
          id = attrs.insert(data)
        end
      }
    end
  }
end
  
convert('増井研',pages,attrs)
convert('osusume',pages,attrs)

