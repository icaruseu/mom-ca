;(function( $, undefined ){

	/* Contains functions for the register functions.*/

	var myCollectionRegSearchService = "service/register-content-reg-search-terms";
	var myCollectionSearchService = "service/register-search-terms";
	var myCollectionSearchKeyService = "service/register-content-search-key-terms";
	var myCollectionSearchGetChartersService = "service/register-search-charters";

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
		/* when there is a an JSON in options.termsearch it creates the register lists*/
        if(!jQuery.isEmptyObject(this.options.termsearch)){
			self.json =  JSON.parse(this.options.termsearch);
			self._createTermList(self.json, "contentResultsList", "content");
			self._keySearch();
			self._regSearch();
		}
        
        
        /*functions to switch between lists for Content, Normalized and Key Register*/
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
        			else if(id == "regTab"){
        				$(".list.active").removeClass("active").addClass("inactive");
        				$("#regResultList").removeClass("inactive").addClass("active");
					}
        			$(".list.active").show();
        			$(".list.inactive").hide();
        		}
        });
        
		/* Functions to start registersearch*/
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


		/*ajax call for services, if the call is successfull the functions to create the List for Content, Key and Normalized are called */
	_freeTagSearch: function(TagName, FirstCharacter, url){
	    var self = this ;	    	
    	$.getJSON(url,
	    		 {collection: this.options.collectionId, nodename: TagName, firstchar: FirstCharacter, collectionType: self.options.collectionType },
	    		  function(data){
	    			 self.json = data;
					 self._createTermList(self.json, "contentResultsList", "content");
					 self._keySearch();
					 self._regSearch()
                  });

    	self._writeSearchToList("contentResultsList");
    	self._writeSearchToList("keyResultList");
    	self._writeSearchToList("regResultList");

    },

	_writeSearchToList: function(listname){
        var self = this;
        var list = $("#"+listname).empty();
        var listitem = $("li class='resultsListItem'><span>Searching please wait</span></li>").appendTo(list);
	},

		/*Call service service/register-content-search-key-terms */
	_keySearch: function(){
		var self = this;
		$.getJSON(self._serviceUrl(myCollectionSearchKeyService), function(data){
			self._createTermList(data, "keyResultList", "key");
		});
	},

        /*Call service service/register-content-search-reg-terms */
	_regSearch: function(){
		var self = this;
		$.getJSON(self._serviceUrl(myCollectionRegSearchService), function(data){
			self._createTermList(data,"regResultList", "reg");
		});
	},



	/*write search result into lists*/
    _createTermList: function(json, listname, mode){
    	var self = this;
    	var list = $("#"+listname).empty();
    	if(json.results.length <= 0){var listitem = $("li class='resultsListItem'><span>No results found</span></li>").appendTo(list);}
        else {
            for (var c = 0; c < json.results.length; c++) {
                if (json.results[c].key) {
                    var listitem = $("<li class='resultsListItem'><span><a>" + json.results[c].term + "</a><sup class='key'> " + json.results[c].key + "</sup></span></li>").appendTo(list).click(function (e) {
                        self._CharterSearch(this.innerText, mode);
                    });
                }
                else {
                    var listitem = $("<li class='resultsListItem'><a>" + json.results[c].term + "</a></li>").appendTo(list).click(function (e) {
                        self._CharterSearch(this.innerText, mode);
                    });
                }
            }
        }
    },
    
    /*calls service service/register-search-charters, succuess reload page to show results. */
    _CharterSearch: function(clickedItem, mode){
    	var self = this;
    	$.ajax({
    		url: this._serviceUrl(myCollectionSearchGetChartersService),
    		data: {collection: this.options.collectionId, searchterm: clickedItem, type: mode, collectionType: self.options.collectionType},
    		dataType : "xml", 
    		success: function(data) {
    			location.reload();
            }
    	});
    }
    
 });
	

	
})( jQuery );