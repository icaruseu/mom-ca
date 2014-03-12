/**
 * @fileoverview An abstract class which allows
 * custom functions for the XPath processor.
 */

goog.provide('xrx.xpath.Function');



/**
 * A function in a function call expression.
 *
 * @constructor
 * @param {string} name Name of the function.
 * @param {xrx.xpath.DataType} dataType Datatype of the function return value.
 * @param {boolean} needContextPosition Whether the function needs a context
 *     position.
 * @param {boolean} needContextNodeWithoutArgs Whether the function needs a
 *     context node when not given arguments.
 * @param {boolean} needContextNodeWithArgs Whether the function needs a context
 *     node when the function is given arguments.
 * @param {function(!xrx.xpath.Context, ...[!xrx.xpath.Expr]):*} evaluate
 *     Evaluates the function in a context with any number of expression
 *     arguments.
 * @param {number} minArgs Minimum number of arguments accepted by the function.
 * @param {?number=} opt_maxArgs Maximum number of arguments accepted by the
 *     function; null means there is no max; defaults to minArgs.
 * @param {boolean=} opt_nodesetsRequired Whether the args must be nodesets.
 * @private
 */
xrx.xpath.Function = function(name, returnType, needContextPosition,
    needContextNodeWithoutArgs, needContextNodeWithArgs, evaluate, minArgs,
    opt_maxArgs, opt_nodesetsRequired) {

  /**
   * @type {string}
   * @private
   */
  this.name = name;

  /**
   * @type {xrx.xpath.DataType}
   * @private
   */
  this.returnType = returnType;

  /**
   * @type {boolean}
   * @private
   */
  this.needContextPosition_ = needContextPosition;

  /**
   * @type {boolean}
   * @private
   */
  this.needContextNodeWithoutArgs_ = needContextNodeWithoutArgs;

  /**
   * @type {boolean}
   * @private
   */
  this.needContextNodeWithArgs_ = needContextNodeWithArgs;

  /**
   * @type {function(!xrx.xpath.Context, ...[!xrx.xpath.Expr]):*}
   * @private
   */
  this.evaluate = evaluate;

  /**
   * @type {number}
   * @private
   */
  this.minArgs = minArgs;

  /**
   * @type {?number}
   * @private
   */
  this.maxArgs = goog.isDef(opt_maxArgs) ? opt_maxArgs : minArgs;

  /**
   * @type {boolean}
   * @private
   */
  this.nodesetsRequired_ = !!opt_nodesetsRequired;
};



xrx.xpath.Function.prototype.toString = function() {
  return this.name_;
};