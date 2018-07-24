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
    "dojo/query",
    "dijit/MenuItem"
], function(declare, query, MenuItem){
    return declare(MenuItem, {
    	constructor : function(params){
    		  this.selection = params.selection;
    		  this.option = params.option;

			  this.label = this.queryContent("label", this.option);
    		  //console.log('this.label', this.label);
    		  //query("label", this.option)[0].firstChild.data;

    		  var namespaceNode = this.queryOneElementChild("namespace", this.option);
    		  var namespace = this.getElementTextContent(namespaceNode);
    			  //query("namespace", this.option)[0].firstChild.data;
    		  if(namespace){
    			  this.namespace = namespace
    		  }
    		  else{
    			  this.namespace = this.selection.annotationControl.namespace;
    		  }

    		  this.name = this.queryContent("name", this.option);

    		 //query("name", this.option)[0].firstChild.data;

    		  //Does firstElementChild work in all Browsers?
    		  //this.element = query("element", this.option)[0].firstElementChild;
    		  elementNode = this.queryOneElementChild("element", this.option);

    		  for(var i=0; i< elementNode.childNodes.length; i++){
    			  var child = elementNode.childNodes[i];
    			  if(child.nodeType==1){
    				  this.element = child;
    				  break;
    			  }

    		  }


    		  this.inherited(arguments);
    	  },
		  
    	 onClick: function(e){
    		 console.log('/////////////////////////////INSERT', this.name,' /////////////////////////////////////////////////////');


    		 if(this.selection.addAnnotationPossible){
    			  this.selection.getContent().insertAnnotation(this.element, this.selection, this.label, this.namespace, this.name);
    		 }
    		 console.log('/////////////////////////////', this.name,' INSERTED/////////////////////////////////////////////////////');
    	  },


    	  queryContent: function(name, node){
    		  var childNode = this.queryOneElementChild(name, node);
    		  var content = this.getElementTextContent(childNode);
    		  return content;
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
    		  return elementChild;
    	  },

    	  getElementTextContent: function(node){
    		  var content = null;
    		  if(node.firstChild){
    			  if(node.firstChild.data){
    				  content = node.firstChild.data;

    			  }
    		  }
    		  return content;
    	  }
    });
});
