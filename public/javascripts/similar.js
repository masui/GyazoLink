$(function() {
    for(var i=0;i<40;i++){
	image = $('<img>');
	image.attr('id','sim'+i);
	image.attr('class','sim');
	$('body').append(image);
    }
    
    if(!src) src = '1ae719bf0c4eb8607f1cb9b385dbad92';
    
    $("#query").on("keydown", function(e){
	if(e.keyCode == 13){
	    location.href = "/search?query=" + $(this).val();
	}
    });

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
    });
    
    $.getJSON("/__similar/"+src, function(list){
    	images = list['ids'];
    	show_images(images);
    });
});

function show_images(images){
    $('.sim').remove();
    for(i=0;i<images.length;i++){
	image = $('<img>');
	image.attr('id','sim'+i);
	image.attr('class','sim');
	image.attr('src',"http://gyazo.com/"+images[i]+".png");
	image.attr('gyazoid',images[i]);
	image.css('display',"inline");
	$('body').append(image);
    }
    $("img").on("click", function(){
	location.href = "/similar?id=" + $(this).attr('gyazoid');
    });
}
