/**
 * @fileoverview Class represents the empty tag token.
 */

goog.provide('xrx.token.EmptyTag');



goog.require('xrx.token');


/**
 * Constructs a new empty tag token.
 * @constructor
 * @extends xrx.token
 */
xrx.token.EmptyTag = function(label, opt_offset, opt_length) {
  goog.base(this, xrx.token.EMPTY_TAG, label, opt_offset, opt_length);
};
goog.inherits(xrx.token.EmptyTag, xrx.token);



/**
 * Compares the generic type of two tokens.
 *
 * @param {!number} type The type to check against.
 * @return {!boolean}
 */
xrx.token.EmptyTag.prototype.typeOf = function(type) {
  return this.type_ === type || xrx.token.START_EMPTY_TAG === type || 
      xrx.token.TAG === type;
};