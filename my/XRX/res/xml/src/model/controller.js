/**
 * @fileoverview A class representing the controller of
 * the model-view-controller.
 */

goog.provide('xrx.controller');


goog.require('xrx.update');



xrx.controller = function() {};



/**
 * 
 */
xrx.controller.update = function(control, update) {
  var node = control.getNode();
  var stream = new xrx.stream(xrx.model.getComponent(node.instance()).xml());
  var token = node.token();

  var diff = xrx.update.notTag(stream, token, update);
  xrx.model.getComponent(node.instance()).xml(stream.xml());
  xrx.controller.valueUpdate(control, diff, update);
};



/**
 * Handles a value update.
 */
xrx.controller.valueUpdate = function(control, diff, update) {
  var node = control.getNode();
  var offset = node.token().offset();

  // Recalculate the Model:
  //   Update the offset of each bind's node which appears
  //   after the updated node's offset (in document order) 
  for (var c in xrx.model.getComponents()) {
    var component = xrx.model.getComponent(c);
    if (component instanceof xrx.bind) {

      var o = component.node.offset();
      if (o > offset) {
        var token = component.node.token();
        token.offset(o += diff);
      }
    }
  }

  // Refresh the View:
  //   Update the value of each control bound to the same node
  //   as the updated node, but not the updated node itself
  for (var c in xrx.view.getComponents()) {
    var contr = xrx.view.getComponent(c);
    if (contr.getNode().sameAs(node) && c != control.getId()) {
      contr.setValue(update, true);
    } else if (control.getNode().label().isDescendantOf(contr.getNode().label()) && c != control.getId() ) {
      contr.refresh();
    }
  }
};



/**
 * Handles a structural update.
 */
xrx.controller.structuralUpdate = function() {
  
};



