/**
 * @fileoverview A class implementing the text node
 * type for streaming XPath evaluation.
 */

goog.provide('xrx.node.TextS');


goog.require('xrx.node.Text');
goog.require('xrx.nodeS');


xrx.node.TextS = function(token, parent, instance) {
  goog.base(this, token, parent, instance);
};
goog.inherits(xrx.node.TextS, xrx.node.Text);



xrx.nodeS.sharedFunctions(xrx.node.TextS);


xrx.node.TextS.prototype.getNodeAncestor = xrx.nodeS.prototype.getNodeAncestor;
xrx.node.TextS.prototype.getNodePreceding = xrx.nodeS.prototype.getNodePreceding;
xrx.node.TextS.prototype.getNodePrecedingSibling = xrx.nodeS.prototype.getNodePrecedingSibling;



/** 
 * @overwrite
 */
xrx.node.TextS.prototype.getNodeFollowingSibling = function(test) {

  return this.parent_.find(test, xrx.label.prototype.isPrecedingSiblingOf);
};



/** 
 * @overwrite
 */
xrx.node.TextS.prototype.getNodeFollowing = function(test) {

  return this.parent_.find(test, xrx.label.prototype.isBefore);
};



/**
 * @override
 */
xrx.node.TextS.prototype.getNodeParent = function(test) {
  var nodeset = new xrx.xpath.NodeSet();
  if (test.matches(this.parent_)) nodeset.add(this.parent_); 

  return nodeset;
};