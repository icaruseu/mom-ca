xquery version "3.0";

module namespace generator="http://www.monasterium.net/NS/generator";

declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare namespace xrx="http://www.monasterium.net/NS/xrx";

declare function generator:reduce($node as node(), $xrx-xsd as element(xrx:xsd)) {

    typeswitch($node)
    case $annotation as element(xs:annotation) return ()
    case $element as element(xs:element) return
        if( $element/(@name|@ref)/string() = $xrx-xsd/xrx:generator/xrx:includetag/text()) then
            element { name($node) } {(
                $element/@*,
                for $child in $node/child::node()
                return
                generator:reduce($child, $xrx-xsd)
            )}
        else if($element/@minOccurs/string() = '0' or exists($element/parent::xs:choice/@minOccurs/string())) then ()
        else element { name($node) } {(
            $element/@*,
            for $child in $node/child::node()
            return
            generator:reduce($child, $xrx-xsd)
        )}
    case $other as element() return
        element { name($node) } {(
            $other/@*,
            for $child in $node/child::node()
            return
            generator:reduce($child, $xrx-xsd)
        )}
    default return ()
};

declare function generator:reduce-elements($schema as element(xs:schema), $node as node(), $xrx-xsd as element(xrx:xsd), $found as xs:string*) as element()* {

    let $reduced := generator:reduce($node, $xrx-xsd)
    let $referenced-element-names := $reduced//xs:element/@ref/string()
    return
    (
        $reduced,
        for $element-name in $referenced-element-names
        return
        if($element-name = $found) then ()
        else generator:reduce-elements($schema, $schema/xs:element[@name=$element-name], $xrx-xsd, ($found, $referenced-element-names, $reduced/@name/string()))
    )
};

declare function generator:attribute-groups($schema as element(xs:schema), $attribute-group-names as xs:string*, $xrx-xsd, $found as xs:string*) as element()* {

    for $attribute-group-name in $attribute-group-names
    let $reduced := generator:reduce($schema/xs:attributeGroup[@name=$attribute-group-name], $xrx-xsd)
    let $referenced-attribute-group-names := $reduced//xs:attributeGroup/@ref/string()
    return
    (
        $reduced,
        for $group-name in $referenced-attribute-group-names
        return
        if($group-name = $found) then ()
        else generator:attribute-groups($schema, $group-name, $xrx-xsd, ($found, $attribute-group-names))
    )
};

declare function generator:generate-schema($schema as element(xs:schema), $xrx-xsd as element(xrx:xsd)) as element() {

    let $root-element := $schema/xs:element[@name='cei']
    let $reduced-elements := generator:reduce-elements($schema, $root-element, $xrx-xsd, ())
    let $attribute-group-names := distinct-values($reduced-elements//xs:attributeGroup/@ref/string())
    return
    util:eval(
        concat(
            '<xs:schema xmlns="', 
            $xrx-xsd/xrx:generator/@defaultnamespace/string(), 
            '">{( $schema/@*, $reduced-elements, generator:attribute-groups($schema, $attribute-group-names, $xrx-xsd, $attribute-group-names) )}</xs:schema>'
        )
    )
};

