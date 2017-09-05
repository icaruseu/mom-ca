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

module namespace resolver="http://www.monasterium.net/NS/resolver";

declare namespace xrx="http://www.monasterium.net/NS/xrx";

declare function resolver:resolve($live-project-db-base-collection) as element()* {
    let $url := request:get-uri()
    let $first-match :=
        (
            for $uri-pattern in $live-project-db-base-collection//xrx:resolver/xrx:map/xrx:uripattern[matches($url, text())]
            let $priority := ($uri-pattern/parent::xrx:map/@priority/string(), '999')[1]
            order by $priority ascending
            return
            
                $uri-pattern/parent::xrx:map
            
        )[1]
    return
    $first-match
};
