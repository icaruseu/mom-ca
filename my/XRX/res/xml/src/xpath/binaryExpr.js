/**
 * @fileoverview A class representing operations on binary expressions.
 */

goog.provide('xrx.xpath.BinaryExpr');

goog.require('xrx.xpath.DataType');
goog.require('xrx.xpath.Expr');
goog.require('xrx.node');



xrx.xpath.BinaryExpr = function(op, left, right) {
  var opCast = /** @type {!xrx.xpath.BinaryExpr.Op_} */ (op);
  xrx.xpath.Expr.call(this, opCast.dataType_);

  /**
   * @private
   * @type {!xrx.xpath.BinaryExpr.Op_}
   */
  this.op_ = opCast;

  /**
   * @private
   * @type {!xrx.xpath.Expr}
   */
  this.left_ = left;

  /**
   * @private
   * @type {!xrx.xpath.Expr}
   */
  this.right_ = right;

  this.setNeedContextPosition(left.doesNeedContextPosition() ||
      right.doesNeedContextPosition());
  this.setNeedContextNode(left.doesNeedContextNode() ||
      right.doesNeedContextNode());

  // Optimize [@id="foo"] and [@name="bar"]
  if (this.op_ == xrx.xpath.BinaryExpr.Op.EQUAL) {
    if (!right.doesNeedContextNode() && !right.doesNeedContextPosition() &&
        right.getDataType() != xrx.xpath.DataType.NODESET &&
        right.getDataType() != xrx.xpath.DataType.VOID && left.getQuickAttr()) {
      this.setQuickAttr({
        name: left.getQuickAttr().name,
        valueExpr: right});
    } else if (!left.doesNeedContextNode() && !left.doesNeedContextPosition() &&
        left.getDataType() != xrx.xpath.DataType.NODESET &&
        left.getDataType() != xrx.xpath.DataType.VOID && right.getQuickAttr()) {
      this.setQuickAttr({
        name: right.getQuickAttr().name,
        valueExpr: left});
    }
  }
};
goog.inherits(xrx.xpath.BinaryExpr, xrx.xpath.Expr);


/**
 * Performs comparison between the left hand side and the right hand side.
 *
 * @private
 * @param {function((string|number|boolean), (string|number|boolean))}
 *        comp A comparison function that takes two parameters.
 * @param {!xrx.xpath.Expr} lhs The left hand side of the expression.
 * @param {!xrx.xpath.Expr} rhs The right hand side of the expression.
 * @param {!xrx.xpath.Context} ctx The context to perform the comparison in.
 * @param {boolean=} opt_equChk Whether the comparison checks for equality.
 * @return {boolean} True if comp returns true, false otherwise.
 */
xrx.xpath.BinaryExpr.compare_ = function(comp, lhs, rhs, ctx, opt_equChk) {
  var left = lhs.evaluate(ctx);
  var right = rhs.evaluate(ctx);
  var lIter, rIter, lNode, rNode;
  if (left instanceof xrx.xpath.NodeSet && right instanceof xrx.xpath.NodeSet) {
    lIter = left.iterator();
    for (lNode = lIter.next(); lNode; lNode = lIter.next()) {
      rIter = right.iterator();
      for (rNode = rIter.next(); rNode; rNode = rIter.next()) {
        if (comp(lNode.getValueAsString(),
            rNode.getValueAsString())) {
          return true;
        }
      }
    }
    return false;
  }
  if ((left instanceof xrx.xpath.NodeSet) ||
      (right instanceof xrx.xpath.NodeSet)) {
    var nodeset, primitive;
    if ((left instanceof xrx.xpath.NodeSet)) {
      nodeset = left, primitive = right;
    } else {
      nodeset = right, primitive = left;
    }
    var iter = nodeset.iterator();
    var type = typeof primitive;
    for (var node = iter.next(); node; node = iter.next()) {
      var stringValue;
      switch (type) {
        case 'number':
          stringValue = node.getValueAsNumber();
          break;
        case 'boolean':
          stringValue = node.getValueAsBool();
          break;
        case 'string':
          stringValue = node.getValueAsString();
          break;
        default:
          throw Error('Illegal primitive type for comparison.');
      }
      if (comp(stringValue,
          /** @type {(string|number|boolean)} */ (primitive))) {
        return true;
      }
    }
    return false;
  }
  if (opt_equChk) {
    if (typeof left == 'boolean' || typeof right == 'boolean') {
      return comp(!!left, !!right);
    }
    if (typeof left == 'number' || typeof right == 'number') {
      return comp(+left, +right);
    }
    return comp(left, right);
  }
  return comp(+left, +right);
};


/**
 * @override
 * @return {(boolean|number)} The boolean or number result.
 */
xrx.xpath.BinaryExpr.prototype.evaluate = function(ctx) {
  return this.op_.evaluate_(this.left_, this.right_, ctx);
};


/**
 * @override
 */
xrx.xpath.BinaryExpr.prototype.toString = function() {
  var text = 'Binary Expression: ' + this.op_;
  text += xrx.xpath.Expr.indent(this.left_);
  text += xrx.xpath.Expr.indent(this.right_);
  return text;
};



/**
 * A binary operator.
 *
 * @param {string} opString The operator string.
 * @param {number} precedence The precedence when evaluated.
 * @param {!xrx.xpath.DataType} dataType The dataType to return when evaluated.
 * @param {function(!xrx.xpath.Expr, !xrx.xpath.Expr, !xrx.xpath.Context)}
 *         evaluate An evaluation function.
 * @constructor
 * @private
 */
xrx.xpath.BinaryExpr.Op_ = function(opString, precedence, dataType, evaluate) {

  /**
   * @private
   * @type {string}
   */
  this.opString_ = opString;

  /**
   * @private
   * @type {number}
   */
  this.precedence_ = precedence;

  /**
   * @private
   * @type {!xrx.xpath.DataType}
   */
  this.dataType_ = dataType;

  /**
   * @private
   * @type {function(!xrx.xpath.Expr, !xrx.xpath.Expr, !xrx.xpath.Context)}
   */
  this.evaluate_ = evaluate;
};


/**
 * Returns the precedence for the operator.
 *
 * @return {number} The precedence.
 */
xrx.xpath.BinaryExpr.Op_.prototype.getPrecedence = function() {
  return this.precedence_;
};


/**
 * @override
 */
xrx.xpath.BinaryExpr.Op_.prototype.toString = function() {
  return this.opString_;
};


/**
 * A mapping from operator strings to operator objects.
 *
 * @private
 * @type {!Object.<string, !xrx.xpath.BinaryExpr.Op>}
 */
xrx.xpath.BinaryExpr.stringToOpMap_ = {};


/**
 * Creates a binary operator.
 *
 * @param {string} opString The operator string.
 * @param {number} precedence The precedence when evaluated.
 * @param {!xrx.xpath.DataType} dataType The dataType to return when evaluated.
 * @param {function(!xrx.xpath.Expr, !xrx.xpath.Expr, !xrx.xpath.Context)}
 *         evaluate An evaluation function.
 * @return {!xrx.xpath.BinaryExpr.Op} A binary expression operator.
 * @private
 */
xrx.xpath.BinaryExpr.createOp_ = function(opString, precedence, dataType,
    evaluate) {
  if (opString in xrx.xpath.BinaryExpr.stringToOpMap_) {
    throw new Error('Binary operator already created: ' + opString);
  }
  // The upcast and then downcast for the JSCompiler.
  var op = /** @type {!Object} */ (new xrx.xpath.BinaryExpr.Op_(
      opString, precedence, dataType, evaluate));
  op = /** @type {!xrx.xpath.BinaryExpr.Op} */ (op);
  xrx.xpath.BinaryExpr.stringToOpMap_[op.toString()] = op;
  return op;
};


/**
 * Returns the operator with this opString or null if none.
 *
 * @param {string} opString The opString.
 * @return {!xrx.xpath.BinaryExpr.Op} The operator.
 */
xrx.xpath.BinaryExpr.getOp = function(opString) {
  return xrx.xpath.BinaryExpr.stringToOpMap_[opString] || null;
};


/**
 * Binary operator enumeration.
 *
 * @enum {{getPrecedence: function(): number}}
 */
xrx.xpath.BinaryExpr.Op = {
  DIV: xrx.xpath.BinaryExpr.createOp_('div', 6, xrx.xpath.DataType.NUMBER,
      function(left, right, ctx) {
        return left.asNumber(ctx) / right.asNumber(ctx);
      }),
  MOD: xrx.xpath.BinaryExpr.createOp_('mod', 6, xrx.xpath.DataType.NUMBER,
      function(left, right, ctx) {
        return left.asNumber(ctx) % right.asNumber(ctx);
      }),
  MULT: xrx.xpath.BinaryExpr.createOp_('*', 6, xrx.xpath.DataType.NUMBER,
      function(left, right, ctx) {
        return left.asNumber(ctx) * right.asNumber(ctx);
      }),
  PLUS: xrx.xpath.BinaryExpr.createOp_('+', 5, xrx.xpath.DataType.NUMBER,
      function(left, right, ctx) {
        return left.asNumber(ctx) + right.asNumber(ctx);
      }),
  MINUS: xrx.xpath.BinaryExpr.createOp_('-', 5, xrx.xpath.DataType.NUMBER,
      function(left, right, ctx) {
        return left.asNumber(ctx) - right.asNumber(ctx);
      }),
  LESSTHAN: xrx.xpath.BinaryExpr.createOp_('<', 4, xrx.xpath.DataType.BOOLEAN,
      function(left, right, ctx) {
        return xrx.xpath.BinaryExpr.compare_(function(a, b) {return a < b;},
            left, right, ctx);
      }),
  GREATERTHAN: xrx.xpath.BinaryExpr.createOp_('>', 4, xrx.xpath.DataType.BOOLEAN,
      function(left, right, ctx) {
        return xrx.xpath.BinaryExpr.compare_(function(a, b) {return a > b;},
            left, right, ctx);
      }),
  LESSTHAN_EQUAL: xrx.xpath.BinaryExpr.createOp_(
      '<=', 4, xrx.xpath.DataType.BOOLEAN,
      function(left, right, ctx) {
        return xrx.xpath.BinaryExpr.compare_(function(a, b) {return a <= b;},
            left, right, ctx);
      }),
  GREATERTHAN_EQUAL: xrx.xpath.BinaryExpr.createOp_('>=', 4,
      xrx.xpath.DataType.BOOLEAN, function(left, right, ctx) {
        return xrx.xpath.BinaryExpr.compare_(function(a, b) {return a >= b;},
            left, right, ctx);
      }),
  EQUAL: xrx.xpath.BinaryExpr.createOp_('=', 3, xrx.xpath.DataType.BOOLEAN,
      function(left, right, ctx) {
        return xrx.xpath.BinaryExpr.compare_(function(a, b) {return a == b;},
            left, right, ctx, true);
      }),
  NOT_EQUAL: xrx.xpath.BinaryExpr.createOp_('!=', 3, xrx.xpath.DataType.BOOLEAN,
      function(left, right, ctx) {
        return xrx.xpath.BinaryExpr.compare_(function(a, b) {return a != b},
            left, right, ctx, true);
      }),
  AND: xrx.xpath.BinaryExpr.createOp_('and', 2, xrx.xpath.DataType.BOOLEAN,
      function(left, right, ctx) {
        return left.asBool(ctx) && right.asBool(ctx);
      }),
  OR: xrx.xpath.BinaryExpr.createOp_('or', 1, xrx.xpath.DataType.BOOLEAN,
      function(left, right, ctx) {
        return left.asBool(ctx) || right.asBool(ctx);
      })
};
