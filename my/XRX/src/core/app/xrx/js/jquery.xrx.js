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
 * jQuery XRX Forms implementation
 */
;(function($) {
		
	var CONTROL_VISUALXML =            'xrx-visualxml';
	var CONTROL_REPORT =               'xrx-report';
	var CONTROL_SELECT1 =              'xrx-select1';
	
	var CONTEXT_REPEAT =               'xrx-repeat';
	var CONTEXT_SELECT =               'xrx-select';
	
	var DATA_BIND =                    'xrx-bind';
	var DATA_INSTANCE =                'xrx-instance';
	
	var UI_LAYOUT =                    'xrx-layout';
	var UI_TABS =                      'xrx-tabs';

	$.fn.xrx = function(options) {
		
		var opts = $.extend({}, $.fn.xrx.defaults, options);
		return this.each(function(index) {
			$(document).xrxI18n();
			initModel(opts);
			initControls(opts);
			initContexts(opts);
			initUi(opts);
		});
	};
	
	$.fn.xrx.validationRefresh = function() {
		
		$("." + CONTROL_VISUALXML).each(function(index) {
			$(this).xrxVisualxml("validationRefresh");
		});
	};
	
	$.fn.xrx.nodeset = function(control) {
		var select = $(control).parents(".xrx-select"), nodeset;
		var repeat = $(control).parents(".xrx-repeat"), nodeset;
		
		if(repeat.length > 0) {
			var bindId = $(repeat).attr('data-xrx-bind');
			var ref = $(control).attr('data-xrx-ref');
			var index = parseInt($(control).attr('data-xrx-index'));
			var expression = $('#' + bindId).attr('data-xrx-nodeset') + ref;
			nodeset = window.XPath.query(expression, $('.xrx-instance').text());
			if(nodeset.only == null || nodeset.only == undefined) {
				nodeset.only = {};
				nodeset.only.qName = nodeset.nodes[index].qName;
				nodeset.only.xml = nodeset.nodes[index].xml;
				nodeset.only.levelId = nodeset.nodes[index].levelId;
			}
		}
		else if(select.length > 0){			
			var bindId = $(select).attr('data-xrx-bind');
			var ref = $(control).attr('data-xrx-ref');
			var index = parseInt($(control).attr('data-xrx-index'));
			var expression = $('#' + bindId).attr('data-xrx-nodeset') + ref;
			nodeset = window.XPath.query(expression, $('.xrx-instance').text());
			if(nodeset.only == null || nodeset.only == undefined) {
				nodeset.only = {};
				nodeset.only.qName = nodeset.nodes[index].qName;
				nodeset.only.xml = nodeset.nodes[index].xml;
				nodeset.only.levelId = nodeset.nodes[index].levelId;
			}
		}
		else {
			var bindId = $(control).attr('data-xrx-bind');
			var expression = $('#' + bindId).attr('data-xrx-nodeset');
			nodeset = window.XPath.query(expression, $('.xrx-instance').text());
		}
		
		return nodeset;		
	};
	
	function initModel(opts) {
		
		$("." + DATA_BIND).each(function(index) {
			createModelItem(this, DATA_BIND, opts);
		});		
		$("." + DATA_INSTANCE).each(function(index) {
			createModelItem(this, DATA_INSTANCE, opts);
		});
	}
	
	function initControls(opts) {
		
		$("." + CONTROL_VISUALXML).each(function(index) {
			createControl(this, CONTROL_VISUALXML, opts, false);
		});
		$("." + CONTROL_REPORT).each(function(index) {
			createControl(this, CONTROL_REPORT, opts, false);
		});
		$("." + CONTROL_SELECT1).each(function(index) {
			createControl(this, CONTROL_SELECT1, opts, false);
		});	
	}
	
	function initContexts(opts) {

		$("." + CONTEXT_REPEAT).each(function(index) {
			$(this).xrxRepeat();
		});
		$("." + CONTEXT_SELECT).each(function(index) {
			$(this).xrxSelect();
		});
	}
	
	function initUi(opts) {

		$("." + UI_LAYOUT).each(function(index) {
			createUi(this, UI_LAYOUT, opts);
		});
		$("." + UI_TABS).each(function(index) {
			createUi(this, UI_TABS, opts);
		});		
	}
	
	function createModelItem(element, modelItemType, opts) {
		
		switch(modelItemType) {
		case DATA_BIND:
			$(element).xrxBind();
			break;
		case DATA_INSTANCE:
			$(element).xrxInstance();
			break;
		default:
			break;
		}
	}
	
	function createControl(element, controlType, opts, repeatflag) {

		// if we are inside a repeat we create later
		if($(element).parents('.xrx-repeat').length > 0) return;
		if($(element).parents('.xrx-select').length > 0) return;
		

		switch(controlType) {
		case CONTROL_VISUALXML:
			$(element).xrxVisualxml({ repeatflag: repeatflag });
			break;
		case CONTROL_REPORT:
			$(element).xrxReport({
				serviceUrlValidateInstance: opts.serviceUrlValidateInstance
			});
			break;
		/*:
		case CONTROL_REPEAT:
			$(element).xrxRepeat();
			break;
		*/
		case CONTROL_SELECT1:
			$(element).xrxSelect1();
			break;
		default:
			break;
		}
	}
	
	function createUi(element, uiType, opts) {

		switch(uiType) {
		case UI_LAYOUT:
			$(element).xrxLayout();
			break;
		case UI_TABS:
			$(element).xrxTabs();
			break;
		default:
			break;
		}		
	}
	
	$.fn.xrx.defaults = {
		charElementStart: "»",
		charElementEnd: "«"
	};

})(jQuery);