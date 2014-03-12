/**
 * @fileoverview Class represents a generic token called not-tag.
 */

goog.provide('xrx.token.NotTag');



goog.require('xrx.token');



/**
 * Constructs a new not-tag token.
 * xrx.token.NotTag is a container token for all tokens which
 * are no tags and not part of a tag (attribute, namespace), 
 * i.e. text, comment, processing instruction.
 *  
 * @constructor
 * @extends xrx.token
 */
xrx.token.NotTag = function(label, opt_offset, opt_length) {
  goog.base(this, xrx.token.NOT_TAG, label, opt_offset, opt_length);
};
goog.inherits(xrx.token.NotTag, xrx.token);