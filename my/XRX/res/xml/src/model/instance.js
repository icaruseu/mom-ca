/**
 * @fileoverview Class implements data instance component for 
 * the model-view-controller.
 */

goog.provide('xrx.instance');


goog.require('goog.dom');
goog.require('xrx.model');
goog.require('xrx.node');
goog.require('xrx.pilot');


/**
 * @constructor
 */
xrx.instance = function(element) {
  goog.base(this, element);



  this.xml_ = goog.dom.getRawTextContent(this.getElement());
  goog.dom.setTextContent(this.getElement(), '');
};
goog.inherits(xrx.instance, xrx.model);



/**
 * @override
 */
xrx.instance.prototype.recalculate = function() {};



/**
 * @return {!string} The XML document.
 */
xrx.instance.prototype.xml = function(xml) {
  if (xml) this.xml_ = xml;
  return this.xml_;
};



/**
 * @return {!xrx.node.Document} The XML document.
 */
xrx.instance.prototype.document = function(id) {
  var pilot = new xrx.pilot(this.xml());
  var node = new xrx.node.Document(pilot, this.getId());
  
  return node;
};

