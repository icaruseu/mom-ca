/**
 * @fileoverview An abstract class which represents
 * a component of the model-view-controller.
 */

goog.provide('xrx.component');


goog.require('goog.events.EventHandler');
goog.require('goog.ui.IdGenerator');



/**
 * @constructor
 */
xrx.component = function(element) {



  this.element_ = element;
};



xrx.component.prototype.createDom = goog.abstractMethod;



/**
 * Generator for unique IDs.
 * @type {goog.ui.IdGenerator}
 * @private
 */
xrx.component.prototype.idGenerator_ = goog.ui.IdGenerator.getInstance();



/**
 * Unique ID of the component, lazily initialized in {@link
 * xrx.component#getId} if needed. This property is strictly private and
 * must not be accessed directly outside of this class!
 * @type {?string}
 * @private
 */
xrx.component.prototype.id_ = null;



/**
 * Event handler.
 * @type {goog.events.EventHandler}
 * @private
 */
xrx.component.prototype.handler_;




/**
 * Gets the component's element.
 * @return {Element} The element for the component.
 */
xrx.component.prototype.getElement = function() {
  return this.element_;
};



/**
 * Gets the unique ID for the instance of this component. If the instance
 * doesn't already have an ID, generates one on the fly.
 * @return {string} Unique component ID.
 */
xrx.component.prototype.getId = function() {
  return this.id_ || this.element_.getAttribute('id') || 
      (this.id_ = this.idGenerator_.getNextUniqueId());
};



/**
 * Gets the XPath expression found in the component's data-xrx-ref attribute.
 * @return {?string} The expression.
 */
xrx.component.prototype.getRefExpression = function() {
  return this.getElement().getAttribute('data-xrx-ref');
};



/**
 * Gets the bind ID found in the component's data-xrx-bind attribute.
 * @return {?string} The bind ID.
 */
xrx.component.prototype.getBindId = function() {
  return this.getElement().getAttribute('data-xrx-bind');
};



/**
 * Gets the bind referenced by the component.
 * @return {?xrx.bind} The bind.
 */
xrx.component.prototype.getBind = function() {
  return xrx.model.getComponent(this.getBindId());
};



/**
 * Returns the event handler for this component, lazily created the first time
 * this method is called.
 * @return {!goog.events.EventHandler} Event handler for this component.
 * @protected
 */
xrx.component.prototype.getHandler = function() {
  return this.handler_ ||
      (this.handler_ = new goog.events.EventHandler(this));
};

