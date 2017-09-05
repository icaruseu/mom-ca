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
along with VdU/VRET.  If not, see http://www.gnu.org/licenses.
 */
//author: daniel.ebner@uni-koeln.de

define([
    "dojo/_base/declare",
    "dojo/_base/event",
    "dojo/_base/sniff",
    "dojo/dom-construct",
    "dojo/dom-class",
    "dojo/dom-attr",
    "dojo/has",
    "dijit/_WidgetBase",
    "dojox/xml/parser",
    "scripts/xrxa/PasteDialog",
    "scripts/xrxa/Content",
    "scripts/xrxa/Selection",
    "scripts/xrxa/Header",
    "scripts/jquery/jquery"
], function(declare, event, sniff,  domConstruct, domClass, domAttr, has, _WidgetBase, parser, PasteDialog, Content, Selection, Header, jquery){
    return declare(_WidgetBase, {


    	constructor: function(params){
        	console.log("~~~AnnotationControl.constuctor.params", params);

        	this.window = window;
        	this.parser = parser;
        	this.serializer = new XMLSerializer();

        	/*### Get the information passed from the xforms-control ###*/

        	//the initial textarea control
        	this.textarea = params.textarea
    		//the value of the textarea (maseked xml content)
        	this.value = this.textarea.value;
        	this.rows = this.textarea.rows;
    		//the location of the xsd that is queryed
        	this.xsdloc = domAttr.get(this.textarea, 'xsdloc');
    		//the uri of the services that is called for ajax calls
        	this.services = domAttr.get(this.textarea, 'services');
    		//the namespace of the elment that is represented my this control
    		this.namespace = domAttr.get(this.textarea, 'namespace');
    		//the path to this node from the root
    		this.nodePath = domAttr.get(this.textarea, 'nodepath');

    		//get the name of the element from the node's path
    		this.getNodeName();

    		//get the prefix used for this node from the node's name
    		this.getPrefix();

    		console.log('%%% AnnotationControl.constructor.xrxeParams %%%', ' rows:', this.rows, 'namespace:', this.namespace, 'nodeName:', this.nodeName, 'nodePath:', this.nodePath, 'xsdloc:', this.xsdloc, 'services:', this.services);

    		//a object that handles the user's selection within the annotation area
    		this.selection= new Selection({annotationControl: this});
    		//create a dialog that handles the paste evnet
    		this.createPasteDialog();
    		//the domNode of this control
    		this.domNode = domConstruct.create("div");
        },

        getNodeName : function(){
        	var n = this.nodePath.lastIndexOf('/');
        	this.nodeName = this.nodePath.substring(n + 1);
        },

        getPrefix : function(){
        	//TODO if no prefix exists
        	splittedNodeName = this.nodeName.split(":");
        	this.prefix = splittedNodeName[0];
        },

        postCreate: function(){
    		this.inherited(arguments);
    		//Is allready empty in the betterFORM springBud
    		//domConstruct.empty(this.domNode);

    		domClass.add(this.domNode, "dijitEditor");
    		domClass.add(this.domNode, 'xrxaAnnotationControl');

    		//the editable div containing the text and the annotations
    		this.createAnnotationArea();
    		//the header on top of the annotation area containing the menu
    		this.createHeader();
    	},

    	createHeader: function(){
    		this.header = new Header({annotationControl: this, id:this.id+'-header'});
    		domClass.add(this.header, 'xrxaAnnotationHeader');
    		domConstruct.place(this.header.domNode, this.domNode, 'first');
    	},
    	//creates the dialog used to paste Text into the control
    	createPasteDialog : function(){
    		this.pasteDialog = new PasteDialog({
    			  annotationControl: this,
    			  title: "Text Einfügen",
    		      style: "width: 560px; background-color:white;"
    		  });
    		  domClass.add(this.pasteDialog, 'xrxaInsertTextDialog');
    	},

    	//called from PasteDialog when pressing the OK Button or automaically
    	insertText: function(){
    		var text =  this.pasteDialog.getText();
	    	var currentContent = this.selection.getContent();
	    	currentContent.insertText(this.selection, text);
	    	this.pasteDialog.clear();
	    	console.log('AnnotationControl insert Text', text);
	    },

    	//creating the editable Div
	    createAnnotationArea: function(){
    		this.annotationArea = domConstruct.create("div", {id: this.id+"AnnotationArea", tabindex: '0', contentEditable: 'true', style: 'min-height:' + (10 * this.rows) + 'px;'}, this.domNode);
    		domClass.add(this.annotationArea, 'xrxaAnnotationArea');
    		this.addEvents();
    		this.setContent();
    	},

    	//Add Events to the Annotation Area
    	addEvents: function(){
    		this.connect(this.annotationArea, "onmouseup", "onClick");
    		//this.connect(this.annotationArea, "onmouseout", "onMouseOut");
    		this.connect(this.annotationArea, "onkeydown", "onKeyDown");
    		this.connect(this.annotationArea, "onkeyup", "onKeyUp");
    		this.connect(this.annotationArea, "onblur", "onBlur");
    		this.connect(this.annotationArea, "onfocus", "onFocus");
    		this.connect(this.annotationArea, "onpaste", "handlePaste");
    		this.connect(this.annotationArea, "oncopy", "handleCopy");
    	},

    	//the Content of the Annotation Control is Set by demasking the masked XML, creating an XML-DOM-Node and passing this into a Content Objekt
    	setContent: function(){
    		this.xmlValue = this.demaskXML(this.value);
    		this.xmlNode = this.createFilledXMLNode();
    		this.content= new Content({xmlNode:this.xmlNode, element:this});
    		domConstruct.place(this.content.domNode, this.annotationArea);
    	},


    	//the initial content of the textarea is masked xml
    	demaskXML : function(value){
    		value = value.replace(/&lt;/g, "<");
    		value = value.replace(/&gt;/g, ">");
    		value = value.replace(/&quot;/g, '"');
    		return value;
    	},

    	//create a XML-DOM-Node for this Control from the Content and the Name with Content
    	createFilledXMLNode : function(){
    		var xmlNodeDoc = parser.parse(this.createFilledNodeString());
    		return xmlNodeDoc.childNodes[0];
    	},


    	createFilledNodeString : function(){
    		var xmlNodeString = this.createStartTagString() + this.xmlValue + this.createEndTagString();
    		return xmlNodeString;
    	},
    	createStartTagString : function(){
    		var startTagString = "<" + this.nodeName  + this.getXmlns() + ">"
    		return startTagString;
    	},
    	getXmlns : function(){
    		var xmlnsString
    		if(this.prefix){xmlnsString = ' xmlns:' + this.prefix + '="' + this.namespace + '"';}
    		else{ xmlnsString = ' xmlns="' + this.namespace + '"' }

    		//HARDCODED
    		//Problem: we don't know the namespaces used within this content, only the namespace of the control's element
    		xmlnsString = xmlnsString + ' xmlns:xlink="http://www.w3.org/1999/xlink"'
    		return xmlnsString;
    	},
    	createEndTagString : function(){
    		var endTagString = "</" + this.nodeName + '>';
    		return endTagString;
    	},
    	createEmptyXMLNode : function(){
    		var xmlNodeDoc = parser.parse(this.createEmptyNodeString());
    		return xmlNodeDoc.childNodes[0];
    	},
    	createEmptyNodeString : function(){
    		var xmlNodeString = this.createStartTagString() + this.createEndTagString();
    		return xmlNodeString;
    	},

    	onFocus: function(e){
            //console.log('AnnotationControl annotationArea focused. Node: ', focus.curNode);
    		//this.inherited(arguments);
        },
        onBlur: function(e){
        	//console.log('AnnotationControl annotationArea blured');
            //this.inherited(arguments);
        },

        //update the Seletion Objekt when Selektion changes by using keys and shift
        onKeyUp: function(e){
          //update after arrows + shift has been used to select
        	if(e.keyCode == 16  | e.keyCode == 37  | e.keyCode == 38  | e.keyCode == 39  | e.keyCode == 40){
        		this.update();
        	}
        },

        //Stop Enter from inserting new line
    	onKeyDown: function(e){
    		if(e.keyCode == 13){
    			event.stop(e);
    		}
    		return true;
    	},

    	//update the selection and the header
    	onClick: function(e){
    		this.update();
    	},

    	onMouseOut: function(e){
    		//this.update();
    	},

    	update: function(){
    		this.selection.update();
    		this.header.update();
       },


 	  	//to comunicated with betterform code
 	  	onAnnotationsChanged: function(){
 	  		//console.log('onAnnotationsChanged');
 	  		//DO NOT REMOVE
 	  		//connected to FactoryTextarea for incremental update
 	  	},



 		 //handle the paste Event to insert only text and no html-markup
    	handlePaste: function(e){
    		//alert('Bitte Verwenden Sie für das Einfügen von Texten AUSSCHLIESSLICH den Einfüge-Button rechts oben. For inserting text please use only the INSERT button in the right upper corner.');
    		if (has("ie") > 8){
    			event.stop(e);
    			this.pasteDialog.show();
    		}
    		else if(has("chrome")){
    			console.log('chrome handlePaste');
    			this.pasteDialog.show();
    		}
    		else if(has("ff")){
    			console.log('firefox handlePaste');
    			event.stop(e);
    			this.pasteDialog.show();
    		}
    		else{
    			console.log('else handlePaste');
    			event.stop(e);
    			this.pasteDialog.show();
    		}
    	},


    	handleCopy: function(e){
    		event.stop(e);
    	},

    	getPath: function(){
    	  	  return this.nodePath;
    	},

    	getAnnotationControl : function(){
   		 return this
   	    },

   	    //not used
    	getUITexts: function (){
    		var annotationControl = this;
    		$.ajax({
    			  url: this.services + "?service=get-ui-text",
    			  headers: { "Content-Type": "application/xml; charset=utf-8", "Accept": "text/html,application/xhtml+xml,application/xml", "X-Requested-With":null },
    			  type: "GET",
  		      success: function(result, textStatus, jqXHR){
              console.log('get-ui-text:', result);
  		    	   var ui = result.responseText;
  		    	    annotationControl.content.updateUI(ui);
  		    	    annotationControl.pasteDialog.updateUI(ui);
  		      }
    		  });
    	},

    	//returns the Value of the Control
    	getValue: function(){
    		//update the xml-dom-node
    		this.updateXMLNode();
    		//get the content value
    		var value = this.content.getInnerXML().replace(/&nbsp;/g, ' ');
    		console.log('AnnotationControl.getValue', value);
    		return value;
    	},


 		//update the xml-dom-node
 		updateXMLNode: function(){
 	     	//destroy old xml-dom-node
 			if(this.xmlNode){
 	 			  domConstruct.destroy(this.xmlNode);
 	 		}
 	 		//create a new empty xml-dom-node
 			this.xmlNode = this.createEmptyXMLNode();
 	 		//fill the new xml-dom-node by content object
 			if(this.content){
 	 			this.content.updateXML();
 	 		}
 	 	}


    });
});
