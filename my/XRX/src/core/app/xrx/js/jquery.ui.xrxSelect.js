/*!
 * jQuery UI Forms Repeat
 *
 * Depends:
 *   jquery.ui.core.js
 *   jquery.ui.widget.js
 */
(function( $, undefined ) {
	
$.widget( "ui.xrxSelect", {
	
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

		var container = $('<div></div>').attr("class", "xrx-select");
		var node, iter = nodesetControl.iterator(), visualxml = [], index = 0;

		while(node = iter()) {
			var n = node;
			
			var div = $('<div></div>').css("display", "table-row");
			
			var textarea = $('<textarea class="xrx-visualxml">' + node.xml + '</textarea>');
			textarea.attr('data-xrx-ref', ref);
			textarea.attr('data-xrx-index', index);
			
			var menuwrap = $('<div></div>');
			var menuliste = $('<ul></ul>').attr('id', 'menu');
			console.log(n.xml);
			
			//"<cei:class xmlns:cei="http://www.monasterium.net/NS/cei"></cei:class>"
			var menuItem = 
				$('<li><a href="#" >Königsurkunde</a></li>')
					.attr("title", "Königsurkunde");
			menuItem.bind("click", { node: n }, function(event) {
				var xml = 'Königsurkunde';				
	    		numText = 1;			
		
	    		$('.xrx-instance').xrxInstance().replaceTextNode(event.data.node.levelId, numText, xml);
			    console.log(numText);
			    self.refresh();
				$(function() {
	                    $( "#menu" ).menu();
	                         });
			console.log(n);
			console.log(n.type);
			console.log(n.xml);
			});
					
			var menuItem2 = 
				$('<li><a href="#">Sammelindulgenz</a></li>')
					.attr("title", "Sammelindulgenz");
			menuItem2.bind("click", { node: n }, function(event) {
				var xml = 'Sammelindulgenz';				
	    		numText = 1;			
		
	    		$('.xrx-instance').xrxInstance().replaceTextNode(event.data.node.levelId, numText, xml);
			    console.log(numText);
			    self.refresh();
			  $(function() {
                    $( "#menu" ).menu();
                         }); 
			});
			var menuItem3 = 
				$('<li><a href="#">Papsturkunde</a></li>')
					.attr("title", "Papsturkunde");
			menuItem3.bind("click", { node: n }, function(event) {
				var xml = 'Papsturkunde';				
	    		numText = 1;			
		
	    		$('.xrx-instance').xrxInstance().replaceTextNode(event.data.node.levelId, numText, xml);
			    console.log(numText);
			    self.refresh();
			    $(function() {
	                 $( "#menu" ).menu();
	                      });
				
			});
			if(n.xml== '<cei:class xmlns:cei="http://www.monasterium.net/NS/cei"></cei:class>') {
				console.log('jippie');
				console.log(n);
				$('.xrx-instance').insertAfter(n.levelId, 'bla');
			}
			menuliste.append(menuItem).append(menuItem2).append(menuItem3);
			menuwrap.append(menuliste);			
			
			div.append(textarea).append(menuwrap);	
			container.append(div);


			visualxml.push($(textarea).xrxVisualxml({ repeatflag: true, xml: node.xml }));
			
			
		    }
	
		 $(function() { $( "#menu" ).menu();
         }); //rufe von hier aus menu auf.
		control.css("display", "table");
		self.element.children().replaceWith(container.children());
		
		self.element.find("div").find(".CodeMirror").css("display", "table-cell");
		
		for(var i = 0; i < visualxml.length; i++) {
			visualxml[i].xrxVisualxml("refresh");
		}
	}
});
	
})( jQuery );
