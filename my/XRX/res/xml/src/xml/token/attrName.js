/**
 * @fileoverview Class represents the attribute-name token.
 */

goog.provide('xrx.token.AttrName');



goog.require('xrx.token');
goog.require('xrx.token.Attribute');



/**
 * Constructs a new attribute-name token.
 * @constructor
 * @extends xrx.token
 */
xrx.token.AttrName = function(label, opt_offset, opt_length) {
  goog.base(this, xrx.token.ATTR_NAME, label, opt_offset, opt_length);
};
goog.inherits(xrx.token.AttrName, xrx.token);



/**
 * Returns the tag to which the attribute-name belongs.
 * @return {!xrx.token.StartEmptyTag}
 */
xrx.token.AttrName.prototype.tag = xrx.token.Attribute.prototype.tag;