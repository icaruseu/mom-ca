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
    var controlledVoc = true;
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
            cm: null,
            token: null
        },
        /* option properties get values from codemirror.mode.visualxml.js*/
        
        
        _create: function () {
            var self = this,
            elementName = self.options.elementName,
            suggestedAttributes = self.options.suggestedAttributes,
            editedAttributes = self.options.editedAttributes,
            
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
            self._onoffButton(controlledVocButton);
            
            /* All GUI parts concerning the Attributes are appended */
            
            mainDiv.append(controlledVocButton).append(editAttributesDiv).append(droppableAttributeDiv).append(suggestedAttributesDiv);
            self.element.replaceWith(mainDiv);
            
            console.log('++++++++++++++++ WICHTIG +++++++++++++++++++++');
            console.log(elementName);
            console.log(suggestedAttributes);
            console.log(editedAttributes);
            console.log('++++++++++++++++++++++++++++');
            
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
                    var blende = suggestedAttributes;     
                    if (blende.indexOf('lemma') != -1) {
                        var l = blende.indexOf('lemma');
                        blende.splice(l, 1);
                    }                    
                    if (blende.indexOf('sublemma') != -1) {
                        var s = blende.indexOf('sublemma');
                        blende.splice(s, 1);
                    }                   
                    for (var j = 0; j < blende.length; j++) {
                        $("div[title='" + blende[j] + "']", "." + uiMainDivId).draggable("disable");
                    }
                }
                else if (verw.indexOf('indexName') > -1
                			&& wert.indexOf('arthistorian') > -1
                			&& verw.indexOf('lemma') > -1 
                			&& verw.indexOf('sublemma')==-1) {
                	var blende = suggestedAttributes;                	
                   if (blende.indexOf('sublemma') != -1) {
                        var s = blende.indexOf('sublemma');
                        blende.splice(s, 1);
                    }
                   for (var j = 0; j < blende.length; j++) {
                       $("div[title='" + blende[j] + "']", "." + uiMainDivId).draggable("disable");
                   }
                }
                else if (controlledVoc == true && verw.indexOf('indexName')== -1){
                	$("div[title='lemma']", "." + uiMainDivId).draggable("disable");
                	$("div[title='sublemma']", "." + uiMainDivId).draggable("disable");
                }
                else {
                	for (var i= 0; i < editedAttributes.length; i++){
                		$("div[title='" + editedAttributes[i].qName + "']", "." + uiMainDivId).draggable("disable");
                	}
                	
                }            
            
            /* the jquery menu is initialized. the cv is realized in a drop down menu */
            
            $(function () {
                $("#choose").menu();
            });
        },
        
        /*End of create function*/        
        
        
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
            console.log(aktuell);            
                      
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
                var editnew = editedAttributes.push(aktuell);
            }               
           
            /*variables to get the values for the controlled vocabulary */
            var jsonValues = jQuery.parseJSON($('.xrx-forms-json-attribute-valuesuggestions').text());
            /*Till now suggestedVal contains only the values of the Element 'cei:index' */
            var suggestedVal = jsonValues[elementName];                    
            /*if condition to test, if there are values available*/
            if (suggestedVal == undefined) {
                controlledVoc = false;
            } else {                
                /*mainkeys is the array with the keys to the elementname*/
                var mainkeys = Object.getOwnPropertyNames(suggestedVal).sort();
                for (var mk in suggestedVal) {
                    var mk = suggestedVal[mk];                    
                }            
                
                /* it has to be proofed if the from the last use of the attribute widget,
                 * the user used the cv or not.
                 * if in the editedAttributes is the attr indexName with the value 'arthistorian'
                 * then the controllevVoc is true.
                 * Has to be changed, when the cv is used for other descriptions too.
                 * Till now there is only 'arthistorian'.  
               */
                for (var i=0;i < editedAttributes.length; i++){
                	if (editedAttributes[i].qName == 'indexName' && editedAttributes[i].value == 'arthistorian'){
                		controlledVoc = true;
                	}
                }              
                console.log('*****************************************');
            }
            /* In the following lines the GUI is constructed
             * if controlledVoc is true then menuliste (is a dropdown menu)is implemented
             * if false newEditAttributeInput (is an inputfield) is created.*/
            if (elementName == "cei:index") {
                                 
                
                if ((controlledVoc == true) &&(mainkeys.indexOf(name) != -1)) {                	
                    for (var mk in suggestedVal) {                                   
                        	        var y = suggestedVal[mk];                        
                                    var x = setoptioninSelect(y, mk, wert); 
                        }                        
                        newEditAttributeLabel.hide();
                        newEditAttributeInput.hide();
                        newEditAttribute.append(newEditValuelabel).append(menuliste).append(newEditAttributeTrash);
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
            
            function setoptioninSelect(sugname, key, wert) {   
                if (key == name) {
                	 
                      function proofing (sugname){
                    	  for (var i = 0; i < sugname.length; i++){
                      		var kette = sugname[i];
                      		if (typeof kette === 'string'){
                      			return true;
                      			}
                      		
                    	  else {
                    		  return false;
                    	  }
                      }
              	  }
                 
                	var proofed = proofing(sugname);
                	if (proofed == true){
                		 var einf = $("<option> --- </option>");
                         menuliste.append(einf);
                		for (var i=0; i < sugname.length; i++){
                			console.log(sugname);                			
                             var newli = $('<option>' + sugname[i] + '</option>').addClass(uiSuggestedValueDivsClass).attr("title", sugname[i]).attr("value", sugname[i]);
                             if (sugname[i] == value) {
                                  newli.attr("selected", "selected");
                              }
                             menuliste.append(newli);
                             }                		 
                		 }
                	else {
                		var einf = $("<option> --- </option>");
                        menuliste.append(einf);
         			   for (var i=0; i<sugname.length;i++){
         				   var props = Object.getOwnPropertyNames(sugname[i]);

         				   for (var ii=0; ii<wert.length; ii++){
         					   var ind = wert.indexOf(props[0]);
         					   var comp = wert[ind];
         					   }
         					  if ( sugname[i][comp] != undefined){
            					   var cvalues = sugname[i][comp];
            					   for (var iii= 0; iii<cvalues.length; iii++){
            						   var newli = $('<option>' + cvalues[iii] + '</option>').addClass(uiSuggestedValueDivsClass).attr("title", cvalues[iii]).attr("value", cvalues[iii]);
                					   if (cvalues[iii] == value) {
                                           newli.attr("selected", "selected");
                                       }
                					 menuliste.append(newli);
            					   }  
            				   }
         			   }         	
         			  }                	
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
                /* the array verw and wert are updated with the new value,
                 * maybe this is not a general solution,
                 * because it is presumed that it is 
                 * the last value in the array that ist going to be updated.*/
                if (verw.indexOf(name) == -1) {               	
                    var i = verw.indexOf(name)       
                    verw.push(name);

                    var l = wert.length;
                    wert.splice(wert.length-1,1,attrvalue);
                   
                   editedAttributes.splice(i, 1, aktuell);
                }
                /* the arrays are emptied, and filled with aktuell.qName and value
                 * because the are necessary in the case the event change is triggered again.
                 * Attention: these values are still not in the editedAttributes Object,
                 * this happens when a new plugin-method is called.*/
                else {                
                	verw.splice(0, verw.length, aktuell.qName);
                	wert.splice(0, wert.length, aktuell.value);
                }                
                
                /* attribute 'indexName' can have value arthistorian,      
                 * if it is 'arthistorian' the controlled vocabulary for the attributes lemma and sublemma is active. */              
                if (attrvalue == 'arthistorian') {                  
                    $("div", "." + uiSuggestedAttributeDivsClass).each(function () {                        
                        $("div", "." + uiSuggestedAttributesDivClass).addClass("ui-state-disabled");                        
                        //  when 'indexName' is 'arthistorian' only the attribute 'lemma' is draggable                        
                        $("div[title='lemma']", "." + uiSuggestedAttributesDivClass).draggable("enable");
                    });
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
                    inallSpans = $("div", "." + uiEditAttributeDivClass).find("span").not(".ui-icon").text();
                    var allselOption = $("select").find("option[selected='selected']").text();
                    var indexsub = inallSpans.indexOf('sublemma');                   
                    if (indexsub != -1) {                                            
                        var sein = new AttributesImpl();                        
                        sein.addAttribute(undefined, 'sublemma', 'sublemma', undefined, '');                           
                        var row = $("div:contains('sublemma')", "." + uiEditAttributesDivClass);                              
                            var i = verw.indexOf('sublemma'); 
                            verw.splice(i,1);
                        row.remove();                        
                        $('.xrx-instance').xrxInstance().deleteAttributes(contextId, sein);
                        $("div[title='sublemma']", "." + uiSuggestedAttributesDivClass).draggable("enable");
                        // when 'lemma' and a selected value then the attribute 'sublemma' is draggable            
                    }
                } else if (name == 'sublemma') {              
                    var regular = nodeset.only.xml.match(/lemma=".*?"/);
                    var reg = regular.join();
                    var lemmaw = reg.slice(7, reg.length -1);
                   
                    var spantexte =[];
                    var eintrag = $(".forms-mixedcontent-edit-attribute").find("span")
                    for (var i = 0; i < eintrag.length; i++) {
                        spantexte.push(eintrag[i].textContent);
                    }
                    var proofdiv = $("div", "." + uiSuggestedAttributeDivsClass);
                    for (var i = 0; i < proofdiv.length; i++) {
                        var proof = proofdiv[i].previousSibling.data;
                        if (spantexte.indexOf(proof) == -1) {
                            /*  all (not edited) attributes from div.forms-mixedcontent-suggested-Attributes
                             *  are set draggable again */
                            $("div:contains('" + proof + "')", "." + uiSuggestedAttributesDivClass).draggable("enable");
                        }
                    }                   
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
            editedAttributes = self.options.editedAttributes,            
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
                
                var attributes = new AttributesImpl();                
                attributes.addAttribute(null, name, name, undefined, "");
                
                aktuell.qName = name,        
                aktuell.value = inhalt;                
                for (var i = 0; i < editedAttributes.length; i++) {                    
                	if (verw.indexOf(editedAttributes[i].qName)== -1){
                	verw.push(editedAttributes[i].qName);
                	wert.push(editedAttributes[i].value);
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
                    var editnew = editedAttributes.splice(i, 1);
                }
                /*the attribute is removed from the GUI*/
                editAttribute.remove();             
                console.log('-------------------------------------');
                
                var nodeset = $(document).xrx.nodeset(cm.getInputField());                
                var controlId = nodeset.only.levelId;                
                var relativeId = token.state.context.id.split('.').splice(1);                
                var contextId = controlId.concat(relativeId);                
                var findselect = $(editAttribute).find("select");
                /*if indexName is going to be deleted than it is checked if indexName was used with the cv.
                 *If this is the case, the attributes lemma and sublemma have to be deleted too.
                 *When all 3 attributes are deleted they are set to be draggable again.*/
                if ((name == 'indexName') && ($(editAttribute).find("select").length == 1)) {                    
                    var row = $("div:contains('lemma')", "." + uiEditAttributesDivClass);                    
                    var row2 = $("div:contains('sublemma')", "." + uiEditAttributesDivClass);                  
                    
                    if (row2.length > 0) {                       
                        var sein = new AttributesImpl();                        
                        sein.addAttribute(undefined, 'sublemma', 'sublemma', undefined, '');
                        var row = $("div:contains('sublemma')", "." + uiEditAttributesDivClass);            
                        row.remove();                                                
                        /*$("div[title='sublemma']", "." + uiSuggestedAttributesDivClass).draggable("disable");*/
                        /*Attribute is removed from the XML-Instance. */
                        $('.xrx-instance').xrxInstance().deleteAttributes(contextId, sein);
                    }
                    
                    if (row.length > 0) {                      
                        var sein = new AttributesImpl();                        
                        sein.addAttribute(undefined, 'lemma', 'lemma', undefined, '');                      
                        var row = $("div:contains('lemma')", "." + uiEditAttributesDivClass);                        
                        row.remove();                        
                        /* $("div[title='lemma']", "." + uiSuggestedAttributesDivClass).draggable("disable");*/
                         /*Attribute is removed from the XML-Instance. */
                        $('.xrx-instance').xrxInstance().deleteAttributes(contextId, sein);
                    }
                    var spantexte =[];
                    var eintrag = $(".forms-mixedcontent-edit-attribute").find("span")
                    for (var i = 0; i < eintrag.length; i++) {
                        spantexte.push(eintrag[i].textContent);
                    }
                    var proofdiv = $("div", "." + uiSuggestedAttributeDivsClass);
                    for (var i = 0; i < proofdiv.length; i++) {
                        var proof = proofdiv[i].previousSibling.data;
                        if (spantexte.indexOf(proof) == -1) {                       
                            $("div:contains('" + proof + "')", "." + uiSuggestedAttributesDivClass).draggable("enable");
                        }                    
                    }  
                    $("div[title='indexName']", "." + uiSuggestedAttributesDivClass).draggable("enable");
                    $("div[title='lemma']", "." + uiSuggestedAttributesDivClass).draggable("disable");
                    $("div[title='sublemma']", "." + uiSuggestedAttributesDivClass).draggable("disable");
                   
                   /* for (var i = 0; i < suggestedAttributesNamen.length; i++) {                    
                    $("div[title='" + suggestedAttributesNamen[i] + "']", "." + uiSuggestedAttributesDivClass).draggable("enable");*/
                
                }
                /*if lemma (used with cv) is deleted, also sublemma has to be removed.
                 * When this is done, just lemma and sublemma are set to be draggable again.*/
                if (name == 'lemma' && $(editAttribute).find("select").length == 1) {                
                	var sein = new AttributesImpl();                        
                    sein.addAttribute(undefined, 'lemma', 'lemma', undefined, '');
                    var row2 = $("div:contains('sublemma')", "." + uiEditAttributesDivClass);
                    if (row2.length > 0) {                        
                        var sein = new AttributesImpl();                        
                        sein.addAttribute(undefined, 'sublemma', 'sublemma', undefined, '');                       
                        var row = $("div:contains('sublemma')", "." + uiEditAttributesDivClass);                        
                        row.remove();
                        var blende = suggestedAttributes;     
                        if (blende.indexOf('lemma') != -1) {
                            var l = blende.indexOf('lemma');
                            blende.splice(l, 1);
                        }                    
                        if (blende.indexOf('sublemma') != -1) {
                            var s = blende.indexOf('sublemma');
                            blende.splice(s, 1);
                        }                   
                        for (var j = 0; j < blende.length; j++) {
                        	console.log('Die blende');
                        	console.log(blende[j]);
                            $("div[title='" + blende[j] + "']", "." + uiMainDivId).draggable("disable");
                        }
                        /*Attribute is removed from the XML-Instance. */                       
                        $('.xrx-instance').xrxInstance().deleteAttributes(contextId, sein);
                        var sub = verw.indexOf('sublemma');
                        verw.splice(sub,1);
                    }
                    $('.xrx-instance').xrxInstance().deleteAttributes(contextId, sein);
                   // $("div[title='lemma']", "." + uiSuggestedAttributesDivClass).draggable("enable");
                }
                /*if sublemma is deleted, just sublemma should be set to be draggabel again.
                 * Important: sublemma depends on the value of lemma.
                 * in order to pass on the value the 'wert'array is updated with the current value of lemma. */
                if (name == 'sublemma' && $(editAttribute).find("select").length == 1) {                	
                	var regular = nodeset.only.xml.match(/lemma=".*?"/);
                    var reg = regular.join();
                    var lemmaw = reg.slice(7, reg.length -1);
                    console.log('lemmmmw');
                    console.log(lemmaw);
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
                /*for (var i = 0; i < suggestedAttributesNamen.length; i++) {                    
                $("div[title='" + suggestedAttributesNamen[i] + "']", "." + uiSuggestedAttributesDivClass).draggable("enable");
            }*/
                }
            });
            
            return wert;
        },
        
        //End of _trashIconClickable
        
        
        /* method to switch off/on the cv
         * IDEA: maybe better to construct the whole GUI part from _newEditAttribute in this method,
         * because easier to handle the setting of the attributes*/
        _onoffButton: function (controlledVocButton) {
            
            var self = this,            
            suggestedAttributes = self.options.suggestedAttributes,            
            editedAttributes = self.options.editedAttributes,            
            cm = self.options.cm,            
            token = self.options.token;            
            
            controlledVocButton.append($('<span id="onoff"></span>').css("float", "right").append($('<input type="radio" name="radio" id="on" value="on" checked="checked"/><label for="on" class="plug"> On </label>').css("font-size", "0.5em")).            
            append($('<input type="radio" name="radio" id="off" value="off"/><label class="plug" for="off"> Off </label>').css("font-size", "0.5em")))
            
            controlledVocButton.find("span").buttonset();
            
            if (controlledVoc == true) {                
                controlledVocButton.find('#on').attr("checked", "checked");
            } else {                
                controlledVocButton.find('#off').attr("checked", "checked");
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
                    var inallSpans = $("div", "." + uiEditAttributeDivClass).find("span").not(".ui-icon");                    
                    var titelarray =[];
                    
                    for (var i = 0; i < inallSpans.length; i++) {                        
                        var at = inallSpans[i].title;                        
                        console.log(at);                        
                        if (at !== undefined && at != "") {                            
                            titelarray.push(at);
                        }
                    }
                    if (titelarray.indexOf('indexName')>-1){
                    	var sein = new AttributesImpl();                        
                        sein.addAttribute(undefined, 'indexName', 'indexName', undefined, '');
                        var row = $("div:contains('indexName')", "." + uiEditAttributesDivClass);                       
                        row.remove();                        
                        $("div[title='indexName']", "." + uiSuggestedAttributesDivClass).draggable("enable");                        
                        $('.xrx-instance').xrxInstance().deleteAttributes(contextId, sein);
                         /*var ind = verw.indexOf('ind');
                         verw.splice(ind,1);
                        }*/
                    }
                    if (titelarray.indexOf('indexName')>-1 && titelarray.indexOf('lemma')>-1){
                    	var sein = new AttributesImpl();                        
                        sein.addAttribute(undefined, 'lemma', 'lemma', undefined, '');
                        var row = $("div:contains('lemma')", "." + uiEditAttributesDivClass);
                        row.remove();                        
                        $("div[title='lemma']", "." + uiSuggestedAttributesDivClass).draggable("enable");                        
                        $('.xrx-instance').xrxInstance().deleteAttributes(contextId, sein);                        
                         /*var ind = verw.indexOf('ind');
                         verw.splice(ind,1);
                        }*/
                    }
                    if (titelarray.indexOf('indexName')>-1 && titelarray.indexOf('lemma')>-1 && titelarray.indexOf('sublemma') >-1){
                    	var sein = new AttributesImpl();                        
                        sein.addAttribute(undefined, 'sublemma', 'sublemma', undefined, '');
                        var row = $("div:contains('sublemma')", "." + uiEditAttributesDivClass);
                        row.remove();                        
                        $("div[title='sublemma']", "." + uiSuggestedAttributesDivClass).draggable("enable");                        
                        $('.xrx-instance').xrxInstance().deleteAttributes(contextId, sein);                        
                         /*var ind = verw.indexOf('ind');
                         verw.splice(ind,1);
                        }*/
                    }
                    
                    var suggestedAttributesNamen =[];
                    
                    for (var j = 0; j < suggestedAttributes.length; j++) {                        
                        var index = titelarray.indexOf(suggestedAttributes[j]);                        
                        if (index == -1) {                            
                            suggestedAttributesNamen.push(suggestedAttributes[j]);
                        }
                    }
                    
                    for (var i = 0; i < suggestedAttributesNamen.length; i++) {                        
                        $("div[title='" + suggestedAttributesNamen[i] + "']", "." + uiSuggestedAttributesDivClass).draggable("enable");
                    }
                    
                    controlledVoc = false;
                    console.log(controlledVoc);
           
                } else { 
                	var inallSpans = $("div", "." + uiEditAttributeDivClass).find("span").not(".ui-icon");                    
                    var titelarray =[];
                    
                    for (var i = 0; i < inallSpans.length; i++) {                        
                        var at = inallSpans[i].title;                        
                        if (at !== undefined && at != "") {                            
                            titelarray.push(at);
                        }
                    }
                    if (titelarray.indexOf('indexName')>-1){
                    	var sein = new AttributesImpl();                        
                        sein.addAttribute(undefined, 'indexName', 'indexName', undefined, '');
                        var row = $("div:contains('indexName')", "." + uiEditAttributesDivClass);                        
                        row.remove();                        
                        $("div[title='indexName']", "." + uiSuggestedAttributesDivClass).draggable("enable");                        
                        $('.xrx-instance').xrxInstance().deleteAttributes(contextId, sein);
                        
                    }
                    if (titelarray.indexOf('indexName')>-1 && titelarray.indexOf('lemma')>-1){
                    	var sein = new AttributesImpl();                        
                        sein.addAttribute(undefined, 'lemma', 'lemma', undefined, '');
                        var row = $("div:contains('lemma')", "." + uiEditAttributesDivClass);                         
                        row.remove();                        
                                                
                        $('.xrx-instance').xrxInstance().deleteAttributes(contextId, sein);
                     
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
                    
                    console.log('the atts are inserted');
                }
            });
        },
        
        //End _attributeDroppable
        
        
        
        hide: function () {
        }
    });
})(jQuery);