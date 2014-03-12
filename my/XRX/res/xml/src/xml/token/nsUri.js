/**
 * @fileoverview Class represents the namespace URI token.
 */

goog.provide('xrx.token.NsUri');



goog.require('xrx.token');



/**
 * Constructs a new namespace URI token.
 * @constructor
 * @extends xrx.token
 */
xrx.token.NsUri = function(label, opt_offset, opt_length) {
  goog.base(this, xrx.token.NS_URI, label, opt_offset, opt_length);
};
goog.inherits(xrx.token.NsUri, xrx.token);