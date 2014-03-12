/**
 * @fileoverview An interface for the NodeTest construct.
 */

goog.provide('xrx.xpath.NodeTest');



/**
 * The NodeTest interface to represent the NodeTest production
 * in the xpath grammar:
 * http://www.w3.org/TR/xpath-30/#prod-xpath30-NodeTest
 *
 * @interface
 */
xrx.xpath.NodeTest = function() {};


/**
 * Tests if a node matches the stored characteristics.
 *
 * @param {xrx.xpath..Node} node The node to be tested.
 * @return {boolean} Whether the node passes the test.
 */
xrx.xpath.NodeTest.prototype.matches = goog.abstractMethod;


/**
 * Returns the name of the test.
 *
 * @return {string} The name, either nodename or type name.
 */
xrx.xpath.NodeTest.prototype.getName = goog.abstractMethod;


/**
 * @override
 */
xrx.xpath.NodeTest.prototype.toString = goog.abstractMethod;
