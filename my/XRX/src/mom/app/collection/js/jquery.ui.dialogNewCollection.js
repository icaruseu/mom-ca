 /*! 
 * jQuery UI Dialog New Collection (Collection Environment)
 *
 * Depends:
 *   jquery.ui.core.js
 *   jquery.ui.widget.js
 *   jquery.ui.button.js
 *   jquery.ui.dialog.js
 */
;(function( $, undefined ) {

$.widget( "ui.dialogNewCollection", {  

  _create: function() {

    var self = this;
    var newCollectionDialog = $("#dmy-collection-new-dialog");
    var form = $("#fmy-collection-new-dialog");
    var action = form.attr("action");
  
    form.submit( function(event){
      event.preventDefault();
    });
  
    newCollectionDialog.dialog({
      autoOpen: false,
      modal: true,
      width: 500
    });
  
    var collectionNewSuccess = function() {
      newCollectionDialog.dialog("close");
      $("#dmy-collections-tree").myCollectionsTree();
    };

    var collectionNewError = function(xhr, ajaxOptions, thrownError) {
      console.log(xhr);
      console.log(thrownError);
    };
    
    $(".ok-button", "#dmy-collection-new-dialog")
      .button()
      .click( function() {
        var title = form.find( 'input[name="title"]' ).val();
        $.ajax({ 
          url:action, 
          type: "POST",
          data: { title:title },
          success: collectionNewSuccess,
          error: collectionNewError
        });
      });

  }

});
  
})( jQuery );