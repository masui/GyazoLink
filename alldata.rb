require 'json'

presendata = JSON.parse(File.read("presen.json"))
gyazzdata = JSON.parse(File.read("gyazz.json"))
mongodata = JSON.parse(File.read("mongo.json"))

data = {}

presendata.each { |id,item|
  data[id] = {} unless data[id]
  data[id]['keywords'] = item['keywords']
  data[id]['text'] = item['text']
}

gyazzdata.each { |id,item|
  unless data[id]
    data[id] = {}
    data[id]['keywords'] = []
    data[id]['text'] = []
  end
  data[id]['keywords'] |= item['keywords']
  data[id]['text'] |= item['text']
}

mongodata.each { |id,item|
  unless data[id]
    data[id] = {}
    data[id]['keywords'] = []
    data[id]['text'] = []
  end
  data[id]['keywords'] |= item['keywords']
  data[id]['text'] |= item['text']
}

puts data.to_json


