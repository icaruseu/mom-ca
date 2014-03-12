/**
 * @fileoverview An abstract class representing the document node 
 * of the XDM interface.
 */

goog.provide('xrx.node.Document');



goog.require('xrx.node');
goog.require('xrx.token');
goog.require('xrx.xpath.NodeSet');



/** 
 * @constructor 
 */
xrx.node.Document = function(instance) {
  goog.base(this, xrx.node.DOCUMENT, new xrx.token.Root(), instance);
};
goog.inherits(xrx.node.Document, xrx.node);



/**
 * XDM Accessors
 */
xrx.node.Document.prototype.accAttributes = function() {
  return new xrx.xpath.NodeSet();
};
xrx.node.Document.prototype.accBaseUri = function() {};
xrx.node.Document.prototype.accChildren = xrx.node.prototype.getChildNodes;
xrx.node.Document.prototype.accDocumentUri = function() {};
xrx.node.Document.prototype.accIsId = function() {};
xrx.node.Document.prototype.accIsIdrefs = function() {};
xrx.node.Document.prototype.accNamespaceNodes = function() {};
xrx.node.Document.prototype.accNilled = function() {};
xrx.node.Document.prototype.accNodeKind = function() {};
xrx.node.Document.prototype.accNodeName = function() {};
xrx.node.Document.prototype.accParent = function() {};
xrx.node.Document.prototype.accStringValue = function() {};
xrx.node.Document.prototype.accTypeName = function() {};
xrx.node.Document.prototype.accTypedValue = function() {};
xrx.node.Document.prototype.accUnparsedEntityPublicId = function() {};
xrx.node.Document.prototype.accUnparsedEntitySystemId = function() {};



/**
 * Overwrite node functions which always evaluate to an empty node-set
 */
xrx.node.Document.prototype.getNodeAncestor = function() {
  return new xrx.xpath.NodeSet();
};
xrx.node.Document.prototype.getNodeAttribute = function() {
  return new xrx.xpath.NodeSet();
};
xrx.node.Document.prototype.getNodeFollowingSibling = function() {
  return new xrx.xpath.NodeSet();
};
xrx.node.Document.prototype.getNodeParent = function() {
  return new xrx.xpath.NodeSet();
};
xrx.node.Document.prototype.getNodePreceding = function() {
  return new xrx.xpath.NodeSet();
};
xrx.node.Document.prototype.getNodePrecedingSibling = function() {
  return new xrx.xpath.NodeSet();
};



/** 
 * @overwrite
 */
xrx.node.Document.prototype.xml = function() {
  return this.instance_.xml();
};