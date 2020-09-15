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

module namespace template="http://www.monasterium.net/NS/template";

declare namespace xrx="http://www.monasterium.net/NS/xrx";

declare function template:eval($template as element(xrx:template)) {

    let $xml := $template/xrx:xml
    let $serialize := serialize($xml, ())
    return
    if($serialize != '') then util:eval($serialize, false())/node()
    else()
};

declare function template:get($atomid as xs:string) as element() {

    util:deep-copy($xrx:db-base-collection//xrx:id[.=$atomid]/parent::xrx:template/xrx:xml/*)
};

declare function template:get($atomid as xs:string, $deep-copy-flag as xs:boolean) as element() {

    let $template := $xrx:db-base-collection//xrx:id[.=$atomid]/parent::xrx:template/xrx:xml/*
    return
    if($deep-copy-flag) then util:deep-copy($template)
    else $template
};