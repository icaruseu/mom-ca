


goog.provide('xrx.tree');


goog.require('xrx.stream');
goog.require('xrx.label');


xrx.tree = function(xml) {



  this.stream_ = new xrx.stream(xml);
};



xrx.tree.prototype.namespace = goog.abstractMethod;



xrx.tree.prototype.rowStartTag = goog.abstractMethod;



xrx.tree.prototype.rowEmptyTag = goog.abstractMethod;



xrx.tree.prototype.rowEndTag = goog.abstractMethod;



xrx.tree.prototype.forward = function() {
  var tree = this;
  var label = new xrx.label();
  var lastTag;

  this.stream_.namespace = function(offset, length1, length2) {
    tree.namespace(label.clone());
  };

  this.stream_.rowStartTag = function(offset, length1, length2) {
    !lastTag || lastTag === xrx.token.START_TAG ? label.child() : label.nextSibling();
    tree.rowStartTag(label.clone(), offset, length1, length2);
    lastTag = xrx.token.START_TAG;
  };

  this.stream_.rowEmptyTag = function(offset, length1, length2) {
    !lastTag || lastTag === xrx.token.START_TAG ? label.child() : label.nextSibling();
    tree.rowEmptyTag(label.clone(), offset, length1, length2);
    lastTag = xrx.token.END_TAG;
  };

  this.stream_.rowEndTag = function(offset, length1, length2) {
    if (lastTag !== xrx.token.START_TAG) label.parent();
    tree.rowEndTag(label.clone(), offset, length1, length2);
    lastTag = xrx.token.END_TAG;
  };
  
  this.stream_.forward();
};
