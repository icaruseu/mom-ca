;(function () {

	var NODE_ELEMENT_START = "element-start";
	var NODE_ELEMENT_END = "element-end";
	var NODE_TEXT = "text";
	
	/*
	 * XPath
	 * http://www.w3.org/TR/xpath/
	 */
	XPath = function() {};
	
	
	/*
	 * Data Model (Nodes)
	 * http://www.w3.org/TR/xpath/#data-model
	 */
	Node = function(type, levelId, xml, expandedName, qName) {
		this.type = type;
		this.levelId = levelId.slice(0);
		this.xml = xml;
		this.expandedName = expandedName;
		this.qName = qName;
	};
	
	Node.root = 1; 
	
	Node.element = 2;
	
	Node.attribute = 3;
	
	Node.namespace = 4;
	
	Node.pi = 5;
	
	Node.comment = 6;
	
	Node.text = 7;
	
	// not part of the model but useful for node tests
	Node.node = 0;
	
	/*
	 * Node Set
	 * http://www.w3.org/TR/xpath/#node-sets
	 */
	NodeSet = function() {
	    this.length = 0;
	    this.nodes = [];
	};
	
	NodeSet.prototype.isNodeSet = true;

	NodeSet.prototype.merge = function(nodeset) {

	    if (nodeset.only) {
	        return this.push(nodeset.only);
	    }

	    if (this.only){
	        var only = this.only;
	        delete this.only;
	        this.push(only);
	        this.length --;
	    }

	    var nodes = nodeset.nodes;
	    for (var i = 0, l = nodes.length; i < l; i ++) {
	        this._add(nodes[i]);
	    }
	};
	
	NodeSet.prototype._add = function(node) {

	    this.length++;
	    this.nodes.push(node);
	};
	
	NodeSet.prototype.push = function(node) {
	    if(!this.length) {
	        this.length ++;
	        this.only = node;
	        return;
	    }
	    if(this.only) {
	        var only = this.only;
	        delete this.only;
	        this.push(only);
	        this.length --;
	    }
	    return this._add(node);
	};
	
	NodeSet.prototype.iterator = function() {
	    var nodeset = this;

        var count = 0;
        return function() {
            if (nodeset.only && count++ == 0) return nodeset.only;
            return nodeset.nodes[count++];
        };
	};
	
	
	/*
	 * Namespace Context
	 */
	NamespaceContext = function(prefixes, uris) {
		this.prefixes = prefixes || [];
		this.uris = uris || [];
	};
	
	NamespaceContext.prototype.getNamespaceURI = function(prefix) {
		
		return this.prefixes ? this.uris[this.prefixes.indexOf(prefix)] : null;
	};

	
	/*
	 * SAX Handler
	 */
	SAX = function() {
		this.contentHandler = new DefaultHandler();
		this.saxParser = XMLReaderFactory.createXMLReader();
		this.saxParser.setHandler(this.contentHandler);
	};
	
	SAX.prototype.parse = function(xml) {
		var self = this, levelId = [], textId, path = [], prefixMapping = [], numText = [];
		
		var ELEMENT_START  = "#element-start ";
		var ELEMENT_END    = "#element-end   ";
		var TEXT           = "#text          ";
		var DOCUMENT_START = "#document-start";
		var DOCUMENT_END   = "#document-end  ";
		var WHITESPACE     = "#whitespace    ";
		var START_PREFIX   = "#start-prefix  ";
		var END_PREFIX     = "#end-prefix    ";

		// start document
		this.contentHandler.startDocument = function() {

			self.xpathStartDocument.apply(self.xpathStartDocument);
		};

		// start element
		this.contentHandler.startElement = function(uri, localName, qName, atts) {

			path.push(qName);
			levelId[path.length - 1] ? levelId[path.length - 1] += 1 : levelId[path.length - 1] = 1;
			self.xpathStartElement.apply(self.xpathStartElement, [uri, localName, qName, atts, levelId, prefixMapping]);
			previousEventType = ELEMENT_START;
		};

		// end element
		this.contentHandler.endElement = function(uri, localName, qName) {

			if(previousEventType == ELEMENT_END) levelId.pop();
			self.xpathEndElement.apply(self.xpathEndElement, [uri, localName, qName, levelId, prefixMapping]);
			path.pop();
			previousEventType = ELEMENT_END;
		}; 

		// characters
		this.contentHandler.characters = function(ch, start, length) {
			
    		textId = levelId.slice(0);
    		previousEventType == ELEMENT_START ? textId : textId.pop();
			!numText[textId] ? numText[textId] = 1 : numText[textId] += 1;
			self.xpathCharacters.apply(self.xpathCharacters, [ch, start, length, textId, numText[textId]]);
		};

		// whitespace
		this.contentHandler.ignorableWhitespace = function(ch, start, length) {

    		textId = levelId.slice(0);
    		previousEventType == ELEMENT_START ? textId : textId.pop();
			!numText[textId] ? numText[textId] = 1 : numText[textId] += 1;
			// we do not ignore whitespace
			self.xpathCharacters.apply(self.xpathCharacters, [ch, start, length, textId, numText[textId]]);
		};

		// start prefix mapping
		this.contentHandler.startPrefixMapping = function(prefix, uri) {
			
			// TODO: we have to treat default namespaces and namespace declarations differently
			prefix != "" ? prefixMapping.push(" xmlns:" + prefix + "=\"" + uri + "\"") : prefixMapping.push(" xmlns" + "=\"" + uri + "\"");
			self.xpathStartPrefixMapping.apply(self.xpathStartPrefixMapping, [prefix, uri]);
		};

		// end prefix mapping
		this.contentHandler.endPrefixMapping = function(prefix) {

			prefixMapping.pop();
			self.xpathStartPrefixMapping.apply(self.xpathStartPrefixMapping, [prefix]);
		};

		// end document
		this.contentHandler.endDocument = function() {

			self.xpathEndDocument.apply(self.xpathEndDocument);
		};

		this.saxParser.parseString(xml);
	};

	SAX.prototype.xpathStartDocument = function() {};

	SAX.prototype.xpathStartElement = function(uri, localName, qName, atts, levelId, prefixMapping) {};

	SAX.prototype.xpathEndElement = function(uri, localName, qName, levelId, prefixMapping) {};

	SAX.prototype.xpathCharacters = function(ch, start, length, levelId, numText) {};

	//SAX.prototype.xpathIgnorableWhitespace = function(ch, start, length) {}; we do not ignore whitespace

	SAX.prototype.xpathStartPrefixMapping = function(prefix, uri) {};

	SAX.prototype.xpathEndPrefixMapping = function(prefix) {};

	SAX.prototype.xpathEndDocument = function() {};

	
	/*
	 * XML support for browser
	 */
	XML = {
			// node name utilities
			expandedName: function(uri, name) {
				
				return "{" + uri + "}" + name;
			},
			// create nodes
			createStartElement: function(prefixMapping, qName, attributes, keepPrefixes) { 
				var attributeString = "", i, j, attsArray, ns = qName.substring(":"), nsString = "";
				
				if(attributes) attsArray = attributes.attsArray;
				for(i in attsArray) { attributeString += " " + attsArray[i].qName + "=\"" + attsArray[i].value + "\""; };
				for(j in prefixMapping) keepPrefixes ? nsString += prefixMapping[j] : nsString += prefixMapping.pop();
				
				return '<' + qName + nsString + attributeString + '>'; 
			},
			// clone end element
			createEndElement: function(qName) {
				
				return '</' + qName + '>';
			},
			// level test
			isSelfLevel: function(id1, id2) {
				var same = true; 
				
				if(id2.length != id1.length) return false;
				for(var i = 0; i < id1.length; i++) {
					if(id1[i] != id2[i]) {
						same = false;
						break;
					}
				}
				return same;
			},
			isChildLevel: function(testId, parentId) {
				
				if(testId == 1 && parentId == 0) return true;
				
				var id = testId.slice(0);
				id.pop();
				return XML.isSelfLevel(id, parentId) && testId.length == parentId.length + 1 ? true : false;
			},
			isDescendantLevel: function(testId, ancestorId) {

				if(ancestorId == 0) return true;
				
				var id = testId.slice(0, ancestorId.length);
				return XML.isSelfLevel(testId, ancestorId) ? false : XML.isSelfLevel(id, ancestorId);
			},
			isDescendantOrSelfLevel: function(testId, ancestorId) {
				
				return XML.isDescendantLevel(testId, ancestorId) || XML.isSelfLevel(testId, ancestorId);
			},
			// get nodes
			getElementById: function(doc, id) {
				var element = {}, sax = new SAX();
				
				sax.xpathStartElement = function(uri, localName, qName, atts, levelId, prefixMapping) {
					
					if(XML.isSelfLevel(id, levelId)) {
						element.uri = uri;
						element.localName = localName;
						element.qName = qName;
						element.atts = atts;
						element.levelId = [];
						element.levelId = levelId.slice(0);
					}
				}
				
				sax.parse(doc);
				
				return element;
			},
			getChildElementsById: function(doc, id) {
				var elements = [], sax = new SAX();
				
				sax.xpathStartElement = function(uri, localName, qName, atts, levelId, prefixMapping) {
					
					if(XML.isChildLevel(levelId, id)) {
						var element = {};
						element.uri = uri;
						element.localName = localName;
						element.qName = qName;
						element.atts = atts;
						element.levelId = [];
						element.levelId = levelId.slice(0);
						elements.push(element);
					}
				}
				
				sax.xpathEndElement = function(uri, localName, qName, levelId, prefixMapping) {}
				
				sax.xpathCharacters = function(ch, start, length, levelId) {}
				
				sax.parse(doc);

				return elements;
			},
			getChildElements: function(doc, ctx, test) {
				var nodeset = new NodeSet(), xml = "", sax = new SAX(), self = this, cloneUntilElementEndId = [], cloneFlag = false;
				var parentId = ctx.node.levelId;

				sax.xpathStartElement = function(uri, localName, qName, atts, levelId, prefixMapping) {

					if(XML.isChildLevel(levelId, parentId)) {
						var node = new Node(Node.element, levelId, null, XML.expandedName(uri, localName), qName);
						
						if(test.match(node)) {
							cloneUntilElementEndId = levelId.slice(0);
							cloneFlag = true;
						}
					}
					if(cloneFlag) xml += XML.createStartElement(prefixMapping, qName, atts);
				}
				
				sax.xpathEndElement = function(uri, localName, qName, levelId, prefixMapping) {
					var element;
					
					if(cloneFlag) xml += XML.createEndElement(qName);
					if(XML.isSelfLevel(cloneUntilElementEndId, levelId)) {
						cloneUntilElementEndId = [];
						cloneFlag = false;
						element = new Node(Node.element, levelId, xml, XML.expandedName(uri, localName), qName);
						nodeset.push(element);
						xml = "";
					}
				}
				
				sax.xpathCharacters = function(ch, start, length, levelId) {
					
					if(cloneFlag) xml += ch;
				}
				
				sax.parse(doc);
				return nodeset;
			},
			getDescendantElements: function(doc, ctx, test) {
				var nodeset = new NodeSet(), xml = [], first = [], sax = new SAX(), self = this, found = [];
				var ancestorId = ctx.node.levelId;

				sax.xpathStartElement = function(uri, localName, qName, atts, levelId, prefixMapping) {

					if(XML.isDescendantLevel(levelId, ancestorId)) {
						var node = new Node(Node.element, levelId, null, XML.expandedName(uri, localName), qName);
						if(test.match(node)) {
							found.push(levelId.slice(0));
							xml[levelId] = "";
						}
					}
					for(var i=0; i < found.length; i++) {
						lId = found[i];
						if(XML.isSelfLevel(levelId, lId) || XML.isDescendantLevel(levelId, lId)) {
							if(!first[lId]) {
								first[lId] = {};
								first[lId].qName = qName;
								first[lId].atts = atts;
							} else { 
								xml[lId] += XML.createStartElement([], qName, atts);
							}
						}
					}
				}
				
				sax.xpathEndElement = function(uri, localName, qName, levelId, prefixMapping) {
					var element;
					
					for(var i=0; i < found.length; i++) {
						lId = found[i];
						if(XML.isDescendantLevel(levelId, lId)) xml[lId] += XML.createEndElement(qName);
						if(XML.isSelfLevel(levelId, lId)) {
							var start = XML.createStartElement(prefixMapping, first[lId].qName, first[lId].atts); 
							xml[lId] += XML.createEndElement(qName);
							element = new Node(Node.element, levelId, start + xml[lId], XML.expandedName(uri, localName), qName);
							nodeset.push(element);
						}
					}								
				}
				
				sax.xpathCharacters = function(ch, start, length, levelId) {
					
					for(var i=0; i < found.length; i++) {
						lId = found[i];
						if(XML.isSelfLevel(levelId, lId) || XML.isDescendantLevel(levelId, lId)) xml[lId] += ch;
					}
				}
				
				sax.parse(doc);
				
				return nodeset;
			},
			// extension
			replaceElementNode: function(doc, contextId, xml) {
				var result = "", sax = new SAX(), deleteFlag = false;

				sax.xpathStartElement = function(uri, localName, qName, atts, levelId, prefixMapping) {
					
					if(XML.isSelfLevel(contextId, levelId)) {
						deleteFlag = true;
						result += xml;
					}
					if(!deleteFlag) result += XML.createStartElement(prefixMapping, qName, atts, false);
				}
				
				sax.xpathEndElement = function(namespaceURI, localName, qName, levelId) {
					
					if(!deleteFlag) result += XML.createEndElement(qName);
					if(XML.isSelfLevel(contextId, levelId)) {
						deleteFlag = false;
					}
				}
				
				sax.xpathCharacters = function(ch, start, length) {
					
					if(!deleteFlag) result += ch;
				}				

				sax.parse(doc);
				
				return result;
			},
			// update nodes
			// http://www.w3.org/TR/xquery-update-10/#id-upd-insert-attributes
			insertAttributes: function(doc, contextId, attributes) {
				var result = "", sax = new SAX();
				
				sax.xpathStartElement = function(uri, localName, qName, atts, levelId, prefixMapping) {
					
					if(XML.isSelfLevel(contextId, levelId)) {
		    			for(var i = 0 in attributes.attsArray) atts.attsArray.push(attributes.attsArray[i]);
		    			result += XML.createStartElement(prefixMapping, qName, atts, false);						
					}
					else {
						result += XML.createStartElement(prefixMapping, qName, atts, false);
					}
				}
				
				sax.xpathEndElement = function(namespaceURI, localName, qName) {
					result += XML.createEndElement(qName);
				}
				
				sax.xpathCharacters = function(ch, start, length) {
					result += ch;
				}
				
				sax.parse(doc);
				
				return result;
			},
			// extension
			deleteAttributes: function(doc, contextId, attributes) {
				var result = "", sax = new SAX();
				
				sax.xpathStartElement = function(uri, localName, qName, atts, levelId, prefixMapping) {

					if(XML.isSelfLevel(contextId, levelId)) {
		    			for(var i1 in atts.attsArray) {
		    				for(var i2 in attributes.attsArray)
		    					if(attributes.attsArray[i2].qName == atts.attsArray[i1].qName) atts.attsArray.splice(i1, 1);
		    			}
		    			result += XML.createStartElement(prefixMapping, qName, atts, false);
					}
					else {
						result += XML.createStartElement(prefixMapping, qName, atts, false);
					}
				}
				
				sax.xpathEndElement = function(namespaceURI, localName, qName) {
					result += XML.createEndElement(qName);
				}
				
				sax.xpathCharacters = function(ch, start, length) {
					result += ch;
				}
				
				sax.parse(doc);
				
				return result;
			},
			// extension
			replaceAttributeValue: function(doc, contextId, attributes) {
				var result = "", sax = new SAX();
				
				sax.xpathStartElement = function(uri, localName, qName, atts, levelId, prefixMapping) {
					
					if(XML.isSelfLevel(contextId, levelId)) {
		    			for(var i in atts.attsArray) {
		    				if(attributes.attsArray[0].qName == atts.attsArray[i].qName) atts.attsArray[i].value = attributes.attsArray[0].value;
		    			}
		    			result += XML.createStartElement(prefixMapping, qName, atts, false);
					}
					else {
						result += XML.createStartElement(prefixMapping, qName, atts, false);
					}					
				}
				
				sax.xpathEndElement = function(namespaceURI, localName, qName) {
					result += XML.createEndElement(qName);
				}
				
				sax.xpathCharacters = function(ch, start, length) {
					result += ch;
				}
				
				sax.parse(doc);
				
				return result;
			},
			// http://www.w3.org/TR/xquery-update-10/#id-upd-insert-after
			insertAfter: function(doc, contextId, xml) {
				var result = "", sax = new SAX();
				
				sax.xpathStartElement = function(uri, localName, qName, atts, levelId, prefixMapping) {
					result += XML.createStartElement(prefixMapping, qName, atts, false);		
				}
				
				sax.xpathEndElement = function(uri, localName, qName, levelId, prefixMapping) {
					
		    		if(XML.isSelfLevel(contextId, levelId)) {
		    			result += XML.createEndElement(qName);
		    			result += xml;
		    		} else result += XML.createEndElement(qName);
				}
				
				sax.xpathCharacters = function(ch, start, length) {
					result += ch;
				}
				
				sax.parse(doc);
				
				return result;
			},
			// http://www.w3.org/TR/xquery-update-10/#id-upd-insert-before
			insertBefore: function(doc, contextId, xml) {
				var result = "", sax = new SAX();
				
				sax.xpathStartElement = function(uri, localName, qName, atts, levelId, prefixMapping) {
					
		    		if(XML.isSelfLevel(contextId, levelId)) {
		    			result += xml;
		    			result += XML.createStartElement(prefixMapping, qName, atts, false);
		    		} else result += XML.createStartElement(prefixMapping, qName, atts, false);
				}
				
				sax.xpathEndElement = function(uri, localName, qName, levelId, prefixMapping) {
					
		    		result += XML.createEndElement(qName);
				}
				
				sax.xpathCharacters = function(ch, start, length) {
					
					result += ch;
				}
				
				sax.parse(doc);
				
				return result;				
			},
			// http://www.w3.org/TR/xquery-update-10/#id-upd-insert-into
			insertInto: function(doc, contextId, xml) {
				var result = "", sax = new SAX();
				
				sax.xpathStartElement = function(uri, localName, qName, atts, levelId, prefixMapping) {
					
		    		if(XML.isSelfLevel(contextId, levelId)) {
		    			result += XML.createStartElement(prefixMapping, qName, atts, false);
		    			result += xml;
		    		} else result += XML.createStartElement(prefixMapping, qName, atts, false);
				}
				
				sax.xpathEndElement = function(uri, localName, qName, levelId, prefixMapping) {
		    		result += XML.createEndElement(qName);
				}
				
				sax.xpathCharacters = function(ch, start, length) {
					result += ch;
				}
				
				sax.parse(doc);
				
				return result;					
			},
			// extension
			deleteElementTag: function(doc, contextId) {
				var result = "", sax = new SAX();
				
				sax.xpathStartElement = function(uri, localName, qName, atts, levelId, prefixMapping) {
					
		    		if(XML.isSelfLevel(contextId, levelId)) {
		    			null; // delete
		    		} else result += XML.createStartElement(prefixMapping, qName, atts, false);
				}
				
				sax.xpathEndElement = function(uri, localName, qName, levelId, prefixMapping) {
		    		
					if(XML.isSelfLevel(contextId, levelId)) {
						null; // delete
					} else result += XML.createEndElement(qName);
				}
				
				sax.xpathCharacters = function(ch, start, length, levelId, numText) {
					result += ch;
				}
				
				sax.parse(doc);
				
				return result;				
			},
			// extension
			insertElementTag: function(doc, first, last) {
				var result = "", sax = new SAX();
				var onlyText = XML.isSelfLevel(first.contextId, last.contextId) && 
					first.nodeType == NODE_TEXT &&
					last.nodeType == NODE_TEXT &&
					first.numText == last.numText;
				
				console.log(onlyText);
				
				sax.xpathStartElement = function(uri, localName, qName, atts, levelId, prefixMapping) {
					
					
		    		if(XML.isSelfLevel(first.contextId, levelId) && first.nodeType == NODE_ELEMENT_START) {
		    			
		    			result += XML.createStartElement(prefixMapping, qName, atts, false);
		    			result += first.xml;
		    			
		    		} else if(XML.isSelfLevel(last.contextId, levelId) && last.nodeType == NODE_ELEMENT_START) {

		    			result += last.xml;
		    			result += XML.createStartElement(prefixMapping, qName, atts, false);
		    			
		    		} else result += XML.createStartElement(prefixMapping, qName, atts, false);
		    		
				}
				
				sax.xpathEndElement = function(uri, localName, qName, levelId, prefixMapping) {
		    						
		    		if(XML.isSelfLevel(first.contextId, levelId) && first.nodeType == NODE_ELEMENT_END) {
		    			
		    			result += XML.createEndElement(qName);
		    			result += first.xml;
		    			
		    		} else if(XML.isSelfLevel(last.contextId, levelId) && last.nodeType == NODE_ELEMENT_END) {

		    			result += last.xml;
		    			result += XML.createEndElement(qName);
		    			
		    		} else result += XML.createEndElement(qName);
		    		
				}
				
				sax.xpathCharacters = function(ch, start, length, levelId, numText) {
					
					if(XML.isSelfLevel(first.contextId, levelId) && first.nodeType == NODE_TEXT && first.numText == numText && onlyText) {
						
						result += first.string.slice(0).substring(0, first.offset) + 
							first.xml + 
							first.string.slice(0).substr(first.offset, last.offset - first.offset) + 
							last.xml +
							first.string.slice(0).substr(last.offset);
						
					} else if(XML.isSelfLevel(first.contextId, levelId) && first.nodeType == NODE_TEXT && first.numText == numText && !onlyText) {
		    			
						result += first.string.slice(0).substr(0, first.offset) + first.xml + first.string.slice(0).substr(first.offset);
						
		    		} else if(XML.isSelfLevel(last.contextId, levelId) && last.nodeType == NODE_TEXT && last.numText == numText && !onlyText) {

		    			result += last.string.slice(0).substr(0, last.offset) + last.xml + last.string.slice(0).substr(last.offset);
		    			
		    		} else result += ch;

				}
				
				sax.parse(doc);
				
				return result;
			},
			// extension
			replaceMixedSelection: function(doc, first, last, xml) {
				var result = "", sax = new SAX();
				var onlyText = false, copyFlag = true;
				
				sax.xpathStartElement = function(uri, localName, qName, atts, levelId, prefixMapping) {

					if(XML.isSelfLevel(first.contextId, levelId) && first.nodeType == NODE_ELEMENT_START) {
						
						result += XML.createStartElement(prefixMapping, qName, atts, false);
						result += xml;
						copyFlag = false;
					}
					else if(XML.isSelfLevel(last.contextId, levelId) && last.nodeType == NODE_ELEMENT_START) {
						
						copyFlag = true;
					}
					copyFlag ? result += XML.createStartElement(prefixMapping, qName, atts, false) : false;

				}
				
				sax.xpathEndElement = function(uri, localName, qName, levelId, prefixMapping) {

					if(XML.isSelfLevel(levelId, first.contextId) && first.nodeType == NODE_ELEMENT_END) {
						
						result += XML.createEndElement(qName);
						result += xml;
						copyFlag = false;
						
					} else if(XML.isSelfLevel(last.contextId, levelId) && last.nodeType == NODE_ELEMENT_END) {
						
						copyFlag = true;
					}
					copyFlag ? result += XML.createEndElement(qName) : null;

				}
				
				sax.xpathCharacters = function(ch, start, length, levelId, numText) {
					
					if(XML.isSelfLevel(first.contextId, levelId) && first.nodeType == NODE_TEXT && first.numText == numText && onlyText) {
						
						
					} else if(XML.isSelfLevel(first.contextId, levelId) && first.nodeType == NODE_TEXT && first.numText == numText && !onlyText) {
		    			
						result += first.string.slice(0).substr(0, first.offset) + xml;
						
						// For textchanges
                            if(first.numText = last.numText) {
                              result += last.string.slice(0).substr(last.offset, last.string.length - last.offset +1);
                              copyFlag = true;
                            } else {copyFlag = false;}
                        //
						
						
		    		} else if(XML.isSelfLevel(last.contextId, levelId) && last.nodeType == NODE_TEXT && last.numText == numText && !onlyText) {

		    			result += last.string.slice(0).substr(last.offset);
		    			copyFlag = true;
		    			
		    		} else {
		    			
		    			copyFlag ? result += ch : null;	
		    		}
				}
				
				sax.parse(doc);
				
				return result;
			},
			// extension
			replaceTextNode: function(doc, contextId, contextNum, xml) {
				var result = "", sax = new SAX();
				
				sax.xpathStartElement = function(uri, localName, qName, atts, levelId, prefixMapping) {
					
		    		result += XML.createStartElement(prefixMapping, qName, atts, false);
				}
				
				sax.xpathEndElement = function(uri, localName, qName, levelId, prefixMapping) {
		    		
					result += XML.createEndElement(qName);
				}
				
				sax.xpathCharacters = function(ch, start, length, levelId, numText) {
					
					if(XML.isSelfLevel(contextId, levelId) && contextNum == numText) result += xml;
					else result += ch;
				}
				
				sax.parse(doc);
				
				return result;			
			},
			// extension
			deleteTextNode: function(doc, endElementId) {
				var result = "", sax = new SAX(), flag = false;
				
				sax.xpathStartElement = function(uri, localName, qName, atts, levelId, prefixMapping) {
					
		    		result += XML.createStartElement(prefixMapping, qName, atts, false);
				}
				
				sax.xpathEndElement = function(uri, localName, qName, levelId, prefixMapping) {
		    		
					if(XML.isSelfLevel(endElementId, levelId)) flag = true;
					result += XML.createEndElement(qName);
				}
				
				sax.xpathCharacters = function(ch, start, length, levelId, numText) {
					
					if(!flag) result += ch;
					else flag = false;
				}
				
				sax.parse(doc);
				
				return result;					
			}
	}
	

	/*
	 * [14] Expr
	 */
	var Expr = function() {};


	/*
	 * [1] LocationPath
	 */	
	LocationPath = function(filter) {
		this.filter = filter;
		this.steps = [];	
	};

	LocationPath.prototype = new Expr();

	LocationPath.tokenizer = { '//': 1, '/': 1 };

	LocationPath.parse = function(lexer) {
		var op, expr, path, token;

		path = new LocationPath();

		while (true) {
			if (!this.tokenizer[lexer.peek()]) break;
			op = lexer.next();
			if (lexer.empty()) {
				throw Error('missing next location step');
			}
			path.step(op, Step.parse(lexer));
		}

		return path;
	};

	LocationPath.prototype.evaluate = function(doc, ctx) {
		var steps = this.steps;
		var nodeset = new NodeSet();
		
		nodeset.push(ctx.node);
		for (var i = 0, l0 = steps.length; i < l0; i ++) {
			var step = steps[i][1];
	        var iter = nodeset.iterator();
	        var newNodeset = new NodeSet();
			while(node = iter()) {
				var c = new Context(node);
				newNodeset.merge(step.evaluate(doc, c));
			}
			nodeset = null;
			nodeset = newNodeset;
		}
		return nodeset;
	};

	LocationPath.prototype.step = function(op, step) {

		step.op = op;
		this.steps.push([op, step]);
	};


	/*
	 * [4] Step
	 */
	Step = function(axis, test) {
		this.axis = axis;
		this.func = Step.axes[axis][0];
		this.test = test;
	};

	Step.prototype = new Expr();

	Step.parse = function(lexer) {
		var axis, test, step, token;

		if(lexer.peek(1) == "::") {
			
            axis = lexer.next();
            lexer.next();
            
            if (!this.axes[axis]) {
                throw Error('invalid axis or axis not supported: ' + axis);
            }            
            if (lexer.empty()) {
                throw Error('missing node name');
            }
		}
		else if(lexer.peek(0) == "/") {
			throw Error('abbreviated syntax not yet supported: ' +  '//' + ' (use: "descendant::...")');
		} 
		else {
			throw Error('abbreviated syntax not yet supported (use: "child::...")');
		}
		test = NodeTest.parse(lexer);
		step = new Step(axis, test);

		return step;
	};

	Step.prototype.evaluate = function(doc, ctx) {
		
		return this.func(doc, ctx, this.test);
	};
	
	Step.axes = {
			child: [XML.getChildElements],
			descendant: [XML.getDescendantElements]
	};

	
	/*
	 * [37] Name Test
	 */
	NameTest = function(uri, name) {
		this.uri = uri;
		this.name = name;
		this.expandedName = window.XML.expandedName(this.uri, this.name);
	};
	
	NameTest.prototype = new Expr();
	
	NameTest.parse = function(lexer) {
		var qName = lexer.next();
		var index = qName.indexOf(":");
		
		if(index >= 0) {
			var prefix = qName.substr(0, index);
			var uri = window.namespaceContext.getNamespaceURI(prefix);
			
			if(!uri) throw Error("Namespace Prefix '" + prefix + "' is not bound.");
			return new NameTest(uri, qName.substr(index + 1));
		}
		else return new NameTest(null, qName);
	};
	
	NameTest.match = function(node, nameTest) {
		
		return node.expandedName == nameTest.expandedName;
	};
	
	
	/*
	 * [38] Node Type
	 */
	NodeType = function() {};
	
	NodeType.prototype = new Expr();
	
	NodeType.comment = Node.node;
	
	NodeType.text = Node.text;
	
	NodeType.pi = Node.pi;
	
	NodeType.node = Node.node;
	
	NodeType.parse = function(lexer) {
		
		return Node.element;
	};

	NodeType.match = function(node, nodeTest) {
		
		return node.type == nodeTest.nodeType;
	};
	
	
	/*
	 * [7] Node Test
	 */
	NodeTest = function(nodeType, nameTest) {
		this.nodeType = nodeType;
		this.nameTest = nameTest;
	};

	NodeTest.prototype = new Expr();

	NodeTest.parse = function(lexer) {

		return new NodeTest(NodeType.parse(lexer), NameTest.parse(lexer));
	};

	NodeTest.prototype.match = function(node) {
		
		return NodeType.match(node, this) && NameTest.match(node, this.nameTest);
	};
	

	/*
	 * Lexical Structure
	 */
	var Lexer = function(source) {
		var proto = Lexer.prototype;
		var tokens = source.match(proto.regs.token);

		for (var i = 0, l = tokens.length; i < l; i ++) {
			if (proto.regs.strip.test(tokens[i])) {
				tokens.splice(i, 1);
			}
		}

		for (var n in proto) tokens[n] = proto[n];

		tokens.index = 0;
		return tokens;
	};

	Lexer.prototype.regs = {
			token: /\$?(?:(?![0-9-])[\w-]+:)?(?![0-9-])[\w-]+|\/\/|\.\.|::|\d+(?:\.\d*)?|\.\d+|"[^"]*"|'[^']*'|[!<>]=|(?![0-9-])[\w-]+:\*|\s+|./g,
			strip: /^\s/,
	};

	Lexer.prototype.peek = function(i) {

		return this[this.index + (i||0)];
	};

	Lexer.prototype.next = function() {

		return this[this.index++];
	};

	Lexer.prototype.back = function() {

		this.index--;
	};

	Lexer.prototype.empty = function() {

		return this.length <= this.index;
	};

	Lexer.prototype.reset = function() {
		
		this.index = null;
	};
	
	
	/*
	 * Context
	 */
	Context = function(node) {
		this.node = node;
	};	


	XPath.prototype.optimize = function(lexer) {
		var token, unabbreviated = [], forwardsteps = [], optimized = Lexer.prototype;
		
		// translate abbreviated into unabbreviated syntax (http://www.w3.org/TR/xpath20/#abbrev)
		do {
			token = lexer.peek();
			
			switch(token) {
			case "//":
				var step = lexer.peek(2);
				unabbreviated.push("/");
				unabbreviated.push("descendant-or-self::node()");
				unabbreviated.push("/");
				if(step != "::") {
					unabbreviated.push("child");
					unabbreviated.push("::");
				}
				break;
			case "/":
				var step = lexer.peek(2);
				if(step != "::") {
					unabbreviated.push(token);
					unabbreviated.push("child");
					unabbreviated.push("::");
				}
				else unabbreviated.push(token);
				break;
			default:
				unabbreviated.push(token);
				break;
			}
			lexer.next()
		} while(!lexer.empty())
		
		// optimize forward steps (https://mail.gnome.org/archives/xml/2012-August/msg00146.html)
		for(var n = 0; n < unabbreviated.length; n++) {
			token = unabbreviated[n];
			
			switch(token) {
			case "descendant-or-self::node()":
				var step = unabbreviated[n + 2];
				if(step == "child") {
					forwardsteps.push("descendant");
					forwardsteps.push("::");
					n += 3;
				}
				else {
					forwardsteps.push("descendant-or-self");
					forwardsteps.push("::");
					forwardsteps.push("node()");
				};
				break;
			default:
				forwardsteps.push(unabbreviated[n]);
				break;
			}
		}	
			
		for (var n in forwardsteps) optimized[n] = forwardsteps[n];
		optimized.index = 0;
		
		return optimized;
	};
	
	
	/*
	 * Public Interface
	 */
	XPath.prototype.setNamespaceContext = function(prefixes, uris) {
		window.namespaceContext = new NamespaceContext(prefixes, uris);
	};
	
	XPath.prototype.query = function(query, doc) {
		var lexer, expression, result, node, optimized;
		
		window.XML ? null : window.XML = new XML();
		
		//var start = +new Date();
		
		lexer = Lexer(query);
		//optimized = this.optimize(lexer);
		expression = LocationPath.parse(lexer);
		node = new Node(Node.root, [0], doc);
		ctx = new Context(node);
		result = expression.evaluate(doc, ctx);
		
		//var end = +new Date();
		//console.log("Lexer: ")
		//console.log(lexer);
		//console.log("Optimized: ");
		//console.log(optimized);
		//console.log("Expression:");
		//console.log(expression);
		//console.log("Result:");
		//console.log(result);
		//console.log("Time (ms): ");
		//console.log(end - start);
		
		return result;
	};
	
	this.XPath = XPath;
	this.XML = XML;
	
})();