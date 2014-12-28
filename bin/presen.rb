#! /usr/bin/env ruby
# -*- coding: utf-8 -*-
#
# PresentationデータをGyazoLinkで使うMongoデータに変換
# collectionは "attr"
#
require 'mongo'
require 'find'
require 'nkf'

connection = Mongo::Connection.new

gyazodb = connection.db('gyazo')
STDERR.puts "Gyazo connection established"

attrs = gyazodb.collection('attrs')

def process(title,text,keywords,attrs)
  # STDERR.puts "title=#{title}"
  gyazoids = []
  s = text.dup
  k = keywords.dup
  while s.sub!(/\[\[.*gyazo.*\/([0-9a-f]{32})/i,'') do
    gyazoid = $1
    gyazoids << gyazoid
  end

  # STDERR.puts "keywords = #{k.join('--')}"
  while s.sub!(/\[\[([^\s\[\]]+)\]\]/,'') do
    kw = $1
    next if kw =~ /.(jpg|png|gif)$/
    k << kw
  end

  gyazoids.each { |gyazoid|
    data = attrs.find_one('gyazoid' => gyazoid)
    data = {} unless data
    text.strip!
    text.gsub!(/\t/,' ')
    unless data['text'] then
      data['text'] = [text]
    else
      data['text'] << text unless data['text'].member?(text)
    end
    data['keywords'] = [] unless data['keywords']
    kk = {}
    kk[title] = true
    k.each { |keyword|
      kk[keyword] = true
    }
    data['keywords'].each { |keyword|
      kk[keyword] = true
    }
    data['keywords'] = kk.keys
    data['gyazoid'] = gyazoid
    if data['_id'] then
      attrs.update({'_id' => data['_id']}, data)
    else
      id = attrs.insert(data)
    end
  }
end

Find.find("/Users/masui/Presentations") do |path|
  if path =~ /\/slide.txt$/ then
    STDERR.puts path
    keywords = []
    if path =~ /(\d{8})\-(\w+)\/(\d{8})\-(\w+)\/slide.txt$/ then
      date1 = $1
      cat1 = $2
      date2 = $3
      cat2 = $4
      keywords = [date1, cat1, date2, cat2]
    elsif path =~ /(\d{8})\-(\w+)\/slide.txt$/ then
      date1 = $1
      cat1 = $2
      keywords = [date1, cat1]
    end

    title = ""
    text = ""
    File.open(path) { |f|
      f.each { |line|
        line.chomp!
        line = NKF.nkf('-w', line)
        if line =~ /^\S/ then
          if text != "" then
            process(title,text,keywords,attrs)
          end
          unless line =~ /^[\#\%]/ then
            title = line
            text = ""
          end
        else
          text += "#{line}\n"
        end
      }
    }
    if text != ''
      process(title,text,keywords,attrs)
    end
  end
end
