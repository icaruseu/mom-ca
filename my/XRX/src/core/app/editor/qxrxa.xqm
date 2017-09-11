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

    module namespace qxrxa="http://www.monasterium.net/NS/qxrxa";

    import module namespace qxrxe="http://www.monasterium.net/NS/qxrxe" at "../editor/qxrxe.xqm";
    import module namespace qxsd="http://www.monasterium.net/NS/qxsd" at "../editor/qxsd.xqm";
    import module namespace xrxe-conf="http://www.monasterium.net/NS/xrxe-conf" at "../editor/xrxe-conf.xqm";

    declare namespace functx = "http://www.functx.com";
    declare namespace xrx="http://www.monasterium.net/NS/xrx";
    declare namespace xhtml="http://www.w3.org/1999/xhtml";
    declare namespace xrxe="http://www.monasterium.net/NS/xrxe";

(: This module is used to generate the response for the annotation-control's ajax calls via the xrxe-service.xql for the services get-annotation, get-attribute, get-menu and get-aattribute-info:)

(:##################### SERVICES BY PATH ############################:)

(:returns the description of the menu for the text-annotation control, containing the submenus and the annotations:)
(:selection contains the current selection of the text-annotation control:)
(:content contains the current xml-content of the text-annotation-control's node:)
declare function qxrxa:get-menu($path, $content, $selection, $xsd){
<menu>
    {qxrxa:get-submenus($path, $content, $selection, $xsd)}
</menu>
};


(:returns a list of possible attributes to insert into an annotation:)
declare function qxrxa:get-attribute-options($path, $element, $xsd){
<attributes>{
    for $attribute-info in qxrxe:get-node-attribute-options($path, $element, $xsd)
    return qxrxa:attribute($attribute-info, $path, $xsd)
}</attributes>
};

(:returns a list of elements that can be inserted into the text-annotation-control in the current selection-context:)
declare function qxrxa:get-annotation-options($path, $content, $selection, $xsd){

for $element-info in qxrxe:get-node-annotation-options($path, $content, $selection, $xsd)
return  qxrxa:annotation-option($element-info, $path, $selection, $xsd)
};

(:returns information for an annotation within an text-annotation-control:)
declare function qxrxa:get-annotation($path, $xsd){

let $element-info := qxrxe:get-node-info($path, (), $xsd)
return qxrxa:annotation($element-info, $xsd)

};

(:returns information for an attribute of an annotation within an text-annotation-control:)
declare function qxrxa:get-attribute($path, $xsd){

let $attribute-info := qxrxe:get-node-info($path, (), qxsd:xsd($xsd))
return qxrxa:attribute($attribute-info, $path, $xsd)

};



(:####################### MENU ##########################:)

(:returns the submenu of a menu, like described in the xsd by xrxe:menu-item, or just the default-menu-item:)
declare function qxrxa:get-submenus($path, $content, $selection, $xsd){

let $options := qxrxa:get-annotation-options($path, $content, $selection, $xsd)

let $menu-items := functx:distinct-deep($options/menu-item)



let $annotated-sub-menus :=
	for $menu-item in $menu-items//xrxe:menu-item
        let $translated := xrxe-conf:translate($menu-item)
	return
		qxrxa:create-sub-menu($translated, qxrxa:menu-item-options($menu-item, $options))

let $default-sub-menu :=  qxrxa:create-default-sub-menu($options)

return ($default-sub-menu, $annotated-sub-menus)
};

declare function  qxrxa:menu-item-options($menu-item, $options){
	$options[data(menu-item)=$menu-item]
};

(:creates the default sub-menu for the element's that are not part of a declared submenu in the xsd by xrxe:menu-item:)
declare function qxrxa:create-default-sub-menu($options){
let $options-without-menu-item := $options[count(./menu-item) = 0]

return
if($options-without-menu-item) then
qxrxa:create-sub-menu($xrxe-conf:default-menu-item, $options-without-menu-item)
else
()
};

(:returns the description for a submenu:)
declare function qxrxa:create-sub-menu($menu-item, $options){
<sub-menu>
    <menu-item>
	{xs:string($menu-item)}
   </menu-item>
    {$options}
</sub-menu>
};




(:####################### ANNOTATION OPTIONS ##########################:)

(:returns the information for an element as an annotation in a text-annotation-control:)
declare function  qxrxa:annotation-option($element-info, $path, $selection, $xsd){
element option {
qxrxa:label($element-info, $xsd),
qxrxa:namespace($element-info, $path, $xsd),
qxrxa:element-name($element-info, $path, $xsd),
qxrxa:menu-item($element-info, $xsd),
qxrxa:element($element-info, $path, $selection, $xsd)


}
};

(:returns the xml-element node that will be inserted into the text-annotation-control:)
declare function qxrxa:element($element-info, $path, $selection, $xsd){

    let $prefix := qxsd:get-prefix(qxsd:get-name($path))

    let $namespace := xs:string(qxrxe:get-namespace($element-info))

    let $declare := util:declare-namespace($prefix, xs:anyURI($namespace))
    let $name := concat(qxrxe:prefix-string($path), qxrxe:get-name($element-info))

    let $element := element {$name} {$selection/node()}

    return
    <element>
        {$element}
    </element>
};


(:####################### ATTRIBUTES ##########################:)

(:returns the information for an attribute of an annotation in a text-annotation-control:)

declare function  qxrxa:attribute($attribute-info, $path, $xsd){
element attribute {
qxrxa:namespace($attribute-info, $path, $xsd),
qxrxa:attribute-name($attribute-info, $xsd),
qxrxa:label($attribute-info, $xsd),
qxrxa:control($attribute-info, $xsd),
qxrxa:initial-value($attribute-info, $xsd),
qxrxa:fixed($attribute-info, $xsd),
qxrxa:pattern($attribute-info, $xsd),
qxrxa:required($attribute-info, $xsd),
qxrxa:alert($attribute-info, $xsd),
qxrxa:hint($attribute-info, $xsd),
qxrxa:options($attribute-info, $xsd)

}
};

(:Deprecated:)
declare function qxrxa:attribute-control($attribute-info, $xsd){
<attribute-control>
    {
    element {concat('xhtml:', qxrxa:control($attribute-info, $xsd))}
    {
        attribute style {'display : inline !important;'}
        ,
        if(qxrxe:get-fixed($attribute-info, $xsd)) then
            attribute disabled {'disabled'}
        else
        ()
        }
    }
</attribute-control>
};

(:returns the information of the initial value of an attribute that is inserted into an annotation:)
declare function qxrxa:initial-value($attribute-info, $xsd){
        <initial-value>
            {
            if(qxrxe:get-fixed($attribute-info, $xsd)) then
                qxrxe:get-fixed($attribute-info, $xsd)
            else if(qxrxe:get-default-value($attribute-info, $xsd)) then
                qxrxe:get-default-value($attribute-info, $xsd)
            else if (xs:string($attribute-info/@type)='xs:int' or xs:string($attribute-info/@type)='xs:integer' or xs:string($attribute-info/@type)='xs:decimal') then
                    0
            else
                ()
            }
        </initial-value>
};

(:returns an element if the attribute is fixed:)
declare function qxrxa:fixed($attribute-info, $xsd){
         if(qxrxe:get-fixed($attribute-info, $xsd)) then
            <fixed/>
         else
               ()

};

(:returns the information if the attribute is required or not:)
declare function qxrxa:required($attribute-info, $xsd){
        if(xs:string($attribute-info/@use)='required') then
            <required>true</required>
         else
            <required>false</required>

};

(:returns an element containing an regex for the validationInput of an attribute:)
declare function qxrxa:pattern($attribute-info, $xsd){
         <pattern>
             {
             if($attribute-info/xs:simpleType/xs:restriction/xs:pattern/@value) then
                xs:string($attribute-info/xs:simpleType/xs:restriction/xs:pattern/@value)

             else if (xs:string($attribute-info/@type)='xs:int' or xs:string($attribute-info/@type)='xs:integer') then
                    '[\-+]?[0-9]+'
             else if (xs:string($attribute-info/@type)='xs:decimal') then
                    '[\-+]?[0-9.]+'
             (: else if xs:int then
                int
             :)
             (: else if xs:int then
                int
             :)
             (: else if xs:date then
                int
             :)
             (: else if xs:time then

                    [\-+]?[0-9]+
             :)

             else
                   '^.*$'
             }
         </pattern>

};

(:returns an element containing the alert message for the validationInput of an attribute:)
declare function qxrxa:alert($attribute-info, $xsd){
         <alert>
             {
             if(qxrxe:get-alert($attribute-info, $xsd)) then
                qxrxe:get-alert($attribute-info, $xsd)/text()
             else
                   'Invalid Value'
             }
         </alert>

};

(:returns an element containing the hint message for the validationInput of an attribute:)
declare function qxrxa:hint($attribute-info, $xsd){
         <hint>
             {
             if(qxrxe:get-hint($attribute-info, $xsd)) then
                qxrxe:get-hint($attribute-info, $xsd)
             else
                  ()
             }
         </hint>

};


(:####################### ANNOTATION ##########################:)

(:returns the information for an element as annotation in a text-annotation-control:)
declare function  qxrxa:annotation($element-info, $xsd){
element annotation {
qxrxa:label($element-info, $xsd),
qxrxa:html-tag($element-info, $xsd),
qxrxa:style($element-info, $xsd),
qxrxa:empty($element-info, $xsd),
qxrxa:display($element-info, $xsd)
}
};

declare function qxrxa:namespace($node-info, $path, $xsd){
    if(xs:string($node-info/@form)="qualified") then
        element namespace {
            xs:string(qxrxe:get-namespace($node-info))
    }
else
()
};

declare function qxrxa:attribute-name($node-info, $xsd){
element name {xs:string(qxrxe:get-name($node-info))}
};

declare function qxrxa:element-name($node-info, $path, $xsd){
element name {concat(qxrxe:prefix-string($path), qxrxe:get-name($node-info))}
};


declare function  qxrxa:label($node-info, $xsd){
element label {
    qxrxe:get-label($node-info, $xsd)
    }
};

declare function  qxrxa:html-tag($node-info, $xsd){
element html-tag {
'span'
}
};

declare function  qxrxa:style($node-info, $xsd){
()
};

declare function  qxrxa:display($node-info, $xsd){
let $display := qxrxe:get-display($node-info, $xsd)
return
if($display) then
<display>{$display}</display>
else
()
};

declare function  qxrxa:empty($node-info, $xsd){
if(qxrxe:is-empty($node-info, $xsd)) then
<empty />
else
()
};


declare function  qxrxa:menu-item($node-info, $xsd){
let $menu-item := qxrxe:get-menu-item($node-info, $xsd)
return
if ($menu-item) then
element menu-item {
 $menu-item
}
else
element menu-item {
 ()
}
};

declare function qxrxa:control($node-info, $xsd){
element control {
let $declared-control := qxrxe:get-content-control($node-info, $xsd)
return
    if($declared-control) then
        $declared-control
    else if ($node-info/xs:simpleType/xs:restriction/xs:enumeration) then
       'select'
    else
        $xrxe-conf:default-content-control
}
};

declare function qxrxa:options($node-info, $xsd){

     for $option in $node-info/xs:simpleType/xs:restriction/xs:enumeration
     return <option>
            {
                attribute label {xs:string($option/@value)},
                $option/@value

            }
            </option>


};


declare function functx:distinct-deep ($nodes as node()* )  as node()* {

for $seq in (1 to count($nodes))
return $nodes[$seq][not(functx:is-node-in-sequence-deep-equal(
.,$nodes[position() < $seq]))]
} ;

declare function functx:is-node-in-sequence-deep-equal($node as node()? ,
$seq as node()* )  as xs:boolean {

some $nodeInSeq in $seq satisfies deep-equal($nodeInSeq,$node)
} ;
