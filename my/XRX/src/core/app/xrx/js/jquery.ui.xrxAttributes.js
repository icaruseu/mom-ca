/*!
 * jQuery UI Forms Mixed Content Attributes
 *
 * Depends:
 *   jquery.ui.core.js
 *   jquery.ui.widget.js
 *   jquery.ui.draggable.js
 *   jquery.ui.droppable.js
 */
(function( $, undefined ) {

var uiMainDivId						=	"xrx-attributes";
var uiTagnameDivClass				=	"forms-mixedcontent-attributes-tagname";
var uiEditAttributesDivClass		=	"forms-mixedcontent-edit-attributes";
var uiEditAttributeDivClass			=	"forms-mixedcontent-edit-attribute";
var uiSuggestedAttributesDivClass	=	"forms-mixedcontent-suggested-attributes";
var uiSuggestedAttributeDivsClass	=	"forms-mixedcontent-suggested-attribute";
var uiDroppableAttributeDivClass	=	"forms-mixedcontent-attribute-droppable";
/* variablenerweiterung aufgrund von attribut values */
var uiSuggestedValuesDivClass = "forms-mixedcontent-suggested-values";
var uiSuggestedValueDivsClass = "forms-mixedcontent-suggested-value";
var uiDroppableValueDivClass = "forms-mixedcontent-value-droppable";

var uiFormsTableClass				=	"forms-table";
var uiFormsTableRowClass			=	"forms-table-row";
var uiFormsTableCellClass			=	"forms-table-cell";

$.widget( "ui.xrxAttributes", {
	
	options: {
		elementName:null,
		suggestedAttributes:null,
		editedAttributes:null,
		suggestedValues:null,
		cm:null,
		token:null
	},
	
	_create: function() {
		
		var self = this,
		    elementName = self.options.elementName,
			suggestedAttributes = self.options.suggestedAttributes,
			suggestedValues = self.options.suggestedValues,
			editedAttributes = self.options.editedAttributes,
			
			mainDiv = $('<div></div>')
				.attr("class", uiMainDivId),
				
			editAttributesDiv = $('<div></div>')
				.addClass(uiEditAttributesDivClass)
				.addClass(uiFormsTableClass),
			
			droppableAttributeDiv = $('<div>&#160;</div>')
				.addClass(uiDroppableAttributeDivClass),
				
			suggestedAttributesDiv = $('<div></div>')
				.addClass(uiSuggestedAttributesDivClass),
				
			suggestedValuesDiv = $('<div></div>')
				.addClass(uiSuggestedValuesDivClass)
		
		for(var i = 0 in editedAttributes) {
			editAttributesDiv.append(self._newEditAttribute(editedAttributes[i].qName, $(document).xrxI18n.translate(editedAttributes[i].qName, "xs:attribute"), editedAttributes[i].value));
		
	
		}	
		
		self._attributeDroppable(droppableAttributeDiv);
		console.log(editedAttributes);
		//neu für values
		if(editedAttributes){
			console.log('test ob attr vorhanden sind');	//das wird angezeigt, wenn die seite neu geladen wird und schon attribute ausgewählt wurden.	
			console.log(editedAttributes);
			for(var i = 0 in suggestedValues) {
			
			suggestedValuesDiv.append(self._newEditValue(suggestedValues[i].qName, suggestedValues[i].label, suggestedValues[i].value ));
		}
			
		}	
	
		
		for(var i = 0 in suggestedAttributes) {
			var name = suggestedAttributes[i];
			var newDiv = $('<div>' + $(document).xrxI18n.translate(name, "xs:attribute") + '<div>')
							.addClass(uiSuggestedAttributeDivsClass)
							.attr("title", name);
			
			suggestedAttributesDiv.append(newDiv);
			self._suggestedAttributeDraggable(newDiv);
		}

		
		mainDiv
			.append(editAttributesDiv)
			.append(droppableAttributeDiv)
			.append(suggestedAttributesDiv)
			.append(suggestedValuesDiv);
		self.element.replaceWith(mainDiv);
			
		for(var i = 0 in editedAttributes) {
			$("div[title='" + editedAttributes[i].qName + "']", "." + uiMainDivId).draggable("disable");
		}
		$(function() { $( "#choose" ).menu();
        });
	},	
	//Ende create funktion
	
	_newEditAttribute: function(name, label, value) {
		
		var self = this,
			cm = self.options.cm,
			token = self.options.token,
			suggestedValue = self.options.suggestedValues,
			elementName = self.options.elementName,
			
			newEditAttribute = $('<div></div>')
				.addClass(uiFormsTableRowClass)
				.addClass(uiEditAttributeDivClass),
			newEditAttributeLabel = $('<div><span>' + label + '<span></div>')
				.addClass(uiFormsTableCellClass),
			newEditAttributeInput = $('<input></input>')
				.addClass(uiFormsTableCellClass)
				.attr("value", value)
				.attr("name", name),
			newEditAttributeTrash = $('<div><span class="ui-icon ui-icon-trash"/></div>').
				addClass(uiFormsTableCellClass);
		
		newEditAttribute.append(newEditAttributeLabel)
			.append(newEditAttributeInput)			
			.append(newEditAttributeTrash);
			
		self._trashIconClickable(newEditAttributeTrash, newEditAttribute);
		
		
			
		newEditAttributeInput.keyup(function() {
			var attributes = new AttributesImpl();
			attributes.addAttribute(null, name, name, undefined, $(this).val());
			
			var nodeset = $(document).xrx.nodeset(cm.getInputField());
			var controlId = nodeset.only.levelId;
			var relativeId = token.state.context.id.split('.').splice(1);
			var contextId = controlId.concat(relativeId);
			
			$('.xrx-instance').xrxInstance().replaceAttributeValue(contextId, attributes);
			console.log('das ist der input wert');
			console.log( $(this).val());
			console.log(name); //attribut name
			console.log(label);
			console.log(value);
		})
		
		return newEditAttribute;	
	},	
	
	//Ende _newEditAttribute
_newEditValue: function(name, label, value) {
		
		var self = this,
			cm = self.options.cm,
			token = self.options.token,
			elementName = self.options.elementName,
			editedAttributes = self.options.editedAttributes,
			//suggestedValues = self.options.suggestedValues,
			subkey=[];
		
			newEditValue = $('<div></div>')
				.addClass(uiFormsTableCellClass);
				
		
			var menuliste = $('<select></select>').attr('class', 'choose');
			 	
		newEditValue.append(menuliste);	
	
		var jsonValues = jQuery.parseJSON($('.xrx-forms-json-values').text());
		
		        
         var suggestedVal = jsonValues[elementName];
         console.log("frage nach label");
         console.log(name); 
         console.log(label);
         console.log(value); //der name ist der Attributsname
         var mainkeys = Object.getOwnPropertyNames(suggestedVal).sort();
        
         console.log('das sind die suggestedVal');
         console.log(suggestedVal);
         
     	Object.getOwnPropertyNames(suggestedVal).forEach(function(val, idx, array) {
          		
     			if(val == name){
     				console.log('schlüssel mit name abgleichen');
     				console.log(val + ' -> ' + suggestedVal[val]);
     				console.log(suggestedVal[val]);
     				var sugname = suggestedVal[val];
     				//var valuetitle = $('<option style="font-weight:bold">values for @'+name+'</option>');
     				//menuliste.append(valuetitle);
     				for(var i=0; i<sugname.length;i++){
     				
     				var newli = $('<option><a href="#">' + sugname[i] + '</a></option>')
					.addClass(uiSuggestedValueDivsClass)
					.attr("title", sugname[i]);
					
					menuliste.append(newli); 	
					newli.bind("click", function(event) {
						self=this;
						console.log('das ist der self');
						console.log(name);								
				     var blini = this.title;						     
				     var attributes = new AttributesImpl();
					 attributes.addAttribute(undefined, name, name, undefined, blini);
					 	console.log(blini);
						console.log('Das ist der name');
						console.log(name);
						var nodeset = $(document).xrx.nodeset(cm.getInputField());
						var controlId = nodeset.only.levelId;
						var relativeId = token.state.context.id.split('.').splice(1);
						var contextId = controlId.concat(relativeId);
						
						$('.xrx-instance').xrxInstance().replaceAttributeValue(contextId, attributes);
						//$("input.forms-table-cell[name="+name+"]").val(blini);
						//$("input.forms-table-cell[name="+name+"]").hide();
					});
					
     				}	
     				
     		}
     				
     		}); 	
     		$(menuliste).menu();
     		$("div.forms-table-cell").remove("input");
     		$("div.forms-mixedcontent-edit-attribute").append(menuliste).append("div.forms-table-cell");
	
            
		return newEditValue;
	 	
		  
	},
	
	_trashIconClickable: function(trashIcon, editAttribute) {

		var self = this,
			cm = self.options.cm,
			token = self.options.token;
				
		trashIcon.click(function(event) {
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
			$('.choose').hide();
		});		
	},
	//Ende _trashIconClickable
	
	_suggestedAttributeDraggable: function(suggestedAttribute) {
		
		var self = this;
		
		suggestedAttribute.draggable({
			containment: "." + uiMainDivId,
			revert: "invalid",
			cursor: "move",
			helper: "clone",
			start: function(event, ui) { 
				$("." + uiDroppableAttributeDivClass, "." + uiMainDivId).addClass("edit-attributes-droppable-active"); 
				suggestedAttribute.addClass("suggested-attribute-draggable-disabled"); 
			},
			stop: function(event, ui) { 
				$("." + uiDroppableAttributeDivClass, "." + uiMainDivId).removeClass("edit-attributes-droppable-active"); 
				suggestedAttribute.removeClass("suggested-attribute-draggable-disabled"); 
			}
		});		
	},	
	//Ende _suggestedAttributeDraggable
	
	//neue Funktion für Values
	_suggestedValueDraggable: function(suggestedValue){
		var self = this;
		
		suggestedValue.draggable({
			containment: "." + uiMainDivId,
			revert: "invalid",
			cursor: "move",
			helper: "clone",
			start: function(event, ui) { 
				$("." + uiDroppableValueDivClass, "." + uiMainDivId).addClass("edit-values-droppable-active"); 
				suggestedAttribute.addClass("suggested-value-draggable-disabled"); 
			},
			stop: function(event, ui) { 
				$("." + uiDroppableValueDivClass, "." + uiMainDivId).removeClass("edit-values-droppable-active"); 
				suggestedValue.removeClass("suggested-value-draggable-disabled"); 
			}
		});
	},
	//Ende 
	_attributeDroppable: function(droppableAttribute) {
		
		var self = this,
			cm = self.options.cm,
			token = self.options.token,
			suggestedValues = self.options.suggestedValues,
			elementName = self.options.elementName;
		  
		droppableAttribute.droppable({
			accept: "." + uiSuggestedAttributeDivsClass,
			drop: function(event, ui) {
				
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
				console.log('nun wurden die atts eingefügt');//das wird angezeigt, wenn ein att soeben gedroppt wurde				
				console.log(qName);
				var jsonValues = jQuery.parseJSON($('.xrx-forms-json-values').text());	        
		        var suggestedVal = jsonValues[elementName];
		        var subkey =  Object.getOwnPropertyNames(suggestedVal);
		        for (var a =0;a<suggestedVal.length; a++)
		        	{
		        	console.log('brauche werte der keys');
		        	console.log(suggestedVal[a]);
		        	}
		        console.log('noi die subkey');
		        console.log(subkey);
		        for (var b =0;b<subkey.length; b++){		       
				
				if (qName == subkey[b]){					
					//for(var i = 0 in suggestedValues) {
						console.log('die sugg Val');
						console.log(qName);
						console.log(label);
						console.log(suggestedValues.value);	
						//$("input.forms-table-cell").remove();
						//$(".forms-mixedcontent-suggested-values").append(self._newEditValue(suggestedValues.qName, suggestedValues.label, suggestedValues.value ));
						$(".forms-mixedcontent-suggested-values").append(self._newEditValue(qName, label, suggestedValues.value ));
						
					//}
				
				}
				else {
	        		console.log('shitty');
	        	}
				         
		        }
		       
		        
			}
		
		});
		
	},
	//Ende _attributeDroppable
	
	hide: function() {
		
		
	}

});

	
})( jQuery );