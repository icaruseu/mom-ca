var api, mode, workmode="Viewmode", error = 0, saveoption = "new", opened = 'close', AnnoLoaded = false, projectname;
// api is the jcrop object, mode is the chartercontext, error is used for IE, saveoption for save- context and opened is used for toolbar

// *!* ################ HELPER functions in Image- Viewport ################ *!*

// on load functions
function loadDoc(platformid){
                    // set position of page elements (it has to be defined as a result of the fullscreen mode)
                    var width = screen.width;
                    var closeMargin = (width/2)-100+"px";
                    var logoutMargin = (width/2)-30+"px";
                    var pushMargin = (width/2)-105+"px";
                    var funcMargin = (width/2)-590+"px";
                    var viewportHeight = (document.body.offsetHeight)-82; 
                    jQuery('#viewport').css( 'height', viewportHeight);
                    jQuery('#mode').css( 'left', closeMargin);
                    jQuery('#logout-link').css( 'left', logoutMargin);
                    jQuery('#pushDiv').css( 'left', pushMargin);
                    jQuery('#functionField').css( 'left', funcMargin);
                    projectname = platformid;
                    jQuery('#img').css( 'height', viewportHeight);
                    jQuery('#img-draggable').draggable();
};

function showAnno(chartercontext, status, firstVisit, lang){
	mode = chartercontext;
	if(firstVisit)
		{
		loadCoordinates();
		AnnoLoaded = true;
		}
	if(status == 'show')
		{
		jQuery('#privatAnnos').css('display', 'block');
		jQuery('#publicAnnos').css('display', 'block');
		buttontext = geti18nText(lang, 'hide-annotation');
		$("#showButton").text(buttontext);
    var click = "showAnno('"+chartercontext+"','hide', false, '"+lang+"');";
    document.getElementById("showButton").setAttribute('onclick', click);
		}
	else
		{
		buttontext = geti18nText(lang, 'show-annotation');
		$("#showButton").text(buttontext);
    var click = "showAnno('"+chartercontext+"','show', false, '"+lang+"');";
    document.getElementById("showButton").setAttribute('onclick', click);
		jQuery('#privatAnnos').css('display', 'none');
		jQuery('#publicAnnos').css('display', 'none');
		}
}
                
// change image of viewport
function changeImage(url){
	document.images["image"].src = url;
	document.getElementById('imgContainer').setAttribute('href', url);
}
                
// fade in load- div                
function loadFadeIn(){
    jQuery("#loading").animate({
        "marginTop": 51
        });
}

// fade out load- div   
function loadFadeOut(){
    jQuery("#loading").animate({
        "marginTop": 0
        });
}


// open or close function field  
function changeFuncField(){
    // check if field is opened
    if(opened == 'close')
        {
        jQuery('#functionField').css('bottom', '0');
        jQuery('#functionField').css('overflow', 'hidden');
        // show toolbar
        jQuery("#pushDiv").animate({
                    "marginBottom": 45
            });
        jQuery("#functionField").animate({
                "height": 45
            });
        // define next state - show save editor or close Functionfield onClick
        if(jQuery('#cropeditor').css('display')=='block')
            {   
            opened = 'savefield';
            }
        else
            {
            // only show toolbar
            document.getElementById("pushImg").setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/push_down');
            opened = 'open';
            }
        }
    else if(opened == 'savefield')
        {
        // show save editor and define next state to close
        jQuery('#functionField').css('overflow', 'auto');
        document.getElementById("pushImg").setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/push_down');
        opened = 'open';
        jQuery("#pushDiv").animate({
                    "marginBottom": 320
            });
        jQuery("#functionField").animate({
                "height": 320
            });
        }
    else
        {
        // close func field
        document.getElementById("pushImg").setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/push_up');
        opened = 'close';
        jQuery("#pushDiv").animate({
             "marginBottom": 0
        });
        jQuery("#functionField").animate({
             "height": 0
        });
        }
        
}
           
// zoom image on the ImageEditor widget 
function zoom(type){
        // api has to be destroyed to get the control about the image
        if(api!=null)
            {
            api.destroy();
            }
        // remove the old image and create a new one with the new size
        var newwidth, newheight;
        var src = document.getElementById("img").getAttribute("SRC");
        var oldwidth = jQuery('#img').width();
        var oldheight = jQuery('#img').height();
        var img=document.createElement("IMG");
        img.setAttribute('SRC', src); 
        img.setAttribute('ID', "img");
        img.setAttribute('NAME', "image");
        if (type == 'in')
            {
            newwidth = oldwidth * 1.5;
            newheight = oldheight * 1.5;
            
            }
        else
            {
            newwidth = oldwidth / 1.5;
            newheight = oldheight / 1.5;
            }
        jQuery('#img').width(newwidth);
        jQuery('#img').height(newheight);
        jQuery('#functionField').css('bottom', '0');
        // activate Jcrop again
        var selectionArray = new Array();
        var multifactor = newwidth/oldwidth;
        jQuery('#x1').val(Math.round(parseInt(jQuery('#x1').val())*multifactor));
        jQuery('#y1').val(Math.round(parseInt(jQuery('#y1').val())*multifactor));
        jQuery('#x2').val(Math.round(parseInt(jQuery('#x2').val())*multifactor));
        jQuery('#y2').val(Math.round(parseInt(jQuery('#y2').val())*multifactor));
        jQuery('#w').val(Math.round(parseInt(jQuery('#w').val())*multifactor));
        jQuery('#h').val(Math.round(parseInt(jQuery('#h').val())*multifactor));
        
        selectionArray[0] = jQuery('#x1').val();
        selectionArray[1] = jQuery('#y1').val();
        selectionArray[2] = jQuery('#x2').val();
        selectionArray[3] = jQuery('#y2').val();
        if(api!=null)
            {       
            api = jQuery.Jcrop('#img',{ 
	           bgColor: 'red', 
	           setSelect: selectionArray,
	           onChange: showCoords,
			   onSelect: showCoords
	        });
	        }
	     // reprint the annotations
	     if(AnnoLoaded)
       	reprintAnnos(newwidth, oldwidth);
    };

// start Jcrop and the function to mark an image region
function startCrop(chartercontext, lang){
			if(!AnnoLoaded)
					{
					loadCoordinates();
					var click = "showAnno('"+chartercontext+"','show', false, '"+lang+"');";
    			document.getElementById("showButton").setAttribute('onclick', click);
					AnnoLoaded = true;
					}
       mode = chartercontext;
       workmode = "Selectmode";
       jQuery('#viewmodeButton').css('display', 'inline');
       jQuery('#selectmodeButton').css('display', 'none');
       jQuery('#directanno').css('display', 'none');
       jQuery('#directselected').css('display', 'none');
	   jQuery('#img-link').click(function(e) {e.preventDefault();});
	   // create a new api object
	   if(api==null)
            {
	        api = jQuery.Jcrop('#img',{ 
	           bgColor: 'red', 
	           onChange: showCoords,
			   onSelect: showCoords
	           });
	        }
	};

// cancel the activation of the cropping tools
function viewmode(){
    jQuery('#selectmodeButton').css('display', 'block');
    jQuery('.hiddenButton').css('display', 'none');
    jQuery('#viewmodeButton').css('display', 'none');
    jQuery('#directanno').css('display', 'none');
    jQuery('#directselected').css('display', 'none');
    jQuery('#annotationfield').val('');
    workmode = "Viewmode";
    opened = 'open';
    document.getElementById("pushImg").setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/push_down');
    jQuery('#functionField').css('overflow', 'hidden');
    jQuery("#pushDiv").animate({
           "marginBottom": 45
        });
        jQuery("#functionField").animate({
             "height": 45
        });
    jQuery('#cropeditor').css('display', 'none');
    // destroy the cropping function
    api.destroy();
    api = null;
};

// save the coordinates to input fields
function showCoords(c){
	    jQuery('#x1').val(c.x);
		jQuery('#y1').val(c.y);
		jQuery('#x2').val(c.x2);
		jQuery('#y2').val(c.y2);
		jQuery('#w').val(c.w);
		jQuery('#h').val(c.h);
		jQuery('.hiddenButton').css('display', 'inline'); 
        workmode = "Editmode";
};

 // normalize coordinates of the direct annotations
function loadCoordinates(){
    // calculate the zooming factor
    var newImg = new Image();
    newImg.src = document.getElementById('img').src;
    $(newImg).load(function(){
        var multifactor = newImg.width/$('#img').width();
        // go through all privat annotations
        var all = document.getElementById("privatAnnos").childNodes;
        var number = 0;
        for(x=0;x<all.length;x++)
            {
            if(all[x].nodeType == 1)
                 number++;
            }
          
        // calculate the new coordinates
        for(i=1;i<=number;i++)
            {
            var field = "directannofield"+i;
            var tools = "annotools"+i;
            var text = "directannotext"+i;
            document.getElementById(field).style.top = Math.round(parseInt(document.getElementById(field).style.top)/multifactor)+"px";
            document.getElementById(field).style.left = Math.round(parseInt(document.getElementById(field).style.left)/multifactor)+"px";
            document.getElementById(field).style.width = Math.round(parseInt(document.getElementById(field).style.width)/multifactor)+"px";        
            document.getElementById(field).style.height = Math.round(parseInt(document.getElementById(field).style.height)/multifactor)+"px";
            document.getElementById(tools).style.top = Math.round(parseInt(document.getElementById(tools).style.top)/multifactor)+"px";
            document.getElementById(tools).style.left = Math.round(parseInt(document.getElementById(tools).style.left)/multifactor)+"px";
            document.getElementById(text).style.top = Math.round(parseInt(document.getElementById(text).style.top)/multifactor)+"px";
            document.getElementById(text).style.left = Math.round(parseInt(document.getElementById(text).style.left)/multifactor)+"px";
            }
        // go through all public annotations
        var allpub = document.getElementById("publicAnnos").childNodes;
        var number = 0;
        for(x=0;x<allpub.length;x++)
            {
            if(allpub[x].nodeType == 1)
                 number++;
            }
        // calculate the new coordinates
        for(i=1;i<=number;i++)
            {
            var field = "pubannofield"+i;
            var tools = "pubtools"+i;
            var text = "pubannotext"+i;
            document.getElementById(field).style.top = Math.round(parseInt(document.getElementById(field).style.top)/multifactor)+"px";
            document.getElementById(field).style.left = Math.round(parseInt(document.getElementById(field).style.left)/multifactor)+"px";
            document.getElementById(field).style.width = Math.round(parseInt(document.getElementById(field).style.width)/multifactor)+"px";        
            document.getElementById(field).style.height = Math.round(parseInt(document.getElementById(field).style.height)/multifactor)+"px";
            document.getElementById(tools).style.top = Math.round(parseInt(document.getElementById(tools).style.top)/multifactor)+"px";
            document.getElementById(tools).style.left = Math.round(parseInt(document.getElementById(tools).style.left)/multifactor)+"px";
            document.getElementById(text).style.top = Math.round(parseInt(document.getElementById(text).style.top)/multifactor)+"px";
            document.getElementById(text).style.left = Math.round(parseInt(document.getElementById(text).style.left)/multifactor)+"px";
            }
    
    });
};

// has the user mark an image region 
function checkCoords(lang){
	   if (parseInt(jQuery('#w').val())==0) {
	       alert(geti18nText(lang, 'mark-a-region'));
	       return false;
	       }
	   else return true;       
    };

// calculate the zooming factor
function getImgSize(imgSrc){
        var size = jQuery('#img').width();
        var newImg = new Image();
        newImg.src = imgSrc;
        var width = newImg.width/size;
        return width;
    };

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
    x = e.pageX - jQuery(viewid).offset().left;
    y = e.pageY - jQuery(viewid).offset().top;
 
    // Set the z-index of the current item,
    // make sure it's greater than the rest of thumbnail items
    // Set the position and display the image tooltip
    jQuery(viewid).css('z-index','15');
    jQuery(toolid).css({'top': y + 40,'left': x + 30,'display':'block'});
};

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
    x = e.pageX - jQuery(viewid).offset().left;
    y = e.pageY - jQuery(viewid).offset().top;
             
    // This line causes the tooltip will follow the mouse pointer
    jQuery(toolid).css({'top': y + 30,'left': x + 30});
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
    jQuery(viewid).css('z-index','1');
    jQuery(toolid).animate({"opacity": "hide"}, "fast");
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
    if(mode == 'fond') 
        {        
            xmlhttp.open("GET","../../../service/get-i18n-text?key="+key+"&amp;lang="+lang,false);
        }
        else 
        {
            xmlhttp.open("GET","../../service/get-i18n-text?key="+key+"&amp;lang="+lang,false);
        }
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
                   jQuery('#loadgif').css('display', 'none');
                   loadFadeIn();
                   document.getElementById("loadtext").innerHTML= "Error! Please try again!";
                   window.setTimeout(loadFadeOut,10000);
                   error = 0;
                   }
                 }
            }
       };
     xmlhttp.send();
     // return text of i18n message
     return breadcrump;
};

// show help texts
function showHelp(e, chartercontext, lang){
    // may be store chartercontext - font/ collection
    if(mode==null)
            {
            mode = chartercontext;
            }
    var send = "no";
    var width = screen.width;
    var x = e.pageX-40;
    var y = e.pageY;
    // define position auf booble div 
    if(workmode == "Viewmode")
    {
    var key = "viewmode-text";
    var height = "140px";
    var topcorner = "180px";
    y = y-200;
    send = "yes";
    }
    else if(workmode == "Selectmode")
    {
    var key = "selectmode-text";
    var height = "100px";
    y = y-180;
    var topcorner = "140px";
    send = "yes";
    }
    else if(workmode == "Editmode")
    {
    var key = "editmode-text";
    var height = "140px";
    y = y-200;
    var topcorner = "180px";
    send = "yes";
    }
    if(send == "yes")
    {
     jQuery('#bobble').css('display', 'block');
     jQuery('#bobble').css('height', height);
     jQuery('#bobble').css('top', y); 
     jQuery('#bobblecorner').css('top', topcorner); 
     jQuery('#bobble').css('left', x);    
     document.getElementById('bobbletext').innerHTML = geti18nText(lang, key);
    };
};

// *!* ################ crop- functions in Image- Viewport ################ *!*
// crop image
function cropImage(lang){
        jQuery('#directanno').css('display', 'none');
        jQuery('#directselected').css('display', 'none');
        if(checkCoords(lang))
        {
        // collect image informations - coordinates/ src- code
        var url = document.getElementById("img").getAttribute("src");
        var multifactor = getImgSize(document.getElementById('img').src);
        var x1 = Math.round(document.getElementById('x1').value*multifactor);
        var y1 = Math.round(document.getElementById('y1').value*multifactor);
        var x2 = Math.round(document.getElementById('h').value*multifactor);
        var y2 = Math.round(document.getElementById('w').value*multifactor);
        // send request to crop script
        var xmlhttp;
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
        if(mode == "fond") 
        {
        xmlhttp.open("GET","../../../service/crop?type=get&amp;url="+url+"&amp;x1="+x1+"&amp;y1="+y1+"&amp;x2="+x2+"&amp;y2="+y2+"&amp;ignoreMe=" + new Date().getTime(),true);
        }
        else
        {
        xmlhttp.open("GET","../../service/crop?type=get&amp;url="+url+"&amp;x1="+x1+"&amp;y1="+y1+"&amp;x2="+x2+"&amp;y2="+y2+"&amp;ignoreMe=" + new Date().getTime(),true);
        }
        // loading screen
        jQuery('#directanno').css('display', 'none');
        loadFadeIn();
        document.getElementById("loadtext").innerHTML = geti18nText(lang, 'cropping-image');
        jQuery('#loadgif').css('display', 'block');
        jQuery('#loadtext').css('display', 'block');
        xmlhttp.onreadystatechange=function(){
        if (xmlhttp.readyState==4)
            {
             if (xmlhttp.status==200)
                 { 
                    if(document.getElementById("cropviewport").hasChildNodes())
                        {
                        // remove an existing image in the viewport of the editor
                        old = document.getElementById("cropviewport").childNodes[0];
                        old.parentNode.removeChild(old);
                        }
                    // show cropped image in the viewport of the editor
                    jQuery('#cropeditor').css('display', 'block');
                    jQuery('#functionField').css('overflow', 'auto');
                    jQuery("#pushDiv").animate({
                        "marginBottom": 320
                        });
                    jQuery("#functionField").animate({
                        "height": 320
                    });
                    loadFadeOut();
                    var string = "data:image/jpeg;base64,"+xmlhttp.responseText;
                    var img=document.createElement("IMG");
                    img.src = string; 
                    img.setAttribute('id', "cropimg");
                    document.getElementById("cropviewport").appendChild(img);
                    document.getElementById('nametext').value='';
                    document.getElementById('typetext').value='';
                    document.getElementById('imagenametext').value='';
                    document.getElementById('notetext').value='';
                    // reset all add-/ release- Buttons
                    var allp = document.getElementsByTagName("P");
                    for(var i=0;i<allp.length;i++)
                        {
                        if(allp[i].hasAttribute("ID"))
                            {
                            var string = allp[i].getAttribute("ID");
                            if(string.substring(0,7)=="release")
                                {
                                var addid = "#add"+string.substring(7,14);
                                var releaseid = "#"+string;
                                jQuery(addid).css('display', 'block');
                                jQuery(releaseid).css('display', 'none');
                                }
                            }
                        }
                    error = 0;
                    }
                    else
                    {
                    error++;
                    if(error < 20)
                        cropImage();
                    else
                        {
                        jQuery('#loadgif').css('display', 'none');
                        document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                        window.setTimeout(loadFadeOut,10000);
                        error = 0;
                        }
                      
                    }
                }
            else {
                jQuery('#cropeditor').css('display', 'none');
                }
         };
        xmlhttp.send();
        }
    };

// remove cropped image from an existing collection
function removeCrop(type, id, user, buttonid, lang){
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
        if (xmlhttp.status==200)
             {
              // delete the cropped image on the screen
              if(breadcrump.childNodes[0].childNodes[0].nodeValue == "delete")
                 {
                 loadFadeIn();
                 document.getElementById("loadtext").innerHTML = geti18nText(lang, 'data-have-been-successful-removed');
                 window.setTimeout(loadFadeOut,4000);
                 old = document.getElementById(id);
                 old.parentNode.removeChild(old);
                 var addid = '#add'+buttonid;
                 var releaseid = '#release'+buttonid;
                 
                 if(type=="yes")
                    {
                    var typeid = "type"+id;
                    told = document.getElementById(typeid);
                    told.parentNode.removeChild(told);
                    }
                 
                 // configure buttons
                 jQuery(addid).css('display', 'block');
                 jQuery(releaseid).css('display', 'none');
                 error = 0;
                 }
             else
                 {
                 error++;
                 if(error < 20)
                   removeCrop(type, id, user, buttonid, lang);
                 else
                    {
                    loadFadeIn();
                    jQuery('#loadgif').css('display', 'none');
                    document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                    window.setTimeout(loadFadeOut,10000);
                    error = 0;
                    }
                 }
             }
        }
        }
   xmlhttp.send();
};

// add  cropped image to existing collection
function addCrop(id, url, user, name, type, lang){
    var imagename = jQuery('#imagenametext').val();
    var imagenote = jQuery('#notetext').val();
    var img = document.getElementById("cropimg").getAttribute("SRC");
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
        if(mode == "fond") 
                {             
                xmlhttp.open("POST","../../../service/crop?type=post&amp;functype="+functype+"&amp;user="+user+"&amp;id="+id,true);
                }
        else
                {
                xmlhttp.open("POST","../../service/crop?type=post&amp;functype="+functype+"&amp;user="+user+"&amp;id="+id,true);
                }
        loadFadeIn();
        document.getElementById("loadtext").innerHTML = geti18nText(lang, 'saving-data');
        xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
        xmlhttp.onreadystatechange=function(){
            if (xmlhttp.readyState==4)
                {
                 if (xmlhttp.status==200)
                     { 
                        var xmlDoc = jQuery.parseXML(xmlhttp.response);
                        var addID = type+name+id;
                        
                        // define ID because of existing elements
                        var outerid = xmlDoc.getElementsByTagName('dataid')[0].childNodes[0].nodeValue;
                        var newid = Math.floor((Math.random()*1000)+500)+Math.floor((Math.random()*1000)+500);
                        var viewid = 'view'+newid;
                        var toolid = 'tool'+newid;
                        var addid = '#add'+id;
                        var releaseid = '#release'+id;
                        jQuery('#loadgif').css('display', 'none');
                        
                        // insert new data into the dropdown- lists of existing datas
                        document.getElementById("loadtext").innerHTML = geti18nText(lang, 'data-have-been-successful-updated');
                        window.setTimeout(loadFadeOut,4000);
                        var relstring = "removeCrop('no', '"+outerid+"', '"+user+"', '"+id+"', '"+lang+"')";
                        
                        // configure buttons
                        jQuery(addid).css('display', 'none');
                        jQuery(releaseid).css('display', 'block');
                        
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
                            minimg.setAttribute('CLASS', 'cropimg');
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
                        
                        // exchange buttons
                        var relbutton = 'release'+id;
                        document.getElementById(relbutton).removeAttribute('ONCLICK');
                        document.getElementById(relbutton).setAttribute('ONCLICK', relstring);
                        error = 0;
                        }
                 else
                     {
                     error++;
                     if(error < 20)
                       addCrop(id, url, user, name, type , lang);
                     else
                            {
                            jQuery('#loadgif').css('display', 'none');
                            document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                            window.setTimeout(loadFadeOut,10000);
                            error = 0;
                            }
                     }
                }
             };
            xmlhttp.send(parameters);
      }
};

// store the user's cropped image in his userfile    
function storeCrop(url, user, lang){
        var name = jQuery('#nametext').val();
        var type = jQuery('#typetext').val();
        var imagename = jQuery('#imagenametext').val();
        var imagenote = jQuery('#notetext').val();
        var img = document.getElementById("cropimg").getAttribute("SRC");
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
            loadFadeIn();
            document.getElementById("loadtext").innerHTML = geti18nText(lang, 'saving-data');
            if(mode == "fond") 
                    {             
                    xmlhttp.open("POST","../../../service/crop?type=post&amp;functype="+functype+"&amp;user="+user,true);
                    }
                else
                    {
                    xmlhttp.open("POST","../../service/crop?type=post&amp;functype="+functype+"&amp;user="+user,true);
                    }
            xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
            xmlhttp.onreadystatechange=function(){
            if (xmlhttp.readyState==4)
                {
                 if (xmlhttp.status==200)
                     { 
                        jQuery('#loadgif').css('display', 'none');
                        var xmlDoc = xmlhttp.responseXML;
                        if (xmlDoc.childNodes[0].nodeName == "data")
                        {
                            var outerid = xmlDoc.getElementsByTagName('dataid')[0].childNodes[0].nodeValue;
                            var id = xmlDoc.getElementsByTagName('cropid')[0].childNodes[0].nodeValue;
                            var newid = Math.floor((Math.random()*1000)+500)+Math.floor((Math.random()*1000)+500);
                            var addID = type+name+id;
                            // insert new data into the dropdown- lists of existing datas
                            document.getElementById("loadtext").innerHTML = geti18nText(lang, 'data-have-been-saved');
                            window.setTimeout(loadFadeOut,4000);
                            
                            var viewid = 'view'+newid;
                            var toolid = 'tool'+newid;
                            var adderid = 'add'+id;
                            var releaseid = 'release'+id;
                            
                            var entrydiv = document.createElement("div");
                                entrydiv.setAttribute("CLASS","entry");
                            
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
                                minimg.setAttribute('CLASS', 'cropimg');
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
                            var addstring = "addCrop('"+id+"', '"+url+"', '"+user+"', '"+name+"', '"+type+"', '"+lang+"')";
                            
                            var addbutton = document.createElement("p");
                            addbutton.setAttribute('ID', adderid);
                            addbutton.setAttribute('CLASS', 'button');
                            addbutton.setAttribute('ONCLICK', addstring);
                            addbutton.setAttribute('STYLE', 'position:absolute;left:315px;top:9px;width:19px;height:15px;');
                                var addImage = document.createElement("IMG");
                                addImage.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/save');
                                addImage.setAttribute('STYLE', 'width:20px;position:relative;top:-2px;');
                                addImage.setAttribute('TITLE', 'Add Image');
                           addbutton.appendChild(addImage);  
                            
                            var releasebutton = document.createElement("p");
                            releasebutton.setAttribute('ID', releaseid);
                            releasebutton.setAttribute('CLASS', 'button');
                            releasebutton.setAttribute('ONCLICK', '');
                            releasebutton.setAttribute('STYLE', 'position:absolute;left:315px;top:9px;width:19px;height:15px;display:none;');
                            var relImage = document.createElement("IMG");
                                relImage.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/remove');
                                relImage.setAttribute('STYLE', 'width:20px;position:relative;top:-2px;');
                                relImage.setAttribute('TITLE', 'Remove Image');
                           releasebutton.appendChild(relImage); 
                                
                            
                            entrydiv.appendChild(typespan);
                            entrydiv.appendChild(namespan);
                            entrydiv.appendChild(outerdiv);
                            entrydiv.appendChild(addbutton);
                            entrydiv.appendChild(releasebutton);
                            
                            document.getElementById("existdata").appendChild(entrydiv);
                        }
                        else 
                        {   
                            // user only updates an existing DB- entry
                            jQuery('#loadgif').css('display', 'none');
                            // define ID because of existing elements
                            var outerid = xmlDoc.getElementsByTagName('dataid')[0].childNodes[0].nodeValue;
                            var id = xmlDoc.getElementsByTagName('cropid')[0].childNodes[0].nodeValue;
                            document.getElementById("loadtext").innerHTML = geti18nText(lang, 'data-have-been-successful-updated');
                            window.setTimeout(loadFadeOut,4000);
                            var newid = Math.floor((Math.random()*1000)+500)+Math.floor((Math.random()*1000)+500);
                            var viewid = 'view'+newid;
                            var toolid = 'tool'+newid;
                            var addid = '#add'+id;
                            var releaseid = '#release'+id;
                            
                            // configure buttons
                            jQuery(addid).css('display', 'none');
                            jQuery(releaseid).css('display', 'block');
                            
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
                                minimg.setAttribute('CLASS', 'cropimg');
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
                            
                            // exchange buttons
                            var relbutton = 'release';
                            var relstring = "removeCrop('no', '"+outerid+"', '"+user+"', '"+id+"', '"+lang+"')";
                            document.getElementById(relbutton).removeAttribute('ONCLICK');
                            document.getElementById(relbutton).setAttribute('ONCLICK', relstring);
                            }
                        error = 0;
                        }
                 else
                     {
                     error++;
                     if(error < 20)
                       storeCrop(url, user, lang);
                     else
                       {
                       jQuery('#loadgif').css('display', 'none');
                       document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                       window.setTimeout(loadFadeOut,10000);
                       error = 0;
                       }
                     }
                }
             };
            xmlhttp.send(parameters);
            }
            }
 };

// change the saveoption for cropped Images
function changeSave(option){
    if(option == "new") 
        {
        document.getElementById('newcollection').setAttribute('STYLE','position:relative;background:white;float:left;width:223px;z-index:5;border:solid #505050 1px;border-left:0px;border-bottom:0px;-webkit-border-top-left-radius: 5px;-webkit-bordertop-right-radius: 5px;-khtml-border-top-left-radius: 5px;-khtml-border-top-right-radius: 5px;-moz-border-radius-topleft: 5px;-moz-border-radius-topright: 5px;border-top-left-radius: 5px;border-top-right-radius: 5px;');
        document.getElementById('existcollection').setAttribute('STYLE','position:relative;float:left;width:175px;z-index:5;background:#F8F8F8;border:solid #505050 1px;border-left:0px;border-right:0px;border-top:0px;');
        jQuery('#existdata').css('display', 'none');
        jQuery('#newdata').css('display', 'block');
        saveoption = "new";
        }
    else
        {
        document.getElementById('existcollection').setAttribute("style","position:relative;background:white;float:left;width:224px;z-index:5;border:solid #505050 1px;border-right:0px;border-bottom:0px;-webkit-border-top-left-radius: 5px;-webkit-bordertop-right-radius: 5px;-khtml-border-top-left-radius: 5px;-khtml-border-top-right-radius: 5px;-moz-border-radius-topleft: 5px;-moz-border-radius-topright: 5px;border-top-left-radius: 5px;border-top-right-radius: 5px;");
        document.getElementById('newcollection').setAttribute("style","position:relative;float:left;width:174px;z-index:5;background:#F8F8F8;border:solid #505050 1px;border-left:0px;border-right:0px;border-top:0px;");
        jQuery('#existdata').css('display', 'block');
        jQuery('#newdata').css('display', 'none');
        saveoption = "exist";
        }
}

// *!* ################ annotation- functions in Image- Viewport ################ *!*
// prepare to create an annotation on the image
function prepareAnno(lang){
    // first check the coordinates
    if(checkCoords(lang))
    {
    // destroy the Jcrop function
    api.destroy();
    api = null;
    // get the coordinates
    var left = parseInt(document.getElementById('x1').value);
    var topinput = parseInt(document.getElementById('y1').value)+parseInt(document.getElementById('h').value)+1;
    var topselected = parseInt(document.getElementById('y1').value);
    var width = parseInt(document.getElementById('w').value);
    var height = parseInt(document.getElementById('h').value);
    // show the annotation- tools
    jQuery('#annotationfield').val('');
    jQuery('#directanno').css('display', 'block');
    jQuery('#directanno').css('left', left);
    jQuery('#directanno').css('top', topinput);
    jQuery('#directselected').css('display', 'block');
    jQuery('#directselected').css('left', left);
    jQuery('#directselected').css('top', topselected);
    jQuery('#directselected').css('width', width);
    jQuery('#directselected').css('height', height);
    }
};

// cancel process to create an annotation 
function cancelAnno(lang){
    startCrop(mode, lang);
    jQuery('.hiddenButton').css('display', 'none');
    jQuery('#annotationfield').val('');
}

// store the user's annotation in his userfile
function storeAnno(user, archive, fond, charter, role, lang){
        if(checkCoords(lang))
        {
        // get image informations - coordinates, src- code
        var url = document.getElementById("img").getAttribute("src");
        var multifactor = getImgSize(document.getElementById('img').src);
        var x1 = Math.round(parseInt(document.getElementById('x1').value));
        var x2 = Math.round(parseInt(document.getElementById('h').value));
        var y1 = Math.round(parseInt(document.getElementById('y1').value));
        var y2 = Math.round(parseInt(document.getElementById('w').value));
        var nx1 = Math.round(parseInt(document.getElementById('x1').value)*multifactor);
        var ny1 = Math.round(parseInt(document.getElementById('y1').value)*multifactor);
        var nx2 = Math.round(parseInt(document.getElementById('h').value)*multifactor);
        var ny2 = Math.round(parseInt(document.getElementById('w').value)*multifactor);
        // size is important to create an ID in DB
        var size = ny2+nx2; 
        // get annotationtext        
        var annotation = jQuery('#annotationfield').val();
        // check for the user's input
        if (annotation == '')
            {
            alert('Please insert an annotation into the input field!');
            }
        else
        {
        var parameters = "?!url="+url+"?!x1="+nx1+"?!x2="+nx2+"?!y1="+ny1+"?!y2="+ny2+"?!size="+size+"?!annotation="+annotation;
        var xmlhttp;
        // send request to crop script
        if (window.XMLHttpRequest)
            {// code for IE7+, Firefox, Chrome, Opera, Safari
                xmlhttp=new XMLHttpRequest();
            }
        else
            {// code for IE6, IE5
                xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
            } 
        if(mode == "fond") 
        {        
        xmlhttp.open("POST","../../../service/crop?type=postAnno&amp;user="+user,true);
        }
        else 
        {
        xmlhttp.open("POST","../../service/crop?type=postAnno&amp;user="+user,true);
        }
        loadFadeIn();
        document.getElementById("loadtext").innerHTML = geti18nText(lang, 'saving-data');
        xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
        xmlhttp.onreadystatechange=function(){
        if (xmlhttp.readyState==4)
            {
             if (xmlhttp.status==200)
                 { 
                    var breadcrump = document.createElement("div");
                    breadcrump.innerHTML = xmlhttp.responseText;
                    var all = document.getElementById("privatAnnos").childNodes;
                    // define ID because of existing elements
                    var index = 0;
                    for(x=0;x<all.length;x++)
                        {
                        if(all[x].nodeType == 1)
                             index++;
                        }
                    var newid = index+1;
                    
                    var deletetool = document.createElement("p");
                    // functions
                    var deletestring = "deleteAnno('"+mode+"','"+breadcrump.childNodes[0].childNodes[0].nodeValue+"', '"+user+"', '"+lang+"')"
                    var editstring = "prepareEditAnno('"+mode+"','"+breadcrump.childNodes[0].childNodes[0].nodeValue+"', '"+user+"', '"+archive+"' ,'"+fond+"' ,'"+charter+"' , 'privat', '"+newid+"', '"+role+"', '"+lang+"')"
                    var publishstring = "askToPublish('"+mode+"', '"+breadcrump.childNodes[0].childNodes[0].nodeValue+"', '"+user+"' , '"+archive+"' ,'"+fond+"' ,'"+charter+"' ,'"+newid+"', '"+role+"', '"+lang+"')"
                    
                    // create tools
                    // delete
                    deletetool.setAttribute('ONCLICK', deletestring);
                    deletetool.setAttribute('STYLE', "position:relative;left:8px;float:left;");
                    var deleteid = "deltool"+newid;
                    deletetool.setAttribute('ID', deleteid);
                        var deleteimg = document.createElement("IMG");
                        deleteimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/remove')
                        deleteimg.setAttribute('STYLE', 'width:13px;')
                        deleteimg.setAttribute('TITLE', 'Delete Annotation')
                    deletetool.appendChild(deleteimg);
                    
                    //edit
                    var edittool = document.createElement("p");
                    edittool.setAttribute('ONCLICK', editstring);
                    edittool.setAttribute('STYLE', "position:relative;left:6px;float:left;");
                    var editid = "edittool"+newid;
                    edittool.setAttribute('ID', editid);
                        var editimg = document.createElement("IMG");
                        editimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/button_edit')
                        editimg.setAttribute('STYLE', 'width:13px;')
                        editimg.setAttribute('TITLE', 'Edit Annotation')
                    edittool.appendChild(editimg);
                    
                    //publish
                    var publishtool = document.createElement("p");
                    publishtool.setAttribute('ONCLICK', publishstring);
                    publishtool.setAttribute('STYLE', "position:relative;left:4px;float:left;");
                    var pubid = "pubtool"+newid;
                    publishtool.setAttribute('ID', pubid);
                        var publishimg = document.createElement("IMG");
                        publishimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/export')
                        publishimg.setAttribute('STYLE', 'width:13px;')
                        publishimg.setAttribute('TITLE', 'Publish Annotation')
                    publishtool.appendChild(publishimg);
                    
                    // define style and mouse actions
                    var fieldid = "directannofield"+newid; 
                    var textid = "directannotext"+newid;
                    var toolsid = "annotools"+newid;
                    var fieldstyle = "left:"+x1+"px;top:"+y1+"px;height:"+x2+"px;width:"+y2+"px;display:none;position:absolute;border:solid red 1px;-moz-border-radius:3px;-webkit-border-radius:3px;-khtml-border-radius:3px;border-radius:3px;"
                    var texttop = parseInt(y1)+parseInt(x2)+2;
                    var textstyle = "padding:3px;max-width:400px;z-index:1;-moz-border-radius:3px;-webkit-border-radius:3px;-khtml-border-radius:3px;border-radius:3px;display:none;position:absolute;background-color:rgb(240,243,226);left:"+x1+"px;top:"+texttop+"px;"
                    var toolstop = parseInt(y1)-25;
                    var toolsleft = parseInt(x1)+parseInt(y2);
                    var toolsstyle = "background: rgba(0, 0, 0, 0.0);z-index:1;display:none;position:absolute;left:"+toolsleft+"px;top:"+toolstop+"px;"
                    var onmouseover = "jQuery('#directannotext"+newid+"').css('display', 'block');jQuery('#directannofield"+newid+"').css('border-color','black');jQuery('#annotools"+newid+"').css('display', 'block');"
                    var onmouseout = "jQuery('#annotools"+newid+"').css('display', 'none');jQuery('#directannotext"+newid+"').css('display', 'none');jQuery('#directannofield"+newid+"').css('border-color','red');"
                    
                    // create annotationfield
                    var annofield = document.createElement("div");
                    annofield.setAttribute('CLASS', 'direct');
                    annofield.setAttribute('ID', fieldid);
                    annofield.setAttribute('STYLE', fieldstyle);
                    annofield.setAttribute('ONMOUSEOVER', onmouseover);
                    annofield.setAttribute('ONMOUSEOUT', onmouseout);                    
                    
                    // create textfield
                    var annotext = document.createElement("div");
                    annotext.setAttribute('ID', textid);
                    annotext.setAttribute('STYLE', textstyle);
                    annotext.setAttribute('ONMOUSEOVER', onmouseover);
                    annotext.setAttribute('ONMOUSEOUT', onmouseout);
                    annotext.textContent=annotation;
                    
                    // coolect tools for main tool tag
                    var annotools = document.createElement("div");
                    annotools.setAttribute('ID', toolsid);
                    annotools.setAttribute('STYLE', toolsstyle);
                    annotools.setAttribute('ONMOUSEOVER', onmouseover);
                    annotools.setAttribute('ONMOUSEOUT', onmouseout);
                    annotools.appendChild(publishtool);
                    annotools.appendChild(edittool);
                    annotools.appendChild(deletetool);
                    
                    // create main div
                    var maindiv = document.createElement("div");
                    maindiv.setAttribute('ID', breadcrump.childNodes[0].childNodes[0].nodeValue);
                    maindiv.setAttribute('NAME', 'AnnoElement');
                    maindiv.appendChild(annofield);
                    maindiv.appendChild(annotext);
                    maindiv.appendChild(annotools);
                    
                    // add new tags to existing elements
                    document.getElementById("privatAnnos").appendChild(maindiv);
                    jQuery('#loadgif').css('display', 'none');
                    document.getElementById("loadtext").innerHTML = geti18nText(lang, 'data-have-been-saved');
                    window.setTimeout(loadFadeOut,4000);
                    jQuery('#annotationfield').val('');
                    jQuery('#directanno').css('display', 'none');
                    jQuery('#directselected').css('display', 'none');
                    jQuery('#selectmodeButton').css('display', 'block');
                    jQuery('#viewmodeButton').css('display', 'none');
                    jQuery('.hiddenButton').css('display', 'none');
                    error = 0;
                  }
             else
                  {
                  error++;
                  if(error < 20)
                      storeAnno(user, archive, fond, charter, role);
                  else
                      {
                      jQuery('#loadgif').css('display', 'none');
                      document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                      window.setTimeout(loadFadeOut,10000);
                      error = 0;
                      }    
                 }
                }
         };
        xmlhttp.send(parameters);
        }
        }
    }

// prepare to edit an annotationtext
function prepareEditAnno(chartercontext, id, user, archive, fond, charter, type, dataid, role, lang){
    // may be store chartercontext - font/ collection
    if(mode==null)
    {
    mode = chartercontext;
    }
    if(type == 'public' || type == 'response')
        {
        var fieldid = "pubannofield"+dataid;
        var textid = "pubannotext"+dataid;
        }
    else if(type == 'edit' || type == 'privat')
        {
        var fieldid = "directannofield"+dataid;
        var textid = "directannotext"+dataid;
        }
    else
        {
        var fieldid = "repannofield"+dataid;
        var textid = "repannotext"+dataid;
        }
    // set position of the inputfield
    var left = parseInt(document.getElementById(fieldid).style.left);
    var top = parseInt(document.getElementById(fieldid).style.top)+parseInt(document.getElementById(fieldid).style.height)+2;
    var updatestring = "updateAnno('"+id+"', '"+dataid+"', '"+user+"', '"+textid+"', '"+archive+"', '"+fond+"', '"+charter+"', '"+type+"', '"+role+"', '"+lang+"');";
    document.getElementById(textid).style.display = 'none';
    jQuery('#directanno').css('display', 'block');
    jQuery('#directanno').css('left', left);
    jQuery('#directanno').css('top', top);
    document.getElementById('annotationfield').value = document.getElementById(textid).textContent;
    document.getElementById('saveanno').removeAttribute('ONCLICK');
     document.getElementById('saveanno').setAttribute('ONCLICK', updatestring);
};

// edit an annotationtext in the DB
function updateAnno(id, dataid, user, textid, archive, fond, charter, type, role, lang){
        
        var annotation = jQuery('#annotationfield').val();
        var parameters = "?!annotation="+annotation;
        // check for the user's input
        if (annotation == '')
            {
            alert(geti18nText(lang, 'please-insert-an-annotation'));
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
        if(mode == 'fond') 
        { 
            if(type == 'privat') 
                {         
                xmlhttp.open("POST","../../../service/crop?type=updateAnno&amp;user="+user+"&amp;id="+id,true);
                }
            else if(type == 'public') 
                {
                xmlhttp.open("POST","../../../service/publishannotation?type=updateAnno&amp;id="+id+"&amp;archive="+archive+"&amp;fond="+fond+"&amp;charter="+charter+"&amp;status=direct",true);
                }
            else
                {         
                xmlhttp.open("POST","../../../service/crop?type=editAnno&amp;user="+user+"&amp;id="+id+"&amp;status=privat",true);
                }
        }
        loadFadeIn();
        document.getElementById("loadtext").innerHTML = geti18nText(lang, 'updating-data');
        xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
        xmlhttp.onreadystatechange=function(){
        if (xmlhttp.readyState==4)
            {
             if (xmlhttp.status==200)
                 {
                 // update the text of the annotationfield
                 var savestring = "storeAnno('"+user+"','"+archive+"','"+fond+"','"+charter+"','"+role+"');";
                 document.getElementById(textid).textContent = annotation;                 
                 document.getElementById('saveanno').removeAttribute('ONCLICK');
                 document.getElementById('saveanno').setAttribute('ONCLICK', savestring);
                 jQuery('#annotationfield').val('');
                 jQuery('#directanno').css('display', 'none');
                 document.getElementById("loadtext").innerHTML = geti18nText(lang, 'data-have-been-saved');
                 window.setTimeout(loadFadeOut,4000);
                 // add the toolbar to the annotation
                 if(type=="edit")
                    {
                    var declineID = "decline"+dataid;
                    var old = document.getElementById(declineID);
                    old.parentNode.removeChild(old); 
                    
                    var deletetool = document.createElement("p");
                    // functions
                    var deletestring = "deleteAnno('"+mode+"','"+id+"', '"+user+"', '"+lang+"')"
                    var editstring = "prepareEditAnno('"+mode+"','"+id+"', '"+user+"', '"+archive+"', '"+fond+"', '"+charter+"', 'privat', '"+dataid+"', '"+role+"', '"+lang+"')"
                    var publishstring = "askToPublish('"+mode+"', '"+id+"', '"+user+"' , '"+archive+"' ,'"+fond+"' ,'"+charter+"' ,'"+dataid+"', '"+role+"', '"+lang+"')"
                    
                    // create tools
                    // delete
                    deletetool.setAttribute('ONCLICK', deletestring);
                    deletetool.setAttribute('STYLE', "position:relative;left:8px;float:left;");
                    var deleteid = "deltool"+dataid;
                    deletetool.setAttribute('ID', deleteid);
                        var deleteimg = document.createElement("IMG");
                        deleteimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/remove')
                        deleteimg.setAttribute('STYLE', 'width:13px;')
                        deleteimg.setAttribute('TITLE', 'Delete Annotation')
                    deletetool.appendChild(deleteimg);
                    
                    //edit
                    var edittool = document.createElement("p");
                    edittool.setAttribute('ONCLICK', editstring);
                    edittool.setAttribute('STYLE', "position:relative;left:6px;float:left;");
                    var editid = "edittool"+dataid;
                    edittool.setAttribute('ID', editid);
                        var editimg = document.createElement("IMG");
                        editimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/button_edit')
                        editimg.setAttribute('STYLE', 'width:13px;')
                        editimg.setAttribute('TITLE', 'Edit Annotation')
                    edittool.appendChild(editimg);
                    
                    //publish
                    var publishtool = document.createElement("p");
                    publishtool.setAttribute('ONCLICK', publishstring);
                    publishtool.setAttribute('STYLE', "position:relative;left:4px;float:left;");
                    var pubid = "pubtool"+dataid;
                    publishtool.setAttribute('ID', pubid);
                        var publishimg = document.createElement("IMG");
                        publishimg.setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/export')
                        publishimg.setAttribute('STYLE', 'width:13px;')
                        publishimg.setAttribute('TITLE', 'Publish Annotation')
                    publishtool.appendChild(publishimg);
                    
                    // add tools to annotation
                    var tooldivID = "annotools"+dataid;
                    document.getElementById(tooldivID).appendChild(publishtool);
                    document.getElementById(tooldivID).appendChild(edittool);
                    document.getElementById(tooldivID).appendChild(deletetool);
                    }
                    error = 0;
                 }
             else
                 {
                    error++;
                    if(error < 20)
                        updateAnno(id, dataid, user, textid, archive, fond, charter, type, role, lang);
                    else
                        {
                        jQuery('#loadgif').css('display', 'none');
                        document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                        window.setTimeout(loadFadeOut,10000);
                        error = 0;
                        } 
                 }
              }
        };
        xmlhttp.send(parameters);
        }
};

// send a request to the moderator to publish the annotation
function askToPublish(chartercontext, id, user, archive, fond, charter, number, role, lang){
        // may be store chartercontext - font/ collection
        if(mode==null)
            {
            mode = chartercontext;
            }
        var xmlhttp;
        if (window.XMLHttpRequest)
            {// code for IE7+, Firefox, Chrome, Opera, Safari
                xmlhttp=new XMLHttpRequest();
            }
        else
            {// code for IE6, IE5
                xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
            }
        loadFadeIn();
        jQuery('#directanno').css('display', 'none');
        document.getElementById("loadtext").innerHTML = geti18nText(lang, 'sending-request');
        jQuery('#loadgif').css('display', 'block');
        jQuery('#loadtext').css('display', 'block');
        // send request to crop script
        if(mode == "fond") 
        {
            if(role == 'user')
                {
                xmlhttp.open("GET","../../../service/publishannotation?type=ask&amp;id="+id+"&amp;user="+user+"&amp;archive="+archive+"&amp;fond="+fond+"&amp;charter="+charter+"&amp;requestid="+number,true);
                }
            else
                {
                xmlhttp.open("GET","../../../service/publishannotation?type=directPub&amp;id="+id+"&amp;user="+user+"&amp;archive="+archive+"&amp;fond="+fond+"&amp;charter="+charter,true);
                }
        }
        else
        {
            if(role == 'user')
                {
                xmlhttp.open("GET","../../service/publishannotation?type=ask&amp;id="+id+"&amp;user="+user+"&amp;archive="+archive+"&amp;fond="+fond+"&amp;charter="+charter+"&amp;requestid="+number,true);
                }
            else
                {
                xmlhttp.open("GET","../../service/publishannotation?type=directPub&amp;id="+id+"&amp;user="+user+"&amp;archive="+archive+"&amp;fond="+fond+"&amp;charter="+charter,true);
                }
        }
        xmlhttp.onreadystatechange=function(){
        if (xmlhttp.readyState==4)
            {
             if (xmlhttp.status==200)
                 {
                 jQuery('#loadgif').css('display', 'none');
                 var delid = "deltool"+number;
                 var editid = "edittool"+number;
                 var pubid = "pubtool"+number;
                 var oldp = document.getElementById(pubid);
                 oldp.parentNode.removeChild(oldp);
                 if(role == 'user')
                    {
                    var toolid = "annotools"+number;
                    var oldd = document.getElementById(delid);
                    oldd.parentNode.removeChild(oldd); 
                    var olde = document.getElementById(editid);
                    olde.parentNode.removeChild(olde);
                    var span = document.createElement("span"); 
                    span.setAttribute('class', 'release');
                    span.innerHTML = geti18nText(lang, 'wait-for-release');
                    document.getElementById(toolid).appendChild(span);                 
                    // request has been succesfull transmitted to moderator
                    document.getElementById("loadtext").innerHTML = geti18nText(lang, 'request-sent-to-moderator');
                    window.setTimeout(loadFadeOut,4000);
                    }
                 else
                    {
                    var editstring = "prepareEditAnno('"+mode+"', '"+id+"', '"+user+"', '"+archive+"', '"+fond+"', '"+charter+"', 'public', '"+number+"', 'default', '"+lang+"')"
                    var deletestring = "deletePublicAnno('"+mode+"', '"+id+"', '"+user+"', '"+archive+"', '"+fond+"', '"+charter+"', 'charter', '"+lang+"')"
                    document.getElementById(editid).removeAttribute('ONCLICK');
                    document.getElementById(editid).setAttribute('ONCLICK', editstring);
                    document.getElementById(delid).removeAttribute('ONCLICK');
                    document.getElementById(delid).setAttribute('ONCLICK', deletestring);
                    document.getElementById("loadtext").innerHTML = geti18nText(lang, 'the-annotation-has-been-released');
                    window.setTimeout(loadFadeOut,4000)
                    } 
                    error = 0;
                  }
             else
                  {
                  error++;
                  if(error < 20)
                      askToPublish(chartercontext, id, user, archive, fond, charter, number, role, lang);
                  else
                      {
                      jQuery('#loadgif').css('display', 'none');
                      document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                      window.setTimeout(loadFadeOut,10000);
                      error = 0;
                      }                    
                  }
            }
         else
             {
             jQuery('#cropeditor').css('display', 'none');
             }
         };
        xmlhttp.send();
    };

// reprint annotations after zooming   
function reprintAnnos(size, oldsize){
    // calculate the zooming factor
    var multifactor = size/oldsize;
    // go through all privat annotations
    var all = document.getElementById("privatAnnos").childNodes;
    var number = 0;
    for(x=0;x<all.length;x++)
        {
        if(all[x].nodeType == 1)
             number++;
        }
    // calculate the new coordinates
    for(i=1;i<=number;i++)
        {
        var field = "directannofield"+i;
        var tools = "annotools"+i;
        var text = "directannotext"+i;
        document.getElementById(field).style.top = Math.round(parseInt(document.getElementById(field).style.top)*multifactor)+"px";
        document.getElementById(field).style.left = Math.round(parseInt(document.getElementById(field).style.left)*multifactor)+"px";
        document.getElementById(field).style.width = Math.round(parseInt(document.getElementById(field).style.width)*multifactor)+"px";        
        document.getElementById(field).style.height = Math.round(parseInt(document.getElementById(field).style.height)*multifactor)+"px";
        document.getElementById(tools).style.top = Math.round(parseInt(document.getElementById(tools).style.top)*multifactor)+"px";
        document.getElementById(tools).style.left = Math.round(parseInt(document.getElementById(tools).style.left)*multifactor)+"px";
        document.getElementById(text).style.top = Math.round(parseInt(document.getElementById(text).style.top)*multifactor)+"px";
        document.getElementById(text).style.left = Math.round(parseInt(document.getElementById(text).style.left)*multifactor)+"px";
        }
    // go through all public annotations
    var allpub = document.getElementById("publicAnnos").childNodes;
    var number = 0;
    for(x=0;x<allpub.length;x++)
        {
        if(allpub[x].nodeType == 1)
             number++;
        }
    // calculate the new coordinates
    for(i=1;i<=number;i++)
        {
        var field = "pubannofield"+i;
        var tools = "pubtools"+i;
        var text = "pubannotext"+i;
        document.getElementById(field).style.top = Math.round(parseInt(document.getElementById(field).style.top)*multifactor)+"px";
        document.getElementById(field).style.left = Math.round(parseInt(document.getElementById(field).style.left)*multifactor)+"px";
        document.getElementById(field).style.width = Math.round(parseInt(document.getElementById(field).style.width)*multifactor)+"px";        
        document.getElementById(field).style.height = Math.round(parseInt(document.getElementById(field).style.height)*multifactor)+"px";
        document.getElementById(tools).style.top = Math.round(parseInt(document.getElementById(tools).style.top)*multifactor)+"px";
        document.getElementById(tools).style.left = Math.round(parseInt(document.getElementById(tools).style.left)*multifactor)+"px";
        document.getElementById(text).style.top = Math.round(parseInt(document.getElementById(text).style.top)*multifactor)+"px";
        document.getElementById(text).style.left = Math.round(parseInt(document.getElementById(text).style.left)*multifactor)+"px";
        }
    document.getElementById("directselected").style.top = Math.round(parseInt(document.getElementById("directselected").style.top)*multifactor)+"px";
    document.getElementById("directselected").style.left = Math.round(parseInt(document.getElementById("directselected").style.left)*multifactor)+"px";
    document.getElementById("directselected").style.width = Math.round(parseInt(document.getElementById("directselected").style.width)*multifactor)+"px";
    document.getElementById("directselected").style.height = Math.round(parseInt(document.getElementById("directselected").style.height)*multifactor)+"px";
    document.getElementById("directanno").style.top = Math.round(parseInt(document.getElementById("directanno").style.top)*multifactor)+"px";
    document.getElementById("directanno").style.left = Math.round(parseInt(document.getElementById("directanno").style.left)*multifactor)+"px";
 };

// delete an annotation
function deleteAnno(chartercontext, id, user, lang){
    // ask the user to confirm this step
    if(confirm(geti18nText(lang, 'delete-annotation-question')))
    { 
        // may be store chartercontext - font/ collection
        if(mode==null)
            {
            mode = chartercontext;
            }
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
        if(mode == 'fond') 
        {        
            xmlhttp.open("GET","../../../service/crop?type=deleteAnno&amp;id="+id+"&amp;user="+user,true);
        }
        else 
        {
            xmlhttp.open("GET","../../service/crop?type=deleteAnno&amp;id="+id+"&amp;user="+user,true);
        }
        xmlhttp.onreadystatechange=function(){
        if (xmlhttp.readyState==4)
            {
             if (xmlhttp.status==200)
                 {
                    var breadcrump = document.createElement("div");
                    breadcrump.innerHTML = xmlhttp.responseText;
                    // delete annotation on the screen
                    if (breadcrump.childNodes[0].childNodes[0].nodeValue == "delete")
                        {   
                            loadFadeIn();
                            document.getElementById("loadtext").innerHTML = geti18nText(lang, 'data-have-been-successful-removed');
                            window.setTimeout(loadFadeOut,4000);
                            old = document.getElementById(id);
                            old.parentNode.removeChild(old);
                        }
                    else 
                        {
                        loadFadeIn();
                        document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                        window.setTimeout(loadFadeOut,10000);
                        }
                    error = 0;
                 }
             else
                 {
                    error++;
                    if(error < 20)
                        deleteAnno(chartercontext, id, user, lang);
                    else
                        {
                        loadFadeIn();
                        document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                        window.setTimeout(loadFadeOut,10000);
                        error = 0;
                        }   
                 }
            }
        }
        xmlhttp.send();
    }
};

// delete public annotation
function deletePublicAnno(chartercontext, id, user, archive, fond, charter, type, lang) {
    // ask the user to confirm this step
    if(confirm(geti18nText(lang, 'delete-annotation-question')))
    { 
    // may be store chartercontext - font/ collection
        if(mode==null)
            {
            mode = chartercontext;
            }
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
        if(mode == 'fond') 
        {        
            xmlhttp.open("GET","../../../service/publishannotation?type=deleteAnno&amp;id="+id+"&amp;user="+user+"&amp;archive="+archive+"&amp;fond="+fond+"&amp;charter="+charter,true);
        }
        else 
        {
            if(type == 'charter')
                {
                xmlhttp.open("GET","../../service/publishannotation?type=deleteAnno&amp;id="+id+"&amp;user="+user+"&amp;archive="+archive+"&amp;fond="+fond+"&amp;charter="+charter,true);
                }
            else
                {
                xmlhttp.open("GET","service/publishannotation?type=deleteAnno&amp;id="+id+"&amp;user="+user+"&amp;archive="+archive+"&amp;fond="+fond+"&amp;charter="+charter,true);
                }
        }
        xmlhttp.onreadystatechange=function(){
        if (xmlhttp.readyState==4)
            {
             
             if (xmlhttp.status==200)
                 {
                    var breadcrump = document.createElement("div");
                    breadcrump.innerHTML = xmlhttp.responseText;
                    // delete annotation on the screen
                    if (breadcrump.childNodes[0].childNodes[0].nodeValue == "delete")
                        {
                        if(type == 'request')
                            {
                            var delID = "rep"+id;
                            }
                        else 
                            {
                            var delID = "pub"+id;
                            }
                        loadFadeIn();
                        document.getElementById("loadtext").innerHTML = geti18nText(lang, 'data-have-been-successful-removed');
                        window.setTimeout(loadFadeOut,4000);
                        old = document.getElementById(delID);
                        old.parentNode.removeChild(old);
                        error = 0;
                        }
                   }
             else
                 {
                    error++;
                    if(error < 20)
                        deletePublicAnno(chartercontext, id, user, archive, fond, charter, type, lang);
                    else
                        {
                        loadFadeIn();
                        document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                        window.setTimeout(loadFadeOut,10000);
                        error = 0;
                        }                         
                   }
                 }
        }
        xmlhttp.send();
     }
};

// critizise an annotation and send a report to the moderator - open the a comment field an prepare to send a request
function reportAnno(chartercontext, dataid, user, archive, fond, charter, requestid, lang){
        // may be store chartercontext - font/ collection
        if(mode==null)
            {
            mode = chartercontext;
            }
        var fieldid = "pubannofield"+requestid;
        var textid = "pubannotext"+requestid;
        // set position of the inputfield
        var left = parseInt(document.getElementById(fieldid).style.left);
        var top = parseInt(document.getElementById(fieldid).style.top)+parseInt(document.getElementById(fieldid).style.height)+1;
        var reportstring = "sendReport('"+dataid+"', '"+user+"', '"+archive+"', '"+fond+"', '"+charter+"', '"+requestid+"', '"+lang+"');";
        document.getElementById(textid).style.display = 'none';
        jQuery('#directanno').css('display', 'block');
        jQuery('#directanno').css('left', left);
        jQuery('#directanno').css('top', top);
        document.getElementById('saveanno').removeAttribute('ONCLICK');
        document.getElementById('saveanno').setAttribute('ONCLICK', reportstring);        
}

// send the report request to the moderator
function sendReport(dataid, user, archive, fond, charter, requestid, lang){
        // get reporttext        
        var critic = jQuery('#annotationfield').val();
        // check for the user's input
        if (critic == '')
            {
            alert(geti18nText(lang, 'please-insert-a-comment'));
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
        jQuery('#directanno').css('display', 'none');
        document.getElementById("loadtext").innerHTML = geti18nText(lang, 'sending-request');
        loadFadeIn();
        jQuery('#loadgif').css('display', 'block');
        jQuery('#loadtext').css('display', 'block');
        // send request to crop script
        if(mode == "fond") 
        {
        xmlhttp.open("POST","../../../service/publishannotation?type=report&amp;id="+dataid+"&amp;user="+user+"&amp;archive="+archive+"&amp;fond="+fond+"&amp;charter="+charter,true);
        }
        else
        {
        xmlhttp.open("POST","../../service/publishannotation?type=report&amp;id="+dataid+"&amp;user="+user+"&amp;archive="+archive+"&amp;fond="+fond+"&amp;charter="+charter,true);
        }
        xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
        xmlhttp.onreadystatechange=function(){
        if (xmlhttp.readyState==4)
            {
             if (xmlhttp.status==200)
                 {
                 var savestring = "storeAnno('"+user+"','"+archive+"','"+fond+"','"+charter+"');";
                 document.getElementById('saveanno').removeAttribute('ONCLICK');
                 document.getElementById('saveanno').setAttribute('ONCLICK', savestring);
                 jQuery('#annotationfield').val('');
                 jQuery('#directanno').css('display', 'none');
                 jQuery('#loadgif').css('display', 'none');
                 document.getElementById("loadtext").innerHTML = geti18nText(lang, 'sending-request');
                 window.setTimeout(loadFadeOut,4000);
                 error = 0;
                    }
             else
                 {
                 error++;
                 if(error < 20)
                   sendReport(dataid, user, archive, fond, charter, requestid, lang);
                 else
                   {
                   jQuery('#loadgif').css('display', 'none');
                   document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                   window.setTimeout(loadFadeOut,10000);
                   error = 0;
                   }
                 }
            }
         };
        xmlhttp.send(critic);
        }
};
