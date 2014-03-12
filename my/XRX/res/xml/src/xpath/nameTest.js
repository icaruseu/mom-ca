/**
 * @fileoverview A class implementing the XPath NameTest construct.
 */

goog.provide('xrx.xpath.NameTest');

goog.require('xrx.node');



/**
 * Constructs a NameTest based on the XPath grammar.
 * http://www.w3.org/TR/xpath/#NT-NameTest
 *
 * @param {string} name Name to be tested.
 * @param {string=} opt_namespaceUri Namespace URI.
 * @constructor
 * @implements {xrx.xpath.NodeTest}
 */
xrx.xpath.NameTest = function(name, opt_namespaceUri) {

  /**
   * @type {string}
   * @private
   */
  this.name_ = name;

  /**
   * @type {string}
   * @private
   */
  this.namespaceUri_ = opt_namespaceUri;
};



/**
 * @override
 */
xrx.xpath.NameTest.prototype.matches = function(node) {
  var type = node.type();
  if (type !== xrx.node.ELEMENT &&
      type !== xrx.node.ATTRIBUTE) {
    return false;
  }
  if (this.name_ !== '*' && this.name_ !== node.expandedName()) {
    return false;
  } else {
    return this.namespaceUri_ === node.namespaceUri();
  }
};


/**
 * @override
 */
xrx.xpath.NameTest.prototype.getName = function() {
  return this.name_;
};


/**
 * Returns the namespace URI to be matched.
 *
 * @return {string} Namespace URI.
 */
xrx.xpath.NameTest.prototype.getNamespaceUri = function() {
  return this.namespaceUri_;
};


/**
 * @override
 */
xrx.xpath.NameTest.prototype.toString = function() {
  var prefix = this.namespaceUri_ + ':';
  return 'Name Test: ' + prefix + this.name_;
};
