var api, mode, workmode="Viewmode", error = 0, saveoption = "new", interval, IEparser = false, singleID, projectname; // api is the jcrop object, mode is the chartercontext

// load doc
function loadDoc(platformid){
	projectname = platformid;
};

// *!* ################ helper- functions ################ *!*
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

// zoom image on the charter widget 
function requestZoom(type, id, stype){
        // remove the old image and create a new one with the new size
        var newWidth, newHeight;
        if(stype == "user")
        {
        var rid = "requestimg"+id;
        var queryid = "#requestimg"+id;
        var view = "views"+id;
        var field = "directannofield"+id;
        var text = "directannotext"+id;
        }
        else if(stype == "moderator")
        {
        var rid = "pubimg"+id;
        var queryid = "#pubimg"+id;
        var view = "pub"+id;
        var field = "pubannofield"+id;
        var text = "pubannotext"+id;
        var tool = "pubtools"+id;
        }
        else if(stype == "usercrop")
        {
        var rid = "requestimg"+id;
        var queryid = "#requestimg"+id;
        var view = "views"+id;
        }
        else if(stype == "modcrop")
        {
        var rid = "pubimg"+id;
        var queryid = "#pubimg"+id;
        var view = "pub"+id;
        }
        else if(stype == "send")
        {
        var rid = "sendimg"+id;
        var queryid = "#sendimg"+id;
        var view = "sendview"+id;
        }
        else if(stype == "critic")
        {
        var rid = "criticimg"+id;
        var queryid = "#criticimg"+id;
        var view = "viewscritic"+id;
        var field = "directannofieldcritic"+id;
        var text = "directannotextcritic"+id;
        }
        else
        {
        var rid = "repimg"+id;
        var queryid = "#repimg"+id;
        var view = "rep"+id;
        var field = "repannofield"+id;
        var text = "repannotext"+id;
        var tool = "reptools"+id;
        }
        var src = document.getElementById(rid).getAttribute("SRC");
        var oldWidth = $(queryid).width();
        var oldHeight = $(queryid).height();
        var img=document.createElement("IMG");
        img.setAttribute('SRC', src); 
        img.setAttribute('ID', rid);
        $(queryid).remove();
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
        document.getElementById(view).appendChild(img);
        $(queryid).width(newWidth);
        $(queryid).height(newHeight);
        // reprint the annotation
        // calculate the zooming factor
        if(stype != "usercrop" && stype != "modcrop" && stype != "send")
        {
        var multifactor = newWidth/oldWidth;
        document.getElementById(field).style.top = Math.round(parseInt(document.getElementById(field).style.top)*multifactor)+"px";
        document.getElementById(field).style.left = Math.round(parseInt(document.getElementById(field).style.left)*multifactor)+"px";
        document.getElementById(field).style.width = Math.round(parseInt(document.getElementById(field).style.width)*multifactor)+"px";        
        document.getElementById(field).style.height = Math.round(parseInt(document.getElementById(field).style.height)*multifactor)+"px";
        document.getElementById(text).style.top = Math.round(parseInt(document.getElementById(text).style.top)*multifactor)+"px";
        document.getElementById(text).style.left = Math.round(parseInt(document.getElementById(text).style.left)*multifactor)+"px";
        if(stype != "user" && stype != "critic")
            {
            document.getElementById(tool).style.top = Math.round(parseInt(document.getElementById(tool).style.top)*multifactor)+"px";
            document.getElementById(tool).style.left = Math.round(parseInt(document.getElementById(tool).style.left)*multifactor)+"px";
            }
        }
        else
            {
            var wmargin = ((500-parseInt(newWidth))/2 + (parseInt(newWidth)/8));
            var hmargin = ((300-parseInt(newHeight))/2 + (parseInt(newHeight)/8));
            $(queryid).css('left', wmargin);
            $(queryid).css('position', 'relative');
            $(queryid).css('top', hmargin);
            }
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

// show the request informations for the moderator
function showRequest(status, dataid, requestid, user, stype, lang){
   if(stype == "modcrop")
      {
      var field = '#pubfield'+requestid;
      var request = 'publish'+requestid;
      var queryid = '#publish'+requestid;
      var arrow = 'pubarrow'+requestid;
      var shonlick = "showRequest('show', '"+dataid+"' , '"+requestid+"' , '"+user+"', 'modcrop', '"+lang+"');";
      var honlick = "showRequest('hide', '"+dataid+"' , '"+requestid+"' , '"+user+"', 'modcrop', '"+lang+"');";
      }
   else if(stype == "sendImage")
      {
      var field = '#sendfield'+requestid;
      var request = 'send'+requestid;
      var queryid = '#send'+requestid;
      var arrow = 'sendarrow'+requestid;
      var shonlick = "showRequest('show', '"+dataid+"' , '"+requestid+"' , '"+user+"', 'sendImage', '"+lang+"');";
      var honlick = "showRequest('hide', '"+dataid+"' , '"+requestid+"' , '"+user+"', 'sendImage', '"+lang+"');";
      }
   else if(stype == "usercrop")
      {
      var field = '#field'+requestid;
      var request = 'request'+requestid;
      var queryid = '#request'+requestid;
      var arrow = 'arrow'+requestid;
      var shonlick = "showRequest('show', '"+dataid+"' , '"+requestid+"' , '"+user+"', 'usercrop', '"+lang+"');";
      var honlick = "showRequest('hide', '"+dataid+"' , '"+requestid+"' , '"+user+"', 'usercrop', '"+lang+"');";
      }
   
   if(status=="start")
   {
     // show the information- field
     $(field).css('display', 'block');
     $(queryid).css('-moz-border-radius', '10px 10px 0px 0px');
     $(queryid).css('-khtml-border-radius', '10px 10px 0px 0px');
     $(queryid).css('-webkit-border-radius', '10px 10px 0px 0px');
     $(queryid).css('border-radius', '10px 10px 0px 0px');
     document.getElementById(request).removeAttribute('ONCLICK');
     document.getElementById(request).setAttribute('ONCLICK', shonlick);     
     document.getElementById(arrow).removeAttribute('SRC');
     document.getElementById(arrow).setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/minus');
        // send request to compare scriptvar queryid = '#publish'+requestid;
        var xmlhttp;
        if (window.XMLHttpRequest)
            {// code for IE7+, Firefox, Chrome, Opera, Safari
                xmlhttp=new XMLHttpRequest();
            }
        else
            {// code for IE6, IE5
                xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
            }
        if(stype == "modcrop")
            {
            xmlhttp.open("GET","service/publishannotation?type=modcrop&amp;id="+dataid+"&amp;user="+user+"&amp;requestid="+requestid+"&amp;platformid="+projectname, true);
            }
        else if(stype == "sendImage")
            {
            xmlhttp.open("GET","service/publishannotation?type=sendImage&amp;id="+dataid+"&amp;user="+user+"&amp;requestid="+requestid+"&amp;platformid="+projectname, true);
            }
        else if(stype == "usercrop")
            {
            xmlhttp.open("GET","service/publishannotation?type=usercrop&amp;id="+dataid+"&amp;user="+user+"&amp;requestid="+requestid+"&amp;platformid="+projectname, true);
            }
        xmlhttp.onreadystatechange=function(){
        if (xmlhttp.readyState==4)
            {
             if (xmlhttp.status==200)
                 { 
                      var breadcrump = document.createElement("div");
                      breadcrump.innerHTML = xmlhttp.responseText;
                      // load the image into the viewport
                      if(stype == "modcrop")
                            {
                            var viewid = "pubviewport"+requestid;
                            }
                      else if (stype == "usercrop")
                            {
                            var viewid = "viewport"+requestid;
                            }
                      else if (stype == "sendImage")
                            {
                            var viewid = "sendviewport"+requestid;
                            }
                    document.getElementById(viewid).appendChild(breadcrump);
                    if (stype == "usercrop")
                        {
                        var imgID = "requestimg"+requestid;
                        var width = document.getElementById(imgID).width;
                        var height = document.getElementById(imgID).height;
                        var wmargin = ((500-parseInt(width))/2 + (parseInt(width)/4));
                        var hmargin = ((300-parseInt(height))/2 + (parseInt(height)/4));
                        imgID = "#requestimg"+requestid;
                        $(imgID).css('left', wmargin);
                        $(imgID).css('top', hmargin);
                        }
                    else if (stype == "modcrop")
                        {
                        var imgID = "pubimg"+requestid;
                        var width = document.getElementById(imgID).width;
                        var height = document.getElementById(imgID).height;
                        var wmargin = ((500-parseInt(width))/2 + (parseInt(width)/4));
                        var hmargin = ((300-parseInt(height))/2 + (parseInt(height)/4));
                        imgID = "#pubimg"+requestid;
                        $(imgID).css('left', wmargin);
                        $(imgID).css('top', hmargin);
                        }
                    else if (stype == "sendImage")
                        {
                        var imgID = "sendimg"+requestid;
                        var width = document.getElementById(imgID).width;
                        var height = document.getElementById(imgID).height;
                        var wmargin = ((500-parseInt(width))/2 + (parseInt(width)/4));
                        var hmargin = ((300-parseInt(height))/2 + (parseInt(height)/4));
                        imgID = "#sendimg"+requestid;
                        $(imgID).css('left', wmargin);
                        $(imgID).css('top', hmargin);
                        }
                    error = 0;
                    }
             else
                 {
                 error++;
                 if(error < 20)
                   showRequest(status, dataid, requestid, user, stype, lang);
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
   else if(status=="hide")
   {
     // show the information- field
     $(field).css('display', 'block');
     $(queryid).css('-moz-border-radius', '10px 10px 0px 0px');
     $(queryid).css('-khtml-border-radius', '10px 10px 0px 0px');
     $(queryid).css('-webkit-border-radius', '10px 10px 0px 0px');
     $(queryid).css('border-radius', '10px 10px 0px 0px');
     document.getElementById(request).removeAttribute('ONCLICK');
     document.getElementById(request).setAttribute('ONCLICK', shonlick);     
     document.getElementById(arrow).removeAttribute('SRC');
     document.getElementById(arrow).setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/minus');
   }
   else
   {
     // hide the information- field
     $(field).css('display', 'none');
     $(queryid).css('-moz-border-radius', '10px 10px 10px 10px');
     $(queryid).css('-khtml-border-radius', '10px 10px 10px 10px');
     $(queryid).css('-webkit-border-radius', '10px 10px 10px 10px');
     $(queryid).css('border-radius', '10px 10px 10px 10px');
     document.getElementById(request).removeAttribute('ONCLICK');
     document.getElementById(request).setAttribute('ONCLICK', honlick);     
     document.getElementById(arrow).removeAttribute('SRC');
     document.getElementById(arrow).setAttribute('SRC', '/'+projectname+'/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/image/plus');
   }
}

// *!* ################ Crop requests functions ################ *!*
// prepare to save a cropped image which has been send by another user
function acceptSend(e, requestid, cropid){
    //  locate mouse position and set booble on this position
    x = e.pageX;
    y = e.pageY;
    $('#bobble').css('display', 'block');
    $("#bobble").css({'top': y - 730,'left': x - 440});
    singleID = requestid;
    interval = cropid;
    $('#nametext').val('');
    $('#typetext').val('');
    var imageID = "sendImagename"+requestid;
    var noteID = "sendNote"+requestid;
    $('#imagenametext').val(document.getElementById(imageID).textContent);
    $('#notetext').val(document.getElementById(noteID).textContent);
}

// store a cropped image which has been send by another user in a new collection of the current user
function storeSend(user, lang){
        var name = $('#nametext').val();
        var type = $('#typetext').val();
        var imagename = $('#imagenametext').val();
        var imagenote = $('#notetext').val();
        var imgID = "sendimg"+singleID;
        var urlID = "sendurl"+singleID;
        var img = document.getElementById(imgID).getAttribute("SRC");
        var url = document.getElementById(urlID).getAttribute("HREF");
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
                        var breadcrump = document.createElement("div");
                        
                        breadcrump.innerHTML = xmlhttp.responseText;
                        if (breadcrump.childNodes[0].nodeName =="DATA")
                        {
                            var outerid = breadcrump.childNodes[0].childNodes[1].childNodes[0].nodeValue;
                            var id = breadcrump.childNodes[0].childNodes[3].childNodes[0].nodeValue;
                            var newid = Math.floor((Math.random()*1000)+500)+Math.floor((Math.random()*1000)+500);
                            var addID = type+name+id;
                            // insert new data into the dropdown- lists of existing datas
                            document.getElementById("loadtext").innerHTML = geti18nText(lang, 'data-have-been-saved');
                            
                            var viewid = 'view'+newid;
                            var toolid = 'tool'+newid;
                            var addid = 'add'+id;
                            
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
                            
                            var addstring = "addSend('"+id+"','"+user+"', '"+name+"', '"+type+"', '"+lang+"')";
                            
                            var addbutton = document.createElement("p");
                            addbutton.setAttribute('ID', addid);
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
                            var breadcrump = document.createElement("div");
                            breadcrump.innerHTML = xmlhttp.responseText;
                            $('#loadgif').css('display', 'none');
                            // define ID because of existing elements
                            var outerid = breadcrump.childNodes[0].childNodes[1].childNodes[0].nodeValue;
                            var id = breadcrump.childNodes[0].childNodes[3].childNodes[0].nodeValue;
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
                            var relstring = "removeCrop('no', '"+outerid+"', '"+user+"', '"+id+"', '"+lang+"')";
                            document.getElementById(relbutton).removeAttribute('ONCLICK');
                            document.getElementById(relbutton).setAttribute('ONCLICK', relstring);
                            }
                        error = 0;
                        // delete the entry
                        var secxmlhttp;
                        if (window.XMLHttpRequest)
                                {// code for IE7+, Firefox, Chrome, Opera, Safari
                                    secxmlhttp=new XMLHttpRequest();
                                }
                        else
                                {// code for IE6, IE5
                                    secxmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
                                }
                        secxmlhttp.open("GET","service/publish-cropimages?type=declineSend&amp;id="+interval+"&amp;user="+user, true);
                        secxmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
                        secxmlhttp.onreadystatechange=function(){
                        if (secxmlhttp.readyState==4)
                              {
                               if (secxmlhttp.status==200)
                                     { 
                                          // delete request in open-request-list
                                          var deleteid = "send"+singleID;
                                          var fieldid = "sendfield"+singleID;
                                          var old = document.getElementById(deleteid);
                                          old.parentNode.removeChild(old);
                                          var oldf = document.getElementById(fieldid);
                                          oldf.parentNode.removeChild(oldf);
                                          error = 0;
                                        }
                                 else
                                     {
                                     error++;
                                     if(error < 20)
                                       answerSend('declineSend', interval, singleID, user, lang);
                                     else
                                       {
                                       document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                                       error = 0;
                                       }
                                     }
                                }
                           };
                        secxmlhttp.send();
                        $('#bobble').css('display', 'none');
                        }
                 else
                     {
                     error++;
                     if(error < 20)
                       storeSend(user, lang);
                     else
                       {
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

// add a cropped image which has been send by another user to a collection of the current user
function addSend(id, user, name, type, lang){
    var imagename = $('#imagenametext').val();
    var imagenote = $('#notetext').val();
    var imgID = "sendimg"+singleID;
    var urlID = "sendurl"+singleID;
    var img = document.getElementById(imgID).getAttribute("SRC");
    var url = document.getElementById(urlID).getAttribute("HREF");
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
                        var breadcrump = document.createElement("div");
                        breadcrump.innerHTML = xmlhttp.responseText;
                        var addID = type+name+id;
                        // define ID because of existing elements
                        var outerid = breadcrump.childNodes[0].childNodes[1].childNodes[0].nodeValue;
                        var newid = Math.floor((Math.random()*1000)+500)+Math.floor((Math.random()*1000)+500);
                        var viewid = 'view'+newid;
                        var toolid = 'tool'+newid;
                        // insert new data into the dropdown- lists of existing datas
                        document.getElementById("loadtext").innerHTML = geti18nText(lang, 'data-have-been-successful-updated');
                        
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
                        
                        document.getElementById(addID).appendChild(outerdiv);
                        
                        // delete the entry
                        var secxmlhttp;
                        if (window.XMLHttpRequest)
                                {// code for IE7+, Firefox, Chrome, Opera, Safari
                                    secxmlhttp=new XMLHttpRequest();
                                }
                        else
                                {// code for IE6, IE5
                                    secxmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
                                }
                        secxmlhttp.open("GET","service/publish-cropimages?type=declineSend&amp;id="+interval+"&amp;user="+user, true);
                        secxmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
                        secxmlhttp.onreadystatechange=function(){
                        if (secxmlhttp.readyState==4)
                              {
                               if (secxmlhttp.status==200)
                                     { 
                                          // delete request in open-request-list
                                          var deleteid = "send"+singleID;
                                          var fieldid = "sendfield"+singleID;
                                          var old = document.getElementById(deleteid);
                                          old.parentNode.removeChild(old);
                                          var oldf = document.getElementById(fieldid);
                                          oldf.parentNode.removeChild(oldf);
                                          error = 0;
                                        }
                                 else
                                     {
                                     error++;
                                     if(error < 20)
                                       answerSend('declineSend', interval, singleID, user, lang);
                                     else
                                       {
                                       document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                                       error = 0;
                                       }
                                     }
                                }
                           };
                        secxmlhttp.send();
                        $('#bobble').css('display', 'none');
                        error = 0;
                        }
                 else
                     {
                     error++;
                     if(error < 20)
                       addSend(user, name, type, lang);
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

// answer a send request
function answerSend(type, dataid, requestid, user, lang){
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
    xmlhttp.open("GET","service/publish-cropimages?type="+type+"&amp;id="+dataid+"&amp;user="+user, true);
    xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
    xmlhttp.onreadystatechange=function(){
    if (xmlhttp.readyState==4)
          {
           if (xmlhttp.status==200)
                 { 
                      // delete request in open-request-list
                      var deleteid = "send"+requestid;
                      var fieldid = "sendfield"+requestid;
                      var old = document.getElementById(deleteid);
                      old.parentNode.removeChild(old);
                      var oldf = document.getElementById(fieldid);
                      oldf.parentNode.removeChild(oldf);
                      error = 0;
                    }
             else
                 {
                 error++;
                 if(error < 20)
                   answerSend(type, dataid, requestid, user, lang);
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

// answer a request to publish a cropped image
function answerCrop(type , dataid , requestid, user, lang){
    var comment = $('#input'+requestid).val();
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
    xmlhttp.open("POST","service/publish-cropimages?type="+type+"&amp;id="+dataid+"&amp;user="+user, true);
    xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
    xmlhttp.onreadystatechange=function(){
    if (xmlhttp.readyState==4)
          {
           if (xmlhttp.status==200)
                 { 
                      // delete request in open-request-list
                      var deleteid = "publish"+requestid
                      var fieldid = "pubfield"+requestid
                      var old = document.getElementById(deleteid);
                      old.parentNode.removeChild(old);
                      var oldf = document.getElementById(fieldid);
                      oldf.parentNode.removeChild(oldf);
                      error = 0;
                    }
             else
                 {
                 error++;
                 if(error < 20)
                   answerCrop(type, dataid, requestid, user, lang);
                 else
                   {
                   $('#loadgif').css('display', 'none');
                   document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                   error = 0;
                   }
                 }
            }
       };
     xmlhttp.send(comment);
}

// hide the crop request in the request list
function hideCrop(dataid, requestid, user, lang){
    var xmlhttp;
    if (window.XMLHttpRequest)
            {// code for IE7+, Firefox, Chrome, Opera, Safari
                xmlhttp=new XMLHttpRequest();
            }
    else
            {// code for IE6, IE5
                xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
            }
    xmlhttp.open("GET","service/publish-cropimages?type=hide&amp;id="+dataid+"&amp;user="+user, true);
    xmlhttp.onreadystatechange=function(){
    if (xmlhttp.readyState==4)
          {
           if (xmlhttp.status==200)
                 { 
                        // delete request in open-request-list
                        var deleteid = "request"+requestid;
                        var fieldid = "field"+requestid;
                        var old = document.getElementById(deleteid);
                        old.parentNode.removeChild(old);
                        var oldf = document.getElementById(fieldid);
                        oldf.parentNode.removeChild(oldf);
                        error = 0;
                    }
             else
                 {
                 error++;
                 if(error < 20)
                   hideCrop(dataid, requestid, user, type, lang);
                 else
                   {
                   $('#loadgif').css('display', 'none');
                   document.getElementById("loadtext").innerHTML = geti18nText(lang, 'ajax-error');
                   error = 0;
                   }
                 }
            }
       };
     xmlhttp.send();
}
