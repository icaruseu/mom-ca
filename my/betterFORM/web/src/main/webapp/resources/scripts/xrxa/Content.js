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
    "dojo/dom-style",
    "dijit/_WidgetBase",
    "scripts/xrxa/Annotation",
    "scripts/xrxa/Text"
    ],
    function(declare, win, domConstruct, domClass, domStyle, _WidgetBase, Annotation, Text){
    	return declare(_WidgetBase, {

    		constructor : function(params){

    		  console.log('Content.constructor');

    		  this.id = params.id;



    		  //an xml-dom node that's content this objekt represent's
    		  this.element = params.element;

  			  this.htmlTag = params.htmlTag;
  			  this.tagLabelDisplay = 'inline';

  			  //deprecated way
  			  this.selectedText = params.selectedText;
  			  this.selectedAnnotations  = params.selectedAnnotations;
  			  this.endText  = params.endText;

  			  this.childObjects = new Array();
			  this.removeObjects = new Array();
    		},
		  	  postCreate : function(){
		  		this.createContentSpan();

		  		if(this.selectedText){
		  			  this.createSelectedContent();
		  		  }
		  		  else{
		  			  this.build();
		  		  }
		  	  },

		  	  updateUI : function(ui){
		  		  for(var i=0; i<this.childObjects.length; i++){
		  			if(this.childObjects[i].myDeclaredClass=='xrxa.Annotation'){
		  				this.childObjects[i].updateUI(ui);
		  			}
		  		  }
		  	  },

		  	  //span element that contains the ui-content
		  	  createContentSpan : function(){
		  		  if(!this.htmlTag){
		  			  this.htmlTag = 'span';
		  		  }
		  		  this.domNode = domConstruct.create(this.htmlTag, {id: this.id});
		  		  domClass.add(this.domNode, 'xrxaContent');
		  	  },

		  	  //creates the Objekt-Strukture out of the xml-node of the element
		  	  build : function (){

		  		  console.log('////////////////  START BUILD ', this.element.name, '//////////////////');

		  		  this.previous = '';
		  		  		for(var i=0; i<this.element.xmlNode.childNodes.length; i++){


		  				  var childNode = this.element.xmlNode.childNodes[i];

		  				  //ELEMENT-CHILD --> ANNOTATION
		  				  if(childNode.nodeType==1){

		  					  //TEXTDUMMY AT THE BEGINNING OR BETWEEN ANNOTATIONS
	  					  	 if(i==0 || this.previous == 'element'){
	  							  this.createTextDummy();
	  						 }

  					  	 	var child = new Annotation({xmlNode: childNode, parentElement: this.element});
  				   	  	 	this.pushChild(child);

	  				   	  	 //TEXTDUMMY AT THE END
	  				   	  	 if(i==(this.element.xmlNode.childNodes.length-1)){
	  				   	  		 this.createTextDummy();
	  						 }
	  				   	  	 this.previous = 'element';
	  				  	  }
		  				  //TEXT_CHILD
	  				  	  else if(childNode.nodeType==3){
	  				  		  child = new Text({xmlNode: childNode, parentElement:this.element});
	  				  		  this.pushChild(child);
	  				  		  this.previous = 'text';
	  				  	  }
		  			  }
		  			  //NO CONTENT: EMPTY --> TEXTDUMMY
		  			  if(this.element.xmlNode.childNodes.length==0){
		  				  this.createTextDummy();
		  			  }
		  			console.log('////////////////  END BUILD ', this.element.name, '//////////////////');
		  		},

		  		//push the child-object into the array and it's html-domNode into the ui
		  		pushChild: function(child){
		  			this.childObjects.push(child);
		  			domConstruct.place(child.domNode, this.domNode, "last");
		  		},

		  		//text-dummys are inserted ' '-strings to enable that the user can click into empty Annotations or in front of or behind an annotation
		  		createTextDummy: function(){
		  			 var dummy = new Text({dummy: true, parentElement:this.element});
		  			 this.pushChild(dummy);
		  		},

		  		//used only for debugging
		  		showChildObjects: function(){
		  			var show = new Array();
		  				for(var i=0; i<this.childObjects.length; i++){
		  					console.log('--->',this.childObjects[i].myDeclaredClass);
		  					if(this.childObjects[i].myDeclaredClass=='xrxa.Text'){
		  						show.push(this.childObjects[i].domNode.data);
		  					}
		  					else if(this.childObjects[i].myDeclaredClass=='xrxa.Annotation'){
		  						show.push(this.childObjects[i].name);
		  					}

		  				}
		  			return show;
		  		},

		  		//If all the Content has been deleted, a textdummy is created onBlur to enable to click into the content again
		  		handleEmpty: function(){

		  			if(this.childObjects.length==0  || (this.childObjects.length==1 && this.childObjects[0].myDeclaredClass=='xrxa.Text' && (this.childObjects[0].domNode.data==' ' || this.childObjects[0].domNode.data==''))){
		  				this.childObjects = new Array();
		  				this.createTextDummy();
		  			}
		  		},

		  		//TODO: Check if ther's a native dojo/javascript method to get the index
		  		  getIndex: function(childobject){
		  			  for(var i=0; i<this.childObjects.length; i++){
		  				  if(this.childObjects[i]==childobject){
		  					  return i
		  				  }
		  			  }
		  		  },

		  		  //called in Text.deleted
		  		  deleteChildObject: function(child){
		  				index = this.getIndex(child);
		  	  	  		this.childObjects.splice(index, 1);
		  		  },

		  		  createSelectionText: function (startText){

		  			  startTextNode= win.doc.createTextNode(startText);
		  	  		  startTextObject = new Text({xmlNode: startTextNode, parentElement:this.element});
		  	  		  this.childObjects.push(startTextObject);
		  	  		  domConstruct.place(startTextObject.domNode, this.domNode, "last");
		  		  },

		  		  createEndOfSelectionText: function (endText){
		  			  endTextNode= win.doc.createTextNode(endText);
		  			  endTextObject = new Text({xmlNode: endTextNode, parentElement:this.element});
		  			  this.childObjects.push(endTextObject);
		  			  domConstruct.place(endTextObject.domNode, this.domNode, "last");
		  		  },

		  		  update : function(){
		  			  console.log('///////////START UPDATE ' , this.element.nodeName , '////////////');
		  			  //element updateXML node also handels the update of the Attributes not only the content
		  			  this.element.updateXMLNode()
		  		  	  this.clean();
		  		  	  this.build();
		  		  	  this.element.getAnnotationControl().onAnnotationsChanged();
		  		  	  console.log('///////////END UPDATE ' , this.element.nodeName , '////////////');
		  		    },


		  		  updateXML : function(){
		  			  console.log('///////START UPDATEXML ' , this.element.nodeName , '////////');
		  			  this.preprocessObjects();
		  			  for(var i=0; i<this.childObjects.length; i++){
		  		  		var xmlChild = this.childObjects[i].getXMLNode();
		  	    		if(xmlChild){
		  	    			domConstruct.place(xmlChild, this.element.xmlNode);

		  	    		}
		  			  }
		  			  console.log('////////END UPDATEXML ' , this.element.nodeName , '////////');
		  			  //console.log('Content.updateXML', this.element.xmlNode);
		  		  },

		  		  getInnerXML : function(){
		  			  this.preprocessObjects();
		  			  var innerXML = ''
		  			  for(var i=0; i<this.childObjects.length; i++){
		  		    			innerXML = innerXML + this.childObjects[i].getOuterXML();
		  			  }
		  			  return innerXML;
		  		  },

		  		  preprocessObjects: function(){
		  			  this.insertNonXRXAText();
		  			  while(this.joinTextSiblings()){}
		  		 },

		  		  removeDeletedObjects: function(){

		  			  var remove = new Array();
		  			  //Find the Object of the deleted textNode and store it in the remove array
		  			  for(var i=0; i<this.childObjects.length; i++){
		  					 for(var j=0; j<this.removeObjects.length; j++){
		  						 if(this.childObjects[i].domNode==this.removeObjects[j]){
		  							 remove.push(i);
		  						 }
		  				  }
		  			  }
		  			  for(var i=0; i<remove.length; i++){
		  				  this.childObjects.splice(remove[i], 1);
		  			  }
		  			  this.removeObjects = new Array();

		  		  },

		  		  insertNonXRXAText : function(){
		  			  if (this.childObjects.length==0 & this.domNode.childNodes.length!=0){
		  					var insert = new Array();
		  					var nonXRXA = this.domNode.cloneNode(true).childNodes

		  					domConstruct.empty(this.domNode);

		  					for(var i=0; i<nonXRXA.length; i++){

		  						var node = nonXRXA[i];
		  						if(node.nodeType==3){
		  							insertText =  new Text({xmlNode: node, parentElement:this.element});
		  							insert.push(insertText);
		  						}
		  						else{
		  						}
		  				    }
		  					for(var i=0; i<insert.length; i++){
		  						this.pushChild(insert[i]);
		  					}
		  				}
		  		  },

		  		   //When removing an annotation several textnodes are following each other. These are put together to one textnode within one text-object
		  		  joinTextSiblings : function(){
		  			    for(var i=0; i<this.childObjects.length; i++){
		  			       	if(this.childObjects[i].myDeclaredClass=='xrxa.Text'){
		  			    		j=i+1;
		  			    		if(this.childObjects[j]){
		  				    		if(this.childObjects[j].myDeclaredClass=='xrxa.Text'){
		  				    			jointText = this.childObjects[i].domNode.nodeValue + this.childObjects[j].domNode.nodeValue;

		  				    			jointTextNode = win.doc.createTextNode(jointText);

		  				  			  	jointTextObject =  new Text({xmlNode: jointTextNode, parentElement:this.element});
		  				  			  	this.childObjects.splice(i, 2, jointTextObject);

		  				  			  	return true;
		  				    		}
		  			    		}
		  			    	}
		  			    }
		  			    return false;
		  		  },



		  		    //called in xrxa.DeleteElementButton
		  		    //called in xrxa.StartTag.tagDeleted
		  		    removeAnnotation : function(annotation){
		  		      console.log('/////////////////////////////REMOVE', this.element.nodeName,' /////////////////////////////////////////////////////');
		  		      var index = this.getIndex(annotation);
		  		      if(annotation.content.childObjects[0]){
		  			  	  var textToAdopt = annotation.content.childObjects[0];
		  			  	  	//Remove Textdummy
		  			  	    //Nessassary??? Should also been removed at when updating XML
		  			  	  	if(textToAdopt.isDummy()){
		  			  	  		this.childObjects.splice(index, 1);
		  			  	  	}
		  			  	  	//Keep contained Text as Child of Parent Element
		  			  	  	else{
		  			  	  		textToAdopt.setParent(this.element);
		  			  	  		this.childObjects.splice(index, 1, textToAdopt);
		  			  	  	}
		  		  	  }
		  		  	  else{
		  		  		this.childObjects.splice(index, 1);
		  		  	  }
		  		      this.update();
		  		    },



		  		    //deletes the domNode and all childobjects of the element
		  			  clean : function(){
		  				  //Destroy all inner Widgets
		  				  for(var i=0; i<this.childObjects.length; i++){
		  					  this.childObjects[i].destroyRecursive();
		  				  }
		  				  this.childObjects = new Array();
		  				  //should be empty from destroyRecursive, but just to be sure
		  				  domConstruct.empty(this.domNode);

		  			  },
		  		    //called in xrxa.InsertAnnotationItem
		  		    insertAnnotation : function(element, selection, label, namespace, name){


		  		  	  	//TEXT IN FRONT OF THE SELECTION/ANNOTATION
		  		  	  	textInFrontOfAnnotation= win.doc.createTextNode(selection.startTextBefore);



		  		  	  	if(textInFrontOfAnnotation.data==''){
		  		  	  		var textObjectInFrontOfAnnotation = new Text({dummy: true, parentElement:this.element});
		  		  	  	}
		  		  	  	else{
		  		  	  		textObjectInFrontOfAnnotation = new Text({xmlNode: textInFrontOfAnnotation, parentElement:this.element});
		  		  	  	}



		  		  	  	//SELECTION/ANNOTATION
		  		  	  	//var annotation = new xrxa.Annotation({startText: selection.startTextAfter, containedObjects: selection.selectedAnnotations, endText: selection.endTextBefore, namespace: namespace, labelname: label, name: name, parentElement: this.element});
		  		  	  	var annotation =  new Annotation({xmlNode: element, parentElement: this.element});



		  		  	  	//TEXT BEHIND THE SELECTION/ANNOTATION
		  		  	  	var textBehindAnnotation= win.doc.createTextNode(selection.endTextAfter);



		  		  	  	if(textBehindAnnotation.data==''){
		  		  	  		textObjectBehindAnnotation = new Text({dummy: true, parentElement:this.element});
		  		  	  	}
		  		  	  	else{
		  		  	  		textObjectBehindAnnotation = new Text({xmlNode: textBehindAnnotation, parentElement:this.element});
		  		  	  	}




		  		  	  	//selected Objects are deleted from the Array and the new Objects are inserted
		  		  	  	selectionStartIndex = selection.getSelectionStartIndex();
		  		  	  	selectionEndIndex = selection.getSelectionEndIndex();
		  		  	  	numDeleteObjects = selectionEndIndex-selectionStartIndex+1;

		  		  	  	//update the node array
		  		  	  	this.childObjects.splice(selectionStartIndex, numDeleteObjects, textObjectInFrontOfAnnotation, annotation, textObjectBehindAnnotation);
		  		  	  	//update the content object

		  		  	  	this.update();
		  		    },

		  		    insertText: function(selection, text){

		  		  	  textContent = selection.startTextBefore + text + selection.endTextAfter;
		  		  	  textNode= win.doc.createTextNode(textContent);

		  		  	  textChild = new Text({xmlNode: textNode, parentElement:content.element});

		  		  	  this.childObjects.splice(selection.getSelectionStartIndex(), 1, textChild);
		  		  	  this.update();

		  		    },

		  		    createSelectedContent: function(){



		  		      //Selected Text in front of selected Annotation or just the selected Text if no Annotation is selected
		  	    	  if(this.selectedText!=''){
		  	    		  this.createSelectionText(this.selectedText);
		  	    	  }

		  		  	  //selected Annotations
		  		  	  for(var i=0; i<this.selectedAnnotations.length; i++){
		  	  		  		this.selectedAnnotations[i].parentElement = this.element;
		  	  		  		this.pushChild(this.selectedAnnotations[i]);
		  		  	 }

		  		  	  //Selected Text behind selected Annotaions
		  		  	  if(this.endText!=''){
		  		  		  this.createEndOfSelectionText(this.endText);
		  		  	  }
		  		    },

		  		    //called in DeleteButton
		  		    countContainedAnnotations : function(){
		  	          var count = 0;
		  	          for(var i=0; i<this.childObjects.length; i++){
		  	                if(this.childObjects[i].myDeclaredClass=='xrxa.Annotation'){
		  	                  count++;
		  	                }
		  	          }
		  	         return count;
		  	         },


		  	         toggleLabelDisplay : function(){
		  	        	 if(this.tagLabelDisplay!='none'){
		  	        		 this.tagLabelDisplay='none';
		  		       	  }
		  		       	  else if(this.tagLabelDisplay=='none'){
		  		       		this.tagLabelDisplay='inline';
		  		       	  }

		  	        	 for(var i=0; i<this.childObjects.length; i++){
		  	        		 if(this.childObjects[i].myDeclaredClass=='xrxa.Annotation'){
		  	        			 this.childObjects[i].content.toggleLabelDisplay();
		  	        			 this.childObjects[i].toggleLabelDisplay();

		  	 				}

		  	 			}
		  	         }

    	});
	});
