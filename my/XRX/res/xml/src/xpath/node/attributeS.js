/**
 * @fileoverview A class implementing the attribute node
 * type for streaming XPath evaluation.
 */

goog.provide('xrx.node.AttributeS');


goog.require('xrx.node.Attribute');
goog.require('xrx.nodeS');


xrx.node.AttributeS = function(token, parent, instance) {
  goog.base(this, token, parent, instance);
};
goog.inherits(xrx.node.AttributeS, xrx.node.Attribute);



xrx.nodeS.sharedFunctions(xrx.node.AttributeS);


xrx.node.AttributeS.prototype.getNodeAncestor = xrx.nodeS.prototype.getNodeAncestor;



/**
 * @override
 */
xrx.node.AttributeS.prototype.getNodeParent = function(test) {
  var nodeset = new xrx.xpath.NodeSet();
  if (test.matches(this.parent_)) nodeset.add(this.parent_); 

  return nodeset;
};