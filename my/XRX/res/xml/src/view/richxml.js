/**
 * @fileoverview A user interface component to visually edit 
 * XML Mixed Content like in a Rich Text Editor.
 */

goog.provide('xrx.richxml');


goog.require('goog.dom');
goog.require('xrx.codemirror');
goog.require('xrx.label');
goog.require('xrx.richxml.cursor');
goog.require('xrx.richxml.mode');
goog.require('xrx.richxml.tagname');
goog.require('xrx.stream');
goog.require('xrx.view');



/**
 * @constructor
 */
xrx.richxml = function(element, opt_tagname) {



  goog.base(this, element);



  /**
   * @private
   */
  this.cursor_;



  /**
   * @private
   */
  this.tagname_ = opt_tagname;
};
goog.inherits(xrx.richxml, xrx.codemirror);



xrx.richxml.prototype.cursor = function() {
  return this.cursor_ || new xrx.richxml.cursor(this);
};



xrx.richxml.prototype.tagname = function() {
  return this.tagname_ ? this.tagname_ : this.tagname_ = new xrx.richxml.tagname();
};


xrx.richxml.placeholder = {
  startTag: unescape('%BB'),
  endTag: unescape('%AB'),
  emptyTag: unescape('%D7')
};



xrx.richxml.placeholder.matches = function(ch) {

  for(var p in xrx.richxml.placeholder) {
    if (xrx.richxml.placeholder[p] === ch) {
      return true;
    }
  }
  return false;
};



xrx.richxml.prototype.cursorIsNearTag = function() {
  return xrx.richxml.placeholder.matches(this.cursor().leftTokenOutside().string);
};



xrx.richxml.className = {
  startTag: 'richxml-start-tag',
  startTagActive: 'richxml-start-tag-active',
  endTag: 'richxml-end-tag',
  endTagActive: 'richxml-end-tag-active',
  emptyTag: 'richxml-empty-tag',
  emptyTagActive: 'richxml-empty-tag-active',
  notTag: 'richxml-not-tag',
  notTagActive: 'richxml-not-tag-active'
};



/**
 * @private
 */
xrx.richxml.prototype.transformXml_ = function(xml) {
  var visualXml = '';
  var self = this;
  var stream = new xrx.stream(xml);

  stream.rowStartTag = function(offset, length1, length2) {
    visualXml += xrx.richxml.placeholder.startTag;
    if(length1 !== length2) visualXml += xml.substr(offset + length1, length2 - length1);
  };

  stream.rowEndTag = function(offset, length1, length2) {
    visualXml += xrx.richxml.placeholder.endTag;
    if(length1 !== length2) visualXml += xml.substr(offset + length1, length2 - length1);
  };

  stream.rowEmptyTag = function(offset, length1, length2) {
    visualXml += xrx.richxml.placeholder.emptyTag;
    if(length1 !== length2) visualXml += xml.substr(offset + length1, length2 - length1);
  };

  stream.forward();

  return visualXml;
};



xrx.richxml.prototype.options = {
  'mode': 'richxml'
};



xrx.richxml.prototype.refresh = function() {
  var visualXml = this.transformXml_(this.getNode().xml());
  this.codemirror_.setValue(visualXml);
};



xrx.richxml.prototype.clear = function() {
  this.unmarkActiveTags();
  this.hideElements();
  this.hideAttributes();
  this.hideTagName();
};



xrx.richxml.prototype.unmarkActiveTags = function() {
  this.markActiveTags(true);
};



xrx.richxml.prototype.markActiveTags = function(unmarkflag) {

  var cm = this.codemirror_;
  var cursor = this.cursor();
  var self = this;
  
  var markedElements = function() { 
    return self.markedElements_ || (self.markedElements_ = []); 
  };

  var correspondingTag = function() {
    var text = cm.getValue();
    var index = cm.indexFromPos(cm.getCursor()) - 1;
    var ch;
    var stack = 0;

    if(cursor.leftTokenOutside().string === xrx.richxml.placeholder.startTag) {

      for(var i = index; i < text.length; i++) {
        ch = text[i];
        if(ch === xrx.richxml.placeholder.endTag) stack -= 1;
        if(ch === xrx.richxml.placeholder.startTag) stack += 1;
        if(stack === 0) {
          index = i + 1;
          break;
        } 
      }
    } else if(cursor.leftTokenOutside().string === xrx.richxml.placeholder.endTag) {

      for(var i = index; i >= 0; i--) {
        ch = text[i];
        if(ch == xrx.richxml.placeholder.endTag) stack += 1;
        if(ch == xrx.richxml.placeholder.startTag) stack -= 1;
        if(stack == 0) {
          index = i + 1;
          break;
        } 
      }
    } else {};

    return cm.posFromIndex(index);
  };
  
  var mark = function(from, to, style) {
    var mark = cm.markText(from, to, style);

    markedElements().push(mark);
  };
  
  var unmark = function() {

    for(var i = 0; i < markedElements().length; ++i) {
      markedElements()[i].clear();
    }
    self.markedElements_ = [];
  };

  unmark();
  if (!this.cursorIsNearTag()) return;
  if (unmarkflag) return;

  var firstMark = cursor.leftTokenOutside().string === xrx.richxml.placeholder.startTag ? 
      xrx.richxml.className.startTagActive : xrx.richxml.className.endTagActive;
  var secondMark = cursor.leftTokenOutside().string === xrx.richxml.placeholder.startTag ? 
      xrx.richxml.className.endTagActive : xrx.richxml.className.startTagActive;

  // mark matched element
  mark(
      { line: cursor.leftPosition().line, ch: cursor.leftPosition().ch - 1 }, 
      { line: cursor.leftPosition().line, ch: cursor.leftPosition().ch }, 
      { className: firstMark }
  );
  
  if (cursor.leftTokenOutside().string === xrx.richxml.placeholder.emptyTag) return;
  
  // mark corresponding element
  var corresponding = correspondingTag();
  mark(
      { line: corresponding.line, ch: corresponding.ch - 1 },
      { line: corresponding.line, ch: corresponding.ch },
      { className: secondMark }
  );
  
  // mark text
  var from = { line: cursor.leftPosition().line, ch: cursor.leftPosition().ch };
  var to = { line: corresponding.line, ch: corresponding.ch - 1 };
  cursor.leftTokenOutside().string === xrx.richxml.placeholder.startTag ? 
      mark(from, to, { className: xrx.richxml.className.notTagActive }) : 
      mark(to, from, { className: xrx.richxml.className.notTagActive });
};



xrx.richxml.prototype.showElements = function() {
  
};



xrx.richxml.prototype.hideElements = function() {
  
};



xrx.richxml.prototype.showAttributes = function() {
  
};



xrx.richxml.prototype.hideAttributes = function() {
  
};



xrx.richxml.prototype.showTagName = function() {
  this.cursorIsNearTag() ? this.tagname().show(this.cursor().getNode()) : 
      this.hideTagName();
};



xrx.richxml.prototype.hideTagName = function() {
  this.tagname().hide();
};



xrx.richxml.prototype.setReadonly = function(readonly) {
  readonly ? this.codemirror_.setOption('readOnly', true) : 
      this.codemirror_.setOption('readOnly', false);
};



xrx.richxml.prototype.eventBlur = function() {
  this.clear();
};



xrx.richxml.prototype.cursorActivitySelection = function() {
  var cm = this.codemirror_;
  var cursor = this.cursor();
  var valid = false;

  if(cursor.leftAtStartPosition() || cursor.rightAtEndPosition()) return;

  var leftTokenOutside = cursor.leftTokenOutside().state.context.token;
  var rightTokenInside = cursor.rightTokenInside().state.context.token;
  var leftToken
  var rightToken
};



/**
 * 
 */
xrx.richxml.prototype.eventCursorActivity = function() {
  var cm = this.codemirror_;

  if (cm.somethingSelected()) {
    this.setReadonly(true);
    this.cursorActivitySelection();
  } else {
    this.setReadonly(false);
    this.markActiveTags();
    this.showElements();
    this.showAttributes();
    this.showTagName();
  }
};





