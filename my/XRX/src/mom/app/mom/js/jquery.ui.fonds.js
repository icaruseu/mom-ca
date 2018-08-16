function showHideDiv(id, clickedElement){
	
	//console.log(clickedElement);
	
	console.log($(clickedElement).find("img"));

   headlineArrow = $(clickedElement).find("img")


if(headlineArrow.attr('id') == "open"){
   $({deg: 180}).animate({deg: 90}, {
       duration: 400,
       step: function(now) {
           headlineArrow.css({
               transform: 'rotate(' + now + 'deg)'
           });
       },
       complete: function(){
    	   headlineArrow.attr('id', 'closed');
       }
   });
   
   $("#"+id).slideUp("slow");
}
   
else if(headlineArrow.attr('id') == "closed"){
	   $({deg: 90}).animate({deg: 180}, {
	       duration: 400,
	       step: function(now) {
	           headlineArrow.css({
	               transform: 'rotate(' + now + 'deg)'
	           });
	       },
	       complete: function(){
	    	   headlineArrow.attr('id', 'open');
	       }
	   });
	   
	   $("#"+id).slideDown("slow");
}
  
   //$("#"+id).toggle( function(){
		
		/*

		if ($(this)[0].style.display == 'none'){
			var bild = $('div#Icons').find('img');
			var b = $(bild)[1];
			$(b).css("height", "20px");
			var cIcon2 = $(b).clone();
			var img2 = $(cIcon2)[0];
			var icontillnow = $(xmlid).prev("div.cat").find("img#aus");
			$(icontillnow[0]).replaceWith(img2);

		}
		else {
			var bild = $('div#Icons').find('img');
			var a = $(bild)[0];
			$(a).css("height", "20px");
			var cIcon1 = $(a).clone();
			var img1 = $(cIcon1)[0];
			var icontillnow = $(xmlid).prev("div.cat").find("img#ein");
			$(icontillnow[0]).replaceWith(img1);
		}

	} );
	
	*/
}