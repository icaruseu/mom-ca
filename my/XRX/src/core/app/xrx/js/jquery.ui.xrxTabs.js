/*!
 * jQuery UI XRX Tabs
 *
 * Depends:
 *   jquery.ui.tabs.js
 */
(function( $, undefined ) {
	
$.widget( "ui.xrxTabs", $.ui.xrx, {
	
	_create: function() {
		
		var self = this; 	
		
		self.element.tabs(self._options());
	}
	
});
	
})( jQuery );