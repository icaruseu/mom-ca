var error = 0;

function changeStatus(fondID){
    var chooseTag = "Select-"+fondID;
    var divTag = "Entry-"+fondID;
    if(fondID == 'collection')
        var urlTag = "URL-"+fondID;
    var index = document.getElementById(chooseTag).selectedIndex;
    var status = document.getElementById(chooseTag).options[index].text;
    // send request to edit-DataProvider script
    var xmlhttp;
    if (window.XMLHttpRequest)
        {// code for IE7+, Firefox, Chrome, Opera, Safari
           xmlhttp=new XMLHttpRequest();
        }
    else
        {// code for IE6, IE5
            xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
        }
    if(fondID != 'collection')
        xmlhttp.open("GET","./"+fondID+"/service/edit-DataProvider?type="+status, true);
    else
        xmlhttp.open("GET","./service/edit-DataProvider?type="+status, true);
    xmlhttp.onreadystatechange=function(){
    if(xmlhttp.readyState==4)
      {
      if (xmlhttp.status==200)
          {
            if(fondID != 'collection')
                {
                if(xmlhttp.responseText == 'true')
                    document.getElementById('archive-URL').setAttribute('STYLE', 'display:block;');
                else
                    document.getElementById('archive-URL').setAttribute('STYLE', 'display:none;');
                 }
            if(status == 'enable')
                {
                document.getElementById(divTag).setAttribute('CLASS', 'resource-enabled');
                if(fondID == 'collection')
                    {
                    document.getElementById(urlTag).setAttribute('CLASS', 'URLenable');
                    document.getElementById(chooseTag).setAttribute('STYLE', 'top:8px;');
                    }
                else
                    document.getElementById(divTag).setAttribute('STYLE', 'height:100%;');
                }
            else
                {
                if(fondID == 'collection')
                    document.getElementById(urlTag).setAttribute('CLASS', 'URLdisable');
                document.getElementById(divTag).setAttribute('CLASS', 'resource-disabled');
                document.getElementById(chooseTag).setAttribute('STYLE', 'top:0px;');
                }
          }          
     else
          {
          error++;
          if(error < 20)
             changeStatus(fondID);
          else
             {
             error = 0;
             }
           }
       }
      };
     xmlhttp.send();
};

function prepareAdding(){
    $('#input-harvester').css('display', 'block');
    $('#input-harvester').val('');
    $('#save-harvester').css('display', 'block');
    $('#add-harvester').css('display', 'none');
};

function addHarvester(context){
    $('#input-harvester').css('display', 'none');
    var input = $('#input-harvester').val();
    $('#save-harvester').css('display', 'none');
    $('#add-harvester').css('display', 'block');
    // send request to edit-DataProvider script
    var xmlhttp;
    if (window.XMLHttpRequest)
        {// code for IE7+, Firefox, Chrome, Opera, Safari
           xmlhttp=new XMLHttpRequest();
        }
    else
        {// code for IE6, IE5
            xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
        }
    xmlhttp.open("GET","./service/edit-DataProvider?type=add-harvester&harvester="+input, true);
    xmlhttp.onreadystatechange=function(){
    if(xmlhttp.readyState==4)
      {
      if (xmlhttp.status==200)
          {
            var breadcrump = document.createElement("div");
            breadcrump.innerHTML = xmlhttp.responseText;
            document.getElementById('harvester-list').appendChild(breadcrump);
            if(context == 'archive')
                $('#fonds').css('display', 'block');
            else
                $('#collection').css('display', 'block');
          }          
     else
          {
          error++;
          if(error < 20)
             addHarvester();
          else
             {
             error = 0;
             }
           }
       }
      };
     xmlhttp.send();
};

function removeHarvester(harvesterID, context){
    // send request to edit-DataProvider script
    var xmlhttp;
    if (window.XMLHttpRequest)
        {// code for IE7+, Firefox, Chrome, Opera, Safari
           xmlhttp=new XMLHttpRequest();
        }
    else
        {// code for IE6, IE5
            xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
        }
    xmlhttp.open("GET","./service/edit-DataProvider?type=remove-harvester&harvester="+harvesterID, true);
    xmlhttp.onreadystatechange=function(){
    if(xmlhttp.readyState==4)
      {
      if (xmlhttp.status==200)
          {
            var old = document.getElementById(harvesterID);
            old.parentNode.removeChild(old);
            if(xmlhttp.responseText == 'false')
                {
                location.reload();
                }
          }          
     else
          {
          error++;
          if(error < 20)
             deleteHarvester(harvesterID, context);
          else
             {
             error = 0;
             }
           }
       }
      };
     xmlhttp.send();
};