/*!
 * jQuery UI Forms Mixed Content
 *
 * Depends:
 *   jquery.ui.core.js
 *   jquery.ui.widget.js
 */
(function( $, undefined ) {

var NODE_ELEMENT_START = "element-start";
var NODE_ELEMENT_END = "element-end";
var NODE_TEXT = "text";
	
$.widget( "ui.xrxVisualxml", {
	
	options: {
		charElementStart: "»",
		charElementEnd: "«",
		repeatflag: false,
		xml: ""
	},
	
	/*
	 * Public Interface
	 */
	clear: function() {
		//console.log('die clear function in xrxVisualxml mit this codemirror');
		//console.log(this.codemirror);
		this.codemirror.clear();
		this.codemirror.refresh();
	},
	
	refresh: function() {
		
		this.codemirror.refresh();
	},
	
	validationRefresh: function() {
		//console.log('Die ValidationRefresh funktion wird ausgelöst.')
		var self = this, cm = this.codemirror;
		var report = $('.xrx-report').xrxReport("asJson");
		var messages = report["messages"], reportLength = report["length"], text = cm.getValue(), token, context;

		var cId = $(document).xrx.nodeset(cm.getInputField()).only.levelId;

		var InvalidElements = function() { this.invalidElements = []; }
		
		var getInvalidElements = function(cm) { return cm._invalidElements || (cm._invalidElements = new InvalidElements()); }
		
		var clearInvalidElements = function(cm) {
			
			var state = getInvalidElements(cm);
			
			for (var i = 0; i < state.invalidElements.length; ++i) {
				state.invalidElements[i].clear();
			}
			state.invalidElements = [];
		}
		
		// if instance is valid return
		if(!messages) {
			clearInvalidElements(cm);
			return;
		}
		
		// if control is valid return;
		var controlIsValid = true, key;
		for(key in messages) {
			var messageId = key.split('.');
			if(window.XML.isDescendantOrSelfLevel(messageId, cId)) controlIsValid = false;
		}
		if(controlIsValid) {
			clearInvalidElements(cm);
			return;
		}
		
		// if there are invalid messages for this control make a scan
		clearInvalidElements(cm);
		for(var i = 0; i <= text.length; i++) {
			token = cm.getTokenAt(cm.posFromIndex(i));
			context = token.state.context;
			if(context) {
				var id = self.contextId(cId, context.id).join('.');

				if(context.nodeType == NODE_ELEMENT_START || context.nodeType == NODE_ELEMENT_END) {
					var from = cm.posFromIndex(i - 1), to = cm.posFromIndex(i), state, mark;
					if(messages[id]) {
						mark = cm.markText(from, to, 'xrx-visualxml-error');
						state = getInvalidElements(cm);
						state.invalidElements.push(mark);
					}
				}
			}
		}
	},
	
	contextId: function(controlId, relativeId) {
		
		return controlId.concat(relativeId.split('.').splice(1));
	},
	
	/*
	 * Private Functions
	 */
	_create: function() {

		var self = this, textarea = self.element[0];
		if(self.options.repeatflag) {
			var ref = $(textarea).attr('data-xrx-ref');
			var index = $(textarea).attr('data-xrx-index');

			$(textarea).val(self._transformXml(self.options.xml));
			self._codemirrorInstance(textarea);
			$(self.codemirror.getInputField()).attr('data-xrx-ref', ref);
			$(self.codemirror.getInputField()).attr('data-xrx-index', index);
		}
		else {
			var bindId = $(textarea).attr('data-xrx-bind'),
				bind = $('#' + bindId),
				expression = $(bind).attr('data-xrx-nodeset'),
				instance = $('.xrx-instance').text(),
				nodeset = window.XPath.query(expression, instance),
				xml = nodeset.only.xml;

			$(textarea).val(self._transformXml(xml));
			self._codemirrorInstance(textarea);
			$(self.codemirror.getInputField()).attr('data-xrx-bind', bindId);
		}
	},

	_codemirrorInstance: function(textarea) {
		var self = this;
		
		self.codemirror = CodeMirror.fromTextArea(textarea, { 
			mode: "text/visualxml",
			lineWrapping: true,
			dragDrop: false,
			keyMap: "visualxml",
			onCursorActivity: function() { self.codemirror.matchElement(); },
			onChange: function(cm, change) { self.codemirror.contentChanged(cm, change); },
			onFocus: function() { 
				$(".xrx-visualxml").each(function() {
					$(this).xrxVisualxml("clear");
				});
				//console.log('die onfocus funktion unter self.codemirror');
				$(self.codemirror.getScrollerElement()).addClass("xrx-forms-control-hover");
				self.codemirror.matchElement();
				self.codemirror.keepValue();
			}
		});
		self.codemirror.visualxml = self;
	},
	
	// OK
	_transformXml: function(xml) {
		var self = this, visualxml = "";
		var contentHandler = new DefaultHandler();
		var saxParser = XMLReaderFactory.createXMLReader();
		saxParser.setHandler(contentHandler);
		
        contentHandler.startElement = function(namespaceURI, localName, qName, atts) {
        	visualxml += self.options.charElementStart;
        };
        
        contentHandler.endElement = function(namespaceURI, localName, qName) {
        	visualxml += self.options.charElementEnd;
        };
        
        contentHandler.characters = function(ch, start, length) {
        	visualxml += CodeMirror.splitLines(ch).join("");
        };
        
		saxParser.parseString(xml);
		return visualxml;
	}
	
});
	
})( jQuery );

