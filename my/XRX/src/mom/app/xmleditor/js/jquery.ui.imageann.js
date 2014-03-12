/*!
 * jQuery UI Image Annotator
 *
 * Depends:
 *   jquery.ui.core.js
 *   jquery.ui.widget.js
 *   jquery.ui.draggable.js
 *   jquery.mousewheel.js
 */
(function( $, undefined ) {

$.widget( "ui.imageann", {
	
	version: "@VERSION",
	
	_create: function() {
		
		this._initMousewheel();
		this._initDraggable();
		this._initImageSelect();
	},

	_initDraggable: function() {
		
		var main = $("#ui-imageann");
		main.find("div:first").draggable();
		main.css("width", "100%");
		var firstImage = 
			$(this.uiSelf().find("div")).find("img");
		firstImage.css("display", "inline");
		firstImage.css("width", "100%");
	},
	
	_initMousewheel: function() {
		var scale = 1;
		this.uiSelf().bind('mousewheel', function(e, delta) {
		    if (delta > 0) { scale += 0.05; }
		    else { scale -= 0.05; }
		    scale = scale < 0.2 ? 0.2 : (scale > 40 ? 40 : scale);
		
		    var x = e.pageX - $(this).offset().left;
		    var y = e.pageY - $(this).offset().top;
		    
		    $(this).find("div").css("width", scale * 100 + "%");
        $(this).find("div").find("img").css("width", scale * 100 + "%");
		    
		    return false;
		});
	},
	
	uiSelf: function() {
		
		return $("#ui-imageann")
	},
	
	uiImageselect: function() {
		
		return $( "#ui-imageselect" )
	},
	
	_initImageSelect: function() {
		
		this.uiImageselect().selectable({
			stop: function() {
				var result = $( "#img" );
				$( ".ui-selected", this ).each(function() {
					var index = $( "#ui-imageselect li" ).index(this);
					var url = $($( "#ui-imageselect li" )[index]).attr("title");
					result.attr( "src", url );
				}); 
        // reload SVG and cancel create- process
        if(jQuery(document).imageTool.getinitSVG())
           {
           jQuery(document).imageTool.resetSVGId();
           jQuery(document).createAnno.resetCreateProcess();
           jQuery(document).imageTool.loadSVG();
           }
			}
		});
	}
});

})( jQuery );