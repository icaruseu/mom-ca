/**
 * @fileoverview Context information about nodes in their nodeset.
 */

goog.provide('xrx.xpath.Context');



/**
 * Provides information for where something is in the XML tree.
 *
 * @param {!xrx.node} node A node in the XML tree.
 * @param {number=} opt_position The position of this node in its nodeset,
 *     defaults to 1.
 * @param {number=} opt_last Index of the last node in this nodeset,
 *     defaults to 1.
 * @constructor
 */
xrx.xpath.Context = function(node, opt_position, opt_last) {

  /**
    * @private
    * @type {!xrx.node}
    */
  this.node_ = node;

  /**
   * @private
   * @type {number}
   */
  this.position_ = opt_position || 1;

  /**
   * @private
   * @type {number} opt_last
   */
  this.last_ = opt_last || 1;
};


/**
 * Returns the node for this context object.
 *
 * @return {!xrx.node} The node for this context object.
 */
xrx.xpath.Context.prototype.getNode = function() {
  return this.node_;
};


/**
 * Returns the position for this context object.
 *
 * @return {number} The position for this context object.
 */
xrx.xpath.Context.prototype.getPosition = function() {
  return this.position_;
};


/**
 * Returns the last field for this context object.
 *
 * @return {number} The last field for this context object.
 */
xrx.xpath.Context.prototype.getLast = function() {
  return this.last_;
};
