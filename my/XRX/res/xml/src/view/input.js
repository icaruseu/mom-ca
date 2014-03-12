/**
 * @fileoverview A class which implements a single-line 
 * input control.
 */

goog.provide('xrx.input');


goog.require('goog.dom');
goog.require('xrx.codemirror');
goog.require('xrx.controller');
goog.require('xrx.view');



/**
 * @constructor
 */
xrx.input = function(element) {



  /**
   * call constructor of class xrx.codemirror
   * @param {!xrx.input}
   * @param {Element}
   */
  goog.base(this, element);
};
goog.inherits(xrx.input, xrx.codemirror);




xrx.input.prototype.options = {
  'extraKeys': { Enter: function(cm) {} },
  'fixedGutter': false
};
