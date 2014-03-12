xquery version "3.0";

module namespace mom="http://www.monasterium.net/NS/mom";

declare namespace xrx="http://www.monasterium.net/NS/xrx";
declare namespace cei="http://www.monasterium.net/NS/cei";
declare namespace ead="urn:isbn:1-931666-22-9";

import module namespace metadata="http://www.monasterium.net/NS/metadata"
    at "../metadata/metadata.xqm";

declare function mom:statistics() {

    let $timestamp-current := datetime:timestamp(current-dateTime())
    let $timestamp-cached := xs:integer(cache:get('statistics', 'portal')//xrx:param[@name='timestamp']/text())
    let $outofdate := (($timestamp-current - $timestamp-cached) gt 86400000) or empty(cache:get('statistics', 'portal'))
    
    let $update :=
        if($outofdate) then
            (: metadata base collections :)
            let $metadata-archive-collection := metadata:base-collection('archive', 'public')
            let $metadata-fond-collection := metadata:base-collection('fond', 'public')
            let $metadata-collection-collection := metadata:base-collection('collection', 'public')
            let $metadata-charter-collection := metadata:base-collection('charter', 'public')
            (: statistics :)
            let $archives := count($metadata-archive-collection)
            let $fonds := count($metadata-fond-collection[.//ead:ead])
            let $collections := count($metadata-collection-collection)
            let $charters := count($metadata-charter-collection)
            let $graphics := count($metadata-charter-collection//cei:graphic/@url)
            let $statistics := 
                <xrx:statistics>
                    <xrx:param name="timestamp">{ datetime:timestamp(current-dateTime()) }</xrx:param>
                    <xrx:param name="archives">{ $archives }</xrx:param>
                    <xrx:param name="fonds">{ $fonds }</xrx:param>
                    <xrx:param name="collections">{ $collections }</xrx:param>
                    <xrx:param name="charters">{ $charters }</xrx:param>
                    <xrx:param name="graphics">{ $graphics }</xrx:param>
                </xrx:statistics>
            return
            cache:put('statistics', 'portal', $statistics)
        else()
    return
    cache:get('statistics', 'portal')
};