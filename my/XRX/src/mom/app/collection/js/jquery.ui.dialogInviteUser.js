 /*! 
 * jQuery UI Dialog Invite User (Collection Environment)
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
var serviceMyCollectionCharterInviteUser =       "service/my-collection-charter-share";
var serviceMyCollectionCharterSharedUsers =      "service/my-collection-charter-shared-users";

$.widget( "ui.dialogInviteUser", {



  options: {
    requestRoot: ""
  },
  
  
  
  open: function() {
    var self = this;
    
    $("#dmy-collection-items-share-dialog").dialog("open");
    self.sharedUsers();
  },



  _serviceUrl: function(atomid) {
    return this.options.requestRoot + atomid;
  },



  _create: function() {
    
    var self = this;

    $("#binvite-user")
      .button()
      .click(function(event) {
        $.ajax({
          url: self._serviceUrl(serviceMyCollectionCharterInviteUser),
          contentType: "application/xml",
          type: "POST",
          data: self._requestXml(),
          complete: function(data, textStatus, jqXHR) {
            if (data.responseText == "false") {
              $(".xrx-message").xrxMessage({ 
                state: "error",
                icon: "alert",
                message: "User does not exist."
              });
              $(".xrx-message").delay(2000).slideUp(1000);               
            }
            $('#iinvite-user').val("");
            self.sharedUsers();
          }
        });
      });

    $("#dmy-collection-items-share-dialog").dialog({
      resizable: false,
      width: 500,
      modal: true,
      buttons: {
        "Done": function() {
          $("#dshared-users").empty();
          $(this).dialog("close");
        }
      }
    });
    
    self.sharedUsers();
  },


  
  _requestXml: function() {

    var self = this;
    var collectionId = $(".selected-collections-tree-item", "#dmy-collections-tree").attr("title");
    var input = $('input[type="checkbox"]:checked', "#" + uiMyCollectionItemsDivId);
    var charterId = $(input).parent().parent().attr("id");

    var xml = '<invite xmlns="">';
    xml += '<collectionid>';
    xml += collectionId;
    xml += '</collectionid>';
    xml += '<charterid>';
    xml += charterId;
    xml += '</charterid>';
    xml += '<user>';
    xml += $('#iinvite-user').val();
    xml += '</user>';
    xml += '</invite>';
    
    return xml;
  },



  sharedUsers: function() {
    
    var self = this;
    var collectionId = $(".selected-collections-tree-item", "#dmy-collections-tree").attr("title");
    var input = $('input[type="checkbox"]:checked', "#" + uiMyCollectionItemsDivId);
    var charterId = $(input).parent().parent().attr("id");
    var users = $("#dshared-users");
    users.empty();
    
    $.ajax({
      url: self._serviceUrl(serviceMyCollectionCharterSharedUsers),
      dataType: 'json',
      data: { collectionid: collectionId, charterid: charterId },
      success: function(data, textStatus, jqXHR) {
        $.each(data, function(key, value) {
          var div = $('<div class="invited-user"></div>');
          var span = $('<span class="invited-user"></span>');
          span.text(value + " (" +  key + ")");
          if(key != 'user') users.append(div.append(span));
        });
      }
    });
  }

});
  
})( jQuery );