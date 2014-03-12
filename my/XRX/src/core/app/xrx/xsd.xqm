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

module namespace xsd="http://www.monasterium.net/NS/xsd";

import module namespace xrx="http://www.monasterium.net/NS/xrx"
    at "../xrx/xrx.xqm";
import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../xrx/conf.xqm";

declare function xsd:get-catalog() as node() {
    
    $conf:db-base-collection/*:catalog/root()
};

declare function xsd:get($atom-id as xs:string) as element() {

    $xrx:db-base-collection//xrx:id[.=$atom-id]/parent::xrx:xsd
};

declare function xsd:child-element-names($parent, $found, $xsd)
{
    let $groups-and-elements := 
        $xsd//xs:element[@name=$parent]//(xs:element|xs:group)/self::*[ancestor::xs:element[1]/@name=$parent]
        
    let $combine := 
    (
        for $item in $groups-and-elements
        return
        typeswitch($item)
        
        case element(xs:element) return
        
            $item/(@ref|@name)/string()
        
        case element(xs:group) return
        
            xsd:element-names-of-group($item/(@ref|@name)/string(), (), $xsd)
        
        default return ()
    )
    return 
    if(count($combine) gt 0) then distinct-values($combine) else ()
};

(: TODO: same as above: keep order of groups and elements :)
declare function xsd:element-names-of-group($parent, $found, $xsd) as xs:string* {

    let $subgroups :=
    (
        $xsd/xs:group[@name=$parent]//xs:group/@ref/string(),
        $xsd/xs:group[@name=$parent]//xs:group/@ref/string()
    )    
    let $elements :=
    (
        $xsd/xs:group[@name=$parent]//xs:element/(@ref|@name)/string(),
        $xsd/xs:group[@name=$parent]//xs:element/(@ref|@name)/string()
    )
    return
    (
        $elements,
        for $group in $subgroups
        return
        if($group = $found) then ()
        else xsd:element-names-of-group($group, ($found, $group), $xsd)
    )    
};

declare function xsd:parent-element-names($child, $found, $xsd)
{
    let $groups := 
    (
        $xsd//xs:element[(@name|@ref)=$child]/ancestor::xs:group[1],
        $xsd//xs:group[@ref=$child]/ancestor::xs:group[1]
    )
    let $elements :=
    (
        $xsd/descendant::xs:element[(@name|@ref)=$child]/ancestor::xs:element[1]/@name/string(),
        $xsd/descendant::xs:group[@ref=$child]/ancestor::xs:element[1]/@name/string()
    )
    return
    (
        $elements,
        if($groups)
        then
            for $group in $groups
            return
            if($group intersect $found)
            then()
            else
            xsd:parent-element-names($group/@name/string(), ($group, $found), $xsd)
        else ()
    )
};

declare function xsd:parent-element-names-of-attribute($child, $found, $xsd)
{
    let $groups := 
    (
        $xsd/descendant::xs:attribute[(@name|@ref)=$child]/ancestor::xs:attributeGroup[1],
        $xsd/descendant::xs:attributeGroup[@ref=$child]/ancestor::xs:attributeGroup[1]
    )
    let $elements :=
    (
        $xsd/descendant::xs:attribute[(@name|@ref)=$child]/ancestor::xs:element[1]/@name/string(),
        $xsd/descendant::xs:attributeGroup[(@name|@ref)=$child]/ancestor::xs:element[1]/@name/string()
    )
    return
    (
        $elements,
        if($groups) then
            for $group in $groups
            return
            if($group intersect $found) then ()
            else
            xsd:parent-element-names-of-attribute($group/@name/string(), ($group, $found), $xsd)
        else()
    )
};

declare function xsd:attribute-names($parent, $found, $xsd)
{
    let $groups-and-attributes := 
        $xsd//xs:element[@name=$parent]//(xs:attribute|xs:attributeGroup)
    let $combine := 
    (
        for $item in $groups-and-attributes
        let $item-name := $item/(@ref|@name)/string()
        return
        typeswitch($item)
        
        case element(xs:attribute) return
        
            $item-name
        
        case element(xs:attributeGroup) return
        
            xsd:attribute-names-of-group($item-name, (), $xsd)
        
        default return ()
    )
    return
    if(count($combine) gt 0) then distinct-values($combine) else ()
};

declare function xsd:attribute-names-of-group($parent, $found, $xsd) as xs:string* {

    let $subgroups-and-attributes :=
        $xsd/xs:attributeGroup[@name=$parent]//(xs:attribute|xs:attributeGroup)
    let $combine := 
    (
        for $item in $subgroups-and-attributes
        let $item-name := $item/(@ref|@name)/string()
        return
        typeswitch($item)
        
        case element(xs:attribute) return
        
            $item-name
        
        case element(xs:attributeGroup) return
        
            if($item-name = $found) then ()
            else
                xsd:attribute-names-of-group($item-name, ($item-name, $found), $xsd)
        
        default return ()
    )
    return
    if(count($combine) gt 0) then distinct-values($combine) else ()    
};
