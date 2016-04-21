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
    var verw =[];
    var wert =[];
    
    
    
    $.widget("ui.xrxAttributes", {
        
        
        options: {
            elementName: null,
            suggestedAttributes: null,
            editedAttributes: null,
           // controlledVoc:false,
            cm: null,
            token: null
        },
        /* option properties get values from codemirror.mode.visualxml.js*/
        
        
        _create: function () {
            var self = this,
            elementName = self.options.elementName,
            suggestedAttributes = self.options.suggestedAttributes,
            editedAttributes = self.options.editedAttributes,
            //controlledVoc = false,
                        
            mainDiv = $('<div></div>').attr("class", uiMainDivId),
            
            editAttributesDiv = $('<div></div>').addClass(uiEditAttributesDivClass).addClass(uiFormsTableClass),
            droppableAttributeDiv = $('<div">&#160;</div>').addClass(uiDroppableAttributeDivClass),
            suggestedAttributesDiv = $('<div></div>').addClass(uiSuggestedAttributesDivClass),
            controlledVocButton = $('<div>Controlled Vocabulary</div>').addClass('controlledVocabulary').css("text-align", "right")
            
            /*when editor is opened, look if there are already attributes set,
             * then append to the div.forms-mixedcontent-edit-attributes the attributes that already exist.  */
            
            for (var i = 0 in editedAttributes) {
                editAttributesDiv.append(self._newEditAttribute(editedAttributes[i].qName, $(document).xrxI18n.translate(editedAttributes[i].qName, "xs:attribute"), editedAttributes[i].value));
            }
            
            /*xrx-attributes class gets method _attributeDroppable*/
            self._attributeDroppable(droppableAttributeDiv);
     
            
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
                    return dis;
                    }
                        
            /*In the GUI already set (edited) Attributes are made unable to drag from the div-box with the possible (suggested) Attributes.
             * the arrays verw and wert are filled with the values of the editedAttributes property.*/
            for (var i = 0; i < editedAttributes.length; i++) {                    
            	  if (verw.indexOf(editedAttributes[i].qName)== -1){
                  	verw.push(editedAttributes[i].qName);	
                  	}                    
                if (wert.indexOf(editedAttributes[i].value)== -1){
                	wert.push(editedAttributes[i].value);	
                	}
            }
            /* These if-else-conditions are necessary to lead the user in the case the user uses the cv
             * when indexName is set with the value arthistorian, then lemma and sublemma are the
             * only draggable attributes. To do so in var blende are all the attributes, 
             * which are set to 'draggable disable'
             * when indexName and lemma are already set then just sublemma will be draggable.
             * in the else-condition all attributes, which are not edited, are set to be draggable. */
                if (verw.indexOf('indexName') > -1
                			&& wert.indexOf('arthistorian') > -1
                			&& verw.indexOf('lemma') == -1 
                    		&& verw.indexOf('sublemma') == -1)
                 {                  	
                	
                	/* Meiner Meinung nach muss nur lemma da rausgenommen werden,
                	 * weil die anderen ja noch nicht gesetzt sind.*/
                	var x = ausblenden('lemma');
                	//var y = ausblenden('sublemma');
                
                }
                else if (verw.indexOf('indexName') > -1
                			&& wert.indexOf('arthistorian') > -1
                			&& verw.indexOf('lemma') > -1 
                			&& verw.indexOf('sublemma')==-1) {
              
                	var x = ausblenden('sublemma');              
                }
                /*else if (controlledVoc == true && verw.indexOf('indexName')== -1){
                	$("div[title='lemma']", "." + uiMainDivId).draggable("disable");
                	$("div[title='sublemma']", "." + uiMainDivId).draggable("disable");
                }*/
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
        	
            var self = this,
            cm = self.options.cm,
            token = self.options.token,
            editedAttributes = self.options.editedAttributes,
            suggestedAttributes = self.options.suggestedAttributes,
            elementName = self.options.elementName,
            
            /* variables to define the GUI */
            newEditAttribute = $('<div></div>').addClass(uiFormsTableRowClass).addClass(uiEditAttributeDivClass),
            newEditAttributeLabel = $('<div><span title="' + name + '" >' + label + '<span></div>').addClass(uiFormsTableCellClass),
            newEditAttributeInput = $('<input></input>').addClass(uiFormsTableCellClass).attr("value", value).attr("name", name),
            newEditValuelabel = $('<div><span title="' + name + '" >' + label + '<span></div>').addClass(uiFormsTableCellClass),
            menuliste = $('<select></select>').attr('class', 'choose').addClass(uiFormsTableCellClass),
            newEditAttributeTrash = $('<div><span class="ui-icon ui-icon-trash"/></div>').
            addClass(uiFormsTableCellClass);
            /* die aktuell ausgewählten Attribute werden in das aktuell objekt geschrieben,
             * nun hat aktuell die gleichen properties, wie die Objekte in editedAttributes array.*/
            aktuell.qName = name,
            aktuell.value = value;            
                      
            for (var i = 0; i < editedAttributes.length; i++) {                    
          	  if (verw.indexOf(editedAttributes[i].qName)== -1){
                	verw.push(editedAttributes[i].qName);
                	wert.push(editedAttributes[i].value);
                	}                   	
          }
         
            /* if the new attribute is not already in the array, 
             * then the current value is pushed to the arrays verw and wert and to editedAttributes
             * wenn das neue Attribut nicht im Array steht, dann wird zu den editedAttributes gepusht.*/
            if (verw.indexOf(name) == -1) {         
                verw.push(name);
                wert.push(value);             
                //var editnew = editedAttributes.push(aktuell);

            }         
                
                /* it has to be proofed if from the last use of the attribute widget,
                 * the user used the cv or not.
                 * if in the editedAttributes is the attr indexName with the value 'arthistorian'
                 * then the controllevVoc is true.
                 * Has to be changed, when the cv is used for other descriptions too.
                 * Till now there is only 'arthistorian'.  
               */
               if ((elementName == "cei:index") && ((name == "lemma") | (name == "sublemma") | (name == "indexName"))){
            	   for (var i=0;i < editedAttributes.length; i++){
                   	if (editedAttributes[i].qName == 'indexName' && editedAttributes[i].value == 'arthistorian'){
                   		controlledVoc = true;
                   	}
                   
                   }  
               }
               else {
            	   controlledVoc = false;
  
            	  
               }
           
           
           
            /* Array [ "indexName", "lemma", "sublemma" ] mainkeys
				Object { indexName: Array[1], lemma: Array[3], sublemma: Array[3] } suggestedVal
             * 
             * In the following lines the GUI is constructed
             * if controlledVoc is true then menuliste (is a dropdown menu)is implemented
             * if false newEditAttributeInput (is an inputfield) is created.*/
            if (elementName == "cei:index") {
                                 
                if ((controlledVoc == true) && ((name == "lemma") | (name == "sublemma") | (name == "indexName")))
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
            
            self._trashIconClickable(newEditAttributeTrash, newEditAttribute, aktuell.value);
            
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
             * sugname are the values of the keys,
             * they can be strings or arrays.
             * That's why the function proofing is necessary.
             * In the 'newli' variable the option elements with the possible values
             * are appended to 'menuliste'.*/
            
            function setoptioninSelect(name) {
            	if (name == "indexName"){
            		var einf = $("<option> --- </option>");
            		menuliste.append(einf);
            		var iName = ['arthistorian', 'glossary'];
            		for (var i=0; i<iName.length; i++){
            			var newli = $('<option>' + iName[i] + '</option>')
            			.addClass(uiSuggestedValueDivsClass).attr("title", iName[i]).attr("value", iName[i]).attr("name", name);
                		if (iName[i] == value){
               			 newli.attr("selected", "selected");
               		}
                		
                		menuliste.append(newli);
            		}
            		
            	}          
                	else {
                		var einf = $("<option> --- </option>");
                        menuliste.append(einf);
                        
                        if (name == 'lemma'){
                        	var lemmawert = '';
                        }
                        else {
                        	var sucheOptions = $(".forms-mixedcontent-edit-attributes").children().find("option[selected]");
                     
                        sucheOptions.each( function(index) {                        
                            var attrname = $(this).attr('name');
                          if (attrname == "lemma"){                        	  
                        	  attributswert = $(this).attr('title');                        	 
                          }
                        
                            });
                        var lemmawert = attributswert;
                        }
                        /*  
                         * var sucheOptions = $(".forms-mixedcontent-edit-attributes").children().find("option[selected]");
                         *  die Klasse xrx-language-for-skos wurde serverseitig im widget 
                        * my-collection-charter-illurk und
                        * my-collection-charter-edit eingeführt,
                        * um die Sprache des Users mit der Sprache des ControllVoc
                        * abzugleichen.                        * 
                        */
                        var sprachwert = $(".xrx-language-for-skos").text();                       
                        $.ajax({     
                            url: "/mom/service/editMomgetControlledVoc",
                            type:"GET",      
                            //contentType: "application/xml",     
                            dataType: "json", 
                            data: {lemma:lemmawert, sprache:sprachwert},
                            success: function(data, textStatus, jqXHR)
                            {                           
                          for (var i in data){                            		
                            		var valeur = data[i];
                            		console.log(valeur);
                            		var newli = $('<option>' + valeur + '</option>')
                        			.addClass(uiSuggestedValueDivsClass).attr("title", valeur).attr("value", i).attr("name", name);
                            		if (i == value){
                           			 newli.attr("selected", "selected");
                           		}
                            		menuliste.append(newli);
                            }                        
                                                         
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
            menuliste.change(function (event) {            	              
                self = this;                
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

                
            var liste = [];
            for (i in editedAttributes){            	        	
             liste.push(editedAttributes[i].qName); //müsste so sein wie verw!!!!             
            } 
            for ( var i=0; i<liste.length; i++){
            	if (liste.indexOf(name) == -1){
            		editedAttributes.push({qName:name, value:attrvalue});
            		
            	}
            	else{
            	
            		editedAttributes[i].value = attrvalue;
            	}
            }
            console.log(liste);
            console.log(editedAttributes); //nun sind die editedAttributes wieder aktuell
            	
            	
            	
                
                /* the array verw and wert are updated with the new value,
                 * maybe this is not a general solution,
                 * because it is presumed that it is 
                 * the last value in the array that ist going to be updated.*/
                if (verw.indexOf(name) == -1) {               	
                        
                    verw.push(name);
                    var l = wert.length;
                    wert.splice(wert.length-1,1,attrvalue);                   
                  
                }
             
               
                /* the arrays are emptied, and filled with aktuell.qName and value
                 * because the are necessary in the case the event change is triggered again.
                 * Attention: these values are still not in the editedAttributes Object,
                 * this happens when a new plugin-method is called.*/
                else {                
                	verw.splice(0, verw.length, aktuell.qName);
                	wert.splice(0, wert.length, aktuell.value);
                } 
                /* attribute 'indexName can have value glossary,
                 * then the controlled Vocabulary is switched off again.
                 * 
                 * */
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
                        var i = verw.indexOf(gewissesAttr); 
                        verw.splice(i,1);
                    row.remove(); 
                                   
                    $('.xrx-instance').xrxInstance().deleteAttributes(contextId, sein);
                    var attr = editedAttributes.indexOf(gewissesAttr);
                    editedAttributes.splice(attr, 1);
                 
                    return editedAttributes;
                  
             }
                
                if (attrvalue == 'glossary'){
                	
                	 var x = rowremove('lemma', editedAttributes);
                     var y = rowremove('sublemma', editedAttributes);
                     var x = eruieren();              
                    controlledVoc = false;
                }
                
                
                /* attribute 'indexName' can have value arthistorian,      
                 * if it is 'arthistorian' the controlled vocabulary for the attributes lemma and sublemma is active. */              
                if (attrvalue == 'arthistorian') { 
                	
            		controlledVoc = true;
            		
                	$("div", "." + uiSuggestedAttributeDivsClass).each(function () {                        
                     $("div", "." + uiSuggestedAttributesDivClass).addClass("ui-state-disabled");
                     
                    var x = rowremove('lemma', editedAttributes);
                    var y = rowremove('sublemma', editedAttributes);                           
                	});
                
                    $("div[title='lemma']", "." + uiSuggestedAttributesDivClass).draggable("enable");
                }
                /*when lemma is changed, then sublemma is deleted.
                 * sublemma is the only attribute that is set to be draggable 
                 * when sublemma is changed, then through the info of the nodeset (queried 
                 * by a function in the XPath.js) which is string, it is possible to find out
                 * which value lemma has. This is necessary because editedAttributes doesn't
                 * provide this info.*/
                if (name == 'lemma') {                                
                        controlledVoc = true;                        
                        $("div", "." + uiSuggestedAttributesDivClass).not("div[title='sublemma']").addClass("ui-state-disabled");                        
                        $("div[title='sublemma']", "." + uiSuggestedAttributesDivClass).draggable("enable");
                        var y = rowremove('sublemma', editedAttributes);
             
                } else if (name == 'sublemma') {
                	
                	var x = eruieren();            
                	
                } //if wird geschlossen
                
                /* Set the new value of the attributes in the instance. The function replaceAttrbiuteValue of the
                 * jquery wigdet xrxInstance.js is called */                
                $('.xrx-instance').xrxInstance().replaceAttributeValue(contextId, attributes);
            });
            //end of change function
            
            
            $(menuliste).menu();
           
            return newEditAttribute;
        },      
        /*End of _newEditAttribute */       
        
        /*the Delete Method: in GUI you can click a trash-icon*/
        _trashIconClickable: function (trashIcon, editAttribute, inhalt) {          
            
            var self = this,            
            suggestedAttributes = self.options.suggestedAttributes,            
            editedAttributes,   //ich glaube das kann ruhig leer sein zuerst!         
            cm = self.options.cm,            
            token = self.options.token;
          
            /*when the click event is triggered, the function takes the the name of the attribute 
             * that is going to be deleted out of the input Element or out of the editedAttributes
             * the arrays 'verw' and 'wert' are updated and returned in order to be used by the method _newEditAttribute */
            trashIcon.click(function (event) {
                if ($($(editAttribute).find("input")).length == 1) {                    
                    var name = $($(editAttribute).find("input")).attr("name");  
                    var value = ($(editAttribute).find("input")).text();
                } else {         
                    var name = editAttribute[0].firstElementChild.firstChild.firstChild.data;
                }             

                var liste = [];
              
                var sucheInput = $(".forms-mixedcontent-edit-attributes").children().find("input");
                
                sucheInput.each( function(index) {
                    var attrname = $(this).attr('name');
                  
                    var attrvalue = $(this).attr('value');
                    	liste.push({qName : attrname ,
                    				value : attrvalue
                    	});                   
                    	
                    });                
                
                var sucheOptions = $(".forms-mixedcontent-edit-attributes").children().find("option[selected]");
                
                sucheOptions.each( function(index) {
                    var attrname = $(this).attr('name');
                  
                    var attrvalue = $(this).attr('title');
                    	liste.push({qName : attrname ,
                    				value : attrvalue
                    	});                   
                    	
                    });
              editedAttributes = liste; //ich glaub das muss hier global gesetzt werden, sonst gibts die editedAttrbutes nicht.

                
                var attributes = new AttributesImpl();                
                attributes.addAttribute(null, name, name, undefined, "");
       
                for (i in editedAttributes){
                	
                    var raus = editedAttributes[i];                
                    if (raus.qName == name){
     
                    	var ind = editedAttributes.indexOf(raus);
   
                    	editedAttributes.splice(ind,1);
                    }                    
                } 
                
                var suggestedAttributesNamen =[];            
                
                for (var j = 0; j < suggestedAttributes.length; j++) {                    
                    var index = verw.indexOf(suggestedAttributes[j]);                    
                    if (index == -1) {                        
                        suggestedAttributesNamen.push(suggestedAttributes[j]);
                    }
                } 
                console.log(suggestedAttributesNamen);
                if (verw.indexOf(name) != -1) {                    
                    var i = verw.indexOf(name); 
                    var b = wert.indexOf(inhalt);
                    verw.splice(i,1);                    
                    wert.splice(b,1);
                    editedAttributes.splice(i, 1);
                }
             
               
                
                var nodeset = $(document).xrx.nodeset(cm.getInputField());                
                var controlId = nodeset.only.levelId;                
                var relativeId = token.state.context.id.split('.').splice(1);                
                var contextId = controlId.concat(relativeId);                
                var findselect = $(editAttribute).find("select");
                /*if indexName is going to be deleted than it is checked if indexName was used with the cv.
                 *If this is the case, the attributes lemma and sublemma have to be deleted too.
                 *When all 3 attributes are deleted they are set to be draggable again.*/
                if ((name == 'indexName') && ($(editAttribute).find("select").length == 1)) {                    
     
                
               	var x = rowremove('lemma', editedAttributes);
                var y = rowremove('sublemma', editedAttributes);
                var x = eruieren();
                
                    $("div[title='indexName']", "." + uiSuggestedAttributesDivClass).draggable("enable");
                    $("div[title='lemma']", "." + uiSuggestedAttributesDivClass).draggable("disable");
                    $("div[title='sublemma']", "." + uiSuggestedAttributesDivClass).draggable("disable");
             
                
                }
                /*if lemma (used with cv) is deleted, also sublemma has to be removed.
                 * When this is done, just lemma and sublemma are set to be draggable again.*/
                if (name == 'lemma' && $(editAttribute).find("select").length == 1) { 
                	
                	var x = rowremove('lemma', editedAttributes);
                    var y = rowremove('sublemma', editedAttributes);
                    var z = eruieren();
                    var w = ausblenden('sublemma');
                    $("div[title='sublemma']", "." + uiSuggestedAttributesDivClass).draggable("disable");
                  
                }
                /*if sublemma is deleted, just sublemma should be set to be draggabel again.
                 * Important: sublemma depends on the value of lemma.
                 * in order to pass on the value the 'wert'array is updated with the current value of lemma. */
                if (name == 'sublemma' && $(editAttribute).find("select").length == 1) {                	
                	var regular = nodeset.only.xml.match(/lemma=".*?"/);
                    var reg = regular.join();
                    var lemmaw = reg.slice(7, reg.length -1);
  
                    if(wert.indexOf(lemmaw)== -1){
                    	 wert.push(lemmaw);
                    }                
                	var sein = new AttributesImpl();                        
                    sein.addAttribute(undefined, 'sublemma', 'sublemma', undefined, '');
                    var row = $("div:contains('sublemma')", "." + uiEditAttributesDivClass);
                    row.remove();
                    $('.xrx-instance').xrxInstance().deleteAttributes(contextId, sein);
                    for (var i = 0; i < suggestedAttributes.length; i++){
                    	$("div[title='" + suggestedAttributes[i] + "']", "." + uiMainDivId).draggable("disable");
                    	}                    
                    $("div[title='sublemma']", "." + uiSuggestedAttributesDivClass).draggable("enable");
                }
                /*That is the default case. Attribute is removed from the instance and in GUI set draggable again.*/
                else {              
                $('.xrx-instance').xrxInstance().deleteAttributes(contextId, attributes);
                $("div[title='" + name + "']", "." + uiSuggestedAttributesDivClass).draggable("enable");
           
                }
                /*the attribute is removed only from the GUI*/
                editAttribute.remove();

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
                    var i = verw.indexOf(gewissesAttr); 
                    verw.splice(i,1);
                row.remove(); 

                var nodeset = $(document).xrx.nodeset(cm.getInputField());                
                var controlId = nodeset.only.levelId;                
                var relativeId = token.state.context.id.split('.').splice(1);                
                var contextId = controlId.concat(relativeId);
                $('.xrx-instance').xrxInstance().deleteAttributes(contextId, sein);
                var attr = editedAttributes.indexOf(gewissesAttr);
                editedAttributes.splice(attr, 1);

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
            
            var self = this,            
            suggestedAttributes = self.options.suggestedAttributes,            
            editedAttributes,            
            cm = self.options.cm,            
            token = self.options.token;            
            
            controlledVocButton.append($('<span id="onoff"></span>').css("float", "right").append($('<input type="radio" name="radio" id="on" value="on"/><label for="on" class="plug"> On </label>').css("font-size", "0.5em")).            
            append($('<input type="radio" name="radio" id="off" value="off" checked="checked"/><label class="plug" for="off"> Off </label>').css("font-size", "0.5em")))
            
            controlledVocButton.find("span").buttonset();   

            
            function rowremove(gewissesAttr, editedAttributes){
      
            	 var nodeset = $(document).xrx.nodeset(cm.getInputField());                
                 var controlId = nodeset.only.levelId;                
                 var relativeId = token.state.context.id.split('.').splice(1);                
                 var contextId = controlId.concat(relativeId);
          	   var sein = new AttributesImpl();                        
                 sein.addAttribute(undefined, gewissesAttr, gewissesAttr, undefined, '');                           
                 var row = $("div:contains('" + gewissesAttr + "')", "." + uiEditAttributesDivClass);                              
                 for (i in editedAttributes){
                	 var index = editedAttributes[i].qName;
              
                	 if (i > -1) {
                  
                    	 editedAttributes.splice(i, 1);
                     }
                 }                         
                 row.remove(); 
                  
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
                    
                    var liste = [];
                  
                    var sucheInput = $(".forms-mixedcontent-edit-attributes").children().find("input");
                    
                    sucheInput.each( function(index) {
                        var attrname = $(this).attr('name');
 
                        var attrvalue = $(this).attr('value');
                        	liste.push({qName : attrname ,
                        				value : attrvalue
                        	});                   
                        	
                        });                
                    
                    var sucheOptions = $(".forms-mixedcontent-edit-attributes").children().find("option[selected]");
                    
                    sucheOptions.each( function(index) {
                        var attrname = $(this).attr('name');

                        var attrvalue = $(this).attr('title');
                        	liste.push({qName : attrname ,
                        				value : attrvalue
                        	});                   
                        	
                        });
                   editedAttributes = liste; //ich glaub das muss hier global gesetzt werden, sonst gibts die editedAttrbutes nicht.

                   for (var i = 0; i < editedAttributes.length; i++){
                	   if ((editedAttributes[i].qName == 'indexName')&& (editedAttributes[i].value == 'arthistorian')){
                	   var x = rowremove('indexName', editedAttributes);
                	   var y = rowremove('lemma', editedAttributes);
                	   var z = rowremove('sublemma', editedAttributes);
                	   
                	   $("div[title='indexName']", "." + uiSuggestedAttributesDivClass).draggable("enable");
                	   $("div[title='lemma']", "." + uiSuggestedAttributesDivClass).draggable("enable");
                	   $("div[title='sublemma']", "." + uiSuggestedAttributesDivClass).draggable("enable");
                	 
                	   }  
                	   
                   }
                   console.log("Das sind die neuen EditedAttributes nach der For-Schleife!");
                   console.log(editedAttributes);
                	               	
                   var inallSpans = $("div", "." + uiEditAttributeDivClass).find("span").not(".ui-icon");                    
                    var titelarray =[];
                    
                    for (var i = 0; i < inallSpans.length; i++) {                        
                        var at = inallSpans[i].title;                        
                        console.log(at);                        
                        if (at !== undefined && at != "") {                            
                            titelarray.push(at);
                        }
                    }
       
                    var suggestedAttributesNamen =[];

                    for (var j = 0; j < suggestedAttributes.length; j++) {                        
                        var index = titelarray.indexOf(suggestedAttributes[j]);                        
                        if (index == -1) {                            
                            suggestedAttributesNamen.push(suggestedAttributes[j]);
                        }
                    }

                    for (var i = 0; i < suggestedAttributes.length; i++){
                    	
                    		$("div[title='" + suggestedAttributes[i] + "']", "." + uiSuggestedAttributesDivClass).draggable("disable");                   	
                    }
                    for (var i = 0; i < suggestedAttributesNamen.length; i++) {                        
                        $("div[title='" + suggestedAttributesNamen[i] + "']", "." + uiSuggestedAttributesDivClass).draggable("enable");
                    }
                    
                    controlledVoc = false;

           
                } else { 

                	controlledVoc = true;
                	var inallSpans = $("div", "." + uiEditAttributeDivClass).find("span").not(".ui-icon");                    
                    var titelarray =[];
                    
                    for (var i = 0; i < inallSpans.length; i++) {                        
                        var at = inallSpans[i].title;                        
                        if (at !== undefined && at != "") {                            
                            titelarray.push(at);
                        }
                    }
                    if (titelarray.indexOf('indexName')>-1){
                    	var x = rowremove('indexName');                  
                    	$("div[title='indexName']", "." + uiSuggestedAttributesDivClass).draggable("enable");
                    }
                    if (titelarray.indexOf('indexName')>-1 && titelarray.indexOf('lemma')>-1){
                    	var x = rowremove('lemma');                                                
                       // $('.xrx-instance').xrxInstance().deleteAttributes(contextId, sein);
                     
                    }
                    $("div[title='lemma']", "." + uiSuggestedAttributesDivClass).draggable("disable");
                    $("div[title='sublemma']", "." + uiSuggestedAttributesDivClass).draggable("disable");
                    controlledVoc = true;
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
         *  'div.forms-mixed-content-attribute-droppable' in the GUI is the dashed line field, where the suggested attr are droped in */        
        _attributeDroppable: function (droppableAttribute) {            
            var self = this,            
            cm = self.options.cm,            
            token = self.options.token,            
            elementName = self.options.elementName;  
            
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
 
                }
            });
        },
        
        //End _attributeDroppable
        
        
        
        hide: function () {
        }
    });
})(jQuery);