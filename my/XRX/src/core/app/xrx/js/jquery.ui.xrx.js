/*!
 * jQuery UI xrx
 *
 * Depends:
 *   jquery.ui.core.js
 *   jquery.ui.widget.js
 */
(function( $, undefined ) {
	
$.widget( "ui.xrx", {
	
	_create: function() {},
	
	_options: function() {
		
		var self = this,
			element = self.element[0],
			options;
		
		if(typeof element.onclick !== 'function') return {};
		
		options = element.onclick();
		element.onclick = null;
		
		return options;
	}
		
});
	
})( jQuery );