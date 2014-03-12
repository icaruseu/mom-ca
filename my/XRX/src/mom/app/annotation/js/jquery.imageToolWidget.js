/*!
 * jQuery Image Tool Widget
 *
 */

;(function($) {

var mouseAbsX, mouseAbsY, downTimer, toolinterval;

   /*
	 * public interface
	 */
  
  // init the image tool widget
  $.fn.ImageToolWidget = function() {
    // open image tool widget
    jQuery('#image-tool-widget').css('display', 'block');
    // move tool widget onmousemove
    jQuery("#image-tool-widget").mousedown(function(event) {
                                moveTooltip(event);
                                });
    jQuery("#image-tool-widget").mouseup(function(event) {
                                stopTooltip(event);
                                });
    jQuery("#dmy-collection-charter-edit").mouseup(function(event) {
                                stopTooltip(event);
                                });
	};


  /*
	 * private functions
	 */

  // move information tooltip to mouse position
  function moveTooltip(e){
      // disable selection of other elements
      document.onselectstart = new Function ("return false");
      // FF hack for no selection
      document.onmousemove = function(){
         	document.getSelection().removeAllRanges();
         };
      // check if mousebutton is pressed more than 0.2 sec
  		clearTimeout(downTimer);
  		downTimer = setTimeout(function() {
          // Tooltip will follow the mouse pointer
  		    toolinterval = window.setInterval(function() { moveTool(); }, 50);
  		    // Calculate the position of the image tooltip
  		    this.onmousemove = updateMouseAbsCoords;    
          }, 200);
  };
  
  // set coordinates of information tooltip
  function moveTool(){
  	jQuery('#image-tool-widget').css({'top': mouseAbsY-15,'left': mouseAbsX-95});
  };
  
  // hide information tooltip
  function stopTooltip(e){
      // Reset the z-index and hide the image tooltip
      clearTimeout(downTimer);
      clearInterval(toolinterval);
      // enable selection
      document.onselectstart = new Function ("return true");
      document.onmousemove = "";
  };
  
  // update mouse coordination
  function updateMouseAbsCoords(e) {
     mouseAbsX = e.pageX - $(document).scrollLeft(); 
     mouseAbsY = e.pageY - $(document).scrollTop();
  };

})( jQuery );