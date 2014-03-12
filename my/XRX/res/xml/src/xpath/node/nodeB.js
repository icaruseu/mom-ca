/**
 * @fileoverview A node implementation for binary XPath 
 * evaluation.
 */

goog.provide('xrx.nodeB');


goog.require('xrx.node');



/**
 * @constructor
 */
xrx.nodeS = function(type, token, instance) {
  goog.base(this, type, token, instance);
};
goog.inherits(xrx.nodeB, xrx.node);