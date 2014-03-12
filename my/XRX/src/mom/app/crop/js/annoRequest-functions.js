var error = 0, projectname;

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

// zoom image on the request widget 
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

// normalize coordinates of the direct annotations
function normCoordinates(idPrefix, number){
    // calculate the zooming factor
    var id = idPrefix+"img"+number;
    var jqueryID = '#'+id;
    var newImg = new Image();
    newImg.src = document.getElementById(id).src;
    $(newImg).load(function(){
        var multifactor = newImg.width/$(jqueryID).width();
        if(idPrefix == 'request' || idPrefix == 'critic')
                {
                var prefix = 'direct'
                if(idPrefix == 'critic')
                    {
                    var field = prefix+"annofieldcritic"+number;
                    var text = prefix+"annotextcritic"+number;
                    }
                else
                    {
                    var field = prefix+"annofield"+number;
                    var text = prefix+"annotext"+number;
                    }
                document.getElementById(field).style.top = Math.round(parseInt(document.getElementById(field).style.top)/multifactor)+"px";
                document.getElementById(field).style.left = Math.round(parseInt(document.getElementById(field).style.left)/multifactor)+"px";
                document.getElementById(field).style.width = Math.round(parseInt(document.getElementById(field).style.width)/multifactor)+"px";        
                document.getElementById(field).style.height = Math.round(parseInt(document.getElementById(field).style.height)/multifactor)+"px";
                document.getElementById(text).style.top = Math.round(parseInt(document.getElementById(text).style.top)/multifactor)+"px";
                document.getElementById(text).style.left = Math.round(parseInt(document.getElementById(text).style.left)/multifactor)+"px";
                }
        else
            {
            var field = idPrefix+"annofield"+number;
            var tools = idPrefix+"tools"+number;
            var text = idPrefix+"annotext"+number;
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
    }

// *!* ################ Annotation requests functions ################ *!*
// delete an annotation
function deleteAnno(chartercontext, id, user, lang){
    // ask the user to confirm this step
    if(confirm(geti18nText(lang, 'delete-annotation-question')))
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
             $('#loadtext').css('display', 'block');
             if (xmlhttp.status==200)
                 {
                    var breadcrump = document.createElement("div");
                    breadcrump.innerHTML = xmlhttp.responseText;
                    // delete annotation on the screen
                    if (breadcrump.childNodes[0].childNodes[0].nodeValue == "delete")
                        {
                            old = document.getElementById(id);
                            old.parentNode.removeChild(old);
                        }
                    else document.getElementById("loadtext").innerHTML = geti18nText(lang, 'data-have-been-successful-removed');
                    error = 0;
                 }
             else
                 {
                    error++;
                    if(error < 20)
                        deleteAnno(chartercontext, id, user, lang);
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

// delete public annotation
function deletePublic(number, id, user, archive, fond, charter, lang) {
    // ask the user to confirm this step
    if(confirm(geti18nText(lang, 'delete-annotation-question')))
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
        xmlhttp.open("GET","service/publishannotation?type=deleteAnno&amp;id="+id+"&amp;user="+user+"&amp;archive="+archive+"&amp;fond="+fond+"&amp;charter="+charter,true);
        xmlhttp.onreadystatechange=function(){
        if (xmlhttp.readyState==4)
            {
             $('#loadtext').css('display', 'block');
             if (xmlhttp.status==200)
                 {
                    var breadcrump = document.createElement("div");
                    breadcrump.innerHTML = xmlhttp.responseText;
                    // delete annotation on the screen
                    if (breadcrump.childNodes[0].childNodes[0].nodeValue == "delete")
                        {
                        var annoDelID = "repannotext"+number;
                        var fieldDelID = "repannofield"+number;
                        var toolsDelID = "reptools"+number;
                        var old = document.getElementById(annoDelID);
                        old.parentNode.removeChild(old);
                        var fold = document.getElementById(fieldDelID);
                        fold.parentNode.removeChild(fold);
                        var tools = document.getElementById(toolsDelID);
                        tools.parentNode.removeChild(tools);
                        error = 0;
                        }
                   }
             else
                 {
                    error++;
                    if(error < 20)
                        deletePublic(number, id, user, archive, fond, charter, lang);
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

// prepare to edit an annotationtext
function editAnno(chartercontext, id, user, archive, fond, charter, type, dataid, role, lang){
    // may be store chartercontext - font/ collection
    if(type == 'response')
        {
        var fieldid = "pubannofield"+dataid;
        var textid = "pubannotext"+dataid;
        }
    else if(type == 'edit')
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
    if(type == 'response')
        {
        var save = "saveanno"+dataid;
        var field = "annotationfield"+dataid;
        var direct = '#directanno'+dataid;
        document.getElementById(field).value = document.getElementById(textid).textContent;
        document.getElementById(save).removeAttribute('ONCLICK');
        document.getElementById(save).setAttribute('ONCLICK', updatestring);
        $(direct).css('display', 'block');
        $(direct).css('left', left);
        $(direct).css('top', top);
        }
     else if(type == 'report')
        {
        var save = "saverep"+dataid;
        var field = "repinputfield"+dataid;
        var direct = '#repanno'+dataid;
        document.getElementById(field).value = document.getElementById(textid).textContent;
        document.getElementById(save).removeAttribute('ONCLICK');
        document.getElementById(save).setAttribute('ONCLICK', updatestring);
        $(direct).css('display', 'block');
        $(direct).css('left', left);
        $(direct).css('top', top);
        }
     else
        {
        $('#directanno').css('display', 'block');
        $('#directanno').css('left', left);
        $('#directanno').css('top', top);
        document.getElementById('annotationfield').value = document.getElementById(textid).textContent;
        document.getElementById('saveanno').removeAttribute('ONCLICK');
        document.getElementById('saveanno').setAttribute('ONCLICK', updatestring);
        }
}

// edit an annotationtext in the DB
function updateAnno(id, dataid, user, textid, archive, fond, charter, type, role, lang){
        if(type == 'response')
        {
        var annotation = $('#annotationfield'+dataid).val();
        }
        else if(type == 'report')
        {
        var annotation = $('#repinputfield'+dataid).val();
        }
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
            if(type == 'response') 
                {
                xmlhttp.open("POST","service/publishannotation?type=editAnno&amp;user="+user+"&amp;id="+id+"&amp;status=wait",true);
                }
           else if(type == 'report') 
                {
                xmlhttp.open("POST","service/publishannotation?type=updateAnno&amp;user="+user+"&amp;id="+id+"&amp;archive="+archive+"&amp;fond="+fond+"&amp;charter="+charter+"&amp;status=report" ,true);
                }
        }
        xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
        xmlhttp.onreadystatechange=function(){
        if (xmlhttp.readyState==4)
            {
             if (xmlhttp.status==200)
                 {
                 document.getElementById(textid).textContent = annotation;
                 if(type == 'response')
                    {
                    $('#annotationfield'+dataid).val('');
                    $('#directanno'+dataid).css('display', 'none');
                    }
                 else if(type == 'report')
                    {
                    $('#repinputfield'+dataid).val('');
                    $('#repanno'+dataid).css('display', 'none');
                    }
                 $('#loading').css('display', 'none');
                 error = 0;
                 }
             else
                 {
                    error++;
                    if(error < 20)
                        updateAnno(id, dataid, user, textid, archive, fond, charter, type, role, lang);
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
           document.getElementById("loadtext").innerHTML = geti18nText(lang, 'updating-data');
           }
        };
        xmlhttp.send(parameters);
        
    };

// show the request informations for the moderator or user
function showRequest(status, dataid, requestid, user, stype, lang){
   if(stype == "moderator")
      {
      var field = '#pubfield'+requestid;
      var request = 'publish'+requestid;
      var queryid = '#publish'+requestid;
      var arrow = 'pubarrow'+requestid;
      var shonlick = "showRequest('show', '"+dataid+"' , '"+requestid+"' , '"+user+"', 'moderator', '"+lang+"');";
      var honlick = "showRequest('hide', '"+dataid+"' , '"+requestid+"' , '"+user+"', 'moderator', '"+lang+"');";
      }
   else if(stype == "user")
      {
      var field = '#field'+requestid;
      var request = 'request'+requestid;
      var queryid = '#request'+requestid;
      var arrow = 'arrow'+requestid;
      var shonlick = "showRequest('show', '"+dataid+"' , '"+requestid+"' , '"+user+"', 'user', '"+lang+"');";
      var honlick = "showRequest('hide', '"+dataid+"' , '"+requestid+"' , '"+user+"', 'user', '"+lang+"');";
      }
   else if(stype == "modcrop")
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
   else if(stype == "critic")
      {
      var field = '#fieldcritic'+requestid;
      var request = 'requestcritic'+requestid;
      var queryid = '#requestcritic'+requestid;
      var arrow = 'arrowcritic'+requestid;
      var shonlick = "showRequest('show', '"+dataid+"' , '"+requestid+"' , '"+user+"', 'critic', '"+lang+"');";
      var honlick = "showRequest('hide', '"+dataid+"' , '"+requestid+"' , '"+user+"', 'critic', '"+lang+"');";
      }
   else if(stype == "report")
      {
      var field = '#repfield'+requestid;
      var request = 'report'+requestid;
      var queryid = '#report'+requestid;
      var arrow = 'reparrow'+requestid;
      var shonlick = "showRequest('show', '"+dataid+"' , '"+requestid+"' , '"+user+"', 'report', '"+lang+"');";
      var honlick = "showRequest('hide', '"+dataid+"' , '"+requestid+"' , '"+user+"', 'report', '"+lang+"');";
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
        if(stype == "moderator")
            {
            xmlhttp.open("GET","service/publishannotation?type=image&amp;id="+dataid+"&amp;user="+user+"&amp;lang="+lang+"&amp;requestid="+requestid+"&amp;platformid="+projectname, true);
            }
        else if(stype == "user")
            {
            xmlhttp.open("GET","service/publishannotation?type=request&amp;id="+dataid+"&amp;user="+user+"&amp;lang="+lang+"&amp;requestid="+requestid+"&amp;platformid="+projectname, true);
            }
        else if(stype == "critic")
            {
            xmlhttp.open("GET","service/publishannotation?type=critic&amp;id="+dataid+"&amp;user="+user+"&amp;lang="+lang+"&amp;requestid="+requestid+"&amp;platformid="+projectname, true);
            }
        else if(stype == "report")
            {
            xmlhttp.open("GET","service/publishannotation?type=getreport&amp;id="+dataid+"&amp;user="+user+"&amp;lang="+lang+"&amp;requestid="+requestid+"&amp;platformid="+projectname, true);
            }
        else if(stype == "modcrop")
            {
            xmlhttp.open("GET","service/publishannotation?type=modcrop&amp;id="+dataid+"&amp;user="+user+"&amp;lang="+lang+"&amp;requestid="+requestid+"&amp;platformid="+projectname, true);
            }
        else if(stype == "sendImage")
            {
            xmlhttp.open("GET","service/publishannotation?type=sendImage&amp;id="+dataid+"&amp;user="+user+"&amp;lang="+lang+"&amp;requestid="+requestid+"&amp;platformid="+projectname, true);
            }
        else if(stype == "usercrop")
            {
            xmlhttp.open("GET","service/publishannotation?type=usercrop&amp;id="+dataid+"&amp;user="+user+"&amp;lang="+lang+"&amp;requestid="+requestid+"&amp;platformid="+projectname, true);
            }
        xmlhttp.onreadystatechange=function(){
        if (xmlhttp.readyState==4)
            {
             if (xmlhttp.status==200)
                 { 
                      var breadcrump = document.createElement("div");
                      breadcrump.innerHTML = xmlhttp.responseText;
                      // load the image into the viewport
                      if(stype == "moderator" || stype == "modcrop")
                            {
                            var viewid = "pubviewport"+requestid;
                            }
                      else if (stype == "user" || stype == "usercrop")
                            {
                            var viewid = "viewport"+requestid;
                            }
                      else if (stype == "critic")
                            {
                            var viewid = "viewportcritic"+requestid;
                            }
                      else if (stype == "sendImage")
                            {
                            var viewid = "sendviewport"+requestid;
                            }
                      else  
                            {
                            var viewid = "repviewport"+requestid;
                            }
                    document.getElementById(viewid).appendChild(breadcrump);
                    if(stype == "moderator")
                                {
                                normCoordinates("pub", requestid);
                                }
                    else if(stype == "user")
                                {
                                normCoordinates("request", requestid);
                                }
                    else if(stype == "critic")
                                {
                                normCoordinates("critic", requestid);
                                }
                    else if(stype == "report")
                                {
                                normCoordinates("rep", requestid);
                                }
                    else if (stype == "usercrop")
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

// moderator answers an publication request 
function answerRequest(type, dataid, requestid, user, lang){
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
    xmlhttp.open("POST","service/publishannotation?type="+type+"&amp;id="+dataid+"&amp;user="+user, true);
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
                   answerRequest(type, dataid, requestid, user, lang);
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

// hide the annotation request in the request list
function hideRequest(dataid, requestid, user, type, lang){
    var xmlhttp;
    if (window.XMLHttpRequest)
            {// code for IE7+, Firefox, Chrome, Opera, Safari
                xmlhttp=new XMLHttpRequest();
            }
    else
            {// code for IE6, IE5
                xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
            }
    xmlhttp.open("GET","service/publishannotation?type=hide&amp;id="+dataid+"&amp;user="+user+"&amp;status="+type, true);
    xmlhttp.onreadystatechange=function(){
    if (xmlhttp.readyState==4)
          {
           if (xmlhttp.status==200)
                 { 
                      if(type == "report")
                        {
                        // delete request in open-request-list
                        var deleteid = "requestcritic"+requestid;
                        var fieldid = "fieldcritic"+requestid;
                        var old = document.getElementById(deleteid);
                        old.parentNode.removeChild(old);
                        var oldf = document.getElementById(fieldid);
                        oldf.parentNode.removeChild(oldf);
                        }
                      else
                        {
                        // delete request in open-request-list
                        var deleteid = "request"+requestid;
                        var fieldid = "field"+requestid;
                        var old = document.getElementById(deleteid);
                        old.parentNode.removeChild(old);
                        var oldf = document.getElementById(fieldid);
                        oldf.parentNode.removeChild(oldf);
                        }
                        error = 0;
                    }
             else
                 {
                 error++;
                 if(error < 20)
                   hideRequest(dataid, requestid, user, type, lang);
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

// answer a report
function answerReport(dataid, requestid, user, lang){
    var comment = $('#reportInput'+requestid).val();
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
    xmlhttp.open("POST","service/publishannotation?type=answerReport&amp;id="+dataid+"&amp;user="+user, true);
    xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
    xmlhttp.onreadystatechange=function(){
    if (xmlhttp.readyState==4)
          {
           if (xmlhttp.status==200)
                 { 
                      // delete request in open-request-list
                      var deleteid = "report"+requestid
                      var fieldid = "repfield"+requestid
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
                   answerReport(dataid, requestid, user, lang);
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
