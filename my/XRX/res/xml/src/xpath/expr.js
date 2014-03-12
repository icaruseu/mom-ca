/**
 * @fileoverview An abstract class representing basic expressions.
 */

goog.provide('xrx.xpath.Expr');

goog.require('xrx.xpath.NodeSet');



/**
 * Abstract constructor for an XPath expression.
 *
 * @param {!xrx.xpath.DataType} dataType The data type that the expression
 *                                    will be evaluated into.
 * @constructor
 */
xrx.xpath.Expr = function(dataType) {

  /**
   * @type {!xrx.xpath.DataType}
   * @private
   */
  this.dataType_ = dataType;

  /**
   * @type {boolean}
   * @private
   */
  this.needContextPosition_ = false;

  /**
   * @type {boolean}
   * @private
   */
  this.needContextNode_ = false;

  /**
   * @type {?{name: string, valueExpr: xrx.xpath.Expr}}
   * @private
   */
  this.quickAttr_ = null;
};


/**
 * Indentation method for pretty printing.
 *
 * @param {*} obj The object to return a string representation for.
 * @return {string} The string prepended with newline and two spaces.
 */
xrx.xpath.Expr.indent = function(obj) {
  return '\n  ' + obj.toString().split('\n').join('\n  ');
};


/**
 * Evaluates the expression.
 *
 * @param {!xrx.xpath.Context} ctx The context to evaluate the expression in.
 * @return {!(string|boolean|number|xrx.xpath.NodeSet)} The evaluation result.
 */
xrx.xpath.Expr.prototype.evaluate = goog.abstractMethod;


/**
 * @override
 */
xrx.xpath.Expr.prototype.toString = goog.abstractMethod;


/**
 * Returns the data type of the expression.
 *
 * @return {!xrx.xpath.DataType} The data type that the expression
 *                            will be evaluated into.
 */
xrx.xpath.Expr.prototype.getDataType = function() {
  return this.dataType_;
};


/**
 * Returns whether the expression needs context position to be evaluated.
 *
 * @return {boolean} Whether context position is needed.
 */
xrx.xpath.Expr.prototype.doesNeedContextPosition = function() {
  return this.needContextPosition_;
};


/**
 * Sets whether the expression needs context position to be evaluated.
 *
 * @param {boolean} flag Whether context position is needed.
 */
xrx.xpath.Expr.prototype.setNeedContextPosition = function(flag) {
  this.needContextPosition_ = flag;
};


/**
 * Returns whether the expression needs context node to be evaluated.
 *
 * @return {boolean} Whether context node is needed.
 */
xrx.xpath.Expr.prototype.doesNeedContextNode = function() {
  return this.needContextNode_;
};


/**
 * Sets whether the expression needs context node to be evaluated.
 *
 * @param {boolean} flag Whether context node is needed.
 */
xrx.xpath.Expr.prototype.setNeedContextNode = function(flag) {
  this.needContextNode_ = flag;
};


/**
 * Returns the quick attribute information, if exists.
 *
 * @return {?{name: string, valueExpr: xrx.xpath.Expr}} The attribute
 *         information.
 */
xrx.xpath.Expr.prototype.getQuickAttr = function() {
  return this.quickAttr_;
};


/**
 * Sets up the quick attribute info.
 *
 * @param {?{name: string, valueExpr: xrx.xpath.Expr}} attrInfo The attribute
 *        information.
 */
xrx.xpath.Expr.prototype.setQuickAttr = function(attrInfo) {
  this.quickAttr_ = attrInfo;
};


/**
 * Evaluate and interpret the result as a number.
 *
 * @param {!xrx.xpath.Context} ctx The context to evaluate the expression in.
 * @return {number} The evaluated number value.
 */
xrx.xpath.Expr.prototype.asNumber = function(ctx) {
  var exrs = this.evaluate(ctx);
  if (exrs instanceof xrx.xpath.NodeSet) {
    return exrs.number();
  }
  return +exrs;
};


/**
 * Evaluate and interpret the result as a string.
 *
 * @param {!xrx.xpath.Context} ctx The context to evaluate the expression in.
 * @return {string} The evaluated string.
 */
xrx.xpath.Expr.prototype.asString = function(ctx) {
  var exrs = this.evaluate(ctx);
  if (exrs instanceof xrx.xpath.NodeSet) {
    return exrs.string();
  }
  return '' + exrs;
};


/**
 * Evaluate and interpret the result as a boolean value.
 *
 * @param {!xrx.xpath.Context} ctx The context to evaluate the expression in.
 * @return {boolean} The evaluated boolean value.
 */
xrx.xpath.Expr.prototype.asBool = function(ctx) {
  var exrs = this.evaluate(ctx);
  if (exrs instanceof xrx.xpath.NodeSet) {
    return !!exrs.getLength();
  }
  return !!exrs;
};
