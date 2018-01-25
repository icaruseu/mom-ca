
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
	        $.each(data, function(key, value) { 
	        	var option = "<option value='"+key+"'>"+value.title+"</option>";
	        	$("#collectionSelect").append(option);
	        });
			createSelectDialog(requestRoot, charterid, owner);
		}
	});
};

function createSelectDialog(requestRoot, charterid, owner) {
	$('#select-collection-popUp').dialog({
	      width: 500,
			buttons:{
				Cancel: function(){$(this).dialog("close");},
				"Accept": function(){
					$(this).dialog("close");
					callserviceMyCollectionCopyCharter(requestRoot, charterid, owner);
				}
			}
	});
};

function createServiceUrl(requestRoot, service, charterid){ return requestRoot +"service/" +service};

function callserviceMyCollectionCopyCharter(requestRoot, charterid, owner){
	var MyCollectionCopyCharter = "my-collection-copy-charter";
	var selected_collection = $("#collectionSelect").val();
	console.log("charterid" +charterid);
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

