/**
 * @fileoverview Helper class for class xrx.stream.
 */

goog.provide('xrx.reader');



xrx.reader = function(input) {



  this.input_ = input || '';



  this.pos_ = 0;



  this.length_ = input.length;
};



xrx.reader.prototype.first = function() {

  this.pos_ = 0;
};



xrx.reader.prototype.last = function() {

  this.pos_ = this.length_ - 1;
};



xrx.reader.prototype.set = function(pos) {

  this.pos_ = pos || 0;
};



xrx.reader.prototype.get = function() {

  return this.input_.charAt(this.pos_);
};



xrx.reader.prototype.input = function(xml) {
  
  xml ? this.input_ = xml : null;
  return this.input_;
};



xrx.reader.prototype.pos = function() {

  return this.pos_;
};



xrx.reader.prototype.length = function() {

  return this.length_;
};



xrx.reader.prototype.finished = function() {

  return this.pos_ < 0 || this.pos_ > this.length_ ? true : false;
};



xrx.reader.prototype.next = function() {

  return this.input_.charAt(this.pos_++);
};



xrx.reader.prototype.previous = function() {

  return this.input_.charAt(this.pos_--);
};



xrx.reader.prototype.peek = function(i) {

  return this.input_.charAt(this.pos_ + (i || 0));
};



xrx.reader.prototype.forward = function(i) {

  this.pos_ += (i || 0);
};



xrx.reader.prototype.backward = function(i) {

  this.pos_ -= (i || 0);
};



xrx.reader.prototype.forwardInclusive = function(ch) {
  var i;

  for (i = 0;; i++) {
    if (this.peek(i) === ch) break;
  }
  this.forward(++i);
};



xrx.reader.prototype.forwardExclusive = function(ch) {
  var i;

  for (i = 0;; i++) {
    if (this.peek(i) === ch) break;
  }
  this.forward(i);
};



xrx.reader.prototype.backwardInclusive = function(ch) {
  var i;

  for (i = 0;; i++) {
    if (this.peek(-i) === ch) break;
  }
  this.backward(i);
};



xrx.reader.prototype.backwardExclusive = function(ch) {
  var i;

  for (i = 0;; i++) {
    if (this.peek(-i) === ch) break;
  }
  this.backward(--i);
};
