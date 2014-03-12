/**
 * @fileoverview A class implementing the document node
 * type for streaming XPath evaluation.
 */

goog.provide('xrx.node.DocumentS');


goog.require('xrx.node.Document');
goog.require('xrx.nodeS');


xrx.node.DocumentS = function(instance) {
  goog.base(this, instance);
};
goog.inherits(xrx.node.DocumentS, xrx.node.Document);



xrx.nodeS.sharedFunctions(xrx.node.DocumentS);


xrx.node.DocumentS.prototype.getNodeChild = xrx.nodeS.prototype.getNodeChild;
xrx.node.DocumentS.prototype.getNodeDescendant = xrx.nodeS.prototype.getNodeDescendant;
xrx.node.DocumentS.prototype.getNodeFollowing = xrx.nodeS.prototype.getNodeFollowing;