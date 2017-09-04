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

module namespace data="http://www.monasterium.net/NS/data";

declare namespace atom="http://www.w3.org/2005/Atom";

import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../xrx/conf.xqm";
import module namespace xrx="http://www.monasterium.net/NS/xrx"
    at "../xrx/xrx.xqm";


declare function data:validate($data as element(), $schemas as element(xs:schema)+) as element() {

    validation:jaxv-report($data, $schemas, 'http://www.w3.org/XML/XMLSchema/v1.1')
};

declare function data:objectid($atomid as xs:string, 
                               $datatype as element()) as xs:string {

    typeswitch($datatype)
    
    (: get the last URI token from a metadata Atom ID :)
    case element(xrx:metadata) return
    
        (tokenize($atomid, '/'))[last()]
    
    default return ()
};

declare function data:uri-tokens($atomid as xs:string,
                                 $datatype as element()) as xs:string+ {

    let $tokens := tokenize($atomid, '/')
    
    return
            
    typeswitch($datatype)
    
    (: get the URI tokens from a metadata Atom ID :)
    case element(xrx:metadata) return
        
        subsequence($tokens, 3, count($tokens) - 3)
    
    case element(xrx:revision) return
    
        subsequence($tokens, 3, count($tokens) - 5)
    
    default return ()
};

declare function data:object-type($atomid as xs:string,
                                  $datatype as element()) as xs:string {

    typeswitch($datatype)
    
    (: get the object type from a metadata Atom ID :)
    case element(xrx:metadata) return
    
        (tokenize($atomid, '/'))[2]
    
    case element(xrx:revision) return
    
        (tokenize($atomid, '/'))[2]
        
    default return ()
};

(: get a atom entry :)
declare function data:entry($base-collection-path as xs:string, 
                            $atomid as xs:string) {

    collection($base-collection-path)//atom:id[.=$atomid]/parent::atom:entry
};

declare function data:base-collection-path($object-type as xs:string, 
                                           $object-uri-tokens as xs:string*, 
                                           $metadata-scope as xs:string,
                                           $revision-flag as xs:boolean,
                                           $datatype as element()) as xs:string {

    typeswitch($datatype)

    case element(xrx:metadata) return

    concat(
    
        if(starts-with($metadata-scope, 'private')) then
        
            let $user-token := substring-after($metadata-scope, 'private:')
            let $userid := 
                if($user-token != '') then $user-token
                else $xrx:user-id
            return
            data:uri(
                concat(
                    conf:param('xrx-user-db-base-uri'),
                    $userid,
                    '/metadata.',
                    $object-type,
                    if($revision-flag = true()) then '.revision' else '',
                    '/',
                    string-join(
                        $object-uri-tokens,
                        '/'
                    )
                )
            )
        else
            data:uri(
                concat(
                    conf:param('atom-db-base-uri'),
                    '/metadata.',
                    $object-type,
                    '.',
                    $metadata-scope,
                    if($revision-flag = true()) then '.revision' else '',
                    '/',
                    string-join(
                        $object-uri-tokens,
                        '/'
                    )
                )
            ),
            
        '/'
    ) 
    
    default return ()   
};

declare function data:feed($object-type as xs:string,
                           $metadata-scope as xs:string,
                           $revision-flag as xs:boolean,
                           $datatype as element()) as xs:string {

    typeswitch($datatype)

    case element(xrx:metadata) return
    
    if(starts-with($metadata-scope, 'private')) then
    
        let $user-token := substring-after($metadata-scope, 'private:')
        let $userid := 
            if($user-token != '') then $user-token
            else $xrx:user-id
        return
        data:uri(
            concat(
                conf:param('xrx-user-atom-base-uri'),
                $userid,
                '/metadata.',
                $object-type,
                if($revision-flag = true()) then '.revision' else ''
            )
        )
    else
        data:uri(
            concat(
                '/metadata.',
                $object-type,
                '.',
                $metadata-scope,
                if($revision-flag = true()) then '.revision' else ''
            )
        )
    
    default return ()
};

declare function data:feed($object-type as xs:string, 
                           $object-uri-tokens as xs:string*, 
                           $metadata-scope as xs:string, 
                           $revision-flag as xs:boolean,
                           $datatype as element()) as xs:string {

    typeswitch($datatype)

    case element(xrx:metadata) return
    
    if(starts-with($metadata-scope, 'private')) then

        let $user-token := substring-after($metadata-scope, 'private:')
        let $userid := 
            if($user-token != '') then $user-token
            else $xrx:user-id
        return
        data:uri(
            concat(
                conf:param('xrx-user-atom-base-uri'),
                $userid,
                '/metadata.',
                $object-type,
                if($revision-flag = true()) then '.revision' else '',
                '/',
                string-join(
                    $object-uri-tokens,
                    '/'
                )
            )
        )
    else
        data:uri(
            concat(
                '/metadata.',
                $object-type,
                '.',
                $metadata-scope,
                if($revision-flag = true()) then '.revision' else '',
                '/',
                string-join(
                    $object-uri-tokens,
                    '/'
                )
            )
        )
    
    default return ()
};

declare function data:uri($uri as xs:string) as xs:anyURI {

    (: 
        Be careful! The xmldb:encode-uri() function
        removes any slash at the end of a given
        string 
    :)
    xmldb:encode-uri(xmldb:decode($uri))
};