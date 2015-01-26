/*!
 * jQuery UI XML Editor
 *
 * Depends:
 *   jquery.ui.core.js
 *   jquery.ui.widget.js
 *   jquery.ui.tabs.js
 */
(function( $, undefined ) {

var serviceMyCollectionSave             =        "service/my-collection-save";
var serviceValidateInstance             =        "service/my-collection-charter-validate";

$.widget( "ui.xmleditor", {

	options: {
		requestRoot: ""
	},
	
	_create: function() {
		
		var self = this;
		
        jQuery(document).xrx({
        	serviceUrlValidateInstance: self.options.requestRoot + serviceValidateInstance
        });
		$("#ui-imageann").imageann();
	},
	
	save: function() {
		
		var self = this;
		console.log( "kuhmuh: " );
		$.ajax({
			url: self.options.requestRoot + serviceMyCollectionSave,
			type: "POST",
			contentType: "application/xml",
			data: $(".xrx-instance").text()
		});

	}
	
});
	
})( jQuery );