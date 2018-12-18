
define([
    "dojo/_base/declare",
    "dojo/dom-class",
    "dojo/query",
    "dijit/form/Button" 
    ], 
    function(declare, domClass, query, Button){	
    	return declare(Button, {   	
    		constructor : function(params){
    			  console.log('InsertAttributeButton.constructor'); //, this.attributeOption);
    			  this.attributeOption = params.attributeOption;
    			  
	   			  this.attributes = params.attributes;	   			  
	   			  

	   			  this.namespace = this.queryContent("namespace", this.attributeOption); 	   			 
	   			  this.name = this.queryContent("name", this.attributeOption); 
	   			  this.label = '+ ' + this.queryContent("label", this.attributeOption); 
	   			  
	   			  //query("label", this.attributeOption)[0].firstChild.data;  			  	  
	   			  this.inherited(arguments);   
    		  },
    		   postCreate : function(){	
    			   domClass.add(this.domNode, 'xrxaInsertAttributeButton');
	   		  },
	   		  onClick: function(e){
	   			  console.log('////////////////////////////INSERT ATTRIBUTE START////////////////////////////////////////////');		   			  
	   			  this.attributes.insertAttribute(this.attributeLabel, this.namespace, this.name);
	   			  console.log('////////////////////////////INSERT ATTRIBUTE END////////////////////////////////////////////');	
	   		  },
	   		  
	   		  	queryContent: function(name, node){
	   		  		return this.getElementTextContent(this.queryOneElementChild(name, node));
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
		    		  if(node){
		    			  if(node.firstChild){
			    			  if(node.firstChild.data){
			    				  content = node.firstChild.data;
			    			  }    			  
			    		  }
		    		  }		    		  
		    		  return content;
		    	  }
    	});	  
	});