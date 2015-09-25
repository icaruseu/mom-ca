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
            
            droppableAttributeDiv = $('<div">&#160;</div>').addClass(uiDroppableAttributeDivClass),
            
            suggestedAttributesDiv = $('<div></div>').addClass(uiSuggestedAttributesDivClass),
            controlledVocButton = $('<div></div>').addClass('controlledVocabulary')
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
            self._onoffButton(controlledVocButton);
            /* All GUI parts concerning the Attributes are appended */
            mainDiv.append(controlledVocButton).append(editAttributesDiv).append(droppableAttributeDiv).append(suggestedAttributesDiv);
            self.element.replaceWith(mainDiv);
            console.log('++++++++++++++++ WICHTIG +++++++++++++++++++++');
            console.log(elementName);
            console.log(suggestedAttributes);
            console.log(editedAttributes);
            console.log('++++++++++++++++++++++++++++');
            /*In the GUI already set (edited) Attributes are made unable to drag from the div-box with the possible (suggested) Attributes*/
            
            for (var i = 0 in editedAttributes) {
                $("div[title='" + editedAttributes[i].qName + "']", "." + uiMainDivId).draggable("disable");
                if ((editedAttributes[i].qName == 'indexName') && (editedAttributes[i].value == 'arthistorian')) {
                    /*for (var ii = 0 in suggestedAttributes){
                    $("div[title='" + suggestedAttributes[ii].qName + "']", "." + uiMainDivId).draggable("disable");
                    }*/
                    console.log('Zum Ausblenden!!!!!!');
                    console.log(suggestedAttributes);
                    var blende = suggestedAttributes;
                    if (blende.indexOf('lemma') != -1) {
                        var l = blende.indexOf('lemma');
                        blende.splice(l, 1);
                    }
                    if (blende.indexOf('sublemma') != -1) {
                        var s = blende.indexOf('sublemma');
                        blende.splice(s, 1);
                    }
                    console.log(blende);
                    for (var j = 0; j < blende.length; j++) {
                        $("div[title='" + blende[j] + "']", "." + uiMainDivId).draggable("disable");
                    }
                }
            }

            
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
            suggestedAttributes = self.options.suggestedAttributes,
            elementName = self.options.elementName,
            /* variables to define the GUI */
            newEditAttribute = $('<div></div>').addClass(uiFormsTableRowClass).addClass(uiEditAttributeDivClass),
            newEditAttributeLabel = $('<div><span title="' + name + '" >' + label + '<span></div>').addClass(uiFormsTableCellClass),
            newEditAttributeInput = $('<input></input>').addClass(uiFormsTableCellClass).attr("value", value).attr("name", name),
            newEditValuelabel = $('<div><span title="' + name + '" >' + label + '<span></div>').addClass(uiFormsTableCellClass),
            menuliste = $('<select></select>').attr('class', 'choose').addClass(uiFormsTableCellClass),
            //controlledVocButton = $('<div></div>').addClass(uiFormsTableCellClass);
            newEditAttributeTrash = $('<div><span class="ui-icon ui-icon-trash"/></div>').
            addClass(uiFormsTableCellClass);
            
            var proofarray =[];
            for (var i = 0 in editedAttributes) {
                var cle = editedAttributes[i].qName;
                var val = editedAttributes[i].value;
                // proofarray.push( cle + ":" + val);
            }
            /*variables to get the values for the controlled vocabulary */
            var jsonValues = jQuery.parseJSON($('.xrx-forms-json-values').text());
            var suggestedVal = jsonValues[elementName];
            
            if (suggestedVal == undefined) {
                controlledVoc = false;
            } else {
                //das array mit den keys zum Elementnamen
                var mainkeys = Object.getOwnPropertyNames(suggestedVal).sort();
                
                for (var mk in suggestedVal) {
                    var mk = suggestedVal[mk];
                }
                
                /* arrays that inform about chosen attributes (qName) and its values, necessary for further conditions*/
                var lemma =[ "LEVEL1", "LEVEL2", "LEVEL3"];
                var WithAdditionalColours =[ "HistoriatedDecoration", "WithAdditionalColours: Miniatures", "WithAdditionalColours: Initials", "WithAdditionalColours: Borders", "WithAdditionalColours: CoatsofArms", "WithAdditionalColours: ExecutionDraw", "WithAdditionalColours: ExecutionPainted"];
                var DrawnDecorationnothistoriated =[ "DrawnDecorationnothistoriated: DD-nh-Panels", "DrawnDecorationnothistoriated: Initials", "DrawnDecorationnothistoriated: DD-nh-Borders", "DepictiveMotivesnothistoriated: figural", "DepictiveMotivesnothistoriated: zoomorphic", "DepictiveMotivesnothistoriated: otherMotivs"];
                var DepictiveMotivesnothistoriated =[ "DepictiveMotivesnothistoriated: figural", "DepictiveMotivesnothistoriated: zoomorphic", "DepictiveMotivesnothistoriated: otherMotivs"];
                var GraphicMeansOfAuthenticating =[ "GraphicMeansofAuthenticating: Chrismon", "GraphicMeansofAuthenticating: Monogramm", "GraphicMeansofAuthenticating: Rota", "GraphicMeansofAuthenticating: SignumRecognitionis", "GraphicMeansofAuthenticating: SignumNotarile", "GraphicMeansofAuthenticating: OtherSignsofAuthentication"];
                
                var werte =[];
                var attrname =[];
                
                for (var i = 0; i < editedAttributes.length; i++) {
                    q = editedAttributes[i].qName;
                    w = editedAttributes[i].value;
                    werte.push(w);
                    attrname.push(q);
                }
                alleWertedesIndex =[ "other", "arthistorian"];
                for (var i = 0; i < lemma.length; i++) {
                    alleWertedesIndex.push(lemma[i]);
                }
                for (var i = 0; i < WithAdditionalColours.length; i++) {
                    alleWertedesIndex.push(WithAdditionalColours[i]);
                }
                for (var i = 0; i < DrawnDecorationnothistoriated.length; i++) {
                    alleWertedesIndex.push(DrawnDecorationnothistoriated[i]);
                }
                for (var i = 0; i < GraphicMeansOfAuthenticating.length; i++) {
                    alleWertedesIndex.push(GraphicMeansOfAuthenticating[i]);
                }
                console.log('*****************************************');
                console.log(mainkeys);
                console.log(alleWertedesIndex);
                console.log(werte);
                console.log(proofarray);
                for (var i = 0; i < alleWertedesIndex.length; i++) {
                    for (var j = 0; j < werte.length; j++) {
                        if (alleWertedesIndex[i] == werte[j]) {
                            console.log(alleWertedesIndex[i] + " und " + werte[j]);
                            controlledVoc = true;
                        }
                    }
                }
                var ediertminus =[];
                for (var i = 0; i < attrname.length; i++) {
                    for (var j = 0; j < mainkeys.length; j++) {
                        if (attrname[i] != mainkeys[j]) {
                            ediertminus.push(attrname[i]);
                            //controlledVoc = false;
                        }
                    }
                }
                var restAttr =[]
                for (var i = 0; i < suggestedAttributes.length; i++) {
                    for (var j = 0; j < mainkeys.length; j++) {
                        if (suggestedAttributes[i] != mainkeys[j]) {
                            restAttr.push(suggestedAttributes[i]);
                        }
                    }
                }
                console.log(restAttr);
                console.log('*****************************************');
                //brauch liste der attr, die nicht im CV sind(restAttr.indexOf(name) == -1)&& ((name = "indexName")|(name = "lemma")| (name = "sublemma"))
            }
            //2. Versuch else von undefined zu schließen
            if (elementName == "cei:index") {
                console.log('000000000000000000000');
                if ((controlledVoc == true) &&(mainkeys.indexOf(name) != -1)) {
                    console.log('das if wenn controlled voc auf true');
                    for (var mk in suggestedVal) {
                        
                        console.log('das wird abgearbeitet');
                        console.log(suggestedVal[mk]);
                        console.log(mk);
                        var y = suggestedVal[mk];
                        var x = setoptioninSelect(y, mk);
                        
                        
                        console.log('MK: ' + mk + ' : ' + suggestedVal[mk]);
                        console.log(mk);
                        console.log(suggestedVal[mk] instanceof Array);
                        console.log(suggestedVal[mk]);
                        console.log('test unterhalb suggestedVal test');
                        console.log(suggestedVal);
                        newEditAttributeLabel.hide();
                        newEditAttributeInput.hide();
                        newEditAttribute.append(newEditValuelabel).append(menuliste).append(newEditAttributeTrash);
                    }
                } else {
                    console.log('22222222222222222');
                    newEditAttribute.append(newEditAttributeLabel).append(newEditAttributeInput).append(newEditAttributeTrash);
                }
                //return newEditAttribute;
            } else {
                console.log('333333333333');
                newEditAttribute.append(newEditAttributeLabel).append(newEditAttributeInput).append(newEditAttributeTrash);
                //return newEditAttribute;
            }
            /*the div.forms-mixedcontent-edit-attributes gets the method _trashIconClickable */
            self._trashIconClickable(newEditAttributeTrash, newEditAttribute);
            //self._onoffButton(controlledVocButton);
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
            });
            
            /* function to set the options in the select box */
            function setoptioninSelect(sugname, key) {
                console.log(sugname);
                console.log(key);
                var nodeset = $(document).xrx.nodeset(cm.getInputField());
                var controlId = nodeset.only.levelId;
                var relativeId = token.state.context.id.split('.').splice(1);
                var contextId = controlId.concat(relativeId);
                console.log('da muss noch was rein');
                console.log(editedAttributes);
                
                if ((key == name) && (sugname instanceof Array == true)) {
                    function eruieren(x) {
                        console.log('IIIIIIIIII');
                        console.log(nodeset.only.xml);
                        var regular = nodeset.only.xml.match(/lemma=".*?"/);
                        if (regular != null) {
                            console.log(regular);
                            var reg = regular.join();
                            console.log(reg);
                            var lemmaw = reg.slice(7, reg.length -1);
                            console.log(lemmaw);
                        }
                        
                        
                        if ((x != 'lemma') &&(x != 'sublemma')) {
                            return sugname;
                        } else if (x == 'lemma') {
                            return lemma;
                        } else if (x == 'sublemma') {
                            
                            if (lemmaw === 'LEVEL1') {
                                return WithAdditionalColours;
                            } else if (lemmaw === 'LEVEL2') {
                                return DrawnDecorationnothistoriated;
                            } else if (lemmaw === 'LEVEL3') {
                                return GraphicMeansOfAuthenticating;
                            }
                        }
                    }
                    var inhalt = eruieren(key);
                    if (inhalt == undefined) {
                        controlledVoc = false;
                    } else {
                        console.log('+++++++++++++++++++++++++++++');
                        console.log(inhalt);
                        console.log('+++++++++++++++++++++++++++++');
                        var einf = $("<option> --- </option>");
                        menuliste.append(einf);
                        
                        for (var i = 0; i < inhalt.length; i++) {
                            
                            console.log(inhalt[i]);
                            console.log('wertausgabe');
                            console.log(value);
                            
                            var newli = $('<option>' + inhalt[i] + '</option>').addClass(uiSuggestedValueDivsClass).attr("title", inhalt[i]).attr("value", inhalt[i]);
                            if (inhalt[i] == value) {
                                newli.attr("selected", "selected");
                            }
                            menuliste.append(newli);
                            
                            
                            /* options are clickable and the value is going to be saved */
                            /* Function used to remove edited attributes when indexName changes from arthistorian to other viceversa.*/
                            function removeAtts(x) {
                                var inallSpans = $("div", "." + uiEditAttributeDivClass).find("span").not(".ui-icon").text();
                                var allselOption = $("select").find("option[selected='selected']").text();
                                var indexsub = inallSpans.indexOf('sublemma');
                                var indexlem = inallSpans.indexOf('lemma');
                                var indexopt = allselOption.indexOf(x);
                                if (indexsub != -1) {
                                    
                                    /* a new Objekt, prepared to be deleted in the modell */
                                    var sein = new AttributesImpl();
                                    sein.addAttribute(undefined, 'sublemma', 'sublemma', undefined, '');
                                    console.log(sein);
                                    var row = $("div:contains('sublemma')", "." + uiEditAttributesDivClass);
                                    console.log(row);
                                    row.remove();
                                    $('.xrx-instance').xrxInstance().deleteAttributes(contextId, sein);
                                    /*chosen (edited) attributes disabled in the div-box .mixed-forms-suggested-attributes */
                                    $("div", "." + uiSuggestedAttributesDivClass).addClass("ui-state-disabled");
                                }
                                if (indexlem != -1) {
                                    /*a new Objekt, prepared to be deleted in the modell */
                                    var sein = new AttributesImpl();
                                    sein.addAttribute(undefined, 'lemma', 'lemma', undefined, '');
                                    console.log(sein);
                                    var row = $("div:contains('lemma')", "." + uiEditAttributesDivClass);
                                    console.log(row);
                                    row.remove();
                                    $('.xrx-instance').xrxInstance().deleteAttributes(contextId, sein);
                                    /*chosen (edited) attributes disabled in the div-box .mixed-forms-suggested-attributes */
                                    $("div", "." + uiSuggestedAttributesDivClass).addClass("ui-state-disabled");
                                }
                            }
                        }
                    }
                }
               
            }
            menuliste.change(function (event) {
                self = this;
                var attrvalue = self.value;
                var nodeset = $(document).xrx.nodeset(cm.getInputField());
                var controlId = nodeset.only.levelId;
                var relativeId = token.state.context.id.split('.').splice(1);
                var contextId = controlId.concat(relativeId);
                console.log(self);
                console.log(attrvalue);
                var attributes = new AttributesImpl();
                console.log('Der NAAAMMMMMMMMMMMMEEEEEEEEEEEE');
                console.log(attributes);
                attributes.addAttribute(undefined, name, name, undefined, attrvalue);
                console.log('add Attr');
                console.log(attributes);
                
                /* attribute 'indexName' in element 'keyword' can have 2 values: other or arthistorian,
                if it is 'other' the controlled vocabulary is switched off.
                 * if it is 'artihistorian' the controlled vocabulary for the attributes lemma and sublemma is active. */
                
                if (attrvalue == 'other') {
                    
                    //var removedAttributes = removeAtts('other');
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
                        }
                    }
                }
                if (attrvalue == 'arthistorian') {
                    
                    $("div", "." + uiSuggestedAttributeDivsClass).each(function () {
                        //var removedAttributes = removeAtts('arthistorian');
                        $("div", "." + uiSuggestedAttributesDivClass).addClass("ui-state-disabled");
                        //  when 'indexName' is 'arthistorian' only the attribute 'lemma' is draggable
                        $("div[title='lemma']", "." + uiSuggestedAttributesDivClass).draggable("enable");
                    });
                }
                if (name == 'lemma') {
                    if (attrvalue === "LEVEL1: HistoriatedDecoration") {
                        
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
                            }
                        }
                    } else {
                        controlledVoc = true;
                        $("div", "." + uiSuggestedAttributesDivClass).addClass("ui-state-disabled");
                        $("div[title='sublemma']", "." + uiSuggestedAttributesDivClass).draggable("enable");
                    }
                    var inallSpans = $("div", "." + uiEditAttributeDivClass).find("span").not(".ui-icon").text();
                    var allselOption = $("select").find("option[selected='selected']").text();
                    var indexsub = inallSpans.indexOf('sublemma');
                    var indexopt = allselOption.indexOf('other');
                    if (indexsub != -1) {
                        console.log('weg damit');
                        var sein = new AttributesImpl();
                        sein.addAttribute(undefined, 'sublemma', 'sublemma', undefined, '');
                        console.log(sein);
                        var row = $("div:contains('sublemma')", "." + uiEditAttributesDivClass);
                        console.log(row);
                        row.remove();
                        $('.xrx-instance').xrxInstance().deleteAttributes(contextId, sein);
                        //  $("div", "." + uiSuggestedAttributesDivClass).addClass("ui-state-disabled");
                        // when 'lemma' and a selected value then the attribute 'sublemma' is draggable
                        //  $("div[title='sublemma']", "." + uiSuggestedAttributesDivClass).draggable("enable");
                    }
                } else if (name == 'sublemma') {
                    console.log('kkkkkkkkkkkkkkkkkkkkk');
                    console.log(nodeset.only.xml);
                    var regular = nodeset.only.xml.match(/lemma=".*?"/);
                    console.log(regular);
                    var reg = regular.join();
                    console.log(reg);
                    var lemmaw = reg.slice(7, reg.length -1);
                    console.log(lemmaw);
                    
                    
                    //controlledVoc = true;
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
                            /*  all (not edited) attributes from div.forms-mixedcontent-suggested-Attributes
                             *  are set draggable again */
                            $("div:contains('" + proof + "')", "." + uiSuggestedAttributesDivClass).draggable("enable");
                            console.log(spantexte);
                        }
                    }
                    
                    //controlledVoc = false;
                }
                /* Set the new value of the attributes in the instance */
                $('.xrx-instance').xrxInstance().replaceAttributeValue(contextId, attributes);
                console.log('selfiiiiiiiiiiiiiiiii');
                console.log(cm);
                //cm = self.options.cm,
                //token = self.options.token,
            });
            
            $(menuliste).menu();
            
            
            console.log('ich werde vergessssssssssssssssen');
            return newEditAttribute;
        },
        
        /*End of _newEditAttribute */
        
        
        _trashIconClickable: function (trashIcon, editAttribute) {
            
            var self = this,
            suggestedAttributes = self.options.suggestedAttributes,
            editedAttributes = self.options.editedAttributes,
            cm = self.options.cm,
            token = self.options.token;
            
            trashIcon.click(function (event) {
                if ($($(editAttribute).find("input")).length == 1) {
                    var name = $($(editAttribute).find("input")).attr("name");
                    console.log('oder das');
                } else {
                    
                    var name = editAttribute[0].firstElementChild.firstChild.firstChild.data;
                }
                var attributes = new AttributesImpl();
                console.log('Auch hier wird der name geprüft');
                console.log(editAttribute[0]);
                console.log(name);
                console.log($($(editAttribute).find("input")));
                console.log('der self');
                console.log(self);
                attributes.addAttribute(null, name, name, undefined, "");
                
                editAttribute.remove();
                //$("div[title='" + name + "']", "." + uiSuggestedAttributesDivClass).draggable("enable");
                console.log('die edierten Attribute noch mals ausgeben lassen');
                console.log(editedAttributes);
                var inallSpans = $("div", "." + uiEditAttributeDivClass).find("span").not(".ui-icon");
                var titelarray =[];
               for (var i = 0; i < inallSpans.length; i++) {
                		var at = inallSpans[i].title;
                		console.log(at);
                	if (at !== undefined && at != ""){                        		
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
                console.log(suggestedAttributesNamen);
                for (var i = 0; i < suggestedAttributesNamen.length; i++) {
                    $("div[title='" + suggestedAttributesNamen[i] + "']", "." + uiSuggestedAttributesDivClass).draggable("enable");
                }
                
                console.log('-------------------------------------');
                var nodeset = $(document).xrx.nodeset(cm.getInputField());
                var controlId = nodeset.only.levelId;
                var relativeId = token.state.context.id.split('.').splice(1);
                var contextId = controlId.concat(relativeId);
                var findselect = $(editAttribute).find("select");
                if ((name = 'indexName') && ($(editAttribute).find("select").length == 1)) {
                    var row = $("div:contains('lemma')", "." + uiEditAttributesDivClass);
                    var row2 = $("div:contains('sublemma')", "." + uiEditAttributesDivClass);
                    console.log('Vorbereitungen zum Löschen der Attrbiute');
                    console.log(row);
                    console.log(row2);
                    if (row2.length > 0) {
                        console.log('ich treffe zu sublemma');
                        var sein = new AttributesImpl();
                        sein.addAttribute(undefined, 'sublemma', 'sublemma', undefined, '');
                        console.log(sein);
                        var row = $("div:contains('sublemma')", "." + uiEditAttributesDivClass);
                        console.log(row);
                        row.remove();
                        for (var i = 0; i < editedAttributes.length; i++) {
                        }
                        $("div[title='sublemma']", "." + uiSuggestedAttributesDivClass).draggable("enable");
                        $('.xrx-instance').xrxInstance().deleteAttributes(contextId, sein);
                    }
                    if (row.length > 0) {
                        console.log('ich treffe zu lemma');
                        var sein = new AttributesImpl();
                        sein.addAttribute(undefined, 'lemma', 'lemma', undefined, '');
                        console.log(sein);
                        var row = $("div:contains('lemma')", "." + uiEditAttributesDivClass);
                        console.log(row);
                        row.remove();
                        $("div[title='lemma']", "." + uiSuggestedAttributesDivClass).draggable("enable");
                        $('.xrx-instance').xrxInstance().deleteAttributes(contextId, sein);
                    }
                }
                if ((name = 'lemma') && ($(editAttribute).find("select").length == 1)) {
                    var row2 = $("div:contains('sublemma')", "." + uiEditAttributesDivClass);
                    console.log('Vorbereitungen zum Löschen der Attrbiute');
                    console.log(row2);
                    if (row2.length > 0) {
                        var sein = new AttributesImpl();
                        sein.addAttribute(undefined, 'sublemma', 'sublemma', undefined, '');
                        console.log(sein);
                        var row = $("div:contains('sublemma')", "." + uiEditAttributesDivClass);
                        console.log(row);
                        row.remove();
                        $("div[title='sublemma']", "." + uiSuggestedAttributesDivClass).draggable("enable");
                        $('.xrx-instance').xrxInstance().deleteAttributes(contextId, sein);
                    }
                }
                $('.xrx-instance').xrxInstance().deleteAttributes(contextId, attributes);
            });
        },
        //End of _trashIconClickable
        
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
            
            //controlledVocButton.find("input").on("click", function(){
            	controlledVocButton.find("input").change( function(){
            	 var nodeset = $(document).xrx.nodeset(cm.getInputField());
                 var controlId = nodeset.only.levelId;
                 var relativeId = token.state.context.id.split('.').splice(1);
                 var contextId = controlId.concat(relativeId);
                 
            	var wert = $("input:radio:checked").val();
            	console.log(wert);
            	if (wert == "off"){
            		var inallSpans = $("div", "." + uiEditAttributeDivClass).find("span").not(".ui-icon");
                    var titelarray =[];
                   for (var i = 0; i < inallSpans.length; i++) {
                    		var at = inallSpans[i].title;
                    		console.log(at);
                    	if (at !== undefined && at != ""){                        		
                    			titelarray.push(at);
                    		}                       	
                    }
                    console.log('TTdas titelarray N');
                    console.log(titelarray);
                    var suggestedAttributesNamen =[];
                  for (var j = 0; j < suggestedAttributes.length; j++) {
                        var index = titelarray.indexOf(suggestedAttributes[j]);
                        if (index == -1) {
                            suggestedAttributesNamen.push(suggestedAttributes[j]);
                        }
                    }
                    console.log(suggestedAttributesNamen);
                    for (var i = 0; i < suggestedAttributesNamen.length; i++) {
                        $("div[title='" + suggestedAttributesNamen[i] + "']", "." + uiSuggestedAttributesDivClass).draggable("enable");
                    }
                    controlledVoc = false;
                   // self._create();
            	}
            	else{
            		controlledVoc = true;
            	}
            });
            console.log('Test controlledVoc');
            console.log(controlledVoc);
            return controlledVoc;
        },
        
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
