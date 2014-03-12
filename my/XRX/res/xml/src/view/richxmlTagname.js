/**
 * @fileoverview A tag-name UI component used by xrx.richxml.
 */
goog.provide('xrx.richxml.tagname');



goog.require('goog.dom');
goog.require('goog.style');
goog.require('xrx.i18n');
goog.require('xrx.richxml');



/**
 * Constructs a tag-name UI component.s
 * The tag-name is shown when the cursor moves near to a 
 * tag in a xrx.richxml component.
 * @constructor
 */
xrx.richxml.tagname = function(element)  {



  this.element_ = element;



  this.createDom();
};



/**
 * Lazy creation. We first search for a element with
 * id 'xrx-tagname'. If not found, we create a DIV and
 * append it to HTML BODY.
 */
xrx.richxml.tagname.prototype.createDom = function() {

  if (!this.element_) {
    this.element_ = goog.dom.getElement('xrx-tagname');
  }
  if (!this.element_) {
    this.element_ = goog.dom.createElement('div');
    goog.dom.append(goog.dom.getElementsByTagNameAndClass('body')[0],
        this.element_);
  }
};



/**
 * Shows the tag-name control.
 * @param {!xrx.node.Element}
 */
xrx.richxml.tagname.prototype.show = function(node) {
  var span = goog.dom.createElement('span');
  var text = xrx.i18n.translate(node);
  goog.dom.setTextContent(span, text);

  this.hide();
  goog.dom.append(this.element_, span);
};



/**
 * Hides the tag-name control.
 */
xrx.richxml.tagname.prototype.hide = function() {
  goog.dom.removeChildren(this.element_);
};
