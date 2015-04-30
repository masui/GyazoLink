#
# ブラウザからのキーワード検索
#

res = []

$ ->
  $("#query").val(query)
  $("#query").on "keydown", (e) ->
    if e.keyCode == 13
      location.href = "/search?query=#{$(this).val()}"

  # Mongoのキーワードサーチ
  # $.getJSON "/__search/#{query}", (list) ->
  #   show_images list['ids']

  # elastic.gyazo.com のElasticSearch利用の場合
  $.ajax
    type: "POST"
    url: "http://elastic.gyazo.com/masui/test/_search"
    dataType: 'json'
    data: 
      JSON.stringify
        "query":
          "match":
            "keywords": query
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
