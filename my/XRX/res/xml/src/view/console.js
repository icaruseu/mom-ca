/**
 * @fileoverview Class implements a XML console to pretty
 * print XML instances in the browser.
 */

goog.provide('xrx.console');


goog.require('goog.dom');
goog.require('xrx.serialize');
goog.require('xrx.view');



/**
 * @constructor
 */
xrx.console = function(element) {



  goog.base(this, element);
};
goog.inherits(xrx.console, xrx.view);



xrx.console.prototype.createDom = function() {};



xrx.console.prototype.eventBeforeChange = function() {};



xrx.console.prototype.eventFocus = function() {};



xrx.console.prototype.getValue = function() {};



xrx.console.prototype.setFocus = function() {};


xrx.console.prototype.setValue = function(xml) {

  goog.dom.setTextContent(this.getElement(), xrx.serialize.indent(xml, 2));
};


xrx.console.prototype.refresh = function() {
  var xml = this.getNode().xml();

  this.setValue(xml);
};
