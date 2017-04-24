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
    "dojo/on",
    "dojo/dom-construct",
    "dojo/dom-class",
    "dojo/query",
    "dijit/form/Button",
    "dijit/Dialog",
    "scripts/xrxa/Attribute",
    "scripts/xrxa/InsertAttributeButton",
    "scripts/jquery/jquery"
    ],
    function(declare,  on, domConstruct, domClass, query, Button, Dialog, Attribute, InsertAttributeButton, jquery){
    	return declare(Dialog,
	    	{
    		constructor : function(params){

    			  this.element = params.element;
    			  this.attributesObject = params.attributesObject;
    			  this.title = this.element.label;
    		      this.style ="background-color:white;"; //width: 560px;
    		      this.attributeObjects = new Array();
    			  this.inherited(arguments);
    			  this.getAttributeOptions();
    			  this.label = "Remove Annotation";
    			  this.ok = 'OK';
    		 },
    		  postCreate : function(){
    			  this.inherited(arguments);
    			  this.createHeader();
    			  this.createContent();
    			  this.createFooter();
    		  },
    		  updateUI : function(ui){
    			  /*this.label = query("text[id='remove-annotation']", ui)[0].firstChild.data;
    			  this.ok = query("text[id='ok']", ui)[0].firstChild.data
    			  this.removeAnnotationButton.set('label', this.label);
    			  this.okButton.innerHTML = this.ok;*/
    		  },

    		  createHeader : function(){
    		  this.header = domConstruct.create('div');
    		  domClass.add(this.header, "xrxaAnnotationDialogHeader");
    		  domConstruct.place(this.header, this.containerNode, 'first');
    		  this.createRemoveAnnotationButton();
    	  	  },
    		  createRemoveAnnotationButton: function(){
    			  //why does this work in 1.7?
    			  this.removeAnnotationButton = new dijit.form.Button({
    			        label: this.label,
    			        iconClass : "dijitEditorIcon dijitEditorIconDelete"
    			    });
    			  domClass.add(this.removeAnnotationButton.domNode, "xrxaRemoveAnnotationButton");
    			  domConstruct.place(this.removeAnnotationButton.domNode, this.header);
    			  this.connect(this.removeAnnotationButton.domNode, "onmouseup", 'hide');
    			  this.connect(this.removeAnnotationButton.domNode, "onmouseup", "removeAnnotation");
    		  },
    		  createFooter : function(){
    			  this.footer = domConstruct.create('div');
    			  domClass.add(this.footer, "xrxaAnnotationDialogFooter");
    			  domConstruct.place(this.footer, this.containerNode, 'last');
    			  this.createOk();
    		  },
    		  createOk : function(){
    			  this.okButton = domConstruct.create('button', {innerHTML : this.ok});
    			  domClass.add(this.okButton, "xrxaOKButton");
    			  dojo.connect(this.okButton, "click", this, 'hide');
    			  //on(this.okButton, "click", this, 'hide');
    			  domConstruct.place(this.okButton, this.footer);
    		  },
    		  removeAnnotation: function(){
    			 if(this.element.content.countContainedAnnotations()>0){
    					alert('Please delete all annotations within this annotation first!');
    			 }
    			  else{
    				  this.element.parentElement.content.removeAnnotation(this.element);
    			 }
    		  },
    		  createContent : function(){
    			  this.content = domConstruct.create('div');
    			  domClass.add(this.content, "xrxaAnnotationDialogContent");
    			  domConstruct.place(this.content, this.containerNode);
    			  this.createAttributesDiv();
    		  },
    		  createAttributesDiv : function(){
    			  this.attributesDiv = domConstruct.create('div', {}, this.content);
    			  this.createOptionsDiv();
    			  this.addAttributes();
    		  },
    		  createOptionsDiv: function(){
    			 this.optionsDiv = domConstruct.create("div");
    			 domClass.add(this.optionsDiv, 'xrxaOptionsDiv');
    			 domConstruct.place(this.optionsDiv, this.attributesDiv);
    		 },
    		// creates attribute objects for all existing xml attributes
    		 addAttributes: function(){
    			 for(var i=0; i<this.element.xmlNode.attributes.length; i++){
    				   var attribute = this.element.xmlNode.attributes[i];
    				   this.addAttribute(attribute)
    			   }
    		  },
    		//creates an attribute object for a xml attribute and adds it into the UI and the array
    		  addAttribute : function(attribute){
    			  var attributeObject = new Attribute({xmlNode: attribute, element:this.element});
    			  this.attributeObjects.push(attributeObject);
    			  domConstruct.place(attributeObject.domNode, this.attributesDiv);
    		  },
    		  updateOptions: function(){
    				 domConstruct.empty(this.optionsDiv);
    				 this.getAttributeOptions();
    				 this.element.getAnnotationControl().onAnnotationsChanged();
    		  },
    		  getAttributeOptions : function(){
    		  	  var attributes = this;
    			  var pathElement = '<path>' + this.element.getPath() + '</path>';
    			  var xsdlocElement = '<xsdloc>' + this.element.getAnnotationControl().xsdloc + '</xsdloc>';
    			  var elementElement = '<element xmlns:'+ this.element.prefix+ '="' + this.element.namespace+ '">' + this.element.getOuterXML() + '</element>';
    			  var dataElement = '<data>'+ pathElement + xsdlocElement + elementElement + '</data>';
    			  $.ajax({
    				  url: this.element.getAnnotationControl().services + "?service=get-attribute-options",
    				  headers: { "Content-Type": "application/xml; charset=utf-8", "Accept": "text/html,application/xhtml+xml,application/xml", "X-Requested-With":null },
              type: "POST",
    				  data: dataElement,

    			    success: function(result , textStatus, jqXHR){

                  //console.log('get-attribute-options:', result);
                  var parseXML = attributes.loadXMLString(result);
    			    	  var attributeInfo = parseXML.documentElement;
    			    	  var attributeOptions = attributes.queryElementChildren('attribute', attributeInfo);
    			    	  	//var attributeOptions = query('attribute', attributeInfo);
    				    	for(var i=0; i< attributeOptions.length; i++){
    				    		var insertAttributeButton = InsertAttributeButton({attributeOption: attributeOptions[i], attributes: attributes});
	            				domConstruct.place(insertAttributeButton.domNode, attributes.optionsDiv);
				    	  	}
    			      }
    			  });
    			  },
    			  insertAttribute : function(label, namespace, name){
    				  var attributeObject = new Attribute({label:label, namespace:namespace, name:name, element:this.element});
    				  this.attributeObjects.push(attributeObject);
    				  domConstruct.place(attributeObject.domNode, this.attributesDiv);
    				  this.element.updateXMLNode();
    				  this.updateOptions();
    			  },
    			  removeAttribute : function(attributeObject){
    				  domConstruct.destroy(attributeObject.domNode);
    				  domConstruct.destroy(attributeObject.xmlNode)
    				  var index = this.getIndex(attributeObject);
    				  this.attributeObjects.splice(index, 1);
    				  this.element.updateXMLNode();
    				  this.updateOptions();
    			  },
    			  getIndex: function(attributeObject){
    				  for(var i=0; i<this.attributeObjects.length; i++){
    					  if(this.attributeObjects[i]==attributeObject){
    						  return i
    					  }
    				  }
    			  },
    			  //returns attributes as xml-dom nodes cretaed off the -Object model
    			  getXMLAttributes: function(element){
    				  for(var i=0; i<this.attributeObjects.length; i++){
    					  this.attributeObjects[i].getAttribute(element);
    				  }
    				  return element;
    			  },
    			  hide: function(){
    				  this.inherited(arguments);
    				  this.element.getAnnotationControl().onAnnotationsChanged();
    			  },

    			  show: function(){

    				  this.inherited(arguments);
    				  this.set('title', this.element.label);

    			  },

    			  queryElementChildren: function(name, node){
    	    		  var childNodes = node.childNodes;
    	    		  var length = childNodes.length;
    	    		  var children = new Array();

    		    		  for(var i = 0; i < length; i++){
    		    			  var childNode = childNodes[i];
    		    			  if(childNode.nodeType==1 & childNode.nodeName==name){
    		    				  children.push(childNode)
    		    			  }
    		    		  }
    		    		  var elementChild = children[0];
    	    		  return children
    	    	  },
              loadXMLString: function (text)
                {
                  try {
                     var xml = null;

                     if ( window.DOMParser ) {

                       var parser = new DOMParser();
                       xml = parser.parseFromString( text, "text/xml" );

                       var found = xml.getElementsByTagName( "parsererror" );

                       if ( !found || !found.length || !found[ 0 ].childNodes.length ) {
                         return xml;
                       }

                       return null;
                     } else {

                       xml = new ActiveXObject( "Microsoft.XMLDOM" );

                       xml.async = false;
                       xml.loadXML( text );

                       return xml;
                     }
                   } catch ( e ) {
                     // suppress
                   }

                }


	    	});
		});
