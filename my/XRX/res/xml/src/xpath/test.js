/**
 * @fileoverview Utilities for XPath JSUnit tests.
 */

goog.provide('xrx.xpath.test');

goog.require('goog.dom');
goog.require('goog.testing.jsunit');
goog.require('xrx.node');
goog.require('xrx.node.DocumentS');
goog.require('xrx.instance');
goog.require('xrx.xpath');



xrx.xpath.test = {};



xrx.xpath.test.query = function(expression) {
  var element = goog.dom.createElement('div');
  goog.dom.setTextContent(element, '<dummy/>');
  var instance = new xrx.instance(element);
  var node = new xrx.node.DocumentS(instance);

  return xrx.xpath.evaluate(expression, node, null, xrx.xpath.XPathResultType.ANY_TYPE);
};



xrx.xpath.test.xpathAssertEquals = function(expected, expression) {
  var result = xrx.xpath.test.query(expression);

  switch (result.resultType) {
  case xrx.xpath.XPathResultType.NUMBER_TYPE:
    assertEquals(expected, result.numberValue);
    break;
  case xrx.xpath.XPathResultType.STRING_TYPE:
    assertEquals(expected, result.stringValue);
    break;
  case xrx.xpath.XPathResultType.BOOLEAN_TYPE:
    assertEquals(expected, result.booleanValue);
    break;
  default:
    assertEquals('Missing XPath Result Type', '');
    break;
  }
};
