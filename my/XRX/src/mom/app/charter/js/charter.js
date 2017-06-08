
// $(document).ready(function(){
//	 $('#graphics').has('.no-graphic').css( 'display', 'none');
//	 $('#tenor').has('#bibltenor').css( 'display', 'block');
// });


function changeImage(url, num){
	var alleBilder = document.getElementsByClassName('imageLink');

	for (var i=0;i<alleBilder.length; i++){

		if(alleBilder[i].text == num ){
			alleBilder[i].setAttribute('id', 'gelb');
			
		}
		else {
			alleBilder[i].setAttribute('id', 'black');
		}		
	}
	//image in ansicht mit aktuellem title ausstatten
	document.getElementById('img').setAttribute('title', url);
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

	// bibltenor belongs to tenor and has to be toggled in sync
	if(id=="tenor"){
		$('#bibltenor').toggle();
	}

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
var emptyabstract = $("div#abstract").children("div.p");
/* need to define exceptions because of irregularities in the html structure!!!!!*/
if(($("div#abstract").children().children().length == 0 ) && (emptyabstract.val()== '')){
	console.log('was wird da ausgegeben?');
	console.log($("div#abstract").children().children());
	console.log($("div#abstract").children());
	$("div#abstract").css("display", "none");
	$("div.abs").find('img').replaceWith(clon2);
}
//if(($("div#abstract").children("div"))
console.log("Abstrakt unter der Lupe!");
console.log(emptyabstract.val());
console.log($("div#abstract").children().children().length);

if($("div#indexlist").children().length == 0) {
	$("div.idx").find('img').replaceWith(clone2);
	$("div#index").css("display", "none");

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

}

/*function rapper is uses to show the clicked glossary entry in a viewport on the single charter view. */

function rapper(){		
	
		var infoeintrag = $('li[value="true"]');		
		/* normally all li where value = true (which means that there is more information provided to this index)
		 * has an eception which is the illurk-vocabulary and vis, because until now there is no additional info.
		 * 
		 * */
		$('li[value="true"]:not(.illurk-vocabulary):not(.vis)').each(function(){
	
			var glossartyp= $(this)[0].className;
			
				if ($(this)[0].attributes.lemma == undefined)
					{
					var entry = $(this)[0].attributes.id.value;
					}
				else{
					var entry = $(this)[0].attributes.lemma.value;
				}
				
				var gentry = entry.charAt(0).toUpperCase() + entry.slice(1);				
				var anker = $('<a><a>').addClass('eintrag');
				$(this).append('<span class="info_i">i</span>');
				$(this).wrapInner(anker);				
							
				$(this).click( function(){
					console.log("click event on list");					
					$("div#enhancedView").empty();
										
			        console.log(glossartyp);
			        $.ajax({     
			        	url: "/mom/service/getTextfromGlossar",
			        	type:"GET",      
			        	contentType: "application/xml",     
			        	dataType: "xml",
			        	data: { id : gentry, typ : glossartyp},
			        	success: function(data, textStatus, jqXHR)
			        	{    
			        		if (glossartyp == 'bishop' ){
			        			var note = $(data).find("tei\\:note");
			        			console.log("Note NOte");
			        			console.log(note);
			        			console.log($(data));
			        			var person = $(data).text();			        			
			        			/* Person data is retrieved as text
			        			 * Problem of textformatting: 
				        		 * in order to be able to insert whitespaces again
				        		 * this is done via regex. 
				        		 * Some cases may be not considered! */
			        			var reguliert = person.replace(/([0-9])([A-Z])/g, '$1 $2')
			        									.replace(/([a-z])([A-Z])/g, '$1 $2')
			        									.replace(/([a-z])(\()/g, '$1 $2')
			        									.replace(/(.)([A-Z])/g, '$1 $2')
			        									.replace(/(,)([a-z][A-Z])/g, ', $2')
			        									.replace(/(\))([0-9a-zA-Z])/g, '$1 $2')
			        									.replace(/(\()(\s)/g, '$1')
			        									.replace(/([A-Za-z]*)(,|\s)/, '<h2 class="bishop">$1$2</h2>');			        

			        			var port = $("<div class='port'></div>").append(reguliert);			        			
			        			$("div#enhancedView").append(port);				        			
			        	
			        		}
			        		else {				        		

			        			var preflabel = $(data).find("skos\\:prefLabel");
			        			var h = $("<h3></h3>").append(preflabel);			        			
			        				var def = $(data).find("skos\\:definition");
			        			var div = $("<div class='bla'></div>").append(def);
			        			var port = $("<div class='port'></div>").append(h).append(div);
			        			$("div#enhancedView").append(port);			        			
			        		};
			        		        		
			        		return true;
			        	},     
			        	error: function(){
			        		$("#result").text("Error: Failed to load script.");
			   
			        		return false;
			        	}    
			        });
					
					
					
				});
		
		}
				);
		
	
	}


//function addInfo(){
//	
//	var glossarcat = $("ul.glossary li[class]");
//	
//	
//	for (var i= 0; i < glossarcat.length; i++) {
//	
//		var cat = $(glossarcat[i]);		
//	
//		var glossartyp = cat.context.className;
//	
//		console.log("das ist der glossartyp")
//		console.log(glossartyp);
//		doAnAjax(glossartyp, cat,function(wert, cat){			
//			console.log(wert);
//			var neuewerte = cat.attr("value", wert);			
//			rapper();
//		}		
//				
//		);
//		
//		
//	}
//	
//}
//
//function doAnAjax(glossartyp,cat ,hisBack){
//$.ajax({     
//	url: "/mom/service/getTextfromGlossar",
//	type:"GET",      
//	//contentType: "application/xml",     
//	dataType: "xml",
//	data: { checktype : glossartyp},
//	success: function(data, textStatus, jqXHR)
//	{    	console.log("wann bin ich dran?");
//	
//		return hisBack(data.activeElement.value, cat);
//	},     
//	error: function(){
//		$("#result").text("Error: Failed to load script.");
//
//		return false;
//	}    
//});
//}

//function transport(){
//	var sprachwert = "de";
//	var indexname = "illurk-vocabulary";
//	console.log("wann komme ich zum Einsatz!!!!!!!!!!!!");
//	$('li[lemma]').each( function() {
//		//var entry = $(this)[0].attributes.sublemma.value;
//		var self = $(this);
//		if(self[0].attributes.lemma.value == ""){
//			console.log("no lemma value");
//		}
//		else {
//		console.log(self);
//		var sublemmawert = self[0].attributes.lemma.value;
//		var lemmawert = self[0].attributes.lemma.value;		
//		$.ajax({
//			url:"/mom/service/sublemma",
//			type:"GET",
//			dataType:"xml",
//			data: {lemma : lemmawert, sprache:sprachwert, index:indexname},
//			success: function(data, textStatus, jqXHR)			{
//								
//				if(data.childNodes[0].childNodes[0] == undefined){
//					console.log("hallojjjjjjj");
//						}
//				else {
//					var translation = data.childNodes[0].childNodes[0].data;					
//					self.text(translation);
//					console.log("was passiert da?");
//					console.log(self.text(translation));
//				}
//				
//				return true;
//			},
//			error: function() {
//				console.log("Error. Failed to load script.");
//				return false;
//			}
//			
//		});
//		}
//	});
//	
//}
