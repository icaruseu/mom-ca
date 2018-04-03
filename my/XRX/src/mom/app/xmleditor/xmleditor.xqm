xquery version "3.0";

module namespace xmleditor="http://www.monasterium.net/NS/xmleditor";

declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare namespace catalog="urn:oasis:names:tc:entity:xmlns:xml:catalog";
declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace skos="http://www.w3.org/2004/02/skos/core#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace tei="http://www.tei-c.org/ns/1.0/";

import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../xrx/conf.xqm";
import module namespace xrx="http://www.monasterium.net/NS/xrx"
    at "../xrx/xrx.xqm";
import module namespace assertion="http://www.monasterium.net/NS/assertion"
    at "../xrx/assertion.xqm";
import module namespace xsd="http://www.monasterium.net/NS/xsd"
    at "../xrx/xsd.xqm";
import module namespace data="http://www.monasterium.net/NS/data"
    at "../data/data.xqm";
    
import module namespace jsonx="http://www.monasterium.net/NS/jsonx"
    at "../xrx/jsonx.xqm";

declare variable $xmleditor:catalog := $xrx:live-project-db-base-collection/catalog:catalog;
declare variable $xmleditor:catalog-url := xs:anyURI(concat(util:collection-name($xmleditor:catalog), '/', util:document-name($xmleditor:catalog)));

declare function xmleditor:json-element-suggestions($xsd as element(xs:schema)) {

    let $namespace := $xsd/@targetNamespace/string()
    let $namespace-prefix := tokenize($namespace, '/')[last()]
    let $element-names := distinct-values($xsd//xs:element/@name/string())
    return
    jsonx:object(
        for $element-name in $element-names
        let $namespace-element-name := concat($namespace-prefix, ":", $element-name)
        let $child-element-names := xsd:child-element-names($element-name, $element-name, $xsd)
        return
        jsonx:pair(
            jsonx:string($namespace-element-name),
            jsonx:array(
                for $child-element-name in $child-element-names
                let $namespace-child-element-name := concat($namespace-prefix, ":", $child-element-name)
                return
                jsonx:string($namespace-child-element-name)
            )
        )
    )
};

declare function xmleditor:json-attribute-suggestions($xsd as element(xs:schema)) as xs:string {

    let $namespace := $xsd/@targetNamespace/string()
    let $namespace-prefix := tokenize($namespace, '/')[last()]
    return
    jsonx:object(
        for $element in $xsd//xs:element[@name]
        
        let $qname := concat($namespace-prefix, ':', $element/@name/string())
        let $attribute-elements := 
            (
                $element//xs:attribute,
                for $attribute-group in $element//xs:attributeGroup
                
                return
                xmleditor:attribute-elements-of-group($attribute-group/@ref/string(), (), $xsd)
            )
        where $qname != "cei:figure"(: das wird hier hart reingeschrieben, um zu vermeiden, dass in das figure Element @ eingetragen werden. by maburg .:)
        order by $element/@name
        
        return
        jsonx:pair(
            jsonx:string($qname),
                jsonx:array(
                    distinct-values(
                        for $attribute in $attribute-elements
                        order by $attribute/(@name|@ref)
                        return
                        jsonx:string($attribute/(@name|@ref)/string())
                    )
                )
            )
    )
};

declare function xmleditor:attribute-elements-of-group($attribute-group, $found, $xsd) {

    let $attribute-group-element := $xsd/xs:attributeGroup[@name=$attribute-group]
    let $groups := $attribute-group-element/xs:attributeGroup
    let $attributes := $attribute-group-element/xs:attribute
    return
    (
        $attributes,
        for $group in $groups
        return
        if($group intersect $found) then ()
        else xmleditor:attribute-elements-of-group($group/@ref/string(), ($group, $found), $xsd)
    )
};

declare function xmleditor:json-element-topics($xrx-schema as element(xrx:xsd)) {

    jsonx:object(
        for $element in $xrx-schema/xrx:elements/xrx:element
        let $element-name := $element/@name/string()
        let $topic := if($element/xrx:topic/text()) then $element/xrx:topic/text() else '#'
        return
        jsonx:pair(
            jsonx:string($element-name),
            jsonx:string($topic)
        )
    )
    
};


declare function xmleditor:validation-report-message($message as xs:string) as xs:string* {

    assertion:translate($message)
};

declare function xmleditor:validation-report($instance as element()) {

    let $report := validation:xrx-instance($instance, false(), $xmleditor:catalog-url)
    return
    jsonx:object((
        jsonx:pair(
            jsonx:string("status"),
            jsonx:string(xs:string($report/status/text()))
        ),
        jsonx:pair(
            jsonx:string("duration"),
            jsonx:string(concat($report/duration/text(), $report/duration/@unit/string()))
        ),
        jsonx:pair(
            jsonx:string("length"),
            jsonx:string(xs:string(count($report/message)))
        ),
        if(exists($report/message)) then
            jsonx:pair(
                jsonx:string("messages"),
                jsonx:object(
                    for $message in $report/message
                    let $nodeId := $message/@nodeId/string()
                    let $text := xmleditor:validation-report-message(xs:string($message/text()))
                    return
                    jsonx:pair(
                        jsonx:string($nodeId),
                        jsonx:array(
                                for $entry in $text
                                    let $returner := $entry
                                    return
                                    jsonx:string($returner)
                                
                        )
                    )

                    
                )
            )
        else()
    ))
};

declare function xmleditor:vocabularasjson($rdf as xs:string, $vocabular){   
    jsonx:object(
            let $getlang := substring($xrx:lang, 0,3)
            let $label := jsonx:string( if($vocabular//skos:Concept[@rdf:about=$rdf]/skos:prefLabel/@xml:lang= $getlang)
                                        then (
                                        normalize-space($vocabular//skos:Concept[@rdf:about=$rdf]/skos:prefLabel[@xml:lang= $getlang]/text()))
                                        else(normalize-space($vocabular//skos:Concept[@rdf:about=$rdf]/skos:prefLabel[1]/text()))
                                        )
            let $labelling := jsonx:pair(jsonx:string("label"), $label)
            let $objectcontent := for $g in $vocabular//skos:Concept[skos:broader/@rdf:resource = $rdf][child::skos:prefLabel]
                            let $newrdf := data($g/@rdf:about)
                            let $key := jsonx:string(substring-after(normalize-space($newrdf), '#'))
                            let $value := if($g/skos:prefLabel/@xml:lang= $getlang) then normalize-space($g/skos:prefLabel[@xml:lang= $getlang]/text()) else(normalize-space($g/skos:prefLabel[1]/text()))
                            order by $g/@rdf:about
                            return 
                            if($g/skos:narrower | $vocabular//skos:broader[@rdf:resource = $newrdf]) then 
                            let $iterate := xmleditor:vocabularasjson($newrdf, $vocabular)
                            return jsonx:pair($key, $iterate)
                            else( 
                            let $pairs := jsonx:pair($key, jsonx:string($value))
                            return 
                             $pairs
                            )                         
            return if(empty($objectcontent)) then $labelling
            else( concat($labelling, ',', string-join($objectcontent, ',')))
                         
                         )
            
          
 };
