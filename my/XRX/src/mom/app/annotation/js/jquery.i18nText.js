/*!
 * jQuery i18nText
 *
 */

;(function($) {

    var servicei18n             =        "service/get-i18n-text";
    var error                   =         0;
    
    // Plugin defaults 
    var settings = {
      lang: "eng",
      requestRoot: ""
    };

   /*
	 * public interface
	 */
  
  // init the i18n language
  $.fn.i18nText = function( options ) {
      settings.lang = options.lang;
      settings.requestRoot = options.requestRoot;
	};


  // get the i18n messages
  $.fn.i18nText.get = function(key){
    var text;

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
    xmlhttp.open("GET", settings.requestRoot+servicei18n+"?key="+key+"&amp;lang="+settings.lang,false);
    xmlhttp.setRequestHeader("Content-type", "text/xml; charset=UTF-8");
    xmlhttp.onreadystatechange=function(){
    if (xmlhttp.readyState==4)
          {
           if (xmlhttp.status==200)
                 {
                 error = 0;
                 text = xmlhttp.responseText;
                 }
             else
                 {
                 error++;
                 if(error < 20)
                   jQuery(document).i18nText.get(key);
                 else
                   {
                   error = 0;
                   }
                 }
            }
       };
     xmlhttp.send();

     // return text of i18n message
    return text;
};

})( jQuery );