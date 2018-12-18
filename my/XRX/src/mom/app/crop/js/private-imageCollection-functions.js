var editorContext = "cropped-img", error = 0, saveoption = "new", interval, IEparser = false, singleID, noname = 1, projectname, mouseAbsX, mouseAbsY, downTimer, undo = false, undoPoint = 1;

// *!* ################ helper- functions ################ *!*
// slider functions
function loadDoc(platformid){
				projectname = platformid;
		    $("#slider-contrast").slider({
		      slide: function(e, ui) {
		      $("#value-contrast").val( ((ui.value / 100 * 4)-1).toFixed(1));
		      }, value : 25
		    });
		    
		    $("#slider-brightness").slider({
			value : 50,
			slide: function(e, ui) {
				$("#value-brightness").val(Math.round(ui.value / 100 * 300) - 150);
			}
	       });
	       
	       $("#slider-radius").slider({
	          range: "min",
	          max: 100,
	          min: 0,
		      slide: function(e, ui) {
		      $("#value-radius").val((ui.value / 100).toFixed(2));
		      }, value : 20
		    });
		    
		    $("#slider-grey").slider({
	          range: "min",
	          max: 255,
	          min: 0,
		      slide: function(e, ui) {
		      $("#value-grey").val(ui.value);
		      }, value : 179
		    });
		    
		    $("#slider-strength").slider({
	          range: "min",
	          max: 100,
	          min: 0,
		      slide: function(e, ui) {
		      $("#value-strength").val(((ui.value)/ 100 * 10).toFixed(1));
		      }, value : 10
		    });
		    
		    $("#slider-amount").slider({
	          range: "min",
	          max: 100,
	          min: 0,
		      slide: function(e, ui) {
		      $("#value-amount").val((ui.value / 100).toFixed(2));
		      }, value : 30
		    });
	       
	       $("#slider-red").slider({
	          range: "min",
	          max: 100,
	          min: 0,
		      slide: function(e, ui) {
		      $("#value-red").val(((ui.value / 100 * 2)-1).toFixed(2));
		      }, value : 50
		    });
		    
		    
		    $("#slider-green").slider({
		      range: "min",
	          max: 100,
	          min: 0,
			  slide: function(e, ui) {
				$("#value-green").val(((ui.value / 100 * 2)-1).toFixed(2));
			}, value : 50
	       });
	       
	       $("#slider-blue").slider({
	          range: "min",
	          max: 100,
	          min: 0,
			  slide: function(e, ui) {
				$("#value-blue").val(((ui.value / 100 * 2)-1).toFixed(2));
			}, value : 50
	       });
	       
	       $("#slider-rotate").slider({
	          stepping: 1,
	          range: false,
	          max: 360,
	          min: 0,
	          value : 0,
			  slide: function(e, ui) {
				 var index = document.getElementById("imagelist").selectedIndex;
                 var id = document.getElementById("imagelist").options[index].text;
                 if (id == "")
                    {
                    alert('Please select an image in the drop-down list to adjust the changes!');
                    }
                 else
                    {
                    img = "#"+id;
                    var value = ui.value;
                    IEstring = "progid:DXImageTransform.Microsoft.BasicImage(rotation="+value+")";
                    string = "rotate("+value+"deg)";
                    $(img).css('-moz-transform', string);
                    $(img).css('-webkit-transform', string);
                    $(img).css('-o-transform', string);
                    $(img).css('msTransform', string);
                    }
        jQuery( ".editorimg" ).draggable();
			}
	       });
	       
	        $("#slider-transparent").slider({
			slide: function(e, ui) {
			     var index = document.getElementById("translist").selectedIndex;
                 var id = document.getElementById("translist").options[index].text;
                 if (id == "")
                    {
                    alert('Please select an image in the drop-down list to adjust the changes!');
                    }
                 else
                    {
                    imgID = "#"+id;
                    IEopacity = Math.round(ui.value);
                    opacity = Math.round(ui.value)/100;
                    string = "alpha(opacity="+IEopacity+");";
                    $(imgID).css('filter', string);
                    $(imgID).css('opacity', opacity);
                    }
			}, value : 100, min: 0, max: 100
		  });
};

// get the i18n messages
function geti18nText(lang, key){
    var breadcrump;
    // send request to service
    var xmlhttp;
    if (window.XMLHttpRequest)
            {// code for IE7+, Firefox, Chrome, Opera, Safari
                xmlhttp=new XMLHttpRequest();
            }
    else
            {// code for IE6, IE5
                xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
            }
    xmlhttp.open("GET","service/get-i18n-text?key="+key+"&amp;lang="+lang,false);
    xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
    xmlhttp.onreadystatechange=function(){
    if (xmlhttp.readyState==4)
          {
           if (xmlhttp.status==200)
                 {
                 error = 0;
                 breadcrump = xmlhttp.responseText;
                 }
             else
                 {
                 error++;
                 if(error < 20)
                   geti18nText(lang, key);
                 else
                   {
                   $('#loadgif').css('display', 'none');
                   document.getElementById("loadtext").innerHTML= "Error! Please try again!";
                   error = 0;
                   }
                 }
            }
       };
     xmlhttp.send();
     // return text of i18n message
     return breadcrump;
};

// change the image in the compare viewport
function changeViewport(side, changeType, user, lang){
        var id;
        var name;
        var type;
        // select the side and define the parameters
        if(side == "left")
            {
             id = $('#leftImg').attr("alt");
             name = $('#namelistleft').val();
             type  =  $('#typelistleft').val();              
            }
        else 
            {
             id = $('#rightImg').attr("alt");
             name = $('#namelistright').val(); 
             type  =  $('#typelistright').val();             
            }
        // send request to compare script
        var xmlhttp;
        if (window.XMLHttpRequest)
            {// code for IE7+, Firefox, Chrome, Opera, Safari
                xmlhttp=new XMLHttpRequest();
            }
        else
            {// code for IE6, IE5
                xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
            }
        xmlhttp.open("GET","service/compare?type=change&amp;id="+id+"&amp;name="+name+"&amp;type="+type+"&amp;user="+user+"&amp;side="+side+"&amp;changeType="+changeType, true);
        xmlhttp.onreadystatechange=function(){
        if (xmlhttp.readyState==4)
            {
             if (xmlhttp.status==200)
                 { 
                    var xmlDoc = jQuery.parseXML(xmlhttp.response);
                    var breadcrump = document.createElement("div");
             		 		breadcrump.innerHTML = xmlhttp.responseText;
                    // select the right side
                    if(side == "left")
                      {
                      // load the image into the viewport
                      if(document.getElementById("leftImg")!=null)
                            {
                            old = document.getElementById("leftImg");
                            old.parentNode.removeChild(old);
                            }
                      document.getElementById("viewportleft").appendChild(breadcrump.childNodes[0].childNodes[0]);
                      if (!xmlDoc.getElementsByTagName('imagename')[0].hasChildNodes())
                        {
                        document.getElementById("ImgNameLeft").innerHTML = "No name "+noname;
                        noname++;
                        if(xmlDoc.getElementsByTagName('imagenote')[0].hasChildNodes())
                        	document.getElementById("ImgNoteLeft").innerHTML = xmlDoc.getElementsByTagName('imagenote')[0].childNodes[0].nodeValue;
                        else 
                        	document.getElementById("ImgNoteLeft").innerHTML = "";
                        }
                      else
                        {
                        document.getElementById("ImgNameLeft").innerHTML = xmlDoc.getElementsByTagName('imagename')[0].childNodes[0].nodeValue;
                        document.getElementById("ImgNoteLeft").innerHTML = xmlDoc.getElementsByTagName('imagenote')[0].childNodes[0].nodeValue;
                        }
                      }
                    else
                      {
                      // load the image into the viewport
                      if(document.getElementById("rightImg")!=null)
                            {
                            old = document.getElementById("rightImg");
                            old.parentNode.removeChild(old);
                            }
                      document.getElementById("viewportright").appendChild(breadcrump.childNodes[0].childNodes[0]);
                      if (!xmlDoc.getElementsByTagName('imagename')[0].hasChildNodes())
                        {
                        document.getElementById("ImgNameRight").innerHTML = "No name "+noname;
                        noname++;
                        if(xmlDoc.getElementsByTagName('imagenote')[0].hasChildNodes())
                        	document.getElementById("ImgNoteRight").innerHTML = xmlDoc.getElementsByTagName('imagenote')[0].childNodes[0].nodeValue;
                        else
                        	document.getElementById("ImgNoteRight").innerHTML = "";
                        }
                      else
                        {
                        document.getElementById("ImgNameRight").innerHTML = xmlDoc.getElementsByTagName('imagename')[0].childNodes[0].nodeValue;
                        document.getElementById("ImgNoteRight").innerHTML = xmlDoc.getElementsByTagName('imagenote')[0].childNodes[0].nodeValue;
                        }
                      } 
                    error = 0;
                 }
             else
                 {
                    error++;
                    if(error < 20)
                        changeViewport(side, changeType, user, lang);
                    else
                        {
                        document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                        error = 0;
                        }
                }
           }
       };
        xmlhttp.send();
    }

// change the image in the compare viewport
function changeCollectionViewport(side, changeType){
        var collection, nxtNum;
        // select the side and define the parameters
        if(side == "left")
            {
             nxtNum = $('#collection-leftImg').attr("alt");
             collection = $('#collection-left').val();             
            }
        else 
            {
             nxtNum = $('#collection-rightImg').attr("alt");
             collection = $('#collection-right').val();             
            }
        // send request to compare script
        var xmlhttp;
        if (window.XMLHttpRequest)
            {// code for IE7+, Firefox, Chrome, Opera, Safari
                xmlhttp=new XMLHttpRequest();
            }
        else
            {// code for IE6, IE5
                xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
            }
        xmlhttp.open("GET","service/get-anno-image?type=changeImage&scope=private&collection="+collection+"&side="+side+"&changeType="+changeType+"&nxtNum="+nxtNum, true);
        xmlhttp.onreadystatechange=function(){
        if (xmlhttp.readyState==4)
            {
             if (xmlhttp.status==200)
                 { 
                    var xmlDoc = jQuery.parseXML(xmlhttp.response);
                    var breadcrump = document.createElement("div");
             		 		breadcrump.innerHTML = xmlhttp.responseText;
                    // select the right side
                    if(side == "left")
                      {
                      // show the image
                      if(document.getElementById("collection-leftImg")!=null)
                            {
                            old = document.getElementById("collection-leftImg");
                            old.parentNode.removeChild(old);
                            }
                      document.getElementById("collection-viewport-left").appendChild(breadcrump.childNodes[0].childNodes[0]);
                      document.getElementById("annoIdLeft").innerHTML = xmlDoc.getElementsByTagName('annoId')[0].childNodes[0].nodeValue;
                      if(xmlDoc.getElementsByTagName('relationStatus')[0].childNodes[0].nodeValue == "ok"){
                        var searchedTag = xmlDoc.getElementsByTagName('related')[0].childNodes[0].nodeValue
                        var optimizedKey = searchedTag.replace(":", "_");
                        document.getElementById("relateLeft").innerHTML = jQuery(document).i18nText.get(optimizedKey);
                        if (xmlDoc.getElementsByTagName('content')[0].childNodes[0] != undefined)
                          document.getElementById("contentLeft").innerHTML = xmlDoc.getElementsByTagName('content')[0].childNodes[0].nodeValue;
                        if (xmlDoc.getElementsByTagName('desc')[0].childNodes[0] != undefined)
                          document.getElementById("descLeft").innerHTML = xmlDoc.getElementsByTagName('desc')[0].childNodes[0].nodeValue;
                      }
                      else{
                        document.getElementById("relateLeft").innerHTML = jQuery(document).i18nText.get("broken-anno");
                      }
                      }
                    else
                      {
                      // show the image
                      if(document.getElementById("collection-rightImg")!=null)
                            {
                            old = document.getElementById("collection-rightImg");
                            old.parentNode.removeChild(old);
                            }
                      document.getElementById("collection-viewport-right").appendChild(breadcrump.childNodes[0].childNodes[0]);
                      document.getElementById("annoIdRight").innerHTML = xmlDoc.getElementsByTagName('annoId')[0].childNodes[0].nodeValue;
                      if(xmlDoc.getElementsByTagName('relationStatus')[0].childNodes[0].nodeValue == "ok"){
                        var searchedTag = xmlDoc.getElementsByTagName('related')[0].childNodes[0].nodeValue
                        var optimizedKey = searchedTag.replace(":", "_");
                        document.getElementById("relateRight").innerHTML = jQuery(document).i18nText.get(optimizedKey);
                        if (xmlDoc.getElementsByTagName('content')[0].childNodes[0] != undefined)
                          document.getElementById("contentRight").innerHTML = xmlDoc.getElementsByTagName('content')[0].childNodes[0].nodeValue;
                        if (xmlDoc.getElementsByTagName('desc')[0].childNodes[0] != undefined)
                          document.getElementById("descRight").innerHTML = xmlDoc.getElementsByTagName('desc')[0].childNodes[0].nodeValue;
                      }
                      else{
                        document.getElementById("relateRight").innerHTML = jQuery(document).i18nText.get("broken-anno");
                      }
                      } 
                    error = 0;
                 }
             else
                 {
                    error++;
                    if(error < 20)
                        changeCollectionViewport(side, changeType);
                    else
                        {
                        document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                        error = 0;
                        }
                }
           }
       };
        xmlhttp.send();
    }

 // show an image in the compare viewport
function collectionlist(collection, side){
        // send a request to the compare script
        var xmlhttp;
        if (window.XMLHttpRequest)
            {// code for IE7+, Firefox, Chrome, Opera, Safari
                xmlhttp=new XMLHttpRequest();
            }
        else
            {// code for IE6, IE517
                xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
            }
        xmlhttp.open("GET","service/get-anno-image?type=init&scope=private&collection="+collection+"&side="+side, true);
        xmlhttp.onreadystatechange=function(){
        if (xmlhttp.readyState==4)
            {
             if (xmlhttp.status==200)
                 { 
                 // show the viewport
                 $('.hiddenButton').css('display', 'block');
                 $('.arrowleft').css('display', 'block');
                 $('.arrowright').css('display', 'block');
                 $('.innerviewport').css('display', 'table-cell');
                 $('.outerviewport').css('display', 'block');
                 var xmlDoc = xmlhttp.responseXML;
                 var breadcrump = document.createElement("div");
             		 breadcrump.innerHTML = xmlhttp.responseText;
                    // select the right side
                    if(side == "left")
                      {
                      // show the image
                      if(document.getElementById("collection-leftImg")!=null)
                            {
                            old = document.getElementById("collection-leftImg");
                            old.parentNode.removeChild(old);
                            }
                      document.getElementById("collection-viewport-left").appendChild(breadcrump.childNodes[0].childNodes[0]);
                      document.getElementById("annoIdLeft").innerHTML = xmlDoc.getElementsByTagName('annoId')[0].childNodes[0].nodeValue;
                      if(xmlDoc.getElementsByTagName('relationStatus')[0].childNodes[0].nodeValue == "ok"){
                        var searchedTag = xmlDoc.getElementsByTagName('related')[0].childNodes[0].nodeValue
                        var optimizedKey = searchedTag.replace(":", "_");
                        document.getElementById("relateLeft").innerHTML = jQuery(document).i18nText.get(optimizedKey);
                        if (xmlDoc.getElementsByTagName('content')[0].childNodes[0] != undefined)
                          document.getElementById("contentLeft").innerHTML = xmlDoc.getElementsByTagName('content')[0].childNodes[0].nodeValue;
                        if (xmlDoc.getElementsByTagName('desc')[0].childNodes[0] != undefined)
                          document.getElementById("descLeft").innerHTML = xmlDoc.getElementsByTagName('desc')[0].childNodes[0].nodeValue;
                      }
                      else{
                        document.getElementById("relateLeft").innerHTML = jQuery(document).i18nText.get("broken-anno");
                        document.getElementById("contentLeft").innerHTML = "none";
                        document.getElementById("descLeft").innerHTML = "none";
                      }

                      $('#collection-viewleft').css('display', 'block');
                      $('#collection-zoomer-left').css('display', 'block');
                      // show help 
                      $('#helpCollectionLeft').css('display', 'none'); 
                      $('#helpCollectionRight').css('display', 'block'); 
                      $('#helpCompareCollection').css('display', 'none');
                      $('#editor').css('display', 'block');
                      }
                    else
                      {
                      // show the image
                      if(document.getElementById("collection-rightImg")!=null)
                            {
                            old = document.getElementById("collection-rightImg");
                            old.parentNode.removeChild(old);
                            }
                      document.getElementById("collection-viewport-right").appendChild(breadcrump.childNodes[0].childNodes[0]);
                      document.getElementById("annoIdRight").innerHTML = xmlDoc.getElementsByTagName('annoId')[0].childNodes[0].nodeValue;
                      if(xmlDoc.getElementsByTagName('relationStatus')[0].childNodes[0].nodeValue == "ok"){
                        var searchedTag = xmlDoc.getElementsByTagName('related')[0].childNodes[0].nodeValue
                        var optimizedKey = searchedTag.replace(":", "_");
                        document.getElementById("relateRight").innerHTML = jQuery(document).i18nText.get(optimizedKey);
                        if (xmlDoc.getElementsByTagName('content')[0].childNodes[0] != undefined)
                          document.getElementById("contentRight").innerHTML = xmlDoc.getElementsByTagName('content')[0].childNodes[0].nodeValue;
                        if (xmlDoc.getElementsByTagName('desc')[0].childNodes[0] != undefined)
                          document.getElementById("descRight").innerHTML = xmlDoc.getElementsByTagName('desc')[0].childNodes[0].nodeValue;
                      }
                      else{
                        document.getElementById("relateRight").innerHTML = jQuery(document).i18nText.get("broken-anno");
                        document.getElementById("contentLeft").innerHTML = "none";
                        document.getElementById("descLeft").innerHTML = "none";
                      }


                      $('#collection-viewright').css('display', 'block');
                      $('#collection-zoomer-right').css('display', 'block');
                      // show help 
                      $('#helpCollectionLeft').css('display', 'none'); 
                      $('#helpCollectionRight').css('display', 'none');
                      $('#helpCompareCollection').css('display', 'block');
                      $('#editor').css('display', 'block');
                      } 
                     error = 0;
                 }
             else
                 {
                    error++;
                    if(error < 20)
                        collectionlist(collection, side);
                    else
                        {
                        document.getElementById("loadtext").innerHTML="Error! Please try again!";
                        error = 0;
                        }                      
                 }
            }
       };
        xmlhttp.send();
    }

 // show an image in the compare viewport
function showImage(side, user){
        var name;
        var type;
        // select the side and define the parameters
        if(side == "left")
            {
             name = $('#namelistleft').val();
             type  =  $('#typelistleft').val();            
            }
        else 
            {
             name = $('#namelistright').val(); 
             type  =  $('#typelistright').val(); 
            }
        // send a request to the compare script
        var xmlhttp;
        if (window.XMLHttpRequest)
            {// code for IE7+, Firefox, Chrome, Opera, Safari
                xmlhttp=new XMLHttpRequest();
            }
        else
            {// code for IE6, IE517
                xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
            }
        xmlhttp.open("GET","service/compare?type=view&amp;name="+name+"&amp;type="+type+"&amp;user="+user+"&amp;side="+side, true);
        xmlhttp.onreadystatechange=function(){
        if (xmlhttp.readyState==4)
            {
             if (xmlhttp.status==200)
                 { 
                 // show the viewport
                 $('.hiddenButton').css('display', 'block');
                 $('.arrowleft').css('display', 'block');
                 $('.arrowright').css('display', 'block');
                 $('.innerviewport').css('display', 'table-cell');
                 $('.outerviewport').css('display', 'block');
                 var xmlDoc = jQuery.parseXML(xmlhttp.response);
                 var breadcrump = document.createElement("div");
             		 breadcrump.innerHTML = xmlhttp.responseText;
                    // select the right side
                    if(side == "left")
                      {
                      // show the image
                      if(document.getElementById("leftImg")!=null)
                            {
                            old = document.getElementById("leftImg");
                            old.parentNode.removeChild(old);
                            }
                      document.getElementById("viewportleft").appendChild(breadcrump.childNodes[0].childNodes[0]);
                      if (!xmlDoc.getElementsByTagName('imagename')[0].hasChildNodes())
                        {
                        document.getElementById("ImgNameLeft").innerHTML = "No name "+noname;
                        noname++;
                        if(xmlDoc.getElementsByTagName('imagenote')[0].hasChildNodes())
                        	document.getElementById("ImgNoteLeft").innerHTML = xmlDoc.getElementsByTagName('imagenote')[0].childNodes[0].nodeValue;
                        else 
                        	document.getElementById("ImgNoteLeft").innerHTML = "";
                        }
                      else
                        {
                        document.getElementById("ImgNameLeft").innerHTML = xmlDoc.getElementsByTagName('imagename')[0].childNodes[0].nodeValue;
                        if(xmlDoc.getElementsByTagName('imagenote')[0].hasChildNodes())
                        	document.getElementById("ImgNoteLeft").innerHTML = xmlDoc.getElementsByTagName('imagenote')[0].childNodes[0].nodeValue;
                        else 
                        	document.getElementById("ImgNoteLeft").innerHTML = "";
                        }
                      $('#viewleft').css('display', 'block');
                      $('#zoomerleft').css('display', 'block');
                      // show help 
                      $('#helpAutorLeft').css('display', 'none'); 
                      $('#helpAnnoLeft').css('display', 'none');
                      $('#helpAutorRight').css('display', 'block'); 
                      $('#helpAnnoRight').css('display', 'none');
                      $('#helpCompare').css('display', 'none');
                      $('#editor').css('display', 'block');
                      }
                    else
                      {
                      // show the image
                      if(document.getElementById("rightImg")!=null)
                            {
                            old = document.getElementById("rightImg");
                            old.parentNode.removeChild(old);
                            }
                      document.getElementById("viewportright").appendChild(breadcrump.childNodes[0].childNodes[0]);
                      if (!xmlDoc.getElementsByTagName('imagename')[0].hasChildNodes())
                        {
                        document.getElementById("ImgNameRight").innerHTML = "No name "+noname;
                        noname++;
                        if(xmlDoc.getElementsByTagName('imagenote')[0].hasChildNodes())
                        	document.getElementById("ImgNoteRight").innerHTML = xmlDoc.getElementsByTagName('imagenote')[0].childNodes[0].nodeValue;
                        else
                        	document.getElementById("ImgNoteRight").innerHTML = "";
                        }
                      else
                        {
                        document.getElementById("ImgNameRight").innerHTML = xmlDoc.getElementsByTagName('imagename')[0].childNodes[0].nodeValue;
                        if(xmlDoc.getElementsByTagName('imagenote')[0].hasChildNodes())
                        	document.getElementById("ImgNoteRight").innerHTML = xmlDoc.getElementsByTagName('imagenote')[0].childNodes[0].nodeValue;
                        else
                        	document.getElementById("ImgNoteRight").innerHTML = "";
                        }
                      $('#viewright').css('display', 'block');
                      $('#zoomerright').css('display', 'block');
                      // show help 
                      $('#helpAutorLeft').css('display', 'none'); 
                      $('#helpAnnoLeft').css('display', 'none');
                      $('#helpAutorRight').css('display', 'none'); 
                      $('#helpAnnoRight').css('display', 'none');
                      $('#helpCompare').css('display', 'block');
                      $('#editor').css('display', 'block');
                      } 
                     error = 0;
                 }
             else
                 {
                    error++;
                    if(error < 20)
                        showImage(side, user);
                    else
                        {
                        document.getElementById("loadtext").innerHTML="Error! Please try again!";
                        error = 0;
                        }                      
                 }
            }
       };
        xmlhttp.send();
    }

// create the annotation list because of the choosen type
function annolist(side, user, lang){
        var name;
        // select the side and define the parameters
        if(side == "left")
            {
             type = $('#typelistleft').val();   
            }
        else if(side == "right") 
            {
             type = $('#typelistright').val(); 
            }
        else
            {
            type = $('#reltypelist').val();
            }
        // send a request to the compare script
        var xmlhttp;
        if (window.XMLHttpRequest)
            {// code for IE7+, Firefox, Chrome, Opera, Safari
                xmlhttp=new XMLHttpRequest();
            }
        else
            {// code for IE6, IE5
                xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
            }
        xmlhttp.open("GET","service/compare?type=list&amp;type="+type+"&amp;user="+user+"&amp;side="+side, true);
        xmlhttp.onreadystatechange=function(){
        if (xmlhttp.readyState==4)
            {
             if (xmlhttp.status==200)
                 { 
                    if(side == "left")
                      {
                      // integrate the dropdown list with the single annotations
                      document.getElementById("annoleft").innerHTML = xmlhttp.responseText;
                      // show help 
                      $('#helpAutorLeft').css('display', 'none'); 
                      $('#helpAnnoLeft').css('display', 'block');
                      $('#helpAutorRight').css('display', 'none'); 
                      $('#helpAnnoRight').css('display', 'none');
                      $('#helpCompare').css('display', 'none');                      
                      }
                    else if(side == "right") 
                      {
                      // integrate the dropdown list with the single annotations
                      document.getElementById("annoright").innerHTML = xmlhttp.responseText;
                      // show help 
                      $('#helpAutorLeft').css('display', 'none'); 
                      $('#helpAnnoLeft').css('display', 'none');
                      $('#helpAutorRight').css('display', 'none'); 
                      $('#helpAnnoRight').css('display', 'block');
                      $('#helpCompare').css('display', 'none');
                      }  
                     else
                        {
                        // integrate the dropdown list with the single annotations
                        document.getElementById("annorel").innerHTML = xmlhttp.responseText;
                        $('#relname').css('display', 'block');
                        }
                      error = 0;
                 }
             else
                 {
                    error++;
                    if(error < 20)
                        annolist(side, user, lang);
                    else
                        {
                        document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                        error = 0;
                        }   
                 }
            }
       };
        xmlhttp.send();
    }

// zoom the image in the compare viewport
function compareZoom(type, side){
        var src;
        var newWidth, newHeight;
        var alt;
        var img=document.createElement("IMG");
        // select the side and and delete the old image
        if (side == 'left')
        {
        src = document.getElementById("leftImg").getAttribute("SRC");
        alt = document.getElementById("leftImg").getAttribute("ALT");
        oldWidth = $('#leftImg').width();
        oldHeight = $('#leftImg').height();
        $('#leftImg').remove();
        img.setAttribute('NAME', "leftImg");
        img.setAttribute('ID', "leftImg");
        }
        else
        {
        src = document.getElementById("rightImg").getAttribute("SRC");
        alt = document.getElementById("rightImg").getAttribute("ALT");
        oldWidth = $('#rightImg').width();
        oldHeight = $('#rightImg').height();
        $('#rightImg').remove();
        img.setAttribute('NAME', "rightImg");
        img.setAttribute('ID', "rightImg");
        }
        img.setAttribute('ALT', alt);
        img.setAttribute('SRC', src);
        img.setAttribute('CLASS', 'img');
        // create a new image with the new size        
        if (type == 'in')
            {
            newWidth = oldWidth * 1.5;
            newHeight = oldHeight * 1.5;
            }
        else
            {
            newWidth = oldWidth / 1.5;
            newHeight = oldHeight / 1.5;
            }
        if (side == 'left')
        {
        document.getElementById("viewportleft").appendChild(img);
        $('#leftImg').width(newWidth);
        $('#leftImg').height(newHeight);
        }
        else
        {
        document.getElementById("viewportright").appendChild(img);
        $('#rightImg').width(newWidth);
        $('#rightImg').hidth(newHeight);
        }
    };

// zoom the image in the collection- compare viewport
function collectionZoom(type, side){
        var src;
        var newWidth, newHeight;
        var alt;
        var img=document.createElement("IMG");
        // select the side and and delete the old image
        if (side == 'left')
        {
        src = document.getElementById("collection-leftImg").getAttribute("SRC");
        alt = document.getElementById("collection-leftImg").getAttribute("ALT");
        oldWidth = $('#collection-leftImg').width();
        oldHeight = $('#collection-leftImg').height();
        $('#collection-leftImg').remove();
        img.setAttribute('NAME', "collection-leftImg");
        img.setAttribute('ID', "collection-leftImg");
        }
        else
        {
        src = document.getElementById("collection-rightImg").getAttribute("SRC");
        alt = document.getElementById("collection-rightImg").getAttribute("ALT");
        oldWidth = $('#collection-rightImg').width();
        oldHeight = $('#collection-rightImg').height();
        $('#collection-rightImg').remove();
        img.setAttribute('NAME', "collection-rightImg");
        img.setAttribute('ID', "collection-rightImg");
        }
        img.setAttribute('ALT', alt);
        img.setAttribute('SRC', src);
        img.setAttribute('CLASS', 'img');
        // create a new image with the new size        
        if (type == 'in')
            {
            newWidth = oldWidth * 1.5;
            newHeight = oldHeight * 1.5;
            }
        else
            {
            newWidth = oldWidth / 1.5;
            newHeight = oldHeight / 1.5;
            }
        if (side == 'left')
        {
        document.getElementById("collection-viewport-left").appendChild(img);
        $('#collection-leftImg').width(newWidth);
        $('#collection-leftImg').height(newHeight);
        }
        else
        {
        document.getElementById("collection-viewport-right").appendChild(img);
        $('#collection-rightImg').width(newWidth);
        $('#collection-rightImg').hidth(newHeight);
        }
    };

// zoom the image in the cropped Image Editor viewport
function editorZoom(type){
    var newWidth, newHeight;
    var index = document.getElementById("imagelist").selectedIndex;
    var id = document.getElementById("imagelist").options[index].text;
    var qid = "#"+id;
    oldWidth = $(qid).width();
    oldHeight = $(qid).height();
    // create a new image with the new size        
    if (type == 'in')
            {
            newWidth = oldWidth * 1.5;
            newHeight = oldHeight * 1.5;
            }
    else
            {
            newWidth = oldWidth / 1.5;
            newHeight = oldHeight / 1.5;
            }
   $(qid).width(newWidth);
   $(qid).height(newHeight);
   var img = document.getElementById(id);
   Pixastic.process(img, "brightness", {brightness:0,contrast:0});
	 jQuery( '.editorimg').draggable();
   IEparser = false;
}

// show the image tooltip
function showTooltip(e, id, type){
    // Calculate the position of the image tooltip
    if(type == 'publish')
        {
        var viewid = '#pubview'+id;
        var toolid = '#pubtool'+id;
        }
    else
        {
        var viewid = '#view'+id;
        var toolid = '#tool'+id;
        }
    x = e.pageX - $(viewid).offset().left;
    y = e.pageY - $(viewid).offset().top;
 
    // Set the z-index of the current item,
    // make sure it's greater than the rest of thumbnail items
    // Set the position and display the image tooltip
    $(viewid).css('z-index','15');
    $(toolid).css({'top': y + 40,'left': x + 30,'display':'block'});
}

// move the image tooltip to mouse position
function moveTooltip(e, id, type){
    if(type == 'publish')
        {
        var viewid = '#pubview'+id;
        var toolid = '#pubtool'+id;
        }
    else
        {
        var viewid = '#view'+id;
        var toolid = '#tool'+id;
        }
    // Calculate the position of the image tooltip         
    x = e.pageX - $(viewid).offset().left;
    y = e.pageY - $(viewid).offset().top;
             
    // This line causes the tooltip will follow the mouse pointer
    $(toolid).css({'top': y + 30,'left': x + 30});
}

// hide the image tooltip
function hideTooltip(e, id, type){
    if(type == 'publish')
        {
        var viewid = '#pubview'+id;
        var toolid = '#pubtool'+id;
        }
    else
        {
        var viewid = '#view'+id;
        var toolid = '#tool'+id;
        }
    // Reset the z-index and hide the image tooltip
    $(viewid).css('z-index','1');
    $(toolid).animate({"opacity": "hide"}, "fast");
}

// change the publishoption
function changePublish(option){
    if(option == "new") 
        {
        document.getElementById('newPubCollection').setAttribute('STYLE','position:relative;background:white;float:left;width:174px;z-index:5;border:solid #505050 1px;border-left:0px;border-bottom:0px;-webkit-border-top-left-radius: 5px;-webkit-bordertop-right-radius: 5px;-khtml-border-top-left-radius: 5px;-khtml-border-top-right-radius: 5px;-moz-border-radius-topleft: 5px;-moz-border-radius-topright: 5px;border-top-left-radius: 5px;border-top-right-radius: 5px;');
        document.getElementById('existPubCollection').setAttribute('STYLE','position:relative;float:left;width:175px;z-index:5;background:#F8F8F8;border:solid #505050 1px;border-left:0px;border-right:0px;border-top:0px;');
        $('#existPubData').css('display', 'none');
        $('#newPubData').css('display', 'block');
        saveoption = "new";
        }
    else
        {
        document.getElementById('existPubCollection').setAttribute("style","position:relative;background:white;float:left;width:175px;z-index:5;border:solid #505050 1px;border-right:0px;border-bottom:0px;-webkit-border-top-left-radius: 5px;-webkit-bordertop-right-radius: 5px;-khtml-border-top-left-radius: 5px;-khtml-border-top-right-radius: 5px;-moz-border-radius-topleft: 5px;-moz-border-radius-topright: 5px;border-top-left-radius: 5px;border-top-right-radius: 5px;");
        document.getElementById('newPubCollection').setAttribute("style","position:relative;float:left;width:174px;z-index:5;background:#F8F8F8;border:solid #505050 1px;border-left:0px;border-right:0px;border-top:0px;");
        $('#existPubData').css('display', 'block');
        $('#newPubData').css('display', 'none');
        saveoption = "exist";
        }
}

// change the saveoption
function changeSave(option){
    if(option == "new") 
        {
        document.getElementById('newcollection').setAttribute('STYLE','position:relative;background:white;float:left;width:174px;z-index:5;border:solid #505050 1px;border-left:0px;border-bottom:0px;-webkit-border-top-left-radius: 5px;-webkit-bordertop-right-radius: 5px;-khtml-border-top-left-radius: 5px;-khtml-border-top-right-radius: 5px;-moz-border-radius-topleft: 5px;-moz-border-radius-topright: 5px;border-top-left-radius: 5px;border-top-right-radius: 5px;');
        document.getElementById('existcollection').setAttribute('STYLE','position:relative;float:left;width:175px;z-index:5;background:#F8F8F8;border:solid #505050 1px;border-left:0px;border-right:0px;border-top:0px;');
        $('#existdata').css('display', 'none');
        $('#newdata').css('display', 'block');
        saveoption = "new";
        }
    else
        {
        document.getElementById('existcollection').setAttribute("style","position:relative;background:white;float:left;width:175px;z-index:5;border:solid #505050 1px;border-right:0px;border-bottom:0px;-webkit-border-top-left-radius: 5px;-webkit-bordertop-right-radius: 5px;-khtml-border-top-left-radius: 5px;-khtml-border-top-right-radius: 5px;-moz-border-radius-topleft: 5px;-moz-border-radius-topright: 5px;border-top-left-radius: 5px;border-top-right-radius: 5px;");
        document.getElementById('newcollection').setAttribute("style","position:relative;float:left;width:174px;z-index:5;background:#F8F8F8;border:solid #505050 1px;border-left:0px;border-right:0px;border-top:0px;");
        $('#existdata').css('display', 'block');
        $('#newdata').css('display', 'none');
        saveoption = "exist";
        }
}

// change context of compare editor
function changeContext(radio){
  if(radio.value == "cropped-img") {
    jQuery('#cropped-image-view').css('display', 'block');
    jQuery('#anno-view').css('display', 'none');
  }
  else {
    jQuery('#anno-view').css('display', 'block');
    jQuery('#cropped-image-view').css('display', 'none');
  }
  editorContext = radio.value;
}

// *!* ################ functions to edit cropped images ################ *!*

// delete a cropped image
function deleteData(id, user, entryid, lang){
    // ask user to confirm this step
    if(confirm(geti18nText(lang, 'delete-image-question')))
    {    
        // send a request to the crop script
        var xmlhttp;
        if (window.XMLHttpRequest)
            {// code for IE7+, Firefox, Chrome, Opera, Safari
                xmlhttp=new XMLHttpRequest();
            }
        else
            {// code for IE6, IE5
                xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
            }
        xmlhttp.open("GET","service/crop?type=delete&amp;id="+id+"&amp;user="+user,true);
        xmlhttp.onreadystatechange=function(){
        if (xmlhttp.readyState==4)
            {
             var breadcrump = document.createElement("div");
             breadcrump.innerHTML = xmlhttp.responseText;
             $('#loadtext').css('display', 'block');
             if (xmlhttp.status==200)
                 {
                    if (breadcrump.childNodes[0].childNodes[0].nodeValue == "delete")
                        {
                        document.getElementById("loadtext").innerHTML = geti18nText(lang, 'data-have-been-successful-removed');
                        var delID = 'type'+id;
                        old = document.getElementById(delID);
                        old.parentNode.removeChild(old);
                        }
                    else if(breadcrump.childNodes[0].childNodes[0].nodeValue == "deleteAll")
                        {
                        document.getElementById("loadtext").innerHTML = geti18nText(lang, 'data-and-colletcion-deleted');
                        var delID = 'type'+id;
                        old = document.getElementById(delID);
                        old.parentNode.removeChild(old);
                        nold = document.getElementById(entryid);
                        nold.parentNode.removeChild(nold);
                        }
                    else document.getElementById("loadtext").innerHTML = geti18nText(lang, 'data-not-deleted');
                    var miniID = 'viewimg'+id;
                    mold = document.getElementById(miniID).parentNode.parentNode;
                    mold.parentNode.removeChild(mold);
                    error = 0;
                 }
             else
                 {
                    error++;
                    if(error < 20)
                        deleteData(id, user, entryid, lang);
                    else
                        {
                        document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                        error = 0;
                        }   
                 }
            }
        }
        xmlhttp.send();
    }
    };

// add  cropped image to an existing collection
function addCrop(id, url, user, name, type, role, lang){
    var imagename = $('#imagenametext').val();
    var imagenote = $('#notetext').val();
    var index = document.getElementById("imagelist").selectedIndex;
    url = document.getElementById("imagelist").options[index].getAttribute("TITLE");
    var bid = document.getElementById("imagelist").options[index].text;
    if( bid == "")
      {
      alert(geti18nText(lang, 'select-image-in-drop-down'));
      }    
    else
      {
       if(IEparser == false)
           {
           var canvas = document.getElementById(bid);
           var context = canvas.getContext("2d");
           var img = canvas.toDataURL();
           }
        else
           var img = document.getElementById(bid).getAttribute("SRC");
      }
    if( img != null)
        {
        var parameters = "img="+img+"?!url="+url+"?!name="+name+"?!type="+type+"?!imagename="+imagename+"?!imagenote="+imagenote;
        var functype = "exist";
        // send request to crop script
        var xmlhttp;
        if (window.XMLHttpRequest)
                {// code for IE7+, Firefox, Chrome, Opera, Safari
                    xmlhttp=new XMLHttpRequest();
                }
        else
                {// code for IE6, IE5
                    xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
                }
        xmlhttp.open("POST","service/crop?type=post&amp;functype="+functype+"&amp;user="+user+"&amp;id="+id,true);
        xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
        xmlhttp.onreadystatechange=function(){
            if (xmlhttp.readyState==4)
                {
                 if (xmlhttp.status==200)
                     { 
                        $('#process-img').css('display', 'none');
                        $('#result').css('display', 'block');
                        var xmlDoc = jQuery.parseXML(xmlhttp.response);
                        var addID = type+name+id;
                        // define ID because of existing elements
                        var outerid = xmlDoc.getElementsByTagName('dataid')[0].childNodes[0].nodeValue;
                        var newid = Math.floor((Math.random()*1000)+500)+Math.floor((Math.random()*1000)+500);
                        var viewid = 'view'+newid;
                        var toolid = 'tool'+newid;
                        var addid = '#add'+id;
                            var nspanStyle = "position:relative;float:left;font-size:12px;"
                            var inamespan = document.createElement("span");
                            inamespan.setAttribute('STYLE', nspanStyle);
                            inamespan.setAttribute('CLASS', 'autorlabels');
                            inamespan.textContent = "Image Name: ";
                            
                            var colspanStyle = "position:relative;float:left;font-size:12px;"
                            var colID = "colimage"+outerid;
                            var colspan = document.createElement("span");
                            colspan.setAttribute('STYLE', colspanStyle);
                            colspan.setAttribute('ID', colID);
                            colspan.setAttribute('CLASS', 'autorlabels');
                            colspan.textContent = imagename;
                            
                            var editnameID = "editimage"+outerid;
                            var editnameStyle = "position:relative;top:-4px;float:left;margin:auto;left:-2px;z-index:20;";
                            var editnameClick = "prepareEditCollection('image','"+outerid+"')";
                            var editname = document.createElement("p");
                            editname.setAttribute('ID', editnameID);
                            editname.setAttribute('ONCLICK', editnameClick);
                            editname.setAttribute('STYLE', editnameStyle);
                                var nameimg = document.createElement("img");
                                    nameimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/button_edit');
                                    nameimg.setAttribute('STYLE', 'width:10px;');
                                    nameimg.setAttribute('TITLE', 'Edit Image Name');
                            editname.appendChild(nameimg);
                            
                            var nameinputID = "fieldimage"+outerid;
                            var nameinput = document.createElement("input");
                            nameinput.setAttribute('STYLE', 'position:relative;float:left;height:20px;width:45px;top:2px;');
                            nameinput.setAttribute('TYPE', 'text');
                            nameinput.setAttribute('ID', nameinputID);
                            
                            var namebuttonID = "saveimage"+outerid;
                            var namebuttonCLICK = "editCollection('image','"+outerid+"', '"+id+"', '"+user+"' , '"+outerid+"', '"+lang+"')";
                            var namebutton = document.createElement("p");
                            namebutton.setAttribute('CLASS', 'button');
                            namebutton.setAttribute('STYLE', 'position:relative;top:-21px;margin-bottom:0px;float:left;text-align:center;line-height: 0.7em;');
                            namebutton.setAttribute('ID', namebuttonID);
                            namebutton.setAttribute('ONCLICK', namebuttonCLICK);
                            namebutton.textContent = "Save";
                            
                            var divename = document.createElement("div");
                            var divenameID = "editorimage"+outerid;
                            divename.setAttribute('STYLE', 'display:none;');
                            divename.setAttribute('ID', divenameID);
                            divename.appendChild(nameinput);
                            divename.appendChild(namebutton);
                            
                            var charterspan = document.createElement("span");
                            charterspan.setAttribute('CLASS', 'autorlabels');
                            charterspan.setAttribute('STYLE', 'position:relative;float:left;font-size:12px;');
                            charterspan.textContent = "Charter: ";
                            
                            var chartertext = document.createElement("span");
                            chartertext.setAttribute('CLASS', 'autorlabels');
                            chartertext.setAttribute('STYLE', 'position:relative;float:left;top:-2px;');
                                var atag = document.createElement("a");
                                atag.setAttribute('HREF', url);
                                atag.setAttribute('STYLE', "font-size:12px;");
                                var slashindex = url.lastIndexOf("/");
                                atag.textContent = url.substring(slashindex+1);
                            chartertext.appendChild(atag);
                            
                            var inameStyle = "position:relative;float:left;width:100%;";
                            var inamediv = document.createElement("div");
                            inamediv.setAttribute('STYLE', inameStyle);
                            inamediv.appendChild(inamespan);
                            inamediv.appendChild(colspan);
                            inamediv.appendChild(editname);
                            inamediv.appendChild(divename);
                            
                            var charterdiv = document.createElement("div");
                            charterdiv.setAttribute('STYLE', 'position:relative;float:left;width:100%;');
                            charterdiv.appendChild(charterspan);
                            charterdiv.appendChild(chartertext);
                            
                            var aview = document.createElement("a");
                            var aviewID = "url"+outerid;
                            aview.setAttribute('ID', aviewID);
                            aview.setAttribute('HREF', url);
                                var viewimg = document.createElement("img");
                                var viewimgID = "cropimgview"+outerid;
                                viewimg.setAttribute('CLASS', 'cropimg');
                                viewimg.setAttribute('ID', viewimgID);
                                viewimg.setAttribute('SRC', img);
                            aview.appendChild(viewimg);
                            
                            var viewportdiv = document.createElement("div");
                            viewportdiv.setAttribute('CLASS', 'cropviewport');
                            viewportdiv.setAttribute('STYLE', 'vertical-align:middle;margin:5%;text-align:center;');
                            viewportdiv.appendChild(aview);
                            
                            var spannote = document.createElement("span");
                            spannote.setAttribute('CLASS', 'autorlabels');
                            spannote.setAttribute('STYLE', 'position:relative;float:left;font-size:12px;');
                            spannote.textContent = "Note :";
                            
                            var colnoteID = "colnote"+outerid;
                            var colnote = document.createElement("span");
                            colnote.setAttribute('CLASS', 'autorlabels'); 
                            colnote.setAttribute('ID', colnoteID); 
                            colnote.setAttribute('STYLE', 'position:relative;float:left;font-size:12px;max-width:250px;');
                            colnote.textContent = imagenote;
                            
                            var editnoteID = "editnote"+outerid;
                            var noteONCLICK = "prepareEditCollection('note','"+outerid+"')";
                            var editnote = document.createElement("p");
                            editnote.setAttribute('ONCLICK', noteONCLICK);
                            editnote.setAttribute('ID', editnoteID);
                            editnote.setAttribute('STYLE', 'position:relative;top:-4px;float:left;margin:auto;left:-2px;z-index:20;');
                                var noteimg = document.createElement("img");
                                    noteimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/button_edit');
                                    noteimg.setAttribute('STYLE', 'width:10px;');
                                    noteimg.setAttribute('TITLE', 'Edit Note');
                            editnote.appendChild(noteimg);
                            
                            var textareaID = "fieldnote"+outerid;
                            var ntextarea = document.createElement("textarea");
                            ntextarea.setAttribute('STYLE', 'position:relative;float:left;height:20px;width:100px;top:2px;');
                            ntextarea.setAttribute('ID', textareaID);
                            
                            var noteButtonID = "savenote"+outerid;
                            var noteButtonCLICK = "editCollection('note','"+outerid+"', '"+id+"', '"+user+"' , '"+outerid+"', '"+lang+"')";
                            var noteButton = document.createElement("p");
                            noteButton.setAttribute('ID', noteButtonID);
                            noteButton.setAttribute('ONCLICK', noteButtonCLICK);
                            noteButton.setAttribute('CLASS', 'button');
                            noteButton.setAttribute('STYLE', 'position:relative;top:-21px;margin-bottom:0px;float:left;text-align:center;line-height: 0.7em;');
                            noteButton.textContent = "Save";
                            
                            var editornoteID = "editornote"+outerid;
                            var editornote = document.createElement("div"); 
                            editornote.setAttribute('STYLE', 'display:none;');
                            editornote.setAttribute('ID', editornoteID);
                            editornote.appendChild(ntextarea);
                            editornote.appendChild(noteButton);
                            
                            var notediv = document.createElement("div");
                            notediv.setAttribute('STYLE', 'position:relative;float:left;width:100%;');
                            notediv.appendChild(spannote);
                            notediv.appendChild(colnote);
                            notediv.appendChild(editnote);
                            notediv.appendChild(editornote);
                            
                            var relocateButton = document.createElement("p");
                            var relocateCLICK = "prepareRelocate(event, '"+outerid+"', '"+user+"', '"+role+"', '"+lang+"')";
                            relocateButton.setAttribute('STYLE', 'position:relative;float:left;');
                            relocateButton.setAttribute('CLASS', 'button');
                            relocateButton.setAttribute('TITLE', 'Move To');
                            relocateButton.setAttribute('ONCLICK', relocateCLICK);
                                    var relocateimg = document.createElement("img");
                                    relocateimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/move-to');
                                    relocateimg.setAttribute('STYLE', 'width:25px;');
                                    relocateimg.setAttribute('TITLE', 'Move To');
                            relocateButton.appendChild(relocateimg);
                            
                            var deleteButton = document.createElement("p");
                            var deleteCLICK = "deleteData('"+outerid+"', '"+user+"', '"+name+type+id+"', '"+lang+"')";
                            deleteButton.setAttribute('STYLE', 'position:relative;float:left;height:25px;');
                            deleteButton.setAttribute('CLASS', 'button');
                            deleteButton.setAttribute('TITLE', 'Delete Image');
                            deleteButton.setAttribute('ONCLICK', deleteCLICK);
                                    var deleteimg = document.createElement("img");
                                    deleteimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/remove');
                                    deleteimg.setAttribute('STYLE', 'width:20px;position:relative;top:2px;');
                                    deleteimg.setAttribute('TITLE', 'Delete Image');
                            deleteButton.appendChild(deleteimg);
                            
                            var publishButton = document.createElement("p");
                            var publishCLICK = "preparePublish(event, '"+outerid+"', '"+user+"', '"+name+"', '"+type+"', '"+id+"', '"+role+"', '"+lang+"');";
                            publishButton.setAttribute('STYLE', 'position:relative;float:left;height:25px;');
                            publishButton.setAttribute('CLASS', 'button');
                            publishButton.setAttribute('TITLE', 'Publish Image');
                            publishButton.setAttribute('ONCLICK', publishCLICK);
                                    var publishimg = document.createElement("img");
                                    publishimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/export');
                                    publishimg.setAttribute('STYLE', 'width:20px;position:relative;top:2px;');
                                    publishimg.setAttribute('TITLE', 'Publish Image');
                            publishButton.appendChild(publishimg);
                            
                            var sendButton = document.createElement("p");
                            var sendCLICK = "prepareSend(event, '"+outerid+"', '"+user+"', '"+lang+"');";
                            sendButton.setAttribute('STYLE', 'position:relative;float:left;height:25px;');
                            sendButton.setAttribute('CLASS', 'button');
                            sendButton.setAttribute('TITLE', 'Send To');
                            sendButton.setAttribute('ONCLICK', sendCLICK);
                                    var sendimg = document.createElement("img");
                                    sendimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/mail');
                                    sendimg.setAttribute('STYLE', 'width:25px;position:relative;left:1px;');
                                    sendimg.setAttribute('TITLE', 'Send To');
                            sendButton.appendChild(sendimg);
                            
                            var buttonDiv = document.createElement("div");
                            buttonDiv.setAttribute('STYLE', 'position:relative;left:30px;width:190px;');
                            buttonDiv.appendChild(relocateButton);
                            buttonDiv.appendChild(deleteButton);
                            buttonDiv.appendChild(publishButton);
                            buttonDiv.appendChild(sendButton);
                            
                            var basicID = 'type'+outerid;
                            var basicStyle = "float:left;height:100%;max-height:430px;width:230px;overflow:auto;border:solid rgb(240,243,226) 1px;margin:3px;";
                            var basicdiv = document.createElement("div");
                            basicdiv.setAttribute('ID', basicID);
                            basicdiv.setAttribute('STYLE', basicStyle);
                            basicdiv.appendChild(inamediv); 
                            basicdiv.appendChild(charterdiv); 
                            basicdiv.appendChild(viewportdiv);
                            basicdiv.appendChild(notediv);
                            basicdiv.appendChild(buttonDiv);
                            
                            var entryid = "annotable"+name+type+id;
                            document.getElementById(entryid).appendChild(basicdiv);
                        
                        
                        // functions
                        var overstring = "showTooltip(event, '"+newid+"')"
                        var movestring = "moveTooltip(event, '"+newid+"')"
                        var outstring = "hideTooltip(event, '"+newid+"')"
                        
                        var outerdiv = document.createElement("div");
                        outerdiv.setAttribute('ID', outerid);
                        
                        // create miniviewport
                        var viewdiv = document.createElement("div");
                        viewdiv.setAttribute('ID', viewid);
                        viewdiv.setAttribute('CLASS', 'miniviewport');
                            var minimg = document.createElement("img");
                            minimg.setAttribute('SRC', img);
                            var miniID = "viewimg"+outerid;
                            minimg.setAttribute('ID', miniID);
                            minimg.setAttribute('CLASS', 'cropminiimg');
                            minimg.setAttribute('ONMOUSEOVER', overstring);
                            minimg.setAttribute('ONMOUSEMOVE', movestring);
                            minimg.setAttribute('ONMOUSEOUT', outstring);
                        viewdiv.appendChild(minimg);
                            
                        
                        // create tooltip
                        var tooldiv = document.createElement("div");
                        tooldiv.setAttribute('ID', toolid);
                        tooldiv.setAttribute('CLASS', 'tooltip');
                            var toolimg = document.createElement("img");
                            toolimg.setAttribute('SRC', img);
                            toolimg.setAttribute('CLASS', 'toolimg');
                        tooldiv.appendChild(toolimg);
                        
                        outerdiv.appendChild(viewdiv);
                        outerdiv.appendChild(tooldiv);
                        
                        document.getElementById(addID).appendChild(outerdiv);
                        
                        error = 0;
                        }
                 else
                     {
                     error++;
                     if(error < 20)
                       addCrop(id, url, user, name, type, role, lang);
                     else
                            {
                            $('#loadgif').css('display', 'none');
                            document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                            error = 0;
                            }
                     }
                }
           else { 
                    $('#process-img').css('display', 'block');
                    $('#result').css('display', 'none');
                    $('#loading').css('display', 'block');
                    document.getElementById("loadtext").innerHTML = geti18nText(lang, 'saving-data');
                }
             };
            xmlhttp.send(parameters);
      }
}

// store the user's cropped image in his userfile    
function storeCrop(url, user, role, lang){
        var name = $('#nametext').val();
        var type = $('#typetext').val();
        var imagename = $('#imagenametext').val();
        var imagenote = $('#notetext').val();
        var index = document.getElementById("imagelist").selectedIndex;
        url = document.getElementById("imagelist").options[index].getAttribute("TITLE");
        var bid = document.getElementById("imagelist").options[index].text;
        if( bid == "")
                {
                alert(geti18nText(lang, 'select-image-in-drop-down'));
                }
       else
                {
                if(IEparser == false)
                    {
                    var canvas = document.getElementById(bid);
                    var context = canvas.getContext("2d");
                    var img = canvas.toDataURL();
                    }
                else
                    var img = document.getElementById(bid).getAttribute("SRC");
                }
        if( img != null)
            {
            var parameters = "img="+img+"?!url="+url+"?!name="+name+"?!type="+type+"?!imagename="+imagename+"?!imagenote="+imagenote;
            var functype = "new";
            // check for the user's input
            if (name == '' || type == '')
                {
                alert(geti18nText(lang, 'insert-type-or-name'));
                }
            else
            {
            // send request to crop script
            var xmlhttp;
            if (window.XMLHttpRequest)
                {// code for IE7+, Firefox, Chrome, Opera, Safari
                    xmlhttp=new XMLHttpRequest();
                }
            else
                {// code for IE6, IE5
                    xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
                }
            xmlhttp.open("POST","service/crop?type=post&amp;functype="+functype+"&amp;user="+user,true);
            xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
            xmlhttp.onreadystatechange=function(){
            if (xmlhttp.readyState==4)
                {
                 if (xmlhttp.status==200)
                     { 
                        $('#loadgif').css('display', 'none');
                        $('#process-img').css('display', 'none');
                        $('#result').css('display', 'block');
                        var xmlDoc = jQuery.parseXML(xmlhttp.response);
                        if (xmlDoc.childNodes[0].nodeName == "data")
                        {
                            var outerid = xmlDoc.getElementsByTagName('dataid')[0].childNodes[0].nodeValue;
                            var id = xmlDoc.getElementsByTagName('cropid')[0].childNodes[0].nodeValue;
                            var newid = Math.floor((Math.random()*1000)+500)+Math.floor((Math.random()*1000)+500);
                            var addID = type+name+id;
                            // insert new data into the dropdown- lists of existing datas
                                var typeoptions = document.getElementById("typelistleft").options;
                                var found = false;
                                for(i=0;i<typeoptions.length;i++)
                                    {
                                    if(typeoptions[i].text == type)
                                        found=true;
                                    }
                                if(found==false)
                                    {
                                    var leftoption = document.createElement("option");
                                        leftoption.textContent = type;
                                        document.getElementById("typelistleft").appendChild(leftoption);
                                        
                                    var rightoption = document.createElement("option");
                                        rightoption.textContent = type;
                                        document.getElementById("typelistright").appendChild(rightoption); 
                                    
                                    var reloption = document.createElement("option");
                                        reloption.textContent = type;
                                        document.getElementById("reltypelist").appendChild(reloption);
                                    }
                                
                                var nspanStyle = "position:relative;float:left;font-size:12px;"
                                var inamespan = document.createElement("span");
                                inamespan.setAttribute('STYLE', nspanStyle);
                                inamespan.setAttribute('CLASS', 'autorlabels');
                                inamespan.textContent = "Image Name: ";
                                
                                var colspanStyle = "position:relative;float:left;font-size:12px;"
                                var colID = "colimage"+outerid;
                                var colspan = document.createElement("span");
                                colspan.setAttribute('STYLE', colspanStyle);
                                colspan.setAttribute('ID', colID);
                                colspan.setAttribute('CLASS', 'autorlabels');
                                colspan.textContent = imagename;
                                
                                var editnameID = "editimage"+outerid;
                                var editnameStyle = "position:relative;top:-4px;float:left;margin:auto;left:-2px;z-index:20;";
                                var editnameClick = "prepareEditCollection('image','"+outerid+"')"
                                var editname = document.createElement("p");
                                editname.setAttribute('ID', editnameID);
                                editname.setAttribute('ONCLICK', editnameClick);
                                editname.setAttribute('STYLE', editnameStyle);
                                    var nameimg = document.createElement("img");
                                        nameimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/button_edit');
                                        nameimg.setAttribute('STYLE', 'width:10px;');
                                        nameimg.setAttribute('TITLE', 'Edit Image Name');
                                editname.appendChild(nameimg);
                                
                                var nameinputID = "fieldimage"+outerid;
                                var nameinput = document.createElement("input");
                                nameinput.setAttribute('STYLE', 'position:relative;float:left;height:20px;width:45px;top:2px;');
                                nameinput.setAttribute('TYPE', 'text');
                                nameinput.setAttribute('ID', nameinputID);
                                
                                var namebuttonID = "saveimage"+outerid;
                                var namebuttonCLICK = "editCollection('image','"+outerid+"', '"+id+"', '"+user+"' , '"+outerid+"', '"+lang+"')";
                                var namebutton = document.createElement("p");
                                namebutton.setAttribute('CLASS', 'button');
                                namebutton.setAttribute('STYLE', 'position:relative;top:-21px;margin-bottom:0px;float:left;text-align:center;line-height: 0.7em;');
                                namebutton.setAttribute('ID', namebuttonID);
                                namebutton.setAttribute('ONCLICK', namebuttonCLICK);
                                namebutton.textContent = "Save";
                                
                                var divename = document.createElement("div");
                                var divenameID = "editorimage"+outerid;
                                divename.setAttribute('STYLE', 'display:none;');
                                divename.setAttribute('ID', divenameID);
                                divename.appendChild(nameinput);
                                divename.appendChild(namebutton);
                                
                                var charterspan = document.createElement("span");
                                charterspan.setAttribute('CLASS', 'autorlabels');
                                charterspan.setAttribute('STYLE', 'position:relative;float:left;font-size:12px;');
                                charterspan.textContent = "Charter: ";
                                
                                var chartertext = document.createElement("span");
                                chartertext.setAttribute('CLASS', 'autorlabels');
                                chartertext.setAttribute('STYLE', 'position:relative;float:left;top:-2px;');
                                    var atag = document.createElement("a");
                                    atag.setAttribute('HREF', url);
                                    atag.setAttribute('STYLE', "font-size:12px;");
                                    var slashindex = url.lastIndexOf("/");
                                    atag.textContent = url.substring(slashindex+1);
                                chartertext.appendChild(atag);
                                
                                var inameStyle = "position:relative;float:left;width:100%;";
                                var inamediv = document.createElement("div");
                                inamediv.setAttribute('STYLE', inameStyle);
                                inamediv.appendChild(inamespan);
                                inamediv.appendChild(colspan);
                                inamediv.appendChild(editname);
                                inamediv.appendChild(divename);
                                
                                var charterdiv = document.createElement("div");
                                charterdiv.setAttribute('STYLE', 'position:relative;float:left;width:100%;');
                                charterdiv.appendChild(charterspan);
                                charterdiv.appendChild(chartertext);
                                
                                var aview = document.createElement("a");
                                var aviewID = "url"+outerid;
                                aview.setAttribute('ID', aviewID);
                                aview.setAttribute('HREF', url);
                                    var viewimg = document.createElement("img");
                                    var viewimgID = "cropimgview"+outerid;
                                    viewimg.setAttribute('CLASS', 'cropimg');
                                    viewimg.setAttribute('ID', viewimgID);
                                    viewimg.setAttribute('SRC', img);
                                aview.appendChild(viewimg);
                                
                                var viewportdiv = document.createElement("div");
                                viewportdiv.setAttribute('CLASS', 'cropviewport');
                                viewportdiv.setAttribute('STYLE', 'vertical-align:middle;margin:5%;text-align:center;');
                                viewportdiv.appendChild(aview);
                                
                                var spannote = document.createElement("span");
                                spannote.setAttribute('CLASS', 'autorlabels');
                                spannote.setAttribute('STYLE', 'position:relative;float:left;font-size:12px;');
                                spannote.textContent = "Note :";
                                
                                var colnoteID = "colnote"+outerid;
                                var colnote = document.createElement("span");
                                colnote.setAttribute('CLASS', 'autorlabels'); 
                                colnote.setAttribute('ID', colnoteID); 
                                colnote.setAttribute('STYLE', 'position:relative;float:left;font-size:12px;max-width:230px;');
                                colnote.textContent = imagenote;
                                
                                var editnoteID = "editnote"+outerid;
                                var noteONCLICK = "prepareEditCollection('note','"+outerid+"')";
                                var editnote = document.createElement("p");
                                editnote.setAttribute('ONCLICK', noteONCLICK);
                                editnote.setAttribute('ID', editnoteID);
                                editnote.setAttribute('STYLE', 'position:relative;top:-4px;float:left;margin:auto;left:-2px;z-index:20;');
                                    var noteimg = document.createElement("img");
                                        noteimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/button_edit');
                                        noteimg.setAttribute('STYLE', 'width:10px;');
                                        noteimg.setAttribute('TITLE', 'Edit Note');
                                editnote.appendChild(noteimg);
                                
                                var textareaID = "fieldnote"+outerid;
                                var ntextarea = document.createElement("textarea");
                                ntextarea.setAttribute('STYLE', 'position:relative;float:left;height:20px;width:100px;top:2px;');
                                ntextarea.setAttribute('ID', textareaID);
                                
                                var noteButtonID = "savenote"+outerid;
                                var noteButtonCLICK = "editCollection('note','"+outerid+"', '"+id+"', '"+user+"' , '"+outerid+"', '"+lang+"')";
                                var noteButton = document.createElement("p");
                                noteButton.setAttribute('ID', noteButtonID);
                                noteButton.setAttribute('ONCLICK', noteButtonCLICK);
                                noteButton.setAttribute('CLASS', 'button');
                                noteButton.setAttribute('STYLE', 'position:relative;top:-21px;margin-bottom:0px;float:left;text-align:center;line-height: 0.7em;');
                                noteButton.textContent = "Save";
                                
                                var editornoteID = "editornote"+outerid;
                                var editornote = document.createElement("div"); 
                                editornote.setAttribute('STYLE', 'display:none;');
                                editornote.setAttribute('ID', editornoteID);
                                editornote.appendChild(ntextarea);
                                editornote.appendChild(noteButton);
                                
                                var notediv = document.createElement("div");
                                notediv.setAttribute('STYLE', 'position:relative;float:left;width:100%;');
                                notediv.appendChild(spannote);
                                notediv.appendChild(colnote);
                                notediv.appendChild(editnote);
                                notediv.appendChild(editornote);
                                
                                var relocateButton = document.createElement("p");
                            var relocateCLICK = "prepareRelocate(event, '"+outerid+"', '"+user+"', '"+role+"', '"+lang+"')";
                            relocateButton.setAttribute('STYLE', 'position:relative;float:left;');
                            relocateButton.setAttribute('CLASS', 'button');
                            relocateButton.setAttribute('TITLE', 'Move To');
                            relocateButton.setAttribute('ONCLICK', relocateCLICK);
                                    var relocateimg = document.createElement("img");
                                    relocateimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/move-to');
                                    relocateimg.setAttribute('STYLE', 'width:25px;');
                                    relocateimg.setAttribute('TITLE', 'Move To');
                            relocateButton.appendChild(relocateimg);
                            
                            var deleteButton = document.createElement("p");
                            var deleteCLICK = "deleteData('"+outerid+"', '"+user+"', '"+name+type+id+"', '"+lang+"')";
                            deleteButton.setAttribute('STYLE', 'position:relative;float:left;height:25px;');
                            deleteButton.setAttribute('CLASS', 'button');
                            deleteButton.setAttribute('TITLE', 'Delete Image');
                            deleteButton.setAttribute('ONCLICK', deleteCLICK);
                                    var deleteimg = document.createElement("img");
                                    deleteimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/remove');
                                    deleteimg.setAttribute('STYLE', 'width:20px;position:relative;top:2px;');
                                    deleteimg.setAttribute('TITLE', 'Delete Image');
                            deleteButton.appendChild(deleteimg);
                            
                            var publishButton = document.createElement("p");
                            var publishCLICK = "preparePublish(event, '"+outerid+"', '"+user+"', '"+name+"', '"+type+"', '"+id+"', '"+role+"','"+lang+"');";
                            publishButton.setAttribute('STYLE', 'position:relative;float:left;height:25px;');
                            publishButton.setAttribute('CLASS', 'button');
                            publishButton.setAttribute('TITLE', 'Publish Image');
                            publishButton.setAttribute('ONCLICK', publishCLICK);
                                    var publishimg = document.createElement("img");
                                    publishimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/export');
                                    publishimg.setAttribute('STYLE', 'width:20px;position:relative;top:2px;');
                                    publishimg.setAttribute('TITLE', 'Publish Image');
                            publishButton.appendChild(publishimg);
                            
                            var sendButton = document.createElement("p");
                            var sendCLICK = "prepareSend(event, '"+outerid+"', '"+user+"', '"+lang+"');";
                            sendButton.setAttribute('STYLE', 'position:relative;float:left;height:25px;');
                            sendButton.setAttribute('CLASS', 'button');
                            sendButton.setAttribute('TITLE', 'Send To');
                            sendButton.setAttribute('ONCLICK', sendCLICK);
                                    var sendimg = document.createElement("img");
                                    sendimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/mail');
                                    sendimg.setAttribute('STYLE', 'width:25px;position:relative;left:1px;');
                                    sendimg.setAttribute('TITLE', 'Send To');
                            sendButton.appendChild(sendimg);
                            
                            var buttonDiv = document.createElement("div");
                            buttonDiv.setAttribute('STYLE', 'position:relative;left:30px;width:190px;');
                            buttonDiv.appendChild(relocateButton);
                            buttonDiv.appendChild(deleteButton);
                            buttonDiv.appendChild(publishButton);
                            buttonDiv.appendChild(sendButton);
                                
                                var basicID = 'type'+outerid;
                                var basicStyle = "float:left;height:100%;max-height:430px;width:230px;overflow:auto;border:solid rgb(240,243,226) 1px;margin:3px;";
                                var basicdiv = document.createElement("div");
                                basicdiv.setAttribute('ID', basicID);
                                basicdiv.setAttribute('STYLE', basicStyle);
                                basicdiv.appendChild(inamediv); 
                                basicdiv.appendChild(charterdiv); 
                                basicdiv.appendChild(viewportdiv);
                                basicdiv.appendChild(notediv);
                                basicdiv.appendChild(buttonDiv);
                                
                                var typediv = document.createElement("div");
                                typediv.setAttribute('CLASS', 'autorlabels');
                                typediv.setAttribute('STYLE', 'float:left');
                                    var typspan = document.createElement("span");
                                    typspan.setAttribute('STYLE', 'float:left');
                                    typspan.textContent = "Type:";
                                    var coltypeID = "coltype"+newid;
                                    coltype = document.createElement("span");
                                    coltype.setAttribute('STYLE', 'position:relative;float:left;left:3px;');
                                    coltype.setAttribute('ID', coltypeID);
                                    coltype.textContent = type;
                                typediv.appendChild(typspan);
                                typediv.appendChild(coltype);
                                
                                var typeditor = document.createElement("p");
                                var typeditorID = "edittype"+newid;
                                var typeCLICK = "prepareEditCollection('type','"+newid+"')";
                                typeditor.setAttribute('ID', typeditorID);
                                typeditor.setAttribute('ONCLICK', typeCLICK);
                                typeditor.setAttribute('STYLE', "position:relative;top:-4px;float:left;margin:auto;z-index:20;");
                                    var typimg = document.createElement("img");
                                    typimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/button_edit');
                                    typimg.setAttribute('STYLE', 'width:10px;');
                                    typimg.setAttribute('TITLE', 'Edit Type');
                                typeditor.appendChild(typimg);
                                
                                var editortypdiv = document.createElement("div");
                                var editortypdivID = "editortype"+newid;
                                editortypdiv.setAttribute('ID', editortypdivID);
                                editortypdiv.setAttribute('STYLE', 'display:none;');
                                    var typinput = document.createElement("input");
                                    var typinputID = "fieldtype"+newid;
                                    typinput.setAttribute('STYLE', 'position:relative;float:left;height:20px;width:80px;top:2px;left:13px;');
                                    typinput.setAttribute('TYPE', 'text');
                                    typinput.setAttribute('ID', typinputID);
                                    var typbutton = document.createElement("p");
                                    var typbuttonID = "savetype"+newid;
                                    var typbuttonCLICK = "editCollection('type','"+newid+"', '"+id+"', '"+user+"' , '0', '"+lang+"')";
                                    typbutton.setAttribute('STYLE', 'position:relative;left:9px;top:-21px;margin-bottom:0px;float:left;text-align:center;line-height: 0.7em;');
                                    typbutton.setAttribute('CLASS', 'button');
                                    typbutton.setAttribute('ID', typbuttonID);
                                    typbutton.setAttribute('ONCLICK', typbuttonCLICK);
                                    typbutton.textContent = "Save";
                                editortypdiv.appendChild(typinput);
                                editortypdiv.appendChild(typbutton);
                                
                                var namdiv = document.createElement("div");
                                namdiv.setAttribute('CLASS', 'autorlabels');
                                namdiv.setAttribute('STYLE', 'float:left');
                                    var namspan = document.createElement("span");
                                    namspan.setAttribute('STYLE', 'float:left');
                                    namspan.textContent = "Name:";
                                    var colnamID = "colname"+newid;
                                    colnam = document.createElement("span");
                                    colnam.setAttribute('STYLE', 'position:relative;float:left;left:3px;');
                                    colnam.setAttribute('ID', colnamID);
                                    colnam.textContent = name;
                                namdiv.appendChild(namspan);
                                namdiv.appendChild(colnam);
                                
                                var namditor = document.createElement("p");
                                var namditorID = "editname"+newid;
                                var namCLICK = "prepareEditCollection('name','"+newid+"')";
                                namditor.setAttribute('ID', namditorID);
                                namditor.setAttribute('ONCLICK', namCLICK);
                                namditor.setAttribute('STYLE', "position:relative;left:30px;top:-4px;float:left;margin:auto;z-index:20;");
                                    var namimg = document.createElement("img");
                                    namimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/button_edit');
                                    namimg.setAttribute('STYLE', 'width:10px;');
                                    namimg.setAttribute('TITLE', 'Edit Name');
                                namditor.appendChild(namimg);
                                
                                var editornamdiv = document.createElement("div");
                                var editornamdivID = "editorname"+newid;
                                editornamdiv.setAttribute('ID', editornamdivID);
                                editornamdiv.setAttribute('STYLE', 'display:none;');
                                    var naminput = document.createElement("input");
                                    var naminputID = "fieldname"+newid;
                                    naminput.setAttribute('STYLE', 'position:relative;float:left;height:20px;width:80px;top:2px;left:30px;');
                                    naminput.setAttribute('TYPE', 'text');
                                    naminput.setAttribute('ID', naminputID);
                                    var nambutton = document.createElement("p");
                                    var nambuttonID = "savename"+newid;
                                    var nambuttonCLICK = "editCollection('name','"+newid+"', '"+id+"', '"+user+"' , '0', '"+lang+"')";
                                    nambutton.setAttribute('STYLE', 'position:relative;left:30px;top:-21px;margin-bottom:0px;float:left;text-align:center;line-height: 0.7em;');
                                    nambutton.setAttribute('CLASS', 'button');
                                    nambutton.setAttribute('ID', nambuttonID);
                                    nambutton.setAttribute('ONCLICK', nambuttonCLICK);
                                    nambutton.textContent = "Save";
                                editornamdiv.appendChild(naminput);
                                editornamdiv.appendChild(nambutton);
                                
                                var entryheader = document.createElement("div");
                                entryheader.setAttribute('CLASS', 'entryheader');
                                entryheader.appendChild(typediv);
                                entryheader.appendChild(typeditor);
                                entryheader.appendChild(editortypdiv);
                                entryheader.appendChild(namdiv);
                                entryheader.appendChild(namditor);
                                entryheader.appendChild(editornamdiv);
                                
                                var entryfooter = document.createElement("div");
                                entryfooter.setAttribute('CLASS', 'entryfooter');
                                
                                var annotable = document.createElement("div");
                                var annotableID = "annotable"+name+type+id;
                                annotable.setAttribute('CLASS', 'annotable');
                                annotable.setAttribute('ID', annotableID);
                                annotable.appendChild(basicdiv);
                                
                                var basentry = document.createElement("div");
                                var basentryID = name+type+id;
                                basentry.setAttribute('ID', basentryID);
                                basentry.setAttribute('CLASS', 'entry');
                                basentry.appendChild(entryheader);
                                basentry.appendChild(annotable);
                                basentry.appendChild(entryfooter);
                                
                                document.getElementById("anno").appendChild(basentry);
                                
                            
                            var viewid = 'view'+newid;
                            var toolid = 'tool'+newid;
                            var adderid = 'add'+id;
                            
                            var entrydiv = document.createElement("div");
                            entrydiv.setAttribute("CLASS","saveentry");
                            
                            var namespan = document.createElement("span");
                            namespan.setAttribute("CLASS", "labels");
                            namespan.setAttribute("STYLE", "left:15px;font-size:13px;")
                            namespan.textContent = "Name: "+name;
                            
                            var typespan = document.createElement("span");
                            typespan.setAttribute("CLASS", "labels");
                            typespan.setAttribute("STYLE", "float:left;font-size:13px;left:3px;")
                            typespan.textContent = "Type: "+type;
                            
                            var outerdiv = document.createElement("div");
                            outerdiv.setAttribute("STYLE", "width:275px;");
                            outerdiv.setAttribute("ID", addID);
                            
                            // functions
                            var overstring = "showTooltip(event, '"+newid+"')"
                            var movestring = "moveTooltip(event, '"+newid+"')"
                            var outstring = "hideTooltip(event, '"+newid+"')"
                            
                            var containerdiv = document.createElement("div");
                            containerdiv.setAttribute('ID', outerid);
                            
                            // create miniviewport
                            var viewdiv = document.createElement("div");
                            viewdiv.setAttribute('ID', viewid);
                            viewdiv.setAttribute('CLASS', 'miniviewport');
                                var minimg = document.createElement("img");
                                minimg.setAttribute('SRC', img);
                                var miniID = "viewimg"+outerid;
                                minimg.setAttribute('ID', miniID);
                                minimg.setAttribute('CLASS', 'cropminiimg');
                                minimg.setAttribute('ONMOUSEOVER', overstring);
                                minimg.setAttribute('ONMOUSEMOVE', movestring);
                                minimg.setAttribute('ONMOUSEOUT', outstring);
                            viewdiv.appendChild(minimg);
                                
                            
                            // create tooltip
                            var tooldiv = document.createElement("div");
                            tooldiv.setAttribute('ID', toolid);
                            tooldiv.setAttribute('CLASS', 'tooltip');
                                var toolimg = document.createElement("img");
                                toolimg.setAttribute('SRC', img);
                                toolimg.setAttribute('CLASS', 'toolimg');
                            tooldiv.appendChild(toolimg);
                            
                            containerdiv.appendChild(viewdiv);
                            containerdiv.appendChild(tooldiv);
                            
                            outerdiv.appendChild(containerdiv);
                            
                            var addstring = "addCrop('"+id+"', 'no', '"+user+"', '"+name+"', '"+type+"', '"+role+"', '"+lang+"')";
                            
                            var addbutton = document.createElement("p");
                            addbutton.setAttribute('ID', adderid);
                            addbutton.setAttribute('CLASS', 'button');
                            addbutton.setAttribute('ONCLICK', addstring);
                            addbutton.setAttribute('STYLE', 'position:absolute;left:293px;top:-8px;width:19px;height:15px;');
                                var addImage = document.createElement("IMG");
                                addImage.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/save');
                                addImage.setAttribute('STYLE', 'width:20px;position:relative;top:-2px;');
                                addImage.setAttribute('TITLE', 'Add Image');
                           addbutton.appendChild(addImage);  
                                
                            
                            entrydiv.appendChild(typespan);
                            entrydiv.appendChild(namespan);
                            entrydiv.appendChild(outerdiv);
                            entrydiv.appendChild(addbutton);
                            
                            document.getElementById("existdata").appendChild(entrydiv);
                        }
                        else 
                        {   
                            // user only updates an existing DB- entry
                            $('#loadgif').css('display', 'none');
                            // define ID because of existing elements
                            var outerid = xmlDoc.getElementsByTagName('dataid')[0].childNodes[0].nodeValue;
                            var id = xmlDoc.getElementsByTagName('cropid')[0].childNodes[0].nodeValue;
                                var nspanStyle = "position:relative;float:left;font-size:12px;"
                                var inamespan = document.createElement("span");
                                inamespan.setAttribute('STYLE', nspanStyle);
                                inamespan.setAttribute('CLASS', 'autorlabels');
                                inamespan.textContent = "Image Name: ";
                                
                                var colspanStyle = "position:relative;float:left;font-size:12px;"
                                var colID = "colimage"+outerid;
                                var colspan = document.createElement("span");
                                colspan.setAttribute('STYLE', colspanStyle);
                                colspan.setAttribute('ID', colID);
                                colspan.setAttribute('CLASS', 'autorlabels');
                                colspan.textContent = imagename;
                                
                                var editnameID = "editimage"+outerid;
                                var editnameStyle = "position:relative;top:-4px;float:left;margin:auto;left:-2px;z-index:20;";
                                var editnameClick = "prepareEditCollection('image','"+outerid+"')"
                                var editname = document.createElement("p");
                                editname.setAttribute('ID', editnameID);
                                editname.setAttribute('ONCLICK', editnameClick);
                                editname.setAttribute('STYLE', editnameStyle);
                                    var nameimg = document.createElement("img");
                                        nameimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/button_edit');
                                        nameimg.setAttribute('STYLE', 'width:10px;');
                                        nameimg.setAttribute('TITLE', 'Edit Image Name');
                                editname.appendChild(nameimg);
                                
                                var nameinputID = "fieldimage"+outerid;
                                var nameinput = document.createElement("input");
                                nameinput.setAttribute('STYLE', 'position:relative;float:left;height:20px;width:45px;top:2px;');
                                nameinput.setAttribute('TYPE', 'text');
                                nameinput.setAttribute('ID', nameinputID);
                                
                                var namebuttonID = "saveimage"+outerid;
                                var namebuttonCLICK = "editCollection('image','"+outerid+"', '"+id+"', '"+user+"' , '"+outerid+"', '"+lang+"')";
                                var namebutton = document.createElement("p");
                                namebutton.setAttribute('CLASS', 'button');
                                namebutton.setAttribute('STYLE', 'position:relative;top:-21px;margin-bottom:0px;float:left;text-align:center;line-height: 0.7em;');
                                namebutton.setAttribute('ID', namebuttonID);
                                namebutton.setAttribute('ONCLICK', namebuttonCLICK);
                                namebutton.textContent = "Save";
                                
                                var divename = document.createElement("div");
                                var divenameID = "editorimage"+outerid;
                                divename.setAttribute('STYLE', 'display:none;');
                                divename.setAttribute('ID', divenameID);
                                divename.appendChild(nameinput);
                                divename.appendChild(namebutton);
                                
                                var charterspan = document.createElement("span");
                                charterspan.setAttribute('CLASS', 'autorlabels');
                                charterspan.setAttribute('STYLE', 'position:relative;float:left;font-size:12px;');
                                charterspan.textContent = "Charter: ";
                                
                                var chartertext = document.createElement("span");
                                chartertext.setAttribute('CLASS', 'autorlabels');
                                chartertext.setAttribute('STYLE', 'position:relative;float:left;top:-2px;');
                                    var atag = document.createElement("a");
                                    atag.setAttribute('HREF', url);
                                    atag.setAttribute('STYLE', "font-size:12px;");
                                    var slashindex = url.lastIndexOf("/");
                                    atag.textContent = url.substring(slashindex+1);
                                chartertext.appendChild(atag);
                                
                                var inameStyle = "position:relative;float:left;width:100%;";
                                var inamediv = document.createElement("div");
                                inamediv.setAttribute('STYLE', inameStyle);
                                inamediv.appendChild(inamespan);
                                inamediv.appendChild(colspan);
                                inamediv.appendChild(editname);
                                inamediv.appendChild(divename);
                                
                                var charterdiv = document.createElement("div");
                                charterdiv.setAttribute('STYLE', 'position:relative;float:left;width:100%;');
                                charterdiv.appendChild(charterspan);
                                charterdiv.appendChild(chartertext);
                                
                                var aview = document.createElement("a");
                                var aviewID = "url"+outerid;
                                aview.setAttribute('ID', aviewID);
                                aview.setAttribute('HREF', url);
                                    var viewimg = document.createElement("img");
                                    var viewimgID = "cropimgview"+outerid;
                                    viewimg.setAttribute('CLASS', 'cropimg');
                                    viewimg.setAttribute('ID', viewimgID);
                                    viewimg.setAttribute('SRC', img);
                                aview.appendChild(viewimg);
                                
                                var viewportdiv = document.createElement("div");
                                viewportdiv.setAttribute('CLASS', 'cropviewport');
                                viewportdiv.setAttribute('STYLE', 'vertical-align:middle;margin:5%;text-align:center;');
                                viewportdiv.appendChild(aview);
                                
                                var spannote = document.createElement("span");
                                spannote.setAttribute('CLASS', 'autorlabels');
                                spannote.setAttribute('STYLE', 'position:relative;float:left;font-size:12px;');
                                spannote.textContent = "Note :";
                                
                                var colnoteID = "colnote"+outerid;
                                var colnote = document.createElement("span");
                                colnote.setAttribute('CLASS', 'autorlabels'); 
                                colnote.setAttribute('ID', colnoteID); 
                                colnote.setAttribute('STYLE', 'position:relative;float:left;font-size:12px;max-width:250px;');
                                colnote.textContent = imagenote;
                                
                                var editnoteID = "editnote"+outerid;
                                var noteONCLICK = "prepareEditCollection('note','"+outerid+"')";
                                var editnote = document.createElement("p");
                                editnote.setAttribute('ONCLICK', noteONCLICK);
                                editnote.setAttribute('ID', editnoteID);
                                editnote.setAttribute('STYLE', 'position:relative;top:-4px;float:left;margin:auto;left:-2px;z-index:20;');
                                    var noteimg = document.createElement("img");
                                        noteimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/button_edit');
                                        noteimg.setAttribute('STYLE', 'width:10px;');
                                        noteimg.setAttribute('TITLE', 'Edit Note');
                                editnote.appendChild(noteimg);
                                
                                var textareaID = "fieldnote"+outerid;
                                var ntextarea = document.createElement("textarea");
                                ntextarea.setAttribute('STYLE', 'position:relative;float:left;height:20px;width:100px;top:2px;');
                                ntextarea.setAttribute('ID', textareaID);
                                
                                var noteButtonID = "savenote"+outerid;
                                var noteButtonCLICK = "editCollection('note','"+outerid+"', '"+id+"', '"+user+"' , '"+outerid+"', '"+lang+"')";
                                var noteButton = document.createElement("p");
                                noteButton.setAttribute('ID', noteButtonID);
                                noteButton.setAttribute('ONCLICK', noteButtonCLICK);
                                noteButton.setAttribute('CLASS', 'button');
                                noteButton.setAttribute('STYLE', 'position:relative;top:-21px;margin-bottom:0px;float:left;text-align:center;line-height: 0.7em;');
                                noteButton.textContent = "Save";
                                
                                var editornoteID = "editornote"+outerid;
                                var editornote = document.createElement("div"); 
                                editornote.setAttribute('STYLE', 'display:none;');
                                editornote.setAttribute('ID', editornoteID);
                                editornote.appendChild(ntextarea);
                                editornote.appendChild(noteButton);
                                
                                var notediv = document.createElement("div");
                                notediv.setAttribute('STYLE', 'position:relative;float:left;width:100%;');
                                notediv.appendChild(spannote);
                                notediv.appendChild(colnote);
                                notediv.appendChild(editnote);
                                notediv.appendChild(editornote);
                                
                                var relocateButton = document.createElement("p");
                            var relocateCLICK = "prepareRelocate(event, '"+outerid+"', '"+user+"', '"+role+"', '"+lang+"')";
                            relocateButton.setAttribute('STYLE', 'position:relative;float:left;');
                            relocateButton.setAttribute('CLASS', 'button');
                            relocateButton.setAttribute('TITLE', 'Move To');
                            relocateButton.setAttribute('ONCLICK', relocateCLICK);
                                    var relocateimg = document.createElement("img");
                                    relocateimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/move-to');
                                    relocateimg.setAttribute('STYLE', 'width:25px;');
                                    relocateimg.setAttribute('TITLE', 'Move To');
                            relocateButton.appendChild(relocateimg);
                            
                            var deleteButton = document.createElement("p");
                            var deleteCLICK = "deleteData('"+outerid+"', '"+user+"', '"+name+type+id+"', '"+lang+"')";
                            deleteButton.setAttribute('STYLE', 'position:relative;float:left;height:25px;');
                            deleteButton.setAttribute('CLASS', 'button');
                            deleteButton.setAttribute('TITLE', 'Delete Image');
                            deleteButton.setAttribute('ONCLICK', deleteCLICK);
                                    var deleteimg = document.createElement("img");
                                    deleteimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/remove');
                                    deleteimg.setAttribute('STYLE', 'width:20px;position:relative;top:2px;');
                                    deleteimg.setAttribute('TITLE', 'Delete Image');
                            deleteButton.appendChild(deleteimg);
                            
                            var publishButton = document.createElement("p");
                            var publishCLICK = "preparePublish(event, '"+outerid+"', '"+user+"', '"+name+"', '"+type+"', '"+id+"', '"+role+"', '"+lang+"');";
                            publishButton.setAttribute('STYLE', 'position:relative;float:left;height:25px;');
                            publishButton.setAttribute('CLASS', 'button');
                            publishButton.setAttribute('TITLE', 'Publish Image');
                            publishButton.setAttribute('ONCLICK', publishCLICK);
                                    var publishimg = document.createElement("img");
                                    publishimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/export');
                                    publishimg.setAttribute('STYLE', 'width:20px;position:relative;top:2px;');
                                    publishimg.setAttribute('TITLE', 'Publish Image');
                            publishButton.appendChild(publishimg);
                            
                            var sendButton = document.createElement("p");
                            var sendCLICK = "prepareSend(event, '"+outerid+"', '"+user+"', '"+lang+"');";
                            sendButton.setAttribute('STYLE', 'position:relative;float:left;height:25px;');
                            sendButton.setAttribute('CLASS', 'button');
                            sendButton.setAttribute('TITLE', 'Send To');
                            sendButton.setAttribute('ONCLICK', sendCLICK);
                                    var sendimg = document.createElement("img");
                                    sendimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/mail');
                                    sendimg.setAttribute('STYLE', 'width:25px;position:relative;left:1px;');
                                    sendimg.setAttribute('TITLE', 'Send To');
                            sendButton.appendChild(sendimg);
                            
                            var buttonDiv = document.createElement("div");
                            buttonDiv.setAttribute('STYLE', 'position:relative;left:30px;width:190px;');
                            buttonDiv.appendChild(relocateButton);
                            buttonDiv.appendChild(deleteButton);
                            buttonDiv.appendChild(publishButton);
                            buttonDiv.appendChild(sendButton);
                                
                                var basicID = 'type'+outerid;
                                var basicStyle = "float:left;height:100%;max-height:430px;width:230px;overflow:auto;border:solid rgb(240,243,226) 1px;margin:3px;";
                                var basicdiv = document.createElement("div");
                                basicdiv.setAttribute('ID', basicID);
                                basicdiv.setAttribute('STYLE', basicStyle);
                                basicdiv.appendChild(inamediv); 
                                basicdiv.appendChild(charterdiv); 
                                basicdiv.appendChild(viewportdiv);
                                basicdiv.appendChild(notediv);
                                basicdiv.appendChild(buttonDiv);
                                
                                var entryid = "annotable"+name+type+id;
                                document.getElementById(entryid).appendChild(basicdiv);
                                alert(geti18nText(lang, 'data-have-been-successful-updated'));
                                }
                            var newid = Math.floor((Math.random()*1000)+500)+Math.floor((Math.random()*1000)+500);
                            var viewid = 'view'+newid;
                            var toolid = 'tool'+newid;
                            var addid = '#add'+id;
                            
                            
                            // functions
                            var overstring = "showTooltip(event, '"+newid+"')"
                            var movestring = "moveTooltip(event, '"+newid+"')"
                            var outstring = "hideTooltip(event, '"+newid+"')"
                            
                            var outerdiv = document.createElement("div");
                            outerdiv.setAttribute('ID', outerid);
                            
                            // create miniviewport
                            var viewdiv = document.createElement("div");
                            viewdiv.setAttribute('ID', viewid);
                            viewdiv.setAttribute('CLASS', 'miniviewport');
                                var minimg = document.createElement("img");
                                var miniID = "viewimg"+outerid;
                                minimg.setAttribute('ID', miniID);
                                minimg.setAttribute('SRC', img);
                                minimg.setAttribute('CLASS', 'cropminiimg');
                                minimg.setAttribute('ONMOUSEOVER', overstring);
                                minimg.setAttribute('ONMOUSEMOVE', movestring);
                                minimg.setAttribute('ONMOUSEOUT', outstring);
                            viewdiv.appendChild(minimg);
                                
                            
                            // create tooltip
                            var tooldiv = document.createElement("div");
                            tooldiv.setAttribute('ID', toolid);
                            tooldiv.setAttribute('CLASS', 'tooltip');
                                var toolimg = document.createElement("img");
                                toolimg.setAttribute('SRC', img);
                                toolimg.setAttribute('CLASS', 'toolimg');
                            tooldiv.appendChild(toolimg);
                            
                            outerdiv.appendChild(viewdiv);
                            outerdiv.appendChild(tooldiv);
                            
                            document.getElementById(addID).appendChild(outerdiv);
                            
                        error = 0;
                     }
                 else
                     {
                     error++;
                     if(error < 20)
                       storeCrop(url, user, role, lang);
                     else
                       {
                       $('#loadgif').css('display', 'none');
                       document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                       error = 0;
                       }
                     }
                }
           else { 
                    $('#process-img').css('display', 'block');
                    $('#loading').css('display', 'block');
                    $('#result').css('display', 'none');
                    document.getElementById("loadtext").innerHTML = geti18nText(lang, 'saving-data');
                    }
             };
            xmlhttp.send(parameters);
            }
            }
    }

// prepare the relocation of a cropped image 
function prepareRelocate(e, dataid, user, role, lang){
    x = e.pageX;
    y = e.pageY;
    $("#relBobble").css('display', 'block');
    $("#relBobble").css({'top': y - 410,'left': x - 440});
    var relocateString = "relocate('"+dataid+"', '"+user+"', '"+role+"','"+lang+"')";
    document.getElementById("relAdjust").setAttribute("ONCLICK", relocateString);
}

// relocate a cropped image
function relocate(dataid, user, role, lang){
    var typeindex = document.getElementById("reltypelist").selectedIndex;
    var type = document.getElementById("reltypelist").options[typeindex].text;
    var nameindex = document.getElementById("relnamelist").selectedIndex;
    var name = document.getElementById("relnamelist").options[nameindex].text;
    var id = document.getElementById("relnamelist").options[nameindex].value;
    var xmlhttp;
    if(type == "" || name == "")
        alert(geti18nText(lang, 'select-type-or-name'));
    else
        {
        var parameters = "dataid="+dataid+"?!";
        if (window.XMLHttpRequest)
                {// code for IE7+, Firefox, Chrome, Opera, Safari
                    xmlhttp=new XMLHttpRequest();
                }
        else if (window.ActiveXObject) { // IE
                try {
                    http_request = new ActiveXObject("Msxml2.XMLHTTP");
                } catch (e) {
                    try {
                        http_request = new ActiveXObject("Microsoft.XMLHTTP");
                    } catch (e) {}
                }
                }
       xmlhttp.open("POST","service/crop?type=relocate&amp;id="+id+"&amp;user="+user+"",true);
       xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
       xmlhttp.onreadystatechange=function(){
            if (xmlhttp.readyState==4)
                {
                if (xmlhttp.status==200)
                    {
                    var xmlDoc = xmlhttp.responseXML;
                    var typeid = "type"+dataid;
                    var oldnote = "colnote"+dataid;
                    var oldname = "colimage"+dataid;
                    var oldimg = "cropimgview"+dataid;
                    var oldurl = "url"+dataid;
                    var miniID = 'viewimg'+dataid;
                    if (document.getElementById(miniID) != null)
                        {
                        miniold = document.getElementById(miniID).parentNode.parentNode;
                        miniold.parentNode.removeChild(miniold);
                        }
                    var imagename =  document.getElementById(oldname).textContent;
                    var imagenote = document.getElementById(oldnote).textContent;
                    var img = document.getElementById(oldimg).getAttribute("SRC");
                    var url = document.getElementById(oldurl).getAttribute("HREF");
                    var outerid = xmlDoc.getElementsByTagName('dataid')[0].childNodes[0].nodeValue;
                    id = xmlDoc.getElementsByTagName('cropid')[0].childNodes[0].nodeValue;
                    var newid = Math.floor((Math.random()*1000)+500)+Math.floor((Math.random()*1000)+500);
                    
                            var nspanStyle = "position:relative;float:left;font-size:12px;"
                            var inamespan = document.createElement("span");
                            inamespan.setAttribute('STYLE', nspanStyle);
                            inamespan.setAttribute('CLASS', 'autorlabels');
                            inamespan.textContent = "Image Name: ";
                            
                            var colspanStyle = "position:relative;float:left;font-size:12px;"
                            var colID = "colimage"+outerid;
                            var colspan = document.createElement("span");
                            colspan.setAttribute('STYLE', colspanStyle);
                            colspan.setAttribute('ID', colID);
                            colspan.setAttribute('CLASS', 'autorlabels');
                            colspan.textContent = imagename;
                            
                            var editnameID = "editimage"+outerid;
                            var editnameStyle = "position:relative;top:-4px;float:left;margin:auto;left:-2px;z-index:20;";
                            var editnameClick = "prepareEditCollection('image','"+outerid+"')"
                            var editname = document.createElement("p");
                            editname.setAttribute('ID', editnameID);
                            editname.setAttribute('ONCLICK', editnameClick);
                            editname.setAttribute('STYLE', editnameStyle);
                                var nameimg = document.createElement("img");
                                    nameimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/button_edit');
                                    nameimg.setAttribute('STYLE', 'width:10px;');
                                    nameimg.setAttribute('TITLE', 'Edit Image Name');
                            editname.appendChild(nameimg);
                            
                            var nameinputID = "fieldimage"+outerid;
                            var nameinput = document.createElement("input");
                            nameinput.setAttribute('STYLE', 'position:relative;float:left;height:20px;width:45px;top:2px;');
                            nameinput.setAttribute('TYPE', 'text');
                            nameinput.setAttribute('ID', nameinputID);
                            miniID
                            var namebuttonID = "saveimage"+outerid;
                            var namebuttonCLICK = "editCollection('image','"+outerid+"', '"+id+"', '"+user+"' , '"+outerid+"', '"+lang+"')";
                            var namebutton = document.createElement("p");
                            namebutton.setAttribute('CLASS', 'button');
                            namebutton.setAttribute('STYLE', 'position:relative;top:-21px;margin-bottom:0px;float:left;text-align:center;line-height: 0.7em;');
                            namebutton.setAttribute('ID', namebuttonID);
                            namebutton.setAttribute('ONCLICK', namebuttonCLICK);
                            namebutton.textContent = "Save";
                            
                            var divename = document.createElement("div");
                            var divenameID = "editorimage"+outerid;
                            divename.setAttribute('STYLE', 'display:none;');
                            divename.setAttribute('ID', divenameID);
                            divename.appendChild(nameinput);
                            divename.appendChild(namebutton);
                            
                            var charterspan = document.createElement("span");
                            charterspan.setAttribute('CLASS', 'autorlabels');
                            charterspan.setAttribute('STYLE', 'position:relative;float:left;font-size:12px;');
                            charterspan.textContent = "Charter: ";
                            
                            var chartertext = document.createElement("span");
                            chartertext.setAttribute('CLASS', 'autorlabels');
                            chartertext.setAttribute('STYLE', 'position:relative;float:left;top:-2px;');
                                var atag = document.createElement("a");
                                atag.setAttribute('HREF', url);
                                atag.setAttribute('STYLE', "font-size:12px;");
                                var slashindex = url.lastIndexOf("/");
                                atag.textContent = url.substring(slashindex+1);
                            chartertext.appendChild(atag);
                            
                            var inameStyle = "position:relative;float:left;width:100%;";
                            var inamediv = document.createElement("div");
                            inamediv.setAttribute('STYLE', inameStyle);
                            inamediv.appendChild(inamespan);
                            inamediv.appendChild(colspan);
                            inamediv.appendChild(editname);
                            inamediv.appendChild(divename);
                            
                            var charterdiv = document.createElement("div");
                            charterdiv.setAttribute('STYLE', 'position:relative;float:left;width:100%;');
                            charterdiv.appendChild(charterspan);
                            charterdiv.appendChild(chartertext);
                            
                            var aview = document.createElement("a");
                            var aviewID = "url"+outerid;
                            aview.setAttribute('ID', aviewID);
                            aview.setAttribute('HREF', url);
                                var viewimg = document.createElement("img");
                                var viewimgID = "cropimgview"+outerid;
                                viewimg.setAttribute('CLASS', 'cropimg');
                                viewimg.setAttribute('ID', viewimgID);
                                viewimg.setAttribute('SRC', img);
                            aview.appendChild(viewimg);
                            
                            var viewportdiv = document.createElement("div");
                            viewportdiv.setAttribute('CLASS', 'cropviewport');
                            viewportdiv.setAttribute('STYLE', 'vertical-align:middle;margin:5%;text-align:center;');
                            viewportdiv.appendChild(aview);
                            
                            var spannote = document.createElement("span");
                            spannote.setAttribute('CLASS', 'autorlabels');
                            spannote.setAttribute('STYLE', 'position:relative;float:left;font-size:12px;');
                            spannote.textContent = "Note :";
                            
                            var colnoteID = "colnote"+outerid;
                            var colnote = document.createElement("span");
                            colnote.setAttribute('CLASS', 'autorlabels'); 
                            colnote.setAttribute('ID', colnoteID); 
                            colnote.setAttribute('STYLE', 'position:relative;float:left;font-size:12px;max-width:250px;');
                            colnote.textContent = imagenote;
                            
                            var editnoteID = "editnote"+outerid;
                            var noteONCLICK = "prepareEditCollection('note','"+outerid+"')";
                            var editnote = document.createElement("p");
                            editnote.setAttribute('ONCLICK', noteONCLICK);
                            editnote.setAttribute('ID', editnoteID);
                            editnote.setAttribute('STYLE', 'position:relative;top:-4px;float:left;margin:auto;left:-2px;z-index:20;');
                                var noteimg = document.createElement("img");
                                    noteimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/button_edit');
                                    noteimg.setAttribute('STYLE', 'width:10px;');
                                    noteimg.setAttribute('TITLE', 'Edit Note');
                            editnote.appendChild(noteimg);
                            
                            var textareaID = "fieldnote"+outerid;
                            var ntextarea = document.createElement("textarea");
                            ntextarea.setAttribute('STYLE', 'position:relative;float:left;height:20px;width:100px;top:2px;');
                            ntextarea.setAttribute('ID', textareaID);
                            
                            var noteButtonID = "savenote"+outerid;
                            var noteButtonCLICK = "editCollection('note','"+outerid+"', '"+id+"', '"+user+"' , '"+outerid+"', '"+lang+"')";
                            var noteButton = document.createElement("p");
                            noteButton.setAttribute('ID', noteButtonID);
                            noteButton.setAttribute('ONCLICK', noteButtonCLICK);
                            noteButton.setAttribute('CLASS', 'button');
                            noteButton.setAttribute('STYLE', 'position:relative;top:-21px;margin-bottom:0px;float:left;text-align:center;line-height: 0.7em;');
                            noteButton.textContent = "Save";
                            
                            var editornoteID = "editornote"+outerid;
                            var editornote = document.createElement("div"); 
                            editornote.setAttribute('STYLE', 'display:none;');
                            editornote.setAttribute('ID', editornoteID);
                            editornote.appendChild(ntextarea);
                            editornote.appendChild(noteButton);
                            
                            var notediv = document.createElement("div");
                            notediv.setAttribute('STYLE', 'position:relative;float:left;width:100%;');
                            notediv.appendChild(spannote);
                            notediv.appendChild(colnote);
                            notediv.appendChild(editnote);
                            notediv.appendChild(editornote);
                            
                            var relocateButton = document.createElement("p");
                            var relocateCLICK = "prepareRelocate(event, '"+outerid+"', '"+user+"', '"+role+"','"+lang+"')";
                            relocateButton.setAttribute('STYLE', 'position:relative;float:left;');
                            relocateButton.setAttribute('CLASS', 'button');
                            relocateButton.setAttribute('TITLE', 'Move To');
                            relocateButton.setAttribute('ONCLICK', relocateCLICK);
                                    var relocateimg = document.createElement("img");
                                    relocateimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/move-to');
                                    relocateimg.setAttribute('STYLE', 'width:25px;');
                                    relocateimg.setAttribute('TITLE', 'Move To');
                            relocateButton.appendChild(relocateimg);
                            
                            var deleteButton = document.createElement("p");
                            var deleteCLICK = "deleteData('"+outerid+"', '"+user+"', '"+name+type+id+"', '"+lang+"')";
                            deleteButton.setAttribute('STYLE', 'position:relative;float:left;height:25px;');
                            deleteButton.setAttribute('CLASS', 'button');
                            deleteButton.setAttribute('TITLE', 'Delete Image');
                            deleteButton.setAttribute('ONCLICK', deleteCLICK);
                                    var deleteimg = document.createElement("img");
                                    deleteimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/remove');
                                    deleteimg.setAttribute('STYLE', 'width:20px;position:relative;top:2px;');
                                    deleteimg.setAttribute('TITLE', 'Delete Image');
                            deleteButton.appendChild(deleteimg);
                            
                            var publishButton = document.createElement("p");
                            var publishCLICK = "preparePublish(event, '"+outerid+"', '"+user+"', '"+name+"', '"+type+"', '"+id+"', '"+role+"','"+lang+"');";
                            publishButton.setAttribute('STYLE', 'position:relative;float:left;height:25px;');
                            publishButton.setAttribute('CLASS', 'button');
                            publishButton.setAttribute('TITLE', 'Publish Image');
                            publishButton.setAttribute('ONCLICK', publishCLICK);
                                    var publishimg = document.createElement("img");
                                    publishimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/export');
                                    publishimg.setAttribute('STYLE', 'width:20px;position:relative;top:2px;');
                                    publishimg.setAttribute('TITLE', 'Publish Image');
                            publishButton.appendChild(publishimg);
                            
                            var sendButton = document.createElement("p");
                            var sendCLICK = "prepareSend(event, '"+outerid+"', '"+user+"', '"+lang+"');";
                            sendButton.setAttribute('STYLE', 'position:relative;float:left;height:25px;');
                            sendButton.setAttribute('CLASS', 'button');
                            sendButton.setAttribute('TITLE', 'Send To');
                            sendButton.setAttribute('ONCLICK', sendCLICK);
                                    var sendimg = document.createElement("img");
                                    sendimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/mail');
                                    sendimg.setAttribute('STYLE', 'width:25px;position:relative;left:1px;');
                                    sendimg.setAttribute('TITLE', 'Send To');
                            sendButton.appendChild(sendimg);
                            
                            var buttonDiv = document.createElement("div");
                            buttonDiv.setAttribute('STYLE', 'position:relative;left:30px;width:190px;');
                            buttonDiv.appendChild(relocateButton);
                            buttonDiv.appendChild(deleteButton);
                            buttonDiv.appendChild(publishButton);
                            buttonDiv.appendChild(sendButton);
                            
                            var basicID = 'type'+outerid;
                            var basicStyle = "float:left;height:100%;max-height:430px;width:230px;overflow:auto;border:solid rgb(240,243,226) 1px;margin:3px;";
                            var basicdiv = document.createElement("div");
                            basicdiv.setAttribute('ID', basicID);
                            basicdiv.setAttribute('STYLE', basicStyle);
                            basicdiv.appendChild(inamediv); 
                            basicdiv.appendChild(charterdiv); 
                            basicdiv.appendChild(viewportdiv);
                            basicdiv.appendChild(notediv);
                            basicdiv.appendChild(buttonDiv);
                            
                    var entryid = "annotable"+name+type+id;
                    document.getElementById(entryid).appendChild(basicdiv);
                    told = document.getElementById(typeid);
                    told.parentNode.removeChild(told);
                    $('#relBobble').css('display', 'none');
                    
                    var viewid = 'view'+newid;
                    var toolid = 'tool'+newid;
                    var outerdiv = document.createElement("div");
                    // functions
                    var overstring = "showTooltip(event, '"+newid+"')"
                    var movestring = "moveTooltip(event, '"+newid+"')"
                    var outstring = "hideTooltip(event, '"+newid+"')"                    
                    
                    // create miniviewport
                    var viewdiv = document.createElement("div");
                    viewdiv.setAttribute('ID', viewid);
                    viewdiv.setAttribute('CLASS', 'miniviewport');
                                var minimg = document.createElement("img");
                                var minimgID = "viewimg"+outerid;
                                minimg.setAttribute('SRC', img);
                                minimg.setAttribute('CLASS', 'cropminiimg');
                                minimg.setAttribute('ID', minimgID);
                                minimg.setAttribute('ONMOUSEOVER', overstring);
                                minimg.setAttribute('ONMOUSEMOVE', movestring);
                                minimg.setAttribute('ONMOUSEOUT', outstring);
                   viewdiv.appendChild(minimg);
                                
                   // create tooltip
                   var tooldiv = document.createElement("div");
                   tooldiv.setAttribute('ID', toolid);
                   tooldiv.setAttribute('CLASS', 'tooltip');
                                var toolimg = document.createElement("img");
                                toolimg.setAttribute('SRC', img);
                                toolimg.setAttribute('CLASS', 'toolimg');
                   tooldiv.appendChild(toolimg);
                            
                   outerdiv.appendChild(viewdiv);
                   outerdiv.appendChild(tooldiv);
                   var addID = type+name+id;
                   document.getElementById(addID).appendChild(outerdiv);
                    
                    
                    error = 0;
                    }
                else
                     {
                     error++;
                     if(error < 20)
                       relocate(id, user, role, lang);
                     else
                       {
                       document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                       $("#loadtext").css('display', 'block');
                       error = 0;
                       }
                     }
                }
       }
       xmlhttp.send(parameters);
       }
       
}

// start editing process of names or types
function prepareEditCollection(typus, number){
    var buttonID = '#edit'+typus+number;
    var QtextID = '#col'+typus+number;
    var textID = 'col'+typus+number;
    var editID = '#editor'+typus+number;
    var fieldID = 'field'+typus+number;
    $(buttonID).css('display','none');
    $(QtextID).css('display','none');
    document.getElementById(fieldID).value = document.getElementById(textID).textContent;
    $(editID).css('display','block');
}

// edit collection name or type
function editCollection(typus, number, id, user, dataid, lang){
    var fieldID = 'field'+typus+number;
    var newtext = document.getElementById(fieldID).value;
    if(typus=="type")
        var parameters = "type="+newtext+"?!";
    else if(typus=="name")
        var parameters = "name="+newtext+"?!";
    else if(typus=="image")
        var parameters = "imagename="+newtext+"?!dataid="+dataid+"?!"; 
    else
        var parameters = "dataid="+dataid+"?!imagenote="+newtext;    
    var xmlhttp;
    if (window.XMLHttpRequest)
            {// code for IE7+, Firefox, Chrome, Opera, Safari
                xmlhttp=new XMLHttpRequest();
            }
    else
            {// code for IE6, IE5
                xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
            }
    xmlhttp.open("POST","service/crop?type=editCollection&amp;functype="+typus+"&amp;id="+id+"&amp;user="+user,true);
    xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
    xmlhttp.onreadystatechange=function(){
    if (xmlhttp.readyState==4)
          {
           if (xmlhttp.status==200)
                 {
                    var buttonID = '#edit'+typus+number;
                    var QtextID = '#col'+typus+number;
                    var textID = 'col'+typus+number;
                    var editID = '#editor'+typus+number;
                    $(buttonID).css('display','block');
                    $(QtextID).css('display','block');
                    document.getElementById(textID).textContent = newtext;
                    $(editID).css('display','none');
                    if(typus=="type")
                        {
                        var typeoptions = document.getElementById("typelistleft").options;
                        var found = false;
                        for(i=0;i<typeoptions.length;i++)
                            {
                            if(typeoptions[i].text == newtext)
                                found=true;
                            }
                        if(found==false)
                            {
                            var leftoption = document.createElement("option");
                                leftoption.textContent = newtext;
                                document.getElementById("typelistleft").appendChild(leftoption);
                                
                            var rightoption = document.createElement("option");
                                rightoption.textContent = newtext;
                                document.getElementById("typelistright").appendChild(rightoption); 
                            
                            var reloption = document.createElement("option");
                                reloption.textContent = newtext;
                                document.getElementById("reltypelist").appendChild(reloption);
                            }
                        }
                    else if(typus=="name")
                        {
                        var nid = 'savename'+id;
                        document.getElementById(nid).innerHTML = newtext;
                        }
                 }
             else
                 {
                 error++;
                 if(error < 20)
                   editCollection(typus, number, id, user, dataid, lang);
                 else
                   {
                   $('#loadgif').css('display', 'none');
                   document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                   error = 0;
                   }
                 }
            }
       }
     xmlhttp.send(parameters);
}

// publish a cropped image collection
function publishCrop(id, user, oldname, oldtype, cropid, role, lang){
    var imgID = "cropimgview"+id;
    var urlID = "url"+id;
    
    var imagename = $('#publishnametext').val();
    var imagenote = $('#publishnotetext').val();
    var type = $('#pubtypetext').val();
    var name = $('#pubnametext').val();
    var url = document.getElementById(urlID).getAttribute("HREF");
    var img = document.getElementById(imgID).getAttribute("SRC");
    
    if( img != null)
            {
            var parameters = "img="+img+"?!url="+url+"?!name="+name+"?!type="+type+"?!imagename="+imagename+"?!imagenote="+imagenote;
            // check for the user's input
            if (name == '' || type == '')
                {
                alert(geti18nText(lang, 'insert-type-or-name'));
                }
            else
            {
            // send request to crop script
            var xmlhttp;
            if (window.XMLHttpRequest)
                {// code for IE7+, Firefox, Chrome, Opera, Safari
                    xmlhttp=new XMLHttpRequest();
                }
            else
                {// code for IE6, IE5
                    xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
                } 
          if(role == "moderator")
            {           
            xmlhttp.open("POST","service/publish-cropimages?type=publishNewMod&amp;user="+user+"&amp;id="+id,true);
            }
          else
            {
            xmlhttp.open("POST","service/publish-cropimages?type=AskNewData&amp;user="+user+"&amp;id="+id,true);
            }
            xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
            xmlhttp.onreadystatechange=function(){
            if (xmlhttp.readyState==4)
                {
                 if (xmlhttp.status==200)
                     { 
                     var breadcrump = document.createElement("div");
                     breadcrump.innerHTML = xmlhttp.responseText;
                     var outerid = breadcrump.childNodes[0].childNodes[1].childNodes[0].nodeValue;
                     
                     if(role == "user")
                            {      
                            // add new cropped image
                            var nspanStyle = "position:relative;float:left;font-size:12px;"
                            var inamespan = document.createElement("span");
                            inamespan.setAttribute('STYLE', nspanStyle);
                            inamespan.setAttribute('CLASS', 'autorlabels');
                            inamespan.textContent = "Image Name: ";
                            
                            var colspanStyle = "position:relative;float:left;font-size:12px;"
                            var colID = "colimage"+outerid;
                            var colspan = document.createElement("span");
                            colspan.setAttribute('STYLE', colspanStyle);
                            colspan.setAttribute('ID', colID);
                            colspan.setAttribute('CLASS', 'autorlabels');
                            colspan.textContent = imagename;
                            
                            var editnameID = "editimage"+outerid;
                            var editnameStyle = "position:relative;top:-4px;float:left;margin:auto;left:-2px;z-index:20;";
                            var editnameClick = "prepareEditCollection('image','"+outerid+"')"
                            var editname = document.createElement("p");
                            editname.setAttribute('ID', editnameID);
                            editname.setAttribute('ONCLICK', editnameClick);
                            editname.setAttribute('STYLE', editnameStyle);
                                var nameimg = document.createElement("img");
                                    nameimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/button_edit');
                                    nameimg.setAttribute('STYLE', 'width:10px;');
                                    nameimg.setAttribute('TITLE', 'Edit Image Name');
                            editname.appendChild(nameimg);
                            
                            var nameinputID = "fieldimage"+outerid;
                            var nameinput = document.createElement("input");
                            nameinput.setAttribute('STYLE', 'position:relative;float:left;height:20px;width:45px;top:2px;');
                            nameinput.setAttribute('TYPE', 'text');
                            nameinput.setAttribute('ID', nameinputID);
                            
                            var namebuttonID = "saveimage"+outerid;
                            var namebuttonCLICK = "editCollection('image','"+outerid+"', '"+id+"', '"+user+"' , '"+outerid+"', '"+lang+"')";
                            var namebutton = document.createElement("p");
                            namebutton.setAttribute('CLASS', 'button');
                            namebutton.setAttribute('STYLE', 'position:relative;top:-21px;margin-bottom:0px;float:left;text-align:center;line-height: 0.7em;');
                            namebutton.setAttribute('ID', namebuttonID);
                            namebutton.setAttribute('ONCLICK', namebuttonCLICK);
                            namebutton.textContent = "Save";
                            
                            var divename = document.createElement("div");
                            var divenameID = "editorimage"+outerid;
                            divename.setAttribute('STYLE', 'display:none;');
                            divename.setAttribute('ID', divenameID);
                            divename.appendChild(nameinput);
                            divename.appendChild(namebutton);
                            
                            var charterspan = document.createElement("span");
                            charterspan.setAttribute('CLASS', 'autorlabels');
                            charterspan.setAttribute('STYLE', 'position:relative;float:left;font-size:12px;');
                            charterspan.textContent = "Charter: ";
                            
                            var chartertext = document.createElement("span");
                            chartertext.setAttribute('CLASS', 'autorlabels');
                            chartertext.setAttribute('STYLE', 'position:relative;float:left;top:-2px;');
                                var atag = document.createElement("a");
                                atag.setAttribute('HREF', url);
                                atag.setAttribute('STYLE', "font-size:12px;");
                                var slashindex = url.lastIndexOf("/");
                                atag.textContent = url.substring(slashindex+1);
                            chartertext.appendChild(atag);
                            
                            var inameStyle = "position:relative;float:left;width:100%;";
                            var inamediv = document.createElement("div");
                            inamediv.setAttribute('STYLE', inameStyle);
                            inamediv.appendChild(inamespan);
                            inamediv.appendChild(colspan);
                            inamediv.appendChild(editname);
                            inamediv.appendChild(divename);
                            
                            var charterdiv = document.createElement("div");
                            charterdiv.setAttribute('STYLE', 'position:relative;float:left;width:100%;');
                            charterdiv.appendChild(charterspan);
                            charterdiv.appendChild(chartertext);
                            
                            var aview = document.createElement("a");
                            var aviewID = "url"+outerid;
                            aview.setAttribute('ID', aviewID);
                            aview.setAttribute('HREF', url);
                                var viewimg = document.createElement("img");
                                var viewimgID = "cropimgview"+outerid;
                                viewimg.setAttribute('CLASS', 'cropimg');
                                viewimg.setAttribute('ID', viewimgID);
                                viewimg.setAttribute('SRC', img);
                            aview.appendChild(viewimg);
                            
                            var viewportdiv = document.createElement("div");
                            viewportdiv.setAttribute('CLASS', 'cropviewport');
                            viewportdiv.setAttribute('STYLE', 'vertical-align:middle;margin:5%;text-align:center;');
                            viewportdiv.appendChild(aview);
                            
                            var spannote = document.createElement("span");
                            spannote.setAttribute('CLASS', 'autorlabels');
                            spannote.setAttribute('STYLE', 'position:relative;float:left;font-size:12px;');
                            spannote.textContent = "Note :";
                            
                            var colnoteID = "colnote"+outerid;
                            var colnote = document.createElement("span");
                            colnote.setAttribute('CLASS', 'autorlabels'); 
                            colnote.setAttribute('ID', colnoteID); 
                            colnote.setAttribute('STYLE', 'position:relative;float:left;font-size:12px;max-width:250px;');
                            colnote.textContent = imagenote;
                            
                            var editnoteID = "editnote"+outerid;
                            var noteONCLICK = "prepareEditCollection('note','"+outerid+"')";
                            var editnote = document.createElement("p");
                            editnote.setAttribute('ONCLICK', noteONCLICK);
                            editnote.setAttribute('ID', editnoteID);
                            editnote.setAttribute('STYLE', 'position:relative;top:-4px;float:left;margin:auto;left:-2px;z-index:20;');
                                var noteimg = document.createElement("img");
                                    noteimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/button_edit');
                                    noteimg.setAttribute('STYLE', 'width:10px;');
                                    noteimg.setAttribute('TITLE', 'Edit Note');
                            editnote.appendChild(noteimg);
                            
                            var textareaID = "fieldnote"+outerid;
                            var ntextarea = document.createElement("textarea");
                            ntextarea.setAttribute('STYLE', 'position:relative;float:left;height:20px;width:100px;top:2px;');
                            ntextarea.setAttribute('ID', textareaID);
                            
                            var noteButtonID = "savenote"+outerid;
                            var noteButtonCLICK = "editCollection('note','"+outerid+"', '"+id+"', '"+user+"' , '"+outerid+"', '"+lang+"')";
                            var noteButton = document.createElement("p");
                            noteButton.setAttribute('ID', noteButtonID);
                            noteButton.setAttribute('ONCLICK', noteButtonCLICK);
                            noteButton.setAttribute('CLASS', 'button');
                            noteButton.setAttribute('STYLE', 'position:relative;top:-21px;margin-bottom:0px;float:left;text-align:center;line-height: 0.7em;');
                            noteButton.textContent = "Save";
                            
                            var editornoteID = "editornote"+outerid;
                            var editornote = document.createElement("div"); 
                            editornote.setAttribute('STYLE', 'display:none;');
                            editornote.setAttribute('ID', editornoteID);
                            editornote.appendChild(ntextarea);
                            editornote.appendChild(noteButton);
                            
                            var notediv = document.createElement("div");
                            notediv.setAttribute('STYLE', 'position:relative;float:left;width:100%;');
                            notediv.appendChild(spannote);
                            notediv.appendChild(colnote);
                            notediv.appendChild(editnote);
                            notediv.appendChild(editornote);
                            
                            var buttonDiv = document.createElement("div");
                            buttonDiv.setAttribute('STYLE', 'position:relative;left:5px;width:240px;');
                                buttonspan = document.createElement("span");
                                buttonspan.setAttribute('CLASS', 'autorlabels'); 
                                buttonspan.setAttribute('STYLE', 'position:relative;float:left;font-size:14px;left:40px;');
                                buttonspan.textContent = "Wait for release!";
                            buttonDiv.appendChild(buttonspan);
                            
                            var basicID = 'type'+outerid;
                            var basicStyle = "float:left;height:100%;max-height:430px;width:230px;overflow:auto;border:solid rgb(240,243,226) 1px;margin:3px;";
                            var basicdiv = document.createElement("div");
                            basicdiv.setAttribute('ID', basicID);
                            basicdiv.setAttribute('STYLE', basicStyle);
                            basicdiv.appendChild(inamediv); 
                            basicdiv.appendChild(charterdiv); 
                            basicdiv.appendChild(viewportdiv);
                            basicdiv.appendChild(notediv);
                            basicdiv.appendChild(buttonDiv);
                            
                            var typeid = "type"+id;
                            told = document.getElementById(typeid);
                            told.parentNode.removeChild(told);
                            var entryid = oldname+oldtype+cropid;
                            document.getElementById(entryid).childNodes[1].appendChild(basicdiv);
                            }
   
                     $('#publishBobble').css('display', 'none');                             
                     error = 0;
                     }
                 else
                     {
                     error++;
                     if(error < 20)
                       publishCrop(id, user, oldname, oldtype, cropid, role, lang);
                     else
                       {
                       document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                       error = 0;
                       }
                     }
                }
             };
            xmlhttp.send(parameters);
        }
    }
}

// publish a single cropped image
function publishSingleCrop(id, user, name, type, role, lang){
    var imagename = $('#publishnametext').val();
    var imagenote = $('#publishnotetext').val();
    var imgID = 'cropimgview'+singleID;
    var urlID = 'url'+singleID;
    var img = document.getElementById(imgID).getAttribute("SRC");
    var url = document.getElementById(urlID).getAttribute("HREF");
    if( img != null)
        {
        var parameters = "img="+img+"?!url="+url+"?!name="+name+"?!type="+type+"?!imagename="+imagename+"?!imagenote="+imagenote;
        // send request to crop script
        var xmlhttp;
        if (window.XMLHttpRequest)
                {// code for IE7+, Firefox, Chrome, Opera, Safari
                    xmlhttp=new XMLHttpRequest();
                }
        else
                {// code for IE6, IE5
                    xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
                }
        if(role == "moderator")
          {
          xmlhttp.open("POST","service/publish-cropimages?type=publishExistMod&amp;user="+user+"&amp;id="+id+"&amp;dataid="+singleID,true);
          }
        else
          {
          xmlhttp.open("POST","service/publish-cropimages?type=AskExistData&amp;user="+user+"&amp;id="+id+"&amp;dataid="+singleID,true);
          }
        xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
        xmlhttp.onreadystatechange=function(){
            if (xmlhttp.readyState==4)
                {
                 if (xmlhttp.status==200)
                     { 
                        var xmlDoc = jQuery.parseXML(xmlhttp.response);
                        // define ID because of existing elements
                        var outerid = xmlDoc.getElementsByTagName('dataid')[0].childNodes[0].nodeValue;
                        var newid = Math.floor((Math.random()*1000)+500)+Math.floor((Math.random()*1000)+500);
                        var viewid = 'view'+newid;
                        var toolid = 'tool'+newid;
                        var addid = '#send'+id;
                        
                        if(role == "user")
                            {
                            // configure buttons
                            $(addid).css('display', 'none');  
                            // add new cropped image
                            var nspanStyle = "position:relative;float:left;font-size:12px;"
                            var inamespan = document.createElement("span");
                            inamespan.setAttribute('STYLE', nspanStyle);
                            inamespan.setAttribute('CLASS', 'autorlabels');
                            inamespan.textContent = "Image Name: ";
                            
                            var colspanStyle = "position:relative;float:left;font-size:12px;"
                            var colID = "colimage"+outerid;
                            var colspan = document.createElement("span");
                            colspan.setAttribute('STYLE', colspanStyle);
                            colspan.setAttribute('ID', colID);
                            colspan.setAttribute('CLASS', 'autorlabels');
                            colspan.textContent = imagename;
                            
                            var editnameID = "editimage"+outerid;
                            var editnameStyle = "position:relative;top:-4px;float:left;margin:auto;left:-2px;z-index:20;";
                            var editnameClick = "prepareEditCollection('image','"+outerid+"')"
                            var editname = document.createElement("p");
                            editname.setAttribute('ID', editnameID);
                            editname.setAttribute('ONCLICK', editnameClick);
                            editname.setAttribute('STYLE', editnameStyle);
                                var nameimg = document.createElement("img");
                                    nameimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/button_edit');
                                    nameimg.setAttribute('STYLE', 'width:10px;');
                                    nameimg.setAttribute('TITLE', 'Edit Image Name');
                            editname.appendChild(nameimg);
                            
                            var nameinputID = "fieldimage"+outerid;
                            var nameinput = document.createElement("input");
                            nameinput.setAttribute('STYLE', 'position:relative;float:left;height:20px;width:45px;top:2px;');
                            nameinput.setAttribute('TYPE', 'text');
                            nameinput.setAttribute('ID', nameinputID);
                            
                            var namebuttonID = "saveimage"+outerid;
                            var namebuttonCLICK = "editCollection('image','"+outerid+"', '"+id+"', '"+user+"' , '"+outerid+"', '"+lang+"')";
                            var namebutton = document.createElement("p");
                            namebutton.setAttribute('CLASS', 'button');
                            namebutton.setAttribute('STYLE', 'position:relative;top:-21px;margin-bottom:0px;float:left;text-align:center;line-height: 0.7em;');
                            namebutton.setAttribute('ID', namebuttonID);
                            namebutton.setAttribute('ONCLICK', namebuttonCLICK);
                            namebutton.textContent = "Save";
                            
                            var divename = document.createElement("div");
                            var divenameID = "editorimage"+outerid;
                            divename.setAttribute('STYLE', 'display:none;');
                            divename.setAttribute('ID', divenameID);
                            divename.appendChild(nameinput);
                            divename.appendChild(namebutton);
                            
                            var charterspan = document.createElement("span");
                            charterspan.setAttribute('CLASS', 'autorlabels');
                            charterspan.setAttribute('STYLE', 'position:relative;float:left;font-size:12px;');
                            charterspan.textContent = "Charter: ";
                            
                            var chartertext = document.createElement("span");
                            chartertext.setAttribute('CLASS', 'autorlabels');
                            chartertext.setAttribute('STYLE', 'position:relative;float:left;top:-2px;');
                                var atag = document.createElement("a");
                                atag.setAttribute('HREF', url);
                                atag.setAttribute('STYLE', "font-size:12px;");
                                var slashindex = url.lastIndexOf("/");
                                atag.textContent = url.substring(slashindex+1);
                            chartertext.appendChild(atag);
                            
                            var inameStyle = "position:relative;float:left;width:100%;";
                            var inamediv = document.createElement("div");
                            inamediv.setAttribute('STYLE', inameStyle);
                            inamediv.appendChild(inamespan);
                            inamediv.appendChild(colspan);
                            inamediv.appendChild(editname);
                            inamediv.appendChild(divename);
                            
                            var charterdiv = document.createElement("div");
                            charterdiv.setAttribute('STYLE', 'position:relative;float:left;width:100%;');
                            charterdiv.appendChild(charterspan);
                            charterdiv.appendChild(chartertext);
                            
                            var aview = document.createElement("a");
                            var aviewID = "url"+outerid;
                            aview.setAttribute('ID', aviewID);
                            aview.setAttribute('HREF', url);
                                var viewimg = document.createElement("img");
                                var viewimgID = "cropimgview"+outerid;
                                viewimg.setAttribute('CLASS', 'cropimg');
                                viewimg.setAttribute('ID', viewimgID);
                                viewimg.setAttribute('SRC', img);
                            aview.appendChild(viewimg);
                            
                            var viewportdiv = document.createElement("div");
                            viewportdiv.setAttribute('CLASS', 'cropviewport');
                            viewportdiv.setAttribute('STYLE', 'vertical-align:middle;margin:5%;text-align:center;');
                            viewportdiv.appendChild(aview);
                            
                            var spannote = document.createElement("span");
                            spannote.setAttribute('CLASS', 'autorlabels');
                            spannote.setAttribute('STYLE', 'position:relative;float:left;font-size:12px;');
                            spannote.textContent = "Note :";
                            
                            var colnoteID = "colnote"+outerid;
                            var colnote = document.createElement("span");
                            colnote.setAttribute('CLASS', 'autorlabels'); 
                            colnote.setAttribute('ID', colnoteID); 
                            colnote.setAttribute('STYLE', 'position:relative;float:left;font-size:12px;max-width:250px;');
                            colnote.textContent = imagenote;
                            
                            var editnoteID = "editnote"+outerid;
                            var noteONCLICK = "prepareEditCollection('note','"+outerid+"')";
                            var editnote = document.createElement("p");
                            editnote.setAttribute('ONCLICK', noteONCLICK);
                            editnote.setAttribute('ID', editnoteID);
                            editnote.setAttribute('STYLE', 'position:relative;top:-4px;float:left;margin:auto;left:-2px;z-index:20;');
                                var noteimg = document.createElement("img");
                                    noteimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/button_edit');
                                    noteimg.setAttribute('STYLE', 'width:10px;');
                                    noteimg.setAttribute('TITLE', 'Edit Note');
                            editnote.appendChild(noteimg);
                            
                            var textareaID = "fieldnote"+outerid;
                            var ntextarea = document.createElement("textarea");
                            ntextarea.setAttribute('STYLE', 'position:relative;float:left;height:20px;width:100px;top:2px;');
                            ntextarea.setAttribute('ID', textareaID);
                            
                            var noteButtonID = "savenote"+outerid;
                            var noteButtonCLICK = "editCollection('note','"+outerid+"', '"+id+"', '"+user+"' , '"+outerid+"', '"+lang+"')";
                            var noteButton = document.createElement("p");
                            noteButton.setAttribute('ID', noteButtonID);
                            noteButton.setAttribute('ONCLICK', noteButtonCLICK);
                            noteButton.setAttribute('CLASS', 'button');
                            noteButton.setAttribute('STYLE', 'position:relative;top:-21px;margin-bottom:0px;float:left;text-align:center;line-height: 0.7em;');
                            noteButton.textContent = "Save";
                            
                            var editornoteID = "editornote"+outerid;
                            var editornote = document.createElement("div"); 
                            editornote.setAttribute('STYLE', 'display:none;');
                            editornote.setAttribute('ID', editornoteID);
                            editornote.appendChild(ntextarea);
                            editornote.appendChild(noteButton);
                            
                            var notediv = document.createElement("div");
                            notediv.setAttribute('STYLE', 'position:relative;float:left;width:100%;');
                            notediv.appendChild(spannote);
                            notediv.appendChild(colnote);
                            notediv.appendChild(editnote);
                            notediv.appendChild(editornote);
                            
                            var buttonDiv = document.createElement("div");
                            buttonDiv.setAttribute('STYLE', 'position:relative;left:5px;width:240px;');
                                buttonspan = document.createElement("span");
                                buttonspan.setAttribute('CLASS', 'autorlabels'); 
                                buttonspan.setAttribute('STYLE', 'position:relative;float:left;font-size:14px;left:40px;');
                                buttonspan.textContent = "Wait for release!";
                            buttonDiv.appendChild(buttonspan);
                            
                            var basicID = 'type'+outerid;
                            var basicStyle = "float:left;height:100%;max-height:430px;width:230px;overflow:auto;border:solid rgb(240,243,226) 1px;margin:3px;";
                            var basicdiv = document.createElement("div");
                            basicdiv.setAttribute('ID', basicID);
                            basicdiv.setAttribute('STYLE', basicStyle);
                            basicdiv.appendChild(inamediv); 
                            basicdiv.appendChild(charterdiv); 
                            basicdiv.appendChild(viewportdiv);
                            basicdiv.appendChild(notediv);
                            basicdiv.appendChild(buttonDiv);
                            
                            var typeid = "type"+singleID;
                            told = document.getElementById(typeid);
                            told.parentNode.appendChild(basicdiv)
                            told.parentNode.removeChild(told);
                        }
                        // functions
                        var overstring = "showTooltip(event, '"+newid+"')"
                        var movestring = "moveTooltip(event, '"+newid+"')"
                        var outstring = "hideTooltip(event, '"+newid+"')"
                        
                        var outerdiv = document.createElement("div");
                        outerdiv.setAttribute('ID', outerid);
                        
                        // create miniviewport
                        var viewdiv = document.createElement("div");
                        viewdiv.setAttribute('ID', viewid);
                        viewdiv.setAttribute('CLASS', 'miniviewport');
                            var minimg = document.createElement("img");
                            minimg.setAttribute('SRC', img);
                            minimg.setAttribute('CLASS', 'cropminiimg');
                            minimg.setAttribute('ONMOUSEOVER', overstring);
                            minimg.setAttribute('ONMOUSEMOVE', movestring);
                            minimg.setAttribute('ONMOUSEOUT', outstring);
                        viewdiv.appendChild(minimg);
                            
                        
                        // create tooltip
                        var tooldiv = document.createElement("div");
                        tooldiv.setAttribute('ID', toolid);
                        tooldiv.setAttribute('CLASS', 'tooltip');
                            var toolimg = document.createElement("img");
                            toolimg.setAttribute('SRC', img);
                            toolimg.setAttribute('CLASS', 'toolimg');
                        tooldiv.appendChild(toolimg);
                        
                        outerdiv.appendChild(viewdiv);
                        outerdiv.appendChild(tooldiv);
                        
                        var adder = "pub"+type+name+id;
                        var sender = "sender"+type+name+id;
                        var qsender = "#sender"+type+name+id;
                        document.getElementById(adder).appendChild(outerdiv);
                        if(role == "user")
                            {
                            $(qsender).css('top', '10px');
                            document.getElementById(sender).textContent = geti18nText(lang, 'wait-for-release');
                            }
                        else
                            {
                            document.getElementById("loadtext").innerHTML = geti18nText(lang, 'data-have-been-saved');
                            }
                        error = 0;
                        }
                 else
                     {
                     error++;
                     if(error < 20)
                       publishSingleCrop(id, user, name, type, role, lang);
                     else
                            {
                            document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                            error = 0;
                            }
                     }
                }
             };
            xmlhttp.send(parameters);
      }
}

// prepare the publication process of a cropped image 
function preparePublish(e, id, user, name, type, cropid, role, lang){
    x = e.pageX;
    y = e.pageY;
    $("#publishBobble").css('display', 'block');
    $("#publishBobble").css({'top': y - 570,'left': x - 440});
    
    singleID = id;
    var imagenameID = "colimage"+id;
    var noteID = "colnote"+id;
    $("#publishnametext").val(document.getElementById(imagenameID).textContent);
    $("#publishnotetext").val(document.getElementById(noteID).textContent);
    $("#pubtypetext").val(type);
    $("#pubnametext").val(name);
    var publishString = "publishCrop('"+id+"', '"+user+"', '"+name+"', '"+type+"', '"+cropid+"', '"+role+"', '"+lang+"');";
    document.getElementById("pubcrop").setAttribute("ONCLICK", publishString);
}

// prepare sending cropped image to other user
function prepareSend(e, id, user, lang){
    x = e.pageX;
    y = e.pageY;
    $("#sendBobble").css('display', 'block');
    $("#sendBobble").css({'top': y - 400,'left': x - 440});
    
    var sendString = "sendImage('"+id+"', '"+user+"', '"+lang+"');";
    document.getElementById("userAdjust").setAttribute("ONCLICK", sendString);
}

// send cropped image to other user
function sendImage(id, user, lang){
    var index = document.getElementById("userlist").selectedIndex;
    var sendUser = document.getElementById("userlist").options[index].value;
    var sendvalue = document.getElementById("userlist").options[index].text;
    if (id == "")
        {
            alert(geti18nText(lang, 'select-user'));
        }
    else
        {
        var xmlhttp;
        if (window.XMLHttpRequest)
               {// code for IE7+, Firefox, Chrome, Opera, Safari
                   xmlhttp=new XMLHttpRequest();
               }
       else
               {// code for IE6, IE5
                   xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
               }
        xmlhttp.open("GET","service/publish-cropimages?type=sendImage&amp;id="+id+"&amp;user="+user+"&amp;sendUser="+sendUser,true);
        xmlhttp.onreadystatechange=function(){
        if (xmlhttp.readyState==4)
             {
             var breadcrump = document.createElement("div");
             breadcrump.innerHTML = xmlhttp.responseText;
             $('#loadtext').css('display', 'block');
             if (xmlhttp.status==200)
                  {
                  var baseString = geti18nText(lang, 'send-to-user');
                  var finalString = baseString+sendvalue+"!";
                  document.getElementById("loadtext").innerHTML = finalString;
                  alert(finalString);
                  $("#sendBobble").css('display', 'none');
                  error = 0;
                  }
             else
                      {
                      error++;
                      if(error < 20)
                        sendImage(id, user, lang);
                      else
                         {
                         document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                         error = 0;
                         }
                      }
             }
             }
        xmlhttp.send();
        }
}


// *!* ################ functions of the image editor ################ *!*
// save current step on image to undo it later
function saveImage(){
  if(!undo)
    {
      // init undo button
      jQuery('#undo-step').css('display', 'block');
      undo = true;
    }
  // get src of edited img and load it to undo element
  var index = document.getElementById("imagelist").selectedIndex;
  var id = document.getElementById("imagelist").options[index].text;
  var tagName = jQuery('#'+id).prop("tagName");
  var src;
  if(tagName == 'CANVAS')
    {
    var canvas = document.getElementById(id);
    var context = canvas.getContext("2d");
    src = canvas.toDataURL();
    }
  else
    {
    src = jQuery('#'+id).attr('src');
    }
  var actualUndoID = "#undo-"+undoPoint;
  jQuery(actualUndoID).attr('src', src);
  jQuery(actualUndoID).attr('title', id);
  if(undoPoint==5)
    undoPoint = 1;
  else
    undoPoint++;
}

// undo current work step and load old image to editor viewport
function undoStep(lang){
  // get old img
  if(undoPoint==1)
    undoPoint = 5;
  else
    undoPoint--;
  var lastUndoID = "#undo-"+undoPoint;
  var src = jQuery(lastUndoID).attr('src');
  var id = jQuery(lastUndoID).attr('title');
  //check if undo is available
  if(id == 'lastPoint')
    {
    alert(geti18nText(lang, 'reached-last-undo-step'));
    }
  else
    {
    var side = document.getElementById(id).getAttribute("TITLE");
    // create image
    var newimg = document.createElement("img");
          newimg.setAttribute('SRC', src);
          newimg.setAttribute('ID', id);
          newimg.setAttribute('TITLE', side);
          newimg.setAttribute('CLASS', "editorimg");
    var wmargin = $('#'+id).css('left');
    var hmargin = $('#'+id).css('top');
    // delete current img and load old img
    old = document.getElementById(id);
    old.parentNode.removeChild(old); 
    document.getElementById('editorviewport').appendChild(newimg);
    $('#'+id).css('left', wmargin);
    $('#'+id).css('top', hmargin);
    IEparser = true;
    jQuery(".editorimg").draggable();
    // reset Undo Point
    jQuery(lastUndoID).attr('src', '');
    jQuery(lastUndoID).attr('title', 'lastPoint');
    }
} 

// load image to crop compare editor
function loadToEditor(side, lang){
    if(side == "left"){
     var src = document.getElementById("leftImg").getAttribute("SRC");
     var url = document.getElementById("leftImg").getAttribute("TITLE");
     var width = $('#leftImg').width();
     var height = $('#leftImg').height();
     var IMid = document.getElementById("ImgNameLeft").textContent;
    }
    else{
     var src = document.getElementById("rightImg").getAttribute("SRC");
     var url = document.getElementById("rightImg").getAttribute("TITLE");
     var width = $('#rightImg').width();
     var height = $('#rightImg').height();
     var IMid = document.getElementById("ImgNameRight").textContent;
    }
    IMid = IMid.replace(/\./g, "_");
    IMid = IMid.replace(/\&/g, "_");
    IMid = IMid.replace(/\:/g, "_");
    IMid = IMid.replace(/\%/g, "_");
    IMid = IMid.replace(/\//g, "_");
    IMid = IMid.replace(/\\/g, "_");
    IMid = IMid.replace(/\~/g, "_");
    IMid = IMid.replace(/\</g, "_");
    IMid = IMid.replace(/\>/g, "_");
    IMid = IMid.replace(/\^/g, "_");
    IMid = IMid.replace(/\°/g, "_");
    IMid = IMid.replace(/\@/g, "_");
    IMid = IMid.replace(/\=/g, "_");
    IMid = IMid.replace(/\|/g, "_");
    IMid = IMid.replace(/\§/g, "_");
    IMid = IMid.replace(/\$/g, "_");
    IMid = IMid.replace(/\+/g, "_");
    IMid = IMid.replace(/\#/g, "_");
    IMid = IMid.replace(/\;/g, "_");
    IMid = IMid.replace(/\µ/g, "_");
    IMid = IMid.replace(/\*/g, "_");
    IMid = IMid.replace(/\?/g, "_");
    IMid = IMid.replace(/\!/g, "_");
    IMid = IMid.replace(/\"/g, "_");
    IMid = IMid.replace(/\'/g, "_");
    IMid = IMid.replace(/\{/g, "_");
    IMid = IMid.replace(/\}/g, "_");
    IMid = IMid.replace(/\-/g, "_");
    IMid = IMid.replace(/\,/g, "_");
    IMid = IMid.replace(/\s/g, "_");
    IMid = IMid.replace(/\[/g, "_");
    IMid = IMid.replace(/\]/g, "_");
    var id = IMid+"_"+side;
    
    if(document.getElementById(id)!=null)
        {
        if(side == "left")
            alert(geti18nText(lang, 'loaded-to-right-viewport'));
        else
            alert(geti18nText(lang, 'loaded-to-left-viewport'));
        }
    else
        {
        // create image
        var img = document.createElement("img");
        img.setAttribute('SRC', src);
        img.setAttribute('ID', id);
        img.setAttribute('TITLE', side);
        img.setAttribute('CLASS', "editorimg");
        
        var wmargin = ((680-parseInt(width))/2 + (parseInt(width)/4));
        var hmargin = ((400-parseInt(height))/2 + (parseInt(height)/4));
        $('#editorviewport').css('left', wmargin);
        $('#editorviewport').css('top', hmargin);
        
        document.getElementById('editorviewport').appendChild(img);
        Pixastic.process(img, "brightness", {brightness:0,contrast:0});
        var option = document.createElement("option");
        option.setAttribute('TITLE', url);
        var transoption = document.createElement("option");
        option.innerHTML = id;
        transoption.innerHTML = id;
        document.getElementById('imagelist').appendChild(option);
        document.getElementById('translist').appendChild(transoption);
        $('#transparent').css('display', 'block');
        $('#toolbar').css('display', 'block');
        jQuery( ".editorimg" ).draggable();
        }
   IEparser = true;
}

// load annotation image into editor
function loadCollectionToEditor(side){
  if(side == "left"){
     var src = document.getElementById("collection-leftImg").getAttribute("SRC");
     var url = document.getElementById("collection-leftImg").getAttribute("TITLE");
     var width = $('#collection-leftImg').width();
     var height = $('#collection-leftImg').height();
     var IMid = document.getElementById("annoIdLeft").textContent;
    }
    else{
     var src = document.getElementById("collection-rightImg").getAttribute("SRC");
     var url = document.getElementById("collection-rightImg").getAttribute("TITLE");
     var width = $('#collection-rightImg').width();
     var height = $('#collection-rightImg').height();
     var IMid = document.getElementById("annoIdRight").textContent;
    }
    IMid = IMid.replace(/\./g, "_");
    IMid = IMid.replace(/\&/g, "_");
    IMid = IMid.replace(/\:/g, "_");
    IMid = IMid.replace(/\%/g, "_");
    IMid = IMid.replace(/\//g, "_");
    IMid = IMid.replace(/\\/g, "_");
    IMid = IMid.replace(/\~/g, "_");
    IMid = IMid.replace(/\</g, "_");
    IMid = IMid.replace(/\>/g, "_");
    IMid = IMid.replace(/\^/g, "_");
    IMid = IMid.replace(/\°/g, "_");
    IMid = IMid.replace(/\@/g, "_");
    IMid = IMid.replace(/\=/g, "_");
    IMid = IMid.replace(/\|/g, "_");
    IMid = IMid.replace(/\§/g, "_");
    IMid = IMid.replace(/\$/g, "_");
    IMid = IMid.replace(/\+/g, "_");
    IMid = IMid.replace(/\#/g, "_");
    IMid = IMid.replace(/\;/g, "_");
    IMid = IMid.replace(/\µ/g, "_");
    IMid = IMid.replace(/\*/g, "_");
    IMid = IMid.replace(/\?/g, "_");
    IMid = IMid.replace(/\!/g, "_");
    IMid = IMid.replace(/\"/g, "_");
    IMid = IMid.replace(/\'/g, "_");
    IMid = IMid.replace(/\{/g, "_");
    IMid = IMid.replace(/\}/g, "_");
    IMid = IMid.replace(/\-/g, "_");
    IMid = IMid.replace(/\,/g, "_");
    IMid = IMid.replace(/\s/g, "_");
    IMid = IMid.replace(/\[/g, "_");
    IMid = IMid.replace(/\]/g, "_");
    var id = IMid+"_"+side;
    
    if(document.getElementById(id)!=null)
        {
        if(side == "left")
            alert(geti18nText(lang, 'loaded-to-right-viewport'));
        else
            alert(geti18nText(lang, 'loaded-to-left-viewport'));
        }
    else
        {
        // create image
        var img = document.createElement("img");
        img.setAttribute('SRC', src);
        img.setAttribute('ID', id);
        img.setAttribute('TITLE', src);
        img.setAttribute('CLASS', "editorimg");
        
        var wmargin = ((680-parseInt(width))/2 + (parseInt(width)/4));
        var hmargin = ((400-parseInt(height))/2 + (parseInt(height)/4));
        $('#editorviewport').css('left', wmargin);
        $('#editorviewport').css('top', hmargin);
        
        document.getElementById('editorviewport').appendChild(img);
        Pixastic.process(img, "brightness", {brightness:0,contrast:0});
        var option = document.createElement("option");
        option.setAttribute('TITLE', url);
        var transoption = document.createElement("option");
        option.innerHTML = id;
        transoption.innerHTML = id;
        document.getElementById('imagelist').appendChild(option);
        document.getElementById('translist').appendChild(transoption);
        $('#transparent').css('display', 'block');
        $('#toolbar').css('display', 'block');
        jQuery( ".editorimg" ).draggable();
        }
   IEparser = true;
}

// adjust brightness and contrast values
function adjustBC(lang){
    saveImage();
    if(IEparser == false)
        IEparse();
    var index = document.getElementById("imagelist").selectedIndex;
    var id = document.getElementById("imagelist").options[index].text;
    if (id == "")
    {
        alert(geti18nText(lang, 'select-image-to-adjust-changes'));
    }
    else
    {
        var img = document.getElementById(id);
        var  contrast = $("#value-contrast").val();
        var brightness = $("#value-brightness").val();
        Pixastic.process(img, "brightness", {brightness:brightness,contrast:contrast});
    }
    IEparser = false;
    jQuery( ".editorimg" ).draggable();
}

// special function for canvas tag and IE- Explorer
function IEparse(){
    var index = document.getElementById("imagelist").selectedIndex;
    var id = document.getElementById("imagelist").options[index].text;
    var canvas = document.getElementById(id);
    var context = canvas.getContext("2d");
    var imgold = canvas.toDataURL();
    var qid = "#"+id;
    var side = document.getElementById(id).getAttribute("TITLE");
    // create image
    var newimg = document.createElement("img");
        newimg.setAttribute('SRC', imgold);
        newimg.setAttribute('ID', id);
        newimg.setAttribute('TITLE', side);
        newimg.setAttribute('CLASS', "editorimg");
    
    var wmargin = $(qid).css('left');
    var hmargin = $(qid).css('top');

    old = document.getElementById(id);
    old.parentNode.removeChild(old);    
    document.getElementById('editorviewport').appendChild(newimg);

    $(qid).css('left', wmargin);
    $(qid).css('top', hmargin);
    IEparser = true;
    jQuery(".editorimg").draggable();
}

// IE specification
function initImg(){
    $('#buttonBar').css('display', 'block');
    /*
    if ( $.browser.msie ){
        $('#flipHori').css('display', 'none');
        $('#flipVert').css('display', 'none');
    }
    */
    jQuery('#remove-editor-image').css('display', 'block');
    jQuery( '.editorimg').draggable();
    IEparse();
}

// remove selected image in img-editor
function removeImg(lang){
    var index = document.getElementById("imagelist").selectedIndex;
    var id = document.getElementById("imagelist").options[index].text;
    if (id == "")
    {
        alert(geti18nText(lang, 'select-image-to-adjust-changes'));
    }
    else
    {
      // ask user to confirm this step
      if(confirm(geti18nText(lang, 'delete-image-question')))
      {
      old = document.getElementById(id);
      old.parentNode.removeChild(old); 
      document.getElementById("imagelist").remove(index);
			document.getElementById("translist").remove(index);
      }
    }
}

// flip image
function flip(type, lang){
    var index = document.getElementById("imagelist").selectedIndex;
    var id = document.getElementById("imagelist").options[index].text;
    if (id == "")
    {
        alert(geti18nText(lang, 'select-image-to-adjust-changes'));
    }
    else
    {
    var qid = "#"+id;
    $(qid).pixastic("rotate", {angle:0});
    var img = document.getElementById(id);
    if(type == "Horizontal")
        Pixastic.process(img, "fliph");
    else
        Pixastic.process(img, "flipv");
    }
    jQuery( ".editorimg" ).draggable();
}

// edge detection
function adjustEdge(lang){
    saveImage();
    if(IEparser == false)
        IEparse();
    var index = document.getElementById("imagelist").selectedIndex;
    var id = document.getElementById("imagelist").options[index].text;
    if (id == "")
    {
        alert(geti18nText(lang, 'select-image-to-adjust-changes'));
    }
    else
    {
    var img = document.getElementById(id);
    var mono = $("#value-mono").attr("checked");
    var invert = $("#value-invert").attr("checked");
    Pixastic.process(img, "edges", {mono:mono,invert:invert});
    }
    IEparser = false;
    jQuery( ".editorimg" ).draggable();
}

// desaturate
function desaturate(lang){
    if(IEparser == false)
        IEparse();
    var index = document.getElementById("imagelist").selectedIndex;
    var id = document.getElementById("imagelist").options[index].text;
    if (id == "")
    {
        alert(geti18nText(lang, 'select-image-to-adjust-changes'));
    }
    else
    {
    var img = document.getElementById(id);
    Pixastic.process(img, "desaturate", {average : false});
    }
    IEparser = false;
    jQuery(".editorimg").draggable();
}

// glow
function glow(lang){
    saveImage();
    if(IEparser == false)
        IEparse;
    var index = document.getElementById("imagelist").selectedIndex;
    var id = document.getElementById("imagelist").options[index].text;
    if (id == "")
    {
        alert(geti18nText(lang, 'select-image-to-adjust-changes'));
    }
    else
    {
    var img = document.getElementById(id);
    var  amount = $("#value-amount").val();
    var radius = $("#value-radius").val();
    Pixastic.process(img, "glow", {amount:amount, radius:radius});
    }
    IEparser = false;
    jQuery( ".editorimg" ).draggable();
}

// emboss
function emboss(lang){
    saveImage();
    if(IEparser == false)
        IEparse();
    var index = document.getElementById("imagelist").selectedIndex;
    var id = document.getElementById("imagelist").options[index].text;
    if (id == "")
    {
        alert(geti18nText(lang, 'select-image-to-adjust-changes'));
    }
    else
    {
    var img = document.getElementById(id);
    Pixastic.process(img, "emboss", {
		strength : $("#value-strength").val(),
		greyLevel : $("#value-grey").val(),
		direction : $("#value-direction").val()});
    }
    IEparser = false;
    jQuery( ".editorimg" ).draggable();
}

// RGB values
function adjustRGB(lang){
    saveImage();
    if(IEparser == false)
        IEparse();
    var index = document.getElementById("imagelist").selectedIndex;
    var id = document.getElementById("imagelist").options[index].text;
    if (id == "")
    {
        alert(geti18nText(lang, 'select-image-to-adjust-changes'));
    }
    else
    {
    var img = document.getElementById(id);
    var red = $("#value-red").val();
    var green = $("#value-green").val();
    var blue = $("#value-blue").val();
    Pixastic.process(img, "coloradjust", {red:red,green:green,blue:blue});
    }
    IEparser = false;
    jQuery( ".editorimg" ).draggable();
}

// reset image in editor
function reset(lang){
    var index = document.getElementById("imagelist").selectedIndex;
    var id = document.getElementById("imagelist").options[index].text;
    if (id == "")
    {
        alert(geti18nText(lang, 'select-image-to-adjust-changes'));
    }
    else
    {
        var src = document.getElementById(id).getAttribute('TITLE');
        var old = document.getElementById(id);
        old.parentNode.removeChild(old);
        // create image
        var img = document.createElement("img");
        img.setAttribute('SRC', src);
        img.setAttribute('ID', id);
        img.setAttribute('TITLE', src);
        img.setAttribute('CLASS', "editorimg");
        document.getElementById('editorviewport').appendChild(img);
        Pixastic.process(img, "brightness", {brightness:0,contrast:0});
        IEparser = false;
    }
    jQuery( ".editorimg" ).draggable();
}
