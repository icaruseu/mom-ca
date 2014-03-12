/**
 * @fileoverview A class representing the tokens of a XML stream.
 */

goog.provide('xrx.token');



goog.require('xrx.label');



/**
 * Base class to construct a new token.
 * This constructor should never be called directly, but
 * by one of the inherited token classes.
 *
 * @constructor
 * @param {!number} type The type of the token.
 * @param {?xrx.label} label The label attached to the token.
 * @param {?number} offset The offset relative to the start of 
 *     the XML stream.
 * @param {?number} length The number of characters occupied 
 *     in the XML stream.
 */
xrx.token = function(type, opt_label, opt_offset, opt_length) {



  /**
   * @private
   */
  this.type_ = type;



  /**
   * @private
   */
  this.label_ = opt_label;



  /**
   * @private
   */
  this.offset_ = opt_offset;



  /**
   * @private
   */
  this.length_ = opt_length;
};



/**
 * Primary tokens
 */
/** @const */ xrx.token.ROOT = 0;
/** @const */ xrx.token.START_TAG = 1;
/** @const */ xrx.token.END_TAG = 2;
/** @const */ xrx.token.EMPTY_TAG = 3;



/**
 * Secondary tokens (part of a tag)
 */
/** @const */ xrx.token.TAG_NAME = 5;
/** @const */ xrx.token.ATTRIBUTE = 6;
/** @const */ xrx.token.ATTR_NAME = 7;
/** @const */ xrx.token.ATTR_VALUE = 8;
/** @const */ xrx.token.NAMESPACE = 9;
/** @const */ xrx.token.NS_PREFIX = 10;
/** @const */ xrx.token.NS_URI = 11;



/**
 * Generic tokens
 */
/** @const */ xrx.token.UNDEFINED = -1;
/** @const */ xrx.token.NOT_TAG = 12;
// either xrx.token.START_TAG or 
// xrx.token.EMPTY_TAG
/** @const */ xrx.token.START_EMPTY_TAG = 4;
// either xrx.token.END_TAG or 
// xrx.token.START_EMPTY_TAG
/** @const */ xrx.token.TAG = 13;



/**
 * Complex tokens
 */
// A selection of sequenced tokens of 
// different type forming a peace of 
// well-formed XML. Corresponds to what 
// a DOM element is.
/** @const */ xrx.token.FRAGMENT = 14; 
// xrx.token.START_TAG plus 
// xrx.token.END_TAG
/** @const */ xrx.token.START_END = 15;
// same as xrx.token.FRAGMENT, but may 
// start and end with xrx.token.NOT_TAG 
// or even may end or start with a part 
// of xrx.token.NOT_TAG
/** @const */ xrx.token.MIXED = 16;

// numbering of tokens is important to 
// compute document order!



/**
 * Converts a generic token into its native form.
 *
 * @param {!xrx.token} token The token to convert.
 * @return {?}
 */
xrx.token.native = function(token) {
  var newToken;
  var label = token.label().clone();
  var offset = token.offset();
  var length = token.length();
  
  var convert = function(constr) {
    var tmp = new constr();
    tmp.label(label);
    tmp.offset(offset);
    tmp.length(length);
    return tmp;
  };
  
  switch(token.type()) {
  case xrx.token.START_TAG:
    newToken = convert(xrx.token.StartTag);
    break;
  case xrx.token.END_TAG:
    newToken = convert(xrx.token.EndTag);
    break;
  case xrx.token.EMPTY_TAG:
    newToken = convert(xrx.token.EmptyTag);
    break;
  case xrx.token.NOT_TAG:
    newToken = convert(xrx.token.NotTag);
    break;
  case xrx.token.TAG_NAME:
    newToken = convert(xrx.token.TagName);
    break;
  case xrx.token.ATTRIBUE:
    newToken = convert(xrx.token.Attribute);
    break;
  case xrx.token.ATTR_NAME:
    newToken = convert(xrx.token.AttrName);
    break;
  case xrx.token.ATTR_VALUE:
    newToken = convert(xrx.token.AttrValue);
    break;
  default:
    throw Error('Token is generic or unknown.');
    break;  
  };
  
  return newToken;
};



/**
 * Compares the generic type of two tokens.
 *
 * @param {!number} type The type to check against.
 * @return {!boolean}
 */
xrx.token.prototype.typeOf = function(type) {
  return this.type_ === type;
};



/**
 * Checks if two tokens are the same. 
 * Note that two tokens are considered as 'the same' 
 * if the types and the labels of the two tokens are 
 * identical. Offset and length do not play any role 
 * for 'sameness'. 
 *
 * @param {!xrx.token} token The token to check against.
 * @return {!boolean}
 */
xrx.token.prototype.sameAs = function(token) {
  return this.typeOf(token.type()) && this.label_.sameAs(token.label());
};



/**
 * See function xrx.token.sameAs(token), but overloading 
 * the type and the label separately.
 *
 * @param {!type} type The type to check against.
 * @param {!label} label The label to check against.
 * @return {!boolean}
 */
xrx.token.prototype.compare = function(type, label) {
  return this.typeOf(type) && this.label_.sameAs(label);
};



/**
 * Indicates whether the token appears before the overloaded
 * token in document-order.
 * 
 * @param {!xrx.token} token The token to compare.
 * @return {!boolean} 
 */
xrx.token.prototype.isBefore = function(token) {
  return this.label_.isBefore(token.label()) || 
      (this.label_.sameAs(token.label()) && this.type_ < token.type());
};



/**
 * Indicates whether the token appears after the overloaded
 * token in document-order.
 * 
 * @param {!xrx.token} token The token to compare.
 * @return {!boolean} 
 */
xrx.token.prototype.isAfter = function(token) {
  return this.label_.isAfter(token.label()) || 
      (this.label_.sameAs(token.label()) && this.type_ > token.type());
};



/**
 * A cumulative setter function for all private members.
 *
 * @param {!number} type The type of the token.
 * @param {!xrx.label} label The label attached to the token.
 * @param {?number} offset The offset relative to the start of the XML stream.
 * @param {?number} length The number of characters in the XML stream.
 */
xrx.token.prototype.set = function(type, label, offset, length) {

  this.type_ = type;
  this.label_ = label;
  this.offset_ = offset;
  this.length_ = length;
};



/**
 * A combined setter and getter function. Optionally sets the
 * type. Returns the type or the new type.
 * 
 * @param {?number} opt_type The value to be set (optional).
 * @return {!number}
 */
xrx.token.prototype.type = function(opt_type) {
  opt_type !== undefined ? this.type_ = opt_type : null;
  return this.type_;
};



/**
 * A combined setter and getter function. Optionally sets the
 * label. Returns the label or the new label.
 * 
 * @param {?number} opt_label The value to be set (optional).
 * @return {!number}
 */
xrx.token.prototype.label = function(opt_label) {
  opt_label !== undefined ? this.label_ = opt_label : null;
  return this.label_;
};



/**
 * A combined setter and getter function. Optionally sets the
 * offset. Returns the offset or the new offset.
 * 
 * @param {?number} opt_offset The value to be set (optional).
 * @return {!number}
 */
xrx.token.prototype.offset = function(opt_offset) {
  opt_offset !== undefined ? this.offset_ = opt_offset : null;
  return this.offset_;
};



/**
 * A combined setter and getter function. Optionally sets the
 * length. Returns the length or the new length.
 * 
 * @param {?number} opt_length The value to be set (optional).
 * @return {!number}
 */
xrx.token.prototype.length = function(opt_length) {
  opt_length !== undefined ? this.length_ = opt_length : null;
  return this.length_;
};



/**
 * Returns the XML string of a token in a XML stream.
 * 
 * @param {!string} stream A XML stream.
 * @return {!string} The token string.
 */
xrx.token.prototype.xml = function(stream) {
  return stream.substr(this.offset_, this.length_);
};
