 /*! 
 * jQuery UI Charter Items Shared (Collection Environment)
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
var uiMyCollectionItemsDivId            =        "dmy-collection-items";

/**
 * Classes
 */
var uiMyCollectionItemClass             =        "my-collection-item";
var uiMyCollectionItemClassHover        =        "my-collection-item-hover";

/**
 * Services
 */
var serviceMyCollectionItemsShared            =        "service/my-collection-items-shared";
var serviceMyCollectionCharterToggleJustLink =   "service/my-collection-charter-toggle-just-link";

$.widget( "ui.charterItemsShared", {  



  options: {
    requestRoot: "",
    atomid: "",
    userid: ""
  },



  _serviceUrl: function(atomid) {
    return this.options.requestRoot + atomid;
  },



  _create: function() {
    
    this.selectedItemCounter = 0;

    var self = this;
    var myCollectionItemsDiv = $("#" + uiMyCollectionItemsDivId);
    var requestRoot = self.options.requestRoot;
    var atomid = self.options.atomid;

    $(".xrx-message").xrxMessage({ 
      state: "highlight",
      icon: "info",
      message: "Loading Items ..."
    });
      
    // compose preface DIV
    var itemsDiv = $('<div></div>')
            .attr("id", uiMyCollectionItemsDivId)
            .attr("requestRoot", requestRoot),
        itemDivPreface = $('<div></div>')
          .addClass(uiMyCollectionItemClass)
          .hover(
                function(){ $(this).addClass(uiMyCollectionItemClassHover); },
                function(){ $(this).removeClass(uiMyCollectionItemClassHover); }
          ),
        itemLinkPreface = $('<a></a>')
            .attr("href", requestRoot + "preface/" + atomid + "/edit")
            .attr("target", "_blank")
            .text("Edit Collection Information"),
    
        // compose table
        table = $('<div></div>')
          .addClass("forms-table"),
        tableHeader = $('<div></div>')
          .addClass("forms-table-row"),
        tableHeaderDate = $('<div></div>')
          .addClass("forms-table-cell")
          .text($(document).xrxI18n.translate("date", "")),
        tableHeaderTitle = $('<div></div>')
          .addClass("forms-table-cell")
          .text($(document).xrxI18n.translate("title", "")),
        tableHeaderEditors = $('<div></div>')
          .addClass("forms-table-cell")
          .text("Editors"),
        tableHeaderDisplay = $('<div></div>')
          .addClass("forms-table-cell")
          .text("Owner"),
        tableHeaderVersionOf = $('<div></div>')
          .addClass("forms-table-cell")
          .text("Related Charter");
    
    // insert preface DIV
    itemDivPreface.append(itemLinkPreface);
    // compose table header
    tableHeader.append(tableHeaderDate).append(tableHeaderTitle).append(tableHeaderEditors).append(tableHeaderDisplay).append(tableHeaderVersionOf);
    table.append(tableHeader);
    // insert all into items DIV
    itemsDiv.append(table);
        
    
    // compose DIVs for charters
    $.ajax({
      url: self._serviceUrl(serviceMyCollectionItemsShared),
      dataType: 'json',
      data: { mycollection: atomid, userid: self.options.userid },
      success: function(data, textStatus, jqXHR) { 
        var length = 0;
        $.each(data, function(key, value) { 
          var charterTitle = value["title"],
            date = value["date"],
            versionOfLink = value["versionOfLink"],
            versionOfTitle = value["versionOfTitle"],
            owner = value["owner"],
            url = value["url"],
            itemDivCharter = $('<div></div>')
              .addClass("forms-table-row")
              .attr("id", key)
              .hover(
                    function(){ $(this).addClass(uiMyCollectionItemClassHover); },
                    function(){ $(this).removeClass(uiMyCollectionItemClassHover); }
              ),
            itemLinkDate = $('<div></div>')
              .addClass("forms-table-cell")
              .append($('<span/>')
                .text(date)
              ),
            itemLinkCharter = $('<div></div>')
              .addClass("forms-table-cell")
              .append($('<span></span>')                  
                .text(charterTitle)
              )          
           itemLinkIllurk = $('<div></div>')
            .addClass("forms-table-cell")
            .append($('<a></a>')
              .attr("href", requestRoot + url + "/edit")
                  .attr("target", "_blank")
                  .append($('<button></button>')
                  .text("Default Editor")
            )
            
          ).append(
              $('<a></a>').attr("href", requestRoot + "charter/" + key + "/illurk").attr("target", "_blank").append(
                  $('<button></button>').text("Illurk Editor")
                  )
          );
          
          var itemOwner = $('<div></div>')
              .addClass("forms-table-cell")
              .append($('<span style="font-size: .8em; color: rgb(200,200,200)"></span>')
                .text(owner));
          var itemLinkVersionOf = $('<div></div>')
            .addClass("forms-table-cell")
            .append($('<a></a>')
              .attr("href", versionOfLink)
              .attr("target", "_blank")
              .text(versionOfTitle)
            );
          itemDivCharter
            .append(itemLinkDate)
            .append(itemLinkCharter)
            .append(itemLinkIllurk)
            .append(itemOwner)
            .append(itemLinkVersionOf);
          if(key != "charter") {
            table.append(itemDivCharter);
            itemsDiv.append(table);
            length += 1; 
          }
        });  
        $(".xrx-message").xrxMessage({ 
          state: "highlight",
          icon: "info",
          message: "Loading Items (" + length + ") ..."
        });
        $(".xrx-message").delay(2000).slideUp(1000);
      }
    });
    
    // replace the initial DIV
    myCollectionItemsDiv.replaceWith(itemsDiv);  
  }

});
  
})( jQuery );