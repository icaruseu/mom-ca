xquery version "3.0";

module namespace augiasviewer="http://www.monasterium.net/NS/augiasviewer";



import module namespace xrx="http://www.monasterium.net/NS/xrx"
    at "../xrx/xrx.xqm";
import module namespace charter="http://www.monasterium.net/NS/charter"
    at "../charter/charter.xqm";
import module namespace metadata="http://www.monasterium.net/NS/metadata"
    at "../metadata/metadata.xqm";



declare function augiasviewer:link($atomid as xs:string*) as xs:string {

    if($atomid) then
        let $context := charter:context($atomid)
        return
        concat('/augias/viewer.xql?lang=',
            $xrx:lang,
            '&amp;imagedata=/mom/service/augiasviewer',
            if($context = 'fond') then
            concat(
                '&amp;archive-id=',
                charter:archid($atomid), 
                '&amp;fond-id=', 
                charter:fondid($atomid)
            )
            else
            concat(
                '&amp;collection-id=',
                charter:collectionid($atomid)
            ),
            '&amp;charter-id=',
            metadata:objectid($atomid)
        )
    else ''
};