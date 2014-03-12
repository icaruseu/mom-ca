/**
 * @fileoverview A class which represents the location of a token 
 * in a XML stream.
 */

goog.provide('xrx.location');



/**
 * A class representing the location of a token in a XML 
 * stream.
 * 
 * @param {!number} offset The offset.
 * @param {!number} length The number of characters occupied.
 * @constructor
 */
xrx.location = function(offset, length) {



  this.offset = offset;



  this.length = length;
};



/**
 * Returns the XML string of the location in a
 * XML stream.
 * 
 * @param {!string} stream The XML stream.
 * @return {!string} The XML string occupied by the location
 */
xrx.location.prototype.xml = function(stream) {
  return stream.substr(this.offset, this.length);
};