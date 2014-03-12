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

module namespace resource="http://www.monasterium.net/NS/resource";

declare namespace xrx="http://www.monasterium.net/NS/xrx";

declare function resource:mime-type($uri as xs:anyURI) {
    
    xmldb:get-mime-type($uri)
};

declare function resource:name($atomid as xs:string, $base-collection) as xs:string* {

    let $resource := $base-collection//xrx:resource[xrx:atomid=$atomid]
    let $name := $resource/xrx:name/text()
    return
    $name   
};

declare function resource:uri($atomid as xs:string, $base-collection) {

    let $resource := $base-collection//xrx:resource[xrx:atomid=$atomid]
    let $relative-path := $resource/xrx:relativepath/text()
    let $name := $resource/xrx:name/text()
    return
    xs:anyURI(concat(util:collection-name($resource), '/', $relative-path, $name))
};

declare function resource:document($atomid as xs:string, $base-collection) as xs:string? { 

    let $uri := resource:uri($atomid, $base-collection)
    return
    if(util:binary-doc-available($uri)) then util:binary-to-string(util:binary-doc($uri)) else ''
};

declare function resource:document($uri) { 

    if(util:binary-doc-available($uri)) then 
        util:binary-doc($uri)
    else if(doc($uri)) then
        doc($uri)
    else ''
};

declare function resource:binary($atomid as xs:string, $base-collection) {

    let $uri := resource:uri($atomid, $base-collection)
    return
    if(util:binary-doc-available($uri)) then util:binary-doc($uri) else ()    
};