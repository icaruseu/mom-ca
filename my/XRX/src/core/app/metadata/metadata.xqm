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
along with VdU/VRET.  If not, see &lt;http://www.gnu.org/licenses/&gt;.

We expect VdU/VRET to be distributed in the future with a license more lenient towards the inclusion of components into other systems, once it leaves the active development stage.
:)

module namespace metadata="http://www.monasterium.net/NS/metadata";

import module namespace data="http://www.monasterium.net/NS/data"
    at "../data/data.xqm";
import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../xrx/conf.xqm";
import module namespace xrx="http://www.monasterium.net/NS/xrx"
    at "../xrx/xrx.xqm";

declare variable $metadata:datatype := <xrx:metadata/>;

(:
###############################
#
# [A] Public Interface
#
###############################
:)

(:
###############################
#
# (1) Atom related functions
#
#
# a. Functions to handle Atom Entries
#
###############################
:)



(: get a atom entry :)
declare function metadata:entry($base-collection-path as xs:string, 
                                $atomid as xs:string) as element() {

    data:entry($base-collection-path, $atomid)
};



(: compose an entry name by handing over a object type and a single URI token :)
declare function metadata:entryname($object-type as xs:string, $objectid as xs:string) as xs:string {

    xmldb:encode(
        xmldb:decode(
            concat(
                $objectid,
                '.',
                $object-type,
                '.xml'
            )
        )
    )
};



(:
###############################
#
# (1) Atom related functions
#
#
# b. Functions to handle Atom IDs
#
###############################
:)
(: get the object ID (=the last URI token) from a Atom ID :)
declare function metadata:objectid($atomid as xs:string) as xs:string {
    
    data:objectid($atomid, $metadata:datatype)
};
(: get the URI tokens from a Atom ID :)
declare function metadata:uri-tokens($atomid as xs:string) as xs:string+ {
    
    data:uri-tokens($atomid, $metadata:datatype)
};
(: get the object type from a Atom ID :)
declare function metadata:object-type($atomid as xs:string) as xs:string {

    data:object-type($atomid, $metadata:datatype)
};
(: compose an Atom ID by handing over an object type and URI tokens :)
declare function metadata:atomid($object-type as xs:string, 
                                 $object-uri-tokens as xs:string*) as xs:string {
    
    concat(
        conf:param('atom-tag-name'),
        '/',
        $object-type,
        data:uri(
            concat(
                '/',
                string-join(
                    $object-uri-tokens,
                    '/'
                )
            )
        )
    )
};

(:
###############################
#
# (1) Atom related functions
#
#
# c. Functions to handle Atom Feeds
#
###############################
:)
declare function metadata:feed( $object-type as xs:string, 
                                $metadata-scope as xs:string) as xs:string {

    data:feed($object-type, $metadata-scope, false(), <xrx:metadata/>)
};

declare function metadata:feed( $object-type as xs:string, 
                                $object-uri-tokens as xs:string*, 
                                $metadata-scope as xs:string) as xs:string {

    data:feed($object-type, $object-uri-tokens, $metadata-scope, false(), <xrx:metadata/>)
};

(:
###############################
#
# (3) DB collection related functions
#
#
# a. Functions to handle collection paths
#
###############################
:)
declare function metadata:base-collection($object-type as xs:string, 
                                          $metadata-scope as xs:string) as node()* {

    collection(
        metadata:base-collection-path(
            $object-type, 
            $metadata-scope
        )
    )
};

declare function metadata:base-collection($object-type as xs:string, 
                                          $object-uri-tokens as xs:string*,  
                                          $metadata-scope as xs:string) as node()* {

    collection(
        metadata:base-collection-path(
            $object-type, 
            $object-uri-tokens,  
            $metadata-scope
        )
    )
};

declare function metadata:base-collection-path($object-type as xs:string, 
                                               $metadata-scope as xs:string) as xs:string {

    concat(
    
        if($metadata-scope = 'private') then
            data:uri(
                concat(
                    conf:param('xrx-user-db-base-uri'),
                    $xrx:user-id,
                    '/metadata.',
                    $object-type
                )
            )            
        else
            data:uri(
                concat(
                    conf:param('atom-db-base-uri'),
                    '/metadata.',
                    $object-type,
                    '.',
                    $metadata-scope
                )
            ),
        
        '/'
    )
};

declare function metadata:base-collection-path($object-type as xs:string, 
                                               $object-uri-tokens as xs:string*, 
                                               $metadata-scope as xs:string) as xs:string {

    data:base-collection-path($object-type, $object-uri-tokens, $metadata-scope, false(), <xrx:metadata/>)
};
