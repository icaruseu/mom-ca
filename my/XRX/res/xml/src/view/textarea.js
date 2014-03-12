/**
 * @fileoverview A class which implements a multi-line 
 * text control.
 */

goog.provide('xrx.textarea');



/**
 * @constructor
 */
xrx.textarea = function(element) {



  /**
   * call constructor of class xrx.codemirror
   * @param {!xrx.textarea}
   * @param {Element}
   */
  goog.base(this, element);
};
goog.inherits(xrx.textarea, xrx.codemirror);




xrx.textarea.prototype.options = {
  'lineWrapping': true
};

