src = '1ae719bf0c4eb8607f1cb9b385dbad92' unless src

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

  $.getJSON "/__similar/#{src}", (list) ->
    show_images list['ids']

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
