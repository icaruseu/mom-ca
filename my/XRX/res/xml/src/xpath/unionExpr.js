/**
 * @fileoverview A class representing operations on union expressions.
 */

goog.provide('xrx.xpath.UnionExpr');

goog.require('goog.array');
goog.require('xrx.xpath.DataType');
goog.require('xrx.xpath.Expr');



/**
 * Constructor for UnionExpr.
 *
 * @param {!Array.<!xrx.xpath.Expr>} paths The paths in the union.
 * @extends {xrx.xpath.Expr}
 * @constructor
 */
xrx.xpath.UnionExpr = function(paths) {
  xrx.xpath.Expr.call(this, xrx.xpath.DataType.NODESET);

  /**
   * @type {!Array.<!xrx.xpath.Expr>}
   * @private
   */
  this.paths_ = paths;
  this.setNeedContextPosition(goog.array.some(this.paths_, function(p) {
    return p.doesNeedContextPosition();
  }));
  this.setNeedContextNode(goog.array.some(this.paths_, function(p) {
    return p.doesNeedContextNode();
  }));
};
goog.inherits(xrx.xpath.UnionExpr, xrx.xpath.Expr);


/**
 * @override
 * @return {!xrx.xpath.NodeSet} The nodeset result.
 */
xrx.xpath.UnionExpr.prototype.evaluate = function(ctx) {
  var nodeset = new xrx.xpath.NodeSet();
  goog.array.forEach(this.paths_, function(p) {
    var result = p.evaluate(ctx);
    if (!(result instanceof xrx.xpath.NodeSet)) {
      throw Error('Path expression must evaluate to NodeSet.');
    }
    nodeset = xrx.xpath.NodeSet.merge(nodeset, result);
  });
  return nodeset;
};


/**
 * @override
 */
xrx.xpath.UnionExpr.prototype.toString = function() {
  return goog.array.reduce(this.paths_, function(prev, curr) {
    return prev + xrx.xpath.Expr.indent(curr);
  }, 'Union Expression:');
};
