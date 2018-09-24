
 $(document).ready(function(){
	 //informs user if the IIF-Server ist not available	
    var nographic = "Sorry, service temporarily unavailable";    
    $("img.thumbs").error(function(){    
    	$(this).parents("#imagebox").hide();
    
        var ausgabe = $(this).parents(".images");        	
        	$(ausgabe).append('<span>' + nographic + '</span>');        
   
    }); 
    //extracted from edit-charter.widget in order to be loaded at the right time
    $( "#zoomslider" ).slider({ 
        value:100, 
        min: 100, 
        max: 500, 
        step: 10, 
        slide: function( event, ui ) { 
          $( "#img" ).css( "width", ui.value + "%" ); 
        } 
      }); 
    
    
});

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

/* ********
 *  * function addinfo gives additional info to index terms in the single charter view. Till now there are 2 collections, 
 *  where controlled vocabularies can be saved and retrieved in the data base:
 *  metadata.person.public and metadata.controlledVocabularies.public.
 *  In metadata.controlledVocabularies.public files are in skos and in different languages.
 *  The files in metadata.person.public are TEIs. Until now there are 2 kinds of structures: a low structured
 *  one containing a unique key, a persName, occupation of the person and maybe a comment on the person.
 *  The other one BischoefeAblaesse is deeper nested,that is why there is a special handling (1.if-clause) for that case.  
 *  The additional information is retrieved from the service "getTextfromGlossar" via ajax. 
 *  The data from the service is prepared and integrated in the single charter view.
 *  The function is called in charter and my-charter.widget.
 *   */

function addInfo(){		
		
		var findlang = $("select[name='_lang']").children("option[selected='selected']");

		/* lang in voc has 2 chars not 3*/	
		console.log($(findlang));
		var lang = $(findlang)[0].value.substring(0,2) || 'eng';	

		
		/* normally all li where value = true (which means that there is more information provided to this index)
		 * has an eception which is the vis, because until now there is no additional info.
		 * 
		 * */
		$('li[value="true"]:not(.vis)').each(function(){
			var self = this,
			vocabulary = self.className,
			term = self.attributes.lemma || self.attributes.id;
			
			var begriff = term.value; 
			
			var category = (self.attributes.lemma == undefined)? 'person': 'item';		
							
				var anker = $('<a><a>').addClass('eintrag');
				$(this).append('<span class="info_i">i</span>');
				$(this).wrapInner(anker);				
							
				$(this).click( function(){					
					
					$("div#enhancedView").empty();			
			        $.ajax({     
			        	url: "/mom/service/getTextfromGlossar",
			        	type:"GET",      
			        	contentType: "application/xml",     
			        	dataType: "xml",
			        	data: { id : begriff, typ : vocabulary, cat: category},
			        	success: function(data, textStatus, jqXHR)
			        	{    
			        		
			        		if (vocabulary == 'BischoefeAblaesse' ){
			        			var note = $(data).find("tei\\:note");
			        			
			        			var person = $(data).text();			        			
			        			/* Person data of BischoefeAblaesse is retrieved as text
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
			        		else if((category == 'person') && (vocabulary != 'BischoefeAblaesse')){
			        			/* the person data is retrieved from TEI-files in metadata.person.public.
			        			 * These person lists are low structured: persName, occupation, maybe note. */
			        			var name = $(data).find("tei\\:persName").text();
			        			var h = $("<h3></h3>").append(name);			        			
			        			//var more = $(data).children("div.port").children().not(name)
			        			var occupation = $(data).find("tei\\:occupation").text();
			        			var p = $("<p></p>").append(occupation);
			        			var note = $("<p></p>").append($(data).find("tei\\:note").text());
			        		
			        			var port = $("<div class='port'></div>").append(h).append(p).append(note);
			        			$("div#enhancedView").append(port);			        			
			        		}
			        		else {	
			        			var preflabel = $(data).find("skos\\:prefLabel[xml\\:lang='" + lang +"']");			        			
			        			var h = $("<h3></h3>").append(preflabel);			        			
			        			var def = $(data).find("skos\\:definition");
			        			var div = $("<div></div>").append(def);
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

