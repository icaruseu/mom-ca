
function createLegalDialog(requestRoot, charterid, owner){
		$("#insertOwner").append(owner);
	    $("#copy-legal-popUp").dialog({
			      				width: 500,
			      				buttons:{
									Cancel: function(){$(this).dialog("close");},
									"Accept": function(){
										callserviceMyCollectionsTree(requestRoot, charterid, owner);
										$(this).dialog("close");
									}
			      				}
	    	});
};

function callserviceMyCollectionsTree(requestRoot, charterid, owner){	
	var MyCollectionsTree = "my-collections-tree";
	$.ajax({
		url: createServiceUrl(requestRoot, MyCollectionsTree),
		type: "GET",
		dataType: "json",
		success: function(data, textStatus, jqXHR){
			$("#collectionSelect").empty();
			var defaultOption = "<option>Select Collection</option>";
			$("#collectionSelect").append(defaultOption);
	        $.each(data, function(key, value) {	        
	        	var option = "<option value='"+key+"'>"+value.title+"</option>";
	        	$("#collectionSelect").append(option);
	        	$("#collectionSelect").change(function(){
	        		callserviceMyCollectionCheckCharterExists(requestRoot, charterid)
	        	})
	        });
			createSelectDialog(requestRoot, charterid, owner);
		}
	});
};


function callserviceMyCollectionCheckCharterExists(requestRoot, charterid){
	var MyCollectionCheckCharterExists = "my-collection-check-charter-exists";
	var selected_collection = $("#collectionSelect").val();
	$.ajax({
		url: createServiceUrl(requestRoot, MyCollectionCheckCharterExists),
		type: "POST",
		data: {collection: selected_collection, charterid: charterid},
		dataType: "text",
		success: function(data, textStatus, jqXHR){
			if(data == "true"){$("#Copy-Charter-Button").button('disable');}
			else if(data == "false"){$("#Copy-Charter-Button").button('enable');}
		}
	});
}

function createSelectDialog(requestRoot, charterid, owner) {
	$('#select-collection-popUp').dialog({
	      width: 500,
			buttons:{
				"Cancel": { text:"Cancel",
						    id: "Cancel-Button",
						    click: function(){$(this).dialog("close");}
				},
				"CopyCharter": {
					text: "Copy Charter",
					id: "Copy-Charter-Button",
					click: function(){
				    $(this).dialog("close");
					callserviceMyCollectionCopyCharter(requestRoot, charterid, owner);
				}
			  }
			}
	});
	$("#Copy-Charter-Button").button('disable');
};

function createServiceUrl(requestRoot, service, charterid){ return requestRoot +"service/" +service};

function callserviceMyCollectionCopyCharter(requestRoot, charterid, owner){
	var MyCollectionCopyCharter = "my-collection-copy-charter";
	var selected_collection = $("#collectionSelect").val();
	$.ajax({
		url: createServiceUrl(requestRoot, MyCollectionCopyCharter),
		type: "POST",
		data: {collection: selected_collection, charterid: charterid, owner: owner},
		dataType: "text",
		success: function(data, textStatus, jqXHR){
			console.log(data);
		}
	});
};

