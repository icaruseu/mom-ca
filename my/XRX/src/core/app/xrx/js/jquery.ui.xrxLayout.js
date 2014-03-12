/*!
 * jQuery UI XRX Layout
 *
 * Depends:
 *   jquery.ui.layout.js
 */
(function( $, undefined ) {
	
$.widget( "ui.xrxLayout", $.ui.xrx, {
	
	_create: function() {
		
		var self = this; 	
		
		self.element.layout(self._options());
	}
	
});
	
})( jQuery );