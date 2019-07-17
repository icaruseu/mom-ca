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
    "dojo/dom-class",
    "dojo/dom-attr",
    "dijit/_WidgetBase",
    "dijit/_editor/range" 
	], function(declare, domClass, domAttr, _WidgetBase, Range){
	    return declare(_WidgetBase, {
	    	constructor : function(params){
	    		  this.annotationControl = params.annotationControl;
	    		  this.addAnnotationPossible = true;	  
	    		  this.selectionStartIndex  = -1;
	    		  this.selectionEndIndex = -1;
	    		  //TODO: set Default Selection
	    	  },  
	    	  update: function(){  
	    		  console.log('Selection.update');
	    		  this.setHTMLSelection();	  
	    		  this.setAnnotationPossible();	  
	    		  this.setTextInsertionPossible();
	    		  this.setStartAndEndTextNodes();
	    		  this.selectContentObject();	
	    		  //Könnte mit setSelectedAnnotations zusammengefasst werden!!!
	    		  this.setIndexOfSelectionStartAndSelectionEnd();
	    		  this.setSelectedAnnotations();
	    		  this.setStartAndEndSeletionPosition();
	    		  this.setStartAndEndSeletionText();	
	    		  this.cutText();
	    		  this.setInnerXML();
	    	  },	    	  
	    	  setHTMLSelection: function(){
	    		  this.selection = Range.getSelection(this.annotationControl.window);	
	    		  this.anchor = this.selection.anchorNode;
	    		  this.focus = this.selection.focusNode;	 
	    	  },  
	    	  //checks if the selection would create well-formed XML, (if all selected tags have their partner in the selection too)
	    	  setAnnotationPossible: function(){ 
			console.log("setAnnotationPossible: " + this.anchor.parentNode + this.focus.parentNode);
	if(!this.anchor) {
	    		  if(domClass.contains(this.anchor.parentNode, 'StartTag') | domClass.contains(this.anchor.parentNode, 'EndTag') | domClass.contains(this.anchor.parentNode, 'Attributes') | domClass.contains(this.anchor.parentNode, 'Attribute')| domClass.contains(this.anchor.parentNode, 'AttributeName') | domClass.contains(this.anchor.parentNode, 'AttributeValue')| domClass.contains(this.anchor.parentNode, 'AttributeValueInput')){
	    			  this.addAnnotationPossible = true; 
	    		  }
	    		  else if (this.anchor.parentNode!=this.focus.parentNode){
	    			  	this.addAnnotationPossible = true;
	    			 }
	    		  else{
	    			 if (this.anchor.nodeType!=3){			 
	    				 this.addAnnotationPossible = true;
	    			 }
	    			 else{
	    				 if (this.focus.nodeType!=3){
	    					 this.addAnnotationPossible = true;
	    				 }
	    				 else{
	    					 this.addAnnotationPossible = true;
	    				 }
	    			 }
	    		 }
	    	  } else {this.addAnnotationPossible = true;}
		console.log("setAnnotationPossible: " + this.addAnnotationPossible);
		},
	    		setTextInsertionPossible: function(){  	  
	    			  if(this.anchor != this.focus | domClass.contains(this.anchor.parentNode, 'StartTag') | domClass.contains(this.anchor.parentNode, 'EndTag') | domClass.contains(this.anchor.parentNode, 'Attributes') | domClass.contains(this.anchor.parentNode, 'Attribute')| domClass.contains(this.anchor.parentNode, 'AttributeName') | domClass.contains(this.anchor.parentNode, 'AttributeValue')| domClass.contains(this.anchor.parentNode, 'AttributeValueInput')){
	    				  
	    				  this.annotationControl.pasteDialog.textarea.domNode.disabled='disabled';
	    				  //this.annotationControl.toolbar.insertText.disableInsertButton();
	    			  }
	    			  else{
	    				  domAttr.remove(this.annotationControl.pasteDialog.textarea.domNode, 'disabled');
	    				  //this.annotationControl.toolbar.insertText.enableInsertButton();
	    			  }
	    		  },
	    	  leftToRight: function(anker ,focus){
	    		  var check=false;
	    	      current = anker;
	    	          var sibling ; 
	    	          while(current.nextSibling!=null){             
	    	        	  sibling = current.nextSibling;
	    	              if (sibling==focus){
	    	                  check=true;
	    	                  break;
	    	              }
	    	              current=sibling;
	    	          }
	    	      return check;      
	    	  }, 
	    	  //get textnode the seletion starts in and the textnode the seletion ends in
	    	  //not anchor and focus if selection started on the right side and moved to left
	    	  setStartAndEndTextNodes: function(){
	    		  if(this.addAnnotationPossible){
	    			  if(this.focus==this.anchor){
	    				  this.startNode = this.endNode = this.focus;
	    			  }
	    			  else{
	    				  if(this.leftToRight(this.anchor, this.focus)){
	    					 
	    					  this.startNode = this.anchor;
	    					  this.endNode = this.focus;
	    				  }
	    				  else{
	    					  this.startNode = this.focus;
	    					  this.endNode = this.anchor;
	    				  }			  
	    			  }
	    		  }
	    		  else{
	    			  this.startNode = null;
	    			  this.endNode = null;
	    		  }
	    	  },
	    	  setIndexOfSelectionStartAndSelectionEnd: function(){
	    		  if(this.startNode!=null && this.endNode!=null && this.content){
	    			  //console.log('Selection.setIndexOfSelectionStartAndSelectionEnd', this.startNode, this.endNode);
	    			  for(var i=0; i<this.content.childObjects.length; i++){
	    				 
	    				  //if(this.content.childObjects[i].domNode.data==this.startNode.data){	
	    				  if(this.content.childObjects[i].domNode==this.startNode){	
	    					  this.selectionStartIndex = i;
	    					  //console.log('Selection.setIndexOfSelectionStartAndSelectionEnd.selectionStartIndex', i);
	    				  }
	    		 
	    				  //if(this.content.childObjects[i].domNode.data==this.endNode.data){	
	    				  if(this.content.childObjects[i].domNode==this.endNode){	
	    					  this.selectionEndIndex = i;
	    					  //console.log('Selection.setIndexOfSelectionStartAndSelectionEnd.selectionEndIndex', i);
	    				  }
	    			  }
	    		  }
	    	  },
	    	  setSelectedAnnotations: function(){
	    		  
	    		  this.selectedAnnotations = new Array();	  
	    		  	  if(this.content){
	    		  		 for (i=this.selectionStartIndex+1; i<this.selectionEndIndex; i++){
	    					  this.selectedAnnotations.push(this.content.childObjects[i]);
	    				  }
	    		  	  }
	    		  },
	    	   //the content object that is responsible for the insertion of a new annotation
	    	   selectContentObject: function(){
	    		  
	    		  if(this.startNode!=null){		
	    			  this.content = dijit.byId(this.startNode.parentNode.id);		
	    		  }
	    		  else{
	    			  this.content =  this.annotationControl.content
	    		  }
	    	  },
	    	  setStartAndEndSeletionPosition: function(){
	    		  //console.log('Selection.setStartAndEndSeletionPositiont.addAnnotationPossible', this.addAnnotationPossible);
	    		  if(this.addAnnotationPossible){
	    			  if(this.focus==this.anchor){
	    				  if(this.selection.anchorOffset>this.selection.focusOffset){
	    					  this.startPosition = this.selection.focusOffset;
	    					  this.endPosition = this.selection.anchorOffset;
	    				  }
	    				  else{
	    					  this.startPosition = this.selection.anchorOffset;
	    					  this.endPosition = this.selection.focusOffset;
	    				  }
	    			  }
	    			  else{
	    				  if(this.startNode==this.anchor){
	    					  this.startPosition = this.selection.anchorOffset;
	    					  this.endPosition = this.selection.focusOffset;
	    				  }	
	    				  else{
	    					  this.startPosition = this.selection.focusOffset;
	    					  this.endPosition = this.selection.anchorOffset;
	    				  }
	    			  }	  
	    		  }
	    		  else{
	    			  
	    			  this.startPosition = null;
	    			  this.endPosition = null; 			  
	    		  }
	    		  
	    	  },
	    	  setStartAndEndSeletionText: function(){
	    		  if(this.addAnnotationPossible){
	    			  this.startText = this.startNode.data;
	    			  this.endText = this.endNode.data;
	    		  }
	    		  else{
	    			  this.startText = "";
	    			  this.endText = "";  
	    		  }
	    	  },
	    	  cutText: function(){
	    		  
	    		  this.startTextBefore = this.startText.substr(0, this.startPosition);
	    		  this.endTextAfter = this.endText.substr(this.endPosition, this.endText.length-this.endPosition);
	    		 
	    		  if(this.startNode!=this.endNode){
	    			 
	    			 this.startTextAfter = this.startText.substr(this.startPosition, this.startText.length)
	    			 this.endTextBefore = this.endText.substr(0, this.endPosition);		 
	    		  }
	    		  else{
	    				 this.startTextAfter = this.startText.substr(this.startPosition, this.endPosition-this.startPosition)
	    				 this.endTextBefore = '';
	    		 }
	    	  },
	    	  setInnerXML: function(){	    		  
	    		  this.innerXML = this.startTextAfter;
	    		  
	    		  for(var i=0; i<this.selectedAnnotations.length; i++){		
	    			  this.innerXML += this.selectedAnnotations[i].getOuterXML();
	    		  }	  
	    		  this.innerXML += this.endTextBefore
	    		  console.log('Selection.setInnerXML updated:', this.innerXML);
	    	  },
	    	  //called in  Options
	    	  getInnerXML: function(){
	    		  return this.innerXML;	 
	    	  },
	    	  //called in  Options
	    	  getContent: function(){
	    		  return this.content;	 
	    	  },  
	    	  //called in Toolbar
	    	  getSelectedAnnotations: function(){	  
	    		  return this.selectedAnnotations;
	    	  },  
	    	  //called in Content.insertAnnotation
	    	  getSelectionStartIndex: function(){
	    		  return this.selectionStartIndex;
	    	  },  
	    	  //called in Content.insertAnnotation
	    	  getSelectionEndIndex: function(){
	    		  return this.selectionEndIndex;
	    	  }
	    });	  
	});


