/**
 * @fileoverview Class represents a generic token for tags of
 * any kind.
 */

goog.provide('xrx.token.Tag');



goog.require('xrx.token');

/**
 * Constructs a new tag token. The tag token is a generic 
 * container token for all kinds of native tag tokens as 
 * well as all generic tag tokens.
 * 
 * @constructor
 * @extends xrx.token
 */
xrx.token.Tag = function(label) {
  goog.base(this, xrx.token.TAG, label);
};
goog.inherits(xrx.token.Tag, xrx.token);



/**
 * Compares the generic type of two tokens.
 *
 * @param {!number} type The type to check against.
 * @return {!boolean}
 */
xrx.token.Tag.prototype.typeOf = function(type) {
  return this.type_ === type || xrx.token.START_TAG === type
      || xrx.token.END_TAG === type || xrx.token.EMPTY_TAG === type || 
      xrx.token.START_EMPTY_TAG === type;
};