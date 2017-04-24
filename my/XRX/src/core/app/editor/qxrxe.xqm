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


module namespace qxrxe="http://www.monasterium.net/NS/qxrxe";



(: ################# IMOPORT MODULES #################:)

import module namespace qxsd='http://www.monasterium.net/NS/qxsd' at '../editor/qxsd.xqm';
import module namespace xrxe-conf="http://www.monasterium.net/NS/xrxe-conf" at "../editor/xrxe-conf.xqm";


(: ################# DECLARE NAMESAPCES #################:)

declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace xrxe="http://www.monasterium.net/NS/xrxe";

(:#####################SERVICES BY PATH ############################:)

declare function qxrxe:get-node-info($path, $parent-info, $xsd){
    let $xsd := qxsd:xsd($xsd)
    let $path := qxsd:get-path($path)

    let $parent-info :=
        if($parent-info) then
            $parent-info
        else
            $xsd

    let $node := qxsd:find-node(qxsd:tokenize-path($path), $parent-info,  1, $xsd)
    return qxrxe:node-info($node, $xsd)
};

declare function qxrxe:get-node-appinfos($path, $xsd){
    let $node-info := qxrxe:get-node-info($path, (), $xsd)
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)
    return $appinfos
};

declare function qxrxe:get-node-content($path, $xsd){
    let $xsd := qxsd:xsd($xsd)
    let $node-info := qxrxe:get-node-info($path, (), $xsd)
    let $type := qxsd:get-type($node-info, $xsd)
    return qxrxe:get-relevant-content($type, $node-info, $xsd)
};

declare function qxrxe:get-node-relevant-elements($path, $xsd){
    let $xsd := qxsd:xsd($xsd)
    let $node-info := qxrxe:get-node-info($path, (), $xsd)
    let $type := qxsd:get-type($node-info, $xsd)
    let $content := qxrxe:get-relevant-content($type, $node-info, $xsd)
    return qxrxe:get-relevant-elements($content, $node-info, $xsd)
};

declare function qxrxe:get-node-annotation-options($path, $content, $selection, $xsd){
    let $xsd := qxsd:xsd($xsd)
    let $node-info := qxrxe:get-node-info($path, (), $xsd)
    let $type := qxsd:get-type($node-info, $xsd)
    let $content-desc := qxrxe:get-relevant-content($type, $node-info, $xsd)
    return qxrxe:get-annotation-options($content-desc, $node-info, $path, $content, $selection, $xsd)
};

declare function qxrxe:get-node-attribute-options($path, $element, $xsd){
    let $xsd := qxsd:xsd($xsd) 
    let $node-info := qxrxe:get-node-info($path, (), $xsd)
    let $type := qxsd:get-type($node-info, $xsd)
    return qxrxe:get-attribute-options($element, $type, $node-info, $xsd)
};

declare function qxrxe:get-node-relevant-attributes($path, $xsd){
    let $xsd := qxsd:xsd($xsd)
    let $node-info := qxrxe:get-node-info($path, (), $xsd)
    let $type := qxsd:get-type($node-info, $xsd)
    return qxrxe:get-relevant-attributes($type, $node-info, $xsd)
};

declare function  qxrxe:get-node-template($path, $xsd){
    let $xsd := qxsd:xsd($xsd)
    let $node-info := qxrxe:get-node-info($path, (), $xsd)
    return
        qxrxe:create-template($node-info, qxsd:get-prefix(qxsd:get-name($path)), () ,  $xsd, 1)

};

(:##################### CREATE INFO NODES ############################:)


declare function  qxrxe:node-info($node, $xsd){

        let $node-definition := qxsd:node-definition($node, $xsd)
        let $node-info := qxrxe:get-definition-copy($node-definition)
        let $node-info := qxrxe:add-form($node-info, $node-definition)
        let $node-info := qxrxe:add-namespace-into-info($node-info, $node-definition, $xsd)
        let $node-info := qxrxe:add-node-into-info($node, $node-info)
        let $node-info := qxrxe:add-type-into-info($node-info, $xsd)
        return $node-info

};

declare function qxrxe:get-definition-copy($to-copy){
    if($to-copy) then
        qxrxe:copy($to-copy)
    else ()
};

declare function qxrxe:add-node-into-info($node, $node-info){
    if($node/@ref) then
        let $node-info :=  qxrxe:add-annotations-into-info($node-info, $node)
        let $node-info :=  qxrxe:add-attributes-into-info($node-info, $node)
        return
            $node-info
    else
        $node-info
};

declare function qxrxe:add-annotations-into-info($node-info, $node){
    let $annotations := $node/xs:annotation
    return
        if($node-info and $annotations) then
            xrxe-conf:insert-into-as-first($node-info, $annotations)
        else
            $node-info
};

declare function qxrxe:add-attributes-into-info($node-info, $node){
    let $attributes := $node/@*
    return
        if($node-info and $attributes) then
            xrxe-conf:insert-attributes($node-info, $attributes)
        else
            $node-info
};

declare function qxrxe:add-type-into-info($node-info, $xsd){
    if($node-info/@type) then
        let $type := qxsd:get-type($node-info, $xsd)
        return
            if($type instance of node()) then
                xrxe-conf:insert-into-as-last($node-info, $type)
            else
                $node-info
    else
       $node-info
};

declare function qxrxe:add-namespace-into-info($node-info, $node-definition, $xsd){
        let $targetNamespace :=
		if($node-definition/ancestor::xs:schema/@targetNamespace) then
		    $node-definition/ancestor::xs:schema/@targetNamespace
		 else
		    $xsd/@targetNamespace


    return
        if($node-info and $targetNamespace) then
            xrxe-conf:insert-attributes($node-info, $targetNamespace)
        else
            $node-info
};

declare function qxrxe:add-form($node-info, $node-definition){
    let $form :=
        if(not($node-info/@form)) then
            let $schema := $node-definition/ancestor::xs:schema
            return
            if (qxrxe:get-node-type($node-info)='element') then
                if($schema/@elementFormDefault) then
                    xs:string($schema/@elementFormDefault)
                else
                    'qualified'
            else if (qxrxe:get-node-type($node-info)='attribute') then
                if ($node-definition/parent::xs:schema) then
                    'qualified'
                else if($schema/@attributeFormDefault) then
                    xs:string($schema/@attributeFormDefault)
                else
                    'unqualified'
            else
                ()
        else
            ()

    let $form-attribute := attribute form {$form}
    return
        if($node-info and $form) then
            xrxe-conf:insert-attributes($node-info, $form-attribute)
        else
            $node-info
};

declare function  qxrxe:attribute-group-info($attribute-group, $xsd){
    let $attribute-group-definition := qxsd:attribute-group-definition($attribute-group, $xsd)
    let $attribute-group-info :=  qxrxe:get-definition-copy($attribute-group-definition)
    let $attribute-group-info := qxrxe:add-annotations-into-info($attribute-group-info, $attribute-group)
    return $attribute-group-info
};

declare function  qxrxe:group-info($group, $xsd){
    let $group-definition := qxsd:group-definition($group, $xsd)
    let $group-info :=  qxrxe:get-definition-copy($group-definition)
    let $group-info := qxrxe:add-annotations-into-info($group-info, $group)
    return $group-info
};

(:##################### QUERY NODE-INFO ############################:)


declare function qxrxe:get-appinfos($node-info, $xsd){
    let $appinfos := ($node-info/xs:annotation/xs:appinfo, $node-info/xs:simpleType/xs:annotation/xs:appinfo, $node-info/xs:complexType/xs:annotation/xs:appinfo)
    return $appinfos
};

declare function qxrxe:get-name($node-info){
    if($node-info/@ref) then
        $node-info/@ref
    else if ($node-info/@name) then
        $node-info/@name
    else ()
};

declare function qxrxe:get-namespace($node-info){
    $node-info/@targetNamespace
};

declare function qxrxe:get-node-type($node-info){
    local-name($node-info)
};

declare function qxrxe:is-xs-attribute($node-info){
    if (qxrxe:get-node-type($node-info)='attribute') then
        true()
    else
        false()
};

declare function qxrxe:is-xs-element($node-info){
    if (qxrxe:get-node-type($node-info)='element') then
        true()
    else
        false()
};

declare function qxrxe:get-label($node-info, $xsd){
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)
    let $log := util:log("ERROR", $appinfos)
    let $xrxe-label := $appinfos/xrxe:label[1]

    let $translate := xrxe-conf:translate($xrxe-label)

    let $label :=
        if($translate) then
            xs:string($translate)
        else
            xs:string($node-info/@name)



    return $label
};

declare function qxrxe:get-plural-label($node-info, $xsd){
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)

    let $xrxe-labels := $appinfos/xrxe:plural-label
    let $xrxe-label := $xrxe-labels[1]
    let $label :=
        if($xrxe-label) then
            $xrxe-label
        else
            ()
    return $label
};

declare function qxrxe:get-menu-item($node-info, $xsd){
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)

    let $xrxe-menu-items := $appinfos/xrxe:menu-item
    let $xrxe-menu-item := $xrxe-menu-items[1]


    let $menu-item :=
        if($xrxe-menu-item) then
            $xrxe-menu-item
        else
            ()

    return $menu-item
};

declare function qxrxe:is-relevant($node-info, $xsd){
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)

    let $xrxe-relevants := $appinfos/xrxe:relevant
    let $xrxe-relevant := $xrxe-relevants[1]
    let $xrxe-relevant-text := $xrxe-relevant/text()
    let $relevant :=
        if($xrxe-relevant-text='true' or $xrxe-relevant-text='false') then
            xs:boolean($xrxe-relevant)
        else
             if($node-info instance of element(xs:attribute)) then
                $xrxe-conf:default-attribute-relevant
             else if($node-info instance of element(xs:element)) then
                $xrxe-conf:default-element-relevant
             else if($node-info instance of element(xs:attributeGroup)) then
                $xrxe-conf:default-attribute-group-relevant
             else if($node-info instance of element(xs:group)) then
                $xrxe-conf:default-group-relevant
             else
                true()
    return $relevant
};

(:DEPRECATED:)
declare function qxrxe:get-min-occur($node-info, $xsd){
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)

    let $xrxe-min-occurs := $appinfos/xrxe:min-occur
    let $xrxe-min-occur := $xrxe-min-occurs[1]
    let $min-occur :=
        if($xrxe-min-occur/text()='0') then
           0
        else if($xrxe-min-occur/text()) then
            $xrxe-min-occur/text()
        else
           if($node-info instance of element(xs:attribute)) then
                $xrxe-conf:default-attribute-min-occur
           else
                $xrxe-conf:default-min-occur
    return $min-occur
};

declare function qxrxe:min-occurs($node-info, $xsd){
    let $xrxe-min-occur := qxrxe:get-appinfos($node-info, $xsd)/xrxe:min-occur[1]
    return
        if($xrxe-min-occur/text()='0') then
           ()
        else if($xrxe-min-occur/text()) then
            $xrxe-min-occur/text()
        else
            qxsd:min-occurs($node-info, $xsd)
};

(:DEPRECATED:)
declare function qxrxe:get-max-occur($node-info, $xsd){
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)

    let $xrxe-max-occurs := $appinfos/xrxe:max-occur
    let $xrxe-max-occur := $xrxe-max-occurs[1]
    let $max-occur :=
        if($xrxe-max-occur/text()='unbounded') then
            9999
        else if($xrxe-max-occur/text()) then
            $xrxe-max-occur/text()
        else
           if($node-info instance of element(xs:attribute)) then
                1
           else
                $xrxe-conf:default-max-occur
    return $max-occur
};

declare function qxrxe:max-occurs($node-info, $xsd){

    let $xrxe-max-occur := qxrxe:get-appinfos($node-info, $xsd)/xrxe:max-occur[1]
    return
        if($xrxe-max-occur/text()='unbounded') then
            ()
        else if($xrxe-max-occur/text()) then
            $xrxe-max-occur/text()
        else
                qxsd:max-occurs($node-info, $xsd)
};


declare function qxrxe:get-rows($node-info, $xsd){

    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)
    let $xrxe-rows := $appinfos/xrxe:rows
    let $xrxe-row := $xrxe-rows[1]
    let $row :=
        if(xs:int($xrxe-row)) then
            xs:int($xrxe-row)
        else
             $xrxe-conf:default-rows
    return $row
};

declare function qxrxe:get-type-type($node-info, $xsd){

    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)
    let $xrxe-type-types := $appinfos/xrxe:type-type
    let $xrxe-type-type := $xrxe-type-types[1]
    let $xrxe-type-type-text := $xrxe-type-type/text()
    let $type-type :=
        if($xrxe-type-type-text='xs:simpleType' or $xrxe-type-type-text='simpleType' or $xrxe-type-type-text='simple') then
            'simpleType'
        else if($xrxe-type-type-text='xs:complexType' or $xrxe-type-type-text='complexType' or $xrxe-type-type-text='complex') then
            'complexType'
        else
             qxsd:get-type-type($node-info, $xsd)
    return $type-type
};

declare function qxrxe:is-simple-type($node-info, $xsd){
    let $type-type := qxrxe:get-type-type($node-info, $xsd)
    return
    if($type-type='simpleType') then
        true()
    else
        false()
};

declare function qxrxe:is-complex-type($node-info, $xsd){
    let $type-type := qxrxe:get-type-type($node-info, $xsd)
    return
    if($type-type='complexType') then
        true()
    else
        false()
};

declare function qxrxe:is-mixed($node-info, $xsd){
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)
    let $xrxe-mixeds := $appinfos/xrxe:mixed
    let $xrxe-mixed := $xrxe-mixeds[1]
    let $xrxe-mixed-text := $xrxe-mixed/text()
    let $mixed :=
        if($xrxe-mixed-text='true' or $xrxe-mixed-text='false') then
            xs:boolean($xrxe-mixed-text)
        else
            qxsd:is-mixed($node-info, $xsd)
    return $mixed
};

declare function qxrxe:is-enum($node-info, $xsd){
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)

    let $type := qxsd:get-type($node-info, $xsd)
    return qxsd:is-enum-restriction($type)
};

declare function qxrxe:get-enums($node-info, $xsd){
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)
    let $type := qxsd:get-type($node-info, $xsd)
    return qxsd:get-enums($type)
};

declare function qxrxe:get-hint($node-info, $xsd){
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)
    let $xrxe-hints := $appinfos/xrxe:hint
    let $xrxe-hint := $xrxe-hints[1]

    return $xrxe-hint/node()[1]

};

declare function qxrxe:get-help($node-info, $xsd){
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)
    let $xrxe-helps := $appinfos/xrxe:help
    let $xrxe-help := $xrxe-helps[1]
    return $xrxe-help/node()[1]


};

declare function qxrxe:get-alert($node-info, $xsd){
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)
    let $xrxe-alerts := $appinfos/xrxe:alert
    let $xrxe-alert := $xrxe-alerts[1]
    return $xrxe-alert/node()[1]



};

declare function qxrxe:get-default-value($node-info, $xsd){
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)
    let $xrxe-default-values := $appinfos/xrxe:default-value
    let $xrxe-default-value := $xrxe-default-values[1]
    let $default-value :=
        if($xrxe-default-value/text()) then
           $xrxe-default-value/text()
        else
            qxsd:get-default-string($node-info, $xsd)
    return $default-value
};

declare function qxrxe:get-fixed($node-info, $xsd){
    let $xrxe-fixed := qxrxe:get-appinfos($node-info, $xsd)/xrxe:fixed[1]
    return
        if($xrxe-fixed/text()) then
           $xrxe-fixed/text()
        else
            qxsd:get-fixed-string($node-info, $xsd)
};

declare function qxrxe:get-value($node-info, $xsd){
    let $fixed-value := qxrxe:get-fixed($node-info, $xsd)
    let $default-value := qxrxe:get-default-value($node-info, $xsd)
    return
        if($fixed-value) then
            $fixed-value
        else if($default-value) then
            $default-value
        else
            ()

};

declare function qxrxe:get-constraint($node-info, $xsd){
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)
    let $xrxe-constraints := $appinfos/xrxe:constraint
    let $xrxe-constraint := $xrxe-constraints[1]
    let $constraint :=
        if($xrxe-constraint/text()) then
           $xrxe-constraint/text()
        else
            ()
    return $constraint
};

declare function qxrxe:is-empty($node-info, $xsd){
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)
    let $xrxe-emptys := $appinfos/xrxe:empty
    let $xrxe-empty := $xrxe-emptys[1]
    return
        if($xrxe-empty) then
               true()
            else
                false()
};

declare function qxrxe:type-name($node-info, $xsd, $conf){
    let $type-name := qxrxe:get-appinfos($node-info, $xsd)/xrxe:type[1]/text()
    return
         if (not($type-name)) then
             let $type := qxsd:get-type($node-info, $xsd)
             return
                 if ($type instance of xs:string) then
                     $type
                 else
                     ()
         else
             $type-name

};




declare function qxrxe:get-children-control($node-info, $xsd){
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)

    let $xrxe-children-controls := $appinfos/xrxe:children-control
    let $xrxe-children-control := $xrxe-children-controls[1]
    let $children-control :=
        if($xrxe-children-control/text()) then
           $xrxe-children-control/text()
        else
            ()
    return $children-control
};

declare function qxrxe:get-content-control($node-info, $xsd){
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)

    let $xrxe-content-controls := $appinfos/xrxe:content-control
    let $xrxe-content-control := $xrxe-content-controls[1]
    let $content-control :=
        if($xrxe-content-control/text()) then
           $xrxe-content-control/text()
        else
            ()
    return $content-control
};

declare function qxrxe:get-display($node-info, $xsd){
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)
    let $xrxe-displays := $appinfos/xrxe:display
    let $xrxe-display := $xrxe-displays[1]
    let $display :=
        if($xrxe-display/text()) then
           $xrxe-display/text()
        else
            ()
    return $display
};



declare function qxrxe:is-relevant-in-context($node-info, $context-node, $xsd){
    let $appinfos := qxrxe:get-appinfos($node-info, $xsd)
    let $xrxe-relevants := $appinfos/xrxe:relevant
    let $xrxe-relevant := $xrxe-relevants[1]
    let $context := xs:string($context-node/@name)
    return
    if($xrxe-relevant/@context) then
        util:eval(concat('$context', xs:string($xrxe-relevant/@context)))
    else
        qxrxe:is-relevant($node-info, $xsd)
};

declare function qxrxe:can-have-element-content($node-info, $xsd){
    if(qxsd:is-xs-datatype($node-info/@type) or qxrxe:is-mixed($node-info, $xsd) or qxrxe:get-type-type($node-info, $xsd)='simpleType') then
        false()
    else
        true()
};

(:################## QUERY NODE-INFO CONTENT##########################:)



declare function qxrxe:get-relevant-content($type, $context-node, $xsd){
     (:exactly 1:)
    let $content := qxrxe:get-content($type, $xsd)
    return
    if(qxrxe:is-relevant-in-context($content, $context-node, $xsd)) then
        $content
    else
         ()
};

declare function qxrxe:get-content($type, $xsd){
    ($type/xs:sequence  | $type/xs:choice | $type/xs:all | qxrxe:group-info($type/xs:group, $xsd))
};

declare function qxrxe:get-relevant-elements($parent, $context-node, $xsd){
    for $content-model-item in qxsd:get-content-model-items($parent)
        return qxrxe:if-relevant-content-model-item($content-model-item, $context-node, $xsd)
};

declare function qxrxe:if-relevant-content-model-item($content-model-item, $context-node, $xsd){
    if ($content-model-item instance of element(xs:element)) then
            qxrxe:if-relevant-element($content-model-item, $context-node, $xsd)
        else if ($content-model-item instance of element(xs:group)) then
            qxrxe:if-relevant-group($content-model-item, $context-node, $xsd)
        else if ($content-model-item instance of element(xs:sequence) or $content-model-item instance of element(xs:choice) or $content-model-item instance of element(xs:all)) then
            qxrxe:if-relevant-compositor($content-model-item, $context-node, $xsd)
        else ()
};

declare function qxrxe:if-relevant-element($element, $context-node, $xsd){
    let $element-info := qxrxe:node-info($element, $xsd)
    return
        if(qxrxe:is-relevant-in-context($element-info, $context-node, $xsd)) then
            $element-info
        else
            ()
};

declare function qxrxe:if-relevant-group($group, $context-node, $xsd){
    let $group-info := qxrxe:group-info($group, $xsd)
        return
        if(qxrxe:is-relevant-in-context($group-info, $context-node, $xsd)) then
                qxrxe:get-relevant-elements($group-info, $context-node, $xsd)
        else
             ()
};

declare function qxrxe:if-relevant-compositor($compositor, $context-node, $xsd){
    if(qxrxe:is-relevant-in-context($compositor, $context-node, $xsd)) then
            qxrxe:get-relevant-elements($compositor, $context-node, $xsd)
    else
         ()
};

(:only used in create!!!! :)
declare function qxrxe:get-relevant-content-model-items($content-definition, $context, $xsd){
    for $content-model-item in qxsd:get-content-model-items($content-definition)
    return
        if ($content-model-item instance of element(xs:element)) then
            let $node-info := qxrxe:node-info($content-model-item, $xsd)
            return
                if(qxrxe:is-relevant-in-context($node-info, $context, $xsd)) then
                    $node-info
                else
                    ()
        else if ($content-model-item instance of element(xs:group)) then
            let $group-info := qxrxe:group-info($content-model-item, $xsd)
            return
            if(qxrxe:is-relevant-in-context($group-info, $context, $xsd)) then
                    $group-info
            else
                 ()
        else if ($content-model-item instance of element(xs:sequence) or $content-model-item instance of element(xs:choice) or $content-model-item instance of element(xs:all)) then
            if(qxrxe:is-relevant-in-context($content-model-item, $context, $xsd)) then
                    $content-model-item
             else
                 ()
        else ()
};

(:################## QUERY NODE INFO ATTRIBUTES ##########################:)


declare function qxrxe:get-attribute-items($type, $xsd){
    $type/xs:attribute | $type/xs:attributeGroup
};

declare function qxrxe:get-relevant-attributes($context, $parent-node, $xsd){

    let $context :=
         if($context/xs:simpleContent/xs:extension) then
            $context/xs:simpleContent/xs:extension
        else $context

    for $attribute-item in qxrxe:get-attribute-items($context, $xsd)
        return qxrxe:if-relevant-attribute-item($attribute-item, $parent-node, $xsd)


};

declare function qxrxe:if-relevant-attribute-item($attribute-item, $context-node, $xsd){
        if ($attribute-item instance of element(xs:attribute)) then
            qxrxe:if-relevant-attribute($attribute-item, $context-node, $xsd)
        else if ($attribute-item instance of element(xs:attributeGroup)) then
            qxrxe:if-relevant-attribute-group($attribute-item, $context-node, $xsd)
        else ()
};

declare function qxrxe:if-relevant-attribute($attribute, $context-node, $xsd){
    let $attribute-info := qxrxe:node-info($attribute, $xsd)
    return
        if(qxrxe:is-relevant-in-context($attribute-info, $context-node, $xsd)) then
            $attribute-info
        else
            ()
};

declare function qxrxe:if-relevant-attribute-group($attribute-group, $context-node, $xsd){
    let $attribute-group-info := qxrxe:attribute-group-info($attribute-group, $xsd)
        return
        if(qxrxe:is-relevant-in-context($attribute-group-info, $context-node, $xsd)) then
                qxrxe:get-relevant-attributes($attribute-group-info, $context-node, $xsd)
        else
             ()
};

(:Make deprecated:)
(:
declare function qxrxe:get-relevant-local-attributes($parent, $context-node, $xsd) {
    if($parent instance of element()) then
        for  $attribute in $parent/xs:attribute
            let $attribute-info := qxrxe:node-info($attribute, $xsd)
            return
            if(qxrxe:is-relevant-in-context($attribute-info, $context-node, $xsd)) then
                $attribute-info
            else ()
    else ()
};:)

(:Make deprecated:)
(:
declare function qxrxe:get-relevant-attribute-groups($parent, $context-node, $xsd){
    if($parent instance of element()) then
        for  $attribute-group in $parent/xs:attributeGroup
            let $attribute-group-info := qxrxe:attribute-group-info($attribute-group, $xsd)
            return
                if(qxrxe:is-relevant-in-context($attribute-group-info, $context-node, $xsd)) then
                    $attribute-group-info
                else
                ()
    else ()
};
:)

(:
(:Make deprecated:)
declare function qxrxe:get-relevant-group-attributes($attribute-group, $context-node, $xsd){
    for $group in $attribute-group
        return
            qxrxe:get-relevant-attributes($group, $context-node, $xsd)
};
:)

(:################# TRAVERSE #################:)

(:qxrxe:traverse($context, $context-node, $xsd, $depth){
    let $type := qxsd:get-type($node-info, $xsd)
    let $content := qxsd:get-content($type, $xsd)
    for content-model-item in qxsd:get-content-model-items($content-definition)

};

qxrxe:traverseAttributes(){
()
};

qxrxe:traverseContent(){
    for content-model-item in qxsd:get-content-model-items($context)

};:)

(:################# CREATE TEMPLATE NODE #################:)

declare function qxrxe:create-template($node-info, $prefix, $context-node, $xsd, $depth){

    (:get prefix from node-info/@ref or use prefix from $context-node:)
     let $prefix :=
        if($node-info/@ref) then
            if(contains(xs:string($node-info/@ref), ':')) then
                substring-before(xs:string($node-info/@ref), ':')
            else
                $prefix
        else
            $prefix

    (:check if namespace if node and context-node differ. If yes declare new namespace:)

    let $namespace := xs:anyURI(qxrxe:get-namespace($node-info))

    let $declare :=
        if(not($context-node) or $namespace!= xs:anyURI(qxrxe:get-namespace($context-node))) then
             qxrxe:declare-namespace($prefix, $namespace)
        else
            ()

    let $local-name := $node-info/@name
    let $name := concat($prefix, ':', $local-name)


    let $type := qxsd:get-type($node-info, $xsd)

    return

            if($depth > $xrxe-conf:default-max-depth) then
                ()
            else
                element {$name} {

                    (:Debugging:)
                    (:attribute depth {$depth}
                    ,:)
                    qxrxe:create-attributes($type, $node-info, $xsd)
                    ,
                    if(qxrxe:can-have-element-content($node-info, $xsd)) then
                        qxrxe:create-content(qxrxe:get-relevant-content-model-items($type, $context-node, $xsd), $prefix, $node-info, $xsd, $depth + 1)
                    else
                        ()

                }
};



declare function qxrxe:create-content($content-definition, $prefix, $context, $xsd, $depth){
     let $content-model-items := qxrxe:get-relevant-content-model-items($content-definition, $context, $xsd)
     for $content-model-item in  $content-model-items
        return
                if ($content-model-item instance of element(xs:element)) then
                    qxrxe:create-template($content-model-item, $prefix, $context,  $xsd, $depth)
                else if ($content-model-item instance of element(xs:sequence)) then
                    qxrxe:create-content($content-model-item, $prefix, $context, $xsd, $depth)
                else if ($content-model-item instance of element(xs:choice)) then
                    qxrxe:create-content($content-model-item, $prefix, $context, $xsd, $depth)
                else if ($content-model-item instance of element(xs:group)) then
                    qxrxe:create-content($content-model-item, $prefix, $context, $xsd, $depth)
                else ()
};





declare function qxrxe:create-attributes($type, $context-node, $xsd){
    if($type instance of node()) then
        for $attribute-info  in qxrxe:get-relevant-attributes($type, $context-node, $xsd)
            return qxrxe:create-attribute($attribute-info, $context-node, $xsd)
    else
        ()
};

declare function qxrxe:create-attribute($attribute-info, $context-node, $xsd){

     let $prefix :=
        if($attribute-info/@ref) then
                qxsd:get-prefix($attribute-info/@ref)
        else
            ()
    let $namespace := xs:anyURI(qxrxe:get-namespace($attribute-info))

    let $declare :=
        if(not($context-node) or $namespace!= xs:anyURI(qxrxe:get-namespace($context-node))) then
             qxrxe:declare-namespace($prefix, $namespace)
        else
            ()

     let $local-name := xs:string($attribute-info/@name)
     let $attribute-name :=
        (:TODO handle no prefix:)
        if($attribute-info/@form="qualified" and $prefix) then
            concat($prefix, ':', $local-name)
        else
           $local-name
     return
        attribute {$attribute-name} {qxsd:create-attribute-value($attribute-info, $xsd)}
};



declare function qxrxe:create-attribute-value($attribute-info, $xsd){
    let $type := qxsd:get-type($attribute-info, $xsd)
    let $value :=
        if(qxsd:get-fixed($attribute-info)) then
            qxsd:get-fixed($attribute-info)
        else if(qxsd:get-default($attribute-info)) then
            qxsd:get-default($attribute-info)
        else if (qxsd:is-enum-restriction($type)) then
            qxsd:get-first-enum-value($type)
        else
            ''
   return $value
};

(: ################# ANNOTATION #################:)

(:
declare function qxrxe:get-annotation-option-paths(){
     for $element in $relevant-elements-for-selection
        return concat($path , '/', $prefix, ':',  xs:string($element/@name))
};:)

declare function qxrxe:get-annotation-options($parent, $context-node, $path, $content, $selection, $xsd){

    let $declare := qxrxe:declare-namespaces($content)

    let $relevant-elements := qxrxe:get-relevant-elements($parent, $context-node, $xsd)
    let $relevant-elements-in-content := qxrxe:get-relevant-elements-in-content($relevant-elements, $path, $content, $selection, $xsd)
    let $relevant-elements-for-selection := qxrxe:get-relevant-elements-in-selection($relevant-elements-in-content, $selection, $xsd)
    return $relevant-elements-for-selection


};

declare function qxrxe:get-relevant-elements-in-content($elements, $path, $content, $selection, $xsd){

    let $prefix-string := qxrxe:prefix-string($path)

    (:TODO: Attention $element could have a different prefix:)
    for $element in $elements
        let $element-name := xs:string(qxrxe:get-name($element))
        let $count := util:eval(concat('count($content/', $prefix-string, $element-name, ')')) -  util:eval(concat('count($selection/', $prefix-string , $element-name, ')'))

        let $max := qxrxe:max-occurs($element, $xsd)

        return
            if($max)then
                if($count lt xs:int($max)) then
                    $element
                 else
                    ()

            else
                $element


};

declare function qxrxe:prefix-string($path){
     let $prefix := qxsd:get-prefix(qxsd:get-name($path))
        return
        if($prefix) then
               concat($prefix, ':')
        else
            ''
};

declare function qxrxe:get-relevant-elements-in-selection($elements, $selection, $xsd){
    for $element in $elements
        return qxrxe:if-relevant-in-selection($element, $selection, $xsd)
};

declare function qxrxe:if-relevant-in-selection($element, $selection, $xsd){

        if($selection/element() or $selection/text()) then
            if($selection/element() and $selection/text()) then
                if (qxrxe:is-mixed($element, $xsd) and not(qxrxe:is-empty($element, $xsd))) then
                    qxrxe:if-relevant-for-selected-elements($element, $selection, $xsd)
                else ()
            else if ($selection/element()) then
                if (qxrxe:is-complex-type($element, $xsd) and not(qxrxe:is-empty($element, $xsd))) then
                    qxrxe:if-relevant-for-selected-elements($element, $selection, $xsd)
                else ()
            else if ($selection/text()) then
                (:complexType only to allow annotation of complexTypes temoraraly until better method exists:)
                if ((qxrxe:is-complex-type($element, $xsd) or qxrxe:is-simple-type($element, $xsd) or qxrxe:is-mixed($element, $xsd)) and not(qxrxe:is-empty($element, $xsd))) then
                    (:differ mixed and simple:)
                    (:check xs:datatype:)
                    (:check type:)
                    $element
                else ()

            else ()
        else
            (:No Content of Selection
            use $element or () if is not empty?
            check if type allows this :)
            $element
};

declare function qxrxe:if-relevant-for-selected-elements($element, $selection, $xsd){

let $distinct-selected-element-names :=
    distinct-values(for $selected-element in  $selection/element()
        return name($selected-element)
    )

return
if(qxrxe:if-relevant-for-selected-element($element, $distinct-selected-element-names, 1, $selection, $xsd)) then
    $element
else
    ()

};

declare function  qxrxe:if-relevant-for-selected-element($element, $distinct-selected-element-names, $pos, $selection,  $xsd){

if($pos gt count($distinct-selected-element-names)) then
    true()
else
    let $selected-element-name := $distinct-selected-element-names[$pos]
    let $selected-element-info := qxrxe:get-node-info($selected-element-name, $element, $xsd)
    return
        if($selected-element-info) then
            let $count := util:eval(concat('count($selection/', $selected-element-name, ')'))
            (:max Choice:)
            (:max Sequence:)
            return
            if(xs:int(qxrxe:get-max-occur($selected-element-info, $xsd)) ge $count) then
                qxrxe:if-relevant-for-selected-element($element, $distinct-selected-element-names, $pos + 1, $selection, $xsd)
            else
                ()
        else
            false()
};

(: ################# ATTRIBUTE OPTIONS #################:)

declare function qxrxe:get-attribute-options($element, $type, $node-info, $xsd){
    for $relevant-attribute in qxrxe:get-relevant-attributes($type, $node-info, $xsd)
    let $attribute-name := qxrxe:get-name($relevant-attribute)

    let $prefix := qxsd:get-prefix($attribute-name)
    let $namespace := xs:string(qxrxe:get-namespace($relevant-attribute))
    let $declare :=
        if($prefix and xs:anyURI($namespace)) then
            util:declare-namespace($prefix, xs:anyURI($namespace))
        else
           ()

    return
    if(util:eval(concat('$element/@', $attribute-name))) then
        ()
    else
        $relevant-attribute
};

(: ################ ELEMENT INFO ##################:)

(: ################# UTIL #################:)


(: FROM http://en.wikibooks.org/wiki/XQuery/Filtering_Nodes :)
declare function qxrxe:copy($element as element()) as element() {
   element {node-name($element)}
      {$element/@*,
          for $child in $element/node()
              return
               if ($child instance of element())
                 then qxrxe:copy($child)
                 else $child
      }
};

declare function qxrxe:declare-namespace($prefix, $namespace){
    if($prefix!='xml') then
        util:declare-namespace($prefix, xs:anyURI($namespace))
    else
        ()
};


(:copied from xrxe:)
declare function qxrxe:declare-namespaces($node){

for $xmlns in  qxrxe:get-all-xmlns($node)
    return util:declare-namespace(xs:string($xmlns/@prefix), xs:anyURI($xmlns/@namespace))

};

(:copied from xrxe:)
declare function qxrxe:get-all-xmlns ($node){
    for $node in $node//element() | $node//attribute()
        let $prefix := prefix-from-QName(node-name($node))
        let $namespace := namespace-uri-from-QName(node-name($node))
            return
                if($prefix and $namespace and $prefix!='xml') then
                    <xmlns prefix="{$prefix}" namespace="{$namespace}" />
                else ()
 } ;



(:new namespaces:)

declare function qxrxe:get-node-prefix-namespaces($path, $xsd){
    ()(:let $xsd := qxsd:xsd($xsd)
    let $node-info := qxrxe:get-node-info($path, (), $xsd)
    return qxrxe:get-distinct-prefix-namespaces(qxrxe:prefix-namespaces($node-info, qxsd:get-prefix(qxsd:get-name($path)), () ,  $xsd, 1)):)
};

(:
(:copied from xrxe:)
 declare function qxrxe:get-distinct-prefix-namespaces($xmlns) {

  for $prefix in distinct-values($xmlns/@prefix)
     return
     <xmlns prefix="{$prefix}" namespace="{subsequence($xmlns[@prefix=$prefix]/@namespace, 1, 1)}"/>
};

 declare function qxrxe:prefix-namespaces($node-info, $prefix, $context-node, $xsd, $depth){

    if($depth > $xrxe-conf:default-max-depth) then
        ()
    else
         (
         <xmlns prefix="{qxrxe:check-prefix($node-info, $prefix, $context-node) }" namespace="{qxrxe:get-namespace($node-info)}" node-name="{name($node-info)}" name="{$node-info/@name}"/>
         ,
         let $type := qxsd:get-type($node-info, $xsd)
         return
             for $child-node-info in xrxe:get-child-infos($type, $node-info, $xsd)
             return
                qxrxe:prefix-namespaces($child-node-info, $prefix, $node-info, $xsd, $depth+1)
         )


};

declare function qxrxe:check-prefix($node-info, $prefix, $context-node){
    let $prefix :=
        if($node-info/@ref and contains(xs:string($node-info/@ref), ':')) then
            substring-before(xs:string($node-info/@ref), ':')
        else
            $prefix

     return qxrxe:declare($prefix, $node-info, $context-node)
};

declare function qxrxe:declare($prefix, $node-info, $context-node){
    let $namespace := xs:anyURI(qxrxe:get-namespace($node-info))
    let $declare :=
        if(not($context-node) or $namespace!= xs:anyURI(qxrxe:get-namespace($context-node))) then
             qxrxe:declare-namespace($prefix, $namespace)
        else
            ()
    return $prefix
};
:)
