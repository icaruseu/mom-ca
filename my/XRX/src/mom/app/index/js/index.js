 $( function() {
      
   $(".choose-menu").menu();     
   $(".buchstaben").menu();
   $(".accordion").accordion({active: true, collapsible: true, heightStyle: "auto"});    
   $(".ui-accordion-content").css("height", "auto");
   
   $("a.filter").each(function (){
   if($(".glossary-entry").children("h2")[0]){
   var term = $(".glossary-entry").children("h2")[0].textContent;
   }   
   if ($(this).text() == term){   
    var ac = $(this).parents("div.accordion");
    $(ac).accordion({active:0});
     }    
   }); 
    
   $( ".radio" ).buttonset();
   
    var parameter = window.location.href;
    if(parameter.includes('?pm=charter')){
    $("span.moreless").toggle();    
    showglossar();
 
    }    
    $("span.moreless").click(function(){
    $("span.moreless").toggle();
    showglossar();   
   })
   
   function showglossar() {
    	  if($("div.glossary-open").length == 0) {
    		    $("div.glossary-entry").addClass("glossary-open").removeClass("glossary-entry");    
    		    var pfeil = $("#aus").clone();
    		    var spanless = $('<p></p>').addClass("moreless zusatz").append(pfeil);    
    		    var letztesp = $(".glossary-open").append(spanless);
    		    spanless.click( function() {
    		    $("div.glossary-open").addClass("glossary-entry").removeClass("glossary-open");
    		    $("span.moreless").toggle(); 
    		    $(".zusatz").remove();
    		     window.scrollTo(0,0);
    		    })
    		    }
    		    else {    
    		    $("div.glossary-open").addClass("glossary-entry").removeClass("glossary-open"); 
    		    $(".zusatz").remove(); 
    		    }   
    }

  } );