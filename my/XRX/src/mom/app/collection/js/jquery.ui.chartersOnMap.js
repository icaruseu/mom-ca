function createPageList(requestroot , steps, range, actualpos, place) {
    $list = $("<ul id='pageList'></ul>");
    lastpos = range / steps;
    for (counter = 0; counter < lastpos; counter++) {
        startpos = counter * parseInt(steps,10) + 1;
        endpos = startpos + parseInt(steps,10) - 1;

        var text;
        if (endpos < range) {text =+startpos+"-"+endpos;}
        else if (startpos == range) {text = startpos;}
        else {text = startpos+"-"+range;};
        position = parseInt(counter)+1;
        var $listitem;
        if (position == actualpos){
            $listitem = $("<li class='pagenumber hili' pos='"+position +"'>["+text+"]</li>")
        }
        else {
            $listitem = $("<li class='pagenumber' pos='" + position + "'><a>[" + text + "]</a></li>").click(function (e) {
                newpos = parseInt($(this).attr("pos"));
                get_charters(requestroot, place, newpos, steps, range)
            });
        }
        $list.append($listitem);
    }
    $("#resultpages").append($list);
};

function get_charters(requestroot, place, position, steps, range){
    $.ajax({
        type: "GET",
        dataType: "xml",
        url: requestroot + "service/geolocations-charter-results",
        data:{clickedLocation: place, pos: position, steps: steps},
        success: function(data){
            url = $(location).attr("href");
            linkroot = url.substr(0, url.indexOf("?"));
            window.location.href = linkroot+"?place="+place+"&count="+range+"&pos="+position+"&steps="+step+"#results";
            },
        error:function(jqHXR, textStatus, errorThrown){
            console.log(jqHXR, textStatus, errorThrown);
        }
    });
}