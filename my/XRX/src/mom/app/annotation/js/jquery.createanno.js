/*!
* jQuery Create Annotations
*
*/;
(function ($) {
  
  var serviceGetIndex, serviceGetMetadataPath, serviceSaveAnno, serviceDeleteSVG = "";
  var error = 0;
  
  var toolSelection = {
    x1: 0,
    y1: 0,
    x2: 0,
    y2: 0,
    width: 0,
    height: 0
  };
  
  // settings
  var settings = {
    servicePrefix: "",
    requestRoot: "",
    svgId: "",
    charter: "",
    droppedObject: "none",
    mode: "base"
  };
  
  /*
  * public interface
  */
  
  // init creation process
  $.fn.createAnno = function (options) {
    // set settings
    settings.servicePrefix = options.servicePrefix;
    settings.requestRoot = options.requestRoot;
    settings.charter = options.charter;
    settings.svgId = options.svgId;

    initServiceUris();
    
    // init create Button
    jQuery("#create-new-anno-button")
    .button()
    .unbind('click').click(function (event) {
      startSelect();
    });
    
    // init save-selection Button
    jQuery("#save-selection-button")
    .button()
    .unbind('click').click(function (event) {
      useSelection();
    });
  };
  
  // set params
  $.fn.createAnno.setParams = function (options) {
    // set settings
    settings.requestRoot = options.requestRoot;
    settings.charter = options.charter;
    settings.svgId = options.svgId;
  }
  
  // cancel creation process because of current work step (mode)
  $.fn.createAnno.resetCreateProcess = function () {
    $('.xrx-layout').layout().open("south");
    if (settings.mode == "select")
    stopSelect(); else if (settings.mode == "metadata")
    endMetadataProcess();
  };
  
  // fallback function - the relationship between annotation and markup is broken
  $.fn.createAnno.brokenRelation = function (zoneId, xmlDoc) {
    var relationStatus = xmlDoc.getElementsByTagName('relationStatus')[0].childNodes[0].nodeValue;
    // differentiate between different problem-cases
    if (relationStatus == "create-new-relation") {
      // id on related markup tag has been deleted - so the user has to define a new relationship
      alert(jQuery(document).i18nText.get('relation-broken'));
      // set current work mode
      settings.mode = "metadata";
      // change buttons to metadata process
      jQuery("#create-new-anno-button").find("span").text(jQuery(document).i18nText.get('cancel'));
      jQuery("#create-new-anno-button").unbind('click').click(function (event) {
        endMetadataProcess();
      });
      jQuery('#show-anno-button').css('display', 'none');
      jQuery('#edit-anno-button').css('display', 'none');
      jQuery('#delete-anno-button').css('display', 'none');
      jQuery('#metadata-field').css('display', 'none');
      // drop new metadata tag
      useMetadata(relationStatus, zoneId, xmlDoc);
    } else if (relationStatus == "create-new-annotation") {
      // id and cei:zone tag have been deleted - so the user has to define a new relationship
      alert(jQuery(document).i18nText.get('relation-broken'));
      // set current work mode
      settings.mode = "metadata";
      // change buttons to metadata process
      jQuery("#create-new-anno-button").find("span").text(jQuery(document).i18nText.get('cancel'));
      jQuery("#create-new-anno-button").unbind('click').click(function (event) {
        endMetadataProcess();
      });
      jQuery('#show-anno-button').css('display', 'none');
      jQuery('#edit-anno-button').css('display', 'none');
      jQuery('#delete-anno-button').css('display', 'none');
      jQuery('#metadata-field').css('display', 'none');
      // drop new metadata tag and create cei:zone tag
      useMetadata(relationStatus, zoneId);
    } else {
      // only zone tag is broken - can be fixed without user action
      alert(jQuery(document).i18nText.get('relation-broken-repaired'));
      repareZoneTag(zoneId);
    }
  };
  
  // edit selected annotation
  $.fn.createAnno.editAnno = function (zoneId, xmlDoc) {
    // set current work mode
    settings.mode = "metadata";
    // change buttons to metadata process
    jQuery("#create-new-anno-button").find("span").text(jQuery(document).i18nText.get('cancel'));
    jQuery("#create-new-anno-button").unbind('click').click(function (event) {
      endMetadataProcess();
    });
    jQuery('#show-anno-button').css('display', 'none');
    jQuery('#edit-anno-button').css('display', 'none');
    jQuery('#delete-anno-button').css('display', 'none');
    jQuery('#metadata-field').css('display', 'none');
    // drop new metadata tag
    useMetadata("edit-relation", zoneId, xmlDoc);
  };
  
  // delete selected annotation
  $.fn.createAnno.deleteAnno = function (zoneId) {
    // setup interface
    jQuery('#edit-anno-button').css('display', 'none');
    jQuery('#delete-anno-button').css('display', 'none');
    jQuery('#metadata-field').css('display', 'none');
    // delete facs attribute
    deleteMetadataTag(zoneId);
    // delete cei:zone tag
    deleteZoneTag(zoneId);
    // delete svg rect
    deleteSVGrect(zoneId);
    // delete markup field
    old = document.getElementById(zoneId);
    if (old != null) {
      old.parentNode.removeChild(old);
    }
  };
  
  
  /*
  * private functions
  */
  
  // repare broken cei:zone- Tag
  function repareZoneTag(zoneId) {
    // get index of cei:figure
    var index = getIndex("figure", zoneId);
    // load linked img name
    var currentImgUrl = document.getElementById('img').src;
    var imgName = currentImgUrl.split('/').pop();
    // create cei:zone
    createZoneTag(imgName, index, zoneId);
  };
  
  // create cei:zone
  function createZoneTag(imgName, nodeNumber, zoneId) {
    // get description
    var desc = $("#zone-description").val();
    if (nodeNumber == "Not available") {
      // create markup tags
      var imgNameBeforePoint = imgName.split('.', 1);
      var xml = "<cei:figure n='" + imgNameBeforePoint + "'><cei:zone id='" + zoneId + "'><cei:desc>" + desc + "</cei:desc></cei:zone></cei:figure>";
      var expression = "/descendant::cei:witnessOrig/child::cei:traditioForm";
      var nodeset = window.XPath.query(expression, $('.xrx-instance').text());
      var controlId = nodeset.only.levelId;
      $('.xrx-instance').xrxInstance().insertAfter(controlId, xml);
    } else {
      // create markup tags
      var xml = "<cei:zone id='" + zoneId + "'><cei:desc>" + desc + "</cei:desc></cei:zone>";
      
      var expression = "/descendant::cei:witnessOrig/child::cei:figure";
      var nodeset = window.XPath.query(expression, $('.xrx-instance').text());
      if (nodeset.only == null || nodeset.only == undefined) {
        var levelId = nodeset.nodes[nodeNumber].levelId;
      }
      $('.xrx-instance').xrxInstance().insertInto(levelId, xml);
    }
  };
  
  // update cei:zone
  function updateZoneTag(nodeNumber, zoneId) {
    // get description
    var desc = $("#zone-description").val();
    // create markup tags
    var xml = "<cei:zone id='" + zoneId + "'><cei:desc>" + desc + "</cei:desc></cei:zone>";
    // get node id
    var expression = "/descendant::cei:witnessOrig/child::cei:figure/child::cei:zone";
    var nodeset = window.XPath.query(expression, $('.xrx-instance').text());
    if (nodeset.only == null || nodeset.only == undefined) {
      var levelId = nodeset.nodes[nodeNumber].levelId;
    } else {
      var levelId = nodeset.only.levelId;
    }
    
    // replace existing cei:zone tag
    $('.xrx-instance').xrxInstance().replaceElementNode(levelId, xml);
  };
  
  // delete cei:zone
  function deleteZoneTag(zoneId) {
    // get index of cei:zone
    var nodeNumber = getIndex("zone", zoneId);
    var xml = "";
    // get node id
    var expression = "/descendant::cei:witnessOrig/child::cei:figure/child::cei:zone";
    var nodeset = window.XPath.query(expression, $('.xrx-instance').text());
    if (nodeset.only == null || nodeset.only == undefined) {
      var levelId = nodeset.nodes[nodeNumber].levelId;
    } else {
      var levelId = nodeset.only.levelId;
    }
    
    // delete zone tag
    $('.xrx-instance').xrxInstance().replaceElementNode(levelId, xml);
  };
  
  // delete SVG rect
  function deleteSVGrect(zoneId) {
    // send request to service
    var xmlhttp;
    if (window.XMLHttpRequest) {
      // code for IE7+, Firefox, Chrome, Opera, Safari
      xmlhttp = new XMLHttpRequest();
    } else {
      // code for IE6, IE5
      xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
    }
    xmlhttp.open("GET", settings.requestRoot + serviceDeleteSVG+"?scope=private&zoneId=" + zoneId + "&charter=" + settings.charter + "&svgId=" + settings.svgId, false);
    xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
    xmlhttp.onreadystatechange = function () {
      if (xmlhttp.readyState == 4) {
        if (xmlhttp.status == 200) {
          error = 0;
          metadataPath = xmlhttp.responseXML;
        } else {
          error++;
          if (error < 20)
          deleteSVGrect(zoneId); else {
            error = 0;
          }
        }
      }
    };
    xmlhttp.send();
  };
  
  // add facs attribute to related tag
  function addFacsAttribut(zoneId) {
    // add facs attribut with cei:zone- id to selected Tag
    var attributes = new AttributesImpl();
    attributes.addAttribute(null, 'facs', 'facs', undefined, zoneId);
    $('.xrx-instance').xrxInstance().insertAttributes(settings.droppedObject, attributes);
  };
  
  // get index of searched tag
  function getIndex(type, zoneId) {
    var index;
    
    // load linked img name
    var currentImgUrl = document.getElementById('img').src;
    var imgName = currentImgUrl.split('/').pop();
    
    // send request to service
    var xmlhttp;
    if (window.XMLHttpRequest) {
      // code for IE7+, Firefox, Chrome, Opera, Safari
      xmlhttp = new XMLHttpRequest();
    } else {
      // code for IE6, IE5
      xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
    }
    xmlhttp.open("GET", settings.requestRoot + serviceGetIndex+"?type=" + type + "&zoneId=" + zoneId + "&charter=" + settings.charter + "&imgName=" + imgName, false);
    xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
    xmlhttp.onreadystatechange = function () {
      if (xmlhttp.readyState == 4) {
        if (xmlhttp.status == 200) {
          error = 0;
          index = xmlhttp.responseText;
        } else {
          error++;
          if (error < 20)
          getIndex(type, zoneId); else {
            error = 0;
          }
        }
      }
    };
    xmlhttp.send();
    
    return index;
  };
  
  // get metadata path for jsax parser
  function getMetadataPath(zoneId) {
    var metadataPath;
    
    // send request to service
    var xmlhttp;
    if (window.XMLHttpRequest) {
      // code for IE7+, Firefox, Chrome, Opera, Safari
      xmlhttp = new XMLHttpRequest();
    } else {
      // code for IE6, IE5
      xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
    }
    xmlhttp.open("GET", settings.requestRoot + serviceGetMetadataPath+"?zoneId=" + zoneId + "&charter=" + settings.charter, false);
    xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
    xmlhttp.onreadystatechange = function () {
      if (xmlhttp.readyState == 4) {
        if (xmlhttp.status == 200) {
          error = 0;
          metadataPath = xmlhttp.responseXML;
        } else {
          error++;
          if (error < 20)
          getMetadataPath(zoneId); else {
            error = 0;
          }
        }
      }
    };
    xmlhttp.send();
    
    return metadataPath;
  };
  
  // start select process
  function startSelect() {
    if (jQuery(document).imageTool.annoVisible())
    jQuery(document).imageTool.changeAnnoDisplayStatus();

    // set mouse cursor style
    jQuery('#img').css('cursor', 'crosshair');

    // init imgAreaSelect Plugin
    jQuery('#img').imgAreaSelect({
      handles: true,
      onSelectEnd: function (img, selection) {
        endSelection(selection);
      }
    });
    
    // change button to stop select process
    jQuery("#create-new-anno-button").find("span").text(jQuery(document).i18nText.get('cancel'));
    jQuery("#create-new-anno-button").unbind('click').click(function (event) {
      stopSelect();
    });
    
    // show button to save selection and hide 'show annotation' button
    jQuery('#save-selection-button').css('display', 'inline');
    jQuery('#show-anno-button').css('display', 'none');
    
    // set current work mode
    settings.mode = "select";
    
    // close south region
    $('.xrx-layout').layout().close("south");
  };
  
  // stop select process
  function stopSelect() {
    // set current work mode
    settings.mode = "base";
    
    // set mouse cursor style
    jQuery('#img').css('cursor', 'auto');

    // remove imgAreaSelect Plugin
    jQuery('#img').imgAreaSelect({
      remove: true
    });
    
    // change Button to default values
    jQuery("#create-new-anno-button").find("span").text(jQuery(document).i18nText.get('create-new'));
    jQuery("#create-new-anno-button").unbind('click').click(function (event) {
      startSelect();
    });
    
    // hide button to save selection and show 'show annotation' button
    jQuery('#save-selection-button').css('display', 'none');
    jQuery('#show-anno-button').css('display', 'inline');
    
    // hide add metadata button
    jQuery("#add-metadata-button").css('display', 'none');
  };
  
  // cancel metadata process
  function endMetadataProcess() {
    // set current work mode
    settings.mode = "base";
    
    // change Button to default values
    jQuery("#create-new-anno-button").find("span").text(jQuery(document).i18nText.get('create-new'));
    jQuery("#create-new-anno-button").unbind('click').click(function (event) {
      startSelect();
    });
    // delete dummy markup field
    old = document.getElementById("dummySelection");
    if (old != null) {
      old.parentNode.removeChild(old);
    }
    // hide button to add metadata/ save metadata and show 'show annotation' button
    jQuery('#add-metadata-button').css('display', 'none');
    jQuery("#save-metadata-button").css('display', 'none');
    jQuery('#create-metadata-field').css('display', 'none');
    jQuery('#show-anno-button').css('display', 'inline');
    
    // reset style
    resetStyle();
    
    // remove draggable actions
    if ($('.xrx-tagname').parent().data('draggable'))
    $('.xrx-tagname').parent().draggable('destroy');
  };
  
  // reset image tool style
  function resetStyle() {
    // show Image and hide SVG
    if (jQuery(document).imageTool.annoVisible())
    jQuery(document).imageTool.changeAnnoDisplayStatus();
    // reset add elements
    $('#zone-description').val("");
    $('.drop-pointer').css('display', 'none');
    $('#drop-area').css('display', 'none');
  };
  
  // set selection window
  function endSelection(selection) {
    var multifactor = getImgSize(document.getElementById('img').src);
    toolSelection.x1 = Math.round(selection.x1 * multifactor);
    toolSelection.y1 = Math.round(selection.y1 * multifactor);
    toolSelection.width = Math.round(selection.width * multifactor);
    toolSelection.height = Math.round(selection.height * multifactor);
  };
  
  // calculate the zooming factor
  function getImgSize(imgSrc) {
    var size = jQuery('#img').width();
    var newImg = new Image();
    newImg.src = imgSrc;
    var width = newImg.width / size;
    return width;
  };
  
  // use selection and start "input metadata"- process
  function useSelection() {
    // remove imgAreaSelect Plugin
    jQuery('#img').imgAreaSelect({
      remove: true
    });
    // set cancel button to metadata mode
    jQuery("#create-new-anno-button").unbind('click').click(function (event) {
      endMetadataProcess();
    });
    
    // set current work mode
    settings.mode = "metadata";
    
    // create new dummy- selection area in svg img
    var bild = document.createElementNS("http://www.w3.org/2000/svg", "rect");
    bild.setAttribute("x", toolSelection.x1);
    bild.setAttribute("y", toolSelection.y1);
    bild.setAttribute("width", toolSelection.width);
    bild.setAttribute("height", toolSelection.height);
    bild.setAttribute("style", "stroke:blue;stroke-width:2;fill-opacity:0;");
    bild.setAttribute("id", "dummySelection");
    $("#" + settings.svgId).append(bild);
    
    // turn SVG img on and html img off
    jQuery(document).imageTool.changeAnnoDisplayStatus();
    
    // display button for next work step
    jQuery("#save-selection-button").css('display', 'none');
    jQuery("#add-metadata-button").css('display', 'inline');
    
    // init add-metadata Button
    jQuery("#add-metadata-button")
    .button()
    .unbind('click').click(function (event) {
      useMetadata("new");
    });
  };
  
  // create drag und drop functions to add metadata
  function useMetadata(type, zoneId, xmlDoc) {
    // open south region
    $('.xrx-layout').layout().open("south");
    $('.xrx-tagname').parent().css('cursor', 'move');
    
    // show draggable and droppable objects
    $('#drop-area').css('display', 'block');
    
    // init drag process - show different styles on dragging objects
    $('.xrx-tagname').parent().draggable({
      appendTo: "body",
      cursorAt: {
        left: 0
      },
      zIndex: 300,
      revert: "true",
      cursor: "pointer",
      helper: "clone",
      distance: 10,
      start: function (event, ui) {
        // show dropping arrows
        $('#drop-annotation-markup-tag').removeClass("inactive-drop-annotation");
        $('#drop-annotation-markup-tag').addClass("active-drop-annotation");
      },
      stop: function (event, ui) {
        // hide dropping arrows
        $('#drop-annotation-markup-tag').removeClass("active-drop-annotation");
        $('#drop-annotation-markup-tag').addClass("inactive-drop-annotation");
      }
    });
    
    // init droppable process - define actions on drop
    $("#drop-annotation-markup-tag").droppable({
      drop: function (event, ui) {
        baseString = $('.xrx-tagname').attr("id");
        settings.droppedObject = baseString.split(",");
        // check linked Mark Up
        if (settings.droppedObject == "none" || settings.droppedObject == undefined)
        alert(jQuery(document).i18nText.get('select-tag-to-drop')); else {
          // check for attribute
          var attributes =[];
          $('.xrx-attributes input').each(function () {
            attributes.push($(this).attr('name'))
          });
          if (jQuery.inArray("facs", attributes) == - 1) {
            // setup GUI elements
            tagDropped();
            
            // add existing description to textarea
            if (type == "create-new-relation" || type == "edit-relation") {
              if (xmlDoc.getElementsByTagName('desc')[0].childNodes[0] != undefined)
              var desc = xmlDoc.getElementsByTagName('desc')[0].childNodes[0].nodeValue; else
              var desc = "";
              $("#zone-description").val(desc);
            }
            
            // init trash icon to delete selected tag
            jQuery("#tag-to-trash")
            .unbind('click').click(function (event) {
              settings.droppedObject = "none";
              // selected tag to trash
              $('#selected-tag').text("");
              // go step back of creation process - select metadata tag
              jQuery("#save-metadata-button").css('display', 'none');
              jQuery('#create-metadata-field').css('display', 'none');
              useMetadata(type, zoneId, xmlDoc);
            });
            
            // init save metadata button
            jQuery("#save-metadata-button")
            .button()
            .unbind('click').click(function (event) {
              if (type == "new")
              saveMetadataTag(); else if (type == "create-new-relation")
              updateMetadataTag(zoneId); else if (type == "edit-relation") {
                deleteMetadataTag(zoneId);
                updateMetadataTag(zoneId);
              } else
              restoreMetadataTag(zoneId);
            });
          } else {
            alert(jQuery(document).i18nText.get('tag-not-available'));
          }
        }
      }
    });
  };
  
  // when the tag is selected, the GUI will be adjusted
  function tagDropped() {
    // set style setup
    $('.xrx-tagname').parent().css('cursor', 'text');
    $('.drop-pointer').css('display', 'none');
    $('#drop-annotation-markup-tag').removeClass("active-drop-annotation");
    $('#drop-annotation-markup-tag').addClass("inactive-drop-annotation");
    $('#drop-area').css('display', 'none');
    
    // next step of creation process - save metadata
    jQuery("#add-metadata-button").css('display', 'none');
    jQuery("#save-metadata-button").css('display', 'inline');
    jQuery('#create-metadata-field').css('display', 'block');
    
    // show tag name in metadata area
    $('#selected-tag').text(jQuery('.xrx-tagname:first').text());
  };
  
  // delete relation to metadata element
  function deleteMetadataTag(zoneId) {
    // get index of cei:figure
    var controlId, xmlDoc = getMetadataPath(zoneId);
    var siblings = xmlDoc.getElementsByTagName('siblings')[0].childNodes[0].nodeValue;
    var expression = xmlDoc.getElementsByTagName('jsaxPath')[0].childNodes[0].nodeValue;
    var nodeNumber = xmlDoc.getElementsByTagName('index')[0].childNodes[0].nodeValue;
    var nodeset = window.XPath.query(expression, $('.xrx-instance').text());
    if (siblings == "true") {
      if (nodeset.only == null || nodeset.only == undefined) {
        controlId = nodeset.nodes[nodeNumber].levelId;
      }
    } else {
      controlId = nodeset.only.levelId;
    }
    var attributes = new AttributesImpl();
    attributes.addAttribute(null, 'facs', 'facs', undefined, zoneId);
    $('.xrx-instance').xrxInstance().deleteAttributes(controlId, attributes);
  }
  
  // update related metadata and restore cei:zone- tag
  function restoreMetadataTag(zoneId) {
    // add facs attribut
    addFacsAttribut(zoneId);
    // get index of cei:figure
    var index = getIndex("figure", zoneId);
    // load linked img name
    var currentImgUrl = document.getElementById('img').src;
    var imgName = currentImgUrl.split('/').pop();
    // create cei:zone
    createZoneTag(imgName, index, zoneId);
    // reset dropped object and reset input
    endMetadataProcess();
    settings.droppedObject = "none";
  };
  
  // update related metadata
  function updateMetadataTag(zoneId) {
    // add facs attribut
    addFacsAttribut(zoneId);
    // get index of cei:zone
    var index = getIndex("zone", zoneId);
    // update cei:zone
    updateZoneTag(index, zoneId);
    // reset dropped object and reset input
    endMetadataProcess();
    settings.droppedObject = "none";
  };
  
  // save metadata tags
  function saveMetadataTag() {
    // create facs attribut
    var randomId = Math.random();
    randomId = "_zone_" + randomId;
    randomId = randomId.replace(".", "");
    var currentImgUrl = document.getElementById('img').src;
    var imgName = currentImgUrl.split('/').pop();
    var cleanedImgName = cleanImageURL(imgName);
    var zoneId = cleanedImgName + randomId;
    
    // add facs attribut
    addFacsAttribut(zoneId);
    
    // create new cei:zone and cropped image and connect it to markup
    saveAnnotation(zoneId);
  };
  
  // create new cei:zone and cropped image and connect it to markup
  function saveAnnotation(zoneId) {
    // load linked img name
    var currentImgUrl = document.getElementById('img').src;
    var imgName = currentImgUrl.split('/').pop();
    
    // define POST parameters
    var parameters = "x=" + toolSelection.x1 + "?!;y=" + toolSelection.y1 + "?!;width=" + toolSelection.width + "?!;height=" + toolSelection.height + "?!;imgUrl=" + currentImgUrl + "?!;";
    
    // send request to service
    var xmlhttp;
    if (window.XMLHttpRequest) {
      // code for IE7+, Firefox, Chrome, Opera, Safari
      xmlhttp = new XMLHttpRequest();
    } else {
      // code for IE6, IE5
      xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
    }
    xmlhttp.open("POST", settings.requestRoot+serviceSaveAnno+"?scope=private&zoneId=" + zoneId + "&charter=" + settings.charter + "&imgName=" + imgName + "&svgId=" + settings.svgId, false);
    xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
    xmlhttp.onreadystatechange = function () {
      if (xmlhttp.readyState == 4) {
        if (xmlhttp.status == 200) {
          error = 0;
          var breadcrump = document.createElement("div");
          // save process sucessful - now save element tags
          var xmlDoc = xmlhttp.responseXML;
          // svg has to be loaded as Text - otherwise browser will not display it in the right way
          breadcrump.innerHTML = xmlhttp.responseText;
          var nodeNumber = xmlDoc.getElementsByTagName('index')[0].childNodes[0].nodeValue;
          var newSVG = breadcrump.childNodes[0].childNodes[1].childNodes[0];
          
          // create zone tag
          createZoneTag(imgName, nodeNumber, zoneId);
          
          // delete current SVG file
          var svg = document.getElementById("img-svg");
          if (svg.firstChild != null) {
            svg.removeChild(svg.firstChild);
          }
          
          // load updated SVG file
          $("#img-svg").append(newSVG);
          
          // reset dropped object and reset input
          endMetadataProcess();
          settings.droppedObject = "none";
        } else {
          error++;
          if (error < 20)
          saveAnnotation(zoneId); else {
            error = 0;
          }
        }
      }
    };
    xmlhttp.send(parameters);
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

  // init service URI's
  function initServiceUris(){
      serviceGetIndex       = "service/"+settings.servicePrefix+"get-index";
      serviceGetMetadataPath  = "service/"+settings.servicePrefix+"get-metadata-path";
      serviceSaveAnno = "service/"+settings.servicePrefix+"save-annotation";
      serviceDeleteSVG = "service/"+settings.servicePrefix+"delete-svg-rect";

  };
})(jQuery);