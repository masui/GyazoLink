#! /usr/bin/env ruby
# -*- coding: utf-8 -*-
#
require 'mongo'
require 'sdbm'
require 'json'

# MongoDB
#
# データ
#   wiki名, page名, id, text
#
# % mongo gyazz
# MongoDB shell version: 2.4.8
# connecting to: gyazz
# > db.pages
# gyazz.pages
# > db.pages.find()
# > db.pages.find({title:'Xcode'})
#

connection = Mongo::Connection.new

gyazzdb = connection.db('gyazz')
STDERR.puts "connection established"

pages = gyazzdb.collection('pages')
data = {}

def get_json(wiki,pages,data)
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
        data[gyazoid] = {} unless data[gyazoid]
        
        unless data[gyazoid]['text'] then
          data[gyazoid]['text'] = [text]
        else
          data[gyazoid]['text'] << text unless data[gyazoid]['text'].member?(text)
        end
        
        data[gyazoid]['keywords'] = [] unless data[gyazoid]['keywords']
        keywords = {}
        keywords[title] = true
        data[gyazoid]['keywords'].each { |keyword|
          keywords[keyword] = true
        }
        pagelinks.keys.each { |keyword|
          keywords[keyword] = true
        }
        data[gyazoid]['keywords'] = keywords.keys
      }
    end
  }
end
  
get_json('増井研',pages,data)
get_json('osusume',pages,data)

puts data.to_json
