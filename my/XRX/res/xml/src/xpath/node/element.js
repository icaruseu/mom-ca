/**
 * @fileoverview A class representing the element node of the
 * XDM interface.
 */

goog.provide('xrx.node.Element');



goog.require('xrx.node');
goog.require('xrx.node.Attribute');
goog.require('xrx.pilot');
goog.require('xrx.stream');
goog.require('xrx.token');
goog.require('xrx.xpath.NodeSet');



/** 
 * @constructor
 */
xrx.node.Element = function(token, instance) {
  goog.base(this, xrx.node.ELEMENT, token, instance);
};
goog.inherits(xrx.node.Element, xrx.node);



xrx.node.Element.prototype.accAttributes = function(test) {
  this.getNodeAttribute(test);
};
xrx.node.Element.prototype.accBaseUri = function() {};
xrx.node.Element.prototype.accChildren = function() {};
xrx.node.Element.prototype.accDocumentUri = function() {};
xrx.node.Element.prototype.accIsId = function() {};
xrx.node.Element.prototype.accIsIdrefs = function() {};
xrx.node.Element.prototype.accNamespaceNodes = function() {};
xrx.node.Element.prototype.accNilled = function() {};
xrx.node.Element.prototype.accNodeKind = function() {};
xrx.node.Element.prototype.accNodeName = function() {};
xrx.node.Element.prototype.accParent = function() {};
xrx.node.Element.prototype.accStringValue = function() {};
xrx.node.Element.prototype.accTypeName = function() {};
xrx.node.Element.prototype.accTypedValue = function() {};
xrx.node.Element.prototype.accUnparsedEntityPublicId = function() {};
xrx.node.Element.prototype.accUnparsedEntitySystemId = function() {};



/**
 * @override
 */
xrx.node.Element.prototype.expandedName = function() {
  var pilot = new xrx.pilot(this.instance_.xml());
  return '' + pilot.xml(pilot.tagName(this.token_, this.token_));
};



/**
 * @override
 */
xrx.node.Element.prototype.namespaceUri = function() {
  return undefined;
};
