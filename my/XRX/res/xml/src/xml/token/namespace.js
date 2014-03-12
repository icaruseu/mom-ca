/**
 * @fileoverview Class represents the namespace token.
 */

goog.provide('xrx.token.Namespace');



goog.require('xrx.token');



/**
 * Constructs a new namespace token.
 * @constructor
 * @extends xrx.token
 */
xrx.token.Namespace = function(label, opt_offset, opt_length) {
  goog.base(this, xrx.token.NAMESPACE, label, opt_offset, opt_length);  
};
goog.inherits(xrx.token.Namespace, xrx.token);
