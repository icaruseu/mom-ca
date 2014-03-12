/**
 * @fileoverview A collection of custom XRX++ XPath functions.
 */

goog.provide('xrx.func');


goog.require('xrx.model');
goog.require('xrx.xpath');
goog.require('xrx.xpath.DataType');
goog.require('xrx.xpath.FunctionCall');
goog.require('xrx.xpath.NodeSet');



xrx.xpath.declareNamespace('xrx', 'http://www.monasterium.net/NS/xrx');



xrx.func = {
  INSTANCE: xrx.xpath.FunctionCall.createFunc('xrx:instance',
      xrx.xpath.DataType.NODESET, true, true, true,
      function(ctx, expr) {
        var nodeset = new xrx.xpath.NodeSet();
        var instance = expr.evaluate(ctx);
        nodeset.add(xrx.model.getComponent(instance).document());

        return nodeset;
      }, 1, 1)
};
