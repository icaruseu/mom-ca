
function createLegalDialog(requestRoot, userid, charterid){
	    $("#copy-legal-popUp").dialog({
			      				width: 500,
			      				buttons:{
									Cancel: function(){$(this).dialog("close");},
									"Accept": function(){
										callserviceMyCollectionsTree(requestRoot, charterid ,charterid);
										$(this).dialog("close");
									}
			      				}
	    	});
};

function callserviceMyCollectionsTree(requestRoot, userid, charterid){	
	var MyCollectionsTree = "my-collections-tree";
	$.ajax({
		url: createServiceUrl(requestRoot, MyCollectionsTree),
		type: "GET",
		dataType: "json",
		success: function(data, textStatus, jqXHR){
	        $.each(data, function(key, value) { 
	        	var option = "<option value='"+key+"'>"+value.title+"</option>";
	        	$("#collectionSelect").append(option);
	        });
			createSelectDialog(requestRoot, userid, charterid);
		}
	});
};

function createSelectDialog(requestRoot, userid, charterid) {
	$('#select-collection-popUp').dialog({
	      width: 500,
			buttons:{
				Cancel: function(){$(this).dialog("close");},
				"Accept": function(){
					$(this).dialog("close");
					callserviceMyCollectionCopyCharter(requestRoot, userid, charterid);
				}
			}
	});
};

function createServiceUrl(requestRoot, service, charterid){ return requestRoot +"service/" +service};

function callserviceMyCollectionCopyCharter(requestRoot, userid, charterid){
	var MyCollectionCopyCharter = "my-collection-copy-charter";
	var selected_collection = $("#collectionSelect").val();
	console.log("charterid" +charterid);
	$.ajax({
		url: createServiceUrl(requestRoot, MyCollectionCopyCharter),
		type: "POST",
		data: {collection: selected_collection, charterid: charterid},
		dataType: "text",
		success: function(data, textStatus, jqXHR){
			console.log(data);
		}
	});
};

$.widget( "ui.dialogCopyToCollection", {
		   /*
			options: {
				
		
				requestRoot: "",
				userid: "",
				charterid: "",
				
			},
			*/
			//_serviceUrl: function(service){ return this.options.requestRoot + service; },
		    
			_create: function() {
				console.log("abfuck number 3");
			    //console.log(this);
				/*
				var self = this;
				this.legalDialog = $("#copy-legal-popUp");
				this.selectCollectionDialog = $('#select-collection-popUp');
				//this.Button = $("#copycollection").click(function(){self._createlegalDialog(self)});
				this.serviceMyCollectionsTree = "service/my-collections-tree";
				this.serviceMyCollectionCopyCharter = "service/my-collection-copy-charter";
			    */
			}
			/*
			
			_createlegalDialog: function(self){
				this.legalDialog.show();
				this.legalDialog.dialog({
				      modal: true,
				      width: 500,
						buttons:{
							Cancel: function(){$(this).dialog("close");},
							"Accept": function(){
								//self.callserviceMyCollectionsTree(self);
								$(this).dialog("close");
							}
							}
					
				});
			}
			
			createSelectDialog: function(self){
				this.selectCollectionDialog.show();
				this.selectCollectionDialog.dialog({
				      modal: true,
				      width: 500,
						buttons:{
							Cancel: function(){$(this).dialog("close");},
							"Accept": function(){
								$(this).dialog("close");
								//self.callserviceMyCollectionCopyCharter();
							}
							}
				});
			},
			
			callserviceMyCollectionCopyCharter: function(){
				var selected_collection = $("#collectionSelect").val();
				$.ajax({
					url: this._serviceUrl(this.serviceMyCollectionCopyCharter),
					type: "POST",
					data: {collection: selected_collection, charterid: this.options.charterid, context: this.options.context},
					dataType: "text",
					success: function(data, textStatus, jqXHR){
						console.log(data);
					}
				});
			},
			
			

			*/
			
		});