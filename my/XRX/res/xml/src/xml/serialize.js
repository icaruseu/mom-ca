/**
 * @fileoverview Class for XML serialization.
 */

goog.provide('xrx.serialize');


goog.require('xrx.stream');
goog.require('xrx.token');



xrx.serialize = {};



xrx.serialize.indent = function(xml, indent) {
  var stream = new xrx.stream(xml);
  var level = 0;
  var lastRow = xrx.token.UNDEFINED;
  var lastToken = xrx.token.UNDEFINED;
  var output = '';
  
  var newLine = function(offset, length1, length2) {
    for(var i = 0, ind = level * indent; i < ind; i++) {
      output += ' ';
    }
    output += stream.xml().substr(offset, length1);
    if (length1 !== length2) {
      output += stream.xml().substr(offset + length1, length2 - length1);
    }
  };
  
  stream.rowStartTag = function(offset, length1, length2) {
    if (lastRow === xrx.token.START_TAG) level += 1;
    if (lastToken === xrx.token.START_TAG || lastToken === xrx.token.EMPTY_TAG) output += '\n';
    newLine(offset, length1, length2);
    lastRow = xrx.token.START_TAG;
    length1 !== length2 ? lastToken = xrx.token.NOT_TAG : 
        lastToken = xrx.token.START_TAG;
  };
  
  stream.rowEmptyTag = function(offset, length1, length2) {
    if(lastRow === xrx.token.START_TAG) level += 1;
    newLine(offset, length1, length2);
    lastRow = xrx.token.END_TAG;
    length1 !== length2 ? lastToken = xrx.token.NOT_TAG : 
      lastToken = xrx.token.EMPTY_TAG;
  };
  
  stream.rowEndTag = function(offset, length1, length2) {
    if (lastRow !== xrx.token.START_TAG) level -= 1;
    output += stream.xml().substr(offset, length1);
    if (level !== 0) output += '\n';
    lastRow = xrx.token.END_TAG;
    length1 !== length2 ? lastToken = xrx.token.NOT_TAG : 
      lastToken = xrx.token.END_TAG;
  };
  
  stream.forward();
  
  return output;
};
