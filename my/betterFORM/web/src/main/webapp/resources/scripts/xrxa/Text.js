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
    "dijit/_WidgetBase"
], function(declare, win, _WidgetBase){
    return declare(_WidgetBase, 
    		{
    	  constructor : function(params){	  
    		  //console.log('~~~ Text.constructor', params.xmlNode);	  
    		  this.myDeclaredClass ='xrxa.Text';	
    		  this.xmlNode = params.xmlNode;
    		  this.dummy = params.dummy;	  
    		  if(this.dummy==true){
    			  this.string = '\u00a0';
    		  }
    		  else{
    			  this.string = params.string; 
    		  }
    		  this.parentElement = params.parent;	  
    		  this.serializer = new XMLSerializer();
    	  },
    	  

    	  postCreate : function()
    	  {	
    		  if(this.xmlNode){
    			  //Does this cause an erroro in IE cause a xml-textnode can't be inserted into a html-node?
    			  //this.domNode = this.xmlNode.cloneNode(true);
    			  //so better do it like this:
    			  var text = this.xmlNode.data;
    			  this.domNode = win.doc.createTextNode(text);
    			  
    		  }
    		  else if(this.string){
    			  this.domNode = win.doc.createTextNode(this.string);
    		  } 
    		  
    		  
    		  //this.domNode.addEventListener ('DOMNodeRemoved', this.deleted, false);	 
    		  this.connect('DOMNodeRemoved', this.domNode, this.deleted);	 
    		  
    	  },
    	  deleted: function(event) {	 
    		  //in here this is the deleted domNode not the Text object 
    		  //console.log('Text.deleted', this);
    		  var content = dijit.byId(event.relatedNode.id);
    		  content.removeObjects.push(this);
    		  content.removeDeletedObjects();
    		 
    	  }, 
    	  getXMLNode : function(){ 
    		  this.updateXMLNode();	  
    		  return this.xmlNode;	  
    	  },  
    	  updateXMLNode : function(){	  
    		  if(this.isDummy()){
    			  console.log('---- Destroy Dummy------');
    			  this.xmlNode = null;
    		  }
    		  else{
    			  this.xmlNode = this.domNode.cloneNode(true);
    			  //this.xmlNode.data = this.xmlNode.data.replace("/u00a0/g", ' ');
    		  }	  	 
    	  },  
    	  //only for first and last text of annotationControl
    	  getOuterXML : function(){	  
    		  if(this.isDummy()){
    			  return '';
    		  }	  
    		  else{
    			  if(this.xmlNode){
    				  return this.xmlNode.data
    				  //var outerXML  = this.serializer.serializeToString(this.xmlNode);
    				  //return outerXML.replace("/u00a0/g", '');  
    			  }
    		  }
    	  },
    	  isDummy : function(){
    		  if(this.dummy==true & this.domNode.data=="\u00a0"){
    			  return true;
    		  }
    		  else{
    			  return false;
    		  }
    	  },
    	  setParent: function(newParent){
    		  this.parentElement = newParent;
    	  },  
    	  getParent: function(){
    		  return this.parentElement;
    	  }
   });
});


