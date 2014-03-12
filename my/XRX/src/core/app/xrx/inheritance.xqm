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

module namespace inheritance="http://www.monasterium.net/NS/inheritance";

declare namespace xrx="http://www.monasterium.net/NS/xrx";

declare function inheritance:modules($modules as element(xrx:modules)*) as element() {

    <xrx:modules>
    {
        for $module in $modules[count($modules)]/xrx:module
        let $resource-name := $module/xrx:resource/text()
        let $origin := util:collection-name($module)
        return
        <xrx:module>
            <xrx:resource origin="{ $origin }">{ $resource-name }</xrx:resource>
            { $module/xrx:prefix }
            { $module/xrx:uri }
        </xrx:module>
    }
    </xrx:modules>
};

declare function inheritance:resources($resources as element(xrx:resources)*) as element() {

    <xrx:resources>
    {
        for $resource in $resources[count($resources)]/xrx:resource
        let $name := $resource/xrx:name/text()
        let $relative-path := $resource/xrx:relativepath/text()
        let $origin := if($relative-path != '') then concat(util:collection-name($resource), '/', $relative-path) else util:collection-name($resource)
        return
        <xrx:resource>
            { $resource/xrx:atomid }
            <xrx:relativepath>{ $relative-path }</xrx:relativepath>
            <xrx:name origin="{ $origin }">{ $name }</xrx:name>
        </xrx:resource>
    }
    </xrx:resources>
};