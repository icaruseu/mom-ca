
// $(document).ready(function(){
//	 $('#graphics').has('.no-graphic').css( 'display', 'none');
//	 $('#tenor').has('#bibltenor').css( 'display', 'block');
// });


function changeImage(url, num){	
	var alleBilder = document.getElementsByClassName('imageLink');	
	for (var i=0;i<alleBilder.length; i++){
		console.log(alleBilder[i]);
		if(alleBilder[i].text == num ){
			alleBilder[i].setAttribute('id', 'gelb');
		}
		else {
			alleBilder[i].setAttribute('id', 'black');
		}
		
	}	
	document.images["image"].src = url;
	document.getElementById('img-link').setAttribute('href', url);	
  // reload SVG and cancel create- process
  //jQuery(document).imageTool.resetSVGId();
  //jQuery(document).imageTool.loadSVG();
}



function changeGraphic(wit, url)
{
	document.images[wit].src = url;
}



function showHideDiv(id, triangle)
{
	
	if(document.getElementById(id).style.display == "none")
	{
			
		document.getElementById(id).style.display = "block";	
		        
	}
	else
	{	
		document.getElementById(id).style.display = "none";
		
	}
}

function showHideDiv_neu(id, triangle)
{
	console.log('alles klar');
	var xmlid = '#'+ id;
		$(xmlid).toggle( function(){		
		
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
}


function hideDiv(id)
{	
	document.getElementById(id).style.display = "none";
}



function showDiv(id)
{	
	document.getElementById(id).style.display = "block";
}



function assignDiv(hide, show)
{	
	var divs = new Array();
	divs = hide.split(' ');
	for (n = 0; n < divs.length; n++)
	{
		document.getElementsByName(divs[n])[0].style.backgroundColor = "";
		document.getElementsByName(divs[n])[0].style.color = "";
		document.getElementsByName(divs[n])[0].style.borderRight = "";
	}
	document.getElementsByName(show)[0].style.backgroundColor = "rgb(255,255,255);"
		//"rgb(142,163,132)";
	document.getElementsByName(show)[0].style.color = "white";
	document.getElementsByName(show)[0].style.borderRight = "solid rgb(255,151,5) 6px";
}



function showContent(hide, show)
{	
	var divs = new Array();
	divs = hide.split(' ');
	for (n = 0; n < divs.length; n++)
	{
		hideDiv(divs[n]);
	}
	showDiv(show);
	assignDiv(hide, show);
}

/* Prüffunktion, ob kategorie offen oder zu */
/* muss clone nehmen, weil bild nur einmal vorhanden, wills aber öfter einsetzen!!!!!!*/
function proof(){
var bild = $('div#Icons').find('img');

var a = $(bild)[0];
var b = $(bild)[1];	
$(a).css("height", "20px");
$(b).css("height", "20px");
 clonedIcon1 = $(a).clone();
 clonedIcon2 = $(b).clone();
 cloneI1 = $(a).clone();
 cloneI2 = $(b).clone();
 clone1 = $(a).clone();
 clone2 = $(b).clone();
 clon2 = $(b).clone();

var allNone = $("div[style='display:none']").prev('div.cat').children().append(clonedIcon2);
var show = $("div.cat").next(":not(div[style='display:none'])");
var allShown = $(show).prev('div.cat').children().append(clonedIcon1);

if($("div#abstract").children().children().length == 0){	
	$("div.abs").find('img').replaceWith(clon2);
}

if($("div#indexlist").children().length == 0) {	
	$("div.idx").find('img').replaceWith(clone2);
	
}
else {
		
	$("div.idx").find('img').replaceWith(clone1);
}
if($("div.no-graphic").length >= 1) {	
	
	$("div#graphicheader").children().append(cloneI2);
	$("div#graphicheader").nextAll("img").remove();	
}
else 	{	
	$("div#graphicheader").children().append(cloneI1);
	$("div#graphicheader").nextAll("img").remove();
	}


//var arrowatgraphic  = $("div#change-image-links").next();
//$("div#graphicheader").children().append(arrowatgraphic);

}