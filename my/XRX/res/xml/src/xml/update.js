/**
 * @fileoverview A class implementing low-level update operations 
 * on XML tokens.
 */

goog.provide('xrx.update');



goog.require('xrx.stream');
goog.require('xrx.token');



xrx.update = function(stream, token, string) {
  var diff = string.length - token.length();

  stream.update(token.offset(), token.length(), string);

  token.length(string.length);


  
  return diff;
};


xrx.update.notTag = function(stream, token, value) {

  return xrx.update(stream, token, value);
};



xrx.update.tagName = function(stream, token, name) {

  return xrx.update(stream, token, name);
};



xrx.update.attrValue = function(stream, token, value) {
  
  return xrx.update(stream, token, value);
};
