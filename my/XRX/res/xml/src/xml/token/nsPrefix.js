/**
 * @fileoverview Class represents the namespace prefix token.
 */

goog.provide('xrx.token.NsPrefix');



goog.require('xrx.token');



/**
 * Constructs a new namespace prefix token.
 * @constructor
 * @extends xrx.token
 */
xrx.token.NsPrefix = function(label, opt_offset, opt_length) {
  goog.base(this, xrx.token.NS_PREFIX, label, opt_offset, opt_length);
};
goog.inherits(xrx.token.NsPrefix, xrx.token);