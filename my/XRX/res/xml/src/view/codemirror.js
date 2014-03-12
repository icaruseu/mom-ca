/**
 * @fileoverview A utility class which provides common functions for 
 * all controls that use CodeMirror.
 */

goog.provide('xrx.codemirror');


goog.require('xrx.model');
goog.require('xrx.view');



/**
 * @constructor
 */
xrx.codemirror = function(element) {



  /**
   * Call constructor of class xrx.view
   * @param {!xrx.codemirror}
   * @param {Element}
   */
  goog.base(this, element);



  this.codemirror_;



  this.internalUpdate = false;



  this.setOptions();
};
goog.inherits(xrx.codemirror, xrx.view);



xrx.codemirror.prototype.setOptions = function() {

  for(var opt in this.options) {
    this.codemirror_.setOption(opt, this.options[opt]);
  }
};


/**
 * 
 */
xrx.codemirror.prototype.createDom = function() {
  var self = this;

  var cm = this.codemirror_ = window.CodeMirror.fromTextArea(this.element_);

  cm.on('beforeChange', function(cm, change) { self.eventBeforeChange(cm, change); });
  cm.on('blur', function(cm, change) { self.eventBlur(); });
  cm.on('cursorActivity', function() { self.eventCursorActivity(); });
  cm.on('focus', function() { self.eventFocus(); });
};



/**
 * 
 */
xrx.codemirror.prototype.eventBeforeChange = function(cm, change) {

  if (this.internalUpdate === false) {
    var doc = this.codemirror_.getDoc().copy();
    doc.replaceRange(change.text.join('\n'), change.from, change.to);

    xrx.controller.update(this, doc.getValue());
  }
};



/**
 * 
 */
xrx.codemirror.prototype.eventFocus = function()  {
  var arr = new Array(1);
  arr[0] = this.getNode();
  xrx.model.cursor.setNodes(arr);
};




xrx.codemirror.prototype.setFocus = function() {
  this.codemirror_.focus();
};



xrx.codemirror.prototype.getValue = function() {
  return this.codemirror_.getValue();
};



xrx.codemirror.prototype.setValue = function(xml, internal) {
  this.internalUpdate = internal || false;
  this.codemirror_.setValue(xml);
  this.codemirror_.refresh();
  this.internalUpdate = false;
};



/**
 * 
 */
xrx.codemirror.prototype.refresh = function() {
  var xml = this.getNode().xml();

  this.setValue(xml, true);
};
