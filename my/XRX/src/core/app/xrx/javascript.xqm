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

module namespace javascript="http://www.monasterium.net/NS/javascript";

declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace xrx="http://www.monasterium.net/NS/xrx";

declare function javascript:compile($widget as element(xrx:widget), $jss as element(xrx:jss)*, $xrx-live-project-db-base-collection, $xrx-resources-base-collection as node()*, $project-name as xs:string) {

    let $widgetid := $widget/xrx:id/text()
    let $resources := for $i in distinct-values($jss/xrx:resource/text()) return <xrx:resource>{$i}</xrx:resource>  
    let $jss-strings :=        
        for $js in $resources
        return
        typeswitch($js)
        case(element(xrx:resource)) return
            let $jsid := $js/text()
            let $resource := $xrx-resources-base-collection//xrx:resource[xrx:atomid=$jsid]
            let $collection-name := if($resource) then util:collection-name($resource) else ''
            let $relative-path := $resource/xrx:relativepath/text()
            let $name := $resource/xrx:name/text()
            let $uri := concat($collection-name, '/', $relative-path, $name)
            let $document := if(util:binary-doc-available($uri)) then minify:js(util:binary-to-string(util:binary-doc($uri))) else()
            return
            $document
        default return ''   
    return
    <xhtml:script id="{ $widgetid }">{ $jss-strings }</xhtml:script>
   
};