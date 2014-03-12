 /*! 
 * jQuery UI Bookmark Items (Collection Environment)
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
var uiMyCollectionBookmarksButton       =        "dmy-collection-bookmarks-button";
var uiMyCollectionItemsDivId            =        "dmy-collection-items";

/**
 * Classes
 */
var uiMyCollectionsTreeItemClass         =       "my-collections-tree-item";
var uiMyCollectionsTreeItemClassSelected =       "selected-collections-tree-item";
var uiMyCollectionItemClass              =       "my-collection-item";
var uiMyCollectionItemClassHover        =        "my-collection-item-hover";
var uiMyCollectionItemClassDragstart    =        "my-collection-item-dragstart";
var uiMyCollectionItemDraggableHelperClass =     "my-collection-item-draggable-helper";

/**
 * Services
 */
var serviceMyCollectionBookmarks        =        "service/my-collection-bookmarks";

$.widget( "ui.myCollectionsBookmarks", {



  options: {
    requestRoot: ""
  },



  _create: function() {
  
    var self = this;
    self.myCollectionTreeItem($("#" + uiMyCollectionBookmarksButton), self._myCollectionBookmarksClick, null);    
  },



  _serviceUrl: function(atomid) {
    return this.options.requestRoot + atomid;
  },



  myCollectionTreeItem: function(item, clickFunction, collectionContextAtomid, breadcrumb) {
    
    var self = this, hoverClass = "my-collection-tree-item-hover";
    $(item).addClass(uiMyCollectionsTreeItemClass);
    $(item).hover( 
      function() { $(this).addClass(hoverClass); },
      function() { $(this).removeClass(hoverClass); }
    );
    if(clickFunction != undefined){ 
      $(item).click( function() {
        $("." + uiMyCollectionsTreeItemClass, "#dmy-collection-left-menu").removeClass(uiMyCollectionsTreeItemClassSelected);
        $(item).addClass(uiMyCollectionsTreeItemClassSelected);
        clickFunction(self, collectionContextAtomid);
        $("#dmy-collections").myCollectionsEdit("updateBreadcrumb", breadcrumb);
      });
    }
  },



  _myCollectionBookmarksClick: function(self, atomid) {
    
    var itemsDiv = $('<div></div>')
           .attr("id", uiMyCollectionItemsDivId)
           .attr("requestRoot", self.options.requestRoot),
       infoDiv = $('<div></div>')
         .html("Drag and Drop a Bookmark into one of your Collections to start a new Version of this Charter.<br/><br/>");
   itemsDiv.append(infoDiv);
   $(".xrx-message").xrxMessage({ 
     state: "highlight",
     icon: "info",
     message: $(document).xrxI18n.translate("loading-entries", "") + " ..."
   });
   $.ajax({
     url: self._serviceUrl(serviceMyCollectionBookmarks),
     dataType: 'json',
     success: function(data, textStatus, jqXHR) {
       var length = 0;
       $.each(data, function(key, value) {
         length += 1;
         var title = value["title"];
         var link = value["link"];
         var bookmarkDiv = $('<div></div>')
           .attr("title", key)
           .addClass(uiMyCollectionItemClass)
           .hover(
             function() { $(this).addClass(uiMyCollectionItemClassHover); },
             function() { $(this).removeClass(uiMyCollectionItemClassHover); }
           )
           .draggable({
             revert: "invalid",
             cursor: "pointer",
             helper: function() { 
               var div = $('<div></div>')
                 .addClass(uiMyCollectionItemDraggableHelperClass)
                 .addClass("ui-corner-all")
                 .html("<span>Start a new version of</span><br/><span>'" + title + "'</span>");
               return div; 
             },
             handle: ".ui-icon",
             start: function(event, ui) { 
                $(this).addClass(uiMyCollectionItemClassDragstart);
             },
             stop: function(event, ui) { 
                $(this).removeClass(uiMyCollectionItemClassDragstart);
             }              
           });
         var arrowIconSpan = $('<span></span>')
           .addClass("ui-icon ui-icon-arrow-4-diag")
           .css("float", "left").css("margin-right", "1%").css("margin-top", "3px").css("cursor", "pointer");
         var titleSpan = $('<a></a>').text(title)
           .attr("href", link).attr("target", "_blank");
         bookmarkDiv.append(arrowIconSpan).append(titleSpan);
         itemsDiv.append(bookmarkDiv);
       });    
       $(".xrx-message").xrxMessage({ 
         state: "highlight",
         icon: "info",
         message: $(document).xrxI18n.translate("loading-entries", "") + " (" + length + ") ..."
       });
       $(".xrx-message").delay(2000).slideUp(1000);    
     }
   });
   $("#" + uiMyCollectionItemsDivId).replaceWith(itemsDiv);
 }

});
  
})( jQuery );