 /*! 
 * jQuery UI Dialog for Editors (charter)
 *
 * Depends:
 *   jquery.ui.core.js
 *   jquery.ui.widget.js
 *   jquery.ui.button.js
 *   jquery.ui.dialog.js
 */
;(function( $, undefined ) {
	

$.widget( "ui.dialogEditor", {  

	  options: {
		  baseurl: "",
		  charterid: ""
	  },
	  

  _create: function() {
	  var self = this,
	  baseurl = self.options.baseurl,
	  charterid = self.options.charterid,
	  dialogEdit = $('<div></div>').attr("title", "Choose your Editor"),

      infotext1 = $('<span class="window"> Das ist die Vollversion des editors</span>').css("padding-left", "1em").css("color", "#808080"),
      infotext2 = $('<span class="window"> Editor zur Datumseingabe</span>').css("padding-left", "1em").css("color", "#808080"),
      infotext3 = $('<span class="window"> Editor zur kunsthistorischen Beschreibung</span>').css("padding-left", "1em").css("color", "#808080"),
	  infotext4 = $('<span class="window">Editor zur Erstellung der Transkription</span>').css("padding-left", "1em").css("color", "#808080"),
	  editorLink1 = $('<a></a>')
      .attr("href", baseurl  + charterid + "/edit")
      .attr("target", "_blank")
      .text("Editor 1").css("margin-bottom", "0.5em"),
      editorLink2 = $('<a></a>')
      .attr("href", baseurl + charterid + "/edit")
      .attr("target", "_blank")
      .text("Editor 2").css("margin-bottom", "0.5em"),
      editorLink3 = $('<a></a>')
      .attr("href", "mom/charter/"+ charterid + "/illurk")
      .attr("target", "_blank")
      .text("Editor 3").css("margin-bottom", "0.5em"),
      editorLink4 = $('<a></a>')
      .attr("href", baseurl + charterid + "/edit")
      .attr("target", "_blank")
      .text("Editor 4").css("margin-bottom", "0.5em")

      var eins = $("<div></div>").append(editorLink1).append(infotext1);
	  var zwei = $("<div></div>").append(editorLink2).append(infotext2);
	  var drei = $("<div></div>").append(editorLink3).append(infotext3);
	  var vier = $("<div></div>").append(editorLink4).append(infotext4);
	  dialogEdit.append(eins).append(zwei).append(drei).append(vier);
	  console.log("editorlink");	  
	  console.log(eins);
	  console.log(dialogEdit);
	  $(function() {
		  	var self = this;
		  	$("#new-button")
		  		.button()
		  		.click( function() {
		
		  			dialogEdit.dialog({
		  				width:450
		  				});
  });
  })
  
 $(function() {
	    dialogEdit.buttonset();
	  });
  }

});
  
})( jQuery );

