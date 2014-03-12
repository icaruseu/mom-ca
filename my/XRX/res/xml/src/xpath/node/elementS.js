/**
 * @fileoverview A class implementing the element node
 * type for streaming XPath evaluation.
 */

goog.provide('xrx.node.ElementS');


goog.require('xrx.node.Element');
goog.require('xrx.nodeS');


xrx.node.ElementS = function(token, instance) {
  goog.base(this, token, instance);
};
goog.inherits(xrx.node.ElementS, xrx.node.Element);



xrx.nodeS.sharedFunctions(xrx.node.ElementS);



xrx.node.ElementS.prototype.getNodeAncestor = xrx.nodeS.prototype.getNodeAncestor;
xrx.node.ElementS.prototype.getNodeAttribute = xrx.nodeS.prototype.getNodeAttribute;
xrx.node.ElementS.prototype.getNodeChild = xrx.nodeS.prototype.getNodeChild;
xrx.node.ElementS.prototype.getNodeDescendant = xrx.nodeS.prototype.getNodeDescendant;
xrx.node.ElementS.prototype.getNodeFollowing = xrx.nodeS.prototype.getNodeFollowing;
xrx.node.ElementS.prototype.getNodeFollowingSibling = xrx.nodeS.prototype.getNodeFollowingSibling;
xrx.node.ElementS.prototype.getNodeParent = xrx.nodeS.prototype.getNodeParent;
xrx.node.ElementS.prototype.getNodePreceding = xrx.nodeS.prototype.getNodePreceding;
xrx.node.ElementS.prototype.getNodePrecedingSibling = xrx.nodeS.prototype.getNodePrecedingSibling;