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

module namespace atom="http://www.w3.org/2005/Atom";

import module namespace sm="http://exist-db.org/xquery/securitymanager";
import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../xrx/conf.xqm";
import module namespace xrx="http://www.monasterium.net/NS/xrx"
    at "../xrx/xrx.xqm";

declare namespace app="http://www.w3.org/2007/app";

declare variable $atom:group-name := 'atom';
declare variable $atom:default-permission := 'rwxrwxrwx';
declare variable $atom:db-base-uri := conf:param('atom-db-base-uri');
declare variable $atom:db-base-collection := collection($atom:db-base-uri);
declare variable $atom:data := ();
declare variable $atom:url := request:get-uri();
declare variable $atom:tok-url := tokenize($atom:url, '/');
declare variable $atom:action := $atom:tok-url[4];
declare variable $atom:feed := substring-after($atom:url, $atom:action);
declare variable $atom:resource := 
    if($atom:tok-url[last()] = '') then
        $atom:data//atom:id/text()
    else 
        $atom:tok-url[last()];
declare variable $atom:collection := 
    if($atom:tok-url[last()] = '') then $atom:feed
    else substring-before($atom:feed, $atom:tok-url[last()]);

declare function atom:set-permissions($collection-uri as xs:string*) {

    (
        system:as-user('admin', conf:param('dba-password'), sm:chgrp($collection-uri, $atom:group-name)),
        system:as-user('admin', conf:param('dba-password'), sm:chmod($collection-uri, $atom:default-permission))
    )
};

declare function atom:create-collection($base-collection, $cols-to-create, $num) {

    let $new-collection := concat($base-collection, '/', $cols-to-create[$num])
    let $create-collection := 
        if($cols-to-create[$num] != '') then let $x := ()
            let $create := system:as-user('admin', conf:param('dba-password'), xmldb:create-collection($base-collection, $cols-to-create[$num]))
            let $permissions := atom:set-permissions($new-collection)
            return
            ()
        else()
    return
    if($num le count($cols-to-create)) then atom:create-collection($new-collection, $cols-to-create, $num + 1)
    else()
};

declare function atom:create-collections($collection) {
    let $cols-to-create := 
        for $col in tokenize(substring-after($collection, $atom:db-base-uri), '/')
        return
        if($col != '') then $col
        else ()
    let $create-cols := 
        for $col-to-create in $cols-to-create
        return
        atom:create-collection($atom:db-base-uri, $cols-to-create, 1)
    return
    <null/>
};

declare function atom:auth-by-group($group) {

    true()
};

declare function atom:entry-to-update($element) {
    element {node-name($element)}
    {
        $element/@*,
        for $child in $element/node()
        return
        if($child instance of element()) then
            if(matches(node-name($child), 'atom:updated') and ($child/ancestor::atom:entry[1] = root($child))) then
                <atom:updated>{ current-dateTime() }</atom:updated>
            else if(matches(node-name($child), 'atom:email') and ($child/ancestor::atom:entry[1] = root($child))) then
                <atom:email>{ $xrx:user-id }</atom:email>
            else 
                atom:entry-to-update($child)
        else $child
    }
};

declare function atom:entry-to-create($element) {
    element {node-name($element)}
    {
        $element/@*,
        for $child in $element/node()
        return
        if($child instance of element()) then
            if(matches(node-name($child), 'atom:updated') and ($child/ancestor::atom:entry[1] = root($child))) then
                <atom:updated>{ current-dateTime() }</atom:updated>
            else if(matches(node-name($child), 'atom:published') and ($child/ancestor::atom:entry[1] = root($child))) then
                <atom:published>{ current-dateTime() }</atom:published>
            else if(matches(node-name($child), 'atom:email') and ($child/ancestor::atom:entry[1] = root($child))) then
                <atom:email>{ $xrx:user-id }</atom:email>
            else 
                atom:entry-to-create($child)
        else $child
    }
};

declare function atom:GET() {
    let $entry := doc(concat('xmldb:exist://', xmldb:encode(xmldb:decode(concat($atom:db-base-uri, $atom:feed)))))
    return
    if(local-name($entry/atom:*) = 'entry') then
        if($entry/atom:entry/app:control/app:draft/text()='no') then
            $entry
        else <atom:null/>
    else if(not($entry)) then <atom:null/>
    else $entry
};

declare function atom:PUT($data) {

    atom:PUT($atom:collection, $atom:resource, $data)
};

declare function atom:PUT($collection, $resource, $data) {

    let $base-collection := concat($atom:db-base-uri, $collection)
    return
    if(atom:auth-by-group($atom:group-name)) then
        let $entry-to-update := atom:entry-to-update($data/root()/*)
        let $store := xmldb:store($base-collection, $resource, $entry-to-update)
        let $uri := concat($base-collection, '/', $resource)
        let $set-permissions := atom:set-permissions($uri)
        return
        $entry-to-update
    else()
};

declare function atom:PUTSILENT($collection, $resource, $data) {
    
    let $base-collection := concat($atom:db-base-uri, $collection)
    return
    if(atom:auth-by-group($atom:group-name)) then
        let $entry-to-update := $data/root()/*
        let $store := xmldb:store($base-collection, $resource, $entry-to-update)
        let $uri := concat($base-collection, '/', $resource)
        let $set-permissions := atom:set-permissions($uri)
        return
        $entry-to-update
    else()
};

declare function atom:POST($data) {

    atom:POST($atom:collection, $atom:resource, $data)
};

declare function atom:POST($collection, $resource, $data) {

    let $base-collection := concat($atom:db-base-uri, $collection)
    return
    if(atom:auth-by-group($atom:group-name)) then
        let $entry-to-create := atom:entry-to-create($data/root()/*)
        let $collection-available := xmldb:collection-available($base-collection)
        let $create-collection := 
            if(not($collection-available)) then atom:create-collections($base-collection) 
            else()
        let $create := system:as-user('admin', conf:param('dba-password'), xmldb:store($base-collection, $resource, $entry-to-create))
        let $uri := concat($base-collection, '/', $resource)
        let $set-permissions := system:as-user('admin', conf:param('dba-password'), atom:set-permissions($uri))
        return
        $entry-to-create
    else()
};

declare function atom:POSTSILENT($collection, $resource, $data) {

    let $base-collection := concat($atom:db-base-uri, $collection)
    return
    if(atom:auth-by-group($atom:group-name)) then
        let $entry-to-create := $data/root()/*
        let $collection-available := xmldb:collection-available($base-collection)
        let $create-collection := 
            if(not($collection-available)) then atom:create-collections($base-collection) 
            else()
        let $create := xmldb:store($base-collection, $resource, $entry-to-create)
        let $uri := concat($base-collection, '/', $resource)
        let $set-permissions := atom:set-permissions($uri)
        return
        $entry-to-create
    else()
};

declare function atom:DELETE() {

    atom:DELETE($atom:collection, $atom:resource)
};

declare function atom:DELETE($collection, $resource) {
    
    let $base-collection := concat($atom:db-base-uri, $collection)
    return
    if(atom:auth-by-group($atom:group-name)) then
        let $delete := xmldb:remove($base-collection, $resource)
        return
        ()
    else()
};

declare function atom:DELETE($collection) {

        ()
};

declare function atom:entry-to-contribute($data) {

    let $contributor-exists :=
      if($data//atom:contributor/atom:email[.=$xrx:user-id]) then true()
      else false()
    let $some-contributor-exists :=
      if($data//atom:contributor) then true()
      else false()
    return
    atom:create-entry-to-contribute($data, $contributor-exists, $some-contributor-exists)
};

declare function atom:create-entry-to-contribute($element, $contributor-exists as xs:boolean, $some-contributor-exists as xs:boolean) as element() {

    element {node-name($element)}
    {
        $element/@*,
        for $child in $element/node()
        return
        if($child instance of element()) then
            
            typeswitch($child)
            
            case element(atom:contributor) return
            
                (
                    $child,
                    if($contributor-exists) then ()
                    else
                    <atom:contributor>
                      <atom:email>{ $xrx:user-id }</atom:email>
                    </atom:contributor>
                )
            
            case element(atom:author) return
            
                if(not($some-contributor-exists)) then
                    
                    (
                        $child,
                        <atom:contributor>
                          <atom:email>{ $xrx:user-id }</atom:email>
                        </atom:contributor>
                    )
                
                else $child
            
            case element(atom:updated) return
            
                <atom:updated>{ current-dateTime() }</atom:updated>
            
            default return 
                
                atom:create-entry-to-contribute($child, $contributor-exists, $some-contributor-exists)
            
        else $child
    }    
};

declare function atom:CONTRIBUTE($data) {

    atom:CONTRIBUTE($atom:collection, $atom:resource, $data)
};

declare function atom:CONTRIBUTE($feed as xs:string, $entry-name as xs:string, $data as element(atom:entry)) {

    let $base-collection := concat($atom:db-base-uri, $feed)
    return
    if(atom:auth-by-group($atom:group-name)) then
        let $entry-to-update := atom:entry-to-contribute($data/root()/*)
        let $store := xmldb:store($base-collection, $entry-name, $entry-to-update)
        let $uri := concat($base-collection, '/', $entry-name)
        let $set-permissions := atom:set-permissions($uri)
        return
        $entry-to-update
    else()    
};

