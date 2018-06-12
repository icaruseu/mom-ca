 $( document ).ready(function() {   
 
    $("#navigation").mouseenter(function(){      
        $("li.facet").show();        
    });
    
    $("#navigation").mouseleave(function(){
        $("li.facet").hide();       
   });
 
 
});