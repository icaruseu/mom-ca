;(function( $, undefined ){

	var myCollectionSearchService = "service/collection-content-search-terms";
	var myCollectionSearchKeyService = "service/collection-content-search-key-terms"
	var myCollectionSearchGetChartersService = "service/collection-search-charters";

    var myCollectionSearchService;
    $.widget( "ui.collectionIndexSearch", {
		
	
	options: {
		requestRoot: "",
	    collectionId: "",
	    termsearch: "",
	},




	_serviceUrl: function(service) { return this.options.requestRoot + service; },


	_create: function(){
		var self = this;
        this.json = {};
		
        if(!jQuery.isEmptyObject(this.options.termsearch)){
			self.json =  JSON.parse(this.options.termsearch);
			self._createTermList(self.json);
		}
        
        
        
        var searchTabInactive = $(".typeTab").click(function(event){
        	if($(this).hasClass("inactive"))
        		{
        			$(".typeTab.active").removeClass("active").addClass("inactive");
        			$(this).removeClass("inactive").addClass("active");
        			id = $(this).attr('id');
        			if(id=="contentTab"){
        				$(".options.active").removeClass("active").addClass("inactive")
        				$("#contentSearch").removeClass("inactive").addClass("active");
        			}
        			else if(id=="keyTab"){
        				$(".options.active").removeClass("active").addClass("inactive");
        				$("#keySearch").removeClass("inactive").addClass("active")
        			}
        			$(".options.active").show();
        			$(".options.inactive").hide();
        			
        		}
        });
        

        var contentsearchbutton = $("#contentSearchButton").
            click(function(event){
				var TagName = $("#elementNameField").val();
			    var FirstCharacter = $("#firstCharacterSelect").val();

		    	if($('#keysearchcheck').prop("checked")){
		    		var mode = "key_search";
		    		url = self._serviceUrl(myCollectionSearchKeyService);}
		    	else{
		    		var mode = "free_search";
		    		url = self._serviceUrl(myCollectionSearchService); }
			    

			    if(jQuery.isEmptyObject(self.json)){
					self._freeTagSearch(TagName, FirstCharacter, url);
			    }
			    
			    else if(self.json.node_name != TagName || self.json.first_character != FirstCharacter || self.json.mode != mode)
			    	{
			    	self._freeTagSearch(TagName, FirstCharacter, url);
			    	}
			    });	
        
        var keysearchbutton = $("#keySearchButton").click(function(event){
        	var TagName = $("#elementNameField").val();
        	var key = $("#keyField").val();
        	console.log("KeySearchButton clicked");
        });
	},
		
		
	_freeTagSearch: function(TagName, FirstCharacter, url){
	    var self = this ;	    	
    	$.getJSON(url,
	    		 {collection: this.options.collectionId, nodename: TagName, firstchar: FirstCharacter },
	    		  function(data){
	    			 self.json = data;
	    			 self._createTermList(self.json); });


    },

    
    _createTermList: function(json){   
    	var self = this;
    	
    	var list = $("#termResultsList").empty();
    	for (var c = 0; c < json.results.length; c++){
    		console.log(json.results[c].term)
    		if(json.results[c].key){var listitem = $("<li class='resultsListItem'><span><a>" + json.results[c].term + "</a><sup class='key'> "+json.results[c].key+"</sup></span></li>").appendTo(list).click(function(e){
    			self._CharterSearch(this.innerText);
    		});}
    		else{
    		var listitem = $("<li class='resultsListItem'><a>" + json.results[c].term + "</a></li>").appendTo(list).click(function(e){
    			self._CharterSearch(this.innerText);
    		});
    		}
    	}
    },
    
    
    _CharterSearch: function(clickedItem){
    	var self = this;
    	
    	$.ajax({
    		url: this._serviceUrl(myCollectionSearchGetChartersService),
    		data: {collection: this.options.collectionId, searchterm: clickedItem},
    		dataType : "xml", 
    		success: function(data){
    	        location.reload();
    		}
    		
    	});
    	
    }
    
 });
	

	
})( jQuery );