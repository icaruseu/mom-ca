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
	/* ajax-request of my-collection-save.service.xml */
	save: function() {
		var self = this;		
		$.ajax({
			url: self.options.requestRoot + serviceMyCollectionSave,
			type: "POST",
			contentType: "application/xml",
			data: $(".xrx-instance").text(),
			dataType: "xml",
			  /* 
			   * success function
			   * save-script was loaded, 
			   * if result = true the save-function is completed and the save function was a success
			   * if result = false the save-function is completed but the save function was not a success
			   */	
			success: function(response){
				if($(response).find('result').text() == "true"){
					$("#autoSaveStatus").text("All changes saved.");
					return true;
				}
				else {
					$("#autoSaveStatus").text("Failed to save changes.");
					return false;
				}			
			},
			error: function(){
			 $("#autoSaveStatus").text("Error: Failed to load save-script.");
			 
			 return false;
			}			
		});

	}
	
});
	
})( jQuery );