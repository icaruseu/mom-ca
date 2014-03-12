/**
 * @fileoverview Class represents the attribute token.
 */

goog.provide('xrx.token.Attribute');



goog.require('xrx.token');



/**
 * Constructs a new attribute token.
 * @constructor
 * @extends xrx.token
 */
xrx.token.Attribute = function(label, opt_offset, opt_length) {
  goog.base(this, xrx.token.ATTRIBUTE, label, opt_offset, opt_length);
};
goog.inherits(xrx.token.Attribute, xrx.token);



/**
 * Returns the tag to which the attribute belongs.
 * @return {!xrx.token.StartEmptyTag}
 */
xrx.token.Attribute.prototype.tag = function() {
  var label = this.label().clone();
  label.parent();

  return new xrx.token.StartEmptyTag(label);
};