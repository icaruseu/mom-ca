/** functions to create a List for result Pages and to get data for charters **/


/** Create a List for Result-Pages,  **/
function createPageList(requestroot , steps, range, actualpos, place, latlng, actualzoom) {
    $list = $("<ul id='pageList'></ul>");
    lastpos = range / steps;
    for (counter = 0; counter < lastpos; counter++) {
        startpos = counter * parseInt(steps,10) + 1;
        endpos = startpos + parseInt(steps,10) - 1;
        var text;

        /** create Page entries, for all 5 results create a new Page entry.  **/
        if (endpos < range) {text =+startpos+"-"+endpos;}
        else if (startpos == range) {text = startpos;}
        else {text = startpos+"-"+range;};
        position = parseInt(counter)+1;
        var $listitem;
        if (position == actualpos){
            $listitem = $("<li class='pagenumber hili' pos='"+position +"'>["+text+"]</li>")
        }
        else {
            $listitem = $("<li class='pagenumber' pos='" + position + "'><a href='#'>[" + text + "]</a></li>").click(function (e) {
                newpos = parseInt($(this).attr("pos"));
                get_charters(requestroot, place, newpos, steps, range, latlng, actualzoom)
            });
        }
        $list.append($listitem);
    }
    $("#resultpages").append($list);
};


/** when user clicks on an page entrie start a ajax-call for the service geolocations-charter-results.service.xml
 * service is located in ../geoservices/service **/
function get_charters(requestroot, place, position, steps, range, latlng, actualZoom){
    $.ajax({
        type: "GET",
        dataType: "xml",
        url: requestroot + "service/geolocations-charter-results",
        data:{clickedLocation: place, pos: position, steps: steps},
        success: function(data){
            url = $(location).attr("href");
            linkroot = url.substr(0, url.indexOf("?"));
            window.location.href = linkroot+"?place="+place+"&count="+range+"&pos="+position+"&steps="+steps+"&mapview="+latlng+"&zoom="+actualZoom+"#results";
            },
        error:function(jqHXR, textStatus, errorThrown){
            console.log(jqHXR, textStatus, errorThrown);
        }
    });
}