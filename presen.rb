# -*- coding: utf-8 -*-
# -*- ruby -*-

require 'find'
require 'nkf'

Find.find("/Users/masui/Presentations") do |f|
  title = ""
  f =~ /\/([^\/]+)\/([^\/]+)$/
  file = $1
  if f =~ /\/slide.txt$/
    File.open(f){ |f|
      f.each { |line|
        line.chomp!
        line = NKF.nkf('-w', line)
        if line =~ /^\S/ then
          unless line =~ /^[\#\%]/ then
            title = line
          end
        end
        while line.sub!(/\[\[.*gyazo.*\/([0-9a-f]{32})/i,'') do
          id = $1
          # puts "#{id} #{file}"
          puts "#{id} #{title}"
        end
      }
    }
  end
end


