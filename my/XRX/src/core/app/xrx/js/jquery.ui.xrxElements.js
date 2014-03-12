/*!
 * jQuery UI Forms Mixed Content Elements
 *
 * Depends:
 *   jquery.ui.core.js
 *   jquery.ui.widget.js
 *   jquery.ui.button.js
 */
(function( $, undefined ) {

var uiMainDivId						=	"xrx-elements";
var uiElementsMenuWrapperDivClass	=	"forms-mixedcontent-elements-menu-wrapper";
var uiElementsMenuButtonDivClass	=	"forms-mixedcontent-elements-menu-button";
var uiElementsMenuDivClass			=	"forms-mixedcontent-elements-menu";

$.widget( "ui.xrxElements", {
	
	options: {
		menues:null,
		cm:null,
		replaceString:""
	},
	
	_create: function() {
		
		var self = this,
			menues = self.options.menues,
		
			mainDiv = $('<div></div>')
				.attr("class", uiMainDivId);
		
		for(var i = 0 in menues) {
			var menuWrapper = $('<div></div>').addClass(uiElementsMenuWrapperDivClass),
				menuButton = $('<button></button>')
					.addClass(uiElementsMenuButtonDivClass)
					.text(menues[i].topic),
				menuItemList = $('<ul></ul>');
			for(var j = 0 in menues[i].items) {
				var menuItem = 
					$('<li><a href="#">' + $(document).xrxI18n.translate(menues[i].items[j], "xs:element") + '</a></li>')
						.attr("title", menues[i].items[j]);
				menuItemList.append(menuItem);
			}
			menuWrapper.append(menuButton).append(menuItemList);
			mainDiv.append(menuWrapper);
		}
		//console.log(menues);
		self.element.replaceWith(mainDiv);
		
		self._menuClickable();
	},
	
	_menuClickable: function() {
		
		var self = this,
			cm = self.options.cm,
			replaceString = self.options.replaceString;

		$("." + uiElementsMenuButtonDivClass, "." + uiMainDivId).button({ 
			icons: { secondary: "ui-icon-triangle-1-s" } 
		}).each( function() {
			$(this).next().menu({
				select: function(event, ui) {
					$(this).hide();
				},
				input: $(this)
			}).hide();
		}).click( function(event) {
			var menu = $(this).next();
			if (menu.is(":visible")) {
				menu.hide();
				return false;
			}
			$("." + uiMainDivId + " ul").hide();
			$("." + uiMainDivId + " button").find("span").removeClass("ui-menu-selected");
			$(this).find("span").addClass("ui-menu-selected");
			menu.menu("disable").show().css({top:30, right:0}).position({
				my: "right top",
				at: "right top",
				of: this
			});
			$(document).one("click", function() {
				menu.hide();
				$("." + uiMainDivId + " button").find("span").removeClass("ui-menu-selected");
			});
			return false;
		});
		
	}
		
});
	
})( jQuery );