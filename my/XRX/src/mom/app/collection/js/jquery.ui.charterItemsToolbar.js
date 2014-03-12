 /*! 
 * jQuery UI Charter Items Toolbar (Collection Environment)
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
 * Services
 */
var serviceMyCollectionCharterDelete    =        "service/my-collection-charter-delete";
var serviceMyCollectionCharterNew       =        "service/my-collection-charter-new";
var serviceMyCollectionCharterShare     =        "service/my-collection-charter-share";
var serviceMyCollectionPublish          =        "service/my-collection-publish";

$.widget( "ui.charterItemsToolbar", {  



  options: {
    requestRoot: ""
  },



  showOptional: function() {
    $(".button-delete", "#dmy-collection-items-toolbar").show();
    $(".button-share", "#dmy-collection-items-toolbar").show();
  },



  hideOptional: function() {
    $(".button-delete", "#dmy-collection-items-toolbar").hide();
    $(".button-share", "#dmy-collection-items-toolbar").hide();
  },



  _create: function() {

    var self = this;
    var element = self.element;
    
    element.append(self._myCollectionPublishButton());
    element.append(self._myCharterNewButton());
    element.append(self._myChartersDeleteButton().hide());
    element.append(self._myChartersShareButton().hide());
  },



  _serviceUrl: function(atomid) {
    return this.options.requestRoot + atomid;
  },



  _myCollectionPublish: function(dialog, objectid) {
    
    var self = this, xml = "";

    xml += "<objectids xmlns=''><objectid>" + objectid + "</objectid></objectids>";
    
    $.ajax({
      url: self._serviceUrl(serviceMyCollectionPublish),
      contentType: "application/xml",
      type: "POST",
      data: xml,
      beforeSend: function() {
        $("#dpublish-progress").show().effect("pulsate", {}, 2000);
      },
      complete: function(data, textStatus, jqXHR) {
        $("#dpublish-progress").hide();
        $(dialog).dialog("close");          
      }
    });  
  },


  
  _myCollectionPublishButton: function() {
    
    var self = this,
      
      selectedCollectionName = $(".selected-collections-tree-item", "#dmy-collections-tree").text(),
      selectedCollectionId = $(".selected-collections-tree-item", "#dmy-collections-tree").attr("title"),
      
      button = $('<button>' + $(document).xrxI18n.translate("publish", "") + ' "' + selectedCollectionName  + '"</button>')
        .button({
          icons: {
            primary: "ui-icon-gear"
          }
        })
        .click( function() {
          $("#dmy-collection-publish-dialog").dialog({
            resizable: false,
            width: 300,
            modal: true,
            buttons: {
              Cancel: function() {
                $(this).dialog("close");
              },
              "Publish now": function() {
                self._myCollectionPublish(this, selectedCollectionId);
              }
            }
          });  
        });
    
    return button;
  },


  
  _myCharterNewButton: function() {
    
    var self = this,
        selectedCollectionId = $(".selected-collections-tree-item", "#dmy-collections-tree").attr("title"),
    
        button = $('<button>' + $(document).xrxI18n.translate("create-charter", "") + '</button>')
          .button({
            icons: {
              primary: "ui-icon-gear"
            }
          })
          .click( function() {
          $.ajax({ 
            url: self._serviceUrl(serviceMyCollectionCharterNew), 
            type: "POST",
            data: { mycollection: selectedCollectionId },
            success: function() { 
              $("#dmy-collection-items").charterItems({ 
                atomid: selectedCollectionId,
                requestRoot: self.options.requestRoot
              }); 
            }
          })
          });
    return button;
  },  



  _myChartersDelete: function(button) {
    
    var self = this, inputs = $('input[type="checkbox"]', "#" + uiMyCollectionItemsDivId),
      xml = '<objectids xmlns="">', checkedItemDivs = [];

    $.each(inputs, function(index, input) {
      if($(input).is(":checked")) {
        xml += '<objectid>';
        xml += $(input).parent().parent().attr("id");
        xml += '</objectid>';
        checkedItemDivs.push($(input).parent().parent());
      }
    });
    xml += '</objectids>';
    $(".xrx-message").xrxMessage({ 
      state: "highlight",
      icon: "info",
      message: $(document).xrxI18n.translate("deleting-entries", "") + " ..."
    });          
    $.ajax({
      url: self._serviceUrl(serviceMyCollectionCharterDelete),
      contentType: "application/xml",
      type: "POST",
      data: xml,
      complete: function(data, textStatus, jqXHR) {
        button.hide();
        for(var i in checkedItemDivs) {
          $(checkedItemDivs[i]).effect("pulsate", {}, 2000, function() { $(this).remove() });
        }
        $(".xrx-message").xrxMessage({ 
          state: "highlight",
          icon: "info",
          message: $(document).xrxI18n.translate("entries-successfully-deleted", "")
        });
        $(".xrx-message").delay(2000).slideUp(1000);              
      }
    });    
  },



  _myChartersDeleteButton: function() {
    
    var self = this,
    
      button = $('<button class="button-delete">' + $(document).xrxI18n.translate("delete-selected-entries", "") + '</button>')
        .button({
          icons: {
            primary: "ui-icon-gear"
          }
        })
        .click( function() {
          $("#dmy-collection-items-remove-dialog").dialog({
            resizable: false,
            width: 300,
            modal: true,
            buttons: {
              "Delete all items": function() {
                self._myChartersDelete(button);
                $(this).dialog("close");
              },
              Cancel: function() {
                $(this).dialog("close");
              }
            }
          });          
        });
    return button;
  },



  _myChartersShareButton: function() {
    
    var self = this,
    
      button = $('<button class="button-share">Share</button>')
        .button({
          icons: {
            primary: "ui-icon-gear"
          }
        })
        .click( function() {
          $("#dmy-collection-items-share-dialog").dialogInviteUser();
          $("#dmy-collection-items-share-dialog").dialogInviteUser("open");  
        });        
    
    return button;
  }



});
  
})( jQuery );