require 'json'

data = {}
entry = {}
id = ''
keywords = []
File.open("custom.txt"){ |f|
  f.each { |line|
    line.chomp!
    next if line =~ /^\s*$/
    if line =~ /^\S/ then
      if keywords.length > 0 then
        entry = {}
        entry['keywords'] = keywords
        data[id] = entry
      end
      id = line
      keywords = []
    else
      line.strip!
      keywords << line
    end
  }
  if keywords.length > 0 then
    entry = {}
    entry['keywords'] = keywords
    data[id] = entry
  end
}

puts data.to_json

    
  
