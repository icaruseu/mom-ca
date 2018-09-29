;(function( $, undefined ){

	var myCollectionRegSearchService = "service/collection-content-reg-search-terms";
	var myCollectionSearchService = "service/collection-search-terms";
	var myCollectionSearchKeyService = "service/collection-content-search-key-terms";
	var myCollectionSearchGetChartersService = "service/collection-search-charters";

    var myCollectionSearchService;
    $.widget( "ui.collectionIndexSearch", {
		
	
	options: {
		requestRoot: "",
	    collectionId: "",
	    termsearch: "",
		collectionType: ""
	},




	_serviceUrl: function(service) { return this.options.requestRoot + service; },


	_create: function(){
		var self = this;
        this.json = {};
		
        if(!jQuery.isEmptyObject(this.options.termsearch)){
			self.json =  JSON.parse(this.options.termsearch);
			self._createTermList(self.json, "contentResultsList", "content");
			self._keySearch();
			self._refSearch();
		}
        
        
        
        var searchTabInactive = $(".typeTab").click(function(event){
        	if($(this).hasClass("inactive"))
        		{
        			$(".typeTab.active").removeClass("active").addClass("inactive");
        			$(this).removeClass("inactive").addClass("active");
        			id = $(this).attr('id');
        			if(id=="contentTab"){
        				$(".list.active").removeClass("active").addClass("inactive")
        				$("#contentResultsList").removeClass("inactive").addClass("active");
        			}
        			else if(id=="keyTab"){
        				$(".list.active").removeClass("active").addClass("inactive");
        				$("#keyResultList").removeClass("inactive").addClass("active")
        			}
        			else if(id == "refTab"){
        				$(".list.active").removeClass("active").addClass("inactive");
        				$("#refResultList").removeClass("inactive").addClass("active");
					}
        			$(".list.active").show();
        			$(".list.inactive").hide();
        		}
        });
        

        var contentsearchbutton = $("#contentSearchButton").
            click(function(event){
				var TagName = $("#elementNameSelect").val();
			    var FirstCharacter = $("#firstCharacterSelect").val();

			    var mode = "free_search";
				url = self._serviceUrl(myCollectionSearchService);
			    

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
        });
	},
		
		
	_freeTagSearch: function(TagName, FirstCharacter, url){
	    var self = this ;	    	
    	$.getJSON(url,
	    		 {collection: this.options.collectionId, nodename: TagName, firstchar: FirstCharacter, collectionType: self.options.collectionType },
	    		  function(data){
	    			 self.json = data;
					 self._createTermList(self.json, "contentResultsList", "content");
					 self._keySearch();
					 self._refSearch()
                  });
    },


	_keySearch: function(){
		var self = this;
		$.getJSON(self._serviceUrl(myCollectionSearchKeyService), function(data){
			self._createTermList(data, "keyResultList", "key");
		});
	},


	_refSearch: function(){
		var self = this;
		$.getJSON(self._serviceUrl(myCollectionRegSearchService), function(data){
			self._createTermList(data,"refResultList", "ref");
		});
	},




    _createTermList: function(json, listname, mode){
    	var self = this;
    	var list = $("#"+listname).empty();
    	for (var c = 0; c < json.results.length; c++){
    		console.log(json.results[c].term)
    		if(json.results[c].key){var listitem = $("<li class='resultsListItem'><span><a>" + json.results[c].term + "</a><sup class='key'> "+json.results[c].key+"</sup></span></li>").appendTo(list).click(function(e){
    			self._CharterSearch(this.innerText, mode);
    		});}
    		else{
    		var listitem = $("<li class='resultsListItem'><a>" + json.results[c].term + "</a></li>").appendTo(list).click(function(e){
    			self._CharterSearch(this.innerText, mode);
    		});
    		}
    	}
    },
    
    
    _CharterSearch: function(clickedItem, mode){
    	var self = this;
    	
    	$.ajax({
    		url: this._serviceUrl(myCollectionSearchGetChartersService),
    		data: {collection: this.options.collectionId, searchterm: clickedItem, type: mode, collectionType: self.options.collectionType},
    		dataType : "xml", 
    		success: function(data) {
    			location.reload();
               /* $("#resultIframe").attr("src", function (index, attr) {
                    return attr+"?modus='"+self.options.collectionType+"'";
                });
                */
            }
    	});
    }
    
 });
	

	
})( jQuery );