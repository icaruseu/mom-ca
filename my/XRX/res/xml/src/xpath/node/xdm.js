/**
 * @fileoverview XPath Data Model 3.0 interface (XDM).
 */

goog.provide('xrx.xdm');



/** 
 * An interface representing the XPath Data Model 3.0 (XDM).
 * http://www.w3.org/TR/xpath-datamodel-30/
 * 
 * @interface 
 */
xrx.xdm = function() {};



/**
 * http://www.w3.org/TR/xpath-datamodel-30/#dm-attributes
 */
xrx.xdm.prototype.accAttributes = goog.abstractMethod;



/**
 * http://www.w3.org/TR/xpath-datamodel-30/#dm-base-uri
 */
xrx.xdm.prototype.accBaseUri = goog.abstractMethod;



/**
 * http://www.w3.org/TR/xpath-datamodel-30/#dm-children
 */
xrx.xdm.prototype.accChildren = goog.abstractMethod;



/**
 * http://www.w3.org/TR/xpath-datamodel-30/#dm-document-uri
 */
xrx.xdm.prototype.accDocumentUri = goog.abstractMethod;



/**
 * http://www.w3.org/TR/xpath-datamodel-30/#dm-is-id
 */
xrx.xdm.prototype.accIsId = goog.abstractMethod;



/**
 * http://www.w3.org/TR/xpath-datamodel-30/#dm-is-idrefs
 */
xrx.xdm.prototype.accIsIdrefs = goog.abstractMethod;



/**
 * http://www.w3.org/TR/xpath-datamodel-30/#dm-namespace-nodes
 */
xrx.xdm.prototype.accNamespaceNodes = goog.abstractMethod;



/**
 * http://www.w3.org/TR/xpath-datamodel-30/#dm-nilled
 */
xrx.xdm.prototype.accNilled = goog.abstractMethod;



/**
 * http://www.w3.org/TR/xpath-datamodel-30/#dm-node-kind
 */
xrx.xdm.prototype.accNodeKind = goog.abstractMethod;



/**
 * http://www.w3.org/TR/xpath-datamodel-30/#dm-node-name
 */
xrx.xdm.prototype.accNodeName = goog.abstractMethod;



/**
 * http://www.w3.org/TR/xpath-datamodel-30/#dm-parent
 */
xrx.xdm.prototype.accParent = goog.abstractMethod;



/**
 * http://www.w3.org/TR/xpath-datamodel-30/#dm-string-value
 */
xrx.xdm.prototype.accStringValue = goog.abstractMethod;



/**
 * http://www.w3.org/TR/xpath-datamodel-30/#dm-type-name
 */
xrx.xdm.prototype.accTypeName = goog.abstractMethod;



/**
 * http://www.w3.org/TR/xpath-datamodel-30/#dm-typed-value
 */
xrx.xdm.prototype.accTypedValue = goog.abstractMethod;



/**
 * http://www.w3.org/TR/xpath-datamodel-30/#dm-unparsed-entity-public-id
 */
xrx.xdm.prototype.accUnparsedEntityPublicId = goog.abstractMethod;



/**
 * http://www.w3.org/TR/xpath-datamodel-30/#dm-unparsed-entity-system-id
 */
xrx.xdm.prototype.accUnparsedEntitySystemId = goog.abstractMethod;