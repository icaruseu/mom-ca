/*!
 * jQuery UI Forms Repeat
 *
 * Depends:
 *   jquery.ui.core.js
 *   jquery.ui.widget.js
 */
(function( $, undefined ) {
	
$.widget( "ui.xrxRepeat", {
	
	_create: function() {
		
		var self = this;
		self.refresh();
	},
	
	refresh: function() {
		var self = this,
			bindId = self.element.attr('data-xrx-bind'),
			bind = $('#' + bindId),
			nodeset = $(bind).attr('data-xrx-nodeset');
		
		var control = self.element.find(".xrx-visualxml").first(); // TODO: deep copy the original HTML instead an save it as this.original
		var ref = $(control).attr('data-xrx-ref');
		
		var nodesetControl = window.XPath.query(nodeset + ref, $('.xrx-instance').text());	

		var container = $('<div></div>');
		var node, iter = nodesetControl.iterator(), visualxml = [], index = 0;

		while(node = iter()) {
			var n = node;
			var div = $('<div></div>').css("display", "table-row");
			
			// compose textarea
			var textarea = $('<textarea class="xrx-visualxml">' + node.xml + '</textarea>');
			textarea.attr('data-xrx-ref', ref);
			textarea.attr('data-xrx-index', index);
			
			// compose delete button TODO: descriptive
			var deleteButton = $('<button>-</button>').button({ icons: { primary: "ui-icon-trash" }, text: false });
			deleteButton.css("display", "table-cell").css("font-size", ".8em").css("margin-left", "50px");
			deleteButton.bind("click", { node: n }, function(event){
				$('.xrx-instance').xrxInstance().replaceElementNode(event.data.node.levelId, "");
				self.refresh();
			});
			
			// compose add button TODO: descriptive
			var addButton = $('<button>+</button>').button({ icons: { primary: "ui-icon-plus" }, text: false });
			addButton.css("display", "table-cell").css("font-size", ".8em");
			addButton.bind("click", { node: n }, function(event) {
				$('.xrx-instance').xrxInstance().insertAfter(event.data.node.levelId, window.XML.createStartElement([], event.data.node.qName) + window.XML.createEndElement(event.data.node.qName));
				self.refresh();
			});
			
			if(index == 0) {
				div.append(textarea).append(addButton);
				addButton.css("margin-left", "50px");
			}
			else div.append(textarea).append(deleteButton).append(addButton);
			
			container.append(div);
			
			visualxml.push($(textarea).xrxVisualxml({ repeatflag: true, xml: node.xml }));
			index++;
		}
		control.css("display", "table");
		self.element.children().replaceWith(container.children());
		
		self.element.find("div").find(".CodeMirror").css("display", "table-cell");
		
		for(var i = 0; i < visualxml.length; i++) {
			visualxml[i].xrxVisualxml("refresh");
		}
	}
	
});
	
})( jQuery );