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
   
   var pfeil = $("#aus").clone();
   var spanless = $('<p></p>').addClass("moreless zusatz").append(pfeil);
  
   
  if(($("div.entry").length) && ($("div.entry")[0].textContent !='')){
	   
	   var letztesp = $(".glossary-entry").append(spanless);
	   
	   spanless.click( function() {
		   	$("div.entry").toggle();
		    $("span.moreless").toggle(); 
		    $(spanless).toggle();
		     window.scrollTo(0,0);
		    })
   } ;
   
  
   
    var parameter = window.location.href;
    if(parameter.includes('?pm=charter')){
    $("span.moreless").toggle();
    $("div.entry").toggle();
    $(spanless).toggle();
   
 
    }    
    $("span.moreless").click(function(){
    $("span.moreless").toggle();
    $("div.entry").toggle();
    $(spanless).toggle();

   })   
   

  } );