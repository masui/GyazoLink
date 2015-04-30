src = '1ae719bf0c4eb8607f1cb9b385dbad92' unless src

res = []

$ ->
  $("#query").on "keydown", (e) ->
    if e.keyCode == 13
      location.href = "/search?query=#{$(this).val()}"

  $('#src').attr 'src', "http://gyazo.com/#{src}.png"

  # キーワード表示
  $.getJSON "/__attr/#{src}", (attr) ->
    keywords = attr['keywords']
    $('#comments').children().remove()
    for i in [0...keywords.length]
      keyword = keywords[i]
      if keyword.match /^http/
        entry = $('<a>')
          .text keyword
          .attr 'href', keyword
      else
        entry = $('<span>')
          .text keyword
      $('#comments').append(entry)
      if i < keywords.length - 1
        $('#comments').append $('<span>, </span>')

  # $.getJSON "/__similar/#{src}", (list) ->
  #  show_images list['ids']

  # elastic.gyazo.com のElasticSearch利用の場合
  $.ajax
    type: "POST"
    url: "http://elastic.gyazo.com/masui/test/_search"
    dataType: 'json'
    data: 
      JSON.stringify
        "query":
          "more_like_this":
            "fields": ["text", "keywords"]
            "ids": [ src ]
            "min_term_freq": 1
            "min_doc_freq": 1
            "min_word_len": 2
            "max_query_terms": 3
        "size": 20
    success: (result) ->
      hits = result['hits']['hits']
      for hit in hits
        res.push hit['_source']['image_id']
    #beforeSend: function(xhr) { # 認証うまくいかない
    #  var credentials = $.base64.encode("masui:gyazz");
    #  xhr.setRequestHeader("Authorization", "Basic " + credentials);
    #},
  .done ->
    show_images res
  .fail (xhr, status, error) ->
    alert "Error = #{error}"

show_images = (gyazoids) ->
  $('.sim').remove()
  for gyazoid in gyazoids
    image = $('<img>')
      .attr 'class','sim'
      .attr 'src', "http://gyazo.com/#{gyazoid}.png"
      .css  'display', "inline"
    $('body').append image
  $(".sim").on "click", ->
    m = $(this).attr('src').match /[0-9a-f]{32}/
    location.href = "/similar?id=#{m[0]}"
