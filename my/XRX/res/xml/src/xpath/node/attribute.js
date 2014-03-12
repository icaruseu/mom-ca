/**
 * @fileoverview A class representing the attribute node of the
 * XDM interface.
 */

goog.provide('xrx.node.Attribute');



goog.require('xrx.node');
goog.require('xrx.stream');
goog.require('xrx.token');
goog.require('xrx.xpath.NodeSet');



/** 
 * @constructor 
 */
xrx.node.Attribute = function(token, parent, instance) {
  goog.base(this, xrx.node.ATTRIBUTE, token, instance);
  this.parent_ = parent;
};
goog.inherits(xrx.node.Attribute, xrx.node);



xrx.node.Attribute.prototype.accAttributes = function() {
  return new xrx.xpath.NodeSet();
};
xrx.node.Attribute.prototype.accBaseUri = function() {};
xrx.node.Attribute.prototype.accChildren = function() {};
xrx.node.Attribute.prototype.accDocumentUri = function() {};
xrx.node.Attribute.prototype.accIsId = function() {};
xrx.node.Attribute.prototype.accIsIdrefs = function() {};
xrx.node.Attribute.prototype.accNamespaceNodes = function() {};
xrx.node.Attribute.prototype.accNilled = function() {};
xrx.node.Attribute.prototype.accNodeKind = function() {};
xrx.node.Attribute.prototype.accNodeName = function() {};
xrx.node.Attribute.prototype.accParent = function() {};
xrx.node.Attribute.prototype.accStringValue = function() {};
xrx.node.Attribute.prototype.accTypeName = function() {};
xrx.node.Attribute.prototype.accTypedValue = function() {};
xrx.node.Attribute.prototype.accUnparsedEntityPublicId = function() {};
xrx.node.Attribute.prototype.accUnparsedEntitySystemId = function() {};



/**
 * Override node functions which always evaluate to an empty node-set
 */
xrx.node.Attribute.prototype.getNodeAttribute = function() {
  return new xrx.xpath.NodeSet();
};
xrx.node.Attribute.prototype.getNodeChild = function() {
  return new xrx.xpath.NodeSet();
};
xrx.node.Attribute.prototype.getNodeDescendant = function() {
  return new xrx.xpath.NodeSet();
};
xrx.node.Attribute.prototype.getNodeFollowing = function() {
  return new xrx.xpath.NodeSet();
};
xrx.node.Attribute.prototype.getNodeFollowingSibling = function() {
  return new xrx.xpath.NodeSet();
};
xrx.node.Attribute.prototype.getNodePreceding = function() {
  return new xrx.xpath.NodeSet();
};
xrx.node.Attribute.prototype.getNodePrecedingSibling = function() {
  return new xrx.xpath.NodeSet();
};



/**
 * @override
 */
xrx.node.Attribute.prototype.expandedName = function() {
  var stream = new xrx.stream(this.instance_.xml());
  var attrName = new xrx.token.AttrName(this.label().clone());
  var parentXml = this.parent_.token().xml(this.instance_.xml());
  var location = stream.attrName(parentXml, 
      attrName.label().last(), this.offset());
  
  return '' + location.xml(parentXml);
};



/**
 * @override
 */
xrx.node.Attribute.prototype.stringValue = function() {
  var stream = new xrx.stream(this.instance_.xml());
  var attrValue = new xrx.token.AttrValue(this.label().clone());
  var parentXml = this.parent_.token().xml(this.instance_.xml());
  var location = stream.attrValue(parentXml, attrValue.label().last(), 
      this.offset());
  
  return location.xml(parentXml);
};



/**
 * @override
 */
xrx.node.Attribute.prototype.namespaceUri = function() {
  return undefined;
};