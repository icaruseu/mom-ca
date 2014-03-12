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
    "dojo/_base/sniff",
    "dojo/has",
    "dojo/on",
    "dojo/dom-construct",
    "dojo/dom-class",
    "dojo/dom-style",
    "dijit/form/Button",
    "dijit/Dialog",
    "dijit/form/SimpleTextarea" 
    ], 
function(declare, sniff, has, on, domConstruct, domClass, domStyle, Button, Dialog, SimpleTextarea){
    return declare(Dialog, {
    	constructor : function(params){    		  
    		  console.log('~~~PasteDialog.constructor.params', params);
    		  this.annotationControl = params.annotationControl;  
    		  this.inherited(arguments);
    	  },
    	  postCreate : function(){		 
    		  this.inherited(arguments);  
    		  this.createTextarea();
    		  this.createOk();
    	  },
    	  updateUI : function(ui){
    		  /*TODO var title = dojo.query("text[id='insert-text']", ui)[0].firstChild.data;
    		  var text = dojo.query("text[id='inserting-textbox-below']", ui)[0].firstChild.data;
    		  var ok = dojo.query("text[id='ok']", ui)[0].firstChild.data    		  ;
    		  this.set('title', title);
    		  this.div.innerHTML = text;
    		  this.insertButton.innerHTML = ok;*/
    	  },
    	  createTextarea : function(){

    		  this.textarea = new SimpleTextarea({
    			    name: "insertionTextarea"
    		  });    
    		  this.div = domConstruct.create('div', {innerHTML:"Bitte Verwenden Sie für das Einfügen von Texten das untere Textfeld.<br /> For inserting text please use the textbox below:"}, this.domNode);
    		  domClass.add(this.textarea.domNode, 'xrxaInsertTextarea');
    		  domStyle.set(this.textarea.domNode, 'width', '550px');
    		  domStyle.set(this.textarea.domNode, 'height', '500px');
    		  domConstruct.place(this.textarea.domNode, this.domNode); 
    		  //for the right position
    		  var div = domConstruct.create('div', {}, this.domNode);
    	  },
    	  createOk : function(){
    		  this.insertButton = domConstruct.create('button', {}, this.domNode);
    		  domStyle.set(this.insertButton, 'float', 'right');
    		  this.insertButton.innerHTML = 'OK';
    		  //on(this.insertButton, "click", this.annotationControl, 'insertText'); 
    		  //on(this.insertButton, "click", this, 'hide');     		
    		  dojo.connect(this.insertButton, "onclick", this.annotationControl, 'insertText'); 
    		  dojo.connect(this.insertButton, "onclick", this, 'hide');     		  
    	  },
    	  paste : function(){
    		  this.annotationControl.insertText();
    	  },
    	  getText : function(){
    		  console.log('PasteDialog.textarea,getText', this.textarea);
    		  return this.textarea.get('value');
    	  },
    	  clear : function(){
    	    return this.textarea.set('value', '');
    	  },
    	  
    	  show : function(){	
    		  
    		  
    		  this.inherited(arguments);    		  
    		  
    		  if(has('chrome')){
    			  this.textarea.domNode.focus();
    				   var dialog = this;
    					  setTimeout(function(){
    						  dialog.paste();
    						  dialog.hide();
    					  }, 0);
    		  }
    		  else{
				  this.textarea.domNode.focus();  
				  setTimeout(function(){},0);
    		  }

    		},
    		
    		hide : function(){	
    		  this.inherited(arguments);
    		}
    });
});


  
  
  

