xquery version "3.0";
(:~
This is a component file of the VdU Software for a Virtual Research Environment for the handling of Medieval charters.

As the source code is available here, it is somewhere between an alpha- and a beta-release, may be changed without any consideration of backward compatibility of other parts of the system, therefore, without any notice.

This file is part of the VdU Virtual Research Environment Toolkit (VdU/VRET).

The VdU/VRET is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

VdU/VRET is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with VdU/VRET.  If not, see <http://www.gnu.org/licenses/>.

We expect VdU/VRET to be distributed in the future with a license more lenient towards the inclusion of components into other systems, once it leaves the active development stage.
:)

(:author daniel.ebner@uni-koeln.de:)

module namespace qxsd="http://www.monasterium.net/NS/qxsd";



(: ################# IMOPORT MODULES #################:)

import module namespace xrxe-conf="http://www.monasterium.net/NS/xrxe-conf" at "../editor/xrxe-conf.xqm";

(: ################# DECLARE NAMESAPCES #################:)

declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace xrxe="http://www.monasterium.net/NS/xrxe";
declare namespace functx = "http://www.functx.com";


(:#####################SERVICES BY PATH ############################:)

(: ### returns the <xs:element or xs:attribute ref="..." or name="..."> for the path ###:)
declare function qxsd:get-node($path, $xsd){
    let $path := qxsd:get-path($path)
    let $xsd := qxsd:xsd($xsd)
    return qxsd:find-node(qxsd:tokenize-path($path), $xsd,  1, $xsd)

};

(: ### returns the <xs:element or xs:attribute name="..."> for the path resolves xs:element@ref if occures ###:)
declare function qxsd:get-node-definition($path, $xsd){
    let $xsd := qxsd:xsd($xsd)
    let $node := qxsd:get-node($path, $xsd)
    return  qxsd:node-definition($node, $xsd)
};

declare function qxsd:get-node-content($path, $xsd){
    let $xsd := qxsd:xsd($xsd)
    let $type := qxsd:get-type(qxsd:get-node-definition($path, $xsd), $xsd)
    return qxsd:get-content($type, $xsd)
};

declare function qxsd:get-node-elements($path, $xsd){
    let $xsd := qxsd:xsd($xsd)
    let $type := qxsd:get-type(qxsd:get-node-definition($path, $xsd), $xsd)
    let $content := qxsd:get-content($type, $xsd)
    return qxsd:get-elements($content, $xsd)
};

declare function qxsd:get-node-attributes($path, $xsd){
    let $xsd := qxsd:xsd($xsd)
    let $node := qxsd:get-node-definition($path, $xsd)
    let $type := qxsd:get-type(qxsd:get-node-definition($path, $xsd), $xsd)
    return qxsd:get-attributes($type, $xsd)
};

(: ################# QXSD UTIL #################:)

(:### skips the empty token at first position when path begings with an /###:)
declare function qxsd:tokenize-path($path){
     let $tokenize := tokenize($path, '/')
     return if ($tokenize[1]='') then
        remove($tokenize, 1)
    else $tokenize
};

(: ### gets the xsd-node out of a database doc or collection(by id) ###:)
(: ### TODO: Dublicated from xrxe:get-node--> generate module on top off both to use functions together###:)

declare function qxsd:find($something)

{
    if($something instance of xs:string) then
        if (exists(doc($something))) then
            doc($something)/element()
        else if (collection($xrxe-conf:default-search-id-in)/*[@id=$something]) then
            collection($xrxe-conf:default-search-id-in)/*[@id=$something]
        else ()


    else if ($something instance of node()) then
        if($something instance of document-node()) then
            $something/element()
        else
            $something
    else
        ()
};

(: ################# PATH  #################:)


(: ### be sure to get a path expression qxsd is expacting ### :)
(: ### remove alle [...] constrains  ###:)
(: ### The context-xpath is considered to consists off simple child steps a/b/c :)

declare function qxsd:get-path($context as xs:string)
as xs:string
{
    (:TODO: fails if [...] contains '/' in the steps other than the last:)
    (:handle [/] at last step:)
    let $context :=
        if (fn:contains($context, '[')) then
             fn:substring-before($context, '[')
        else
             $context

    let $context :=
        if (contains($context, '[')) then
            fn:string-join(
                     for $token in tokenize($context, '/')
                         return
                             if(contains($token, '[')) then
                                 fn:substring-before($token, '[')
                             else $token
                , '/')
         else
            $context
     return $context
};

(: ################# NAMES  #################:)

(: ### be sure to the name of a node/element out off a path/context ### :)
(: ### part of the path after the last / ###:)
(: ### at the moment for element-names only check if to join with attributes (qxsd:get-attribute-name)### :)

declare function  qxsd:get-name($path as xs:string)
{
    let $path := qxsd:get-path($path)

    let $name :=
        if (fn:contains($path, '/')) then
            let $tokens := tokenize($path, '/')
            return $tokens[count($tokens)]
            (:tokenize($path, '/')[last()]:)
        else
            $path

    let $name :=
        if (fn:contains($name, '@')) then
            fn:substring-after($name, '@')
        else $name

    return $name
};

(: ### removes the @ that exists from the attributs path to get the attributes name ###:)

(:declare function qxsd:get-attribute-name($att-name as xs:string)
as xs:string
{
    let $name :=
        if (fn:contains($att-name, '@')) then
            fn:substring-after($att-name, '@')
        else $at-name
    return $name
};:)

(:### returns the local name off a nodes name by removing the prefix: off a name if it exists ###:)

declare function qxsd:get-local-name($name as xs:string)
as xs:string
{
    let $name := qxsd:get-name($name)
    return
    if (fn:contains($name, ':')) then
           substring-after($name, ':')
     else
        $name
};

(:### returns the prefix off a nodes name by removing the :local-name off a name if it exists ###:)
declare function qxsd:get-prefix($name as xs:string)
{
    if (fn:contains($name, ':')) then
           substring-before($name, ':')
     else ()
};


(: ################# HANDLE XS:SCHEMA  #################:)

(:### return the xs:schema-node ###:)
declare function qxsd:xsd($xsd)
{
    let $xsd :=
        if($xsd instance of element(xs:schema)) then
            $xsd
        else if($xsd instance of document-node() and $xsd/xs:schema) then
            $xsd/xs:schema
        else
            qxsd:find($xsd)

     return $xsd
     (:return <div>{
     qxsd:get-absolute-db-path(util:collection-name($xsd), '../../xlink/xsd/xlink.xsd')
     }</div>:)



};

declare function functx:substring-after-last
  ( $arg as xs:string? ,
    $delim as xs:string )  as xs:string {

   replace ($arg,concat('^.*',functx:escape-for-regex($delim)),'')
 } ;

 declare function functx:escape-for-regex
  ( $arg as xs:string? )  as xs:string {

   replace($arg,
           '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')
 } ;

declare function qxsd:get-schema-location($xsd, $import){

    let $location := xs:string($import/@schemaLocation)
    return
        if(starts-with($location, 'http://')) then
            $location
        else if(starts-with($location, '..')) then
            qxsd:get-absolute-db-path(util:collection-name($xsd), $location)
        else if($location) then
            concat(qxsd:get-schema-db-context($xsd), $location)
        else
            ()
};

declare function qxsd:get-absolute-db-path($absolute-path, $relative-path){


     let $relative-path-tokens := tokenize($relative-path, '/')
     let $ups := count($relative-path-tokens[.='..'])
     let $absolute-path-tokens := tokenize($absolute-path, '/')
     let $count-absoulte := count($absolute-path-tokens)
     let $part-count := $count-absoulte - $ups
     let $head := fn:subsequence($absolute-path-tokens, 1, $part-count)
     let $tail := $relative-path-tokens[.!='..']
     let $db-path := fn:string-join(($head, $tail), '/')
     return
        $db-path

};

declare function qxsd:get-schema-db-context($xsd){
    let $xsd-context := util:collection-name($xsd)
    return
        if($xsd-context !='') then
            concat($xsd-context, '/')
        else
            $xsd-context
};

(: ################# QUERY XS:SCHEMA  ################# :)

declare function qxsd:get-target-namespace($xsd){
    xs:string($xsd/@targetNamespace)
};

declare function qxsd:get-attribute-form-default($xsd){
    xs:string($xsd/@attributeFormDefault)
};


(: ######################################################################################################################:)
(: ##########***  FIND NODES (XS:ELEMENT OR XS:ATTRIBUTE) IN THE XS:SCHEMA NODE BY SIMPLE PATH-EXPRESSION  ***###########:)

declare function qxsd:find-node($tokenize, $ancestor, $pos, $xsd){


           let $part := $tokenize[$pos]
           let $context := qxsd:find-context($ancestor, $part, $xsd)
           let $name := qxsd:get-name($part)
           let $current-node := qxsd:find-current-node($part, $name, $context, $xsd)

           return
                if($pos = count($tokenize)) then
                     $current-node
                else if ($current-node) then
                     qxsd:find-node($tokenize, qxsd:node-definition($current-node, $xsd)  , $pos + 1, $xsd)
                else
                     ()
};


declare function qxsd:find-context($ancestor, $part, $xsd){
    if($ancestor instance of element (xs:schema)) then
        $ancestor
    else
        let $type := qxsd:get-type($ancestor, $xsd)
        return
        if(qxsd:is-attribute-part($part)) then
            $type
        else
           qxsd:get-content($type, $xsd)
};


declare function qxsd:find-current-node($part, $name, $context, $xsd){
    if(qxsd:is-attribute-part($part)) then
        qxsd:find-attribute($context, $name, $xsd)
    else
       let $local-name := qxsd:get-local-name($name)
       return
       qxsd:find-element($context, $local-name, $xsd)
};

declare function qxsd:is-attribute-part($part){
        if(starts-with($part, '@')) then
            true()
        else
            false()
};

(:searches and element in xs:schema, xs:sequence xs:all xs:choice and xs:group:)

declare function qxsd:find-element($context, $name, $xsd){

    let $element :=
        if($context/xs:element[xs:string(@name) = $name]) then
            $context/xs:element[xs:string(@name) = $name]
        else if ($context/xs:element[xs:string(@ref) = $name]) then
             $context/xs:element[xs:string(@ref) = $name]
        else
            let $content-model-items := $context/xs:sequence | $context/xs:choice | $context/xs:all | $context/xs:group
            for $content-model-item in  $content-model-items
            return
                if ($content-model-item instance of element(xs:sequence) or $content-model-item instance of element(xs:choice) or $content-model-item instance of element(xs:all)) then
                    qxsd:find-element($content-model-item, $name, $xsd)
                else if ($content-model-item instance of element(xs:group)) then
                    let $group-definition := qxsd:group-definition($content-model-item, $xsd)
                    let $group-context := qxsd:get-content($group-definition, $xsd)
                    return
                    qxsd:find-element($group-context, $name, $xsd)
                else ()

    return $element[1]

};



declare function qxsd:find-element($context, $name, $xsd){

    let $element :=
        if($context/xs:element[xs:string(@name) = $name]) then
            $context/xs:element[xs:string(@name) = $name]

        else if ($context/xs:element[xs:string(@ref) = $name]) then
             $context/xs:element[xs:string(@ref) = $name]

        else

            for $content-model-item in  $context/xs:sequence | $context/xs:choice | $context/xs:all | $context/xs:group
            return
                if ($content-model-item instance of element(xs:sequence) or $content-model-item instance of element(xs:choice) or $content-model-item instance of element(xs:all)) then
                    qxsd:find-element($content-model-item, $name, $xsd)
                else if ($content-model-item instance of element(xs:group)) then
                    qxsd:find-element(qxsd:get-content(qxsd:group-definition($content-model-item, $xsd), $xsd), $name, $xsd)
                else ()

    return $element

};

(: ##########*** RESOLVE REFS  ***###########:)

(: ### returns the <xs:group name="..."> of a xs:group/@ref xs:group/@name ###:)
declare function qxsd:group-definition($group, $xsd){
        if($group/@name) then
            $group
        else if($group/@ref) then
            qxsd:group-global-definition($group, $xsd)
        else
            ()
};

declare function qxsd:group-global-definition($group, $xsd){

            let $name := xs:string($group/@ref)
            let $xsd := qxsd:get-xsd($name, $xsd)
            let $local-name := qxsd:get-local-name($name)
            return
                $xsd/xs:group[@name=$local-name]
};

(: ### returns the <xs:element name="..."> of a xs:element/@ref xs:element/@name or string ###:)
declare function qxsd:node-definition($node, $xsd){

    if($node/@name) then
        $node
    else if($node/@ref) then
        qxsd:node-global-definition($node, $xsd)
    else ()
};

declare function qxsd:node-global-definition($node, $xsd){

        let $name := xs:string($node/@ref)
        let $xsd := qxsd:get-xsd($name, $xsd)
        let $local-name := qxsd:get-local-name($name)
        return
            if(qxsd:get-node-type($node)='element') then
                $xsd/xs:element[@name=$local-name]
            else if (qxsd:get-node-type($node)='attribute') then
                $xsd/xs:attribute[@name=$local-name]
            else
                ()
};



(: ### returns the type of a element either a string like 'xs:string', a <xs:complyType /> or a <xs:simpleType />### :)
declare function qxsd:get-type($node, $xsd)
{
    if ($node/@type) then
         if(qxsd:is-xs-datatype($node/@type)) then
           qxsd:get-xs-datatype-string($node/@type)
         else
            qxsd:type-global-definition($node/@type, $xsd)
    else if($node/xs:complexType) then
        $node/xs:complexType
    else if($node/xs:simpleType) then
        $node/xs:simpleType
    else
        ()(:'xs:anySimpleType':)
};


declare function qxsd:type-global-definition($type, $xsd){

        let $name := xs:string($type)
        let $xsd := qxsd:get-xsd($name, $xsd)
        let $local-name := qxsd:get-local-name($name)
        return
        if($xsd/xs:complexType[@name = $local-name]) then
            $xsd/xs:complexType[@name = $local-name]
        else  if($xsd/xs:simpleType[@name = $local-name]) then
            $xsd/xs:simpleType[@name = $local-name]
        else
            ()
};

(: ################################# CONTENT #####################################################################################:)

(:$parent is xs:complexType or xs:group:)
declare function qxsd:get-content($parent, $xsd){
    (:exactly 1:)
    if($parent instance of element()) then
    ($parent/xs:sequence | $parent/xs:choice | $parent/xs:all | qxsd:group-definition($parent/xs:group, $xsd))[1]
    else
        ()
};

declare function qxsd:get-elements($parent, $xsd){
    for $content-model-item in qxsd:get-content-model-items($parent)
        return qxsd:get-elements-of-content-model-item($content-model-item, $xsd)
};

declare function qxsd:get-content-model-items($content-definition){
    $content-definition/xs:element | $content-definition/xs:group | $content-definition/xs:sequence  |  $content-definition/xs:choice | $content-definition/xs:all
};

declare function qxsd:get-elements-of-content-model-item($content-model-item, $xsd){
        if ($content-model-item instance of element(xs:element)) then
            qxsd:node-definition($content-model-item, $xsd)
        else if ($content-model-item instance of element(xs:group)) then
            qxsd:get-elements(qxsd:group-definition($content-model-item, $xsd), $xsd)
        else if ($content-model-item instance of element(xs:sequence) or $content-model-item instance of element(xs:choice) or $content-model-item instance of element(xs:all)) then
            qxsd:get-elements($content-model-item, $xsd)
        else ()
};

(: ################################ ATTRIBUTES ###########################################:)

declare function qxsd:get-attribute-items($type, $xsd){
    $type/xs:attribute | $type/xs:attributeGroup
};

declare function qxsd:get-attributes($parent, $xsd){

    for $attribute-item in qxsd:get-attribute-items($parent, $xsd)
        return qxsd:get-attributes-of-attribute-item($attribute-item, $xsd)
};

declare function qxsd:get-attributes-of-attribute-item($attribute-item, $xsd){
    if ($attribute-item instance of element(xs:attribute)) then
        qxsd:node-definition($attribute-item, $xsd)
    else if ($attribute-item instance of element(xs:attribute-group)) then
        qxsd:get-attributes($attribute-item, $xsd)
    else ()
};


(: ######################################################################################################################:)

(: ################# QUERY ELEMENT CONTENT #################:)



(: Make deprecated:)
declare function qxsd:get-local-elements($type){
    if($type instance of element()) then
        for  $element in $type//xs:element (:constrain be sure that the xs:element is not in another xs:element when using //:)
            return
                $element

    else ()

};

(: Make deprecated:)
declare function qxsd:get-groups($type){
    if($type instance of element()) then
        for  $group in $type//xs:group  (:constrain ????? //:)
            return
                $group
    else ()
};

(: Make deprecated:)
declare function qxsd:get-group-definitions($type, $xsd){
        for $group in qxsd:get-groups($type)
        return qxsd:group-definition($group, $xsd)
};



declare function qxsd:get-group-elements($group-definitions, $xsd){

        for $group-definition in $group-definitions

            let $group-local-elements := $group-definition//xs:element

            let $groups-in-group := $group-definition//xs:group
            let $group-defs :=
                for $group-in-group in $groups-in-group
                return qxsd:group-definition($group-in-group, $xsd)

            let $group-group-elements :=
                for $group-def in  $group-defs
                    return qxsd:get-group-elements($group-def, $xsd)
         return ($group-local-elements, $group-group-elements)

};



declare function qxsd:get-node-definitions($nodes, $xsd){
        for $node in $nodes
            return qxsd:node-definition($node, $xsd)
};

(: ######################################################################################################################:)
(: ######################################################################################################################:)

(: ##########***  QUERY NODES (XS:ELEMENT OR XS:ATTRIBUTE)  ***###########:)

(: Copied from qxrxe returns either 'element' or 'attrbute' :)
declare function qxsd:get-node-type($node){
    local-name($node)
};




(: ##########***  QUERY TYPE ( @TYPE OR XS:COMPLEXTYPE OR XS:SIMPLETYPE)  ***###########:)



declare function qxsd:is-xs-datatype($type-attribute){
    if (starts-with(xs:string($type-attribute), 'xs:')) then
        true()
    else
        false()
};

declare function qxsd:get-xs-datatype-string($type-attribute){
    if (qxsd:is-xs-datatype($type-attribute)) then
        xs:string($type-attribute)
    else
        ()
};

(:DESTROY:)
(:OLD WHERE IS THIS USED??? CAN is-xs-datatype and qxsd:get-xs-datatype-string be used?:)
 declare function qxsd:get-xs-type($type){
       if($type instance of xs:string and starts-with($type, 'xs:')) then
           $type
       else
           ()
};


(:returns either xs:complexType or xs:simpleType TODO: or xs:datatype:)
declare function qxsd:get-type-type($node, $xsd){
    let $type := qxsd:get-type($node, $xsd)
    return
        if ($type instance of xs:string) then
            'simpleType'
        else if(not($type)) then
            'simpleType'
        else
            local-name($type)
};


declare function qxsd:is-simpleType($type){
    ()
};

declare function qxsd:is-complexType($type){
    ()
};



(: ##########***  QUERY XS:DATATYPE ***###########:)



(: ##########***  QUERY XS:COMPLEXTYPE OR XS:SIMPLETYPE ***###########:)

declare function qxsd:is-enum-restriction($type){
    let $enum-restriction :=
        if($type instance of xs:string) then
            false()
        else
            if($type/xs:restriction/xs:enumeration) then
                true()
            else
                false()
    return $enum-restriction
};

 declare function qxsd:get-enums($type){
        if($type instance of xs:string) then
            ()
        else
            if($type/xs:restriction/xs:enumeration) then
                $type/xs:restriction/xs:enumeration
            else
                ()
};

declare function qxsd:get-first-enum-value($type){
    let $enum-value :=
        if($type instance of xs:string) then
            ()
        else
            if($type/xs:restriction/xs:enumeration ) then
                data($type/xs:restriction/xs:enumeration[1]/@value)
            else
                false()
    return $enum-value
};

(: ##########***  QUERY XS:COMPLEXTYPE  ***###########:)

declare function qxsd:is-mixed($node-info, $xsd){
        let $type := qxsd:get-type($node-info, $xsd)
        return
        if($type instance of element() and $type/@mixed = 'true') then
            fn:true()
        else
            fn:false()
};

declare function qxsd:attribute-group-definition($attribute-group, $xsd){
        if($attribute-group/@name) then
            $attribute-group
        else if($attribute-group/@ref) then
           qxsd:attribute-group-global-definition($attribute-group, $xsd)
        else ()
};

declare function qxsd:attribute-group-global-definition($attribute-group, $xsd){

            let $name := xs:string($attribute-group/@ref)
            let $xsd := qxsd:get-xsd($name, $xsd)
            let $local-name := qxsd:get-local-name($name)
            return
                $xsd/xs:attributeGroup[@name=$local-name]
};

(: ### returns the <xs:attribute name="..."> of a xs:attribute/@ref xs:attribute/@name or string ###:)
declare function qxsd:attribute-definition($attribute, $xsd){

     if($attribute/@name) then
            $attribute
     else if($attribute/@ref) then
            qxsd:attribute-global-definition($attribute, $xsd)
     else ()


};

declare function qxsd:attribute-global-definition($attribute, $xsd){

        let $name := xs:string($attribute/@ref)
        let $xsd := qxsd:get-xsd($name, $xsd)
        let $local-name := qxsd:get-local-name($name)
        return
            $xsd/xs:attribute[@name=$local-name]
};

declare function qxsd:get-xsd($name, $xsd)
{

    let $import := $xsd/xs:import[xs:string(@namespace)=qxsd:get-namespace($name, $xsd)]
    let $schemaLocation := qxsd:get-schema-location($xsd, $import)
    return
        if($schemaLocation) then
            qxsd:xsd($schemaLocation)
        else
            $xsd

};

declare function qxsd:get-namespace($name, $xsd){
    let $prefix := qxsd:get-prefix($name)

    return
        if($prefix) then
            fn:namespace-uri-for-prefix($prefix, $xsd)
        else xs:string($xsd/@targetNamespace)

};




(:######### searches for a xs:attribute within xs:compleyType by name################:)
declare function qxsd:find-attribute($context, $name, $xsd){


    if($context/xs:simpleContent/xs:extension) then
        qxsd:find-attribute($context/xs:simpleContent/xs:extension, $name, $xsd)
    else if($context/xs:attribute[xs:string(@name) = $name]) then
        $context/xs:attribute[@name = $name]

    else if ($context/xs:attribute[xs:string(@ref) = $name]) then
        $context/xs:attribute[@ref = $name]

    else if ($context/xs:attributeGroup) then (:constrain?:)
         qxsd:find-attribute-in-groups($context, $name, $xsd)

     (: else xs:anyAttribute :)
     (: else find-attribute-in-extentions :)
     (: else find-attribute-in-restrictions:)

     else
        ()
};

declare function qxsd:find-attribute-in-groups($parent, $name, $xsd){
    for $attribute-group in $parent/xs:attributeGroup
            return
                qxsd:find-attribute-in-group($attribute-group, $name, $xsd)
};


declare function qxsd:find-attribute-in-group($attribute-group, $name, $xsd){
            let $attribute-group-definition := qxsd:attribute-group-definition($attribute-group, $xsd)
            return

                if($attribute-group-definition/xs:attribute[@name = $name]) then
                    $attribute-group-definition/xs:attribute[@name = $name]
                else  if($attribute-group-definition/xs:attribute[@ref = $name]) then
                    qxsd:attribute-definition($attribute-group-definition/xs:attribute[@ref = $name], $xsd)

                else if ($attribute-group-definition/xs:attributeGroup) then
                   qxsd:find-attribute-in-groups($attribute-group-definition, $name, $xsd)

                (: else xs:anyAttribute :)
                else
                    ()
};




(:######## QUERY XS:ATTRIBUTE #########:)

(:######### XS:ATTRIBUTE@DEFAULT ################:)


declare function qxsd:get-default($attribute, $xsd){
   $attribute/@default
};

declare function qxsd:get-default-string($attribute, $xsd){
   if ($attribute/@default) then
        xs:string($attribute/@default)
   else
        ()
};

(:######### XS:ATTRIBUTE@FIXED ################:)

declare function qxsd:get-fixed($attribute, $xsd){
   $attribute/@fixed
};

declare function qxsd:get-fixed-string($attribute, $xsd){
   if ($attribute/@fixed) then
        xs:string($attribute/@fixed)
   else
        ()
};

(:for attribute notes defined by attribute fixed or default:)

declare function qxsd:value($node-info, $xsd){
    let $fixed-value := qxsd:get-fixed-string($node-info, $xsd)
    let $default-value := qxsd:get-default-string($node-info, $xsd)
    return
        if($fixed-value) then
            $fixed-value
        else if($default-value) then
            $default-value
        else
            ()

};



(:######### XS:ATTRIBUTE@USE ################:)

(:declare function qxsd:get-use($attribute, $xsd){
   $attribute/@use
};

declare function qxsd:is-optional($attribute, $xsd){
   if(xs:string(qxsd:get-use($attribute, $xsd))='optional') then
        true()
   else
        false()
};

declare function qxsd:is-required($attribute, $xsd){
   if(xs:string(qxsd:get-use($attribute, $xsd))='required') then
        true()
   else
        false()
};

declare function qxsd:is-prohibited($attribute, $xsd){
   if(xs:string(qxsd:get-use($attribute, $xsd))='prohibited') then
        true()
   else
        false()
};
:)


(: ################# QUERY NODE  #################:)

declare function qxsd:get-default($attribute){
    let $default :=
        if($attribute/@default) then
            data($attribute/@default)
        else
            ()
    return $default
};

declare function qxsd:get-fixed($attribute){
    let $fixed :=
        if($attribute/@fixed) then
            data($attribute/@fixed)
        else
            ()
    return $fixed
};












(: ################# ANNOTATION DUMMYS #################:)



declare function qxsd:get-context-content($context){
   let $context-content := fn:substring-after(fn:translate($context, ']', ''), '[')
   (:TODO more than 1 content element:)
   return $context-content
};


(:### return the complexType an Element is in ###:)
declare function qxsd:get-types-element-is-in($element){

    let $types :=
        if($element/ancestor::xs:complexType[1]) then
            $element/ancestor::xs:complexType[1]
        else () (:Element is in group:)
    return $types
};


declare function qxsd:contained-in-types($element, $xsd){

    let $types :=
        if($element/ancestor::xs:complexType) then
            $element/ancestor::xs:complexType[1]
        else
            let $group := $element/ancestor::xs:group
            return  qxsd:deep-find-type-of-group($group, $xsd)



    return $types
};

declare function qxsd:deep-find-type-of-group($groups, $xsd){

        for $group in $groups
        return
            let $group-name := xs:string($group/@name)
            let $group-refs := $xsd//xs:group[@ref=$group-name]
            let $types-of-group-refs := $group-refs/ancestor::xs:complexType[1]
            let $groups-of-group-refs := $group-refs/ancestor::xs:group[1]
            return ($types-of-group-refs, qxsd:deep-find-type-of-group($groups-of-group-refs, $xsd))

};

declare function qxsd:type-contained-in-element($types, $xsd){
    let $elements :=
         for $type in $types
             let $element :=
                 if($type/@name) then
                     let $type-name := xs:string($type/@name)
                     let $elements := $xsd//xs:element[@type=$type-name][1]
                     return $elements

                 else
                     $type/ancestor::xs:element[1]
             return $element
    return $elements
};

(:###################### CREATE DUMMYS ###################################:)

declare function  qxsd:get-element-create-min($path, $xsd){
    (:namespace as parameter and add ns to first node, or get namespace from xsd:)
    (:use get-name to create prefix:name:)
    let $xsd := qxsd:xsd($xsd)
    let $prefix := qxsd:get-name($path)
    let $element := qxsd:get-node($path, $xsd)

    return qxsd:create-element($element, $prefix, 'min' , $xsd, 1)
};



declare function  qxsd:get-element-create-opt($path, $xsd){
    (:namespace as parameter and add ns to first node, or get namespace from xsd:)
    (:use get-name to create prefix:name:)
    let $xsd := qxsd:xsd($xsd)
    let $prefix := qxsd:get-name($path)
    let $element := qxsd:get-node($path, $xsd)

    return qxsd:create-element($element, $prefix, 'opt', $xsd, 1)
};

declare function qxsd:create-elements($element, $prefix, $mode, $xsd, $depth){
    let $count := qxsd:get-content-model-item-count($element, $mode, $xsd)
    for $num in (1 to $count)
        return   qxsd:create-element($element, $prefix, $mode, $xsd, $depth)
};

declare function qxsd:create-element($element, $prefix, $mode,  $xsd, $depth){

    let $element-definition := qxsd:node-definition($element, $xsd)
    let $local-name := $element-definition/@name
    let $name := concat($prefix, ':', $local-name)

    let $type := qxsd:get-type($element-definition, $xsd)

    let $element :=
            if($depth > $xrxe-conf:default-max-depth) then
                ()
            else
                element {$local-name} {

                    qxsd:create-attributes($type, $mode, $xsd)

                    (:Debugging:)
                    (: ,
                    attribute depth {$depth}:)
                    ,
                    if(not(qxsd:get-xs-type($type)) and not(qxsd:is-mixed($element, $xsd))) then
                         qxsd:create-content($type, $prefix, $mode, $xsd, $depth + 1, ())
                    else
                        ()
                }
    return $element
};


declare function qxsd:create-attributes($type, $mode, $xsd){
    for $attribute  in qxsd:get-attributes($type, $xsd)
    let $attribute-name := $attribute/@name

    let $attribute := attribute {$attribute-name} {qxsd:create-attribute-value($attribute, $xsd)}
    return
        $attribute
};

declare function qxsd:create-attribute-value($attribute, $xsd){
    let $type := qxsd:get-type($attribute, $xsd)

    let $value :=
        if(qxsd:get-fixed($attribute)) then
            qxsd:get-fixed($attribute)
        else if(qxsd:get-default($attribute)) then
            qxsd:get-default($attribute)
        else if (qxsd:is-enum-restriction($type)) then
            qxsd:get-first-enum-value($type)
        else
            ''
   return $value
};


declare function qxsd:create-content($content-model, $mode, $prefix, $xsd, $depth, $pos){


    let $all-content-model-items := $content-model/xs:sequence  | $content-model/xs:element | $content-model/xs:choice | $content-model/xs:group
    let $relevant-content-model-items :=
        if($content-model instance of element(xs:choice)) then
            $all-content-model-items[$pos] (: qxrxe:get-first-choice :)
        else
            $all-content-model-items

    for $content-model-item in $relevant-content-model-items
    return
        if ($content-model-item instance of element(xs:sequence)) then
            qxsd:create-sequences($content-model-item, $prefix, $mode, $xsd, $depth)
        else if ($content-model-item instance of element(xs:choice)) then
            qxsd:create-choices($content-model-item, $prefix, $mode, $xsd, $depth)
        else if ($content-model-item instance of element(xs:element)) then
            qxsd:create-elements($content-model-item, $prefix, $mode, $xsd, $depth)
        else if ($content-model-item instance of element(xs:group)) then
            qxsd:create-groups($content-model-item, $prefix, $mode, $xsd, $depth)
        else ()



};

declare function qxsd:create-groups($group, $prefix, $mode, $xsd, $depth){
    let $count := qxsd:get-content-model-item-count($group, $mode, $xsd)
    for $num in (1 to $count)
        return   qxsd:create-group($group, $prefix, $mode, $xsd, $depth)
};

declare function qxsd:create-group($group, $prefix, $mode, $xsd, $depth){
    let $group-definition := qxsd:group-definition($group, $xsd)
    return
        qxsd:create-content($group-definition, $prefix, $mode, $xsd, $depth, ())
};

declare function qxsd:create-sequences($sequence, $prefix, $mode, $xsd, $depth){
    let $count := qxsd:get-content-model-item-count($sequence, $mode, $xsd)
    for $num in (1 to $count)
        return   qxsd:create-sequence($sequence, $prefix, $mode, $xsd, $depth)
};

declare function qxsd:create-sequence($sequence, $prefix, $mode, $xsd, $depth){
    qxsd:create-content($sequence, $prefix, $mode, $xsd, $depth, ())
};

declare function qxsd:create-choices($choice, $prefix, $mode, $xsd, $depth){
    let $count := qxsd:get-content-model-item-count($choice, $mode, $xsd)
    for $pos in (1 to $count)
        return   qxsd:create-choice($choice, $prefix, $mode, $xsd, $depth, $pos)
};

declare function qxsd:create-choice($choice, $prefix, $mode, $xsd, $depth, $pos){
    qxsd:create-content($choice, $prefix, $mode, $xsd, $depth, $pos)

};

declare function qxsd:content-model-item-min-occurs($content-model-item, $xsd){
    let $min-occur :=
        if($content-model-item/@minOccurs) then
            xs:int($content-model-item/@minOccurs)
        else 1
    return $min-occur
};

declare function qxsd:max-occurs($context, $xsd)
{

    if($context/@maxOccurs) then
        if(xs:string($context/@maxOccurs) = 'unbounded') then
            ()
        else
            xs:int($context/@maxOccurs)
    else 1
};

declare function qxsd:min-occurs($context, $xsd){

    if($context instance of element(xs:attribute)) then
        if(xs:string($context/@use)='required') then
            1
        else
            ()
    else
        if($context/@minOccurs) then
            if ($context/@minOccurs = '0') then
                ()
            else
                xs:int($context/@minOccurs)
        else 1
};

declare function qxsd:content-model-item-max-occurs($content-model-item, $xsd)
as xs:int
{
    let $max-occur :=
        if($content-model-item/@maxOccurs) then
            if($content-model-item/@maxOccurs = 'unbounded') then
                $xrxe-conf:unbounded
            else
                xs:int($content-model-item/@maxOccurs)
        else 1
    return xs:int($max-occur)
};

declare function qxsd:get-content-model-item-count($content-model-item, $mode, $xsd){
    let $min := qxsd:content-model-item-min-occurs($content-model-item, $xsd)
    let $count :=
        if($min = 0) then
            if($content-model-item instance of element(xs:sequence) or $content-model-item instance of element(xs:group) or $content-model-item instance of element(xs:element)) then
                1
            else if($content-model-item instance of element(xs:choice)) then
               min((qxsd:content-model-item-max-occurs($content-model-item, $xsd), count($content-model-item/xs:sequence  | $content-model-item/xs:element | $content-model-item/xs:choice | $content-model-item/xs:group)))
            else
                ()
        else $min
   return $count
};

(:###################### DEPRECATED ###################################:)
