#! /usr/bin/env ruby
# -*- coding: utf-8 -*-
#
# GyazzデータをGyazoLinkで使うMongoデータに変換
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
  Digest::MD5.new.update(s)
end

GyazzDir = "/Volumes/Masui/Backups/gyazz.com/Gyazz/data"

$id2title = SDBM.open("#{GyazzDir}/id2title",0666)
$data = {}

def find(wiki,attrs)
  pair = SDBM.open("#{GyazzDir}/#{id(wiki)}/pair",0666)
  links = {}
  pair.each { |key,val|
    (key1,key2) = key.split(/\t/)
    links[key1] = {} unless links[key1]
    links[key1][key2] = true
    links[key2] = {} unless links[key2]
    links[key2][key1] = true
  }
  count = 0
  Find.find("#{GyazzDir}/#{id(wiki)}") do |f|
    # puts f

    # return if count > 200
    # count += 1

    title = ""
    # if f =~ /\/([0-9a-f]{32})\/([0-9a-f]{32})\/([0-9]{14})/ then
    if f =~ /\/([0-9a-f]{32})\/([0-9a-f]{32})\/curfile$/ then
      wikiid = $1
      titleid = $2
      date = $3
      wiki = $id2title[wikiid]
      title = $id2title[titleid]
      if wiki != 'test' && title != 'test' then
        if wiki && wiki != '' then
          # puts "#{date} #{wiki}/#{title}"
          pagelinks = {}
          text = File.read(f)
          text = NKF.nkf('-w', text)
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
              next if title.to_s == ''

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
        end
      end
    end
  end
end

find("masui",attrs)
