/**
 * @fileoverview An abstract class representing expressions with predicates.
 *     baseExprWithPredictes are immutable objects that evaluate their
 *     predicates against nodesets and return the modified nodesets.
 *
 */


goog.provide('xrx.xpath.Predicates');

goog.require('goog.array');
goog.require('xrx.xpath.Context');
goog.require('xrx.xpath.Expr');



/**
 * An abstract class for expressions with predicates.
 *
 * @constructor
 * @param {!Array.<!xrx.xpath.Expr>} predicates The array of predicates.
 * @param {boolean=} opt_reverse Whether to iterate over the nodeset in reverse.
 */
xrx.xpath.Predicates = function(predicates, opt_reverse) {

  /**
   * List of predicates
   *
   * @private
   * @type {!Array.<!xrx.xpath.Expr>}
   */
  this.predicates_ = predicates;


  /**
   * Which direction to iterate over the predicates
   *
   * @private
   * @type {boolean}
   */
  this.reverse_ = !!opt_reverse;
};


/**
 * Evaluates the predicates against the given nodeset.
 *
 * @param {!xrx.xpath.NodeSet} nodeset The nodes against which to evaluate
 *     the predicates.
 * @param {number=} opt_start The index of the first predicate to evaluate,
 *     defaults to 0.
 * @return {!xrx.xpath.NodeSet} nodeset The filtered nodeset.
 */
xrx.xpath.Predicates.prototype.evaluatePredicates =
    function(nodeset, opt_start) {
  for (var i = opt_start || 0; i < this.predicates_.length; i++) {
    var predicate = this.predicates_[i];
    var iter = nodeset.iterator();
    var l = nodeset.getLength();
    var node;
    for (var j = 0; node = iter.next(); j++) {
      var position = this.reverse_ ? (l - j) : (j + 1);
      var exrs = predicate.evaluate(new
          xrx.xpath.Context(/** @type {xrx.node} */ (node), position, l));
      var keep;
      if (typeof exrs == 'number') {
        keep = (position == exrs);
      } else if (typeof exrs == 'string' || typeof exrs == 'boolean') {
        keep = !!exrs;
      } else if (exrs instanceof xrx.xpath.NodeSet) {
        keep = (exrs.getLength() > 0);
      } else {
        throw Error('Predicate.evaluate returned an unexpected type.');
      }
      if (!keep) {
        iter.remove();
      }
    }
  }
  return nodeset;
};


/**
 * Returns the quickAttr info.
 *
 * @return {?{name: string, valueExpr: xrx.xpath.Expr}}
 */
xrx.xpath.Predicates.prototype.getQuickAttr = function() {
  return this.predicates_.length > 0 ?
      this.predicates_[0].getQuickAttr() : null;
};


/**
 * Returns whether this set of predicates needs context position.
 *
 * @return {boolean} Whether something needs context position.
 */
xrx.xpath.Predicates.prototype.doesNeedContextPosition = function() {
  for (var i = 0; i < this.predicates_.length; i++) {
    var predicate = this.predicates_[i];
    if (predicate.doesNeedContextPosition() ||
        predicate.getDataType() == xrx.xpath.DataType.NUMBER ||
        predicate.getDataType() == xrx.xpath.DataType.VOID) {
      return true;
    }
  }
  return false;
};


/**
 * Returns the length of this set of predicates.
 *
 * @return {number} The number of expressions.
 */
xrx.xpath.Predicates.prototype.getLength = function() {
  return this.predicates_.length;
};


/**
 * Returns the set of predicates.
 *
 * @return {!Array.<!xrx.xpath.Expr>} The predicates.
 */
xrx.xpath.Predicates.prototype.getPredicates = function() {
  return this.predicates_;
};


/**
 * @override
 */
xrx.xpath.Predicates.prototype.toString = function() {
  return goog.array.reduce(this.predicates_, function(prev, curr) {
    return prev + xrx.xpath.Expr.indent(curr);
  }, 'Predicates:');
};
