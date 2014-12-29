var sim = {};
var data = {};
var ids = [];
var tfidf = {};

$(function() {
    s = $('<span>検索: </span>');
    s.css('color','#ffffff');
    $('body').append(s);
    
    query = $('<input>');
    query.attr('type','text');
    query.css('width','90%');
    query.attr('id','query');
    $('body').append(query);
    $('body').append($('<br clear="all">'));
    
    topimage = $('<img>');
    topimage.attr('height','160pt');
    topimage.attr('id','src');
    topimage.attr('class','top');
    topimage.css('float','left');
    topimage.css('margin','6pt');
    $('body').append(topimage);
    
    div = $('<div>');
    div.attr('height','160pt');
    div.attr('id','comments');
    div.css('margin','6pt');
    div.css('overflow','hidden');
    div.css('float','left');
    div.css('color','#ffffff');
    $('body').append(div);
    
    $('body').append($('<br clear="all">'));
    //hr = $('<hr>');
    //hr.css('height','4pt');
    //hr.css('color','#ffffff');
    //hr.css('background-color','#ffffff');
    //$('body').append(hr);
    
    for(var i=0;i<40;i++){
	image = $('<img>');
	image.attr('id','sim'+i);
	image.attr('class','sim');
	$('body').append(image);
    }
    
    if(!src) src = '1ae719bf0c4eb8607f1cb9b385dbad92';
    display();
    
    $("img").on("click", function(){
	src = $(this).attr('gyazoid');
	display();
    });
    
    $("#query").on("keydown", function(e){
	if(e.keyCode == 13){
	    search($('#query').val());
	}
    });
});

function search(query){
    $('#comments').css('display','none');
    $('#src').css('display','none');
    
    $.getJSON("/__search/"+query, function(list){
	showimages(list['ids']);
    });
}

function display(){
    $('#comments').css('display','block');
    $('#src').css('display','block');
    $('#src').attr('src',"http://gyazo.com/"+src+".png");
    // キーワード表示
    $.getJSON("/__attr/"+src, function(attr){
	keywords = attr['keywords'];
	$('#comments').children().remove();
	for(i=0;i<keywords.length;i++){
	    keyword = keywords[i]
	    if(keyword.match(/^http/)){
		entry = $('<a>');
		entry.text(keyword);
		entry.attr('href',keyword);
	    }
	    else {
		entry = $('<span>');
		entry.text(keyword);
	    }
	    $('#comments').append(entry);
	    if(i < keywords.length-1){
		$('#comments').append($('<span>, </span>'));
	    }
	}
	//$('#comments').text(data[src]['keywords'].join(", "));
	//$('#comments').text(attr['keywords'].join(", "));
    });
    
    $.getJSON("/__similar/"+src, function(list){
	images = list['ids'];
	showimages(images);
    });
}

function showimages(images){
    $('.sim').remove();
    for(i=0;i<images.length;i++){
	image = $('<img>');
	image.attr('id','sim'+i);
	image.attr('class','sim');
	image.attr('src',"http://gyazo.com/"+images[i]+".png");
	image.attr('gyazoid',images[i]);
	// image.attr('title',data[images[i]]['keywords'].join(", "));
	image.css('display',"inline");
	$('body').append(image);
    }
    $("img").on("click", function(){
	src = $(this).attr('gyazoid');
	display();
    });
}
