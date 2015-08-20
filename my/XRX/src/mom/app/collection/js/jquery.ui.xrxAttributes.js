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
    var ampel = false;
    
    $.widget("ui.xrxAttributes", {
        
        options: {
            elementName: null,
            suggestedAttributes: null,
            editedAttributes: null,
            suggestedValues: null,
            cm: null,
            token: null
        },
        
        _create: function () {
            
            var self = this,
            elementName = self.options.elementName,
            suggestedAttributes = self.options.suggestedAttributes,
            suggestedValues = self.options.suggestedValues,
            editedAttributes = self.options.editedAttributes,
            
            mainDiv = $('<div></div>').attr("class", uiMainDivId),
            
            editAttributesDiv = $('<div></div>').addClass(uiEditAttributesDivClass).addClass(uiFormsTableClass),
            
            droppableAttributeDiv = $('<div>&#160;</div>').addClass(uiDroppableAttributeDivClass),
            
            suggestedAttributesDiv = $('<div></div>').addClass(uiSuggestedAttributesDivClass)
            
            
            for (var i = 0 in editedAttributes) {
                editAttributesDiv.append(self._newEditAttribute(editedAttributes[i].qName, $(document).xrxI18n.translate(editedAttributes[i].qName, "xs:attribute"), editedAttributes[i].value));
                console.log('#############################');
                console.log(editedAttributes);
            }
            
            // var wert = self._attributeDroppable(droppableAttributeDiv);
            self._attributeDroppable(droppableAttributeDiv);
            console.log('MÄHHHHHHHHHÄÄÄÄÄÄÄÄÄÄÄÄÄÄHHHHHHHHHH');
            console.log(self);
            console.log('kann es das gewesen sein');
            
            //neu für values
            
            /* if (editedAttributes) {
            console.log('test ob attr vorhanden sind');
            //das wird angezeigt, wenn die seite neu geladen wird und schon attribute ausgewählt wurden.
            console.log(editedAttributes);
            for (var i = 0 in suggestedValues) {
            
            //suggestedValuesDiv.append(self._newEditValue(suggestedValues[i].qName, suggestedValues[i].label, suggestedValues[i].value ));
            self.newEditValue(suggestedValues[i].qName, suggestedValues[i].label, suggestedValues[i].value)
             *
            }
            } else {
            }*/
            
            
            for (var i = 0 in suggestedAttributes) {
                var name = suggestedAttributes[i];
                var newDiv = $('<div>' + $(document).xrxI18n.translate(name, "xs:attribute") + '<div>').addClass(uiSuggestedAttributeDivsClass).attr("title", name);
                
                suggestedAttributesDiv.append(newDiv);
                self._suggestedAttributeDraggable(newDiv);
                console.log('WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW')
                console.log(self._suggestedAttributeDraggable(newDiv));
                //Hier werden alle möglichen Attributsnamen ausgegeben.
            }
            
            
            mainDiv.append(editAttributesDiv).append(droppableAttributeDiv).append(suggestedAttributesDiv);
            self.element.replaceWith(mainDiv);
            console.log('MAINDIV---------------MAINDIV');
            console.log(self.element);
            
            for (var i = 0 in editedAttributes) {
                $("div[title='" + editedAttributes[i].qName + "']", "." + uiMainDivId).draggable("disable");
            }
            
            ampel = false;
            $(function () {
                $("#choose").menu();
            });
        },
        //Ende create funktion
        
        _newEditAttribute: function (name, label, value) {
            
            var self = this,
            cm = self.options.cm,
            token = self.options.token,
            suggestedValue = self.options.suggestedValues,
            editedAttributes = self.options.editedAttributes,
            elementName = self.options.elementName,
            
            newEditAttribute = $('<div></div>').addClass(uiFormsTableRowClass).addClass(uiEditAttributeDivClass),
            newEditAttributeLabel = $('<div><span>' + label + '<span></div>').addClass(uiFormsTableCellClass),
            newEditAttributeInput = $('<input></input>').addClass(uiFormsTableCellClass).attr("value", value).attr("name", name),
            newEditValuelabel = $('<div><span>' + label + '<span></div>').addClass(uiFormsTableCellClass),
            menuliste = $('<select></select>').attr('class', 'choose').addClass(uiFormsTableCellClass),
            
            newEditAttributeTrash = $('<div><span class="ui-icon ui-icon-trash"/></div>').
            addClass(uiFormsTableCellClass);
            
            console.log(elementName);
            console.log('SUGOOOOOOOOOOO');
            console.log(suggestedValue);
            var jsonValues = jQuery.parseJSON($('.xrx-forms-json-values').text());
            var suggestedVal = jsonValues[elementName];
            console.log("frage nach label");
            console.log(name);
            console.log(label);
            console.log(value);
            console.log(self);
            console.log(newEditAttribute);
            //der name ist der Attributsname
            var mainkeys = Object.getOwnPropertyNames(suggestedVal).sort();
            
            console.log('das sind die suggestedValöööööööööööö');
            console.log(suggestedVal);
            console.log(suggestedVal.lang instanceof Array);
            console.log('hier die mainkeys');
            console.log(mainkeys);
            console.log(editedAttributes);
            var werte =[];
            var attrname =[];
            for (var i = 0; i < editedAttributes.length; i++) {
                q = editedAttributes[i].qName;
                w = editedAttributes[i].value;
                console.log('das werte array');
                //console.log(werte)
                console.log(w);
                werte.push(w);
                attrname.push(q);
            }
            if (werte.indexOf('other')!= -1){
            	ampel = true;
            }
            
            console.log(werte);
            if ((ampel == true) && (name != 'indexName')) {
                console.log('66666666666');
                console.log('wird erledigt ohne reload');
                newEditAttribute.append(newEditAttributeLabel).append(newEditAttributeInput).append(newEditAttributeTrash);
           }
            else if (((attrname.indexOf('indexName') == -1) && (name == 'lemma')) | ((attrname.indexOf('indexName') == -1) && (name == 'sublemma'))) {
                console.log('++++++++++++++++++++++++++++++++++++');
                newEditAttribute.append(newEditAttributeLabel).append(newEditAttributeInput).append(newEditAttributeTrash);
            } else {
                console.log('++++++++111111111111111111+++++++++++++++');
                for (var mk in suggestedVal) {
                    
                    console.log('MK: ' + mk + ' : ' + suggestedVal[mk]);
                    console.log(mk);
                    console.log(suggestedVal[mk] instanceof Array);
                    if ((mk == name) && (suggestedVal[mk] instanceof Array) && (suggestedVal[mk].length !== 0)) {
                        
                        newEditAttributeLabel.hide();
                        newEditAttributeInput.hide();
                        newEditAttribute.append(newEditValuelabel).append(menuliste).append(newEditAttributeTrash);
                        /*newVal = (self.newEditValue(name, label, value));*/
                        /*newEditAttribute.append(newVal.a).append(newVal.b).append(newEditAttributeTrash);*/
                    } else {
                        newEditAttribute.append(newEditAttributeLabel).append(newEditAttributeInput).append(newEditAttributeTrash);
                    }
                }
            }
            
            self._trashIconClickable(newEditAttributeTrash, newEditAttribute);
            nea = self;
            function raus(sugname, startvalue, endvalue) {
                for (var startvalue; startvalue < endvalue; startvalue++) {
                    
                    var einf = $('<option> --- </option>');
                    var newli = $('<option>' + sugname[startvalue] + '</option>').addClass(uiSuggestedValueDivsClass).attr("title", sugname[startvalue]).attr("value", sugname[startvalue]);
                    console.log("der startvalue");
                    console.log(startvalue);
                    if (sugname[startvalue] == value) {
                        newli.attr("selected", "selected");
                    }
                    menuliste.append(einf).append(newli);
                    var nodeset = $(document).xrx.nodeset(cm.getInputField());
                    console.log('NEA DEMOCRAZIA');
                    console.log(nea);
                    newli.bind("click", function (ev) {
                        self = this;
                        var blini = this.title;
                        var attributes = new AttributesImpl();
                        attributes.addAttribute(undefined, name, name, undefined, blini);
                        console.log(blini);
                        //das ist der wert, der ohne reload gemerkt werden muss
                        console.log('Das ist der name');
                        console.log(name);
                        console.log(attributes);
                        console.log(self);
                        console.log('NEA DEMOCRAZIA');
                        console.log(nea);
                        var controlId = nodeset.only.levelId;
                        var relativeId = token.state.context.id.split('.').splice(1);
                        var contextId = controlId.concat(relativeId);
                        
                        if (blini == 'other') {
                            var tois = $("div", "." + uiEditAttributeDivClass).find("span").not(".ui-icon").text();
                            var opt = $("select").find("option[selected='selected']").text();
                            console.log(opt);
                            console.log(tois);
                            console.log(tois.indexOf('sublemma'));
                            var indexsub = tois.indexOf('sublemma');
                            var indexlem = tois.indexOf('lemma');
                            var indexopt = opt.indexOf('arthistorian');
                            if (indexsub != -1) {
                                console.log('weg damit');
                                var cId =[1, 7, 1, 2, 2, 3, 4, 1, 1, "2"];
                                var schein = new AttributesImpl();
                                schein.addAttribute(undefined, 'sublemma', 'sublemma', undefined, '');
                                console.log(schein);
                                var row = $("div:contains('sublemma')", "." + uiEditAttributesDivClass);
                                console.log(row);
                                row.remove();
                                $('.xrx-instance').xrxInstance().deleteAttributes(cId, schein);
                                $("div", "." + uiSuggestedAttributesDivClass).addClass("ui-state-disabled");
                                // $("div[title='sublemma']", "."+ uiSuggestedAttributesDivClass).draggable("enable");
                            }
                            if (indexlem != -1) {
                                console.log('weg damit22222');
                                var cId =[1, 7, 1, 2, 2, 3, 4, 1, 1, "2"];
                                var schein = new AttributesImpl();
                                schein.addAttribute(undefined, 'lemma', 'lemma', undefined, '');
                                console.log(schein);
                                var row = $("div:contains('lemma')", "." + uiEditAttributesDivClass);
                                console.log(row);
                                row.remove();
                                $('.xrx-instance').xrxInstance().deleteAttributes(cId, schein);
                                $("div", "." + uiSuggestedAttributesDivClass).addClass("ui-state-disabled");
                                //$("div[title='lemma']", "."+ uiSuggestedAttributesDivClass).draggable("enable");
                            }
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
                                    $("div:contains('" + proof + "')", "." + uiSuggestedAttributesDivClass).draggable("enable");
                                    console.log(spantexte);
                                    ampel = true;
                                    //editWidget = nea._newEditAttribute( 'xxx', 'xxx', "");
                                    console.log("FFFFFFFFFFFFFFFFFFFFFFFFFFFF");
                                    console.log(ampel);
                                }
                            }
                        }
                        if (blini == 'arthistorian') {
                            
                            $("div", "." + uiSuggestedAttributeDivsClass).each(function () {
                               /* if ($(this).hasClass("ui-state-disabled")) {
                                    console.log('the if is the case');
                                } else {*/
                                    var tois = $("div", "." + uiEditAttributeDivClass).find("span").not(".ui-icon").text();
                                    var opt = $("select").find("option[selected='selected']").text();
                                    console.log(opt);
                                    console.log(tois);
                                    console.log(tois.indexOf('sublemma'));
                                    var indexsub = tois.indexOf('sublemma');
                                    var indexlem = tois.indexOf('lemma');
                                    var indexopt = opt.indexOf('other');
                                    if (indexsub != -1) {
                                        console.log('weg damit');
                                        var cId =[1, 7, 1, 2, 2, 3, 4, 1, 1, "2"];//das ist die contextId
                                        var schein = new AttributesImpl();
                                        schein.addAttribute(undefined, 'sublemma', 'sublemma', undefined, '');
                                        console.log(schein);
                                        var row = $("div:contains('sublemma')", "." + uiEditAttributesDivClass);
                                        console.log(row);
                                        row.remove();
                                        $('.xrx-instance').xrxInstance().deleteAttributes(cId, schein);
                                        $("div", "." + uiSuggestedAttributesDivClass).addClass("ui-state-disabled");
                                        $("div[title='sublemma']", "." + uiSuggestedAttributesDivClass).draggable("enable");
                                    }
                                    if (indexlem != -1) {
                                        console.log('weg damit22222');
                                        var cId =[1, 7, 1, 2, 2, 3, 4, 1, 1, "2"];
                                        var schein = new AttributesImpl();
                                        schein.addAttribute(undefined, 'lemma', 'lemma', undefined, '');
                                        console.log(schein);
                                        var row = $("div:contains('lemma')", "." + uiEditAttributesDivClass);
                                        console.log(row);
                                        row.remove();
                                        $('.xrx-instance').xrxInstance().deleteAttributes(cId, schein);
                                        $("div", "." + uiSuggestedAttributesDivClass).addClass("ui-state-disabled");
                                        $("div[title='lemma']", "." + uiSuggestedAttributesDivClass).draggable("enable");
                                    }
                                    $("div", "." + uiSuggestedAttributesDivClass).addClass("ui-state-disabled");
                                    $("div[title='lemma']", "." + uiSuggestedAttributesDivClass).draggable("enable");
                                    console.log('das else ist eingetreten');
                                    
                                }
                        //    }
                        );
                            ampel = false;
                        }
                        
                        
                        if (name == 'lemma') {
                            $("div[title='sublemma']", "." + uiSuggestedAttributesDivClass).draggable("enable");
                            console.log("DAS ========== Schweigen ============");
                            //console.log($("div", "."+ uiEditAttributesDivClass).find("span"));
                            var tois = $("div", "." + uiEditAttributeDivClass).find("span").not(".ui-icon").text();
                            var opt = $("select").find("option[selected='selected']").text();
                            console.log(opt);
                            console.log(tois);
                            console.log(tois.indexOf('sublemma'));
                            var indexsub = tois.indexOf('sublemma');
                            var indexopt = opt.indexOf('other');
                            if (indexsub != -1) {
                                console.log('weg damit');
                                var cId =[1, 7, 1, 2, 2, 3, 4, 1, 1, "2"];
                                var schein = new AttributesImpl();
                                schein.addAttribute(undefined, 'sublemma', 'sublemma', undefined, '');
                                console.log(schein);
                                var row = $("div:contains('sublemma')", "." + uiEditAttributesDivClass);
                                console.log(row);
                                row.remove();
                                $('.xrx-instance').xrxInstance().deleteAttributes(cId, schein);
                                $("div", "." + uiSuggestedAttributesDivClass).addClass("ui-state-disabled");
                                $("div[title='sublemma']", "." + uiSuggestedAttributesDivClass).draggable("enable");
                            }
                        }
                        if (name == 'sublemma') {
                            console.log('-----------++++++++++++++++++++-----------------------')
                            //console.log($(".forms-mixedcontent-edit-attribute").find("span").text());
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
                                    $("div:contains('" + proof + "')", "." + uiSuggestedAttributesDivClass).draggable("enable");
                                    console.log(spantexte);
                                }
                            }
                        }
                        
                        $('.xrx-instance').xrxInstance().replaceAttributeValue(contextId, attributes);
                    });
                }
                return endvalue;
            }
            
            
            Object.getOwnPropertyNames(suggestedVal).forEach(function (val, idx, array) {
                
                if (val == name) {
                    
                    var sugname = suggestedVal[val];
                    
                    console.log('der wert als value');
                    console.log(value);
                    console.log(Boolean ($("option:contains(" + value + ")")));
                    //da kommt true raus
                    var nodeset = $(document).xrx.nodeset(cm.getInputField());
                    var nodesetxmlstring = nodeset.only.xml;
                    
                    if (name == 'indexName') {
                        console.log("3§§§§§§§§§§§§§§§§§§§§§§§§§§§?");
                        var x = raus(sugname, 0, 2);
                    } else if (name == 'lemma') {
                        console.log('ssssssssssssssssssssssssssssssssssssssss');
                        console.log(sugname);
                        console.log(suggestedVal);
                        console.log(val);
                        console.log(name);
                        console.log(label);
                        var x = raus(sugname, 0, 3);
                    } else if (name == 'sublemma') {
                        console.log("GGGGGGGGGGGGgggeht das???????")
                        if (nodesetxmlstring.contains('N1')) {
                            console.log("bababababababab");
                            
                            console.log(sugname);
                            var startvalue = 0;
                            var endvalue = 6;
                            var x = raus(sugname, 0, 7);
                            console.log(x);
                        } else if (nodesetxmlstring.contains('"N2"')) {
                            console.log('TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT');
                            console.log(sugname);
                            var startvalue = 7;
                            var endvalue = 14;
                            var x = raus(sugname, 7, 15);
                            console.log(x);
                        } else if (nodesetxmlstring.contains('"N3"')) {
                            console.log('mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm');
                            var startvalue = 15;
                            var endvalue = sugname.length;
                            var x = raus(sugname, 15, 21);
                            console.log(x);
                        }
                    }
                    /*else {
                    console.log("das else wird ausgeführt");
                    var startvalue = 0;
                    var endvalue = sugname.length;
                    var x = raus(sugname, startvalue, endvalue);
                    }*/
                }
                //Ende des ersten IF
            });
            
            $(menuliste).menu();
            
            
            /*  return {
            a: newEditValuelabel, b: menuliste
            };
            }
            ende der Value Funktion*/
            newEditAttributeInput.keyup(function () {
                var attributes = new AttributesImpl();
                attributes.addAttribute(null, name, name, undefined, $(this).val());
                
                var nodeset = $(document).xrx.nodeset(cm.getInputField());
                var controlId = nodeset.only.levelId;
                var relativeId = token.state.context.id.split('.').splice(1);
                var contextId = controlId.concat(relativeId);
                
                $('.xrx-instance').xrxInstance().replaceAttributeValue(contextId, attributes);
                console.log('das ist der input wert');
                console.log($(this).val());
                console.log($('.xrx-instance').xrxInstance());
                console.log(name);
                //attribut name
                console.log(label);
                console.log(value);
            })
            
            
            console.log('++++++++++++++++++++++++++++++++++++');
            console.log(newEditAttribute);
            //es wird ein Objekt erzeugt, dass aber keinen title hat nur einen titlecontext
            //der verwirrend - nicht eindeutig ist.z.B. sublemmasublemma - werte...
            console.log('++++++++++++++++++++++++++++++++++++');
            return newEditAttribute;
        },
        
        //Ende _newEditAttribute
        
        
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
                console.log('+++++++++++++++++++++++++++***************++++++++++++++++++++');
                console.log(nodeset);
                console.log(contextId);
                console.log(attributes);
                $('.xrx-instance').xrxInstance().deleteAttributes(contextId, attributes);
                if (attributes.attsArray[0].qName == 'indexName') {
                    ampel = false;
                    console.log('Ja das stimmt. Ampel ist wahr');
                }
            });
        },
        //Ende _trashIconClickable
        
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
                    console.log('Drop it like its hot, drop it like its hot');
                    console.log(suggestedAttribute[0].title);
                }
            });
            console.log('das wird gedragggggggt!');
            console.log(suggestedAttribute.draggable("option", "start"));
            return suggestedAttribute[0].title;
        },
        //Ende _suggestedAttributeDraggable
        
        
        _attributeDroppable: function (droppableAttribute) {
            console.log('******************************');
            console.log(droppableAttribute);
            //ist obj - das aber keinen title drin hat
            console.log('******************************');
            var self = this,
            cm = self.options.cm,
            token = self.options.token,
            suggestedValues = self.options.suggestedValues,
            elementName = self.options.elementName;
            
            droppableAttribute.droppable({
                accept: "." + uiSuggestedAttributeDivsClass,
                drop: function (event, ui) {
                    
                    var draggable = ui.draggable,
                    qName = draggable.attr("title"),
                    label = draggable.text(),
                    editWidget = self._newEditAttribute(qName, label, "");
                    console.log('-------------------------');
                    console.log(self);
                    console.log(editWidget);
                    var attributes = new AttributesImpl();
                    attributes.addAttribute(null, qName, qName, undefined, "");
                    
                    $("." + uiEditAttributesDivClass, "." + uiMainDivId).append(editWidget);
                    draggable.draggable("disable");
                    
                    var nodeset = $(document).xrx.nodeset(cm.getInputField());
                    var controlId = nodeset.only.levelId;
                    var relativeId = token.state.context.id.split('.').splice(1);
                    var contextId = controlId.concat(relativeId);
                    $('.xrx-instance').xrxInstance().insertAttributes(contextId, attributes);
                    console.log('nun wurden die atts eingefügt');
                    //das wird angezeigt, wenn ein att soeben gedroppt wurde
                    console.log(qName);
                }
            });
            console.log('drop');
            console.log(self);
        },
        //Ende _attributeDroppable
        
        hide: function () {
        }
    });
})(jQuery);
