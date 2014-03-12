/**
 * @fileoverview Class represents the start-tag token.
 */

goog.provide('xrx.token.StartTag');



goog.require('xrx.token');



/**
 * Constructs a new start tag token.
 * @constructor
 * @extends xrx.token
 */
xrx.token.StartTag = function(label, opt_offset, opt_length) {
  goog.base(this, xrx.token.START_TAG, label, opt_offset, opt_length);
};
goog.inherits(xrx.token.StartTag, xrx.token);



/**
 * Compares the generic type of two tokens.
 *
 * @param {!number} type The type to check against.
 * @return {!boolean}
 */
xrx.token.StartTag.prototype.typeOf = function(type) {
  return this.type_ === type || xrx.token.START_EMPTY_TAG === type || 
      xrx.token.TAG === type;
};