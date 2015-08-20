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
    
    $.widget("ui.xrxAttributes", {
        
        options: {
            elementName: null,
            suggestedAttributes: null,
            editedAttributes: null,            
            cm: null,
            token: null
        },
        
        _create: function () {
            
            var self = this,
            elementName = self.options.elementName,
            suggestedAttributes = self.options.suggestedAttributes,
            editedAttributes = self.options.editedAttributes,
            
            mainDiv = $('<div></div>').attr("class", uiMainDivId),
            
            editAttributesDiv = $('<div></div>').addClass(uiEditAttributesDivClass).addClass(uiFormsTableClass),
            
            droppableAttributeDiv = $('<div>&#160;</div>').addClass(uiDroppableAttributeDivClass),
            
            suggestedAttributesDiv = $('<div></div>').addClass(uiSuggestedAttributesDivClass)
            
            /*when editor is opened, look if there are already attributes set, 
             * then append to the div.forms-mixedcontent-edit-attributes the attributes that already exist.  */
            for (var i = 0 in editedAttributes) {
                editAttributesDiv.append(self._newEditAttribute(editedAttributes[i].qName, $(document).xrxI18n.translate(editedAttributes[i].qName, "xs:attribute"), editedAttributes[i].value));
            }            
            /*xrx-attributes class gets method _attributeDroppable*/
            self._attributeDroppable(droppableAttributeDiv);
            
            /* a new div-box in the GUI is created, in it there is the list of all possible Attributes for the element.
             * in Addition these Attributes get a method _suggestedAttributeDraggable, to be able to drag them. */
            for (var i = 0 in suggestedAttributes) {
                var name = suggestedAttributes[i];
                var newDiv = $('<div>' + $(document).xrxI18n.translate(name, "xs:attribute") + '<div>').addClass(uiSuggestedAttributeDivsClass).attr("title", name);
                
                suggestedAttributesDiv.append(newDiv);
                self._suggestedAttributeDraggable(newDiv);             
            }
            
            /* All GUI parts concerning the Attributes are appended */
            mainDiv.append(editAttributesDiv).append(droppableAttributeDiv).append(suggestedAttributesDiv);
            self.element.replaceWith(mainDiv);

            /*In the GUI already set (edited) Attributes are made unable to drag from the div-box with the possible (suggested) Attributes*/
            for (var i = 0 in editedAttributes) {
                $("div[title='" + editedAttributes[i].qName + "']", "." + uiMainDivId).draggable("disable");
            }
            /* the global variable is set to true, as default value. */
            controlledVoc = true;
            
            /* the jquery menu is initialized */
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
            elementName = self.options.elementName,
            /* variables to define the GUI */
            newEditAttribute = $('<div></div>').addClass(uiFormsTableRowClass).addClass(uiEditAttributeDivClass),
            newEditAttributeLabel = $('<div><span>' + label + '<span></div>').addClass(uiFormsTableCellClass),
            newEditAttributeInput = $('<input></input>').addClass(uiFormsTableCellClass).attr("value", value).attr("name", name),
            newEditValuelabel = $('<div><span>' + label + '<span></div>').addClass(uiFormsTableCellClass),
            menuliste = $('<select></select>').attr('class', 'choose').addClass(uiFormsTableCellClass),            
            newEditAttributeTrash = $('<div><span class="ui-icon ui-icon-trash"/></div>').
            addClass(uiFormsTableCellClass);
            /*variables to get the values for the controlled vocabulary */
            var jsonValues = jQuery.parseJSON($('.xrx-forms-json-values').text());
            var suggestedVal = jsonValues[elementName];     
            var mainkeys = Object.getOwnPropertyNames(suggestedVal).sort();
            
            /* arrays that inform about chosen attributes (qName) and its values, necessary for further conditions*/
            var werte =[];
            var attrname =[];
            for (var i = 0; i < editedAttributes.length; i++) {
                q = editedAttributes[i].qName;
                w = editedAttributes[i].value;
                werte.push(w);
                attrname.push(q);
            }
            /* when editor is opened check a value, and switch off the controlled vocabulary */
            if (werte.indexOf('other')!= -1){
            	controlledVoc = false;
            }            
           /* conditions for GUI, depending strongly on controlled vocabulary.
            * in the GUI this runs in the div.forms-mixedcontent-edit-attributes:
            * there table rows with the label of the attr, an input field or a select-box (controlled vocabulary)
            * and a trash icon (delete)  */
            if ((controlledVoc == false) && (name != 'indexName')) {
                console.log('wird erledigt ohne reload');
                newEditAttribute.append(newEditAttributeLabel).append(newEditAttributeInput).append(newEditAttributeTrash);
           }
            else if (((attrname.indexOf('indexName') == -1) && (name == 'lemma')) | ((attrname.indexOf('indexName') == -1) && (name == 'sublemma'))) {
           
                newEditAttribute.append(newEditAttributeLabel).append(newEditAttributeInput).append(newEditAttributeTrash);
            } else {
           
                for (var mk in suggestedVal) {
                    
                    console.log('MK: ' + mk + ' : ' + suggestedVal[mk]);
                    console.log(mk);
                    console.log(suggestedVal[mk] instanceof Array);
                    if ((mk == name) && (suggestedVal[mk] instanceof Array) && (suggestedVal[mk].length !== 0)) {
                        
                        newEditAttributeLabel.hide();
                        newEditAttributeInput.hide();
                        newEditAttribute.append(newEditValuelabel).append(menuliste).append(newEditAttributeTrash);
                    } else {
                        newEditAttribute.append(newEditAttributeLabel).append(newEditAttributeInput).append(newEditAttributeTrash);
                    }
                }
            }
            /*the div.forms-mixedcontent-edit-attributes gets the method _trashIconClickable */
            self._trashIconClickable(newEditAttributeTrash, newEditAttribute);
            /* function to set the options in the select box */
            function setoptioninSelect(sugname, startvalue, endvalue) {
                for (var startvalue; startvalue < endvalue; startvalue++) {
                    
                    var einf = $('<option> --- </option>');
                    var newli = $('<option>' + sugname[startvalue] + '</option>').addClass(uiSuggestedValueDivsClass).attr("title", sugname[startvalue]).attr("value", sugname[startvalue]);

                    if (sugname[startvalue] == value) {
                        newli.attr("selected", "selected");
                    }
                    menuliste.append(einf).append(newli);
                    var nodeset = $(document).xrx.nodeset(cm.getInputField());               
                    /* options are clickable and the value is going to be saved */
                    /* Function used to remove edited attributes when indexName changes from arthistorian to other viceversa.*/
               function removeAtts(x) {
                    var inallSpans = $("div", "." + uiEditAttributeDivClass).find("span").not(".ui-icon").text();
                    var allselOption = $("select").find("option[selected='selected']").text();
                    var indexsub = inallSpans.indexOf('sublemma');
                    var indexlem = inallSpans.indexOf('lemma');
                    var indexopt = allselOption.indexOf(x);
                    if (indexsub != -1) {
                        /* the cId is the contextId hard coded in this case, because its in this case always the same Array.*/
                        var cId =[1, 7, 1, 2, 2, 3, 4, 1, 1, "2"];
                        /* a new Objekt, prepared to be deleted in the modell */
                        var sein = new AttributesImpl();
                        sein.addAttribute(undefined, 'sublemma', 'sublemma', undefined, '');
                        console.log(sein);
                        var row = $("div:contains('sublemma')", "." + uiEditAttributesDivClass);
                        console.log(row);
                        row.remove();
                        $('.xrx-instance').xrxInstance().deleteAttributes(cId, sein);
                        /* chosen (edited) attributes disabled in the div-box .mixed-forms-suggested-attributes */
                        $("div", "." + uiSuggestedAttributesDivClass).addClass("ui-state-disabled");
                        
                    }
                    if (indexlem != -1) {
                    	/* the cId is the contextId hard coded in this case, because its in this case always the same Array.*/
                        var cId =[1, 7, 1, 2, 2, 3, 4, 1, 1, "2"];
                        /* a new Objekt, prepared to be deleted in the modell */
                        var sein = new AttributesImpl();
                        sein.addAttribute(undefined, 'lemma', 'lemma', undefined, '');
                        console.log(sein);
                        var row = $("div:contains('lemma')", "." + uiEditAttributesDivClass);
                        console.log(row);
                        row.remove();
                        $('.xrx-instance').xrxInstance().deleteAttributes(cId, sein);
                        /* chosen (edited) attributes disabled in the div-box .mixed-forms-suggested-attributes */
                        $("div", "." + uiSuggestedAttributesDivClass).addClass("ui-state-disabled");                                
                    	}
                    }
                  
                    newli.bind("click", function (ev) {
                        self = this;
                        var attrvalue = this.title;
                        var attributes = new AttributesImpl();
                        attributes.addAttribute(undefined, name, name, undefined, attrvalue);

                        /* variables necessary for codemirror and XPath.js*/
                        var controlId = nodeset.only.levelId;
                        var relativeId = token.state.context.id.split('.').splice(1);
                        var contextId = controlId.concat(relativeId);
                        /* attribute 'indexName' in element 'keyword' can have 2 values: other or arthistorian, 
                         * if it is 'other' the controlled vocabulary is switched off. 
                         * if it is 'artihistorian' the controlled vocabulary for the attributes lemma and sublemma is active. */
                        if (attrvalue == 'other') {
                        	var removedAttributes = removeAtts('other');                       
                            /* those attributes, that were not edited, are set to be draggabel again.*/
                            var spantexte =[];
                            var eintrag = $(".forms-mixedcontent-edit-attribute").find("span")
                            for (var i = 0; i < eintrag.length; i++) {
                                spantexte.push(eintrag[i].textContent);
                            }
                            console.log(spantexte);
                            var proofdiv = $("div", "." + uiSuggestedAttributeDivsClass);
                            for (var i = 0; i < proofdiv.length; i++) {
                                var proof = proofdiv[i].previousSibling.data;
                                if (spantexte.indexOf(proof) == -1) {                                    
                                    $("div:contains('" + proof + "')", "." + uiSuggestedAttributesDivClass).draggable("enable");

                                    controlledVoc = false;
                                }
                            }
                        }
                        if (attrvalue == 'arthistorian') {                            
                            $("div", "." + uiSuggestedAttributeDivsClass).each(function () {
                            	var removedAttributes = removeAtts('arthistorian');
                                    $("div", "." + uiSuggestedAttributesDivClass).addClass("ui-state-disabled");
                             /* when 'indexName' is 'arthistorian' only the attribute 'lemma' is draggable */
                                    $("div[title='lemma']", "." + uiSuggestedAttributesDivClass).draggable("enable");                                   
                                }                        
                        );
                            controlledVoc = true;
                        }
                        
                        
                        if (name == 'lemma') {
                            $("div[title='sublemma']", "." + uiSuggestedAttributesDivClass).draggable("enable");
                            var inallSpans = $("div", "." + uiEditAttributeDivClass).find("span").not(".ui-icon").text();
                            var allselOption = $("select").find("option[selected='selected']").text();
                            var indexsub = inallSpans.indexOf('sublemma');
                            var indexopt = allselOption.indexOf('other');
                            if (indexsub != -1) {
                                console.log('weg damit');
                                var cId =[1, 7, 1, 2, 2, 3, 4, 1, 1, "2"];
                                var sein = new AttributesImpl();
                                sein.addAttribute(undefined, 'sublemma', 'sublemma', undefined, '');
                                console.log(sein);
                                var row = $("div:contains('sublemma')", "." + uiEditAttributesDivClass);
                                console.log(row);
                                row.remove();
                                $('.xrx-instance').xrxInstance().deleteAttributes(cId, sein);
                                $("div", "." + uiSuggestedAttributesDivClass).addClass("ui-state-disabled");
                                /* when 'lemma' and a selected value then the attribute 'sublemma' is draggable */
                                $("div[title='sublemma']", "." + uiSuggestedAttributesDivClass).draggable("enable");
                            }
                        }
                        if (name == 'sublemma') {
                            var spantexte =[];
                            var eintrag = $(".forms-mixedcontent-edit-attribute").find("span")
                            for (var i = 0; i < eintrag.length; i++) {
                                spantexte.push(eintrag[i].textContent);
                            }
                            console.log(spantexte);
                            var proofdiv = $("div", "." + uiSuggestedAttributeDivsClass);
                            for (var i = 0; i < proofdiv.length; i++) {
                                var proof = proofdiv[i].previousSibling.data;
                                if (spantexte.indexOf(proof) == -1) {
                                    console.log('DAS STimmmt soweit!!!!');
                                    console.log(proof);
                                    console.log(spantexte.indexOf(proof));
                                    /* all (not edited) attributes from div.forms-mixedcontent-suggested-Attributes
                                     *  are set draggable again */
                                    $("div:contains('" + proof + "')", "." + uiSuggestedAttributesDivClass).draggable("enable");
                                    console.log(spantexte);
                                }
                            }
                        }
                        /* Set the new value of the attributes in the instance */
                        $('.xrx-instance').xrxInstance().replaceAttributeValue(contextId, attributes);
                    });
                }
                //return
            }
            
            /*compare json-object values with selected attributes*/
            Object.getOwnPropertyNames(suggestedVal).forEach(function (val, idx, array) {
                
                if (val == name) {                    
                    var sugname = suggestedVal[val];                    
                    console.log(Boolean ($("option:contains(" + value + ")")));
                    //da kommt true raus
                    var nodeset = $(document).xrx.nodeset(cm.getInputField());
                    var nodesetxmlstring = nodeset.only.xml;
                    
                    if (name == 'indexName') {
                        var x = setoptioninSelect(sugname, 0, 2);
                    } else if (name == 'lemma') {
                        var x = setoptioninSelect(sugname, 0, 3);
                    } else if (name == 'sublemma') {
                        if (nodesetxmlstring.contains('N1')) {
                            var startvalue = 0;
                            var endvalue = 6;
                            var x = setoptioninSelect(sugname, 0, 7);
                            console.log(x);
                        } else if (nodesetxmlstring.contains('"N2"')) {
                            var startvalue = 7;
                            var endvalue = 14;
                            var x = setoptioninSelect(sugname, 7, 15);
                            console.log(x);
                        } else if (nodesetxmlstring.contains('"N3"')) {
                            var startvalue = 15;
                            var endvalue = sugname.length;
                            var x = setoptioninSelect(sugname, 15, 21);
                            console.log(x);
                        }
                    }
                    /*else {
                    console.log("das else wird ausgeführt");
                    var startvalue = 0;
                    var endvalue = sugname.length;
                    var x = setoptioninSelect(sugname, startvalue, endvalue);
                    }*/
                }
                //Ende des ersten IF
            });
            
            $(menuliste).menu();
            
            /* function saves all changes in the input field */
            newEditAttributeInput.keyup(function () {
                var attributes = new AttributesImpl();
                attributes.addAttribute(null, name, name, undefined, $(this).val());
                
                var nodeset = $(document).xrx.nodeset(cm.getInputField());
                var controlId = nodeset.only.levelId;
                var relativeId = token.state.context.id.split('.').splice(1);
                var contextId = controlId.concat(relativeId);                
                $('.xrx-instance').xrxInstance().replaceAttributeValue(contextId, attributes);
                console.log($(this).val());
                console.log($('.xrx-instance').xrxInstance());

            })

            return newEditAttribute;
        },
        
        /*End of _newEditAttribute */
        
        
        _trashIconClickable: function (trashIcon, editAttribute) {
            
            var self = this,
            cm = self.options.cm,
            token = self.options.token;
            
            trashIcon.click(function (event) {
                var name = $($(editAttribute).find("input")).attr("name");
                var attributes = new AttributesImpl();
                attributes.addAttribute(null, name, name, undefined, "");
                
                editAttribute.remove();
                $("div[title='" + name + "']", "." + uiSuggestedAttributesDivClass).draggable("enable");
                
                var nodeset = $(document).xrx.nodeset(cm.getInputField());
                var controlId = nodeset.only.levelId;
                var relativeId = token.state.context.id.split('.').splice(1);
                var contextId = controlId.concat(relativeId);
                $('.xrx-instance').xrxInstance().deleteAttributes(contextId, attributes);
                /*when indexName was deleted, the controlled vocabulary is switched on again.*/
                if (attributes.attsArray[0].qName == 'indexName') {
                    controlledVoc = true;
                    console.log('controlledVoc is true');
                }
            });
        },
        //End of _trashIconClickable
        
        _suggestedAttributeDraggable: function (suggestedAttribute) {
            
            var self = this;
            
            suggestedAttribute.draggable({
                containment: "." + uiMainDivId,
                revert: "invalid",
                cursor: "move",
                helper: "clone",
                start: function (event, ui) {
                    $("." + uiDroppableAttributeDivClass, "." + uiMainDivId).addClass("edit-attributes-droppable-active");
                    suggestedAttribute.addClass("suggested-attribute-draggable-disabled");
                },
                stop: function (event, ui) {
                    $("." + uiDroppableAttributeDivClass, "." + uiMainDivId).removeClass("edit-attributes-droppable-active");
                    suggestedAttribute.removeClass("suggested-attribute-draggable-disabled");                    
                }
            });
            //return suggestedAttribute[0].title;
        },
        //End _suggestedAttributeDraggable
        
        /*is div.forms-mixed-content-attribute-droppable in GUI its the dashed line field, where the suggested attr are drop in */
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
