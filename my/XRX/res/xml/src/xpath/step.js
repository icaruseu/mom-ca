/**
 * @fileoverview Class for a step in a path expression.
 */

goog.provide('xrx.xpath.Step');

goog.require('goog.array');
goog.require('xrx.xpath.DataType');
goog.require('xrx.xpath.Expr');
goog.require('xrx.xpath.KindTest');
goog.require('xrx.node');
goog.require('xrx.xpath.Predicates');



/**
 * Class for a step in a path expression
 * http://www.w3.org/TR/xpath20/#id-steps.
 *
 * @extends {xrx.xpath.Expr}
 * @constructor
 * @param {!xrx.xpath.Step.Axis} axis The axis for this Step.
 * @param {!xrx.xpath.NodeTest} test The test for this Step.
 * @param {!xrx.xpath.Predicates=} opt_predicates The predicates for this
 *     Step.
 * @param {boolean=} opt_descendants Whether descendants are to be included in
 *     this step ('//' vs '/').
 */
xrx.xpath.Step = function(axis, test, opt_predicates, opt_descendants) {
  var axisCast = /** @type {!xrx.xpath.Step.Axis_} */ (axis);
  xrx.xpath.Expr.call(this, xrx.xpath.DataType.NODESET);

  /**
   * @type {!xrx.xpath.Step.Axis_}
   * @private
   */
  this.axis_ = axisCast;


  /**
   * @type {!xrx.xpath.NodeTest}
   * @private
   */
  this.test_ = test;

  /**
   * @type {!xrx.xpath.Predicates}
   * @private
   */
  this.predicates_ = opt_predicates || new xrx.xpath.Predicates([]);


  /**
   * Whether decendants are included in this step
   *
   * @private
   * @type {boolean}
   */
  this.descendants_ = !!opt_descendants;

  var quickAttrInfo = this.predicates_.getQuickAttr();
  if (axis.supportsQuickAttr_ && quickAttrInfo) {
    var attrName = quickAttrInfo.name;
    var attrValueExpr = quickAttrInfo.valueExpr;
    this.setQuickAttr({
      name: attrName,
      valueExpr: attrValueExpr
    });
  }
  this.setNeedContextPosition(this.predicates_.doesNeedContextPosition());
};
goog.inherits(xrx.xpath.Step, xrx.xpath.Expr);


/**
 * @override
 * @return {!xrx.xpath.NodeSet} The nodeset result.
 */
xrx.xpath.Step.prototype.evaluate = function(ctx) {
  var node = ctx.getNode();
  var nodeset = null;
  var quickAttr = this.getQuickAttr();
  var attrName = null;
  var attrValue = null;
  var pstart = 0;
  if (quickAttr) {
    attrName = quickAttr.name;
    attrValue = quickAttr.valueExpr ?
        quickAttr.valueExpr.asString(ctx) : null;
    pstart = 1;
  }
  if (this.descendants_) {
    if (!this.doesNeedContextPosition() &&
        this.axis_ == xrx.xpath.Step.Axis.CHILD) {
      nodeset = node.getNodeDescendant(this.test_);
      nodeset = this.predicates_.evaluatePredicates(nodeset, pstart);
    } else {
      var step = new xrx.xpath.Step(xrx.xpath.Step.Axis.DESCENDANT_OR_SELF,
          new xrx.xpath.KindTest('node'));
      var iter = step.evaluate(ctx).iterator();
      var n = iter.next();
      if (!n) {
        nodeset = new xrx.xpath.NodeSet();
      } else {
        nodeset = this.evaluate_(/** @type {!xrx.node} */ (n),
            attrName, attrValue, pstart);
        while ((n = iter.next()) != null) {
          nodeset = xrx.xpath.NodeSet.merge(nodeset,
              this.evaluate_(/** @type {!xrx.node} */ (n), attrName,
              attrValue, pstart));
        }
      }
    }
  } else {
    nodeset = this.evaluate_(ctx.getNode(), attrName, attrValue, pstart);
  }
  return nodeset;
};


/**
 * Evaluates this step on the given context to a node-set.
 *     (assumes this.descendants_ = false)
 *
 * @private
 * @param {!xrx.node} node The context node.
 * @param {?string} attrName The name of the attribute.
 * @param {?string} attrValue The value of the attribute.
 * @param {number} pstart The first predicate to evaluate.
 * @return {!xrx.xpath.NodeSet} The node-set from evaluating this Step.
 */
xrx.xpath.Step.prototype.evaluate_ = function(
    node, attrName, attrValue, pstart) {
  var nodeset = this.axis_.func_(this.test_, node, attrName, attrValue);
  nodeset = this.predicates_.evaluatePredicates(nodeset, pstart);
  return nodeset;
};


/**
 * Returns whether the step evaluation should include descendants.
 *
 * @return {boolean} Whether descendants are included.
 */
xrx.xpath.Step.prototype.doesIncludeDescendants = function() {
  return this.descendants_;
};


/**
 * Returns the step's axis.
 *
 * @return {!xrx.xpath.Step.Axis} The axis.
 */
xrx.xpath.Step.prototype.getAxis = function() {
  return /** @type {!xrx.xpath.Step.Axis} */ (this.axis_);
};


/**
 * Returns the test for this step.
 *
 * @return {!xrx.xpath.NodeTest} The test for this step.
 */
xrx.xpath.Step.prototype.getTest = function() {
  return this.test_;
};


/**
 * @override
 */
xrx.xpath.Step.prototype.toString = function() {
  var text = 'Step:';
  text += xrx.xpath.Expr.indent('Operator: ' + (this.descendants_ ? '//' : '/'));
  if (this.axis_.name_) {
    text += xrx.xpath.Expr.indent('Axis: ' + this.axis_);
  }
  text += xrx.xpath.Expr.indent(this.test_);
  if (this.predicates_.getLength()) {
    var predicates = goog.array.reduce(this.predicates_.getPredicates(),
        function(prev, curr) {
          return prev + xrx.xpath.Expr.indent(curr);
        }, 'Predicates:');
    text += xrx.xpath.Expr.indent(predicates);
  }
  return text;
};



/**
 * A step axis.
 *
 * @constructor
 * @param {string} name The axis name.
 * @param {function(!xrx.xpath.NodeTest, xrx.node, ?string, ?string):
 *     !xrx.xpath.NodeSet} func The function for this axis.
 * @param {boolean} reverse Whether to iterate over the node-set in reverse.
 * @param {boolean} supportsQuickAttr Whether quickAttr should be enabled for
 *     this axis.
 * @private
 */
xrx.xpath.Step.Axis_ = function(name, func, reverse, supportsQuickAttr) {

  /**
   * @private
   * @type {string}
   */
  this.name_ = name;

  /**
   * @private
   * @type {function(!xrx.xpath.NodeTest, xrx.node, ?string, ?string):
   *     !xrx.xpath.NodeSet}
   */
  this.func_ = func;

  /**
   * @private
   * @type {boolean}
   */
  this.reverse_ = reverse;

  /**
   * @private
   * @type {boolean}
   */
  this.supportsQuickAttr_ = supportsQuickAttr;
};


/**
 * Returns whether the nodes in the step should be iterated over in reverse.
 *
 * @return {boolean} Whether the nodes should be iterated over in reverse.
 */
xrx.xpath.Step.Axis_.prototype.isReverse = function() {
  return this.reverse_;
};


/**
 * @override
 */
xrx.xpath.Step.Axis_.prototype.toString = function() {
  return this.name_;
};


/**
 * A map from axis name to Axis.
 *
 * @type {!Object.<string, !xrx.xpath.Step.Axis>}
 * @private
 */
xrx.xpath.Step.nameToAxisMap_ = {};


/**
 * Creates an axis and maps the axis's name to that axis.
 *
 * @param {string} name The axis name.
 * @param {function(!xrx.xpath.NodeTest, xrx.node, ?string, ?string):
 *     !xrx.xpath.NodeSet} func The function for this axis.
 * @param {boolean} reverse Whether to iterate over nodesets in reverse.
 * @param {boolean=} opt_supportsQuickAttr Whether quickAttr can be enabled
 *     for this axis.
 * @return {!xrx.xpath.Step.Axis} The axis.
 * @private
 */
xrx.xpath.Step.createAxis_ =
    function(name, func, reverse, opt_supportsQuickAttr) {
  if (name in xrx.xpath.Step.nameToAxisMap_) {
    throw Error('Axis already created: ' + name);
  }
  // The upcast and then downcast for the JSCompiler.
  var axis = /** @type {!Object} */ (new xrx.xpath.Step.Axis_(
      name, func));
  axis = /** @type {!xrx.xpath.Step.Axis} */ (axis);
  xrx.xpath.Step.nameToAxisMap_[name] = axis;
  return axis;
};


/**
 * Returns the axis for this axisname or null if none.
 *
 * @param {string} name The axis name.
 * @return {xrx.xpath.Step.Axis} The axis.
 */
xrx.xpath.Step.getAxis = function(name) {
  return xrx.xpath.Step.nameToAxisMap_[name] || null;
};


/**
 * Axis enumeration.
 */
xrx.xpath.Step.Axis = {
  ANCESTOR: xrx.xpath.Step.createAxis_('ancestor',
      function(test, node) {
        return node.getNodeAncestor(test);
      }),
  ANCESTOR_OR_SELF: xrx.xpath.Step.createAxis_('ancestor-or-self',
      function(test, node) {
        var nodeset = node.getNodeAncestor(test);
        if (test.matches(node)) nodeset.add(node);
        return nodeset;
      }),
  ATTRIBUTE: xrx.xpath.Step.createAxis_('attribute',
      function(test, node) {
        return node.getNodeAttribute(test);
      }),
  CHILD: xrx.xpath.Step.createAxis_('child',
      function(test, node) {
        return node.getNodeChild(test);
      }),
  DESCENDANT: xrx.xpath.Step.createAxis_('descendant',
      function(test, node) {
        return node.getNodeDescendant(test);
      }),
  DESCENDANT_OR_SELF: xrx.xpath.Step.createAxis_('descendant-or-self',
      function(test, node) {
        var nodeset = node.getNodeDescendant(test);
        if (test.matches(node)) nodeset.unshift(node);
        return nodeset;
      }),
  FOLLOWING: xrx.xpath.Step.createAxis_('following',
      function(test, node) {
        return node.getNodeFollowing(test);
      }),
  FOLLOWING_SIBLING: xrx.xpath.Step.createAxis_('following-sibling',
      function(test, node) {
        return node.getNodeFollowingSibling(test);
      }),
  NAMESPACE: xrx.xpath.Step.createAxis_('namespace',
      function(test, node) {
        // not implemented
        return new xrx.xpath.NodeSet();
      }),
  PARENT: xrx.xpath.Step.createAxis_('parent',
      function(test, node) {
        return node.getNodeParent(test);
      }),
  PRECEDING: xrx.xpath.Step.createAxis_('preceding',
      function(test, node) {
        return node.getNodePreceding(test);
      }),
  PRECEDING_SIBLING: xrx.xpath.Step.createAxis_('preceding-sibling',
      function(test, node) {
        return node.getNodePrecedingSibling(test);
      }),
  SELF: xrx.xpath.Step.createAxis_('self',
      function(test, node) {
        var nodeset = new xrx.xpath.NodeSet();
        if (test.matches(node)) nodeset.add(node);
        return nodeset;
      })
};
