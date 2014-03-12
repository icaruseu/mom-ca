/**
 * @fileoverview A class which represents the model of 
 * the model-view-controller.
 */

goog.provide('xrx.model');



goog.require('xrx.component');



/**
 * @constructor
 */
xrx.model = function(element) {



  goog.base(this, element);



  this.element_ = element;
  


  this.recalculate();
};
goog.inherits(xrx.model, xrx.component);



xrx.model.prototype.recalculate = goog.abstractMethod;



xrx.model.classes = [
  'xrx-instance',
  'xrx-bind'
];



xrx.model.components_ = {};



xrx.model.addComponent = function(id, component) {
  xrx.model.components_[id] = component;
};



xrx.model.getComponent = function(id) {
  return xrx.model.components_[id];
};



xrx.model.getComponents = function() {
  return xrx.model.components_;
};



xrx.model.cursor = {};



xrx.model.cursor.node_ = [];



xrx.model.cursor.setNodes = function(nodes) {
  var n = xrx.model.cursor.node_;
  n.splice(0, n.length);

  for (var i = 0, len = nodes.length; i < len; i++) {
    n[i] = nodes[i];
  }
};



xrx.model.cursor.getNode = function(pos) {
  return xrx.model.cursor.node_[pos];
};

