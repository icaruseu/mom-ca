/**
 * @fileoverview Context information about nodes in their node-set.
 */

goog.provide('xrx.xpath.NodeSet');

goog.require('goog.dom');
goog.require('xrx.node');



/**
 * A set of nodes sorted by their prefix order in the document.
 *
 * @constructor
 */
xrx.xpath.NodeSet = function() {
  // In violation of standard Closure practice, we initialize properties to
  // immutable constants in the constructor instead of on the prototype,
  // because we have empirically measured better performance by doing so.

  /**
   * A pointer to the first node in the linked list.
   *
   * @private
   * @type {xrx.xpath.NodeSet.Entry_}
   */
  this.first_ = null;

  /**
   * A pointer to the last node in the linked list.
   *
   * @private
   * @type {xrx.xpath.NodeSet.Entry_}
   */
  this.last_ = null;

  /**
   * Length of the linked list.
   *
   * @private
   * @type {number}
   */
  this.length_ = 0;
};



/**
 * A entry for a node in a linked list
 *
 * @param {!xrx.node} node The node to be added.
 * @constructor
 * @private
 */
xrx.xpath.NodeSet.Entry_ = function(node) {
  // In violation of standard Closure practice, we initialize properties to
  // immutable constants in the constructor instead of on the prototype,
  // because we have empirically measured better performance by doing so.

  /**
   * @type {!xrx.node}
   */
  this.node = node;

  /**
   * @type {xrx.xpath.NodeSet.Entry_}
   */
  this.prev = null;

  /**
   * @type {xrx.xpath.NodeSet.Entry_}
   */
  this.next = null;
};


/**
 * Merges two node-sets, removing duplicates. This function may modify both
 * node-sets, and will return a reference to one of the two.
 *
 * <p> Note: We assume that the two node-sets are already sorted in DOM order.
 *
 * @param {!xrx.xpath.NodeSet} a The first node-set.
 * @param {!xrx.xpath.NodeSet} b The second node-set.
 * @return {!xrx.xpath.NodeSet} The merged node-set.
 */
xrx.xpath.NodeSet.merge = function(a, b) {
  if (!a.first_) {
    return b;
  } else if (!b.first_) {
    return a;
  }
  var aCurr = a.first_;
  var bCurr = b.first_;
  var merged = a, tail = null, next = null, length = 0;
  while (aCurr && bCurr) {
    if (aCurr.node.isSameAs(bCurr.node)) {
      next = aCurr;
      aCurr = aCurr.next;
      bCurr = bCurr.next;
    } else {
      if (aCurr.node.isAfter(bCurr.node)) {
        next = bCurr;
        bCurr = bCurr.next;
      } else {
        next = aCurr;
        aCurr = aCurr.next;
      }
    }
    next.prev = tail;
    if (tail) {
      tail.next = next;
    } else {
      merged.first_ = next;
    }
    tail = next;
    length++;
  }
  next = aCurr || bCurr;
  while (next) {
    next.prev = tail;
    tail.next = next;
    tail = next;
    length++;
    next = next.next;
  }
  merged.last_ = tail;
  merged.length_ = length;
  return merged;
};


/**
 * Prepends a node to this node-set.
 *
 * @param {!xrx.node} node The node to be added.
 */
xrx.xpath.NodeSet.prototype.unshift = function(node) {
  var entry = new xrx.xpath.NodeSet.Entry_(node);
  entry.next = this.first_;
  if (!this.last_) {
    this.first_ = this.last_ = entry;
  } else {
    this.first_.prev = entry;
  }
  this.first_ = entry;
  this.length_++;
};


/**
 * Adds a node to this node-set.
 *
 * @param {!xrx.node} node The node to be added.
 */
xrx.xpath.NodeSet.prototype.add = function(node) {
  var entry = new xrx.xpath.NodeSet.Entry_(node);
  entry.prev = this.last_;
  if (!this.first_) {
    this.first_ = this.last_ = entry;
  } else {
    this.last_.next = entry;
  }
  this.last_ = entry;
  this.length_++;
};


/**
 * Returns the first node of the node-set.
 *
 * @return {?xrx.node} The first node of the nodeset
                                     if the nodeset is non-empty;
 *     otherwise null.
 */
xrx.xpath.NodeSet.prototype.getFirst = function() {
  var first = this.first_;
  if (first) {
    return first.node;
  } else {
    return null;
  }
};


/**
 * Return the length of this node-set.
 *
 * @return {number} The length of the node-set.
 */
xrx.xpath.NodeSet.prototype.getLength = function() {
  return this.length_;
};


/**
 * Returns the string representation of this node-set.
 *
 * @return {string} The string representation of this node-set.
 */
xrx.xpath.NodeSet.prototype.string = function() {
  var node = this.getFirst();
  return node ? node.getValueAsString() : '';
};


/**
 * Returns the number representation of this node-set.
 *
 * @return {number} The number representation of this node-set.
 */
xrx.xpath.NodeSet.prototype.number = function() {
  return +this.string();
};


/**
 * Returns an iterator over this nodeset. Once this iterator is made, DO NOT
 *     add to this nodeset until the iterator is done.
 *
 * @param {boolean=} opt_reverse Whether to iterate right to left or vice versa.
 * @return {!xrx.xpath.NodeSet.Iterator} An iterator over the nodes.
 */
xrx.xpath.NodeSet.prototype.iterator = function(opt_reverse) {
  return new xrx.xpath.NodeSet.Iterator(this, !!opt_reverse);
};



/**
 * An iterator over the nodes of this nodeset.
 *
 * @param {!xrx.xpath.NodeSet} nodeset The nodeset to be iterated over.
 * @param {boolean} reverse Whether to iterate in ascending or descending
 *     order.
 * @constructor
 */
xrx.xpath.NodeSet.Iterator = function(nodeset, reverse) {
  // In violation of standard Closure practice, we initialize properties to
  // immutable constants in the constructor instead of on the prototype,
  // because we have empirically measured better performance by doing so.

  /**
   * @type {!xrx.xpath.NodeSet}
   * @private
   */
  this.nodeset_ = nodeset;

  /**
   * @type {boolean}
   * @private
   */
  this.reverse_ = reverse;

  /**
   * @type {xrx.xpath.NodeSet.Entry_}
   * @private
   */
  this.current_ = reverse ? nodeset.last_ : nodeset.first_;

  /**
   * @type {xrx.xpath.NodeSet.Entry_}
   * @private
   */
  this.lastReturned_ = null;
};


/**
 * Returns the next value of the iteration or null if passes the end.
 *
 * @return {?xrx.node} The next node from this iterator.
 */
xrx.xpath.NodeSet.Iterator.prototype.next = function() {
  var current = this.current_;
  if (current == null) {
    return null;
  } else {
    var lastReturned = this.lastReturned_ = current;
    if (this.reverse_) {
      this.current_ = current.prev;
    } else {
      this.current_ = current.next;
    }
    return lastReturned.node;
  }
};


/**
 * Deletes the last node that was returned from this iterator.
 */
xrx.xpath.NodeSet.Iterator.prototype.remove = function() {
  var nodeset = this.nodeset_;
  var entry = this.lastReturned_;
  if (!entry) {
    throw Error('Next must be called at least once before remove.');
  }
  var prev = entry.prev;
  var next = entry.next;

  // Modify the pointers of prev and next
  if (prev) {
    prev.next = next;
  } else {
    // If there was no prev node entry must've been first_, so update first_.
    nodeset.first_ = next;
  }
  if (next) {
    next.prev = prev;
  } else {
    // If there was no prev node entry must've been last_, so update last_.
    nodeset.last_ = prev;
  }
  nodeset.length_--;
  this.lastReturned_ = null;
};
