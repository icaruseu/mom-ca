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
		/* proof the variable data: 
		 * if there are ampersands, 
		 * they are escaped 
		 * part of issue #427
		 * */
		var data = $(".xrx-instance").text().replace(/&/g,'&amp;').replace(/&amp;amp;/g, '&amp;');
		
		$.ajax({
			url: self.options.requestRoot + serviceMyCollectionSave,
			type: "POST",
			contentType: "application/xml",
			data: data, 
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



function PermisDialog(){
	$("#permission_dialog").dialog({
		position: {my: "center", at: "center", of: "center"},
		width: 525,
		modal: true,
		buttons: {
			"back": function(){
				window.location="/mom/home";
			}
		}
	});

	$("div#permission_dialog").on('dialogclose', function(event){
		window.location="/mom/home";
		
	});
	
	
};


function CheckSessionStatus(){

	
	$.ajax({
		url: "service/CheckSessionStatus",
		type: "POST",
		contentType: "application/xml",
		data: "",
		dataType: "xml",
		success: function(response){				
			if($(response).find("result").text()=='true'){}
			else {
				location.reload();
				$('#dinner-textann').append("<div>you are logged-out. Please Relog");
			}
			},
	
		error: function(){				
	
			return false;
		}			
	});
}


