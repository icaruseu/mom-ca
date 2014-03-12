/**
 * @fileoverview Class represents a generic token called
 * start-empty-tag.
 */

goog.provide('xrx.token.StartEmptyTag');



goog.require('xrx.token');



/**
 * Constructs a new start-empty-tag token. xrx.token.StartEmptyTag
 * is a generic token which stands for either the start-tag or the
 * empty-tag token. This is especially useful to evaluate Path
 * expressions which do not distinguish between start and empty tags.
 * 
 * @constructor
 * @extends xrx.token
 */
xrx.token.StartEmptyTag = function(label, opt_offset, opt_length) {
  goog.base(this, xrx.token.START_EMPTY_TAG, label, opt_offset, opt_length);
};
goog.inherits(xrx.token.StartEmptyTag, xrx.token);



/**
 * Compares the generic type of two tokens.
 *
 * @param {!number} type The type to check against.
 * @return {!boolean}
 */
xrx.token.StartEmptyTag.prototype.typeOf = function(type) {
  return this.type_ === type || xrx.token.START_TAG === type || 
      xrx.token.EMPTY_TAG === type || xrx.token.TAG === type;
};