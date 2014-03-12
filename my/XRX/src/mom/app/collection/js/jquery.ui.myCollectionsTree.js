 /*! 
 * jQuery UI Tree Menu (Collection Environment)
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
var uiMyCollectionsTreeDivId             =        "dmy-collections-tree";

/**
 * Classes
 */
var uiMyCollectionsTreeItemClass         =        "my-collections-tree-item";
var uiMyCollectionsTreeItemClassSelected =        "selected-collections-tree-item";

/**
 * Services
 */
var serviceMyCollectionsTree             =        "service/my-collections-tree";
var serviceMyCollectionCharterNewVersion =        "service/my-collection-charter-new-version";

$.widget( "ui.myCollectionsTree", {



  options: {
    requestRoot: ""
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
      $("#dmy-collection-items").charterItems({ 
        requestRoot: self.options.requestRoot,
        atomid: collectionContextAtomid
      })
      
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
      url: self._serviceUrl(serviceMyCollectionsTree),
      dataType: 'json',
      success: function(data, textStatus, jqXHR) {
        var length = 0;
        $.each(data, function(key, value) { 
          var title = value["title"];
          var collectionDiv = $('<div></div>')
            .text(title)
            .attr("title", key)
            .addClass(uiMyCollectionsTreeItemClass)
            .droppable({
              hoverClass: "ui-state-hover",
              drop: function(event, ui) {
                var draggable = ui.draggable,
                  charterAtomid = draggable.attr("title"),
                  collectionObjectid = key;
                $.ajax({
                  url: self._serviceUrl(serviceMyCollectionCharterNewVersion),
                  type: "POST",
                  data: { charteratomid: charterAtomid, collectionobjectid: collectionObjectid },
                  success: function() { 
                    $(".xrx-message").xrxMessage({ 
                      state: "highlight",
                      icon: "info",
                      message: "A new version was successfully created."
                    });
                    $(".xrx-message").delay(2000).slideUp(1000);
                  }
                });
              }
            });
          
          var breadcrumb = [
                             $('<a href="' + self.options.requestRoot + 'my-collections">My Collections</a>'),
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