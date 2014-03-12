/*!
 * jQuery UI XRX Tabs
 *
 * Depends:
 *   jquery.ui.tabs.js
 */
(function( $, undefined ) {
	
$.widget( "ui.progressbarImport", {

	options: {
		serviceUrlImportProgress: "",
		cacheId: "",
		processId: ""
	},
	
	_create: function() {
		
		var self = this;
		
		self.label = $(".progress-label", "#" + $(self.element[0]).attr("id"));
		
		self.progbar = self.element.progressbar({
			value: false,
			change: function() {
				self.label.text( self.progbar.progressbar( "value" ) + "%" );
			}
		});
	},
	
	progress: function() {
		
		var self = this;

		$.ajax({
			url: self.options.serviceUrlImportProgress,
			contentType: "application/xml",
			type: "POST",
			data: '<xrx:progress xmlns:xrx="http://www.monasterium.net/NS/xrx"><xrx:cacheid>' + self.options.cacheId + '</xrx:cacheid><xrx:processid>' + self.options.processId + '</xrx:processid></xrx:progress>',
			complete: function(data, textStatus, jqXHR) {
				var json = jQuery.parseJSON(data.responseText);
				var actual = parseInt(json["actual"]);
				var total = parseInt(json["total"]);
				var message = json["message"] || "";
				var val;
				
				if(total == 0) { val = 0; }
				else { val = Math.round(((actual / total) * 100)); }

				if(message != "") { self.label.text(message); }
				else { self.progbar.progressbar( "value", val ); }
				
				if ( val != 100 ) {
					window.setTimeout( function() { self.progress() }, 1000 );
				}
			}
		});
		
	}
	
});
	
})( jQuery );