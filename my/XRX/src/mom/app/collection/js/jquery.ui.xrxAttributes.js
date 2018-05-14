/* jQuery UI Forms Mixed Content Attributes
 *
 * Depends:
 * jquery.ui.core.js
 * jquery.ui.widget.js
 * jquery.ui.draggable.js
 * jquery.ui.droppable.js
 */

(function ($, undefined) {
    
    
    var uiMainDivId = "xrx-attributes";
    var uiTagnameDivClass = "forms-mixedcontent-attributes-tagname";
    var uiEditAttributesDivClass = "forms-mixedcontent-edit-attributes";
    var uiEditAttributeDivClass = "forms-mixedcontent-edit-attribute";
    var uiSuggestedAttributesDivClass = "forms-mixedcontent-suggested-attributes";
    var uiSuggestedAttributeDivsClass = "forms-mixedcontent-suggested-attribute";
    var uiDroppableAttributeDivClass = "forms-mixedcontent-attribute-droppable";
    /* variablenerweiterung aufgrund von attribut values */
    var uiSuggestedValuesDivClass = "forms-mixedcontent-suggested-values";
    var uiSuggestedValueDivsClass = "forms-mixedcontent-suggested-value";    
    
    var uiFormsTableClass = "forms-table";
    var uiFormsTableRowClass = "forms-table-row";
    var uiFormsTableCellClass = "forms-table-cell";
    /* controlledVoc works like a flag: when true then the controlled Vocabulary is active */
    var controlledVoc = false;
    /* 
     * For the controlled Vocabulary a 2-level hierarchy is realized in the json-Object.
     * Til now used only in cei:index @indexName and @lemma 
     * the var controlledVocabularies gets json from a hidden div in the mycollection-charter-edit*/
    var controlledVocabularies;
    
   
    
    $.widget("ui.xrxAttributes", {
        
        
        options: {
            elementName: null,
            suggestedAttributes: null,
            editedAttributes: null,
            cm: null,
            token: null
        },
        /* option properties get values from codemirror.mode.visualxml.js*/
        
       /* the method rowremove is used to remove Attributes from GUI, from the instance and from array-object "editedAttributes"
         * */
       rowremove: function(gewissesAttr, editedAttributes, cm, token) {
      	   var sein = new AttributesImpl();                        
             sein.addAttribute(undefined, gewissesAttr, gewissesAttr, undefined, '');                           
            // var row = $("div:contains("[title=''" + gewissesAttr + "']"), "." + uiEditAttributesDivClass);
            	 
           // var reihe = $("div", "."+ uiEditAttributesDivClass).find("[title='" + gewissesAttr + "']");
             if ($("div", "."+ uiEditAttributesDivClass).find("[title='" + gewissesAttr + "']")) {
            	 var meinort = $("div", "."+ uiEditAttributesDivClass).find("[title='" + gewissesAttr + "']");
            	
            	 var row = $(meinort).closest("div.forms-table-row"); //,"." + uiEditAttributesDivClass
            	 
             }        
             row.remove(); 
             var nodeset = $(document).xrx.nodeset(cm.getInputField());                
             var controlId = nodeset.only.levelId;                
             var relativeId = token.state.context.id.split('.').splice(1);                
             var contextId = controlId.concat(relativeId);
             $('.xrx-instance').xrxInstance().deleteAttributes(contextId, sein);
             function findEditedAttributes(edAttr){                	
             	return edAttr.qName == gewissesAttr;
             }                
            var objectindex = editedAttributes.findIndex(findEditedAttributes);              
            if (objectindex > -1){
         	   editedAttributes.splice(objectindex,1);                 
            }

             return editedAttributes;
           
      }, 
    
        /* the enable function is used to re-enable certain attributes on the GUI*/
        
        enable: function() {
            inallSpans = $("div", "." + uiEditAttributeDivClass).find("span").not(".ui-icon").text();                    

            var spantexte =[];
            var eintrag = $(".forms-mixedcontent-edit-attribute").find("span")
            for (var i = 0; i < eintrag.length; i++) {
                spantexte.push(eintrag[i].textContent);
            }
            var proofdiv = $("div", "." + uiSuggestedAttributeDivsClass);
            for (var i = 0; i < proofdiv.length; i++) {
                var proof = proofdiv[i].previousSibling.data;
                if (spantexte.indexOf(proof) == -1) {                       
                    var enable = $("div:contains('" + proof + "')", "." + uiSuggestedAttributesDivClass).removeClass("ui-state-disabled");
              
                }                    
            } 
        return enable    
        },
        
                
        _create: function () {
        	/*parsing Json out of the widget, in order to know, which controlled Vocabularies are available on the server*/
        	controlledVocabularies = JSON.parse($("div.available-controlled-vocabularies").text());    		
            var self = this,
            elementName = self.options.elementName,
            suggestedAttributes = self.options.suggestedAttributes,
            editedAttributes = self.options.editedAttributes,            
            /* creating the GUI
             * 1. edited attributes
             * 2. suggestedAttributes
             * 3. field to drop attributes into
             * 4. button to switch on/off the use of controlled vocabulary */
            mainDiv = $('<div></div>').attr("class", uiMainDivId),
            editAttributesDiv = $('<div></div>').addClass(uiEditAttributesDivClass).addClass(uiFormsTableClass),
            //droppableAttributeDiv = $('<div">&#160;</div>').addClass(uiDroppableAttributeDivClass),
            suggestedAttributesDiv = $('<div></div>').addClass(uiSuggestedAttributesDivClass),
            controlledVocButton = $('<div>Use Controlled Vocabulary:</div>').addClass('controlledVocabulary').css("text-align", "right");
            
            
            /* a method to switch off/on the use of the controlled Vocabulary*/
            self._onoffButton(controlledVocButton, editedAttributes);
            
             /*xrx-attributes class gets method _attributeDroppable*/
            /*self._attributeDroppable(droppableAttributeDiv);*/
            
            /*when editor is opened, look if there are already attributes set,
             * then append to the div.forms-mixedcontent-edit-attributes the attributes that already exist.  */
            
            for (var i = 0 in editedAttributes) {
                editAttributesDiv.append(self._newEditAttribute(editedAttributes[i].qName, $(document).xrxI18n.translate(editedAttributes[i].qName, "xs:attribute"), editedAttributes[i].value));
            
            }     
            
            /* a new div-box in the GUI is created, in it there is the list of all possible Attributes for the element.
             * in Addition these Attributes get a method _suggestedAttributeDraggable, means that you are able to drag them. */
            
            for (var i = 0 in suggestedAttributes) {
                var name = suggestedAttributes[i];
                var newDiv = $('<div>' + $(document).xrxI18n.translate(name, "xs:attribute") + '<div>').addClass(uiSuggestedAttributeDivsClass).attr("title", name);
                suggestedAttributesDiv.append(newDiv);
               self._suggestedAttributeClickable(newDiv);
                //self._suggestedAttributeDraggable(newDiv);
                
            }
       
            
            /* All GUI parts concerning the Attributes are appended */            
            mainDiv.append(controlledVocButton).append(editAttributesDiv).append(suggestedAttributesDiv); //.append(droppableAttributeDiv)
            self.element.replaceWith(mainDiv);         
            /* function ausblenden is used for usabilty reasons, 
             * when a controlled Vocabulary is specified in the @indexName then just @lemma should be draggable.
             * after @lemma is set - all other attributes are draggable again.
             * */           
            function ausblenden(gewisseAttr){
        		var blende = suggestedAttributes;                       
        		var l = blende.indexOf(gewisseAttr);
                    blende.splice(l, 1);
                    for (var j = 0; j < blende.length; j++) {
                        var dis = $("div[title='" + blende[j] + "']", "." + uiMainDivId).addClass("ui-state-disabled");//.off("click")draggable("disable");
                   }                    
                    return dis;
                   }
            /*function backbone goes through the array controlledVocabularies
             * and justifies if the value set in the @indexName has a reference in one of the controlled Vocabularies*/
            function backbone(attr){
                if(attr.qName == "indexName")
                {	
                    for (var i=0; i < controlledVocabularies.length; i++){
                        var ob = Object.keys(controlledVocabularies[i]);                        
                        if (ob == attr.value){                        
                        return true;
                        }
                    }
                };              
            }
            var vocabulartest = editedAttributes.find(backbone);            
            /* vocabulartest is true, then one of the controlled vocabularies in used.*/
            
            /* findEditedAttributes has a look if @lemma is already set, 
             * if so: in the GUI all @ but @lemma are disabled*/
            function findEditedAttributes(edAttr){            	
            	return edAttr.qName == 'lemma';
            }          
            var objectindex = editedAttributes.findIndex(findEditedAttributes);                        
            
            if((vocabulartest != undefined) && (objectindex == -1)){
            	var x = ausblenden('lemma');
            }
            else {
            	for (var i= 0; i < editedAttributes.length; i++){
            		$("div[title='" + editedAttributes[i].qName + "']", "." + uiMainDivId).addClass("ui-state-disabled");//.draggable("disable").off("click");
            	}
            	
            }
            /*controlledVoc is as default set to false again.*/
            controlledVoc = false;
            
            /* the jquery menu is initialized. the cv is realized in a drop down menu */                        
            $(function () {
                $("#choose").menu();
            });            
            
        },        
        /*End of create function */    
        
        _newEditAttribute: function (name, label, value) {
          
        	controlledVocabularies = JSON.parse($("div.available-controlled-vocabularies").text());
        	/* the variable is needed in the case any controlled vocabulary was usedin or will be set in the indexName Attribute*/
            var self = this,
            cm = self.options.cm,
            token = self.options.token,
            editedAttributes = self.options.editedAttributes,
            suggestedAttributes = self.options.suggestedAttributes,
            elementName = self.options.elementName,
            
            /* variables to define the GUI */
            newEditAttribute = $('<div></div>').addClass(uiFormsTableRowClass).addClass(uiEditAttributeDivClass),
            newEditAttributeLabel = $('<div><span title="' + name + '" >' + label + '<span></div>').addClass(uiFormsTableCellClass),
            newEditAttributeInput = $('<input></input>').addClass(uiFormsTableCellClass).attr("value", value).attr("name", name).attr("list", "tags"),
            newEditValuelabel = $('<div><span title="' + name + '" >' + label + '<span></div>').addClass(uiFormsTableCellClass),
            menuliste = $('<select></select>').attr('class', 'choose').addClass(uiFormsTableCellClass),
            newEditAttributeTrash = $('<div><span class="ui-icon ui-icon-trash"/></div>').
            addClass(uiFormsTableCellClass);       
           /* it has to be proofed if from the last use of the attribute widget,
                 * the user used the cv or not.
                 * so the editedAttributes values are compared with the controlledVocabularies
                 * is there an accordance, the controlledVoc is set to true.
                 *               
                 * 
               */
            function backbone(attr){            	
                if(attr.qName == "indexName")
                {	
                    for (var i=0; i < controlledVocabularies.length; i++){
                        var ob = Object.keys(controlledVocabularies[i]);
                      
                        if (ob == attr.value){                        
                        return true;
                        }
                    }
                };              
            }
            var vocabulartest = editedAttributes.find(backbone);                    
            
               if ((elementName == "cei:index") && ((name == "lemma") | (name == "indexName"))){            	  
            		   if(vocabulartest != undefined){
                       	controlledVoc = true;
                       }                    
               }
               else {
            	   controlledVoc = false;           	  
               }           
           
            /* 
             * 
             * In the following lines the GUI is constructed
             * if controlledVoc is true then menuliste (is a dropdown menu)is implemented
             * if false newEditAttributeInput (is an inputfield) is created.*/
            if (elementName == "cei:index") {
            
                if ((controlledVoc == true) && ((name == "lemma") | (name == "indexName")))
                {
                                    	                               
                                                                 
                        newEditAttributeLabel.hide();
                        newEditAttributeInput.hide();
                        newEditAttribute.append(newEditValuelabel).append(menuliste).append(newEditAttributeTrash);
                        var x = setoptioninSelect(name);
                    }
                 else {
                    newEditAttribute.append(newEditAttributeLabel).append(newEditAttributeInput).append(newEditAttributeTrash);
                }
                }            
                      
            else {
                newEditAttribute.append(newEditAttributeLabel).append(newEditAttributeInput).append(newEditAttributeTrash);
            }
            
            /*the div.forms-mixedcontent-edit-attributes gets the method _trashIconClickable */
        
            self._trashIconClickable(newEditAttributeTrash, newEditAttribute, value);
            
            /* function replaces the attributes values in the instance */            
            newEditAttributeInput.keyup(function () {
            /* Proof the value of the attribute:
             * if there is an &, it is escaped
             * part of issue #427
             * */
            	if ($(this).val().includes('&')){
            	var text = $(this).val().replace('&', '&amp;');
            	}
            	else{
            	var text = $(this).val()
            	}
                var attributes = new AttributesImpl();
                attributes.addAttribute(null, name, name, undefined, text);
                var nodeset = $(document).xrx.nodeset(cm.getInputField());
                var controlId = nodeset.only.levelId;
                var relativeId = token.state.context.id.split('.').splice(1);
                var contextId = controlId.concat(relativeId);                
                $('.xrx-instance').xrxInstance().replaceAttributeValue(contextId, attributes);                           
                
                
            });            
            
            /* Defining the SELECT box:
             * function to set the options in the select box.
             * The function deals with the values from the json-object.             *             
             * In the 'newli' variable the option elements with the possible values
             * are appended to 'menuliste'.*/
            
            function setoptioninSelect(name) {
            	
            	var lemmawert;
            	var indexnamewert;
                var einf = $("<option> --- </option>");
                if (name == "indexName") {
                    menuliste.append(einf);
                    for (var i = 0; i < controlledVocabularies.length; i++) {
                        var currentVocabulary = controlledVocabularies[i];
                        var values = Object.keys(currentVocabulary).map(function (key) {
                            return currentVocabulary[key];
                        });
                        var newOption = $('<option>' + values.sort() + '</option>')
                            .addClass(uiSuggestedValueDivsClass).attr("title", values).attr("value", Object.keys(currentVocabulary)).attr("name", name);
                        if (Object.keys(controlledVocabularies[i]) == value) {

                            newOption.attr("selected", "selected");                          

                            indexnamewert = value;
                        }
            		
            		menuliste.append(newOption);
        		}
            	}
                else {
                        menuliste.append(einf);                        
                                               	
                        	 function findindexName(edAttr){                        		 
                              	  return edAttr.qName == 'indexName';                              	  
                                }
                            indexnamewert = editedAttributes.find(findindexName).value;
                        
                  
                     
                        	 function findEditedAttributes(edAttr){
                           	  return edAttr.qName == 'lemma';                 }          
                             var lemma = editedAttributes.find(findEditedAttributes);
                             
                             if (lemma == undefined) {
                            	 lemmawert = '';
                             }
                             else{
                            	 lemmawert = lemma.value;
                             }                       
                          
                        var sprachwert = $(".xrx-language-for-skos").text();
               
                        $.ajax({     
                            url: "/mom/service/editMomgetControlledVoc",
                            type:"GET",                            
                            dataType: "json", 
                            data: {indexname: indexnamewert, lemma: lemmawert, sprache: sprachwert},
                            success: function(data, textStatus, jqXHR)
                            {                      
                     var auswahl = {};
                                                                                                 
                     var siehe = look(data);
                     
               function look(daten, label){            	
            	   for (key in daten){
            	
            		var liste;
            		if($.type(daten[key]) === "string"){            	
            		if (key === "label"){
            			var liste = $('<option>' + daten[key] +'</option>').addClass("group").addClass(uiSuggestedValueDivsClass).attr("title", daten[key]).attr("value", label).attr("name", name);
            			
            		}
            		else {
            			var liste = $('<option>' + daten[key] + '</option>')
       	   				.addClass(uiSuggestedValueDivsClass).attr("title", daten[key]).attr("value", key).attr("name", name);
            			
            		}             			
            		
   	   				
   	   				menuliste.append(liste);
   	   				var setselected = $("option[value =" + value + "]");
   	   				setselected.attr("selected", "selected");
            	   	}
            	   else {
            		   var obj = (daten[key]);
            		   
            		   var label = key.replace('#', '');            	
            		   var siehe =  look(obj, label);
            		   
            	   } 
            	
            		
            	   }  
            	  
               	};          
                  return true;
                                    },     
                            error: function(){
                            	console.log('Error: Failed to load script.');                           
                             
                             return false;
                            }     
                          });
                        
         		  }                	
              
            }            
            //END of setOptioninselect function
            
            /* When the user changes the value in the dropdown-menu, then 
             * the change event is triggered
             * the new current value (this.value) gets stored via codemirror in the xml-instance
             * I store the self variable in the ev.data (var kapsel)in order to be able to call further methods
             * on the self-object of */
            menuliste.change( {mfg: self}, function (ev) {            	              
            	//console.log( ev.data.mfg);
            	var kapsel = ev.data.mfg;
            	var self = this;           
                var attrvalue = this.value;                
                var nodeset = $(document).xrx.nodeset(cm.getInputField());
                var controlId = nodeset.only.levelId;
                var relativeId = token.state.context.id.split('.').splice(1);
                var contextId = controlId.concat(relativeId);                
                var attributes = new AttributesImpl();                
                attributes.addAttribute(undefined, name, name, undefined, attrvalue);
                /* hier wird bei jedem Value change dann auch das selected Attribut angepasst! */
                var findselected = $(".xrx-attributes").find("option[name =" + name + "]");
                findselected.removeAttr("selected", "selected");
                var setselected = $("option[value =" + attrvalue + "]");

                setselected.attr('selected', 'selected');            
              
                function findEditedAttributes(edAttr){                	
                	return edAttr.qName == name;
                }                
               var objectindex = editedAttributes.findIndex(findEditedAttributes);             
               if (objectindex > -1){
            	   editedAttributes.splice(objectindex,1, {qName: name, value: attrvalue});                  
               }
               else {            	  
            	   editedAttributes.push({qName: name, value: attrvalue});
               }
               
               function backbone(attr){            	
                   if(attr.qName == "indexName")
                   {	
                       for (var i=0; i < controlledVocabularies.length; i++){
                           var ob = Object.keys(controlledVocabularies[i]);
                         
                           if (ob == attrvalue){                        
                           return true;
                           }
                       }
                   };              
               }

               var vocabulartest = editedAttributes.find(backbone);                         
                                        	  
               if(vocabulartest != undefined){
                          	controlledVoc = true;
                          	 $("div.forms-mixedcontent-suggested-attribute").addClass("ui-state-disabled");             
                          	 kapsel.rowremove('lemma', editedAttributes, cm, token);              
                             
                          	 $("div[title='lemma']").removeClass("ui-state-disabled");
                          	 
                          }                    
      
                if (name == 'lemma') {                                
                        controlledVoc = true; 
                        kapsel.rowremove('sublemma', editedAttributes, cm, token);
                        kapsel.enable();
                     
                } 
                
             
                /* Set the new value of the attributes in the instance. The function replaceAttrbiuteValue of the
                 * jquery wigdet xrxInstance.js is called */                
                $('.xrx-instance').xrxInstance().replaceAttributeValue(contextId, attributes);
            });
            //end of change function
            
            
            $(menuliste).menu();
          
            return newEditAttribute;
        },      
        /*End of _newEditAttribute */    
        /* method to switch off/on the use of controlled vocabularies
         * 
         * */
        _onoffButton: function (controlledVocButton, editedAttributes) {
        	controlledVocabularies = JSON.parse($("div.available-controlled-vocabularies").text());
            var self = this,            
            suggestedAttributes = self.options.suggestedAttributes,            
            editedAttributes = self.options.editedAttributes,            
            cm = self.options.cm,            
            token = self.options.token;           
            controlledVocButton.append($('<span id="onoff"></span>').css("float", "right").append($('<input type="radio" name="radio" id="on" value="on"/><label for="on" class="plug"> Yes </label>').css("font-size", "0.5em")).            
            append($('<input type="radio" name="radio" id="off" value="off" checked="checked"/><label class="plug" for="off"> No </label>').css("font-size", "0.5em")))
            
            controlledVocButton.find("span").buttonset();   

            /* if the cv is switched off and the attributes IndexName, or lemma or sublemma are set,
             * these are going to be deleted and set to be draggable again.
             * At the end of the function the boolean var controlledVoc is set to true or false.*/
            controlledVocButton.find("input").change(function () {
                
            	var nodeset = $(document).xrx.nodeset(cm.getInputField());                
                var controlId = nodeset.only.levelId;                
                var relativeId = token.state.context.id.split('.').splice(1);                
                var contextId = controlId.concat(relativeId);            

                var values = $("input:radio:checked").val();
                                                
                if (values == "off") {      
                	controlledVoc = false;

                	   self.rowremove('indexName', editedAttributes, cm, token);
                	   self.rowremove('lemma', editedAttributes, cm, token);                	
                	   self.enable();
                	   $("div[title='indexName']", "." + uiSuggestedAttributesDivClass).removeClass("ui-state-disabled");
                	   $("div[title='lemma']", "." + uiSuggestedAttributesDivClass).removeClass("ui-state-disabled");

                    //controlledVoc = false;           
                } else { 
                   self.rowremove('indexName', editedAttributes, cm, token);
             	   self.rowremove('lemma', editedAttributes, cm, token);
             	   controlledVoc = true;
            	   $("div[title='indexName']", "." + uiSuggestedAttributesDivClass).removeClass("ui-state-disabled");
            	   $("div[title='lemma']", "." + uiSuggestedAttributesDivClass).addClass("ui-state-disabled");
                }
           
                
            });            
            return controlledVoc;
        },
        //end of _onoffButton method
        
        /*the Delete Method: in GUI you can click a trash-icon*/
        _trashIconClickable: function (trashIcon, editAttribute, inhalt) {          
        	controlledVocabularies = JSON.parse($("div.available-controlled-vocabularies").text());
            var self = this,            
            suggestedAttributes = self.options.suggestedAttributes,            
            editedAttributes = self.options.editedAttributes,           
            cm = self.options.cm,            
            token = self.options.token;
          
            /*
             * when the click event is triggered, the function takes the the name of the attribute 
             * that is going to be deleted out of the input Element or out of the editedAttributes
             * --seems complicated - is not a beautiful solution
             *  
             * */
            trashIcon.click(function (event) {
            	
                if ($($(editAttribute).find("input")).length == 1) {                    
                    var name = $($(editAttribute).find("input")).attr("name");  
                    var value = ($(editAttribute).find("input")).text();
                } else {         
                    var name = editAttribute[0].firstElementChild.firstChild.firstChild.data;
                } 
                
                function findEditedAttributes(edAttr){                
                	return edAttr.qName == name;
                }               
               var objectindex = editedAttributes.findIndex(findEditedAttributes);
               if (objectindex > -1){
            	   editedAttributes.splice(objectindex,1); 
               }
                 /*Via the finIndex function the editedAttributes are kept up-to-date,
                  * deleted Attributes are removed with splice.
                  * an in the following also removed from the xml-instance*/               
                var attributes = new AttributesImpl();                
                attributes.addAttribute(null, name, name, undefined, "");
                
                var findselect = $(editAttribute).find("select");
                /*if indexName is going to be deleted than it is checked if indexName was used with the cv.
                 *If this is the case, the attributes lemma has to be deleted too.
                 *When  @indexName and @lemma are deleted they are set to be draggable again.*/
                if ((name == 'indexName') && ($(editAttribute).find("select").length == 1)) {
                	
                self.rowremove('lemma', editedAttributes, cm, token);
                self.rowremove('indexName', editedAttributes, cm, token);
                //self.enable();                
                    var div = $("div[title='indexName']", "." + uiSuggestedAttributesDivClass).removeClass("ui-state-disabled");
                    
                    $("div[title='lemma']", "." + uiSuggestedAttributesDivClass).addClass("ui-state-disabled");
                    self._suggestedAttributeClickable(div);                  
                   
            
               
                }
                /*if lemma (used with cv) is deleted, also sublemma has to be removed.
                 * When this is done, just lemma and sublemma are set to be draggable again.
                else if (name == 'lemma' && $(editAttribute).find("select").length == 1) { 
                	var div = $("div[title='lemma']").removeClass("ui-state-disabled");
                	self.rowremove('lemma', editedAttributes, cm, token);
                  	self._suggestedAttributeClickable(div);
                    
                 
                }*/
                
                else {  
                self.rowremove(name, editedAttributes, cm, token);             
         
                var div = $("div[title='" + name + "']", "." + uiSuggestedAttributesDivClass).removeClass("ui-state-disabled");              
                }
                /*the attribute is also removed from the GUI*/          
             
                editAttribute.remove();                 		               
                
            });
         
           return editedAttributes;
        },
        
        //End of _trashIconClickable
        
        
   
        
        _suggestedAttributeClickable: function (suggestedAttribute){
        	  var self = this,            
              cm = self.options.cm,            
              token = self.options.token,            
              elementName = self.options.elementName,
              suggestedAttributes = self.options.suggestedAttributes,
              editedAttributes = self.options.editedAttributes;
           
        	suggestedAttribute.on("click", function(){
        		 var klasse = suggestedAttribute.attr("class");
        		 if (klasse == "forms-mixedcontent-suggested-attribute ui-state-disabled"){
        			
        		 } else {
        			
            		 var qName = suggestedAttribute.attr("title"),                    
                     label = suggestedAttribute.text();                    
                     editWidget = self._newEditAttribute(qName, label, "");
            	
            		 $("." + uiEditAttributesDivClass, "." + uiMainDivId).append(editWidget);
            		
            		  var attributes = new AttributesImpl();                    
                      attributes.addAttribute(null, qName, qName, undefined, "");
            		  var nodeset = $(document).xrx.nodeset(cm.getInputField());                    
                      var controlId = nodeset.only.levelId;                    
                      var relativeId = token.state.context.id.split('.').splice(1);                    
                      var contextId = controlId.concat(relativeId);
                      
                      $('.xrx-instance').xrxInstance().insertAttributes(contextId, attributes);
                      
                      editedAttributes.push({qName: qName, value: ""});
                      suggestedAttribute.addClass("ui-state-disabled");        			 
        		 }
        	
        	}); 
        
        },        
      
       
              
        
        hide: function () {
        }
    });
})(jQuery);