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
  gyazzdata = {}
  pages.find('wiki' => wiki).each { |page|
    title = page['title']
    timestamp = page['timestamp']
    gyazzdata[title] = {} unless gyazzdata[title]
    if gyazzdata[title]['timestamp'].to_i < timestamp.to_i then
      gyazzdata[title]['timestamp'] = timestamp
      gyazzdata[title]['text'] = page['text']
    end
  }
  
  #
  # リンク解析
  #
  links = {}
  gyazzdata.each { |title,entry|
    text = entry['text']
    while text.sub!(/\[\[([^\s\[\]]+)\]\]/,'') do
      kw = $1
      unless kw =~ /gyazo.*[0-9a-f]{32}/i then
        links[title] = {} unless links[title]
        links[title][kw] = true
        links[kw] = {} unless links[kw]
        links[kw][title] = true
      end
    end
  }
  
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
        links[title].each { |key,val|
          pagelinks[key] = true
        }
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

