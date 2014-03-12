/**
 * @fileoverview A class which represents the view of 
 * the model-view-controller.
 */

goog.provide('xrx.view');


goog.require('goog.string');
goog.require('xrx.control');



/**
 * @constructor
 */
xrx.view = function(element) {



  goog.base(this, element);



  this.createDom();



  this.refresh();
};
goog.inherits(xrx.view, xrx.control);



xrx.view.prototype.eventBeforeChange = goog.abstractMethod;



xrx.view.prototype.eventFocus = goog.abstractMethod;



xrx.view.prototype.getValue = goog.abstractMethod;



xrx.view.prototype.setFocus = goog.abstractMethod;



xrx.view.prototype.refresh = goog.abstractMethod;



xrx.view.classes = [
  'xrx-console',
  'xrx-input',
  'xrx-output',
  'xrx-textarea',
  'xrx-richxml',
  'xrx-richxml-tagname'
];



xrx.view.addClass = function(name) {

  if (goog.string.startsWith(name, 'xrx-')) {
    throw Error('Class names starting with "xrx-" are reserved' +
        'for built-in components.');
  }
  xrx.view.classes.push(name);
};


xrx.view.components_ = {};



xrx.view.addComponent = function(id, component) {
  xrx.view.components_[id] = component;
};



xrx.view.getComponent = function(id) {
  return xrx.view.components_[id];
};



xrx.view.getComponents = function() {
  return xrx.view.components_;
};


