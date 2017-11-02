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
    "dojo/dom-construct",
    "dojo/query",
    "dijit/_WidgetBase",
    "dijit/MenuBar",
    "dijit/Menu",
    "dijit/PopupMenuBarItem",
    "scripts/jquery/jquery",
    "scripts/xrxa/InsertAnnotationItem"
], function(declare, domConstruct, query, _WidgetBase, MenuBar, Menu, PopupMenuBarItem,jquery, InsertAnnotationItem){
    return declare(_WidgetBase, {
    	constructor : function(params){
    		this.id = params.id;
    	    this.name = params.name;
    		this.annotationControl = params.annotationControl;
    	  },
    	  postCreate : function(){
    		  this.domNode =  domConstruct.create('div', {id: this.id});
    		  this.connect(this.domNode, "onmouseenter", "onMouseEnter");
    		  this.addControls();


    		  //Only Update on Click ??
    		  this.update();
    	  },
    	  addControls: function(){
    		  this.addMenu();
    	  },
    	  addMenu : function(){
    		  this.menuBar = new MenuBar();
    		  domConstruct.place(this.menuBar.domNode, this.domNode, 'last');
    	      this.menuBar.startup();
    	  },
    	  update: function(){
    		  this.updateMenu();
    	  },
    	  updateMenu : function(){


    		  var defualtSubMenu = this.defualtSubMenu;
    		  var selection = this.annotationControl.selection;
    		  var id = this.id;
    		  var menuBar = this.menuBar;
    		  var header = this;
    		  var contentObject = this.getContent();
    		  //Clear Menu if no annotation is possible due to the Selection
    		  if(this.annotationControl.selection.addAnnotationPossible==false){
    			  domConstruct.empty(menuBar.domNode);
    		  }
    		  else{


    			  var pathElement = '<path>' + contentObject.element.getPath() + '</path>';
    			  var contentElement = '<content ' + this.annotationControl.prefix + ':dummy="" xmlns:' + this.annotationControl.prefix +'="'+ this.annotationControl.namespace +'">' + contentObject.getInnerXML() + '</content>';
    			  var xsdlocElement = '<xsdloc>' + this.annotationControl.xsdloc + '</xsdloc>';
    			  var selectionElement = '<selection>' + selection.getInnerXML() + '</selection>';
    			  var dataElement = '<data>'+ pathElement + contentElement + xsdlocElement + selectionElement + '</data>';
            var xhr = new XMLHttpRequest();
            var url = this.annotationControl.services + "?service=get-menu";
            xhr.open("POST",url);

            xhr.setRequestHeader("Content-Type", "text/xml");

            xhr.onreadystatechange = function () {
              if (xhr.readyState == 4) {
                if (xhr.status == 200) {
                    var data = xhr.responseText;
                    header.createMenu(data);
                }
              }
            };
            xhr.send();
            //$.ajax({
                //url : this.annotationControl.services + "?service=get-menu",
                //headers: { "Content-Type": "application/xml; charset=utf-8", "Accept": "text/html,application/xhtml+xml,application/xml", "X-Requested-With":null },
                //type: "POST",
                //data : dataElement,
                //success: function(data, textStatus, jqXHR)
                //{
      			    //	  domConstruct.empty(menuBar.domNode);
                //    parseXML = header.loadXMLString(data);
                    //console.log(parseXML);
      			    //	  header.createMenu(parseXML.documentElement);
                //},
                //error: function (jqXHR, textStatus, errorThrown)
                //{

            //    }
            //});

    			}
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

        },
    	  getContent: function(){
    		  var contentObject;
    		  if(this.annotationControl.selection.content){
    			  contentObject =  this.annotationControl.selection.content;
    		  }
    		  else{
    			  contentObject =  this.annotationControl.content;
    		  }
    		  return contentObject;
    	  },
    	  createMenu: function(menuInfo){


    		  var subMenus = this.queryElementChildren("sub-menu", menuInfo);
    		  //var subMenus = query("sub-menu", menuInfo);
	    	  for(var i=0; i< subMenus.length; i++){
	    		  this.createSubMenu(subMenus[i])
	    	  }
    	  },
    	  createSubMenu: function(subMenuInfo){

    		  var menuItem = this.queryOneElementChild("menu-item", subMenuInfo);
    		  var label = this.getElementTextContent(menuItem);
    		  //var label = query("menu-item:first-of-type", subMenuInfo)[0].firstChild.data;
    		  if(label){
    			  var subMenu = new Menu({});
            	  var varpopupMenuBarItem = new PopupMenuBarItem({
	        	          label: label,
	        	          popup: subMenu,
                      id: this.guid()
	        	      });
	        	  this.menuBar.addChild(varpopupMenuBarItem);

	        	  var options = this.queryElementChildren("option", subMenuInfo);
	        	  //var options = query("option", subMenuInfo);
	    		  for(var i=0; i< options.length; i++){
		    		  var optionInfo = options[i];
	    			  this.createOption(optionInfo, subMenu);
		    	  }
    		  }
    	  },
    	  createOption: function(optionInfo, subMenu){
          //console.log("----create Option----");
          //console.log(optionInfo);
          //console.log(this.annotationControl.selection);
    		  var varinsertAnnotationItem = new InsertAnnotationItem({option: optionInfo, selection: this.annotationControl.selection});
			    domConstruct.place(varinsertAnnotationItem.domNode, subMenu.domNode, 'last');
    	  },
    	  onMouseEnter: function(e){
    		  this.annotationControl.selection.update();
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
    		  var content = '';
    		  if(node.firstChild){
    			  if(node.firstChild.data){
    				  content = node.firstChild.data;
    			  }
    		  }
    		  return content;
    	  },

        S4 : function () {
            return (((1+Math.random())*0x10000)|0).toString(16).substring(1);
        },

// then to call it, plus stitch in '4' in the third group
        guid : function () {
            var guid = (this.S4() + this.S4() + "-" + this.S4() + "-4" + this.S4().substr(0,3) + "-" + this.S4() + "-" + this.S4() + this.S4() + this.S4()).toLowerCase();
            return guid;
        }

        });
	});
