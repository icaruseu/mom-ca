/**
 * @fileoverview A class representing operations on unary expressions.
 */

goog.provide('xrx.xpath.UnaryExpr');

goog.require('xrx.xpath.DataType');
goog.require('xrx.xpath.Expr');



/**
 * Constructor for UnaryExpr.
 *
 * @param {!xrx.xpath.Expr} expr The unary expression.
 * @extends {xrx.xpath.Expr}
 * @constructor
 */
xrx.xpath.UnaryExpr = function(expr) {
  xrx.xpath.Expr.call(this, xrx.xpath.DataType.NUMBER);

  /**
   * @private
   * @type {!xrx.xpath.Expr}
   */
  this.expr_ = expr;

  this.setNeedContextPosition(expr.doesNeedContextPosition());
  this.setNeedContextNode(expr.doesNeedContextNode());
};
goog.inherits(xrx.xpath.UnaryExpr, xrx.xpath.Expr);


/**
 * @override
 * @return {number} The number result.
 */
xrx.xpath.UnaryExpr.prototype.evaluate = function(ctx) {
  return -this.expr_.asNumber(ctx);
};


/**
 * @override
 */
xrx.xpath.UnaryExpr.prototype.toString = function() {
  return 'Unary Expression: -' + xrx.xpath.Expr.indent(this.expr_);
};
