/*!
* jQuery annotation overview
*
*/
(function ($) {
  var error = 0;

  // settings
  var settings = {
    requestRoot: "",
    widget: "",
    collection: "",
    scope: ""
  };
  
  /*
  * public interface
  */
  
  // init the scroll box surfaces and functions
  $.fn.annoOverview = function (options) {
    settings.requestRoot = options.requestRoot;
    settings.collection = options.collection;
    settings.widget = options.widget;
    settings.scope = options.scope;

    // init annotation entries
    if(settings.widget == "annoOverview")
      initAnnotationEntries();
  };

  // select collection to show annotations
  $.fn.annoOverview.selectCollection = function (collectionId) {
    settings.collection = collectionId;

    // init annotation entries
    if(settings.collection != "no-value")
      initAnnotationEntries();
  };
  
  /*
  * private functions
  */
  
  // show metadata of selected cropped annotation
  function showMetadata(index) {
    var charter = $('#anno-'+index).attr('title');
    var zoneId  = $('#anno-'+index).attr('alt');
    getAnnotationData(zoneId, charter);
   };

  // focused annotation has changed
  function changeFocusedAnnotation(){
    var focusedAnno = $('ul').roundabout("getChildInFocus"); 
    showMetadata(focusedAnno);
  };
  
  // init the annotation images
  function initAnnotationEntries() {
    // display loading gif
    jQuery('#loading').css('display', 'block'); 
    // send request to service
    var xmlhttp;
    if (window.XMLHttpRequest) {
      // code for IE7+, Firefox, Chrome, Opera, Safari
      xmlhttp = new XMLHttpRequest();
    } else {
      // code for IE6, IE5
      xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
    }
    xmlhttp.open("GET", settings.requestRoot + "service/get-cropped-annos-images?collection="+settings.collection+"&scope="+settings.scope, false);
    xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
    xmlhttp.onreadystatechange = function () {
      if (xmlhttp.readyState == 4) {
        if (xmlhttp.status == 200) {
          error = 0;
          // hide loading gif
          jQuery('#loading').css('display', 'none');
          jQuery('#select-arrows').css('display', 'block');
          var entries = xmlhttp.responseText;
          if(entries == "no-annos")
            {
            // no annotation available - display info
            $('#data-table').css('display', 'none');
            $('#scrollBox').css('display', 'none');
            $('#no-annos').css('display', 'block');
            }
          else
            {
            $('#no-annos').css('display', 'none');
            $('#scrollBox').css('display', 'block');
            // init annotation entries as content
            document.getElementById('scrollBox').innerHTML = entries;
            /*
             * Browser webkit - first load all images and then init roundup
             */
            // get all new images
            var images = new Array();
            var i = 0;
            jQuery('#scrollBox').find('img').each( function() {
                images[i] = $(this).attr('src');
                i++;
            });

            var m = 0;
            
            // go through all images
            $(images).each( function(){
                var imageObj = new Image();
                imageObj.src = images[m];
                $(imageObj).load( function() {
                    m++;
                    if(m == i){
                      // loaded all images - now init roundup module
                      $('ul').roundabout({
                        minOpacity: 0.1,
                        minScale: 0.1,
                        maxScale: 0.8,
                        shape: 'figure8',
                        btnNext: '#arrow-selector-right',
                        btnPrev: '#arrow-selector-left',
                        clickToFocusCallback: changeFocusedAnnotation
                      });
                      // show metadata of first cropped annotation
                      showMetadata('0');
                    }    
                });
            });
            }
          }
        else {
          error++;
          if (error < 20)
          initAnnotationEntries(); 
          else
          error = 0;
        }
      }
    };
    xmlhttp.send();
  };

  // get metadata of cropped annotation
  function getAnnotationData(zoneId, charter) {
    // send request to service
    var xmlhttp;
    if (window.XMLHttpRequest) {
      // code for IE7+, Firefox, Chrome, Opera, Safari
      xmlhttp = new XMLHttpRequest();
    } else {
      // code for IE6, IE5
      xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
    }
    xmlhttp.open("GET", settings.requestRoot + "service/get-cropped-anno-metadata?collection="+settings.collection+"&charter="+charter+"&zoneId="+zoneId+"&scope="+settings.scope, false);
    xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
    xmlhttp.onreadystatechange = function () {
      if (xmlhttp.readyState == 4) {
        if (xmlhttp.status == 200) {
          error = 0;
          xmlDoc = jQuery.parseXML(xmlhttp.response);
          if(xmlDoc.getElementsByTagName('relationStatus')[0].childNodes[0].nodeValue == "ok"){
            // show metadata of annotation
            $('#data-table').css('display', 'block');
            $('#data-broken').css('display', 'none');
            var url = xmlDoc.getElementsByTagName('charter')[0].childNodes[0].nodeValue;
            $('#charter-data').attr('href', url);
            $('#charter-data').text(url);
            var searchedTag = xmlDoc.getElementsByTagName('related')[0].childNodes[0].nodeValue
            var optimizedKey = searchedTag.replace(":", "_");
            $('#related-to-data').text(jQuery(document).i18nText.get(optimizedKey));
            if (xmlDoc.getElementsByTagName('content')[0].childNodes[0] != undefined)
              $('#content-data').text(xmlDoc.getElementsByTagName('content')[0].childNodes[0].nodeValue);
            if (xmlDoc.getElementsByTagName('desc')[0].childNodes[0] != undefined)
              $('#desc-data').text(xmlDoc.getElementsByTagName('desc')[0].childNodes[0].nodeValue);
            else
              $('#desc-data').text('');
          }
          else {
            // annotation is broken - display info
            $('#data-table').css('display', 'none');
            $('#data-broken').css('display', 'block');
          }
          }
        else {
          error++;
          if (error < 20)
          getAnnotationData(zoneId, charter); 
          else
          error = 0;
        }
      }
    };
    xmlhttp.send();
  };
})(jQuery);
