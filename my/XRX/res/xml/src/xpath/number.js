/**
 * @fileoverview A class representing number literals.
 */

goog.provide('xrx.xpath.Number');

goog.require('xrx.xpath.Expr');



/**
 * Constructs a number expression.
 *
 * @param {number} value The number value.
 * @constructor
 * @extends {xrx.xpath.Expr}
 */
xrx.xpath.Number = function(value) {
  xrx.xpath.Expr.call(this, xrx.xpath.DataType.NUMBER);

  /**
   * @type {number}
   * @private
   */
  this.value_ = value;
};
goog.inherits(xrx.xpath.Number, xrx.xpath.Expr);


/**
 * @override
 * @return {number} The number result.
 */
xrx.xpath.Number.prototype.evaluate = function(ctx) {
  return this.value_;
};


/**
 * @override
 */
xrx.xpath.Number.prototype.toString = function() {
  return 'Number: ' + this.value_;
};
