 /*! 
 * jQuery UI Collection Environment
 *
 * Depends:
 *   jquery.ui.core.js
 *   jquery.ui.widget.js
 *   jquery.ui.button.js
 *   jquery.ui.dialog.js
 */
;(function( $, undefined ) {

$.widget( "ui.myCollectionsEdit", {



  options: {
    requestRoot: "",
    userid: ""
  },



  _create: function() {
    
    var self = this;
    $(document).xrxI18n();
    
    $("#dmy-collections-tree").myCollectionsTree(self.options);
    $("#dmy-collections-shared").myCollectionsShared(self.options);
    $("#dmy-collection-new-dialog").dialogNewCollection(self.options);
    this._myCollectionNewButton();
    $("#dmy-collection-bookmarks-button").myCollectionsBookmarks(self.options);
  },



  _serviceUrl: function(atomid) {
    return this.options.requestRoot + atomid;
  },



  updateBreadcrumb: function(items) {
    
    var breadcrumb = $("#dmy-collection-breadcrumb")
        .empty()
        .append($('<a href="/">MOM-CA</a>'))
        .append($('<span>&#160;&gt;&#160;</span>'));
    
    for(item in items) {
      breadcrumb.append(items[item]).append($('<span>&#160;&gt;&#160;</span>'));
    }
  },
  

  
  _myCollectionNewButton: function() {
    
    $("#dmy-collection-new-button")
      .button()
      .click( function() {
        $("#dmy-collection-new-dialog").dialog("open");
      });
  }
    
});
  
})( jQuery );