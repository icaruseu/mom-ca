/*!
 * jQuery UI Forms Mixed Content Tag-name
 *
 * Depends:
 *   jquery.ui.core.js
 *   jquery.ui.widget.js
 */
(function( $, undefined ) {

var uiMainDivId						=	"xrx-tagname";	
	
$.widget( "ui.xrxTagname", {

	options: {
		qName: null,
    elementId: null
	},
	
	_create: function() {
		
		var self = this,
			name = self.options.qName,
      elementId = self.options.elementId,
			
			tagnameDiv = $('<div></div>')
				.attr("class", uiMainDivId)
        .attr("id", elementId)
				.text($(document).xrxI18n.translate(name, "xs:element"));

		self.element.replaceWith(tagnameDiv);
	}
		
});
	
})( jQuery );