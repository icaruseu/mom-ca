/*!
 * jQuery XRX++ i18n
 *
 */
;(function($) {
	
	$.fn.xrxI18n = function() {

		document.catalog = jQuery.parseJSON($('.xrx-data-messages').text());
		return this.each(function(index) {
		});
	};
	
	$.fn.xrxI18n.translate = function(key, type) {
		var optimizedKey = "", translated;
		
		switch(type) {
		case "xs:attribute":
			optimizedKey = "cei_" + key.replace(":", "_");
			break;
		case "xs:element":
			optimizedKey = key.replace(":", "_");
			break;
		default:
			optimizedKey = key;
			break;
		}
		return document.catalog[optimizedKey] ? document.catalog[optimizedKey] : key;
	};
	
})(jQuery);