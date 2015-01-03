# -*- coding: utf-8 -*-
#
# PresentationデータをGyazoLinkで使うMongoデータに変換
# Mongoのcollectionは "attr"
#
require 'mongo'
require 'find'
require 'nkf'

connection = Mongo::Connection.new

gyazodb = connection.db('gyazo')
STDERR.puts "Gyazo connection established"

attrs = gyazodb.collection('attrs')

def process_page(lines, file_keywords, attrs)
  text = lines.join
  gyazoids = text.scan(/\[\[.*gyazo.*\/([0-9a-f]{32})/).map { |matches|
    matches[0]
  }
  if gyazoids.length > 0
    keywords = text.scan(/\[\[([^\s\[\]]+)\]\]/).find_all { |matches|
      matches[0] !~ /gyazo.*[0-9a-f]{32}/i
    }.map { |matches|
      matches[0]
    } + file_keywords
    #
    # Mongo出力
    #
    gyazoids.each { |gyazoid|
      data = attrs.find_one('gyazoid' => gyazoid).to_h
      data['text'] = data['text'].to_a + lines
      data['keywords'] = data['keywords'].to_a + lines + keywords
      data['gyazoid'] = gyazoid
      if data['_id'] then
        attrs.update({'_id' => data['_id']}, data)
      else
        id = attrs.insert(data)
      end
    }
  end
end

#
# ページごとに分割
#
def process_slide_text(path, keywords, attrs)
  lines = NKF.nkf('-w', File.read(path)).split(/\n/).find_all { |line|
    line !~ /^[%#]/ && line !~ /^\s*$/
  }
  pages = []
  pagenum = nil
  lines.each { |line|
    if line =~ /^\S/ then
      pagenum = (pagenum ? pagenum+1 : 0)
      pages[pagenum] = [line.strip]
      true
    else
      pages[pagenum].push(line.strip)
      false
    end
  }
  pages.each { |page|
    process_page(page, keywords, attrs)
  }
end

Find.find("/Users/masui/Presentations") do |path|
  if path =~ /\/slide.txt$/ then
    STDERR.puts path
    keywords = []
    if path =~ /(\d{8})\-(\w+)\/(\d{8})\-(\w+)\/slide.txt$/ then
      keywords = [$1, $2, $3, $4]
    elsif path =~ /(\d{8})\-(\w+)\/slide.txt$/ then
      keywords = [$1, $2]
    end
    process_slide_text(path, keywords, attrs)
  end
end
