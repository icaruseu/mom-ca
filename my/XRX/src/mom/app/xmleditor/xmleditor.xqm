xquery version "3.0";

module namespace xmleditor="http://www.monasterium.net/NS/xmleditor";

declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare namespace catalog="urn:oasis:names:tc:entity:xmlns:xml:catalog";

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


declare variable $xmleditor:catalog := $xrx:live-project-db-base-collection/catalog:catalog;
declare variable $xmleditor:catalog-url := xs:anyURI(concat(util:collection-name($xmleditor:catalog), '/', util:document-name($xmleditor:catalog)));

    
declare function xmleditor:json-object($pairs as xs:string+) as xs:string {
    
    concat('{', string-join($pairs, ',') ,'}')
};

declare function xmleditor:json-array($sequence as xs:string*) as xs:string {

    concat('[', string-join($sequence, ','), ']')
}; 

declare function xmleditor:json-string($string as xs:string) as xs:string {
    
    concat('"', replace(replace($string, "'", "`"), '"', "`"), '"')
};

declare function xmleditor:json-pair($key as xs:string, $value as xs:string) as xs:string {

    concat($key, ":", $value)
};

declare function xmleditor:json-element-suggestions($xsd as element(xs:schema)) {

    let $namespace := $xsd/@targetNamespace/string()
    let $namespace-prefix := tokenize($namespace, '/')[last()]
    let $element-names := distinct-values($xsd//xs:element/@name/string())
    return
    xmleditor:json-object(
        for $element-name in $element-names
        let $namespace-element-name := concat($namespace-prefix, ":", $element-name)
        let $child-element-names := xsd:child-element-names($element-name, $element-name, $xsd)
        return
        xmleditor:json-pair(
            xmleditor:json-string($namespace-element-name),
            xmleditor:json-array(
                for $child-element-name in $child-element-names
                let $namespace-child-element-name := concat($namespace-prefix, ":", $child-element-name)
                return
                xmleditor:json-string($namespace-child-element-name)
            )
        )
    )
};

declare function xmleditor:json-attribute-suggestions($xsd as element(xs:schema)) as xs:string {

    let $namespace := $xsd/@targetNamespace/string()
    let $namespace-prefix := tokenize($namespace, '/')[last()]
    return
    xmleditor:json-object(
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
        xmleditor:json-pair(
            xmleditor:json-string($qname),
                xmleditor:json-array(
                    distinct-values(
                        for $attribute in $attribute-elements
                        order by $attribute/(@name|@ref)
                        return
                        xmleditor:json-string($attribute/(@name|@ref)/string())
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

    xmleditor:json-object(
        for $element in $xrx-schema/xrx:elements/xrx:element
        let $element-name := $element/@name/string()
        let $topic := if($element/xrx:topic/text()) then $element/xrx:topic/text() else '#'
        return
        xmleditor:json-pair(
            xmleditor:json-string($element-name),
            xmleditor:json-string($topic)
        )
    )
    
};

(: neue Funktion für attr Values 
declare function xmleditor:json-attr-values($xrx-schemaV as element(xrx:xsd)) {   
    xmleditor:json-object(
    let $cl := "cei:class"
    return
    xmleditor:json-pair(  
    xmleditor:json-string("type"), 
    xmleditor:json-array( 
    return   
    xmleditor:json-string("papsturkunde"),
    xmleditor:json-string("königsurkunde"),
    xmleditor:json-string("sammelindulgenz")
    )
    )
    )
};:)

declare function xmleditor:validation-report-message($message as xs:string) as xs:string {

    assertion:translate($message)
};

declare function xmleditor:validation-report($instance as element()) {

    let $report := validation:xrx-instance($instance, false(), $xmleditor:catalog-url)
    return
    xmleditor:json-object((
        xmleditor:json-pair(
            xmleditor:json-string("status"),
            xmleditor:json-string(xs:string($report/status/text()))
        ),
        xmleditor:json-pair(
            xmleditor:json-string("duration"),
            xmleditor:json-string(concat($report/duration/text(), $report/duration/@unit/string()))
        ),
        xmleditor:json-pair(
            xmleditor:json-string("length"),
            xmleditor:json-string(xs:string(count($report/message)))
        ),
        if(exists($report/message)) then
            xmleditor:json-pair(
                xmleditor:json-string("messages"),
                xmleditor:json-object(
                    for $message in $report/message
                    let $nodeId := $message/@nodeId/string()
                    let $text := xmleditor:validation-report-message(xs:string($message/text()))
                    return
                    xmleditor:json-pair(
                        xmleditor:json-string($nodeId),
                        xmleditor:json-string($text)
                    )
                )
            )
        else()
    ))
};
