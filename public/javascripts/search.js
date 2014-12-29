$(function() {
    $("#query").val(query);
    $("#query").on("keydown", function(e){
	if(e.keyCode == 13){
	    location.href = "/search?query=" + $(this).val();
	}
    });
    $.getJSON("/__search/"+query, function(list){
	show_images(list['ids']);
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
	// image.attr('title',data[images[i]]['keywords'].join(", "));
	image.css('display',"inline");
	$('body').append(image);
    }
    $("img").on("click", function(){
	location.href = "/similar?id=" + $(this).attr('gyazoid');
    });
}
