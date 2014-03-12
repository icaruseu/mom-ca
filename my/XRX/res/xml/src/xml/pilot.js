/**
 * @fileoverview A class representing a pilot to traverse the 
 * tokens of a XML tree.
 */

goog.provide('xrx.pilot');



goog.require('xrx.label');
goog.require('xrx.stream');
goog.require('xrx.token');
goog.require('xrx.token.Attribute');
goog.require('xrx.token.AttrName');
goog.require('xrx.token.AttrValue');
goog.require('xrx.token.EmptyTag');
goog.require('xrx.token.EndTag');
goog.require('xrx.token.Namespace');
goog.require('xrx.token.NotTag');
goog.require('xrx.token.NsPrefix');
goog.require('xrx.token.NsUri');
goog.require('xrx.token.Root');
goog.require('xrx.token.StartEmptyTag');
goog.require('xrx.token.StartTag');
goog.require('xrx.token.Tag');
goog.require('xrx.token.TagName');



/**
 * Constructs a new pilot. A pilot is able to traverse a XML tree
 * in forward and backward direction.
 * 
 * @param {!string} xml A XML string. 
 * @constructor
 */
xrx.pilot = function(xml) {


  /**
   * Initialize the XML stream.
   * 
   * @type {xrx.stream}
   * @private
   */
  this.stream_ = new xrx.stream(xml);



  /**
   * Path lastly used to traverse the XML tree 
   * (for debugging only).
   * 
   * @param {}
   * @private
   */
  this.currentPath_;
};


xrx.pilot.prototype.stream = function() {
  return this.stream_;
};


/**
 * Returns the path lastly used to traverse the XML tree 
 * (for debugging only).
 * @return {?}
 */
xrx.pilot.prototype.currentPath = function() {
  return this.currentPath_;
};



/**
 * Returns a token string or the content of the XML stream.
 * @return {!string}
 */
xrx.pilot.prototype.xml = function(token) {
  return token === undefined ? this.stream_.xml() : 
    this.stream_.xml().substr(token.offset(), token.length());
};



/**
 * Stops the XML stream.
 * @private
 */
xrx.pilot.prototype.stop = function() {
  this.stream_.stop();
};



/**
 * Forward tree traversing.
 * 
 * @param {?} target The target token.
 */
xrx.pilot.prototype.forward = function(context, target) {
  var tok, startAt = 0;
  var pilot = this;
  var label; 
  if(context === null) {
    label = new xrx.label();
  } else {
    label = context.label().clone();
    label.precedingSibling();
    startAt = context.offset();
  }
  var lastTag = context ? xrx.token.NOT_TAG : xrx.token.UNDEFINED;

  pilot.stream_.rowStartTag = function(offset, length1, length2) {
    lastTag === xrx.token.UNDEFINED || lastTag === xrx.token.START_TAG ? label.child() : label.nextSibling();
    
    var tmp;
    if (target.type() === xrx.token.NOT_TAG) {
      tmp = label.clone();
      tmp.push0();
    }

    if (target.compare(xrx.token.START_TAG, label)) {
      tok = new xrx.token.StartTag(label.clone());
      tok.offset(offset);
      tok.length(length1);
      pilot.stop();
    } else if (target.compare(xrx.token.NOT_TAG, tmp)) {
      tok = new xrx.token.NotTag(tmp);
      tok.offset(offset + length1);
      tok.length(length2 - length1);
      pilot.stop();
    } else {}
    lastTag = xrx.token.START_TAG;
  };
  
  pilot.stream_.rowEndTag = function(offset, length1, length2) {
    lastTag === xrx.token.START_TAG ? null : label.parent();
    if (target.compare(xrx.token.END_TAG, label)) {
      tok = new xrx.token.EndTag(label.clone());
      tok.offset(offset);
      tok.length(length1);
      pilot.stop();
    } else if (target.compare(xrx.token.NOT_TAG, label)) {
      tok = new xrx.token.NotTag(label);
      tok.offset(offset + length1);
      tok.length(length2 - length1);
      pilot.stop();
    } else {}
    lastTag = xrx.token.END_TAG;
  };
  
  pilot.stream_.rowEmptyTag = function(offset, length1, length2) {
    lastTag === xrx.token.UNDEFINED || lastTag === xrx.token.START_TAG ? label.child() : label.nextSibling();    
    if (target.compare(xrx.token.EMPTY_TAG, label)) {
      tok = new xrx.token.EmptyTag(label.clone());
      tok.offset(offset);
      tok.length(length1);
      pilot.stop();
    } else if (target.compare(xrx.token.NOT_TAG, label)) {
      tok = new xrx.token.NotTag(label);
      tok.offset(offset + length1);
      tok.length(length2 - length1);
      pilot.stop();
    } else {}
    lastTag = xrx.token.END_TAG;
  };
  
  pilot.stream_.forward(startAt);

  return tok;
};



/**
 * Backward tree traversing.
 * 
 * @param {?} target The target token.
 */
xrx.pilot.prototype.backward = function(context, target) {
  var tok, startAt = 0;
  var pilot = this;
  var label; 
  if (context === null) {
    label = new xrx.label();
  } else {
    label = context.label().clone();
    startAt = context.offset();
  }
  var lastTag = xrx.token.START_TAG;
  
  pilot.stream_.rowStartTag = function(offset, length1, length2) {
    lastTag === xrx.token.END_TAG ? null : label.parent();
    if (target.compare(xrx.token.START_TAG, label)) {
      tok = new xrx.token.StartTag(label.clone());
      tok.offset(offset);
      tok.length(length1);
      pilot.stop();
    }
    lastTag = xrx.token.START_TAG;
  };
  
  pilot.stream_.rowEndTag = function(offset, length1, length2) {
    lastTag === xrx.token.UNDEFINED || lastTag === xrx.token.END_TAG ?
        label.child() : label.precedingSibling();
    if (target.compare(xrx.token.END_TAG, label)) {
      tok = new xrx.token.EndTag(label.clone());
      tok.offset(offset);
      tok.length(length1);
      pilot.stop();
    }
    lastTag = xrx.token.END_TAG;
  };
  
  pilot.stream_.rowEmptyTag = function(offset, length1, length2) {
    lastTag === xrx.token.UNDEFINED || lastTag === xrx.token.END_TAG ?
        label.child() : label.precedingSibling();
    if (target.compare(xrx.token.EMPTY_TAG, label)) {
      tok = new xrx.token.EmptyTag(label.clone());
      tok.offset(offset);
      tok.length(length1);
      pilot.stop();
    }
    lastTag = xrx.token.START_TAG;
  };
  
  pilot.stream_.rowNotTag = function(offset, length1, length2) {
    // not used for backward streams
  };

  pilot.stream_.backward(startAt);

  return tok;
};



/**
 * Returns the joint parent of two tags.
 * 
 * @private
 * @param {!xrx.token.StartEmptyTag} tag The overloaded tag.
 * @return {!xrx.token.StartEmptyTag}
 */
xrx.pilot.prototype.jointParent = function(context, tag) {
  var label = context.label().jointParent(tag.label());

  return new xrx.token.StartEmptyTag(label);
};



/**
 * Helper function for xrx.pilot.prototype.path.
 * 
 * @private
 * @param {!xrx.token.StartEmptyTag} tag The target tag.
 * @return {!xrx.token.StartEmptyTag}
 */
xrx.pilot.prototype.onLocation = function(tag) {
  return tag;
};


/**
 * Helper function for xrx.pilot.prototype.path.
 * 
 * @private
 * @param {!xrx.token.StartEmptyTag} tag The target tag.
 * @return {!xrx.token.StartEmptyTag}
 */
xrx.pilot.prototype.zigzag = function(context, tag) {

  // we first traverse to the joint parent tag
  var jointParent = this.backward(context, this.jointParent(context, tag));
  
  // then we've (a) already found the target tag or (b) we 
  // stream forward. We can use xrx.pilot.path short hand for 
  // (a) and (b).
  return this.path(jointParent, tag);
};


/**
 * 
 */
xrx.pilot.prototype.path = function(context, tag) {

  if (context === null) {
    return this.forward(context, tag);
  } else if (context.sameAs(tag)) {
    // context is already at the right place?
    // => return tag
    this.currentPath_ = 'xrx.pilot.prototype.onLocation';
    return this.onLocation(tag);
  } else if (context.isBefore(tag)) {
    // context is placed before the target tag?
    // => stream forward
    this.currentPath_ = 'xrx.pilot.prototype.forward';
    return this.forward(context, tag);
  } else {
    // context is placed after the target tag?
    // => zigzag course
    var zigzag = this.zigzag(context, tag);
    this.currentPath_ = 'xrx.pilot.prototype.zigzag';
    return zigzag;
  }
};



/**
 * Returns the location of a token.
 * @return {?}
 */
xrx.pilot.prototype.location = function(opt_context, target) {
  return this.update(opt_context, target);
};



/**
 * Updates a token and returns its location.
 */
xrx.pilot.prototype.update = function(context, target, update) {
  var token;
  
  switch(target.type()) {
  // primary tokens
  case xrx.token.START_TAG:
    token = this.startTag(context, target, update);
    break;
  case xrx.token.END_TAG:
    token = this.endTag(context, target, update);
    break;
  case xrx.token.EMPTY_TAG:
    token = this.emptyTag(context, target, update);
    break;
  case xrx.token.NOT_TAG:
    token = this.notTag(context, target, update);
    break;
  // secondary tokens
  case xrx.token.TAG_NAME:
    throw Error('Not supported. Use function xrx.pilot.tagName instead.');
    break;
  case xrx.token.ATTRIBUTE:
    token = this.attribute(context, target, update);
    break;
  case xrx.token.ATTR_NAME:
    token = this.attrName(context, target, update);
    break;
  case xrx.token.ATTR_VALUE:
    token = this.attrValue(context, target, update);
    break;
  // generic tokens
  case xrx.token.START_EMPTY_TAG:
    token = this.startEmptyTag(context, target, update);
    break;
  // TODO: complex tokens 
  default:
    throw Error('Unknown type.');
    break;
  }
  return token;
};



/**
 * 
 */
xrx.pilot.prototype.startTag = function(context, target, opt_update) {
  var startTag = this.path(context, target);

  return startTag;
};



/**
 * 
 */
xrx.pilot.prototype.endTag = function(context, target, opt_update) {
  var endTag = this.path(context, target);

  return endTag;
};



/**
 * 
 */
xrx.pilot.prototype.emptyTag = function(context, target, opt_update) {
  var emptyTag = this.path(context, target);

  return emptyTag;
};


/**
 * Shared utility function for all secondary tokens.
 * @private
 */
xrx.pilot.prototype.secondaryToken_ = function(context, target, streamFunc, tokenConstr) {

  
  return token;
};



/**
 * Get the location and optionally update a xrx.token.TagName.
 * 
 * @param {?} context
 * @param {(!xrx.token.StartTag|!xrx.token.EndTag|!xrx.token.EmptyTag
 * |!xrx.token.StartEmptyTag|!xrx.token.Tag)} target The tag to which 
 * the tag-name belongs. 
 * @param {?string} opt_update The new tag-name.
 * @return {!xrx.token.TagName}
 */
xrx.pilot.prototype.tagName = function(context, target, opt_update) {
  var pos = this.stream_.pos();
  var tag = this.path(context, target);
  var xml = this.stream_.xml().substr(tag.offset(), tag.length());
  var location = this.stream_.tagName(xml);
  var tagName = new xrx.token.TagName(tag.label().clone(), 
      location.offset + tag.offset(), location.length);
  
  // reset the stream reader position, important!
  this.stream_.pos(pos);

  return !opt_update ? tagName : 
      xrx.update.tagName(this.stream_, tagName, opt_update);
};



/**
 * Get the location and optionally update a xrx.token.Attribute.
 * 
 * @param {?} context
 * @param {!xrx.token.Attribute} target The attribute token.
 * @param {?string} opt_update The new attribute.
 * @return {!xrx.token.Attribute}
 */
xrx.pilot.prototype.attribute = function(context, target, opt_update) {
  var pos = this.stream_.pos();
  var tag = this.path(context, target.tag());
  var xml = this.stream_.xml().substr(tag.offset(), tag.length());
  var location = this.stream_.attribute(xml, target.label().last());
  var attribute = new xrx.token.Attribute(target.label().clone(), 
      location.offset + tag.offset(), location.length);
  
  // reset the stream reader position, important!
  this.stream_.pos(pos);
  
  return !opt_update ? attribute :
      xrx.update.attribute(this.stream_, attribute, opt_update);
};



/**
 * Get the location and optionally update a xrx.token.AttrName.
 * 
 * @param {?} context
 * @param {!xrx.token.AttrName} target The attribute-name token.
 * @param {?string} opt_update The new attribute-name.
 * @return {!xrx.token.AttrName}
 */
xrx.pilot.prototype.attrName = function(context, target, opt_update) {
  var pos = this.stream_.pos();
  var tag = this.path(context, target.tag());
  var xml = this.stream_.xml().substr(tag.offset(), tag.length());
  var location = this.stream_.attrName(xml, target.label().last());
  var attrName = new xrx.token.AttrName(target.label().clone(), 
      location.offset + tag.offset(), location.length);
  
  // reset the stream reader position, important!
  this.stream_.pos(pos);

  return opt_update === undefined ? attrName :
      xrx.update.attrName(this.stream_, attrName, opt_update);  
};



/**
 * Get the location and optionally update a xrx.token.AttrValue.
 * 
 * @param {?} context
 * @param {!xrx.token.AttrValue} target The attribute-value token.
 * @param {?string} opt_update The new attribute-value.
 * @return {!xrx.token.AttrValue}
 */
xrx.pilot.prototype.attrValue = function(context, target, opt_update) {
  var pos = this.stream_.pos();
  var tag = this.path(context, target.tag());
  var xml = this.stream_.xml().substr(tag.offset(), tag.length());
  var location = this.stream_.attrValue(xml, target.label().last());
  var attrValue = new xrx.token.AttrValue(target.label().clone(), 
      location.offset + tag.offset(), location.length);
  
  // reset the stream reader position, important!
  this.stream_.pos(pos);  

  return opt_update === undefined ? attrValue :
      xrx.update.attrValue(this.stream_, attrValue, opt_update);
};



/**
 * Get the location and optionally update a xrx.token.NotTag.
 * 
 * @param {?} context
 * @param {!xrx.token.NotTag} target The not-tag token.
 * @param {?string} opt_update The new not-tag.
 * @return {!xrx.token.NotTag}
 */
xrx.pilot.prototype.notTag = function(context, target, opt_update) {
  var notTag = this.path(context, target);

  return opt_update === undefined ? notTag :
      xrx.update.notTag(this.stream_, notTag, opt_update);
};



xrx.pilot.prototype.startEmptyTag = function(context, target, opt_update) {
  var startEmptyTag = this.path(context, target);

  return opt_update === undefined ? startEmptyTag :
      xrx.update.startEmptyTag(this.stream_, startEmptyTag, opt_update);
};



xrx.pilot.prototype.tag = function(context, target, opt_update) {
  
};


/**
 * Get or update an array of xrx.token.Attribute.
 * 
 * @param {?} context
 * @param {!xrx.token.StartEmptyTag} target The start-empty tag.
 * @param {?Array.<xrx.token.Attribute>} opt_update Array of new attribute tokens.
 * @return {!Array.<xrx.token.Attribute>}
 */
xrx.pilot.prototype.attributes = function(context, target, opt_update) {
  var pos = this.stream_.pos();
  var tag = this.path(context, target);
  var xml = this.stream_.xml().substr(tag.offset(), tag.length());
  var locations = this.stream_.attributes(xml);
  var attributes = [];
  var label = target.label().clone();
  label.child();
  for (var pos in locations) {
    var location = locations[pos];
    attributes.push(new xrx.token.Attribute(label.clone(),
        location.offset + tag.offset(), location.length));
    label.nextSibling();
  }
  
  // reset the stream reader position, important!
  this.stream_.pos(pos); 
  console.log(attributes);
  return opt_update === undefined ? attributes : 
      xrx.update.attributes(this.stream_, attributes, opt_update);
};
