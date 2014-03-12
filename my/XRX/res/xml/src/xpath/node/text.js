/**
 * @fileoverview A class representing the text node of the
 * XDM interface.
 */

goog.provide('xrx.node.Text');



goog.require('xrx.node');
goog.require('xrx.token');
goog.require('xrx.xpath.NodeSet');



/** 
 * @constructor 
 */
xrx.node.Text = function(token, parent, instance) {
  goog.base(this, xrx.node.TEXT, token, instance);
  this.parent_ = parent;
};
goog.inherits(xrx.node.Text, xrx.node);



xrx.node.Text.prototype.accAttributes = function() {
  return new xrx.xpath.NodeSet();
};
xrx.node.Text.prototype.accBaseUri = function() {};
xrx.node.Text.prototype.accChildren = function() {};
xrx.node.Text.prototype.accDocumentUri = function() {};
xrx.node.Text.prototype.accIsId = function() {};
xrx.node.Text.prototype.accIsIdrefs = function() {};
xrx.node.Text.prototype.accNamespaceNodes = function() {};
xrx.node.Text.prototype.accNilled = function() {};
xrx.node.Text.prototype.accNodeKind = function() {};
xrx.node.Text.prototype.accNodeName = function() {};
xrx.node.Text.prototype.accParent = function() {};
xrx.node.Text.prototype.accStringValue = function() {};
xrx.node.Text.prototype.accTypeName = function() {};
xrx.node.Text.prototype.accTypedValue = function() {};
xrx.node.Text.prototype.accUnparsedEntityPublicId = function() {};
xrx.node.Text.prototype.accUnparsedEntitySystemId = function() {};



/** 
 * Overwrite node functions which always evaluate to an empty node-set
 */
xrx.node.Text.prototype.getNodeAttribute = function() {
  return new xrx.xpath.NodeSet();
};
xrx.node.Text.prototype.getNodeChild = function() {
  return new xrx.xpath.NodeSet();
};
xrx.node.Text.prototype.getNodeDescendant = function() {
  return new xrx.xpath.NodeSet();
};
xrx.node.Text.prototype.getNodeAttribute = function() {
  return new xrx.xpath.NodeSet();
};



/** 
 * @overwrite
 */
xrx.node.Text.prototype.xml = function() {
  return this.stringValue();
};



/** 
 * @overwrite
 */
xrx.node.Text.prototype.stringValue = function() {
  return this.pilot_.xml(this.token_);
};