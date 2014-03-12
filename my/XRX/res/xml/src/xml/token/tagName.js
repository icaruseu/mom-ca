/**
 * @fileoverview Class represents the tag-name token.
 */

goog.provide('xrx.token.TagName');



goog.require('xrx.token');



/**
 * Constructs a new tag name token.
 * @constructor
 * @extends xrx.token
 */
xrx.token.TagName = function(label, opt_offset, opt_length) {
  goog.base(this, xrx.token.TAG_NAME, label, opt_offset, opt_length);
};
goog.inherits(xrx.token.TagName, xrx.token);