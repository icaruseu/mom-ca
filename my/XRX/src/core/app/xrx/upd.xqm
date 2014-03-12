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

(:~
    XQuery UPDATE OPERATIONS
    (for in-memory updates)
    
    This Module implements the Update Operations
    specified in W3C's "XQuery Update Facility 1.0".
    http://www.w3.org/TR/xquery-update-10/#id-update-operations
    
    In contrast to eXist's "XQuery Update Extensions" this
    module is useful for updating XML Documents in-memory, 
    but not for updating stored XML documents. To store an 
    updated XML document back into the database use the 
    
        upd:put($node as node(), $uri as xs:string) 
        
    function.
    
    This module can only be used within eXist as it depends on 
    some eXist specific utility functions, namely:
    
        - util:node-id($node as node()) xs:string
        - util:eval($expression as item()) node()*
        - util:parse($to-be-parsed as xs:string?) node()*
    
    
    TODO:
    - Support comment() and processing-instruction() nodes
:)

module namespace upd="http://www.monasterium.net/NS/upd";
declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace app="http://www.w3.org/2007/app";
declare namespace i18n="http://www.monasterium.net/NS/i18n";

(:~ 
    helper variables 
:)

declare variable $upd:dummy := <dummy/>;
declare variable $upd:ELEMENT_REACHED :=
    'util:node-id(($child|$upd:dummy)[1]) = util:node-id($target)';
declare variable $upd:ATTRIBUTE_REACHED := 
    'util:node-id($child) = util:node-id($target/parent::element())';
declare variable $upd:TEXT_REACHED :=
    'util:node-id($child) = util:node-id($target/parent::element())';

(:~ 
    helper functions 
:)

declare function upd:do-update(
    $e as element(), 
    $target as node(), 
    $content as item()*, 
    $node-reached as xs:string,
    $nodes-to-update as xs:string) {

    if(not($e instance of element(dummy))) then
    
        (: $target is root element? :)
        if($target = root($target)) then
        let $child := $target
        return
        util:eval($nodes-to-update)
        
        (: target is attribute of root element? :)
        else if($target instance of attribute() and $target/parent::element() = root($target)) then
        let $child := $target/parent::element()
        return
        util:eval($nodes-to-update)
        
        else
        element { node-name($e) } {
        
            $e/@*,
            for $child in $e/child::node()
            return
            if($child instance of element()) then
                if(util:eval($node-reached)) 
                then 
                    util:eval($nodes-to-update)
                else
                    upd:do-update(
                        $child, 
                        $target, 
                        $content, 
                        $node-reached, 
                        $nodes-to-update
                    )
            else 
                $child
        }
    else()
};

declare function upd:create-attribute($name as xs:QName, $value as xs:string) {
    root(util:parse(concat('<dummy ', xs:string($name), '="', $value ,'"/>')))//@*
};


(:~
    the update operations as defined 
:)

(:~
    # 3.1.1
    upd:insertBefore
    http://www.w3.org/TR/xquery-update-10/#id-upd-insert-before
:)

declare function upd:insert-before($target as node(), $content as node()+) {

    typeswitch($target)
    
    case element() return
    if($target = root($target)) then
    root($target)
    else
    upd:do-update(
        root($target)/child::element(), 
        $target, 
        $content,
        $upd:ELEMENT_REACHED,
        '($content, $child)'
    )
    
    case text() return
    upd:do-update(
        root($target)/child::element(), 
        $target, 
        $content,
        $upd:TEXT_REACHED,
        'element { node-name($child) }{ for $node in $child/(@*, node()) return if(util:node-id($node) != util:node-id($target)) then $node else ($content, $node) }'
    )
    
    case processing-instruction() return
    (: TODO :)
    root($target)
    
    case comment() return
    (: TODO :)
    root($target)
    
    default return 
    root($target)
};


(:~
    # 3.1.2 
    upd:insertAfter
    http://www.w3.org/TR/xquery-update-10/#id-upd-insert-after
:)

declare function upd:insert-after($target as node(), $content as node()+) {

    typeswitch($target)
    
    case element() return
    if($target = root($target)) then
    root($target)
    else
    upd:do-update(
        root($target)/child::element(), 
        $target, 
        $content,
        $upd:ELEMENT_REACHED,
        '($child, $content)'
    )
    
    case text() return
    upd:do-update(
        root($target)/child::element(), 
        $target, 
        $content,
        $upd:TEXT_REACHED,
        'element { node-name($child) }{ for $node in $child/(@*, node()) return if(util:node-id($node) != util:node-id($target)) then $node else ($node, $content) }'
    )
    
    case processing-instruction() return
    (: TODO :)
    root($target)
    
    case comment() return
    (: TODO :)
    root($target)
    
    default return 
    root($target)
};


(:~ 
    # 3.1.3 
    upd:insertInto
    http://www.w3.org/TR/xquery-update-10/#id-upd-insert-into
:)

declare function upd:insert-into($target as node(), $content as node()+) {

    typeswitch($target)
    
    case element() return
    upd:do-update(
        root($target)/child::element(), 
        $target, 
        $content,
        $upd:ELEMENT_REACHED,
        'element { node-name($child) }{ $child/@*, $content, $child/node() }'
    )
    
    case document-node() return
    $content
    
    default return 
    root($target)
};


(:~
    # 3.1.4 
    upd:insertIntoAsFirst
    http://www.w3.org/TR/xquery-update-10/#id-upd-insert-into-as-first
:)

declare function upd:insert-into-as-first($target as node(), $content as node()+) {

    upd:insert-into(
        $target, 
        $content
    )  
};


(:~
    # 3.1.5 
    upd:insertIntoAsLast
    http://www.w3.org/TR/xquery-update-10/#id-upd-insert-into-as-last
:)

declare function upd:insert-into-as-last($target as node(), $content as node()+) {

    typeswitch($target)
    
    case element() return
    upd:do-update(
        root($target)/child::element(), 
        $target, 
        $content,
        $upd:ELEMENT_REACHED,
        'element { node-name($child) }{ $child/@*, $child/node(), $content }'
    )
    
    case document-node() return
    $content
    
    default return 
    root($target)
};


(:~
    # 3.1.6 
    upd:insertAttributes
    http://www.w3.org/TR/xquery-update-10/#id-upd-insert-attributes
:)

declare function upd:insert-attributes($target as element(), $content as attribute()+) {

    upd:do-update(
        root($target)/child::element(), 
        $target, 
        $content,
        $upd:ELEMENT_REACHED,
        'element { node-name($child) }{ $child/@*, $content, $child/node() }'
    )
};


(:~
    # 3.1.7 
    upd:delete
    http://www.w3.org/TR/xquery-update-10/#id-upd-delete
:)

declare function upd:delete($target as node()) {

    typeswitch($target)
    
    case element() return
    if($target = root($target)) then
    root($target)
    else
    upd:do-update(
        root($target)/child::element(), 
        $target, 
        (),
        $upd:ELEMENT_REACHED,
        <dummy/>
    )
    
    case attribute() return
    upd:do-update(
        root($target)/child::element(),
        $target, 
        (),
        $upd:ATTRIBUTE_REACHED,
        'element { node-name($child) } { $child/@*[util:node-id(.) != util:node-id($target)], $child/node() }'
    )
    
    case text() return
    upd:do-update(
        root($target)/child::element(), 
        $target, 
        (),
        $upd:TEXT_REACHED,
        'element { node-name($child) } { $child/@*, $child/node()[util:node-id(.) != util:node-id($target)] }'
    )    
    
    case processing-instruction() return
    (: TODO :)
    root($target)
    
    case comment() return
    (: TODO :)
    root($target)
    
    default return 
    root($target)
};


(:~
    # 3.1.8 
    upd:replaceNode
    http://www.w3.org/TR/xquery-update-10/#id-upd-replacenode
:)

declare function upd:replace-node($target as node(), $replacement as node()*) {
    
    typeswitch($target)

    case element() return
    if($target = root($target)) then
    root($target)
    else
    upd:do-update(
        root($target)/child::element(), 
        $target, 
        $replacement,
        $upd:ELEMENT_REACHED,
        '$content'
    )
    
    case attribute() return
    upd:do-update(
        root($target)/child::element(), 
        $target, 
        $replacement,
        $upd:ATTRIBUTE_REACHED,
        'element { node-name($child) } { $child/@*[util:node-id(.) != util:node-id($target)], $content, $child/node() }'
    )     
    
    case text() return
    upd:do-update(
        root($target)/child::element(), 
        $target, 
        $replacement,
        $upd:TEXT_REACHED,
        'element { node-name($child) } { for $node in $child/(@*, node()) return if(util:node-id($node) != util:node-id($target)) then $node else $content }'
    )   
    
    case comment() return
    (: TODO :)
    root($target)
    
    case processing-instruction() return
    (: TODO :)
    root($target)
    
    default return
    root($target)
};


(:~
    # 3.1.9 
    upd:replaceValue
    http://www.w3.org/TR/xquery-update-10/#id-upd-replace-value
:)

declare function upd:replace-value($target as node(), $string-value as xs:string) {
    
    typeswitch($target)

    case attribute() return
    upd:do-update(
        root($target)/child::element(), 
        $target, 
        $string-value,
        $upd:ATTRIBUTE_REACHED,
        'element { node-name($child) } { for $node in $child/(@*, node()) return if(util:node-id($node) != util:node-id($target)) then $node else upd:create-attribute(node-name($node), $content) }'
    )        
    
    case text() return
    upd:do-update(
        root($target)/child::element(), 
        $target, 
        $string-value,
        $upd:TEXT_REACHED,
        'element { node-name($child) } { for $node in $child/(@*, node()) return if(util:node-id($node) != util:node-id($target)) then $node else $content }'
    )    
    
    case comment() return
    (: TODO :)
    root($target)
    
    case processing-instruction() return
    (: TODO :)
    root($target)
    
    default return
    root($target)
};


(:~
    # 3.1.10 
    upd:replaceElementContent
    http://www.w3.org/TR/xquery-update-10/#id-upd-replace-element-content
:)

declare function upd:replace-element-content($target as element(), $text as text()?) {

    upd:do-update(
        root($target)/child::element(), 
        $target, 
        $text,
        $upd:ELEMENT_REACHED,
        'element { node-name($child) } { $child/@*, $content }'
    )
};


(: ~
    # 3.1.11 
    upd:rename
    http://www.w3.org/TR/xquery-update-10/#id-upd-rename
:)

declare function upd:rename($target as node(), $new-name as xs:QName) {

    typeswitch($target)
    
    case element() return
    upd:do-update(
        root($target)/child::element(), 
        $target, 
        $new-name,
        $upd:ELEMENT_REACHED,
        concat(
            'element { "', 
            $new-name, 
            '" }{ $child/@*, $child/node() }')
    )
    
    case attribute() return
    upd:do-update(
        root($target)/child::element(), 
        $target, 
        $new-name,
        $upd:ATTRIBUTE_REACHED,
        'element { local-name($child) }{ upd:create-attribute($content, data($target)), $child/@*[node-name(.) != node-name($target)], $child/node() }'
    )
    
    case processing-instruction() return
    (: TODO :)
    root($target)
    
    default return
    root($target)
};


(:~
    # 3.1.12 
    upd:put
    http://www.w3.org/TR/xquery-update-10/#id-upd-put
:)

declare function upd:put($node as node(), $uri as xs:string) {
    <null/>
};
