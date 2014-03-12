/**
 * @fileoverview Abstract class which represents a
 * control of the model-view-controller.
 */

goog.provide('xrx.control');


goog.require('xrx.component');



/**
 * @constructor
 */
xrx.control = function(element) {



  goog.base(this, element);
};
goog.inherits(xrx.control, xrx.component);



/**
 * Gets the bind referenced by the component.
 * @return {?xrx.bind} The bind.
 */
xrx.control.prototype.getNode = function() {
  return this.getBind().node;
};
