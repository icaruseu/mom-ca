var api, error = 0, saveoption = "new", interval, IEparser = false, singleID, projectname; // api is the jcrop object, mode is the chartercontext

// *!* ################ helper- functions ################ *!*
// load doc
function loadDoc(platformid){
	projectname = platformid;
	jQuery('#img-draggable').draggable();
};

// change the image in the viewport
function changeImageView(id, changeType, lang){
        var number = $('#cropimg').attr("alt");
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
        xmlhttp.open("GET","service/publish-cropimages?type=change&amp;id="+id+"&amp;number="+number+"&amp;changeType="+changeType, true);
        xmlhttp.onreadystatechange=function(){
        if (xmlhttp.readyState==4)
            {
             if (xmlhttp.status==200)
                 { 
                 		 var xmlDoc = jQuery.parseXML(xmlhttp.response);
                     var breadcrump = document.createElement("div");
                     breadcrump.innerHTML = xmlhttp.responseText;
                     var nameID = "colimage"+id;
                     var noteID = "colnote"+id;
                      // load the image into the viewport
                      if(document.getElementById("cropimg")!=null)
                            {
                            old = document.getElementById("cropimg");
                            old.parentNode.removeChild(old);
                            }
                    document.getElementById("img-draggable").appendChild(breadcrump.childNodes[0].childNodes[0]);
                    document.getElementById("url").innerHTML = xmlDoc.getElementsByTagName('url')[0].childNodes[0].nodeValue;
                    document.getElementById("username").innerHTML = xmlDoc.getElementsByTagName('user')[0].childNodes[0].nodeValue;
                    if (!xmlDoc.getElementsByTagName('imagename')[0].hasChildNodes())
                        {
                        document.getElementById(nameID).innerHTML = ""
                        if(xmlDoc.getElementsByTagName('imagenote')[0].hasChildNodes())
                        	document.getElementById(noteID).innerHTML = xmlDoc.getElementsByTagName('imagenote')[0].childNodes[0].nodeValue;
                        else 
                        	document.getElementById(noteID).innerHTML = "";
                        }
                      else
                        {
                        document.getElementById(nameID).innerHTML = xmlDoc.getElementsByTagName('imagename')[0].childNodes[0].nodeValue;
                        if(xmlDoc.getElementsByTagName('imagenote')[0].hasChildNodes())
                        	document.getElementById(noteID).innerHTML = xmlDoc.getElementsByTagName('imagenote')[0].childNodes[0].nodeValue;
                        else 
                        	document.getElementById(noteID).innerHTML = "";
                        }
                    error = 0;
                 }
             else
                 {
                    error++;
                    if(error < 20)
                        changeImage(id, changeType, lang);
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

// start save process
function startSave(id, name, type){
    singleID = id;
    var imagenameID = "colimage"+id;
    var noteID = "colnote"+id;
    $('#bobble').css('display', 'block');
    $('#bobblecorner').css('display', 'block');
    $("#imagenametext").val(document.getElementById(imagenameID).textContent);
    $("#notetext").val(document.getElementById(noteID).textContent);
    $("#typetext").val(type);
    $("#nametext").val(name);
}

// zoom image
function publicZoom(type){
    var newWidth, newHeight;
    oldWidth = $('#cropimg').width();
    oldHeight = $('#cropimg').height();
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
   $('#cropimg').width(newWidth);
   $('#cropimg').height(newHeight);
}


// *!* ################ Public Image Collection- functions ################ *!*
// save public collection to user collections
function saveCollection(number, id, user, lang){
     var xmlhttp;
     if (window.XMLHttpRequest)
            {// code for IE7+, Firefox, Chrome, Opera, Safari
                xmlhttp=new XMLHttpRequest();
            }
    else
            {// code for IE6, IE5
                xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
            }
    xmlhttp.open("POST","service/publish-cropimages?type=saveCollection&amp;id="+id+"&amp;user="+user,true);
    xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
    xmlhttp.onreadystatechange=function(){
    if (xmlhttp.readyState==4)
          {
           if (xmlhttp.status==200)
                 {
                    var buttonID = '#saveCollection'+number;
                    $(buttonID).css('display','none');
                    alert(geti18nText(lang, 'saved-to-user-collection'));
                 }
             else
                 {
                 error++;
                 if(error < 20)
                   saveCollection(number, id, user, lang);
                 else
                   {
                   $('#loadgif').css('display', 'none');
                   document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                   error = 0;
                   }
                 }
            }
       }
     xmlhttp.send();
}

// delete a public cropped image of a public collection
function deletePublicImage(id, entryid, lang){
    if(confirm('Do you really want to delete this image?'))
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
        xmlhttp.open("GET","service/publish-cropimages?type=delete&amp;id="+id,true);
        xmlhttp.onreadystatechange=function(){
        if (xmlhttp.readyState==4)
            {
             var breadcrump = document.createElement("div");
             breadcrump.innerHTML = xmlhttp.responseText;
             $('#loadtext').css('display', 'block');
             if (xmlhttp.status==200)
                 {
                    document.getElementById("loadtext").innerHTML = geti18nText(lang, 'data-have-been-successful-removed');
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
										error = 0;
                 }
             else
                 {
                    error++;
                    if(error < 20)
                        deletePublic(id);
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

// remove public cropped image from a private (existing) collection
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
        $('#loadtext').css('display', 'block');
        if (xmlhttp.status==200)
             {
              // delete the cropped image on the screen
              if (breadcrump.childNodes[0].childNodes[0].nodeValue == "delete")
                 {
                 document.getElementById("loadtext").innerHTML = geti18nText(lang, 'data-have-been-successful-removed');
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
                 $(addid).css('display', 'block');
                 $(releaseid).css('display', 'none');
                 error = 0;
                 }
             else
                 {
                 error++;
                 if(error < 20)
                   removeCrop(type, id, user, buttonid, lang)
                 else
                    {
                    $('#loadgif').css('display', 'none');
                    document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                    error = 0;
                    }
                 }
             }
        }
        }
   xmlhttp.send();
}

// add cropped image to a private (existing) collection
function addCrop(id, url, user, name, type, lang){
    var imagename = $('#imagenametext').val();
    var imagenote = $('#notetext').val();
    url = document.getElementById("url").getAttribute("HREF");
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
        xmlhttp.open("POST","service/crop?type=post&amp;functype="+functype+"&amp;user="+user+"&amp;id="+id,true);
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
                        $('#loadgif').css('display', 'none');
                        // insert new data into the dropdown- lists of existing datas
                        document.getElementById("loadtext").innerHTML = geti18nText(lang, 'data-have-been-successful-updated');
                        var relstring = "removeCrop('no', '"+outerid+"', '"+user+"', '"+id+"', '"+lang+"')";
                        // configure buttons
                        $(addid).css('display', 'none');
                        $(releaseid).css('display', 'block');
                        
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
                       addCrop(id, url, user, name, type, lang);
                     else
                            {
                            $('#loadgif').css('display', 'none');
                            document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                            error = 0;
                            }
                     }
                }
           else { 
                    $('#loading').css('display', 'block');
                    document.getElementById("loadtext").innerHTML = geti18nText(lang, 'saving-data');
                }
             };
            xmlhttp.send(parameters);
      }
}

// store the user's cropped image in his userfile    
function storeCrop(url, user, lang){
        var name = $('#nametext').val();
        var type = $('#typetext').val();
        var imagename = $('#imagenametext').val();
        var imagenote = $('#notetext').val();
        url = document.getElementById("url").getAttribute("HREF");
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
            xmlhttp.open("POST","service/crop?type=post&amp;functype="+functype+"&amp;user="+user,true);
            xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
            xmlhttp.onreadystatechange=function(){
            if (xmlhttp.readyState==4)
                {
                 if (xmlhttp.status==200)
                     { 
                        $('#loadgif').css('display', 'none');
                        var xmlDoc = jQuery.parseXML(xmlhttp.response);
                        if (xmlDoc.childNodes[0].nodeName == "data")
                        {
                            var outerid = xmlDoc.getElementsByTagName('dataid')[0].childNodes[0].nodeValue;
                            var id = xmlDoc.getElementsByTagName('cropid')[0].childNodes[0].nodeValue;
                            var newid = Math.floor((Math.random()*1000)+500)+Math.floor((Math.random()*1000)+500);
                            var addID = type+name+id;
                            // insert new data into the dropdown- lists of existing datas
                            document.getElementById("loadtext").innerHTML = geti18nText(lang, 'data-have-been-saved');
                            var viewid = 'view'+newid;
                            var toolid = 'tool'+newid;
                            var adderid = 'add'+id;
                            var releaseid = 'release'+id;
                            
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
                            
                            
                            var addstring = "addCrop('"+id+"', 'pub', '"+user+"', '"+name+"', '"+type+"', '"+lang+"')";
                            
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
                            
                            var releasebutton = document.createElement("p");
                            releasebutton.setAttribute('ID', releaseid);
                            releasebutton.setAttribute('CLASS', 'button');
                            releasebutton.setAttribute('ONCLICK', '');
                            releasebutton.setAttribute('STYLE', 'position:absolute;left:293px;top:-8px;width:19px;height:15px;display:none;');
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
                            $('#loadgif').css('display', 'none');
                            // define ID because of existing elements
                            var outerid = xmlDoc.getElementsByTagName('dataid')[0].childNodes[0].nodeValue;
                            var id = xmlDoc.getElementsByTagName('cropid')[0].childNodes[0].nodeValue;
                            document.getElementById("loadtext").innerHTML = geti18nText(lang, 'data-have-been-successful-updated');
                            var newid = Math.floor((Math.random()*1000)+500)+Math.floor((Math.random()*1000)+500);
                            var viewid = 'view'+newid;
                            var toolid = 'tool'+newid;
                            var addid = '#add'+id;
                            var releaseid = '#release'+id;
                            
                            // configure buttons
                            $(addid).css('display', 'none');
                            $(releaseid).css('display', 'block');
                            
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
                            
                            // exchange buttons
                            var relbutton = 'release'+id;
                            var relstring = "removeCrop('"+outerid+"', '"+user+"', '"+id+"')";
                            document.getElementById(relbutton).removeAttribute('ONCLICK');
                            document.getElementById(relbutton).setAttribute('ONCLICK', relstring);
                            }
                        error = 0;
                        }
                 else
                     {
                     error++;
                     if(error < 20)
                       storeCropping(url, user, lang);
                     else
                       {
                       $('#loadgif').css('display', 'none');
                       document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                       error = 0;
                       }
                     }
                }
           else { 
                    $('#loading').css('display', 'block');
                    document.getElementById("loadtext").innerHTML = geti18nText(lang, 'saving-data');
                    }
             };
            xmlhttp.send(parameters);
            }
            }
    }

// prepare to edit collection string values
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

// edit collection string values
function editPubCollection(typus, number, id, dataid, lang){
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
    xmlhttp.open("POST","service/publish-cropimages?type=editCollection&amp;functype="+typus+"&amp;id="+id,true);
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
                    document.getElementById(textID).textContent = " "+newtext;
                    $(editID).css('display','none');
                 }
             else
                 {
                 error++;
                 if(error < 20)
                   editPubCollection(typus, number, id, dataid, lang);
                 else
                   {
                   document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                   error = 0;
                   }
                 }
            }
       }
     xmlhttp.send(parameters);
}

