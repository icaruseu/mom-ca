/*
This is a component file of the VdU Software for a Virtual Research Environment for the handling of Medieval charters.

As the source code is available here, it is somewhere between an alpha- and a beta-release, may be changed without any consideration of backward compatibility of other parts of the system, therefore, without any notice.

This file is part of the VdU Virtual Research Environment Toolkit (VdU/VRET).

The VdU/VRET is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

VdU/VRET is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with VdU/VRET.  If not, see <http://www.gnu.org/licenses/>.

We expect VdU/VRET to be distributed in the future with a license more lenient towards the inclusion of components into other systems, once it leaves the active development stage.
*/
/*!
 * extending CodeMirror with functions for visual 
 * XML presentation and modification
 */
;(function() {
	var TOKEN_ELEMENT_START = "»";
	var TOKEN_ELEMENT_END = "«";
	var NODE_ELEMENT_START = "element-start";
	var NODE_ELEMENT_END = "element-end";
	var NODE_TEXT = "text";
	
	var regexElementToken = new RegExp("("+TOKEN_ELEMENT_START+"|"+TOKEN_ELEMENT_END+")");
	
	var cursorDelay;
	var selectionDelay;
	
	var previousValue;
	var contentChangedFlag = false;
	var internalUpdateFlag = false;
	var invalidContentFlag = false;
	
	/*
	 * Mixed Content Textarea
	 */
	function MarkedElements() { this.markedElements = []; }
	
	function getMarkedElements(cm) { return cm._markedElements || (cm._markedElements = new MarkedElements()); }
	
	function clearMarkedElements(cm) {
		
		var state = getMarkedElements(cm);
		
		for (var i = 0; i < state.markedElements.length; ++i)
			state.markedElements[i].clear();
		state.markedElements = [];
	}

	function correspondingElementToken(cursor, tokenType) {
		// TODO: read per line 
		var text = cursor.cm.getValue(), tokens = [], index = cursor.cm.indexFromPos(cursor.cm.getCursor()) - 1, ch, stack = 0;
		//console.log(index);
		if(tokenType == TOKEN_ELEMENT_START) {
			for(var i = index; i < text.length; i++) {
				ch = text[i];
				//console.log(ch);
				if(ch == TOKEN_ELEMENT_END) stack -= 1;
				if(ch == TOKEN_ELEMENT_START) stack += 1;
				if(stack == 0) {
					index = i + 1;
					break;
				} 
			}
		}
		else if(tokenType == TOKEN_ELEMENT_END) {
			for(var i = index; i >= 0; i--) {
				ch = text[i];
				//console.log(ch);
				if(ch == TOKEN_ELEMENT_END) stack += 1;
				if(ch == TOKEN_ELEMENT_START) stack -= 1;
				if(stack == 0) {
					index = i + 1;
					break;
				} 
			}
		}
		else {};
		//console.log("Corresponding Element: ");
		//console.log(cm.getTokenAt(cm.posFromIndex(index)));
		return cursor.cm.posFromIndex(index);
	}
	
	function mark(from, to, style, cursor) {
		var mark = cursor.cm.markText(from, to, style),
			state = getMarkedElements(cursor.cm);
		state.markedElements.push(mark);
	}
	
	function markElementToken(cursor) {
		var from, to, corresponding,
			firstMark = cursor.firstTokenOutside.string == TOKEN_ELEMENT_START ? "visualxml-mark-start-element" : "visualxml-mark-end-element";
			secondMark = cursor.firstTokenOutside.string == TOKEN_ELEMENT_START ? "visualxml-mark-end-element" : "visualxml-mark-start-element";
		
		// mark matched element
		from = { line: cursor.firstPosition.line, ch: cursor.firstPosition.ch - 1 };
		to = { line: cursor.firstPosition.line, ch: cursor.firstPosition.ch };
		mark(from, to, firstMark, cursor);
		
		// mark corresponding element
		corresponding = correspondingElementToken(cursor, cursor.firstTokenOutside.string);
		from = { line: corresponding.line, ch: corresponding.ch - 1 };
		to = { line: corresponding.line, ch: corresponding.ch };
		mark(from, to, secondMark, cursor);
		
		// mark text
		from = { line: cursor.firstPosition.line, ch: cursor.firstPosition.ch };
		to = { line: corresponding.line, ch: corresponding.ch - 1 };
		cursor.firstTokenOutside.string == TOKEN_ELEMENT_START ? mark(from, to, "visualxml-mark-text", cursor) : mark(to, from, "visualxml-mark-text", cursor);
	}
	
	function saxGetElementById(cm, levelId) {
		var nodeset = $(document).xrx.nodeset(cm.getInputField());
		var element = window.XML.getElementById(nodeset.only.xml, levelId.split('.'));
		var attributes = [];
		
		if(element.atts) {
			for(var att = 0; att < element.atts.attsArray.length; att++) {
				var attName = element.atts.attsArray[att].qName;
				var attValue = element.atts.attsArray[att].value;
				var newAttribute = { qName:attName, value:attValue };
				attributes.push(newAttribute);
			}
		}
		
		return { qName: element.qName, attributes: attributes };		
	}
	
	function textOffset(cursor, index) {
		var value = cursor.cm.getValue(), offset = 0;
		while(index--) {
			if(!regexElementToken.test(value.charAt(index))) {
				offset++;
			} else {
				break;
			}
		}
		return offset;
	}
	
	/*
	 * Mixed Content Attributes
	 */
	function showMixedcontentAttributes(cm, element, token) {
		
		if(cm.visualxml.element.attr("data-xrx-attributes") == "no") return;
	
		var jsonAttributeSuggestions = jQuery.parseJSON($('.xrx-forms-json-attribute-suggestions').text());
		var suggestedAttributes = jsonAttributeSuggestions[element.qName];		
		//console.log('die funktion showmixedcontentAttributes braucht cm, element, token');
		//console.log(cm);
		//console.log(element);
		//console.log(token);
		
		$(".xrx-attributes").xrxAttributes({
			elementName:element.qName,
			suggestedAttributes:suggestedAttributes,
			editedAttributes:element.attributes,
			//suggestedValues:element.attributes,
			cm:cm,
			token:token
		});
		//console.log("Das sind die element Attribute");
		//console.log(element.qName);
	
	}
	
	function hideMixedcontentAttributes(cm) {
		
		if(cm.visualxml.element.attr("data-xrx-attributes") == "no") {
			return;
		} else {
			$(".xrx-attributes").replaceWith('<div class="xrx-attributes"/>');
		}
	}
	
	/*
	 * Mixed Content Elements
	 */
	function getSelectedChildElements(cursor) {
		// if selection invalid return
		if(cursor.lastTokenInside == null) return;
		var cm = cursor.cm, elements = [];
		var nodeset = $(document).xrx.nodeset(cm.getInputField());
		var controlId = nodeset.only.levelId;
		var contextId = cm.visualxml.contextId(controlId, cursor.firstTokenOutside.state.context.id);
		
		// get all child elements of the first cursor position (left side of selection)
		// but it's not yet clear if all child elements are selected
		var childElements = window.XML.getChildElementsById($('.xrx-instance').text(), contextId);

		// now we get all selected elements which might be child and descendant elements
		var firstContext = cursor.firstTokenInside.state.context;
		var isLeftSelection = function(ctx) {
			
			return (firstContext.nodeType == ctx.nodeType && firstContext.id == ctx.id && ( firstContext.numText == ctx.numText || (firstContext.nodeType != NODE_TEXT && ctx.nodeType != NODE_TEXT) )) ? true : false;
		};
		var ctx = cursor.lastTokenInside.state.context, selectedElements = [];
		for(;;) {
			if(ctx == null) break;
			var absoluteId = cm.visualxml.contextId(controlId, ctx.id);
			if(ctx.nodeType == NODE_ELEMENT_START) selectedElements.push(absoluteId.join('.'));
			if(isLeftSelection(ctx)) break;
			ctx = ctx.prev;
		}
		
		// filter out child elements which are not selected
		var selectedChildElements = [], i;
		for(i = 0; i < childElements.length; i++) {
			var childId = childElements[i].levelId.slice(0);
			if($.inArray(childId.join('.'), selectedElements) != -1) selectedChildElements.push(childElements[i].qName);
		}
		return selectedChildElements;
	}
	
	function validChildElements(elementSuggestions, grandChildElements, element) {
		var i, j, elementValid = true;
		//console.log(elementSuggestions);
		//console.log("Element: " + element.qName);
		//console.log("Grandchild Elements: ");
		//console.log(grandChildElements);
		var possibleElements = elementSuggestions[element.qName];
		//console.log("Possible Elements: ");
		//console.log(possibleElements);
		var relevantElements = [], possibleElement, validChildElements, i, j;
		for(i = 0; i < possibleElements.length; i++) {
			elementValid = true;
			possibleElement = possibleElements[i];
			validChildElements = elementSuggestions[possibleElement];
			//console.log("Possible Element: " + possibleElement + " Valid Grandchild Elements: "); 
			//console.log(validChildElements);
			for(j = 0; j < grandChildElements.length; j++) {
				var grandChildElement = grandChildElements[j];
				if($.inArray(grandChildElement, validChildElements) == -1) {
					elementValid = false;
					//console.log("Element not valid because of resulting child element: ");
					//console.log(grandChildElement);
				}
			}
			if(elementValid == true) relevantElements.push(possibleElement);
		}
		return relevantElements;
	}
	
	function showElementMenu(cursor) {
		
		if(cursor.cm.visualxml.element.attr("data-xrx-elements") == "no") return;
		
		var elementSuggestions = jQuery.parseJSON($(".xrx-forms-json-element-suggestions").text());
		var id, element, grandChildElements, childElements, replaceString;
		
		// Which is the relevant element to calculate element suggestions?
		// [F1] firstTokenOutside.id (start)
		// [F2] firstTokenOutside.id (start)
		// [F3] firstTokenOutside.id (start)
		// [F4] firstTokenOutside.id (text)
		// [F5] firstTokenOutside.id (text)
		// [F6] firstTokenOutside.id (text)
		// [F7] firstTokenOutside.parent.id (text)
		// [F8] firstTokenInside.id (text)
		// [F9] firstTokenInside.id (end)
		
		// [L1-L6]
		if(cursor.firstPlace.match(/(F1|F2|F3|F4|F5|F6)/)) id = cursor.firstTokenOutside.state.context.id;
		// [L7]
		else if(cursor.firstPlace == 'F7') id = parentId(cursor.firstTokenOutside.state.context.id);
		// [L8]
		else if(cursor.firstPlace == 'F8') id = cursor.firstTokenInside.state.context.id;
		// [L9]
		else if(cursor.firstPlace == 'F9') id = cursor.firstTokenInside.state.context.id;

		element = saxGetElementById(cursor.cm, id);
		console.log('ID vom Cursor');
		console.log(element);
		console.log(id);
		grandChildElements = cursor.cm.somethingSelected() ? getSelectedChildElements(cursor) : null;
		//console.log(grandChildElements);
		childElements = cursor.cm.somethingSelected() ? validChildElements(elementSuggestions, grandChildElements, element) : elementSuggestions[element.qName];
		replaceString = TOKEN_ELEMENT_START + cursor.cm.getSelection() + TOKEN_ELEMENT_END;

		// group child elements by topic
		var topicForElement = jQuery.parseJSON($(".xrx-forms-json-topics").text());
		var topic, itemsByTopic = [], topicMenues = [];
		for(i in childElements) {
			topic = topicForElement[childElements[i]];
			$.inArray(topic, itemsByTopic) == - 1 ? itemsByTopic.push(topic) : null;
		}
		itemsByTopic = itemsByTopic.sort(); // the relevant topics
		for(j in itemsByTopic) {
			var topicMenu, items = [];
			for(k in childElements) {
				if(topicForElement[childElements[k]] == itemsByTopic[j]) items.push(childElements[k]);
			}
			topicMenu = { topic:itemsByTopic[j], items:items.sort() }
			topicMenues.push(topicMenu);
		}
		$(".xrx-elements").xrxElements({
			menues: topicMenues,
			cm: cursor.cm,
			replaceString:replaceString
		});
		$(".xrx-elements li").click( function(event) {
			var qName = $(this).attr("title");
			var nodeset = $(document).xrx.nodeset(cursor.cm.getInputField());
			var controlId = nodeset.only.levelId;
			
			// update the XML instance
			if(!cursor.cm.somethingSelected()) {
				var xml = window.XML.createStartElement([], qName) + window.XML.createEndElement(qName);
				
				if(cursor.firstTokenOutside.string == TOKEN_ELEMENT_END) {
					var relativeId = cursor.firstTokenOutside.state.context.id;
					var contextId = cursor.cm.visualxml.contextId(controlId, relativeId);
					$('.xrx-instance').xrxInstance().insertAfter(contextId, xml);
				} else if(cursor.firstTokenOutside.string == TOKEN_ELEMENT_START) {
					var relativeId = cursor.firstTokenOutside.state.context.id;
					var contextId = cursor.cm.visualxml.contextId(controlId, relativeId);
					$('.xrx-instance').xrxInstance().insertInto(contextId, xml);
				} else {
					var relativeId = cursor.firstTokenOutside.state.context.id;
					var numText = cursor.firstTokenOutside.state.context.numText;
					var contextId = cursor.cm.visualxml.contextId(controlId, relativeId);
					var offset = textOffset(cursor, cursor.firstIndex);
					var text = cursor.firstTokenOutside.string;
					var element = window.XML.createStartElement([], qName) + window.XML.createEndElement(qName);
					var xml = text.substr(0, offset) + element + text.substr(offset);
					$('.xrx-instance').xrxInstance().replaceTextNode(contextId, numText, xml);
				}
			}
			else {
				var first = {};
				var firstRelativeId = cursor.firstTokenOutside.state.context.id;
				first.contextId = cursor.cm.visualxml.contextId(controlId, firstRelativeId);
				first.nodeType = cursor.firstTokenOutside.state.context.nodeType;
				first.xml = window.XML.createStartElement([], qName);
				first.offset = textOffset(cursor, cursor.firstIndex);
				first.numText = cursor.firstTokenOutside.state.context.numText;
				first.string = cursor.firstTokenOutside.string;

				var last = {};
				var lastRelativeId = cursor.lastTokenOutside.state.context.id;
				last.contextId = cursor.cm.visualxml.contextId(controlId, lastRelativeId);
				last.nodeType = cursor.lastTokenOutside.state.context.nodeType;
				last.xml = window.XML.createEndElement(qName);
				last.offset = textOffset(cursor, cursor.lastIndex);
				last.numText = cursor.lastTokenOutside.state.context.numText;
				last.string = cursor.lastTokenOutside.string;
				
				$('.xrx-instance').xrxInstance().insertElementTag(first, last);
			}
			
			// update the mixed content control
			internalUpdateFlag = true;
			cursor.cm.replaceSelection(replaceString);
			cursor.cm.focus();
			internalUpdateFlag = false;
		});
	}
	
	function hideElementMenu() {

		$(".xrx-elements").hide();
	}
	
	/*
	 * Cursor Selection
	 */
	function handleSomethingSelected(cursor) {
		var valid = false;
		if(cursor.firstAtStartPosition || cursor.lastAtEndPosition) return;
			
		// What is a valid selection in a mixed content field?
		// There are 9 x 9 = 81 possibilities:
		
		// [F1],[L2]      AND [L1], invalid
		// [F1],[L2]      AND [L2], invalid
		// [F1],[L2]      AND [L3], invalid
		// [F1],[L2]      AND [L4], valid if: firstTokenOutside.id (start) == lastTokenInside.id (text)
		// [F1],[L2]      AND [L5], valid if: firstTokenOutside.id (start) == lastTokenInside.id (text)
		// [F1],[L2]      AND [L6], valid if: firstTokenOutside.id (start) == lastTokenOutside.id (text)
		// [F1],[L2]      AND [L7], valid if: firstTokenOutside.id (start) == lastTokenOutside.parent.id (start)
		// [F1],[L2]      AND [L8], valid if: firstTokenOutside.id (start) == lastTokenOutside.id (text)
		// [F1],[L2]      AND [L9], valid if: firstTokenOutside.id (start) == lastTokenOutside.id (text)

		// [F3]           AND [R1-R9], invalid

		// [F4],[F5]      AND [L1], invalid
		// [F4],[F5]      AND [L2], invalid
		// [F4],[F5]      AND [L3], invalid
		// [F4]           AND [L4], valid if: firstTokenOutside.id (text) == lastTokenInside.id (text) 
		// [F4]           AND [L5], valid if: firstTokenOutside.id (text) == lastTokenInside.id (text) 
		// [F4]           AND [L6], valid if: firstTokenOutside.id (text) == lastTokenInside.id (text) 
		// [F4],[F5]      AND [L7], valid if: firstTokenOutside.id (text) == lastTokenOutside.parent.id (start)
		// [F4],[F5]      AND [L8], valid if: firstTokenOutside.id (text) == lastTokenOutside.id (text)
		// [F4],[F5]      AND [L9], valid if: firstTokenOutside.id (text) == lastTokenOutside.id (end)

		// [F5]           AND [L4], valid if: firstTokenInside.id (text) == lastTokenInside.id (text)
		// [F5]           AND [L5], valid if: firstTokenInside.id (text) == lastTokenInside.id (text)
		// [F5]           AND [L6], valid if: firstTokenInside.id (text) == lastTokenInside.id (text)

		// [F6]           AND [L1-L9], invalid
		
		// [F7],[L8]      AND [L1], invalid
		// [F7],[L8]      AND [L2], invalid
		// [F7],[L8]      AND [L3], invalid
		// [F7]           AND [L4], valid if: firstTokenInside.parent.id (start) == lastTokenInside.id (text)  
		// [F7]           AND [L5], valid if: firstTokenInside.parent.id (start) == lastTokenInside.id (text)  
		// [F7]           AND [L6], valid if: firstTokenInside.parent.id (start) == lastTokenInside.id (text)
		// [F7]           AND [L7], valid if: firstTokenInside.parent.id (start) == lastTokenInside.parent.id (end)
		// [F7]           AND [L8], valid if: firstTokenInside.parent.id (start) == lastTokenInside.parent.id (end)
		// [F7]           AND [L9], valid if: firstTokenInside.parent.id (start) == lastTokenInside.parent.id (end)
		
		// [F8]           AND [L4], valid if: firstTokenInside.id (text) == lastTokenInside.id (text)
		// [F8]           AND [L5], valid if: firstTokenInside.id (text) == lastTokenInside.id (text)
		// [F8]           AND [L6], valid if: firstTokenInside.id (text) == lastTokenInside.id (text)
		// [F8]           AND [L7], valid if: firstTokenInside.id (text) == lastTokenInside.parent.id (end)
		// [F8]           AND [L8], valid if: firstTokenInside.id (text) == lastTokenOutside.id (text)
		// [F8]           AND [L9], valid if: firstTokenInside.id (text) == lastTokenOutside.id (end) 
		
		// [F9]           AND [L1-L9], invalid
		
		if(cursor.firstPlace.match(/(F1|F2)/) && cursor.lastPlace.match(/(L4|L5)/) && cursor.firstTokenOutside.state.context.id == cursor.lastTokenInside.state.context.id) valid = true;
		else if(cursor.firstPlace.match(/(F1|F2)/) && cursor.lastPlace.match(/(L6|L8|L9)/) && cursor.firstTokenOutside.state.context.id == cursor.lastTokenOutside.state.context.id) valid = true;
		else if(cursor.firstPlace.match(/(F4)/) && cursor.lastPlace.match(/(L4|L5|L6)/) && cursor.firstTokenOutside.state.context.id == cursor.lastTokenInside.state.context.id) valid = true;
		else if(cursor.firstPlace.match(/(F4|F5)/) && cursor.lastPlace.match(/(L8|L9)/) && cursor.firstTokenOutside.state.context.id == cursor.lastTokenOutside.state.context.id) valid = true;
		else if(cursor.firstPlace.match(/(F5)/) && cursor.lastPlace.match(/(L4|L5|L6)/) && cursor.firstTokenInside.state.context.id == cursor.lastTokenInside.state.context.id) valid = true;
		else if(cursor.firstPlace.match(/(F7)/) && cursor.lastPlace.match(/(L4|L5|L6)/) && parentId(cursor.firstTokenInside.state.context.id) == cursor.lastTokenInside.state.context.id) valid = true;
		else if(cursor.firstPlace.match(/(F7)/) && cursor.lastPlace.match(/(L7|L8|L9)/) && parentId(cursor.firstTokenInside.state.context.id) == parentId(cursor.lastTokenInside.state.context.id)) valid = true;
		else if(cursor.firstPlace.match(/(F8)/) && cursor.lastPlace.match(/(L4|L5|L6)/) && cursor.firstTokenInside.state.context.id == cursor.lastTokenInside.state.context.id) valid = true;
		else if(cursor.firstPlace.match(/(F8)/) && cursor.lastPlace.match(/(L8|L9)/) && cursor.firstTokenInside.state.context.id == cursor.lastTokenOutside.state.context.id) valid = true;
		else if(cursor.firstPlace.match(/(F8)/) && cursor.lastPlace.match(/(L7)/) && cursor.firstTokenInside.state.context.id == parentId(cursor.lastTokenInside.state.context.id)) valid = true;
		else if(cursor.firstPlace.match(/(F1|F2|F4|F5)/) && cursor.lastPlace.match(/(L7)/) && cursor.firstTokenOutside.state.context.id == parentId(cursor.lastTokenOutside.state.context.id)) valid = true;

		//console.log("First Place: " + cursor.firstPlace);
		//console.log("Last Place: " + cursor.lastPlace);
		
		if(!valid) {
			$(".xrx-message").xrxMessage({ 
				state: "error",
				icon: "alert",
				message: "Invalid selection" 
			});
			hideElementMenu();
		} else {
			$(".xrx-message").replaceWith($('<div class="xrx-message"/>'));
			cursor.cm.setOption("readOnly", false);
			showElementMenu(cursor);
		}
		
	}
	/*
	 * Tag Name Widget
	 */
	function showTagName(element, elementContextId) {
		$(".xrx-tagname").xrxTagname({
			qName:element.qName,
      /* -- Annotation Tool -- 
       * set ID for tag selection
       */ 
      elementId:elementContextId
		});
	}
	
	function hideTagName() {
		$(".xrx-tagname").hide();
	}
	/*
	 * Cursor
	 */
	function handleNothingSelected(cursor) {

		if(cursor.firstPosition.line == 0 && cursor.firstPosition.ch == 0) return;
		else {
			var leftNodeType = cursor.firstTokenOutside.state.context.nodeType;
			var rightNodeType = cursor.firstTokenInside.state.context.nodeType;
			var idForAttribute, elementForAttribute;
			
			// mark token on the left side if it is a element
			if(cursor.firstTokenOutside.string == TOKEN_ELEMENT_START || cursor.firstTokenOutside.string == TOKEN_ELEMENT_END) markElementToken(cursor);
			
      /* -- Annotation Tool -- 
       * set ID for tag selection
       */
      var nodeset = $(document).xrx.nodeset(cursor.cm.getInputField());
		  var controlId = nodeset.only.levelId;
        
			idForAttribute = cursor.firstTokenOutside.state.context.id,
			elementForAttribute = saxGetElementById(cursor.cm, idForAttribute);
        
			var elementContextId = cursor.cm.visualxml.contextId(controlId, idForAttribute);

			window.clearTimeout(cursorDelay);
			
			cursorDelay = setTimeout( function() {
				if(cursor.firstTokenOutside.string == TOKEN_ELEMENT_START || cursor.firstTokenOutside.string == TOKEN_ELEMENT_END) { 
					showMixedcontentAttributes(cursor.cm, elementForAttribute, cursor.firstTokenOutside); 
				}
				if(!cursor.firstAtStartPosition && !cursor.firstAtEndPosition) { showElementMenu(cursor); }
			}, 30);

			showTagName(elementForAttribute, elementContextId);
		}
	}
	
	function parentId(id) {
		var tokens = id.split("."), parentId = tokens.slice(0, tokens.length - 1).join(".");
		return parentId;
	}
	
	function clear(cursor) {		
		clearMarkedElements(cursor.cm);
		hideElementMenu();
		hideMixedcontentAttributes(cursor.cm);
		hideTagName();
		$(".xrx-message").replaceWith($('<div class="xrx-message"/>'));
	}

	/*
	 * The nine different places a cursor can have
	 * in a mixed content field
	 * 
	 * [1] start	|	start
	 * [2] start	|	text
	 * [3] start	|	end
	 * [4] text	    |	start
	 * [5] text	    |	text
	 * [6] text	    |	end
	 * [7] end		|	start
	 * [8] end		|	text
	 * [9] end		|	end
	 */
	function cursorPlace(leftToken, rightToken) {
		var leftNodeType = leftToken.state.context.nodeType;
		var rightNodeType = rightToken.state.context.nodeType;
		var place;
		if(       leftNodeType == NODE_ELEMENT_START && rightNodeType == NODE_ELEMENT_START) place = "1";
		else if( leftNodeType == NODE_ELEMENT_START && rightNodeType == NODE_TEXT) place = "2";
		else if( leftNodeType == NODE_ELEMENT_START && rightNodeType == NODE_ELEMENT_END) place = "3";
		else if( leftNodeType == NODE_TEXT          && rightNodeType == NODE_ELEMENT_START) place = "4";
		else if( leftNodeType == NODE_TEXT          && rightNodeType == NODE_TEXT) place = "5";
		else if( leftNodeType == NODE_TEXT          && rightNodeType == NODE_ELEMENT_END) place = "6";
		else if( leftNodeType == NODE_ELEMENT_END   && rightNodeType == NODE_ELEMENT_START) place = "7";
		else if( leftNodeType == NODE_ELEMENT_END   && rightNodeType == NODE_TEXT) place = "8";
		else if( leftNodeType == NODE_ELEMENT_END   && rightNodeType == NODE_ELEMENT_END) place = "9";
		else place = "0";
		//console.log(place);
		return place;
	}
	
	function Cursor(cm) {
		var cursor = new Object(), somethingSelected = cm.somethingSelected();

		var isStartPosition = function(position) {
			return (position.line == 0 && position.ch == 0) ? true : false;
		}
		var isEndPosition = function(position) {
			var numLastLine = cm.lineCount() - 1, lastLine = cm.getLine(numLastLine);
			return (position.line == numLastLine && position.ch == lastLine.length) ? true : false;
		}
		
		var firstCursorPosition = cm.getCursor(true);
		var firstCursorIndex = cm.indexFromPos(firstCursorPosition);
		var firstTokenOutside = cm.getTokenAt(firstCursorPosition);
		var firstTokenInside = cm.getTokenAt(cm.posFromIndex(firstCursorIndex + 1));
		
		var lastCursorPosition = somethingSelected ? cm.getCursor(false) : null;
		var lastCursorIndex = somethingSelected ? cm.indexFromPos(lastCursorPosition) : null;
		var lastTokenInside = somethingSelected ? cm.getTokenAt(lastCursorPosition) : null;
		var lastTokenOutside = somethingSelected ? cm.getTokenAt(cm.posFromIndex(lastCursorIndex + 1)) : null;
		
		var firstFirstCursorIndex = firstCursorIndex - 1;
		var firstFirstCursorPosition = cm.posFromIndex(firstFirstCursorIndex);
		// if we are at the second index we take the first token instead
		var firstFirstTokenOutside = firstFirstCursorIndex == 0 ? firstTokenOutside : cm.getTokenAt(firstFirstCursorPosition);

		var firstAtStartPosition = isStartPosition(firstCursorPosition);
		var firstAtEndPosition = isEndPosition(firstCursorPosition);
		var lastAtStartPosition = somethingSelected ? false : null;
		var lastAtEndPosition = somethingSelected ? isEndPosition(lastCursorPosition) : null;
		
		var firstCursorPlace = firstAtStartPosition ? null : "F" + cursorPlace(firstTokenOutside, firstTokenInside);
		var lastCursorPlace = (firstAtStartPosition || !somethingSelected) ? null : "L" + cursorPlace(lastTokenInside, lastTokenOutside);

		cursor = {
				cm: cm,
				
				firstIndex: firstCursorIndex,
				firstPosition: firstCursorPosition,
				firstTokenInside: firstTokenInside,
				firstTokenOutside: firstTokenOutside,
				firstPlace: firstCursorPlace,
				firstAtStartPosition: firstAtStartPosition,
				firstAtEndPosition: firstAtEndPosition,
				
				lastIndex: lastCursorIndex,
				lastPosition: lastCursorPosition,
				lastTokenInside: lastTokenInside,
				lastTokenOutside: lastTokenOutside,
				lastPlace: lastCursorPlace,
				lastAtStartPosition: lastAtStartPosition,
				lastAtEndPosition: lastAtEndPosition,
				
				firstFirstTokenOutside: firstFirstTokenOutside
		}
		return cursor;
	}
	
	function matchElement(cm) {		
		var cursor = new Cursor(cm);
		clear(cursor);
		if(cm.somethingSelected()) {
			cm.setOption("readOnly", true);
			window.clearTimeout(selectionDelay);
			selectionDelay = setTimeout(function() {
				handleSomethingSelected(cursor);
			}, 30);
		}
		else {
			cm.setOption("readOnly", false);
			handleNothingSelected(cursor);
		}
	}
	
	function deleteElementTag(cursor, tokenType) {
		//console.log("Delete element tag.");
		var corresponding, from, to, oldRange, newRange;
		
		// undo the user's deletion 
		internalUpdateFlag = true;
		cursor.cm.replaceRange(tokenType, cursor.firstPosition);
		internalUpdateFlag = false;
		
		corresponding = correspondingElementToken(cursor, tokenType);
		
		// update the instance (do this before updating the control!)
		var nodeset = $(document).xrx.nodeset(cursor.cm.getInputField());
		var controlId = nodeset.only.levelId;
		var token = cursor.cm.getTokenAt(corresponding);
		var relativeId = token.state.context.id;

		$('.xrx-instance').deleteElementTag(cursor.cm.visualxml.contextId(controlId, relativeId));
		
		// update the mixed content control
		if(tokenType == TOKEN_ELEMENT_START) {
			from = { line: cursor.firstPosition.line, ch: cursor.firstPosition.ch };
			to = { line: corresponding.line, ch: corresponding.ch }; 
		} else {
			from = { line: corresponding.line, ch: corresponding.ch - 1};
			to = { line: cursor.firstPosition.line, ch: cursor.firstPosition.ch + 1};
		}
		oldRange = cursor.cm.getRange(from, to);
		newRange = oldRange.substring(1, oldRange.length - 1);
		//console.log(oldRange + " " + newRange);
		internalUpdateFlag = true;
		cursor.cm.replaceRange(newRange, from, to);
		internalUpdateFlag = false;
	}
	
	// TODO: merge with insertTextNode
	function updateTextNode(cursor, updateType) {
		console.log("Update text node.");
		var tokenToUpdate, textToUpdate, contextId;
		var nodeset = $(document).xrx.nodeset(cursor.cm.getInputField());
		var controlId = nodeset.only.levelId;
		
		// [L1] start | text
		// [L2] start | start
		// [L3] start | end
		// [L4] text  | text
		// [L5] text  | start
		// [L6] text  | end
		// [L7] end   | text
		// [L8] end   | start
		// [L9] end   | end		
		
		// [L2a,L3a] if a new text node is started
		if(cursor.firstFirstTokenOutside.state.context.nodeType == NODE_ELEMENT_START && 
				cursor.firstTokenOutside.state.context.nodeType == NODE_TEXT && 
				(cursor.firstTokenInside.state.context.nodeType == NODE_ELEMENT_START || cursor.firstTokenInside.state.context.nodeType == NODE_ELEMENT_END) &&
				updateType == "insert") {
			//console.log("L2a,L3A");
			tokenToUpdate = cursor.firstFirstTokenOutside;
			textToUpdate = cursor.firstTokenOutside.string;
			contextId = cursor.cm.visualxml.contextId(controlId, tokenToUpdate.state.context.id);
			$('.xrx-instance').insertInto(contextId, textToUpdate);
		}
		// [L2b,L3b] if a existing text node is updated (the last char is deleted)
		else if(cursor.firstTokenOutside.state.context.nodeType == NODE_ELEMENT_START && 
				(cursor.firstTokenInside.state.context.nodeType == NODE_ELEMENT_START || cursor.firstTokenInside.state.context.nodeType == NODE_ELEMENT_END)) {
			//console.log("L2b,L3b");
			tokenToUpdate = cursor.firstTokenOutside;
			textToUpdate = "";
			contextId = cursor.cm.visualxml.contextId(controlId, tokenToUpdate.state.context.id);
			$('.xrx-instance').replaceTextNode(contextId, 1, textToUpdate);
		}
		// [L8a,L9a] if a new text node is inserted
		else if(cursor.firstFirstTokenOutside.state.context.nodeType == NODE_ELEMENT_END &&
				cursor.firstTokenOutside.state.context.nodeType == NODE_TEXT &&
				(cursor.firstTokenInside.state.context.nodeType == NODE_ELEMENT_START || cursor.firstTokenInside.state.context.nodeType == NODE_ELEMENT_END) &&
				updateType == "insert") {
			//console.log("L8a,L9a");
			tokenToUpdate = cursor.firstFirstTokenOutside;
			textToUpdate = cursor.firstTokenOutside.string;
			contextId = cursor.cm.visualxml.contextId(controlId, tokenToUpdate.state.context.id);
			$('.xrx-instance').insertAfter(contextId, textToUpdate);
		}
		// [L8b,L9b] if a existing node is updated (the last char is deleted)
		else if(cursor.firstTokenOutside.state.context.nodeType == NODE_ELEMENT_END &&
				(cursor.firstTokenInside.state.context.nodeType == NODE_ELEMENT_START || cursor.firstTokenInside.state.context.nodeType == NODE_ELEMENT_END)) {
			//console.log("L8b,L9b");
			tokenToUpdate = cursor.firstTokenOutside;
			endElementId = cursor.cm.visualxml.contextId(controlId, tokenToUpdate.state.context.id);
			$('.xrx-instance').deleteTextNode(endElementId);
		}
		// [L1,L4,L7]
		else if(cursor.firstTokenInside.state.context.nodeType == NODE_TEXT) {
			//console.log("L1,L4,L7");
			tokenToUpdate = cursor.firstTokenInside;
			textToUpdate = cursor.firstTokenInside.string;
			contextId = cursor.cm.visualxml.contextId(controlId, tokenToUpdate.state.context.id);
			$('.xrx-instance').replaceTextNode(contextId, tokenToUpdate.state.context.numText, textToUpdate);
		}
		// [L5,L6]
		else if(cursor.firstTokenOutside.state.context.nodeType == NODE_TEXT) {
			//console.log("L5,L6");
			tokenToUpdate = cursor.firstTokenOutside;
			textToUpdate = cursor.firstTokenOutside.string;
			contextId = cursor.cm.visualxml.contextId(controlId, tokenToUpdate.state.context.id);
			$('.xrx-instance').replaceTextNode(contextId, tokenToUpdate.state.context.numText, textToUpdate);
		}
		else {}	
	}
	
	function somethingDeleted(cursor, change) {
		//console.log("Something deleted.");
		//console.log(change);
		var changedText = previousValue.substring(change.from.ch, change.to.ch);
		
		// more than one character deleted including element tags
		if(regexElementToken.test(changedText) && changedText.length > 1) { 
			replaceMixedSelection(cursor, change)
		// element tag deleted
		} else if(regexElementToken.test(changedText)) {
			deleteElementTag(cursor, changedText);
		// one character deleted (not a element tag)
		} else updateTextNode(cursor, "delete");
		
		//console.log("Changed Text: " + changedText);
	}	
	
	function replaceMixedSelection(cursor, change) {
		var cm = cursor.cm;
		var nodeset = $(document).xrx.nodeset(cm.getInputField());
		var controlId = nodeset.only.levelId;
		
		// undo
		internalUpdateFlag = true;
		cm.undo();
		internalUpdateFlag = false;
		
		var firstPositionOutside = { line: 0, ch: change.from.ch };
		var lastPositionInside = { line: 0, ch: change.to.ch };
		var lastPositionOutside = { line: 0, ch: change.to.ch + 1 };
		var firstTokenOutside = cm.getTokenAt(firstPositionOutside);
		var lastTokenOutside = cm.getTokenAt(lastPositionOutside);

		var first = {};
		var firstRelativeId = firstTokenOutside.state.context.id;
		first.contextId = cursor.cm.visualxml.contextId(controlId, firstRelativeId);
		first.nodeType = firstTokenOutside.state.context.nodeType;
		first.offset = textOffset(cursor, cm.indexFromPos(firstPositionOutside));
		first.numText = firstTokenOutside.state.context.numText;
		first.string = firstTokenOutside.string;

		var last = {};
		var lastRelativeId = lastTokenOutside.state.context.id;
		last.contextId = cursor.cm.visualxml.contextId(controlId, lastRelativeId);
		last.nodeType = lastTokenOutside.state.context.nodeType;
		last.offset = textOffset(cursor, cm.indexFromPos(lastPositionInside));
		last.numText = lastTokenOutside.state.context.numText;
		last.string = lastTokenOutside.string;
		
		var xml = clean(change);
		
		// update the instance
		$('.xrx-instance').replaceMixedSelection(first, last, xml)
		
		// update the visual xml control
		internalUpdateFlag = true;
		cm.replaceRange(xml, change.from, change.to);
		internalUpdateFlag = false;
	}
	
	function insertTextNode(cursor, change) {
		var cm = cursor.cm;
		var nodeset = $(document).xrx.nodeset(cm.getInputField());
		var controlId = nodeset.only.levelId;
		var tokenToUpdate, textToUpdate, contextId;
		
		internalUpdateFlag = true;
		cm.undo();
		internalUpdateFlag = false;		

		var firstPositionOutside = { line: 0, ch: change.from.ch };
		var firstTokenOutside = cm.getTokenAt(firstPositionOutside);
		var firstPositionInside = { line: 0, ch: change.from.ch + 1 };
		var firstTokenInside = cm.getTokenAt(firstPositionInside);
		var place = cursorPlace(firstTokenOutside, firstTokenInside);
		var xml = clean(change);
		console.log('that is the place');
		console.log(place);
		
		switch(place) {
		case "1":
		case "3":
			contextId = cm.visualxml.contextId(controlId, firstTokenOutside.state.context.id);
			$('.xrx-instance').insertInto(contextId, xml);
			break;
		case "2":
			contextId = cm.visualxml.contextId(controlId, firstTokenOutside.state.context.id);
			$('.xrx-instance').replaceTextNode(contextId, firstTokenInside.state.context.numText, xml + firstTokenInside.string);
			break;
		case "4":
		case "6":
			contextId = cm.visualxml.contextId(controlId, firstTokenOutside.state.context.id);
			$('.xrx-instance').replaceTextNode(contextId, firstTokenOutside.state.context.numText, firstTokenOutside.string + xml);
			break;
		case "5":
			var offset = textOffset(cursor, cm.indexFromPos(firstPositionOutside));
			contextId = cm.visualxml.contextId(controlId, firstTokenOutside.state.context.id);
			$('.xrx-instance').replaceTextNode(contextId, firstTokenOutside.state.context.numText, firstTokenOutside.string.slice(0).substr(0, offset) + xml + firstTokenOutside.string.slice(0).substr(offset));
			break;
		case "7":
		case "9":
			contextId = cm.visualxml.contextId(controlId, firstTokenOutside.state.context.id);
			$('.xrx-instance').insertAfter(contextId, xml);
			break;
		case "8":
			contextId = cm.visualxml.contextId(controlId, firstTokenInside.state.context.id);
			$('.xrx-instance').replaceTextNode(contextId, firstTokenInside.state.context.numText, xml + firstTokenInside.string);
			break;
		default:
			break;
		}
		
		// update the visual xml control
		internalUpdateFlag = true;
		cm.replaceRange(xml, change.from);
		cm.setCursor({ line: 0, ch: change.to.ch + xml.length });
		internalUpdateFlag = false;		
	}
	
	function contentChanged(cm, change) {
		//console.log("Content changed.");
		//console.log(change);
		var cursor = new Cursor(cm), value = cm.getValue();
		var validStart = new RegExp("^" + TOKEN_ELEMENT_START), validEnd = new RegExp(TOKEN_ELEMENT_END + "$");
		
		
		if(!validStart.test(value) || !validEnd.test(value)) {
			internalUpdateFlag = true;
			cm.undo();
			internalUpdateFlag = false;
			return;
		}
		
		if(change.text == "") somethingDeleted(cursor, change);
		else somethingInserted(cursor, change);
		
		previousValue = cm.getValue();
	}
	
	function somethingInserted(cursor, change) {
		//console.log("Something inserted");
		//console.log(change);
		
		var changedText = previousValue.substring(change.from.ch, change.to.ch);
		//console.log("Changed text: " + changedText);
		//console.log("change.text: " + change.text);
		// a character is inserted, cursor pointer
		if(changedText.length == 0 && change.text[0].length == 1) {
			
			updateTextNode(cursor, "insert");
		}
		// characters are inserted, cursor pointer
		else if(changedText.length == 0 && change.text[0].length > 1) {
			
			insertTextNode(cursor, change);
		}
		// more than one character pasted on cursor selection
		else { 
			//console.log(changedText);
			replaceMixedSelection(cursor, change);
		}
	}
	
	function clean(change) {
		var cleaned, lines = [], regex = new RegExp("("+TOKEN_ELEMENT_START+"|"+TOKEN_ELEMENT_END+"|>|<)", "g");
		for(var i = 0 in change.text) {
			lines.push(change.text[i].replace(regex, ""));
		}
		cleaned = lines.join(" ");
		return cleaned;
	}
	
	/*
	 * Public Interface
	 * function is called whenever the cursor moves
	 */
	CodeMirror.defineExtension("matchElement", function() {

		matchElement(this);
	});
	
	/*
	 * Public Interface
	 */
	CodeMirror.defineExtension("clear", function() {
		
		clearMarkedElements(this);
		hideMixedcontentAttributes(this);
		$(".xrx-elements").hide();
		$(".xrx-tagname").hide();
		$(this.getScrollerElement()).removeClass("xrx-forms-control-hover");
	});
	/*
	 * Public Interface
	 * function is called whenever content changes
	 */
	CodeMirror.defineExtension("contentChanged", function(cm, change) {
		if(!internalUpdateFlag) contentChanged(this, change);
	});
	/*
	 * Public Interface
	 */
	// when focus is given we keep the actual editor content to handle 
	// insertions and deletions into the mixed content control
	// TODO: only keep the actual, the previous and the following line (for larger instances)
	CodeMirror.defineExtension("keepValue", function() {
		previousValue = this.getValue();
		//console.log(previousValue);
	});
  
})();
/*
 * CodeMirror mode which parses the content of 
 * a textarea into a abstract syntax tree (AST)
 */
CodeMirror.defineMode("visualxml", function() {
	var NODE_ELEMENT_START = "element-start";
	var NODE_ELEMENT_END = "element-end";
	var NODE_TEXT = "text";
	var TOKEN_ELEMENT_START = "»";
	var TOKEN_ELEMENT_END = "«";
	var lastStartElementLevel = [];
	var elementReached = new RegExp("(" + TOKEN_ELEMENT_START + "|" + TOKEN_ELEMENT_END + ")"); 
	function previousElementContext(context) {
		var c = context;
		if(c.prev != null) {
			while(c.prev != null) {
				if(c.nodeType == NODE_TEXT) {
					c = c.prev; 
				} else {
					break;
				}
			}
		}
		return c;
	}
	function nodeId(state, nodeType) {
		var newId;
		var previousContext = previousElementContext(state.context);
		var previousId = previousContext.id;
		var previousNodeType = previousContext.nodeType;
		if(nodeType == NODE_ELEMENT_START) {
			if(previousNodeType == NODE_ELEMENT_START) {
				newId = previousId + ".1";
			}
			else {
				var tokens = previousId.split(".");
				var lastTokenAsInt = parseInt(tokens[tokens.length - 1]);
				var incrementLastAString = String(lastTokenAsInt + 1);
				tokens[tokens.length - 1] = incrementLastAString;
				newId = tokens.join(".");
			}
		}
		else if(nodeType == NODE_ELEMENT_END || nodeType == NODE_TEXT) {
			
			if(previousNodeType == NODE_ELEMENT_START) newId = previousId;
			else {
				var tokens = previousId.split(".");
				var removeLast = tokens.slice(0, tokens.length - 1);
				newId = removeLast.join(".");
			}
		}
		else newId = previousId;
		return newId;
	}
	function textNum(context, id) {
		var c = context, num = 0;
		if(c.prev != null) {
			while(c.prev != null) {
				c = c.prev;
				if(c.nodeType == NODE_TEXT && c.id == id) {
					num = c.numText;
					break;
				} else continue;
			}
		}
		return num + 1;
	}
	function changeContext(state, nodeType) {
		var id = (!state.context) ? "1" : nodeId(state, nodeType);
		var numText = (!state.context || nodeType != NODE_TEXT) ? null : textNum(state.context, id);
		var newContext = {
			nodeType: nodeType,
			id: id,
			numText: numText,
			prev: state.context,
			next: null 
		}
		if(nodeType == NODE_ELEMENT_START) lastStartElementLevel.unshift(id);
		else lastStartElementLevel.shift();
		state.context = newContext;
		//console.log(state.context.prev);
	}
	function parse(stream, state) {

		var ch = stream.next();
		if (ch == TOKEN_ELEMENT_START) {
			changeContext(state, NODE_ELEMENT_START);
			return NODE_ELEMENT_START;
		}
		else if (ch == TOKEN_ELEMENT_END) {
			changeContext(state, NODE_ELEMENT_END);
			return NODE_ELEMENT_END;
		}
		else {
			while(true) {
				ch = stream.next();
				if(ch == null) break; 
				if(ch == TOKEN_ELEMENT_START || ch == TOKEN_ELEMENT_END) {
					stream.backUp(1);
					break;
				}
			};
			changeContext(state, NODE_TEXT);
			return NODE_TEXT;
		}
	}
	return {
		startState: function() {
			return {
				tokenize: parse,
				context: null
			};
		},
		token: function(stream, state) {
			var style = state.tokenize(stream, state);
			return style;
		}
	};
});

CodeMirror.defineMIME("text/visualxml", "visualxml");
