/**
 * @fileoverview A function call expression.
 */

goog.provide('xrx.xpath.FunctionCall');

goog.require('goog.array');
goog.require('goog.dom');
goog.require('goog.string');
goog.require('xrx.xpath.DataType');
goog.require('xrx.xpath.Expr');
goog.require('xrx.xpath.Function');
goog.require('xrx.node');
goog.require('xrx.xpath.NodeSet');



/**
 * A function call expression.
 *
 * @constructor
 * @extends {xrx.xpath.Expr}
 * @param {!xrx.xpath.FunctionCall.BuiltInFunc} func Function.
 * @param {!Array.<!xrx.xpath.Expr>} args Arguments to the function.
 */
xrx.xpath.FunctionCall = function(func, args) {
  // Check the provided arguments match the function parameters.
  if (args.length < func.minArgs) {
    throw new Error('Function ' + func.name + ' expects at least' +
        func.minArgs + ' arguments, ' + args.length + ' given');
  }
  if (!goog.isNull(func.maxArgs) && args.length > func.maxArgs) {
    throw new Error('Function ' + func.name + ' expects at most ' +
        func.maxArgs + ' arguments, ' + args.length + ' given');
  }
  if (func.nodesetsRequired_) {
    goog.array.forEach(args, function(arg, i) {
      if (arg.getDataType() != xrx.xpath.DataType.NODESET) {
        throw new Error('Argument ' + i + ' to function ' + func.name +
            ' is not of type Nodeset: ' + arg);
      }
    });
  }
  xrx.xpath.Expr.call(this, func.returnType);

  /**
   * @type {!xrx.xpath.FunctionCall.BuiltInFunc}
   * @private
   */
  this.func_ = func;

  /**
   * @type {!Array.<!xrx.xpath.Expr>}
   * @private
   */
  this.args_ = args;

  this.setNeedContextPosition(func.needContextPosition_ ||
      goog.array.some(args, function(arg) {
        return arg.doesNeedContextPosition();
      }));
  this.setNeedContextNode(
      (func.needContextNodeWithoutArgs_ && !args.length) ||
      (func.needContextNodeWithArgs_ && !!args.length) ||
      goog.array.some(args, function(arg) {
        return arg.doesNeedContextNode();
      }));
};
goog.inherits(xrx.xpath.FunctionCall, xrx.xpath.Expr);


/**
 * @override
 */
xrx.xpath.FunctionCall.prototype.evaluate = function(ctx) {
  var result = this.func_.evaluate.apply(null,
      goog.array.concat(ctx, this.args_));
  return /** @type {!(string|boolean|number|xrx.xpath.NodeSet)} */ (result);
};


/**
 * @override
 */
xrx.xpath.FunctionCall.prototype.toString = function() {
  var text = 'Function: ' + this.func_;
  if (this.args_.length) {
    var args = goog.array.reduce(this.args_, function(prev, curr) {
      return prev + xrx.xpath.Expr.indent(curr);
    }, 'Arguments:');
    text += xrx.xpath.Expr.indent(args);
  }
  return text;
};



/**
 * A mapping from function names to Func objects.
 *
 * @private
 * @type {!Object.<string, !xrx.xpath.FunctionCall.BuiltInFunc>}
 */
xrx.xpath.FunctionCall.nameToFuncMap_ = {};


/**
 * Constructs a Func and maps its name to it.
 *
 * @param {string} name Name of the function.
 * @param {xrx.xpath.DataType} returnType Datatype of the function return value.
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
 * @return {!xrx.xpath.FunctionCall.BuiltInFunc} The function created.
 */
xrx.xpath.FunctionCall.createFunc = function(name, returnType,
    needContextPosition, needContextNodeWithoutArgs, needContextNodeWithArgs,
    evaluate, minArgs, opt_maxArgs, opt_nodesetsRequired) {
  if (name in xrx.xpath.FunctionCall.nameToFuncMap_) {
    throw new Error('Function already created: ' + name + '.');
  }
  var func = new xrx.xpath.Function(name, returnType,
      needContextPosition, needContextNodeWithoutArgs, needContextNodeWithArgs,
      evaluate, minArgs, opt_maxArgs, opt_nodesetsRequired);
  func = /** @type {!xrx.xpath.FunctionCall.BuiltInFunc} */ (func);
  xrx.xpath.FunctionCall.nameToFuncMap_[name] = func;
  return func;
};


/**
 * Returns the function object for this name.
 *
 * @param {string} name The function's name.
 * @return {xrx.xpath.FunctionCall.BuiltInFunc} The function object.
 */
xrx.xpath.FunctionCall.getFunc = function(name) {
  return xrx.xpath.FunctionCall.nameToFuncMap_[name] || null;
};


/**
 * An XPath function enumeration.
 *
 * <p>A list of XPath 1.0 functions:
 * http://www.w3.org/TR/xpath/#corelib
 *
 * @enum {!Object}
 */
xrx.xpath.FunctionCall.BuiltInFunc = {
  BOOLEAN: xrx.xpath.FunctionCall.createFunc('boolean',
      xrx.xpath.DataType.BOOLEAN, false, false, false,
      function(ctx, expr) {
        return expr.asBool(ctx);
      }, 1),
  CEILING: xrx.xpath.FunctionCall.createFunc('ceiling',
      xrx.xpath.DataType.NUMBER, false, false, false,
      function(ctx, expr) {
        return Math.ceil(expr.asNumber(ctx));
      }, 1),
  CONCAT: xrx.xpath.FunctionCall.createFunc('concat',
      xrx.xpath.DataType.STRING, false, false, false,
      function(ctx, var_args) {
        var exprs = goog.array.slice(arguments, 1);
        return goog.array.reduce(exprs, function(prev, curr) {
          return prev + curr.asString(ctx);
        }, '');
      }, 2, null),
  CONTAINS: xrx.xpath.FunctionCall.createFunc('contains',
      xrx.xpath.DataType.BOOLEAN, false, false, false,
      function(ctx, expr1, expr2) {
        return goog.string.contains(expr1.asString(ctx), expr2.asString(ctx));
      }, 2),
  COUNT: xrx.xpath.FunctionCall.createFunc('count',
      xrx.xpath.DataType.NUMBER, false, false, false,
      function(ctx, expr) {
        return expr.evaluate(ctx).getLength();
      }, 1, 1, true),
  FALSE: xrx.xpath.FunctionCall.createFunc('false',
      xrx.xpath.DataType.BOOLEAN, false, false, false,
      function(ctx) {
        return false;
      }, 0),
  FLOOR: xrx.xpath.FunctionCall.createFunc('floor',
      xrx.xpath.DataType.NUMBER, false, false, false,
      function(ctx, expr) {
        return Math.floor(expr.asNumber(ctx));
      }, 1),
  ID: xrx.xpath.FunctionCall.createFunc('id',
      xrx.xpath.DataType.NODESET, false, false, false,
      function(ctx, expr) {
        var ctxNode = ctx.getNode();
        var doc = ctxNode.type() === xrx.node.DOCUMENT ? ctxNode :
            ctxNode.ownerDocument;
        var ids = expr.asString(ctx).split(/\s+/);
        var nsArray = [];
        goog.array.forEach(ids, function(id) {
          var elem = idSingle(id);
          if (elem && !goog.array.contains(nsArray, elem)) {
            nsArray.push(elem);
          }
        });
        nsArray.sort(goog.dom.compareNodeOrder);
        var ns = new xrx.xpath.NodeSet();
        goog.array.forEach(nsArray, function(n) {
          ns.add(n);
        });
        return ns;

        function idSingle(id) {
            return doc.getElementById(id);
        }
      }, 1),
  LANG: xrx.xpath.FunctionCall.createFunc('lang',
      xrx.xpath.DataType.BOOLEAN, false, false, false,
      function(ctx, expr) {
        // TODO(user): Fully implement this.
        return false;
      }, 1),
  LAST: xrx.xpath.FunctionCall.createFunc('last',
      xrx.xpath.DataType.NUMBER, true, false, false,
      function(ctx) {
        if (arguments.length != 1) {
          throw Error('Function last expects ()');
        }
        return ctx.getLast();
      }, 0),
  LOCAL_NAME: xrx.xpath.FunctionCall.createFunc('local-name',
      xrx.xpath.DataType.STRING, false, true, false,
      function(ctx, opt_expr) {
        var node = opt_expr ? opt_expr.evaluate(ctx).getFirst() : ctx.getNode();
        return node ? node.nodeName.toLowerCase() : '';
      }, 0, 1, true),
  NAME: xrx.xpath.FunctionCall.createFunc('name',
      xrx.xpath.DataType.STRING, false, true, false,
      function(ctx, opt_expr) {
        // TODO(user): Fully implement this.
        var node = opt_expr ? opt_expr.evaluate(ctx).getFirst() : ctx.getNode();
        return node ? node.nodeName.toLowerCase() : '';
      }, 0, 1, true),
  NAMESPACE_URI: xrx.xpath.FunctionCall.createFunc('namespace-uri',
      xrx.xpath.DataType.STRING, true, false, false,
      function(ctx, opt_expr) {
        // TODO(user): Fully implement this.
        return '';
      }, 0, 1, true),
  NORMALIZE_SPACE: xrx.xpath.FunctionCall.createFunc('normalize-space',
      xrx.xpath.DataType.STRING, false, true, false,
      function(ctx, opt_expr) {
        var str = opt_expr ? opt_expr.asString(ctx) :
            ctx.getNode().getValueAsString();
        return goog.string.collapseWhitespace(str);
      }, 0, 1),
  NOT: xrx.xpath.FunctionCall.createFunc('not',
      xrx.xpath.DataType.BOOLEAN, false, false, false,
      function(ctx, expr) {
        return !expr.asBool(ctx);
      }, 1),
  NUMBER: xrx.xpath.FunctionCall.createFunc('number',
      xrx.xpath.DataType.NUMBER, false, true, false,
      function(ctx, opt_expr) {
        return opt_expr ? opt_expr.asNumber(ctx) :
            ctx.getNode().getValueAsNumber();
      }, 0, 1),
  POSITION: xrx.xpath.FunctionCall.createFunc('position',
      xrx.xpath.DataType.NUMBER, true, false, false,
      function(ctx) {
        return ctx.getPosition();
      }, 0),
  ROUND: xrx.xpath.FunctionCall.createFunc('round',
      xrx.xpath.DataType.NUMBER, false, false, false,
      function(ctx, expr) {
        return Math.round(expr.asNumber(ctx));
      }, 1),
  STARTS_WITH: xrx.xpath.FunctionCall.createFunc('starts-with',
      xrx.xpath.DataType.BOOLEAN, false, false, false,
      function(ctx, expr1, expr2) {
        return goog.string.startsWith(expr1.asString(ctx), expr2.asString(ctx));
      }, 2),
  STRING: xrx.xpath.FunctionCall.createFunc(
      'string', xrx.xpath.DataType.STRING, false, true, false,
      function(ctx, opt_expr) {
        return opt_expr ? opt_expr.asString(ctx) :
            ctx.getNode().getValueAsString();
      }, 0, 1),
  STRING_LENGTH: xrx.xpath.FunctionCall.createFunc('string-length',
      xrx.xpath.DataType.NUMBER, false, true, false,
      function(ctx, opt_expr) {
        var str = opt_expr ? opt_expr.asString(ctx) :
            ctx.getNode().getValueAsString();
        return str.length;
      }, 0, 1),
  SUBSTRING: xrx.xpath.FunctionCall.createFunc('substring',
      xrx.xpath.DataType.STRING, false, false, false,
      function(ctx, expr1, expr2, opt_expr3) {
        var startRaw = expr2.asNumber(ctx);
        if (isNaN(startRaw) || startRaw == Infinity || startRaw == -Infinity) {
          return '';
        }
        var lengthRaw = opt_expr3 ? opt_expr3.asNumber(ctx) : Infinity;
        if (isNaN(lengthRaw) || lengthRaw === -Infinity) {
          return '';
        }

        // XPath indices are 1-based.
        var startInt = Math.round(startRaw) - 1;
        var start = Math.max(startInt, 0);
        var str = expr1.asString(ctx);

        if (lengthRaw == Infinity) {
          return str.substring(start);
        } else {
          var lengthInt = Math.round(lengthRaw);
          // Length is from startInt, not start!
          return str.substring(start, startInt + lengthInt);
        }
      }, 2, 3),
  SUBSTRING_AFTER: xrx.xpath.FunctionCall.createFunc('substring-after',
      xrx.xpath.DataType.STRING, false, false, false,
      function(ctx, expr1, expr2) {
        var str1 = expr1.asString(ctx);
        var str2 = expr2.asString(ctx);
        var str2Index = str1.indexOf(str2);
        return str2Index == -1 ? '' : str1.substring(str2Index + str2.length);
      }, 2),
  SUBSTRING_BEFORE: xrx.xpath.FunctionCall.createFunc('substring-before',
      xrx.xpath.DataType.STRING, false, false, false,
      function(ctx, expr1, expr2) {
        var str1 = expr1.asString(ctx);
        var str2 = expr2.asString(ctx);
        var str2Index = str1.indexOf(str2);
        return str2Index == -1 ? '' : str1.substring(0, str2Index);
      }, 2),
  SUM: xrx.xpath.FunctionCall.createFunc('sum',
      xrx.xpath.DataType.NUMBER, false, false, false,
      function(ctx, expr) {
        var ns = expr.evaluate(ctx);
        var iter = ns.iterator();
        var prev = 0;
        for (var node = iter.next(); node; node = iter.next()) {
          prev += node.getValueAsNumber();
        }
        return prev;
      }, 1, 1, true),
  TRANSLATE: xrx.xpath.FunctionCall.createFunc('translate',
      xrx.xpath.DataType.STRING, false, false, false,
      function(ctx, expr1, expr2, expr3) {
        var str1 = expr1.asString(ctx);
        var str2 = expr2.asString(ctx);
        var str3 = expr3.asString(ctx);

        var map = [];
        for (var i = 0; i < str2.length; i++) {
          var ch = str2.charAt(i);
          if (!(ch in map)) {
            // If i >= str3.length, charAt will return the empty string.
            map[ch] = str3.charAt(i);
          }
        }

        var translated = '';
        for (var i = 0; i < str1.length; i++) {
          var ch = str1.charAt(i);
          translated += (ch in map) ? map[ch] : ch;
        }
        return translated;
      }, 3),
  TRUE: xrx.xpath.FunctionCall.createFunc(
      'true', xrx.xpath.DataType.BOOLEAN, false, false, false,
      function(ctx) {
        return true;
      }, 0)
};
