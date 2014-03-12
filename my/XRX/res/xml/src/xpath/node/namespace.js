/**
 * @fileoverview A class representing the namespace node of the
 * XDM interface.
 */

goog.provide('xrx.node.Namespace');



goog.require('xrx.node');
goog.require('xrx.token');
goog.require('xrx.xpath.NodeSet');



xrx.node.Namespace = function() {};



xrx.node.Namespace.prototype.accAttributes = function() {
  return new xrx.xpath.NodeSet();
};
xrx.node.Namespace.prototype.accBaseUri = function() {};
xrx.node.Namespace.prototype.accChildren = function() {};
xrx.node.Namespace.prototype.accDocumentUri = function() {};
xrx.node.Namespace.prototype.accIsId = function() {};
xrx.node.Namespace.prototype.accIsIdrefs = function() {};
xrx.node.Namespace.prototype.accNamespaceNodes = function() {};
xrx.node.Namespace.prototype.accNilled = function() {};
xrx.node.Namespace.prototype.accNodeKind = function() {};
xrx.node.Namespace.prototype.accNodeName = function() {};
xrx.node.Namespace.prototype.accParent = function() {};
xrx.node.Namespace.prototype.accStringValue = function() {};
xrx.node.Namespace.prototype.accTypeName = function() {};
xrx.node.Namespace.prototype.accTypedValue = function() {};
xrx.node.Namespace.prototype.accUnparsedEntityPublicId = function() {};
xrx.node.Namespace.prototype.accUnparsedEntitySystemId = function() {};