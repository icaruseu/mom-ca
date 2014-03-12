goog.provide('xrx.richxml.cursor');



goog.require('xrx.richxml');



/**
 * @constructor
 */
xrx.richxml.cursor = function(richxml) {




  this.richxml_ = richxml;



  this.codemirror_ = richxml.codemirror_;
};



xrx.richxml.cursor.prototype.getNode = function() {
  return this.richxml_.getNode();
};



xrx.richxml.cursor.prototype.leftIndex = function() {
  return this.codemirror_.indexFromPos(this.leftPosition());
};



xrx.richxml.cursor.prototype.leftPosition = function() {
  return this.codemirror_.getCursor(true);
};



xrx.richxml.cursor.prototype.leftTokenInside = function() {
  var cm = this.codemirror_;
  return cm.getTokenAt(cm.posFromIndex(this.leftIndex() + 1));
};



xrx.richxml.cursor.prototype.leftTokenOutside = function() {
  return this.codemirror_.getTokenAt(this.leftPosition());
};



xrx.richxml.cursor.prototype.leftPlace = function() {
  
};



xrx.richxml.cursor.prototype.leftAtStartPosition = function() {
  
};



xrx.richxml.cursor.prototype.leftAtEndPosition = function() {
  
};



xrx.richxml.cursor.prototype.rightIndex = function() {
  
};



xrx.richxml.cursor.prototype.rightPosition = function() {
  
};



xrx.richxml.cursor.prototype.rightTokenInside = function() {
  
};



xrx.richxml.cursor.prototype.rightTokenOutside = function() {
  
};



xrx.richxml.cursor.prototype.rightPlace = function() {
  
};



xrx.richxml.cursor.prototype.rightAtStartPosition = function() {
  
};



xrx.richxml.cursor.prototype.rightAtEndPosition = function() {
  
};
