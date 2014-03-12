/**
 * @fileoverview A streaming XPath 3.0 implementation forked
 * from Google's Wicked Good XPath library. The implementation
 * is not yet complete.
 */
/**
 * The MIT License
 * 
 * Copyright (c) 2007 Cybozu Labs, Inc.
 * Copyright (c) 2012 Google Inc.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:

 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
*/

goog.provide('xrx.xpath');

goog.require('xrx.xpath.Context');
goog.require('xrx.xpath.FunctionCall');
goog.require('xrx.xpath.Lexer');
goog.require('xrx.xpath.NodeSet');
goog.require('xrx.xpath.Parser');



xrx.xpath.XPathFunctions = {
  
};


/**
 * XPath namespace resolver.
 *
 * @enum {string}
 */
xrx.xpath.XPathNSResolver = {
  xml: 'http://www.w3.org/XML/1998/namespace',
  xmlns: 'http://www.w3.org/2000/xmlns/',
  xs: 'http://www.w3.org/2001/XMLSchema',
  fn: 'http://www.w3.org/2005/xpath-functions',
  err: 'http://www.w3.org/2005/xqt-errors'
};



/**
 * Adds a new prefix and URI to the static XPath context.
 * 
 * @param {!string} prefix The namespace prefix.
 * @param {!string} uri The namespace uri.
 */
xrx.xpath.declareNamespace = function(prefix, uri) {
  if (xrx.xpath.XPathNSResolver[prefix]) throw Error('Namespace is already defined.');
  xrx.xpath.XPathNSResolver[prefix] = uri;
};



/**
 * Adds a custom function to the static XPath context.
 * 
 * @param {!xrx.xpath.Function} The function.
 */
xrx.xpath.declareFunction = function(func) {
  var prefix = func.name.substr(0, func.name.indexOf(':'));

  if (prefix === '') throw Error('The empty namespace is not allowed for custom functions.');
  if (!xrx.xpath.XPathNSResolver[prefix]) throw Error('Namespace <' + prefix + '> is not defined.');

  if (xrx.xpath.XPathNSResolver[func.name]) throw Error('Function <' + func.name + '> is already defined.');
  xrx.xpath.XPathNSResolver[func.name] = func;

  xrx.xpath.FunctionCall.createFunc(func.name, func.retrunType,
      true, true, true, func.evaluate, func.minArgs, func.maxArgs);
};



/**
 * Enum for XPathResult types.
 *
 * @private
 * @enum {number}
 */
xrx.xpath.XPathResultType = {
  ANY_TYPE: 0,
  NUMBER_TYPE: 1,
  STRING_TYPE: 2,
  BOOLEAN_TYPE: 3,
  UNORDERED_NODE_ITERATOR_TYPE: 4,
  ORDERED_NODE_ITERATOR_TYPE: 5,
  UNORDERED_NODE_SNAPSHOT_TYPE: 6,
  ORDERED_NODE_SNAPSHOT_TYPE: 7,
  ANY_UNORDERED_NODE_TYPE: 8,
  FIRST_ORDERED_NODE_TYPE: 9
};



/**
 * The exported XPathExpression type.
 *
 * @constructor
 * @extends {XPathExpression}
 * @param {string} expr The expression string.
 * @param {?(XPathNSResolver|function(string): ?string)} nsResolver
 *     XPath namespace resolver.
 * @private
 */
xrx.xpath.XPathExpression = function(expr, nsResolver) {
  if (!expr.length) {
    throw Error('Empty XPath expression.');
  }
  var lexer = xrx.xpath.Lexer.tokenize(expr);
  if (lexer.empty()) {
    throw Error('Invalid XPath expression.');
  }

  // nsResolver may either be an XPathNSResolver, which has a lookupNamespaceURI
  // function, a custom function, or null. Standardize it to a function.
  if (!nsResolver) {
    nsResolver = function(string) {return null;};
  } else if (!goog.isFunction(nsResolver)) {
    nsResolver = goog.bind(nsResolver.lookupNamespaceURI, nsResolver);
  }

  var gexpr = new xrx.xpath.Parser(lexer, nsResolver).parseExpr();
  if (!lexer.empty()) {
    throw Error('Bad token: ' + lexer.next());
  }
  this['evaluate'] = function(node, type) {
    var value = gexpr.evaluate(new xrx.xpath.Context(node));
    return new xrx.xpath.XPathResult(value, type);
  };
};



/**
 * The exported XPathResult type.
 *
 * @constructor
 * @extends {XPathResult}
 * @param {(!xrx.xpath.NodeSet|number|string|boolean)} value The result value.
 * @param {number} type The result type.
 * @private
 */
xrx.xpath.XPathResult = function(value, type) {
  if (type == xrx.xpath.XPathResultType.ANY_TYPE) {
    if (value instanceof xrx.xpath.NodeSet) {
      type = xrx.xpath.XPathResultType.UNORDERED_NODE_ITERATOR_TYPE;
    } else if (typeof value == 'string') {
      type = xrx.xpath.XPathResultType.STRING_TYPE;
    } else if (typeof value == 'number') {
      type = xrx.xpath.XPathResultType.NUMBER_TYPE;
    } else if (typeof value == 'boolean') {
      type = xrx.xpath.XPathResultType.BOOLEAN_TYPE;
    } else {
      throw Error('Unexpected evaluation result.');
    }
  }
  if (type != xrx.xpath.XPathResultType.STRING_TYPE &&
      type != xrx.xpath.XPathResultType.NUMBER_TYPE &&
      type != xrx.xpath.XPathResultType.BOOLEAN_TYPE &&
      !(value instanceof xrx.xpath.NodeSet)) {
    throw Error('value could not be converted to the specified type');
  }
  this['resultType'] = type;
  var nodes;
  switch (type) {
    case xrx.xpath.XPathResultType.STRING_TYPE:
      this['stringValue'] = (value instanceof xrx.xpath.NodeSet) ?
          value.string() : '' + value;
      break;
    case xrx.xpath.XPathResultType.NUMBER_TYPE:
      this['numberValue'] = (value instanceof xrx.xpath.NodeSet) ?
          value.number() : +value;
      break;
    case xrx.xpath.XPathResultType.BOOLEAN_TYPE:
      this['booleanValue'] = (value instanceof xrx.xpath.NodeSet) ?
          value.getLength() > 0 : !!value;
      break;
    case xrx.xpath.XPathResultType.UNORDERED_NODE_ITERATOR_TYPE:
    case xrx.xpath.XPathResultType.ORDERED_NODE_ITERATOR_TYPE:
    case xrx.xpath.XPathResultType.UNORDERED_NODE_SNAPSHOT_TYPE:
    case xrx.xpath.XPathResultType.ORDERED_NODE_SNAPSHOT_TYPE:
      var iter = value.iterator();
      nodes = [];
      for (var node = iter.next(); node; node = iter.next()) {
        nodes.push(node);
      }
      this['snapshotLength'] = value.getLength();
      this['invalidIteratorState'] = false;
      break;
    case xrx.xpath.XPathResultType.ANY_UNORDERED_NODE_TYPE:
    case xrx.xpath.XPathResultType.FIRST_ORDERED_NODE_TYPE:
      var firstNode = value.getFirst();
      this['singleNodeValue'] = firstNode;
      break;
    default:
      throw Error('Unknown XPathResult type.');
  }
  var index = 0;
  this['iterateNext'] = function() {
    if (type != xrx.xpath.XPathResultType.UNORDERED_NODE_ITERATOR_TYPE &&
        type != xrx.xpath.XPathResultType.ORDERED_NODE_ITERATOR_TYPE) {
      throw Error('iterateNext called with wrong result type');
    }
    return (index >= nodes.length) ? null : nodes[index++];
  };
  this['snapshotItem'] = function(i) {
    if (type != xrx.xpath.XPathResultType.UNORDERED_NODE_SNAPSHOT_TYPE &&
        type != xrx.xpath.XPathResultType.ORDERED_NODE_SNAPSHOT_TYPE) {
      throw Error('snapshotItem called with wrong result type');
    }
    return (i >= nodes.length || i < 0) ? null : nodes[i];
  };
};



xrx.xpath.evaluate = function(expr, context, nsResolver, type, result) {
  return new xrx.xpath.XPathExpression(expr, nsResolver).
      evaluate(context, type);
};

