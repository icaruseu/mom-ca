
function createLegalDialog(requestRoot, charterid, owner, context){
		$("#insertOwner").append(owner);
	    $("#copy-legal-popUp").dialog({
			      				width: 500,
			      				buttons:{
									Cancel: function(){$(this).dialog("close");},
									"Accept": function(){
										callserviceMyCollectionsTree(requestRoot, charterid, owner, context);
										$(this).dialog("close");
									}
			      				}
	    	});
	    $(".ui-dialog-titlebar").hide();
};

function callserviceMyCollectionsTree(requestRoot, charterid, owner, context){	
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
			createSelectDialog(requestRoot, charterid, owner, context);
		}
	});
};


function callserviceMyCollectionCheckCharterExists(requestRoot, charterid){
	
	var MyCollectionCheckCharterExists = "my-collection-check-charter-exists";
	var selected_collection = $("#collectionSelect").val();
	if(selected_collection == ''){
		$("#Copy-Charter-Button").button('disable');
		$("#charterexistmessage").hide();
		}
	else{
	$.ajax({
		url: createServiceUrl(requestRoot, MyCollectionCheckCharterExists),
		type: "POST",
		data: {collection: selected_collection, charterid: charterid},
		dataType: "xml",
		success: function(data, textStatus, jqXHR){
			if($(data).find("result").text() == "true"){
				$("#charterexistmessage").show();
				$("#Copy-Charter-Button").button('disable');}
			else if($(data).find("result").text() == "false"){
				$("#charterexistmessage").hide();
				$("#Copy-Charter-Button").button('enable');}
		},
	});
	}
}

function createSelectDialog(requestRoot, charterid, owner, context) {
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
					 var self = $(this);
					callserviceMyCollectionCopyCharter(requestRoot, charterid, owner, context, self);
				}
			  }
			}
	});
    $(".ui-dialog-titlebar").hide();

	$("#Copy-Charter-Button").button('disable');
};

function createServiceUrl(requestRoot, service, charterid){ return requestRoot +"service/" +service};

function callserviceMyCollectionCopyCharter(requestRoot, charterid, owner, context, self){
	$("#copyinProgress").show();
	$("#Copy-Charter-Button").button('disable');
	$("#Cancel-Button").button('disable');
	var MyCollectionCopyCharter = "my-collection-copy-charter";
	var selected_collection = $("#collectionSelect").val();
	$.ajax({
		url: createServiceUrl(requestRoot, MyCollectionCopyCharter),
		type: "POST",
		data: {collection: selected_collection, charterid: charterid, owner: owner, context: context},
		dataType: "xml",
		success: function(data, textStatus, jqXHR){
			$("#copyinProgress").hide();
		    self.dialog("close");
			$("#Cancel-Button").button('enable');

		}
	});
};

