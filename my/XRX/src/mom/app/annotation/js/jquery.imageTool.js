/*!
 * jQuery image Tool
 *
 */

;(function($) {

   var serviceGetSVG, serviceGetMetadata     = "";
   var error                                 =  0;

   // settings 
   var settings = {
      servicePrefix: "",
      scope: "",
      charter: "",
      collection: "",
      active: false,
      initSVG: false,
      annoVisible: false,
      requestRoot: "",
      svgId: "",
      shownTag: "none"
    };
  
   /*
	 * public interface
	 */
  
  // init the menu surfaces and functions
  $.fn.imageTool = function( options ) {
    settings.servicePrefix = options.servicePrefix;
    settings.requestRoot = options.requestRoot;
    settings.charter = options.charter;
    settings.collection = options.collection;
    settings.scope = options.scope;

    initServiceUris();
    
    if(settings.scope == "private")
      initPrivateTools();
    else
      initPublicTools();
	};

  $.fn.imageTool.resetSVGId = function() {
    var currentImgUrl = document.getElementById('img').src;
    var imgName = currentImgUrl.split('/').pop();
    settings.svgId = cleanImageURL(imgName);
    if(settings.scope == "private")
      jQuery(document).createAnno.setParams(settings);
  };

  $.fn.imageTool.setStatus = function(status) {
    settings.active = status;
  };

  $.fn.imageTool.getStatus = function() {
    return settings.active;
  };

  $.fn.imageTool.getSVGID = function() {
    return settings.svgId;
  };

  $.fn.imageTool.getinitSVG = function() {
    return settings.initSVG;
  };

  $.fn.imageTool.annoVisible = function() {
    return settings.annoVisible;
  };
  
  // show linked markup
  $.fn.imageTool.showLinkedMarkup = function( tagBinding ) {
      // hide old linked markup
      jQuery(document).imageTool.hideLinkedMarkup();

      if(settings.scope == "public"){
      // highlight and open div of linked markup
      jQuery("#"+tagBinding).css("display", "block");
      jQuery("#"+tagBinding).addClass("linked-anno-tag");
      }
      else{
      // highlight textarea of linked markup
      jQuery("textarea[data-xrx-bind='"+tagBinding+"']").next().addClass("linked-anno-tag");
      var tabindex = jQuery("textarea[data-xrx-bind='"+tagBinding+"']").closest(".ui-tabs-panel");
      jQuery(".xrx-tabs").tabs('select', '#'+tabindex.attr('id'));
      }
    };
  
  // show linked repeated markup
  $.fn.imageTool.showLinkedRepeatedMarkup = function( tagBinding, ref, index  ) {
      // hide old linked markup
      jQuery(document).imageTool.hideLinkedMarkup();

      // highlight textarea of linked markup
      jQuery(".xrx-repeat[data-xrx-bind='"+tagBinding+"']").find("textarea[data-xrx-ref='"+ref+"'][data-xrx-index='"+index+"']").next().css("border", "dashed blue 1px");
      var tabindex = jQuery(".xrx-repeat[data-xrx-bind='"+tagBinding+"']").closest(".ui-tabs-panel");
      jQuery(".xrx-tabs").tabs('select', '#'+tabindex.attr('id'));
    };

  // hide linked markup
  $.fn.imageTool.hideLinkedMarkup = function() {
      jQuery(".linked-anno-tag").removeClass("linked-anno-tag");
    };

  // show or hide annotations
  $.fn.imageTool.changeAnnoDisplayStatus = function() {
      if(settings.annoVisible) {
        settings.annoVisible = false;
        // turn html img on and SVG img off
        jQuery('#img-svg').css('display', 'none');
        jQuery('#img-img').css('display', 'block');
        // change button text
        jQuery("#show-anno-button").find("span").text(jQuery(document).i18nText.get('show-annotation'));
        // hide metadata elements 
        jQuery('#edit-anno-button').css('display', 'none');
        jQuery('#delete-anno-button').css('display', 'none');
        jQuery('#metadata-field').css('display', 'none');
        if(settings.scope == "public"){
           jQuery("#broken-anno").css("display", "none");
           jQuery("#no-annos").css("display", "none");
        }
        // hide linked tag
        jQuery(document).imageTool.hideLinkedMarkup();
        // hide marked rect
        if(settings.shownTag != "none"){
          jQuery('#'+settings.shownTag).attr('style', 'stroke:red;stroke-width:2;fill-opacity:0;');
          settings.shownTag = "none";
        }
      }
      else {
        settings.annoVisible = true;
        // turn SVG img on and html img off
        jQuery('#img-svg').css('display', 'block');
        jQuery('#img-img').css('display', 'none');
        // change button text
        jQuery("#show-anno-button").find("span").text(jQuery(document).i18nText.get('hide-annotation'));
      }
    };

  // show metadata of annotation
  $.fn.imageTool.showMetadata = function( zoneId ) {
      jQuery(document).imageTool.hideLinkedMarkup();
      getAnnoMetadata(zoneId);
    };

  // load SVG file
  $.fn.imageTool.loadSVG = function() {
      // load img width and height
      var newImg = new Image();
      var imgSrc = document.getElementById('img').src;
      newImg.src = imgSrc;
      var width = newImg.width;
      var height = newImg.height;
    
      // define POST parameters
      var parameters = "width="+width+"?!;height="+height+"?!;src="+imgSrc+"?!;";
    
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
      xmlhttp.open("POST", settings.requestRoot+serviceGetSVG+"?svgId="+settings.svgId+"&charter="+settings.charter+"&collection="+settings.collection+"&scope="+settings.scope,false);
      xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
      xmlhttp.onreadystatechange=function(){
      if (xmlhttp.readyState==4)
         {
         if (xmlhttp.status==200)
            {
            error = 0;
            // delete current SVG file
            var svg = document.getElementById("img-svg");
            if(svg.firstChild != null){
              svg.removeChild(svg.firstChild);
            }
            if(settings.scope == "private"){
              var response = xmlhttp.responseText;
              jQuery("#img-svg").append(response);
              settings.initSVG = true;
            }
            else {
              var response = xmlhttp.responseText;
              if(response != "Not available"){
                jQuery("#show-anno-button").css("display", "inline");
                jQuery("#no-annos").css("display", "none");
                jQuery("#img-svg").append(response);
                settings.initSVG = true;
                }
              else {
                jQuery("#no-annos").css("display", "block");
                jQuery("#show-anno-button").css("display", "none");
                jQuery('#metadata-field').css('display', 'none');
                }
            }
            }
         else
            {
            error++;
            if(error < 20)
               jQuery(document).imageTool.loadSVG();
            else
               {
               error = 0;
               }
            }
         }
      };
      xmlhttp.send(parameters);
    };

  /*
	 * private functions
	 */

  // init private image tools settings
  function initPrivateTools(){
    // init main button
		jQuery("#open-image-tool")
      .button()
      .unbind('click').click(function( event ) {
          var currentImgUrl = document.getElementById('img').src;
          var imgName = currentImgUrl.split('/').pop();
          settings.svgId = cleanImageURL(imgName);
          settings.active = true;
          if(!settings.initSVG) jQuery(document).imageTool.loadSVG();
          jQuery(document).ImageToolWidget();
          jQuery(document).createAnno(settings);
      });

    // init show-anno Button
    jQuery("#show-anno-button")
        .button()
        .unbind('click').click(function( event ) {
            jQuery(document).imageTool.changeAnnoDisplayStatus();
          });
      
     // init help-anno Button
    /*jQuery("#help-anno-button")
        .button()
        .unbind('click').click(function( event ) {
            
          });*/

    // close image tool widget
    jQuery("#image-tool-widget-close-button").click(function( event ) {
        jQuery('#image-tool-widget').css('display', 'none');
        if(settings.annoVisible)
          jQuery(document).imageTool.changeAnnoDisplayStatus();
        jQuery(document).createAnno.resetCreateProcess();
        // hide linked tag
        jQuery(document).imageTool.hideLinkedMarkup();
        });
  };

  // init public image tools settings
  function initPublicTools(){
    // init main button
		jQuery("#open-image-tool-button")
      .button()
      .unbind('click').click(function( event ) {
          if(document.getElementById('img') != null)
            {
            var currentImgUrl = document.getElementById('img').src;
            var imgName = currentImgUrl.split('/').pop();
            settings.svgId = cleanImageURL(imgName);
            settings.active = true;
            if(!settings.initSVG) jQuery(document).imageTool.loadSVG();
            jQuery(document).ImageToolWidget();
            }
        else
            alert(jQuery(document).i18nText.get('no-image'));
      });

    // init show-anno Button
    jQuery("#show-anno-button")
        .button()
        .unbind('click').click(function( event ) {
            jQuery(document).imageTool.changeAnnoDisplayStatus();
          });
      
     // init help-anno Button
    jQuery("#help-anno-button")
        .button()
        .unbind('click').click(function( event ) {
            x = event.pageX;
            y = event.pageY;
            $("#bobble").css('display', 'block');
            $("#bobble").css({'top': y - 280, 'left': x - 185 });
          });

    // init open image editor Button
    jQuery("#open-image-editor")
        .button();

    // close image tool widget
    jQuery("#image-tool-widget-close-button").click(function( event ) {
        jQuery('#image-tool-widget').css('display', 'none');
        if(settings.annoVisible)
          jQuery(document).imageTool.changeAnnoDisplayStatus();
        // hide linked tag
        jQuery(document).imageTool.hideLinkedMarkup();
        });
  };
  
  // clean img URL
  function cleanImageURL(IMGid){
     IMGid = IMGid.replace(/ /g, "_");
     IMGid = IMGid.replace(/\./g, "_");
     IMGid = IMGid.replace(/\&/g, "_");
     IMGid = IMGid.replace(/\:/g, "_");
     IMGid = IMGid.replace(/\%/g, "_");
     IMGid = IMGid.replace(/\//g, "_");
     IMGid = IMGid.replace(/\\/g, "_");
     IMGid = IMGid.replace(/\~/g, "_");
     IMGid = IMGid.replace(/\</g, "_");
     IMGid = IMGid.replace(/\>/g, "_");
     IMGid = IMGid.replace(/\^/g, "_");
     IMGid = IMGid.replace(/\°/g, "_");
     IMGid = IMGid.replace(/\@/g, "_");
     IMGid = IMGid.replace(/\=/g, "_");
     IMGid = IMGid.replace(/\|/g, "_");
     IMGid = IMGid.replace(/\§/g, "_");
     IMGid = IMGid.replace(/\$/g, "_");
     IMGid = IMGid.replace(/\+/g, "_");
     IMGid = IMGid.replace(/\#/g, "_");
     IMGid = IMGid.replace(/\;/g, "_");
     IMGid = IMGid.replace(/\µ/g, "_");
     IMGid = IMGid.replace(/\*/g, "_");
     IMGid = IMGid.replace(/\?/g, "_");
     IMGid = IMGid.replace(/\!/g, "_");
     IMGid = IMGid.replace(/\"/g, "_");
     IMGid = IMGid.replace(/\'/g, "_");
     IMGid = IMGid.replace(/\{/g, "_");
     IMGid = IMGid.replace(/\}/g, "_");
     IMGid = IMGid.replace(/\-/g, "_");
     IMGid = IMGid.replace(/\,/g, "_");
     IMGid = IMGid.replace(/\s/g, "_");
     IMGid = IMGid.replace(/\[/g, "_");
     IMGid = IMGid.replace(/\]/g, "_");
     return IMGid;
  };
  
  // get metadata of selected annotation
  function getAnnoMetadata(zoneId){
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
    xmlhttp.open("GET", settings.requestRoot+serviceGetMetadata+"?scope="+settings.scope+"&zoneId="+zoneId+"&collection="+settings.collection+"&charter="+settings.charter,false);
    xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
    xmlhttp.onreadystatechange=function(){
    if (xmlhttp.readyState==4)
       {
       if (xmlhttp.status==200)
          {
          error = 0;
          
          // extract metadata
          var desc, content, onClickFuntion, binding, xmlDoc = jQuery.parseXML(xmlhttp.response);
          var relationStatus = xmlDoc.getElementsByTagName('relationStatus')[0].childNodes[0].nodeValue;

          // hide marked rect
          if(settings.shownTag != "none"){
            jQuery('#'+settings.shownTag).attr('style', 'stroke:red;stroke-width:2;fill-opacity:0;');
          }
          settings.shownTag = zoneId;
          // mark slected rect
          jQuery('#'+zoneId).attr('style', 'stroke:blue;stroke-width:2;fill-opacity:0;');

          // check for relation status
          if(relationStatus == "ok"){
            if(settings.scope == "public")
              jQuery("#broken-anno").css("display", "none");
            // set button functions
            var searchedTag = xmlDoc.getElementsByTagName('searchedTag')[0].childNodes[0].nodeValue;
            if(xmlDoc.getElementsByTagName('content')[0].childNodes[0] != undefined)
              content = xmlDoc.getElementsByTagName('content')[0].childNodes[0].nodeValue;
            else
              content = "";
            if(xmlDoc.getElementsByTagName('desc')[0].childNodes[0] != undefined)
              desc = xmlDoc.getElementsByTagName('desc')[0].childNodes[0].nodeValue;
            else
              desc = "";

            if(settings.scope == "private"){
              var repeat = xmlDoc.getElementsByTagName('repeat')[0].childNodes[0].nodeValue;
    
              if(repeat == "true")
                {
                var ref = xmlDoc.getElementsByTagName('ref')[0].childNodes[0].nodeValue;
                var index = xmlDoc.getElementsByTagName('index')[0].childNodes[0].nodeValue;
                binding = xmlDoc.getElementsByTagName('bind')[0].childNodes[0].nodeValue;
                onClickFuntion  = "javascript:jQuery(document).imageTool.showLinkedRepeatedMarkup('"+binding+"', '"+ref+"', '"+index+"');"
                }
              else
                {
                binding = xmlDoc.getElementsByTagName('bind')[0].childNodes[0].nodeValue;
                onClickFuntion  = "javascript:jQuery(document).imageTool.showLinkedMarkup('"+binding+"');"
                }
            }
            else{
              binding = xmlDoc.getElementsByTagName('binding')[0].childNodes[0].nodeValue;
              onClickFuntion  = "javascript:jQuery(document).imageTool.showLinkedMarkup('"+binding+"');"
            }

            // set link to connected tag
            jQuery('#related-to').attr('href', onClickFuntion);

            // show tag name and description in metadata area
            jQuery('#anno-content').text(content);
            if(settings.scope == "private"){
              jQuery('#related-to').text(jQuery(document).xrxI18n.translate(searchedTag, "xs:element"));
            }
            else {
              var optimizedKey  = searchedTag.replace(":", "_");
              jQuery('#related-to').text(jQuery(document).i18nText.get(optimizedKey));
            }
            jQuery('#anno-desc').text(desc);

            // setup widget style
            if(settings.scope == "private"){
              // init edit-anno Button
              jQuery("#edit-anno-button")
                  .button()
                  .unbind('click').click(function( event ) {
                      jQuery(document).createAnno.editAnno(zoneId, xmlDoc);
                    });
  
              // init delete-anno Button
              jQuery("#delete-anno-button")
                  .button()
                  .unbind('click').click(function( event ) {
                      // hide linked tag
                      jQuery(document).imageTool.hideLinkedMarkup();
                      // delete annotation
                      jQuery(document).createAnno.deleteAnno(zoneId);
                    });
            
            jQuery('#edit-anno-button').css('display', 'inline');
            jQuery('#delete-anno-button').css('display', 'inline');
            }
            jQuery('#metadata-field').css('display', 'block');
            }
          else
            {
            if(settings.scope == "private"){
            // repare relation status
            jQuery(document).createAnno.brokenRelation(zoneId, xmlDoc);
            }
            else
            jQuery("#broken-anno").css("display", "block");
            }
          }
       else
          {
          error++;
          if(error < 20)
            getAnnoMetadata(zoneId);
          else
            error = 0;
          }
       }
    };
    xmlhttp.send();
   };
	
  // init service URI's
  function initServiceUris(){
      serviceGetSVG       = "service/"+settings.servicePrefix+"get-svg-file";
      serviceGetMetadata  = "service/"+settings.servicePrefix+"get-metadata";
  };

})( jQuery );
