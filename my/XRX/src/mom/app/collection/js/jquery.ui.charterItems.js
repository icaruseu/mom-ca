 /*! 
 * jQuery UI Charter Items (Collection Environment)
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
var uiMyCollectionItemsToolbarDivId     =        "dmy-collection-items-toolbar";

/**
 * Classes
 */
var uiMyCollectionItemClass             =        "my-collection-item";
var uiMyCollectionItemClassHover        =        "my-collection-item-hover";

/**
 * Services
 */
var serviceMyCollectionItems            =        "service/my-collection-items";
var serviceMyCollectionCharterToggleJustLink =   "service/my-collection-charter-toggle-just-link";

$.widget( "ui.charterItems", {  



  options: {
    requestRoot: "",
    atomid: ""
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
      
    // create toolbar
    var toolbarDiv = $('<div></div>')
          .attr("id", uiMyCollectionItemsToolbarDivId);
    toolbarDiv.charterItemsToolbar();
      
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
        tableHeaderSelectAll = $('<div></div>')
          .addClass("forms-table-cell")
          .text("     "),
        tableHeaderDate = $('<div></div>')
          .addClass("forms-table-cell")
          .text($(document).xrxI18n.translate("date", "")),
        tableHeaderTitle = $('<div></div>')
          .addClass("forms-table-cell")
          .text($(document).xrxI18n.translate("title", "")),
        tableHeaderEditors = $('<div></div>')
          .addClass("forms-table-cell")
          .text($(document).xrxI18n.translate("edit", "")),
        tableHeaderDisplay = $('<div></div>')
          .addClass("forms-table-cell")
          .text("Display"),
        tableHeaderVersionOf = $('<div></div>')
          .addClass("forms-table-cell")
          .text("Related Charter");
    
    // insert preface DIV
    itemDivPreface.append(itemLinkPreface);
    // compose table header
    tableHeader.append(tableHeaderSelectAll).append(tableHeaderDate).append(tableHeaderTitle).append(tableHeaderEditors).append(tableHeaderDisplay).append(tableHeaderVersionOf);
    table.append(tableHeader);
    // insert all into items DIV
    itemsDiv.append(toolbarDiv)
        //.append(itemDivPreface)
        .append(table);
    var coll = "graz";
    // compose DIVs for charters   
    $.ajax({
      url: self._serviceUrl(serviceMyCollectionItems),      
      dataType: 'json',
      data: { mycollection : atomid },
      success: function(data, textStatus, jqXHR) { 
        var length = 0;
        $.each(data, function(key, value) { 
          var charterTitle = value["title"],
            date = value["date"],
            versionOfLink = value["versionOfLink"],
            versionOfTitle = value["versionOfTitle"],
            justLinked = value["justLinked"],
            url = value["url"],
            itemDivCharter = $('<div></div>')
              .addClass("forms-table-row")
              .attr("id", key)
              .hover(
                    function(){ $(this).addClass(uiMyCollectionItemClassHover); },
                    function(){ $(this).removeClass(uiMyCollectionItemClassHover); }
              ),
            itemSelectCharter = $('<div></div>')
              .addClass("forms-table-cell")
              .append($('<input type="checkbox"/>')
                .change( function() {
                  if($(this).is(":checked")) self.selectedItemCounter += 1;
                  else self.selectedItemCounter -= 1;
                  if(self.selectedItemCounter > 0) {
                    toolbarDiv.charterItemsToolbar("showOptional");
                    if(self.selectedItemCounter != 1) $(".button-share", "#dmy-collection-items-toolbar").hide();
                  } else {
                    toolbarDiv.charterItemsToolbar("hideOptional");
                  }
                })
              ),
            itemLinkDate = $('<div></div>')
              .addClass("forms-table-cell")
              .append($('<span/>')
                .text(date)
              ),
            itemLinkCharter = $('<div></div>')
             .addClass("forms-table-cell")
             .append($('<span/>')
               .text(charterTitle)
              ),
              
              itemLinkIllurk = $('<div></div>')
              .addClass("forms-table-cell")
              .append($('<a></a>')
                .attr("href", requestRoot + url + "/edit")
	            .attr("target", "_blank")
	            .append($('<button></button>')
	            .text("Default Editor") )
                
              ).append(
                  $('<a></a>').attr("href", requestRoot + url + "/edit?mode=illurk").attr("target", "_blank").append(
                      $('<button></button>').text("Illurk Editor")
                      )
              );
          console.log('Das ist ein ajax test');
          console.log(self._serviceUrl(serviceMyCollectionItems));
          var itemLinkDisplay = $('<div></div>')
              .addClass("forms-table-cell");
          if (versionOfTitle !== '') {
            var radioId = 'versionOfRadio' + length.toString();
            var radioId1 = radioId + 'link';
            var radioId2 = radioId + 'version';
            var radioName = radioId + 'name';
            itemLinkDisplay
                 .append($('<span class="just-linked" id="' + radioId + '">')
                      .append($('<input type="radio" id="' + radioId1 + '" name="' + radioName + '" selected="selected"/><label for="' + radioId1 + '">Public Version </label>')
                          .css("size", ".72em"))
                      .append($('<input type="radio" id="' + radioId2 + '" name="' + radioName + '"/><label for="' + radioId2 + '">Own Version</label>')
                          .css("size", ".72em"))
                      )
                 .append($('<span>&#160;</span>'));
            justLinked === 'true' ? itemLinkDisplay.find('#' + radioId1).attr("checked", "checked") : 
                itemLinkDisplay.find('#' + radioId2).attr("checked", "checked");
            itemLinkDisplay.find("#" + radioId)
                .buttonset()
                .click(function(event) {
                  var xml = "<objectid>" + key + "</objectid>";
                  
                  $.ajax({
                    url: self._serviceUrl(serviceMyCollectionCharterToggleJustLink),
                    contentType: "application/xml",
                    type: "POST",
                    data: xml,
                    complete: function(data, textStatus, jqXHR) {
                      $(".xrx-message").xrxMessage({ 
                        state: "highlight",
                        icon: "info",
                        message: "Successfully saved."
                      });
                      $(".xrx-message").delay(2000).slideUp(1000);
                    }
                  }); 
                });
          }
          var itemLinkVersionOf = $('<div></div>')
            .addClass("forms-table-cell")
            .append($('<a></a>')
              .attr("href", versionOfLink)
              .attr("target", "_blank")
              .text(versionOfTitle)
            );
          itemDivCharter.append(itemSelectCharter)
            .append(itemLinkDate)
            .append(itemLinkCharter)
            .append(itemLinkIllurk)
            .append(itemLinkDisplay)
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