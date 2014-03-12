/**
 * @fileoverview A class to stream over XML documents or XML
 * fragments.
 */

goog.provide('xrx.stream');



goog.require('goog.string');
goog.require('xrx.location');
goog.require('xrx.reader');
goog.require('xrx.token');



/**
 * A class to stream over XML documents or XML fragments.
 * <br/>
 * <br/>
 * <b>IMPORTANT NOTE: This class represents a XML streamer and not a 
 *   XML parser! The streamer is different from a XML parser in the 
 *   following respects:</b>
 * <br/>
 * <br/>  
 * <li>the XML input document or fragment must be well-formed before 
 *   streaming starts. The streamer itself does not do any well-formed 
 *   checks
 * <li>the streamer expects the XML document or fragment serialized 
 *   as a string
 * <li>the string must be encoded in UTF-8
 * <li>whitespace must already be normalized and collapsed before 
 *   streaming starts
 * <li>the streamer expects the XML document without any indentation
 * <br/><br/>
 * These restrictions are intended by design, finally to reach optimal
 * performance and to reach full XML support in browsers. For more 
 * background about parsing see e.g.:
 * <li><a href="http://ieeexplore.ieee.org/xpl/articleDetails.jsp?arnumber=4623219">
 *   XML Document Parsing: Operational and Performance Characteristics</a>
 * <br/>
 * <br/>
 * <b>String conversion, encoding conversion, whitespace
 *   normalization as well as indentation can best be prepared with the 
 *   XQuery and XPath 3.0 serialization feature. Example XQuery script:</b>
 * <pre>---
 *xquery version "3.0";
 *
 *declare option output:method "xml";
 *declare option output:encoding "UTF-8";
 *declare option output:indent "no";
 *
 *declare variable $xml := &lt;someXml/&gt;;
 *
 *fn:serialize($xml)
 *---</pre>
 * The output of this XQuery script is exactly what the streamer expects.
 * <br/>
 * <br/>
 * See also: 
 * <li><a href="http://www.w3.org/TR/xslt-xquery-serialization-30/">
 *   XSLT and XQuery Serialization 3.0</a>
 * <li><a href="../../src/agent/xrx2html.xql">XRX++ XQuery Agent</a>
 * <li><a href="../../src/agent/xrx2html.xsl">XRX++ XSLT Agent (For
 *   development only, only runs in modern browsers with full XML 
 *   support)</a>
 *   
 * @param {!string} xml A well-formed, normalized XML document or
 * XML fragment serialized as UTF-8 string.
 * @constructor
 */
xrx.stream = function(xml) {



  /**
   * @type
   * @private
   */
  this.reader_ = new xrx.reader(xml);
  
  

  /**
   * Weather the stream is stopped.
   * @type {boolean}
   * @private
   */
  this.stopped_ = false;
};



/**
 * Event, thrown whenever a start-tag row is found.
 */
xrx.stream.prototype.rowStartTag = goog.abstractMethod;



/**
 * Event, thrown whenever a end-tag row is found.
 */
xrx.stream.prototype.rowEndTag = goog.abstractMethod;



/**
 * Event, thrown whenever a empty-tag row is found.
 */
xrx.stream.prototype.rowEmptyTag = goog.abstractMethod;



/**
 * Event, thrown whenever a namespace declaration is found.
 */
xrx.stream.prototype.namespace = goog.abstractMethod;



/**
 * Enumeration of internal states used by the streamer.
 * @enum
 * @private
 */
xrx.stream.State_ = {
  XML_START: 1,
  XML_END: 2,
  START_TAG: 3,
  END_TAG: 4,
  EMPTY_TAG: 5,
  NOT_TAG: 6,
  LT_SEEN: 7,
  GT_SEEN: 8,
  WS_SEEN: 9,
  TAG_START: 10,
  TAG_NAME: 11,
  TOK_END: 12,
  ATTR_NAME: 13,
  ATTR_VAL: 14
};



/**
 * Returns or sets the content of the current stream reader.
 * 
 * @param opt_xml Well-formed, normalized UTF-8 XML string.
 * @return The content of the stream reader.
 */
xrx.stream.prototype.xml = function(opt_xml) {
  
  return !opt_xml ? this.reader_.input() : this.reader_.input(opt_xml);
};



/**
 * Updates the XML stream at a given location.
 * 
 * @param {!number} offset The offset.
 * @param {!number} length Number of characters to replace.
 * @param {!string} xml The new string.
 */
xrx.stream.prototype.update = function(offset, length, xml) {
  
  this.reader_.input(this.xml().substr(0, offset) + xml + 
      this.xml().substr(offset + length));
};



/**
 * Can be called to stop streaming.
 */
xrx.stream.prototype.stop = function() {

  this.stopped_ = true;
};



/**
 * Returns or sets the position of the stream reader.
 * 
 * @param opt_pos The position.
 * @return {!number} The position or the new position.
 */
xrx.stream.prototype.pos = function(opt_pos) {
  if (opt_pos) this.reader_.set(opt_pos);
  return this.reader_.pos();
};



/**
 * Streams over a XML document or XML fragment in forward direction
 * and fires start-row, end-row, empty row and namespace events. 
 * The streaming starts at the beginning of the XML document / 
 * fragment by default or optionally at an offset.
 * 
 * @param {?number} opt_offset The offset.
 */
xrx.stream.prototype.forward = function(opt_offset) {
  var state = xrx.stream.State_.XML_START;
  var token;
  var offset;
  var length;
  var reader = this.reader_;

  !opt_offset ? reader.first() : reader.set(opt_offset);
  this.stopped_ = false;

  for (;;) {

    switch (state) {
    // start parsing
    case xrx.stream.State_.XML_START:
      reader.get() === '<' ? state = xrx.stream.State_.LT_SEEN :
          state = xrx.stream.State_.NOT_TAG;
      break;
    // end parsing
    case xrx.stream.State_.XML_END:
      break;
    // parse start tag or empty tag
    case xrx.stream.State_.START_TAG:
      offset = reader.pos();
      reader.forwardInclusive('>');
      state = xrx.stream.State_.NOT_TAG;
      reader.peek(-2) === '/' ? token = xrx.token.EMPTY_TAG : 
          token = xrx.token.START_TAG;
      length = reader.pos() - offset;
      break;
    // parse end tag
    case xrx.stream.State_.END_TAG:
      offset = reader.pos();
      reader.forwardInclusive('>');
      state = xrx.stream.State_.NOT_TAG;
      token = xrx.token.END_TAG;
      length = reader.pos() - offset;
      break;
    // empty tag (never used)
    case xrx.stream.State_.EMPTY_TAG:
      break;
    // parse token that is not a tag
    case xrx.stream.State_.NOT_TAG:
      if (!reader.get()) {
        state = xrx.stream.State_.XML_END;
      } else if (reader.peek() === '<') {
        state = xrx.stream.State_.LT_SEEN;
      } else {
        reader.forwardExclusive('<');
        state = xrx.stream.State_.LT_SEEN;
      }
      // if we have parsed the not-tag, the row is complete.
      switch(token) {
      case xrx.token.START_TAG:
        this.rowStartTag(offset, length, reader.pos() - offset);
        break;
      case xrx.token.END_TAG:
        this.rowEndTag(offset, length, reader.pos() - offset);
        break;
      case xrx.token.EMPTY_TAG:
        this.rowEmptyTag(offset, length, reader.pos() - offset);
        break;
      default:
        break;
      };
      // are there any namespace declarations?
      var tag = this.xml().substr(offset, length);
      if (goog.string.contains(tag, 'xmlns')) {
        var atts = this.attributes(tag);
        for (var pos in atts) {
          var att = atts[pos];
          if (goog.string.startsWith(att.xml(tag), 'xmlns')) {
            this.namespace(att.offset + offset, att.length);
          }
        }
      }
      break;
    // '<' seen: start tag or empty tag or end tag?
    case xrx.stream.State_.LT_SEEN:
      if (reader.peek(1) === '/') {
        state = xrx.stream.State_.END_TAG;
      } else {
        state = xrx.stream.State_.START_TAG;
      }
      break;
    default:
      throw Error('Invalid parser state.');
      break;
    }

    if (state === xrx.stream.State_.XML_END || this.stopped_) {
      this.stopped_ = false;
      break;
    }
  }
};



/**
 * Streams over a XML document or XML fragment in backward direction
 * and fires start-row, end-row, empty row and namespace events. The 
 * streaming starts at the end of the XML document / fragment by 
 * default or optionally at an offset.
 * TODO(jochen): do we need lenght2 in backward streaming events?
 * 
 * @param {?number} opt_offset The offset.
 */
xrx.stream.prototype.backward = function(opt_offset) {
  var state = xrx.stream.State_.XML_START;
  var reader = this.reader_;
  var token;
  var offset;
  var length;

  !opt_offset ? reader.last() : reader.set(opt_offset);
  this.stopped_ = false;

  for (;;) {

    switch (state) {
    // start parsing
    case xrx.stream.State_.XML_START:
      if (reader.get() === '<') reader.previous();
      reader.get() === '>' ? state = xrx.stream.State_.GT_SEEN : 
          state = xrx.stream.State_.NOT_TAG;
      break;
    // end parsing
    case xrx.stream.State_.XML_END:
      break;
    // start tag (never used)
    case xrx.stream.State_.START_TAG:
      break;
    // parse end tag or start tag
    case xrx.stream.State_.END_TAG:
      offset = reader.pos();
      reader.backwardInclusive('<');
      state = xrx.stream.State_.NOT_TAG;
      if (reader.peek(1) !== '/') {
        var off = reader.pos();
        var len1 = offset - reader.pos() + 1;
        this.rowStartTag(off, len1);
        // are there any namespace declarations?
        var tag = this.xml().substr(off, len1);
        if (goog.string.contains(tag, 'xmlns')) {
          var atts = this.attributes(tag);
          for (var pos in atts) {
            var att = atts[pos];
            if (goog.string.startsWith(att.xml(tag), 'xmlns')) {
              this.namespace(att.offset + off, att.length);
            }
          }
        }
      } else {
        this.rowEndTag(reader.pos(), offset - reader.pos() + 1);
      }
      reader.previous();
      if (reader.finished()) state = xrx.stream.State_.XML_END;
      break;
    // parse empty tag
    case xrx.stream.State_.EMPTY_TAG:
      offset = reader.pos();
      reader.backwardInclusive('<');
      state = xrx.stream.State_.NOT_TAG;
      var off = reader.pos();
      var len1 = offset - reader.pos() + 1;
      this.rowEmptyTag(off, len1);
      // are there any namespace declarations?
      var tag = this.xml().substr(off, len1);
      if (goog.string.contains(tag, 'xmlns')) {
        var atts = this.attributes(tag);
        for (var pos in atts) {
          var att = atts[pos];
          if (goog.string.startsWith(att.xml(tag), 'xmlns')) {
            this.namespace(att.offset + off, att.length);
          }
        }
      }
      reader.previous();
      if (reader.finished()) state = xrx.stream.State_.XML_END;
      break;
    // parse token that is not a tag
    case xrx.stream.State_.NOT_TAG:
      if (reader.get() === '>') {
        state = xrx.stream.State_.GT_SEEN;
      } else {
        offset = reader.pos();
        reader.backwardExclusive('>');
        //this.tokenNotTag.call(this, reader.pos(), offset - reader.pos() + 1);
        reader.previous();
        state = xrx.stream.State_.GT_SEEN;
      }
      if (reader.finished()) state = xrx.stream.State_.XML_END;
      break;
    // '>' seen: end tag or start tag or empty tag?
    case xrx.stream.State_.GT_SEEN:
      if (reader.peek(-1) === '/') {
        state = xrx.stream.State_.EMPTY_TAG;
      } else {
        state = xrx.stream.State_.END_TAG;
      }
      break;
    default:
      throw Error('Invalid parser state.');
      break;
    }

    if (state === xrx.stream.State_.XML_END || this.stopped_) {
      this.stopped_ = false;
      break;
    }
  }
};



/**
 * Streams over a start-tag, a empty tag or an end-tag and
 * returns the location of the name of the tag.
 * 
 * @param {!string} xml The tag.
 * @param {?xrx.reader} opt_reader Optional reader object.
 * @return {!string} The tag-name.
 */
xrx.stream.prototype.tagName = function(xml, opt_reader) {
  var state = xrx.stream.State_.TAG_START;
  var offset;
  var length;
  var reader = opt_reader || new xrx.reader(xml);

  this.stopped_ = false;
  
  for (;;) {
    
    switch(state) {
    case xrx.stream.State_.TAG_START:
      if (reader.next() !== '<') {
        throw Error('< is expected.');
      } else {
        state = xrx.stream.State_.TAG_NAME;
        reader.get() === '/' ? reader.next() : null;
        offset = reader.pos();
      }
      break;
    case xrx.stream.State_.TAG_NAME:
      if (reader.next().match(/( |\/|>)/g)) {
        state = xrx.stream.State_.TOK_END;
        reader.backward();
        length = reader.pos() - offset - 1;
      }
      break;
    default:
      throw Error('Invalid parser state.');
      break;
    }
    
    if (state === xrx.stream.State_.TOK_END) break; 
  }

  return new xrx.location(offset, length);
};



/**
 * Streams over a start-tag or a empty tag and returns the location
 * of the n'th attribute, or null if the attribute does not exist.
 * 
 * @param {!string} xml The start-tag or empty tag.
 * @param {!number} pos The attribute position.
 * @return {string|null} The attribute at position n or null.
 */
xrx.stream.prototype.attribute = function(xml, pos, opt_offset) {
  return this.attr_(xml, pos, xrx.token.ATTRIBUTE, opt_offset);
};



/**
 * Streams over a start-tag or a empty tag and returns an array of 
 * locations of all attributes found in the tag or null if no 
 * attributes were found.
 * 
 * @param {!string} xml The start-tag or empty tag.
 * @return {Array.<string>|null} The attribute array.
 */
xrx.stream.prototype.attributes = function(xml) {
  var locs = {};
  var location = new xrx.location();

  for(var i = 1;;i++) {
    var newLocation = this.attribute(xml, i, location.offset + location.length);
    if (!newLocation) break;
    
    locs[i] = newLocation;
  }

  return locs;
};



/**
 * Streams over a start-tag or empty tag and returns the location
 * of the name of the n'th attribute.
 * 
 * @param {!string} xml The tag.
 * @param {!number} pos The attribute position.
 * @return {!string} The attribute name.
 */
xrx.stream.prototype.attrName = function(xml, pos) {
  return this.attr_(xml, pos, xrx.token.ATTR_NAME);
};



/**
 * Streams over a start-tag or empty tag and returns the location 
 * of the value of the n'th attribute.
 * 
 * @param {!string} xml The attribute.
 * @param {!number} pos The attribute position.
 * @return {!xrx.location} The attribute value location.
 */
xrx.stream.prototype.attrValue = function(xml, pos) {
  return this.attr_(xml, pos, xrx.token.ATTR_VALUE);
};


/**
 * Shared utility function for attributes.
 * 
 * @private
 */
xrx.stream.prototype.attr_ = function(xml, pos, tokenType, opt_offset, opt_reader) {
  var reader = opt_reader || new xrx.reader(xml);
  if (opt_offset) reader.set(opt_offset);
  this.stopped_ = false;
  
  var location = !opt_offset ? this.tagName(xml, reader) : new xrx.location();
  // tag does not contain any attributes ? => return null
  if (reader.peek(-1).match(/(\/|>)/g)) return null; 

  var state = xrx.stream.State_.ATTR_NAME;
  var offset = reader.pos();
  var length;
  var found = 0;
  var quote;

  
  for (;;) {

    switch(state) {
    case xrx.stream.State_.ATTR_NAME:
      found += 1;
      tokenType === xrx.token.ATTRIBUTE || tokenType === xrx.token.ATTR_NAME ? 
          offset = reader.pos() : null;
      reader.forwardInclusive('=');
      if (tokenType === xrx.token.ATTR_NAME && found === pos) {
        location.offset = offset;
        location.length = reader.pos() - offset - 1;
        state = xrx.stream.State_.TOK_END;
      } else {
        quote = reader.next();
        tokenType === xrx.token.ATTR_VALUE ? offset = reader.pos() : null;
        state = xrx.stream.State_.ATTR_VAL;
      }
      break;
    case xrx.stream.State_.ATTR_VAL:
      reader.forwardInclusive(quote);
      if(found === pos) {
        location.offset = offset;
        if (tokenType === xrx.token.ATTRIBUTE) {
          location.length = reader.pos() - offset;
        } else if (tokenType === xrx.token.ATTR_VALUE) {
          location.length = reader.pos() - offset - 1;
        } else {}
        state = xrx.stream.State_.TOK_END;
      } else {
        reader.next();
        if(!reader.peek(-1).match(/(\/|>)/g)) {
          state = xrx.stream.State_.ATTR_NAME;
        } else {
          state = xrx.stream.State_.TOK_END;
          location = null;
        }
      }
      break;
    default:
      throw Error('Invalid parser state.');
      break;
    }
    
    if (state === xrx.stream.State_.TOK_END) break;
  }
  return location;
};



/**
 * Streams over some XML content and returns the location of 
 * one or more comments.
 */
xrx.stream.prototype.comment = function(xml) {
  // TODO(jochen)
};



/**
 * Streams over some XML content and returns the location of 
 * one or more processing instructions (PI).
 * 
 * @param xml XML string.
 */
xrx.stream.prototype.pi = function(xml) {
  // TODO(jochen)
};



/**
 * Streams over some XML content and returns the location of
 * one or more character data (CDATA) sections.
 * 
 * @param xml XML string.
 */
xrx.stream.prototype.cdata = function(xml) {
  // TODO(jochen)
};



/**
 * Streams over some XML content and returns the location of
 * one or more document type declarations.
 * 
 * @param xml XML string.
 */
xrx.stream.prototype.doctypedecl = function(xml) {
  // TODO(jochen)
};
