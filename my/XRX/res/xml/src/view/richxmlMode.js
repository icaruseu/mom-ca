goog.provide('xrx.richxml.mode');



goog.require('xrx.label');
goog.require('xrx.richxml');
goog.require('xrx.token');



/**
 * CodeMirror mode for xrx.richxml.
 * @return {!Object}
 */
xrx.richxml.mode = CodeMirror.defineMode('richxml', function() {



  function nextToken(state, className) {
    var previousToken = state.context.token;
    var previousLabel = previousToken.label();
    var newToken;
    var newLabel = previousLabel.clone();
    
    switch(className) {
    case xrx.richxml.className.notTag:
      if (previousToken.type() === xrx.token.START_TAG) {
        newLabel.push0();
      }
      newToken = new xrx.token.NotTag(newLabel);
      break;
    case xrx.richxml.className.startTag:
      if (previousToken.type() === xrx.token.START_TAG) {
        newLabel.child();
      } else {
        newLabel.nextSibling();
      }
      newToken = new xrx.token.StartTag(newLabel);
      break;
    case xrx.richxml.className.emptyTag:
      if (previousToken.type() === xrx.token.START_TAG) {
        newLabel.child();
      } else {
        newLabel.nextSibling();
      }
      newToken = new xrx.token.EmptyTag(newLabel);
      break;
    case xrx.richxml.className.endTag:
      if (previousToken.type() === xrx.token.START_TAG) {
        // do nothing
      } else {
        newLabel.parent()
      }
      newToken = new xrx.token.EndTag(newLabel);
      break;
    default:
      throw Error('Unknown token.');
      break;
    }
    return newToken;
  }



  function changeContext(state, className) {
    var token = (!state.context) ? new xrx.token.StartTag(new xrx.label([1])) : 
        nextToken(state, className);
    var newContext = {
      token: token,
      prev: state.context,
      next: null 
    };

    state.context = newContext;
  }


  /**
   * Parses the place-holder string.
   * @return {!xrx.richxml.className} Class name of the token type.
   */
  function parse(stream, state) {
    var ch = stream.next();

    if (ch === xrx.richxml.placeholder.startTag) {
      changeContext(state, xrx.richxml.className.startTag);
      return xrx.richxml.className.startTag;
    } else if (ch === xrx.richxml.placeholder.endTag) {
      changeContext(state, xrx.richxml.className.endTag);
      return xrx.richxml.className.endTag;
    } else if (ch === xrx.richxml.placeholder.emptyTag) {
      changeContext(state, xrx.richxml.className.emptyTag);
      return xrx.richxml.className.emptyTag;
    } else {
      while(true) {
        ch = stream.next();
        if(!ch) break; 
        if(ch === xrx.richxml.placeholder.startTag || ch === xrx.richxml.placeholder.endTag
            || ch === xrx.richxml.placeholder.emptyTag) {
          stream.backUp(1);
          break;
        }
      };
      changeContext(state, xrx.richxml.className.notTag);
      return xrx.richxml.className.notTag;
    }
  }



  return {
    startState: function() {
      return {
        tokenize: parse,
        context: null
      };
    },
    token: function(stream, state) {
      var style = state.tokenize(stream, state);
      return style;
    }
  };
});


/**
 * 
 */
CodeMirror.defineMIME('text/richxml', 'richxml');