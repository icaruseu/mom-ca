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
along with VdU/VRET.  If not, see <http://www.gnu.org/licenses/>.

We expect VdU/VRET to be distributed in the future with a license more lenient towards the inclusion of components into other systems, once it leaves the active development stage.
*/
/*!
 * jQuery XRX Instance
 */
;(function($) {
	
	var onautosave;
	
	/*
	 * public interface
	 */
	$.fn.xrxInstance = function(options) {
		
		//console.log(options);
		return this.each(function(index) {});
	};
	
	$.fn.replaceElementNode = function(contextId, xml) {
		
		$(this).text(window.XML.replaceElementNode($(this).text(), contextId, xml));
		autosave();
	};
	
	$.fn.insertAttributes = function(contextId, attributes) {
		
		$(this).text(window.XML.insertAttributes($(this).text(), contextId, attributes));
		//console.log($(this).text());
		//console.log('contextid');
		//console.log(contextId);
		//console.log('das sind die atts');
		//console.log(attributes);
		autosave();
	};
	
	$.fn.deleteAttributes = function(contextId, attributes) {

		$(this).text(window.XML.deleteAttributes($(this).text(), contextId, attributes));	
		autosave();
	};
	
	$.fn.replaceAttributeValue = function(contextId, attributes) {
		
		$(this).text(window.XML.replaceAttributeValue($(this).text(), contextId, attributes));
		autosave();		
	};
	
	$.fn.insertAfter = function(contextId, xml) {
		
		$(this).text(window.XML.insertAfter($(this).text(), contextId, xml));
		autosave();
	};
	
	$.fn.insertBefore = function(contextId, xml) {
		
		$(this).text(window.XML.insertBefore($(this).text(), contextId, xml));
		autosave();
	};
	
	$.fn.insertInto = function(contextId, xml) {
		
		$(this).text(window.XML.insertInto($(this).text(), contextId, xml));
		autosave();
	};	
	
	$.fn.deleteElementTag = function(contextId) {
		
		$(this).text(window.XML.deleteElementTag($(this).text(), contextId));
		autosave();
	};
	
	$.fn.insertElementTag = function(first, last) {
		
		$(this).text(window.XML.insertElementTag($(this).text(), first, last));
		autosave();
	};
	
	$.fn.replaceMixedSelection = function(first, last, xml) {
		
		$(this).text(window.XML.replaceMixedSelection($(this).text(), first, last, xml));
		autosave();
	};
	
	$.fn.replaceTextNode = function(contextId, contextNum, xml) {
		
		$(this).text(window.XML.replaceTextNode($(this).text(), contextId, contextNum, xml));
		autosave();
	};
	
	$.fn.deleteTextNode = function(endElementId) {
		
		$(this).text(window.XML.deleteTextNode($(this).text(), endElementId));
		autosave();
	};


	/*
	 * private functions
	 */
	function autosave() {

		clearTimeout(onautosave);
		$("#autoSaveStatus").text("Saving ...");
		onautosave = setTimeout( function() {
			// TODO: replace with event handler
			console.log($(document).xmleditor("save"));
			$(".xrx-report").xrxReport("validate");
		}, 1000);	
	};
	
})(jQuery);