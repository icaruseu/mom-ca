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
    "dojo/dom-style",
    "dojo/dom-construct",
    "dojo/dom-class",
    "dojo/dom-attr",
    "dijit/_WidgetBase",
    "scripts/xrxa/Content"
], function(declare, domStyle, domConstruct, domClass, domAttr, _WidgetBase){
    return declare(_WidgetBase,
    		{
		  	  constructor : function(params){
		  		  this.id = params.id;
		  		  this.element = params.element;
		  		  this.label = params.labelname;

		  	  },
		  	  postCreate : function(){
		  		  this.domNode = this.createStartTagSpan();
		  		  this.domNode.addEventListener ('DOMNodeRemoved', this.tagDeleted, false);
		  	  },
		  	  createStartTagSpan : function(){
		  		  this.button = domConstruct.create("span" , {contenteditable: "false"});
		  		  domClass.add(this.button, 'xrxaStarttag');
		  		  this.createLabelSpan();
		  		  return this.button;
		  	  },
		  	  createLabelSpan: function(){
		  			 this.labelSpan = domConstruct.create("span");
		  			 domClass.add(this.labelSpan, 'xrxaTagLabel');
		  			 this.labelSpan.innerHTML = this.label;
		  			 domAttr.set(this.labelSpan, 'title', 'Click to edit Annotation');
		  			 this.connect(this.labelSpan, "onmouseup", "onClick");
		  			 domConstruct.place(this.labelSpan, this.button, 'first');
		  	  },
		  	  setLabel: function(name){
		  			 this.labelSpan.innerHTML = name;
		  	  },
		  	  tagDeleted: function(event) {
		  		  if(event.relatedNode.id){
		  	    	  var content = dijit.byId(event.relatedNode.id);
		  	    	  var annotation = content.element;
		  	    	  annotation.parentElement.content.removeAnnotation(annotation);
		  	      }
		  	  },
		  	  onClick: function(){
		  		  this.element.attributeDialog.show();
		  	  },
		  	  toggleLabelDisplay: function(){
		  		  if(domStyle.get(this.labelSpan, 'display')!='none'){
		  			  this.hide();
		  		  }
		  		  else if(domStyle.get(this.labelSpan, 'display')=='none'){
		  			  this.show();
		  		  }
		  	  },
		  	  hide: function(){
		  		  domStyle.set(this.labelSpan, 'display', 'none');
		  		  domStyle.set(this.button, 'padding', '1px');
		  	  },
		  	  show : function(){
		  		  domStyle.set(this.labelSpan, 'display', 'inline');
		  	  }
		}
    );
});
