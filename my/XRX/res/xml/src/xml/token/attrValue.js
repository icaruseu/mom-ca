/**
 * @fileoverview Class represents the attribute-value token.
 */

goog.provide('xrx.token.AttrValue');



goog.require('xrx.token');
goog.require('xrx.token.Attribute');



/**
 * Constructs a new attribute-value token.
 * @constructor
 * @extends xrx.token
 */
xrx.token.AttrValue = function(label, opt_offset, opt_length) {
  goog.base(this, xrx.token.ATTR_VALUE, label, opt_offset, opt_length);
};
goog.inherits(xrx.token.AttrValue, xrx.token);



/**
 * Returns the tag to which the attribute value belongs.
 * @return {!xrx.token.StartEmptyTag}
 */
xrx.token.AttrValue.prototype.tag = xrx.token.Attribute.prototype.tag;