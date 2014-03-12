/**
 * @fileoverview Class represents the end-tag token.
 */

goog.provide('xrx.token.EndTag');



goog.require('xrx.token');



/**
 * Constructs a new end tag token.
 * @constructor
 * @extends xrx.token
 */
xrx.token.EndTag = function(label, opt_offset, opt_length) {
  goog.base(this, xrx.token.END_TAG, label, opt_offset, opt_length);
};
goog.inherits(xrx.token.EndTag, xrx.token);



/**
 * Compares the generic type of two tokens.
 *
 * @param {!number} type The type to check against.
 * @return {!boolean}
 */
xrx.token.EndTag.prototype.typeOf = function(type) {
  return this.type_ === type || xrx.token.TAG === type;
};