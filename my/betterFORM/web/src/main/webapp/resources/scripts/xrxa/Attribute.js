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
    "dojo/_base/window",
    "dojo/dom-construct",
    "dojo/dom-class",
    "dojo/dom-attr",
    "dojo/query",
    "dijit/_WidgetBase",
    "dijit/form/ValidationTextBox",
    "dijit/form/Select",
    "dijit/form/Button",
    "scripts/jquery/jquery"

    ],
    function(declare, win, domConstruct, domClass, domAttr, query, _WidgetBase, ValidationTextBox, Select, Button, jquery){
    	return declare(_WidgetBase, {
    		constructor : function(params){
    			  //console.log('~~~ Attribute.constructor', params.xmlNode, '| ',params.label, params.namespace, params.name);
    			  console.log('attribute.constructor');
    			  this.id = params.id;
    			  this.element = params.element;
    			  this.label =params.label;
    			  this.namespace = params.namespace;
    			  this.name = params.name;
    			  this.value = "";
    			  this.xmlNode = params.xmlNode;


    			  if(this.xmlNode){
    				  this.label =  this.xmlNode.nodeName;
    				  this.name =  this.xmlNode.nodeName;
    				  this.namespace = this.xmlNode.namespaceURI;
    				  // this.value = this.xmlNode.nodeValue //Das nodeValue-Attribut auf Attributen sollte nicht mehr verwendet werden. Verwenden Sie value stattdessen.
    				  this.value = this.xmlNode.value;
    			  }
    			  else{
    				  this.xmlNode = this.createXMLNode();
    			  }
    		  },
    		  postCreate : function(){
    			     this.createAttributeSpan();
    			     if(this.name.substring(0, 6)!='xmlns:'){
    			    	 this.attributeInfo();
    			     }
    		  },
    		  createAttributeSpan : function()
    		  {


    			  this.attributeSpan = domConstruct.create('span');
    			  domClass.add(this.attributeSpan, 'xrxaAttribute');
    			  // Hide "xmlns" handled as attributes by Javascript
    			  if(this.name.substring(0, 6)=='xmlns:'){
    				  domAttr.set(this.attributeSpan, 'style', 'display:none;') ;
    			  }
    			  this.createAttributeLabelSpan();
    			  this.createAttributeValueSpan();
    			  this.domNode = this.attributeSpan;
    		  },
    		  remove: function(){
    			  	this.element.attributeDialog.removeAttribute(this);
    		  },
    		  createAttributeLabelSpan : function()
    		  {

    			  var labelSpan = domConstruct.create('span');
    			  domClass.add(labelSpan, 'xrxaAttributeName');
    			  this.labelText = win.doc.createTextNode(this.label);
    			  domConstruct.place(this.labelText,  labelSpan);
    			  domConstruct.place(labelSpan,  this.attributeSpan);

    		  },
    		  createAttributeValueSpan : function()
    		  {

    			  this.controlSpan = domConstruct.create('span', {}, this.attributeSpan);
    			  domClass.add(this.controlSpan, 'xrxaAttributeValue');
    		  },
    		   attributeInfo : function(){
    			   console.log('Attribute.attributeInfo');
    			   	  var attribute = this;
    				  var pathElement = '<path>' + this.getPath() + '</path>';
    				  var xsdlocElement = '<xsdloc>' + this.element.getAnnotationControl().xsdloc + '</xsdloc>';
    				  var dataElement = '<data>'+ pathElement + xsdlocElement + '</data>';
	              $.ajax({
    					  url: this.element.getAnnotationControl().services + "?service=get-attribute",
    					  headers: { "Content-Type": "application/xml; charset=utf-8", "Accept": "text/html,application/xhtml+xml,application/xml", "X-Requested-With":null },
                type: "POST",
    					  data: dataElement,
    				    success: function(result){

  				    	   var attributeInfo = attribute.loadXMLString(result);

  				    	   var labelNode = attribute.queryOneElementChild("label", attributeInfo);
  				    	   var label = attribute.getElementTextContent(labelNode);


    				    	   attribute.updateLabel(label);
    				    	   attribute.setControl(attributeInfo, attribute);
    				    	   attribute.createRemoveButton(attributeInfo);
    				      }
    				  });
    			},
    			updateLabel: function(name){
    				this.labelText.data = name;
    			},
    			setControl: function(attributeInfo, attributeObject){
    				var control = this.getControl(attributeInfo);

    				//Disabled until supported in IE
    				var value = this.getInitialValue(attributeInfo, attributeObject);
    				var disabled = this.fixed(attributeInfo);
    		 	    var pattern = this.pattern(attributeInfo);
    		 	    var alert = this.alert(attributeInfo);
    		 	    var hint = this.hint(attributeInfo);

    		 	    if(control=='input'){


					this.control = new ValidationTextBox({
				 		    name: attributeObject.name,
				 		    disabled: disabled,
				 		    regExp: pattern,
				 		    promptMessage: hint,
				 		    invalidMessage: alert,
				 		    value: value
				 		}, this.controlSpan);

    				}

    				if(control=='select'){
    					this.control = new Select({
    			 		    name: attributeObject.name,
    			 		    options: attributeObject.options(attributeInfo, attributeObject)
    			 		}, this.controlSpan);
    				}
    			},
    			options : function(attributeInfo, attributeObject){
    				var options = new Array();
    				query("option", attributeInfo).forEach(function(node, index, arr){
    					var label = domAttr.get(node, 'label');
    					var value =  domAttr.get(node, 'value');
    					if(value == attributeObject.value){
    						options.push({label: label, value: value, selected: true});
    					}
    					else{
    						options.push({label: label, value: value});
    					}
    				});
    				return options;
    			},

    			getControl : function(attributeInfo){
    				var control = query("control", attributeInfo)
    				if(control[0].firstChild){
    					return control[0].firstChild.data;
    				}
    				else {
    					return 'input'
    				}
    			},
    			getInitialValue : function(attributeInfo, attributeObject){


			    var initialValueNode = this.queryOneElementChild("initial-value", attributeInfo);
			    var initialValue = this.getElementTextContent(initialValueNode);

			    if(attributeObject.value=="" && initialValue){
			    	return initialValue;
			    }
			    else
			    	return attributeObject.value;


    			},

    			fixed : function(attributeInfo){
    				if(this.queryOneElementChild("fixed", attributeInfo)){
    					return true;
    				}
    				else
    					return false;
    			},
    			pattern : function(attributeInfo){

    			    var patternNode = this.queryOneElementChild("pattern", attributeInfo);
    			    var pattern = this.getElementTextContent(patternNode);

    				if(pattern){
    					return pattern;
    				}
    				else {
    					return '^.*$';
    				}
    			},
    			alert : function(attributeInfo){

    				var alertNode = this.queryOneElementChild("alert", attributeInfo);
    			    var alert = this.getElementTextContent(alertNode);
    				if(alert){
    					return alert
    				}
    				else {
    					return 'Invalid Value';
    				}
    			},
    			hint : function(attributeInfo){
    				var hintNode = this.queryOneElementChild("hint", attributeInfo);
    			    var hint = this.getElementTextContent(hintNode);
    				if(hint){
    					return hint
    				}
    				else {
    					return null;
    				}
    			},
    			createRemoveButton: function(attributeInfo){
    				  if(query("required", attributeInfo)[0].firstChild.data!='true'){
    					  this.removeAttributeButton = new Button({
    					      label: 'X'
    						  // iconClass : "dijitEditorIcon
								// dijitEditorIconDelete",
    					    });
    					  domClass.add(this.removeAttributeButton.domNode, 'xrxaRemoveAttributeButton');
    					  domConstruct.place(this.removeAttributeButton.domNode, this.attributeSpan, 'last');
    					  this.connect(this.removeAttributeButton.domNode, "onmouseup", "remove");
    				  }
    			},
    			getName : function(){
    				return this.name;
    			},
    			// TODO: use util. getNamespace
    			getPrefix : function(){
    				var doublePointIndex = this.name.indexOf(':');
    				var prefix
    				if(doublePointIndex >= 0){
    					prefix = this.name.substring(0, doublePointIndex);
    				}
    				else {
    					prefix = null;
    				}
    				return prefix;
    			},
    			// TODO: Destroy
    			getNamespace : function(){
    				 return this.namespace;
    			},
    			getValue : function(){
    				if(this.control){
    					return this.control.value;
    				}
    				else
    					return this.value;
    			},
    			createXMLNode : function(){
    				if(this.getNamespace()){
    					//TODO: document.createAttributeNS() sollte nicht mehr verwendet werden. Verwenden Sie stattdessen element.setAttributeNS().
    					this.xmlNode = win.doc.createAttributeNS(this.getNamespace(), this.name)
    				}
    				else{
    				    this.xmlNode = win.doc.createAttribute(this.name);
    				}
    				this.setAttributeValue();
    			},
    			setAttributeValue : function(){
    				//Das nodeValue-Attribut auf Attributen sollte nicht mehr verwendet werden. Verwenden Sie value stattdessen.
    				//this.xmlNode.nodeValue = this.getValue();
    				this.xmlNode.value = this.getValue();

    			},
    			getPath: function(){
    				  return this.element.getPath() + '/@'+ this.name;
    			},
    			getAttribute : function(element){
    				domConstruct.destroy(this.xmlNode)
    			  	this.createXMLNode();
    			  	element.attributes.setNamedItemNS(this.xmlNode);
    			  	return element;
    			},

    			queryOneElementChild: function(name, node){

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
    	    		  return children[0]
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

    	    	  getElementTextContent: function(node){
    	    		  var content = null;
    	    		  if(node.firstChild){
    	    			  if(node.firstChild.data){
    	    				  content = node.firstChild.data;
    	    			  }
    	    		  }
    	    		  return content;
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
