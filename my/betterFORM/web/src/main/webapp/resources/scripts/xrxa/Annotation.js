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
    "dojo/_base/xhr",
    "dojo/_base/window",
    "dojo/dom-construct",
    "dojo/dom-class",
    "dojo/dom-style",
    "dijit/_WidgetBase",
    "scripts/xrxa/StartTag",
    "scripts/xrxa/EndTag",
    "scripts/xrxa/AttributesDialog",
    "scripts/jquery/jquery"
    ],
    function(declare, xhr, win, domConstruct, domClass, domStyle, _WidgetBase, StartTag, EndTag, AttributesDialog,jquery){
	    return declare(_WidgetBase,
	    	{
	    	  constructor : function(params){
	    		  //console.log('~~~ Annotation.constructor', params.xmlNode, '| ',params.label, params.namespace, params.name);

	    		  console.log('Annotation.constructor');

	    		  this.myDeclaredClass ='xrxa.Annotation';
	    		  this.id = params.id;
	    		  this.parentElement = params.parentElement;
	    		  this.label =params.labelname;
	    		  this.namespace = params.namespace;
	    		  this.name = params.name;
	    		  this.xmlNode = params.xmlNode;
	    		  if(!this.namespace && !this.xmlNode){
	    			  this.namespace = this.parentElement.namespace;
	    		  }
	    		  if(this.xmlNode){
	    			  this.label =  this.xmlNode.nodeName;
	    			  this.name =  this.xmlNode.nodeName;
	    			  this.namespace = this.xmlNode.namespaceURI;
	    		  }
	    		  else{
	    			  this.xmlNode = this.createXMLNode();
	    		  }
	    		  this.getPrefix();
	    		  this.startText =params.startText;
	    		  this.containedObjects = params.containedObjects;
	    		  this.endText = params.endText;
	    	  },
	    	  getPrefix : function(){

	          	splittedNodeName = this.name.split(":");
	          	this.prefix = splittedNodeName[0];
	          },
	    	  postCreate : function()
	    	  {
	    		console.log('Annotation.postCreate');

	    		this.domNode = this.createAnnotationSpan();
	    		this.createAnnotation();
	    		this.annotationInfo();
	    		//this.createAttributesObject();
	    		this.attributeDialog = new AttributesDialog({element: this, attributesObject: this.attributesObject});
	    	  },
	    	  updateUI : function(ui){
	    		  this.attributeDialog.updateUI(ui);
	    	  },
	    	  createAnnotation : function(){
	    		  console.log('Annotation.createAnnotation');

	    		  this.createStartTag();

	    		  this.createContent();

	    		  this.createEndTag();
	    	  },
	    	  createAnnotationSpan : function(){
	    		  var annotationSpan =  domConstruct.create("span", {id: this.id});
	    		  domClass.add(annotationSpan, 'xrxaAnnotation');
	    		  return annotationSpan
	    	  },
	    	  createStartTag: function (){
	    		this.starttag = new StartTag({labelname: this.label, element: this});
	    	    domConstruct.place(this.starttag.domNode, this.domNode);
	    	  },
	    	  createContent: function (){
	    		  console.log('Annotation.createContent');
	    		  var annotation = this;
	    		  require(["scripts/xrxa/Content"], function(Content){
	    			  annotation.content = new Content({xmlNode: annotation.xmlNode, parent:annotation, domNode:annotation.domNode, element: annotation, selectedText:annotation.startText, selectedAnnotations:annotation.containedObjects, endText: annotation.endText});
	    			  domConstruct.place(annotation.content.domNode, annotation.domNode);
	    		  });
	    	  },
	    	  createEndTag: function (){
	    		  this.endtag = new EndTag({labelname: this.label, element: this});
	    		  domConstruct.place(this.endtag.domNode, this.domNode);
	    	  },
	    	  annotationInfo : function(){
	    		  var annotation = this;
	    		  var pathElement = '<path>' + this.getPath() + '</path>';
	    		  var xsdlocElement = '<xsdloc>' + this.getAnnotationControl().xsdloc + '</xsdloc>';
	    		  var dataElement = '<data>'+ pathElement + xsdlocElement + '</data>';
	    		  //see Toolbar get-menu
	    		  //var data =  this.getAnnotationControl().parser.parse(dataElement);
	    		  $.ajax({
	    			  url: this.getAnnotationControl().services + "?service=get-annotation",
	    			  headers: { "Content-Type": "application/xml"},
	    			  data: dataElement,
              type: "POST",
    		      success: function(result, textStatus, jqXHR){
    		    	  	var annotationInfo = annotation.loadXMLString(result);
    		    	  	for(var i=0; i< annotationInfo.childNodes.length; i++){
    		    	  		if(annotationInfo.childNodes[i].nodeName=="label"){
    		    	  			var label = annotationInfo.childNodes[i].firstChild.data;
    		    	  			annotation.updateLabel(label);
    		    	  			//annotation.updateToEmptyElement();
    		    	  		}
    		    	  		if(annotationInfo.childNodes[i].nodeName=="empty"){
    		    	  			annotation.updateToEmptyElement();
    		    	  		}
    		    	  		if(annotationInfo.childNodes[i].nodeName=="display"){
    		    	  			var display = annotationInfo.childNodes[i].firstChild.data;
    		    	  			annotation.updateDisplay(display);
    		    	  		}
    		    	  	}
    		      }
	    		  });

	    	  },
	    	  updateLabel: function(name){
	    		    this.label=name;
	    		  	this.starttag.setLabel(name);
	    		  	this.endtag.setLabel(name);
	    	  },
	    	  updateDisplay: function(value){
	    		  domStyle.set(this.domNode, 'display', value);
	    	  },
	    	  updateToEmptyElement: function(){
	    		  domConstruct.destroy(this.content.domNode);
	    		  domStyle.set(this.endtag.domNode, 'display', 'none');
	    		  domClass.remove(this.starttag.domNode, 'xrxaStarttag')
	    		  domClass.add(this.starttag.domNode, 'xrxaStartEndTag')
	    	  },
	    	  getXMLNode : function(){
            this.updateXMLNode();
	    		  return this.xmlNode;
	    	  },

	    	  getOuterXML : function(){

	    		  var serializer = this.getAnnotationControl().serializer;

	    		  try {
	    		      // Gecko- and Webkit-based browsers (Firefox, Chrome), Opera.
	    		      return serializer.serializeToString(this.xmlNode);
	    		  }
	    		  catch (e) {
	    		       return this.xmlNode.xml;
	    		   }
	    		   return false;

	    	  },




	    	  getPath: function(){
	    		  return this.parentElement.getPath() + '/'+ this.name;
	    	  },
	    	  updateXMLNode : function(){
	    		  //console.log('%%%%% Annotation.updateXMLNode %%%%%');
	    		  if(this.xmlNode){
	    			  domConstruct.destroy(this.xmlNode);
	    		  }
	    		  this.xmlNode = this.createXMLNode();
	    		  this.content.updateXML();
	    		  this.updateAttributes();
	    		  //validate here
	    	  },
	    	  updateAttributes : function(){
	    		  this.attributeDialog.getXMLAttributes(this.xmlNode);
	    	  },
	    	  createXMLNode: function(){
	    		  return win.doc.createElementNS(this.namespace, this.name);
	    	  },
	    	  getAnnotationControl : function(){
	    		  return this.parentElement.getAnnotationControl()
	    	  },
	    	  toggleLabelDisplay : function(){
	    		  this.starttag.toggleLabelDisplay();
	    		  this.endtag.toggleLabelDisplay();
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
                   return xml.documentElement;
                 }

                 return null;
               } else {

                 xml = new ActiveXObject( "Microsoft.XMLDOM" );

                 xml.async = false;
                 xml.loadXML( text );

                 return xml.documentElement;
               }
             } catch ( e ) {
               // suppress
             }

          }

	    });
	});
