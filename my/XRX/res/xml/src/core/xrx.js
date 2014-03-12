/**
 * @fileoverview The XRX++ main class.
 */

goog.provide('xrx');

goog.require('goog.dom');
goog.require('xrx.func');
goog.require('xrx.bind');
goog.require('xrx.console');
goog.require('xrx.input');
goog.require('xrx.instance');
goog.require('xrx.model');
goog.require('xrx.output');
goog.require('xrx.richxml');
goog.require('xrx.textarea');
goog.require('xrx.view');


xrx.install_ = function(className) {
  var element = goog.dom.getElementsByClass(className);

  var classFromClassName_ = function(obj, arr) {
    var next = obj[arr.shift()];

    return arr.length > 0 ? classFromClassName_(next, arr) : next;
  }

  var classFromClassName = function(className) {
    var arr = className.split('-');

    return classFromClassName_(window, arr);
  }

  for(var i = 0, len = element.length; i < len; i++) {
    var e = element[i];
    var cmpClass = classFromClassName(className);

    if (!cmpClass) throw Error('Implementation of class <' + 
        className + '> could not be found.');

    var cmp = new cmpClass(e);

    if (cmp instanceof xrx.model) {
      xrx.model.addComponent(cmp.getId(), cmp);
    } else if (cmp instanceof xrx.view) {
      xrx.view.addComponent(cmp.getId(), cmp);
    } else {
      throw Error('Components must either inherit ' + 
          'class xrx.view or class xrx.model');
    }
  }
  
};



xrx.install = function() {

  for(var i = 0, len = xrx.model.classes.length; i < len; i++) {
    xrx.install_(xrx.model.classes[i]);
  }

  for(var i = 0, len = xrx.view.classes.length; i < len; i++) {
    xrx.install_(xrx.view.classes[i]);
  }
};
