/**
 * @fileoverview A node implementation for streaming XPath evaluation.
 */

goog.provide('xrx.nodeS');



goog.require('xrx.node');
goog.require('xrx.node.AttributeS');
goog.require('xrx.node.ElementS');
goog.require('xrx.node.TextS');
goog.require('xrx.stream');
goog.require('xrx.token');



/**
 * @constructor
 */
xrx.nodeS = function(type, token, instance) {
  goog.base(this, type, token, instance);
};
goog.inherits(xrx.nodeS, xrx.node);



/**
 * 
 */
xrx.nodeS.sharedFunctions = function(nodeImpl) {
  var functions = ['backward', 'find', 'forward', 'isSameAs',
                   'isAfter', 'isBefore'];

  for (var i = 0; i < functions.length; i++) {
    var func = functions[i];
    nodeImpl.prototype[func] = xrx.nodeS.prototype[func];
  };
};



/**
 * Indicates whether two nodes are the same.
 *
 * @param {xrx.node} node The node to test against.
 * @return {boolean} Whether the nodes are the same.
 */
xrx.nodeS.prototype.isSameAs = function(node) {
  return this.type() === node.type() && this.label().sameAs(
      node.label()) && this.instance_ === node.instance_;
};



/**
 * Indicates whether a node appears after another node
 * in document order.

 * @param {!xrx.node} node The node to test against.
 * @return {boolean}
 */
xrx.nodeS.prototype.isAfter = function(node) {
  console.log('this');
  console.log(this.label());
  console.log('node');
  console.log(node.label());
  console.log(this.label().isAfter(node.label()));
  console.log(this.type_);
  console.log(node.type());
  return this.type_ >= node.type() && this.label().isAfter(
      node.label());
};



/**
 * Indicates whether a node appears before another node
 * in document order.
 * 
 * @param {!xrx.node} node The node to test against.
 * @return {boolean}
 */
xrx.nodeS.prototype.isBefore = function(node) {
  return this.type_ <= node.type() && this.label().isBefore(
      node.label());
};



/**
 * @override
 */
xrx.nodeS.prototype.expandedName = function() { return ''; };


/**
 * @override
 */
xrx.nodeS.prototype.namespaceUri = function() { return undefined; };



/**
 * @override
 */
xrx.nodeS.prototype.getNodeAncestor = function(test) {

  return this.find(test, xrx.label.prototype.isDescendantOf, true);
};



/**
 * @override
 */
xrx.nodeS.prototype.getNodeAttribute = function(test) {
  var nodeset = new xrx.xpath.NodeSet();
  var stream = new xrx.stream(this.instance_.xml());
  var label = this.label().clone();
  label.child();
  var attribute = new xrx.token.Attribute(label);

  for(;;) {
    var location = stream.attrName(this.token_.xml(stream.xml()), 
        attribute.label().last(), attribute.offset());
    if (!location) break;
    attribute.offset(location.offset);
    attribute.length(location.length);
    var node = new xrx.node.AttributeS(attribute, this, this.instance_)
    if (test.matches(node)) {
      nodeset.add(node);
      break;
    }
    attribute.label().nextSibling();
  }
  return nodeset;
};



/**
 * @override
 */
xrx.nodeS.prototype.getNodeChild = function(test) {

  return this.find(test, xrx.label.prototype.isParentOf);
};



/**
 * Returns the descendants of a node.
 *
 * @return {!xrx.xpath.NodeSet} The node-set with descendants.
 */
xrx.nodeS.prototype.getNodeDescendant = function(test) {

  return this.find(test, xrx.label.prototype.isAncestorOf);
};



/**
 * @override
 */
xrx.nodeS.prototype.getNodeFollowingSibling = function(test) {

  return this.find(test, xrx.label.prototype.isPrecedingSiblingOf);
};



/**
 * @override
 */
xrx.nodeS.prototype.getNodeFollowing = function(test) {

  return this.find(test, xrx.label.prototype.isBefore);
};



/**
 * @override
 */
xrx.nodeS.prototype.getNodeParent = function(test) {

  return this.find(test, xrx.label.prototype.isChildOf, true);
};



/**
 * @override
 */
xrx.nodeS.prototype.getNodePreceding = function(test) {
  // TODO(jochen) implement this
};



/**
 * @override
 */
xrx.nodeS.prototype.getNodePrecedingSibling = function(test) {
  // TODO(jochen) implement this
};



/**
 * @private
 */
xrx.nodeS.prototype.forward = function() {
  var node = this;
  var stream = new xrx.stream(this.instance_.xml());
  var label = node.label().clone();
  var first = true;
  var lastTag;
  if (label.length() === 0) label.child();
  
  stream.rowStartTag = function(offset, length1, length2) {
    if (first) {
      first = false;
    } else if (lastTag === xrx.token.START_TAG) {
      label.child();
    } else {
      label.nextSibling();
    }
    node.nodeElement(new xrx.token.StartEmptyTag(label.clone(), offset, length1));

    if (length1 !== length2) {
      var lbl = label.clone();
      lbl.push0();
      node.nodeText(new xrx.token.NotTag(lbl.clone(), 
          offset + length1, length2 - length1));
    }
    lastTag = xrx.token.START_TAG;
  };
  
  stream.rowEndTag = function(offset, length1, length2) {
    if (lastTag !== xrx.token.START_TAG) label.parent();
    if (length1 !== length2) {
      var lbl = label.clone();
      node.nodeText(new xrx.token.NotTag(lbl.clone(), 
          offset + length1, length2 - length1));
    }
    lastTag = xrx.token.END_TAG;
  };
  
  stream.rowEmptyTag = function(offset, length1, length2) {
    if (first) {
      first = false;
    } else if (lastTag === xrx.token.START_TAG) {
      label.child();
    } else {
      label.nextSibling();
    }
    node.nodeElement(new xrx.token.StartEmptyTag(label.clone(), offset, length1));
    if (length1 !== length2) {
      var lbl = label.clone();
      node.nodeText(new xrx.token.NotTag(lbl.clone(), 
          offset + length1, length2 - length1));
    }
    lastTag = xrx.token.END_TAG;
  };

  stream.forward(node.offset());
};



/**
 * @private
 */
xrx.nodeS.prototype.backward = function() {
  var node = this;
  var stream = new xrx.stream(this.instance_.xml());
  var label = node.label().clone();
  var lastTag = xrx.token.START_TAG;
  
  stream.rowStartTag = function(offset, length1, length2) {
    if (lastTag !== xrx.token.END_TAG) label.parent();
    node.nodeElement(new xrx.token.StartEmptyTag(label.clone(), offset, length1));

    if (length1 !== length2) {
      var lbl = label.clone();
      lbl.push0();
      node.nodeText(new xrx.token.NotTag(lbl.clone(), 
          offset + length1, length2 - length1));
    }
    lastTag = xrx.token.START_TAG;
  };
  
  stream.rowEndTag = function(offset, length1, length2) {
    lastTag === xrx.token.END_TAG ? label.child() : label.precedingSibling();
    if (length1 !== length2) {
      var lbl = label.clone();
      node.nodeText(new xrx.token.NotTag(lbl.clone(), 
          offset + length1, length2 - length1));
    }
    lastTag = xrx.token.END_TAG;
  };
  
  stream.rowEmptyTag = function(offset, length1, length2) {
    lastTag === xrx.token.END_TAG ? label.child() : label.precedingSibling();
    node.nodeElement(new xrx.token.StartEmptyTag(label.clone(), offset, length1));
    if (length1 !== length2) {
      var lbl = label.clone();
      node.nodeText(new xrx.token.NotTag(lbl.clone(), 
          offset + length1, length2 - length1));
    }
    lastTag = xrx.token.START_TAG;
  };
  stream.backward(node.offset());
};



/**
 * @private
 */
xrx.nodeS.prototype.find = function(test, axisTest, reverse) {
  var nodeset = new xrx.xpath.NodeSet();
  var instance = this.instance_;
  var elmnt;

  this.nodeElement = function(token) {
    elmnt = new xrx.node.ElementS(token, instance);
    if (axisTest.call(this.label(), token.label()) && test.matches(elmnt)) {
      reverse ? nodeset.unshift(elmnt) : nodeset.add(elmnt);
    }
  };

  this.nodeText = function(token) {
    var txt = new xrx.node.TextS(token, elmnt, instance);
    if (axisTest.call(this.label(), token.label()) && test.matches(txt)) {
      reverse ? nodeset.unshift(txt) : nodeset.add(txt);
    }
  };
  
  reverse ? this.backward() : this.forward();
  return nodeset;
};
