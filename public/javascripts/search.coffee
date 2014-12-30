$ ->
  $("#query").val(query)
  $("#query").on "keydown", (e) ->
    if e.keyCode == 13
      location.href = "/search?query=#{$(this).val()}"

  $.getJSON "/__search/#{query}", (list) ->
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
