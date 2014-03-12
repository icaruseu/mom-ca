/**
 * @fileoverview A class representing operations on path expressions.
 */

goog.provide('xrx.xpath.PathExpr');


goog.require('goog.array');
goog.require('xrx.node');
goog.require('xrx.xpath.DataType');
goog.require('xrx.xpath.Expr');
goog.require('xrx.xpath.NodeSet');



/**
 * Constructor for PathExpr.
 *
 * @param {!xrx.xpath.Expr} filter A filter expression.
 * @param {!Array.<!xrx.xpath.Step>} steps The steps in the location path.
 * @extends {xrx.xpath.Expr}
 * @constructor
 */
xrx.xpath.PathExpr = function(filter, steps) {
  xrx.xpath.Expr.call(this, filter.getDataType());

  /**
   * @type {!xrx.xpath.Expr}
   * @private
   */
  this.filter_ = filter;

  /**
   * @type {!Array.<!xrx.xpath.Step>}
   * @private
   */
  this.steps_ = steps;

  this.setNeedContextPosition(filter.doesNeedContextPosition());
  this.setNeedContextNode(filter.doesNeedContextNode());
  if (this.steps_.length == 1) {
    var firstStep = this.steps_[0];
    if (!firstStep.doesIncludeDescendants() &&
        firstStep.getAxis() == xrx.xpath.Step.Axis.ATTRIBUTE) {
      var test = firstStep.getTest();
      if (test.getName() != '*') {
        this.setQuickAttr({
          name: test.getName(),
          valueExpr: null
        });
      }
    }
  }
};
goog.inherits(xrx.xpath.PathExpr, xrx.xpath.Expr);



/**
 * Constructor for RootHelperExpr.
 *
 * @extends {xrx.xpath.Expr}
 * @constructor
 */
xrx.xpath.PathExpr.RootHelperExpr = function() {
  xrx.xpath.Expr.call(this, xrx.xpath.DataType.NODESET);
};
goog.inherits(xrx.xpath.PathExpr.RootHelperExpr, xrx.xpath.Expr);


/**
 * Evaluates the root-node helper expression.
 *
 * @param {!xrx.xpath.Context} ctx The context to evaluate the expression in.
 * @return {!xrx.xpath.NodeSet} The evaluation result.
 */
xrx.xpath.PathExpr.RootHelperExpr.prototype.evaluate = function(ctx) {
  var nodeset = new xrx.xpath.NodeSet();
  var node = ctx.getNode();
  if (node.type() === xrx.node.DOCUMENT) {
    nodeset.add(node);
  } else {
    nodeset.add(/** @type {!Node} */ (node.ownerDocument));
  }
  return nodeset;
};


/**
 * @override
 */
xrx.xpath.PathExpr.RootHelperExpr.prototype.toString = function() {
  return 'Root Helper Expression';
};



/**
 * Constructor for ContextHelperExpr.
 *
 * @extends {xrx.xpath.Expr}
 * @constructor
 */
xrx.xpath.PathExpr.ContextHelperExpr = function() {
  xrx.xpath.Expr.call(this, xrx.xpath.DataType.NODESET);
};
goog.inherits(xrx.xpath.PathExpr.ContextHelperExpr, xrx.xpath.Expr);


/**
 * Evaluates the context-node helper expression.
 *
 * @param {!xrx.xpath.Context} ctx The context to evaluate the expression in.
 * @return {!xrx.xpath.NodeSet} The evaluation result.
 */
xrx.xpath.PathExpr.ContextHelperExpr.prototype.evaluate = function(ctx) {
  var nodeset = new xrx.xpath.NodeSet();
  nodeset.add(ctx.getNode());
  return nodeset;
};


/**
 * @override
 */
xrx.xpath.PathExpr.ContextHelperExpr.prototype.toString = function() {
  return 'Context Helper Expression';
};


/**
 * Returns whether the token is a valid PathExpr operator.
 *
 * @param {string} token The token to be checked.
 * @return {boolean} Whether the token is a valid operator.
 */
xrx.xpath.PathExpr.isValidOp = function(token) {
  return token == '/' || token == '//';
};


/**
 * @override
 * @return {!xrx.xpath.NodeSet} The nodeset result.
 */
xrx.xpath.PathExpr.prototype.evaluate = function(ctx) {
  var nodeset = this.filter_.evaluate(ctx);
  if (!(nodeset instanceof xrx.xpath.NodeSet)) {
    throw Error('Filter expression must evaluate to nodeset.');
  }
  var steps = this.steps_;
  for (var i = 0, l0 = steps.length; i < l0 && nodeset.getLength(); i++) {
    var step = steps[i];
    var reverse = step.getAxis().isReverse();
    var iter = nodeset.iterator(reverse);
    nodeset = null;
    var node, next;
    if (!step.doesNeedContextPosition() &&
        step.getAxis() == xrx.xpath.Step.Axis.FOLLOWING) {
      for (node = iter.next(); next = iter.next(); node = next) {
        if (node.contains && !node.contains(next)) {
          break;
        } else {
          if (!(next.compareDocumentPosition(/** @type {!Node} */ (node)) &
              8)) {
            break;
          }
        }
      }
      nodeset = step.evaluate(new
          xrx.xpath.Context(/** @type {xrx.node} */ (node)));
    } else if (!step.doesNeedContextPosition() &&
        step.getAxis() == xrx.xpath.Step.Axis.PRECEDING) {
      node = iter.next();
      nodeset = step.evaluate(new
          xrx.xpath.Context(/** @type {xrx.node} */ (node)));
    } else {
      node = iter.next();
      nodeset = step.evaluate(new
          xrx.xpath.Context(/** @type {xrx.node} */ (node)));
      while ((node = iter.next()) != null) {
        var result = step.evaluate(new
            xrx.xpath.Context(/** @type {xrx.node} */ (node)));
        nodeset = xrx.xpath.NodeSet.merge(nodeset, result);
      }
    }
  }
  return /** @type {!xrx.xpath.NodeSet} */ (nodeset);
};


/**
 * @override
 */
xrx.xpath.PathExpr.prototype.toString = function() {
  var text = 'Path Expression:';
  text += xrx.xpath.Expr.indent(this.filter_);
  if (this.steps_.length) {
    var steps = goog.array.reduce(this.steps_, function(prev, curr) {
      return prev + xrx.xpath.Expr.indent(curr);
    }, 'Steps:');
    text += xrx.xpath.Expr.indent(steps);
  }
  return text;
};
