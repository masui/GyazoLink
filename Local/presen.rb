# -*- coding: utf-8 -*-
# -*- ruby -*-

require 'find'
require 'nkf'
require 'json'

data = {}

def process(title,text,keywords,data)
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
    data[gyazoid] = {} unless data[gyazoid]
    text.strip!
    text.gsub!(/\t/,' ')
    unless data[gyazoid]['text'] then
      data[gyazoid]['text'] = [text]
    else
      data[gyazoid]['text'] << text unless data[gyazoid]['text'].member?(text)
    end
    data[gyazoid]['keywords'] = [] unless data[gyazoid]['keywords']
    kk = {}
    kk[title] = true
    k.each { |keyword|
      kk[keyword] = true
    }
    data[gyazoid]['keywords'].each { |keyword|
      kk[keyword] = true
    }
    data[gyazoid]['keywords'] = kk.keys
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
            process(title,text,keywords,data)
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
      process(title,text,keywords,data)
    end
  end
end

puts data.to_json
