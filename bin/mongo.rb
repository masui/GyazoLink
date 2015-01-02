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
  gyazzdata = Hash[pages.find('wiki' => '増井研').group_by { |page|
                     page['title']
                   }.collect { |title,pages|
                     [
                      title,
                      pages.sort { |page1,page2|
                        page2['timestamp'] <=> page1['timestamp']
                      }.first
                     ]
                   }]
  #
  # リンク解析
  # AというページにBへのリンクがあるときlinks[A] = [B, ...] となる
  #
  links = Hash[gyazzdata.map { |title,entry|
                 entry['text'].scan(/\[\[([^\s\[\]]+)\]\]/).map { |keywords|
                   keywords.find_all { |keyword|
                     keyword =~ /gyazo.*[0-9a-f]{32}/i
                   }.map { |keyword|
                     [[title, keyword], [keyword, title]]
                   }.reduce([]){ |a,b| a+b }
                 }.reduce([]){ |a,b| a+b }
               }.reduce([]){ |a,b| a+b
               }.group_by { |entry|
                 entry[0]
               }.map { |key,val|
                 [key, val.map { |e| e[1] }.uniq]
               }]
  
  #
  # Gyazo用データ出力
  #
  gyazzdata.each { |title,entry|
    pagelinks = {}
    text = entry['text']
    s = text.dup
    have_gyazo = false
    gyazoids = []
    while s.sub!(/\[\[.*gyazo.*\/([0-9a-f]{32})/i,'') do
      gyazoid = $1
      gyazoids << gyazoid
      STDERR.puts "#{gyazoid} #{wiki} #{title}"
      have_gyazo = true
    end
    if have_gyazo
      while s.sub!(/\[\[([^\s\[\]]+)\]\]/,'') do
        kw = $1
        pagelinks[kw] = true
      end
      if links[title] then
        links[title].each { |entry|
          pagelinks[entry] = true
        }
        #links[title].each { |key,val|
        #  pagelinks[key] = true
        #}
      end
      STDERR.puts "pagelinks = #{pagelinks.keys.join('/')}"
      
      # 出力
      gyazoids.each { |gyazoid|
        data = attrs.find_one('gyazoid' => gyazoid)
        data = {} unless data
        unless data['text'] then
          data['text'] = [text]
        else
          data['text'] << text unless data['text'].member?(text)
        end
        
        data['keywords'] = [] unless data['keywords']
        keywords = {}
        keywords[title] = true
        data['keywords'].each { |keyword|
          keywords[keyword] = true
        }
        pagelinks.keys.each { |keyword|
          keywords[keyword] = true
        }
        data['keywords'] = keywords.keys
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

