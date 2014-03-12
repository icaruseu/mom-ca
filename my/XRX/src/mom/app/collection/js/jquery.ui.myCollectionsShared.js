 /*! 
 * jQuery UI Shared Collection tree (Collection Environment)
 *
 * Depends:
 *   jquery.ui.core.js
 *   jquery.ui.widget.js
 *   jquery.ui.button.js
 *   jquery.ui.dialog.js
 */
;(function( $, undefined ) {

/**
 * IDs
 */
var uiMyCollectionsTreeDivId             =        "dmy-collections-shared";

/**
 * Classes
 */
var uiMyCollectionsTreeItemClass         =        "my-collections-tree-item";
var uiMyCollectionsTreeItemClassSelected =        "selected-collections-tree-item";

/**
 * Services
 */
var serviceMyCollectionsSharedTree             =        "service/my-collections-tree-shared";

$.widget( "ui.myCollectionsShared", {



  options: {
    requestRoot: "",
    userid: ""
  },



  _serviceUrl: function(atomid) {
    return this.options.requestRoot + atomid;
  },



  _myCollectionTreeItem: function(item, collectionContextAtomid, breadcrumb) {
    
    var self = this, hoverClass = "my-collection-tree-item-hover";
    
    $(item).addClass(uiMyCollectionsTreeItemClass);
    $(item).hover( 
      function() { $(this).addClass(hoverClass); },
      function() { $(this).removeClass(hoverClass); }
    );
    
    $(item).click( function() {
      $("." + uiMyCollectionsTreeItemClass, "#dmy-collection-left-menu").removeClass(uiMyCollectionsTreeItemClassSelected);
      $(item).addClass(uiMyCollectionsTreeItemClassSelected);
      
      // load items
      $("#dmy-collection-items").charterItemsShared({ 
        requestRoot: self.options.requestRoot,
        atomid: collectionContextAtomid,
        userid: self.options.userid
      });
      
      // update breadcrumb
      $("#dmy-collections").myCollectionsEdit("updateBreadcrumb", breadcrumb);
    });
  },



  _create: function() {

    var self = this;
    var treeItems;
    var collectionTreeDiv = $('<div></div>')
        .attr("id", uiMyCollectionsTreeDivId);

    $(".xrx-message").xrxMessage({ 
      state: "highlight",
      icon: "info",
      message: $(document).xrxI18n.translate("loading-entries", "") + " ..."
    });

    $.ajax({
      url: self._serviceUrl(serviceMyCollectionsSharedTree),
      dataType: 'json',
      data: { userid: self.options.userid },
      success: function(data, textStatus, jqXHR) {
        var length = 0;
        $.each(data, function(key, value) { 
          var title = value["title"];
          var collectionDiv = $('<div></div>')
            .text(title)
            .attr("title", key)
            .addClass(uiMyCollectionsTreeItemClass);
          
          var breadcrumb = [
                             $('<a href="' + self.options.requestRoot + 'my-collections">Shared Collections</a>'),
                             $('<a href="' + self.options.requestRoot + key + '/my-collection">' + $(collectionDiv).text() + '</a>')
                           ];
          
          self._myCollectionTreeItem(collectionDiv,
              key, 
              breadcrumb
          );
          
          collectionTreeDiv.append(collectionDiv);
          length += 1;
          $(".xrx-message").xrxMessage({ 
            state: "highlight",
            icon: "info",
            message: $(document).xrxI18n.translate("loading-entries", "") + " (" + length + ") ..."
          });
          $(".xrx-message").delay(2000).slideUp(1000);
          if(length == 1) collectionDiv.click();
        });        
      }
    });

    $("#" + uiMyCollectionsTreeDivId).replaceWith(collectionTreeDiv);
  }

});
  
})( jQuery );