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
    var uiDroppableValueDivClass = "forms-mixedcontent-value-droppable";
    
    
    var uiFormsTableClass = "forms-table";
    var uiFormsTableRowClass = "forms-table-row";
    var uiFormsTableCellClass = "forms-table-cell";
    /* controlledVoc works like a flag: when true then the controlled Vocabulary is active */
    var controlledVoc = false;
    /* Arrays and object to get actual values of the attributes, 
     * because property editedAttributes is not updated,
     * before the whole lifecycle of the widget is redone!
     * The solution chosen here maybe is more complicated than it has to be.
     * If there is time - this has to be rethought - simplified and generalized. 
     * The global variables are necessary to pass on values 
     * especially from _trashiconClickable to _newEditAttribute and in the menuliste.change-function!
     * because if the controlled Vocabulary is used, it is essential to know the values depending on following values.
     * For the controlled Vocabulary a 3-level hierarchy is realized in the json-Object. */
    var aktuell = {
    };
    //var verw =[];
   // var wert =[];
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
        
//        thrill: function()  {
//        	alert(("Yeah"));
//        },
        
        _create: function () {
        	
        	controlledVocabularies = JSON.parse($("div.available-controlled-vocabularies").text());
    		console.log(controlledVocabularies);
            var self = this,
            elementName = self.options.elementName,
            suggestedAttributes = self.options.suggestedAttributes,
            editedAttributes = self.options.editedAttributes,
            //controlledVoc = false,
                        
            mainDiv = $('<div></div>').attr("class", uiMainDivId),
            
            editAttributesDiv = $('<div></div>').addClass(uiEditAttributesDivClass).addClass(uiFormsTableClass),
            droppableAttributeDiv = $('<div">&#160;</div>').addClass(uiDroppableAttributeDivClass),
            suggestedAttributesDiv = $('<div></div>').addClass(uiSuggestedAttributesDivClass),
            controlledVocButton = $('<div>Controlled Vocabulary</div>').addClass('controlledVocabulary').css("text-align", "right");
            
             /*xrx-attributes class gets method _attributeDroppable*/
            self._attributeDroppable(droppableAttributeDiv);
            
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
                self._suggestedAttributeDraggable(newDiv);
                
            }
            
            /* a method to switch off/on the use of the controlled Vocabulary*/
            self._onoffButton(controlledVocButton, editedAttributes);
            
            /* All GUI parts concerning the Attributes are appended */
            
            mainDiv.append(controlledVocButton).append(editAttributesDiv).append(droppableAttributeDiv).append(suggestedAttributesDiv);
            self.element.replaceWith(mainDiv);
            
            console.log('++++++++++++++++ WICHTIG +++++++++++++++++++++');          
                    	
            console.log(elementName);
            console.log(suggestedAttributes);
            console.log(editedAttributes);
            console.log('++++++++++++++++++++++++++++');
            
            function ausblenden(gewisseAttr){
        		var blende = suggestedAttributes;                       
                    var l = blende.indexOf(gewisseAttr);
                    blende.splice(l, 1);
                    for (var j = 0; j < blende.length; j++) {
                        var dis = $("div[title='" + blende[j] + "']", "." + uiMainDivId).draggable("disable");
                    }
                    console.log("but why are we to blind to see but once we have heard about you and me");
                    return dis;
                    }
                        
          
            /* These if-else-conditions are necessary to lead the user in the case the user uses the cv
             * when indexName is set with the value illurk-vocabulary, then lemma and sublemma are the
             * only draggable attributes. To do so in var blende are all the attributes, 
             * which are set to 'draggable disable'
             * when indexName and lemma are already set then just sublemma will be draggable.
             * in the else-condition all attributes, which are not edited, are set to be draggable. */
            function backbone(attr){
            	console.log("Heeeeeeellllllooooooo");
            	console.log(attr.qName);
                if(attr.qName == "indexName")
                {	console.log("stimmt");
                	console.log(controlledVocabularies);
                    for (var i=0; i < controlledVocabularies.length; i++){
                        var ob = Object.keys(controlledVocabularies[i]);
                        console.log(ob);
                        console.log(attr.value);
                        if (ob == attr.value){                        
                        return true;
                        }
                    }
                };              
            }
            
          

            var vocabulartest = editedAttributes.find(backbone);
            console.log("Is it you I was looking for?");
            console.log(vocabulartest);
            
            
            function findCherries(edAttr){            	
            	return edAttr.qName == 'lemma';
            }          
            var objectindex = editedAttributes.findIndex(findCherries);
            console.log(objectindex);
           
                        
            
            if((vocabulartest != undefined) && (objectindex == -1)){
            	var x = ausblenden('lemma');
            }
            else {
            	for (var i= 0; i < editedAttributes.length; i++){
            		$("div[title='" + editedAttributes[i].qName + "']", "." + uiMainDivId).draggable("disable");
            	}
            	
            }
            
                	
            controlledVoc = false;
            /* the jquery menu is initialized. the cv is realized in a drop down menu */
            
          
            
            
            $(function () {
                $("#choose").menu();
            });
            
            
            
            
            
        },
        
        /*End of create function */       
   
        
        _newEditAttribute: function (name, label, value) {
            /* Variables to deal with the modell */
        	controlledVocabularies = JSON.parse($("div.available-controlled-vocabularies").text());
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
                 
            //self.thrill();
      
                
                /* it has to be proofed if from the last use of the attribute widget,
                 * the user used the cv or not.
                 * if in the editedAttributes is the attr indexName with the value 'illurk-vocabulary'
                 * then the controllevVoc is true.
                 * Has to be changed, when the cv is used for other descriptions too.
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
            console.log("Is it you I was looking for?");
            console.log(vocabulartest);          
            
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
            
            self._trashIconClickable(newEditAttributeTrash, newEditAttribute, aktuell.value); // da reicht sicher value aktuell rausschmeißen
            
            /* function saves all changes in the input field */
            
            newEditAttributeInput.keyup(function () {
             
                var attributes = new AttributesImpl();
                attributes.addAttribute(null, name, name, undefined, $(this).val());
                var nodeset = $(document).xrx.nodeset(cm.getInputField());
                var controlId = nodeset.only.levelId;
                var relativeId = token.state.context.id.split('.').splice(1);
                var contextId = controlId.concat(relativeId);                
                $('.xrx-instance').xrxInstance().replaceAttributeValue(contextId, attributes);                           
                
                
            });            
            
            /* function to set the options in the select box.
             * The fuction deals with the values from the json-object.
             * key are the keys of the object;            
             * In the 'newli' variable the option elements with the possible values
             * are appended to 'menuliste'.*/
            
            function setoptioninSelect(name) {
            	
            	var sublemmawert;
            	var lemmawert;
            	var indexnamewert;
            	if (name == "indexName"){
            		var einf = $("<option> --- </option>");
            		menuliste.append(einf);
            	  for (var i=0; i<controlledVocabularies.length; i++){
                  	var werteausobjekt = Object.values(controlledVocabularies[i]);
                  	console.log("weerte aus objekt");
                  	console.log(werteausobjekt);
                	var newli = $('<option>' + werteausobjekt + '</option>')
        			.addClass(uiSuggestedValueDivsClass).attr("title", werteausobjekt).attr("value", Object.keys(controlledVocabularies[i])).attr("name", name);
            		if (Object.keys(controlledVocabularies[i]) == value){
           			 newli.attr("selected", "selected");               			 
           		}
            		
            		menuliste.append(newli);
        		}
            	}
                	else {
                		var einf = $("<option> --- </option>");
                        menuliste.append(einf);
                        
                        if (name == 'lemma'){                        	
                        	attributswert = '';
                        }
                        else {
                        	var sucheOptions = $(".forms-mixedcontent-edit-attributes").children().find("option[selected]");
                        	var subwert = 'leer';
                        /*When sucheOptions.length is 0 then I know that the window was loaded again
                         *  and no attribute was set.
                         *  instead there are already editedAttributes and 
                         *  the selected Options can be recompound.*/
                        if(sucheOptions.length == 0){
                        	
                        	for (i in editedAttributes){
                        		if (editedAttributes[i].qName == "lemma"){
                        			var attributswert = editedAttributes[i].value;
                        			
                        		}
                        		if (editedAttributes[i].qName == "sublemma"){
                        			 var subwert = editedAttributes[i].value;
                        			 
                        		}
                        	}
                        }
                        else {sucheOptions.each( function(index) {                         	
                            var attrname = $(this).attr('name');
                          if (attrname == "lemma"){                        	  
                        	  attributswert = $(this).attr('value');                        	 
                          }
                        
                            });
                       
                       
                        }                       
                        lemmawert = attributswert.replace('#', '');
                        
                        }
                        /*  
                         * var sucheOptions = $(".forms-mixedcontent-edit-attributes").children().find("option[selected]");
                         *  die Klasse xrx-language-for-skos wurde serverseitig im widget 
                        * 
                        * my-collection-charter-edit eingeführt,
                        * um die Sprache des Users mit der Sprache des ControllVoc
                        * abzugleichen.                        * 
                        */                       
                        indexnamewert = $("option[name='indexName'][selected='selected']").val();
                       /*
                        * Wird die seite neu geladen, dann sind ist das selected nicht gesetzt und ich
                        * hole den wert vom Attribut indexName aus den editedAttributes Objekt.
                        * */
                        if ($("option[name='indexName']").length == 0){
                        	
                        	for (i in editedAttributes){
                        		if (editedAttributes[i].qName == "indexName"){
                        			var indexwert = editedAttributes[i].value;
                        			
                        		}
                        	
                        	}                        	
                        indexnamewert = indexwert;
                        } 
                        console.log("****************************");
                        console.log(lemmawert);
                        console.log(indexnamewert);
                        console.log("+++++++++++++++++++++++++++++");
                        var sprachwert = $(".xrx-language-for-skos").text();                       
                        $.ajax({     
                            url: "/mom/service/editMomgetControlledVoc",
                            type:"GET",                                
                            dataType: "json", 
                            data: {indexname: indexnamewert, lemma: lemmawert, sprache:sprachwert},
                            success: function(data, textStatus, jqXHR)
                            {                           
                          for (var i in data){                            		
                            		var valeur = data[i];                            		
                            		var newli = $('<option>' + valeur + '</option>')
                        			.addClass(uiSuggestedValueDivsClass).attr("title", valeur).attr("value", i).attr("name", name);
                            		
                            		if (i == value.replace('#', '')){                            		
                           			 newli.attr("selected", "selected");
                           		}
                            		
                            		menuliste.append(newli);
                            }                       
                                      console.log("geht!!!!!!") 
                                      console.log(data)
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
            
            /*the user changes the value in the dropdown-menu, then 
             * the change event is triggered
             * the new current value (self.value) gets stored via codemirror in the xml-instance*/
            menuliste.change( function () {            	              
            	var self = this;               
            	           
                var attrvalue = self.value;
                var nodeset = $(document).xrx.nodeset(cm.getInputField());
                var controlId = nodeset.only.levelId;
                var relativeId = token.state.context.id.split('.').splice(1);
                var contextId = controlId.concat(relativeId);                
                var attributes = new AttributesImpl();                
                attributes.addAttribute(undefined, name, name, undefined, attrvalue);
                aktuell.qName = name,                
                aktuell.value = attrvalue;
                
                /* hier wird bei jedem Value change dann auch das selected Attribut angepasst! */
                var findselected = $(".xrx-attributes").find("option[name =" + name + "]");
                findselected.removeAttr("selected", "selected");
                var setselected = $("option[value =" + attrvalue + "]");
                setselected.attr('selected', 'selected');            
              
                function findCherries(edAttr){
                	console.log("was wird übergeben?");
                	console.log(edAttr);
                	return edAttr.qName == name;
                }
                console.log("Finde die Wacholderbeeren!!!!!");
               var objectindex = editedAttributes.findIndex(findCherries);
               console.log(objectindex);
               if (objectindex > -1){
            	   editedAttributes.splice(objectindex,1, {qName: name, value: attrvalue});
                   console.log(editedAttributes); 
               }
               else {
            	   console.log("wenn das attr noch nicht vorhanden ist wirds gepusht!!!!!");
            	   editedAttributes.push({qName: name, value: attrvalue});
               }

                console.log("die editedAttributes in the change funktion");
                console.log(editedAttributes);
             //nun sind die editedAttributes wieder aktuell
          
                function eruieren(){
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
                            var enable = $("div:contains('" + proof + "')", "." + uiSuggestedAttributesDivClass).draggable("enable");
                        }                    
                    } 
                return enable	
                }
               function rowremove(gewissesAttr, editedAttributes){
             	   var sein = new AttributesImpl();                        
                    sein.addAttribute(undefined, gewissesAttr, gewissesAttr, undefined, '');                           
                    var row = $("div:contains('" + gewissesAttr + "')", "." + uiEditAttributesDivClass);
                    row.remove();
                    function findCherries(edAttr){
                    	console.log("was wird übergeben?");
                    	console.log(edAttr);
                    	return edAttr.qName == gewissesAttr;
                    }
                    console.log("Finde die Kirschen");
                   var objectindex = editedAttributes.findIndex(findCherries);
                   console.log(objectindex);
                   if (objectindex > -1){
                	   editedAttributes.splice(objectindex,1);
                       console.log(editedAttributes); 
                   }               
                                   
                    $('.xrx-instance').xrxInstance().deleteAttributes(contextId, sein);
                  
                 
                    return editedAttributes;
                  console.log("rowremove function: test if editedAttr korrekt");
                  console.log(editedAttributes);
             }       
               
                /* attribute 'indexName' can have value illurk-vocabulary,      
                 * if it is 'illurk-vocabulary' the controlled vocabulary for the attributes lemma and sublemma is active. 
                 * 
                 * 
                 * 
                 * 
                 * */ 
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
               console.log("Vokabeljau in der change funktion?");
               console.log(vocabulartest);          
                                        	  
               if(vocabulartest != undefined){
                          	controlledVoc = true;
                          	 $("div.forms-mixedcontent-suggested-attribute").addClass("ui-state-disabled");             
                          	 var x = rowremove('lemma', editedAttributes);              
                             $("div[title='lemma']").draggable("enable");
                          }                    
                    
              
//                if ((attrvalue == 'illurk-vocabulary')| ((attrvalue == 'IllUrkGlossar'))) { 
//                	
//            		controlledVoc = true;
//            	    $("div.forms-mixedcontent-suggested-attribute").addClass("ui-state-disabled");             
//                	var x = rowremove('lemma', editedAttributes);              
//                    $("div[title='lemma']").draggable("enable");
//                    
//                }       
                if (name == 'lemma') {                                
                        controlledVoc = true; 
                        var y = rowremove('sublemma', editedAttributes);
                        var z = eruieren();
             
                }           
                
                /* Set the new value of the attributes in the instance. The function replaceAttrbiuteValue of the
                 * jquery wigdet xrxInstance.js is called */                
                $('.xrx-instance').xrxInstance().replaceAttributeValue(contextId, attributes);
            });
            //end of change function
            
            
            $(menuliste).menu();
            
            console.log("die editedAttributes am ende der newEditAttrfunction funktion");
            console.log(editedAttributes);
            return newEditAttribute;
        },      
        /*End of _newEditAttribute */    
        
        
        
        
        /*the Delete Method: in GUI you can click a trash-icon*/
        _trashIconClickable: function (trashIcon, editAttribute, inhalt) {          
        	controlledVocabularies = JSON.parse($("div.available-controlled-vocabularies").text());
            var self = this,            
            suggestedAttributes = self.options.suggestedAttributes,            
            editedAttributes = self.options.editedAttributes,           
            cm = self.options.cm,            
            token = self.options.token;
          console.log("bin die trashIconClickable methode");
          console.log(editAttribute);
          console.log(editedAttributes);
          console.log(inhalt);
            /*when the click event is triggered, the function takes the the name of the attribute 
             * that is going to be deleted out of the input Element or out of the editedAttributes
             * the arrays 'verw' and 'wert' are updated and returned in order to be used by the method _newEditAttribute */
            trashIcon.click(function (event) {
            	var self = this;
                if ($($(editAttribute).find("input")).length == 1) {                    
                    var name = $($(editAttribute).find("input")).attr("name");  
                    var value = ($(editAttribute).find("input")).text();
                } else {         
                    var name = editAttribute[0].firstElementChild.firstChild.firstChild.data;
                }             
                console.log(" die trashIcon.click funktion wurde ausgelöst!");
                console.log(self);
                console.log(name); //name of deleted Attribute
                console.log(editAttribute);// whole row in the interface table
                console.log(editedAttributes);
                console.log(inhalt);//value of deleted Attribute
                
                function findCherries(edAttr){
                	console.log("was wird übergeben?");
                	console.log(edAttr);
                	return edAttr.qName == name;
                }
                console.log("Finde die Kirschen");
               var objectindex = editedAttributes.findIndex(findCherries);
               console.log(objectindex);
               if (objectindex > -1){
            	   editedAttributes.splice(objectindex,1);
                   console.log(editedAttributes); 
               }
                                
                var attributes = new AttributesImpl();                
                attributes.addAttribute(null, name, name, undefined, "");
                
                var findselect = $(editAttribute).find("select");
                /*if indexName is going to be deleted than it is checked if indexName was used with the cv.
                 *If this is the case, the attributes lemma and sublemma have to be deleted too.
                 *When all 3 attributes are deleted they are set to be draggable again.*/
                if ((name == 'indexName') && ($(editAttribute).find("select").length == 1)) {
                	
               	var x = rowremove('lemma', editedAttributes);
                var y = rowremove('indexName', editedAttributes);
                var z = eruieren();
                
                    $("div[title='indexName']", "." + uiSuggestedAttributesDivClass).draggable("enable");              
                
                }
                /*if lemma (used with cv) is deleted, also sublemma has to be removed.
                 * When this is done, just lemma and sublemma are set to be draggable again.*/
                if (name == 'lemma' && $(editAttribute).find("select").length == 1) { 
                	
                	var x = rowremove('lemma', editedAttributes);
                	$("div.forms-mixedcontent-suggested-attribute").addClass("ui-state-disabled");
                	$("div[title='lemma']").draggable("enable");
                }
                
                else {  
                var x = rowremove(name, editedAttributes);
                var x = eruieren();
               // $('.xrx-instance').xrxInstance().deleteAttributes(contextId, attributes);
                $("div[title='" + name + "']", "." + uiSuggestedAttributesDivClass).draggable("enable");
           
                }
                /*the attribute is removed only from the GUI*/
                editAttribute.remove();

               
                console.log(editedAttributes);
                console.log(suggestedAttributes);
                
            });
            
            function eruieren(){
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
                        var enable = $("div:contains('" + proof + "')", "." + uiSuggestedAttributesDivClass).draggable("enable");
                    }                    
                } 
            return enable	
            }
           function rowremove(gewissesAttr, editedAttributes){
         	   var sein = new AttributesImpl();                        
                sein.addAttribute(undefined, gewissesAttr, gewissesAttr, undefined, '');                           
                var row = $("div:contains('" + gewissesAttr + "')", "." + uiEditAttributesDivClass);
                row.remove(); 

                var nodeset = $(document).xrx.nodeset(cm.getInputField());                
                var controlId = nodeset.only.levelId;                
                var relativeId = token.state.context.id.split('.').splice(1);                
                var contextId = controlId.concat(relativeId);
                $('.xrx-instance').xrxInstance().deleteAttributes(contextId, sein);
                function findCherries(edAttr){
                	console.log("was wird übergeben?");
                	console.log(edAttr);
                	return edAttr.qName == gewissesAttr;
                }
                console.log("Finde die Kirschen");
               var objectindex = editedAttributes.findIndex(findCherries);
               console.log(objectindex);
               if (objectindex > -1){
            	   editedAttributes.splice(objectindex,1);
                   console.log(editedAttributes); 
               }

                return editedAttributes;
              
         }
          function ausblenden(gewisseAttr){
       		var blende = suggestedAttributes;                       
                   var l = blende.indexOf(gewisseAttr);
                   blende.splice(l, 1);
                   for (var j = 0; j < blende.length; j++) {
                   var dis = $("div[title='" + blende[j] + "']", "." + uiMainDivId).draggable("disable");
                   }
                   return dis;
                   }
            
           return editedAttributes;
        },
        
        //End of _trashIconClickable
        
        
        /* method to switch off/on the cv
         * IDEA: maybe better to construct the whole GUI part from _newEditAttribute in this method,
         * because easier to handle the setting of the attributes*/
        _onoffButton: function (controlledVocButton, editedAttributes) {
        	controlledVocabularies = JSON.parse($("div.available-controlled-vocabularies").text());
            var self = this,            
            suggestedAttributes = self.options.suggestedAttributes,            
            editedAttributes = self.options.editedAttributes,            
            cm = self.options.cm,            
            token = self.options.token;
            
            console.log("Aufbau des on off Buttons");
            console.log(self);
            console.log(editedAttributes);
            controlledVocButton.append($('<span id="onoff"></span>').css("float", "right").append($('<input type="radio" name="radio" id="on" value="on"/><label for="on" class="plug"> On </label>').css("font-size", "0.5em")).            
            append($('<input type="radio" name="radio" id="off" value="off" checked="checked"/><label class="plug" for="off"> Off </label>').css("font-size", "0.5em")))
            
            controlledVocButton.find("span").buttonset();   

           
            function eruieren(){
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
                        var enable = $("div:contains('" + proof + "')", "." + uiSuggestedAttributesDivClass).draggable("enable");
                    }                    
                } 
            return enable	
            }
            
            
            function rowremove(gewissesAttr, editedAttributes){
      
            	 var nodeset = $(document).xrx.nodeset(cm.getInputField());                
                 var controlId = nodeset.only.levelId;                
                 var relativeId = token.state.context.id.split('.').splice(1);                
                 var contextId = controlId.concat(relativeId);
          	   	 var sein = new AttributesImpl();                        
                 sein.addAttribute(undefined, gewissesAttr, gewissesAttr, undefined, '');                           
                 var row = $("div:contains('" + gewissesAttr + "')", "." + uiEditAttributesDivClass);                     
                 row.remove(); 
                 function findCherries(edAttr){
                 	console.log("was wird übergeben?");
                 	console.log(edAttr);
                 	return edAttr.qName == gewissesAttr;
                 }
                 console.log("Finde die Kirschen");
                var objectindex = editedAttributes.findIndex(findCherries);
                console.log(objectindex);
                if (objectindex > -1){
             	   editedAttributes.splice(objectindex,1);
                    console.log(editedAttributes); 
                }
                 $('.xrx-instance').xrxInstance().deleteAttributes(contextId, sein);            
               
          }
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
                
                	var z = eruieren();
                   console.log(editedAttributes);

                	   var x = rowremove('indexName', editedAttributes);
                	   var y = rowremove('lemma', editedAttributes);                	
                	   
                	   $("div[title='indexName']", "." + uiSuggestedAttributesDivClass).draggable("enable");
                	   $("div[title='lemma']", "." + uiSuggestedAttributesDivClass).draggable("enable");
      
                   console.log("Das sind die neuen EditedAttributes nach der For-Schleife!");
                   console.log(editedAttributes);

                    controlledVoc = false;

           
                } else { 
                    var x = rowremove('indexName', editedAttributes);
             	   var y = rowremove('lemma', editedAttributes);
             	   controlledVoc = true;
            	   $("div[title='indexName']", "." + uiSuggestedAttributesDivClass).draggable("enable");
            	   $("div[title='lemma']", "." + uiSuggestedAttributesDivClass).draggable("disable");
                }
            });            
            return controlledVoc;
        },
        
        
        /* Method to be able to drag the suggestedAttributes in the GUI*/
        _suggestedAttributeDraggable: function (suggestedAttribute) {
            
            var self = this;          
            suggestedAttribute.draggable({                
                containment: "." + uiMainDivId,               
                revert: "invalid",                
                cursor: "move",                
                helper: "clone",                
                start: function (event, ui) {                    
                    $("." + uiDroppableAttributeDivClass, "." + uiMainDivId).addClass("edit-attributes-droppable-active");                    
                    suggestedAttribute.addClass("suggested-attribute-draggable-disabled");                },
                
                stop: function (event, ui) {                    
                    $("." + uiDroppableAttributeDivClass, "." + uiMainDivId).removeClass("edit-attributes-droppable-active");                    
                    suggestedAttribute.removeClass("suggested-attribute-draggable-disabled");
                }
            });
        },
        
        //End _suggestedAttributeDraggable
        
        
        
        /* Method enabling the dropping of the attributes in the GUI.
         *  'div.forms-mixed-content-attribute-droppable' in the GUI is the dashed line field, where the suggested attr are dropped in */        
        _attributeDroppable: function (droppableAttribute) {            
            var self = this,            
            cm = self.options.cm,            
            token = self.options.token,            
            elementName = self.options.elementName,
            suggestedAttributes = self.options.suggestedAttributes,
            editedAttributes = self.options.editedAttributes;
            
            droppableAttribute.droppable({                
                accept: "." + uiSuggestedAttributeDivsClass,                
                drop: function (event, ui) {                    
                    
                    var draggable = ui.draggable,                    
                    qName = draggable.attr("title"),                    
                    label = draggable.text(),                    
                    editWidget = self._newEditAttribute(qName, label, "");                    
                    var attributes = new AttributesImpl();                    
                    attributes.addAttribute(null, qName, qName, undefined, "");                    
                    $("." + uiEditAttributesDivClass, "." + uiMainDivId).append(editWidget);                  
                    draggable.draggable("disable");                    
                    
                    var nodeset = $(document).xrx.nodeset(cm.getInputField());                    
                    var controlId = nodeset.only.levelId;                    
                    var relativeId = token.state.context.id.split('.').splice(1);                    
                    var contextId = controlId.concat(relativeId);
                    
                    $('.xrx-instance').xrxInstance().insertAttributes(contextId, attributes);
                    
                    editedAttributes.push({qName: qName, value: ""});
                    console.log("drop it like its hot");
                    console.log(editedAttributes);
                    
                }
            });
        },
        
        //End _attributeDroppable
        
        
        
        hide: function () {
        }
    });
})(jQuery);