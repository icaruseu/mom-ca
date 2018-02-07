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

module namespace portal="http://www.monasterium.net/NS/portal";

declare namespace xf="http://www.w3.org/2002/xforms";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../xrx/conf.xqm";
import module namespace css="http://www.monasterium.net/NS/css"
    at "../xrx/css.xqm";
import module namespace xrx="http://www.monasterium.net/NS/xrx"
    at "../xrx/xrx.xqm";

(:
    returns a document of type xrx:portal
    by handing over a main widget of 
    type xrx:widget
:)
declare function portal:get($main-widget as element(xrx:widget)) as element() {

    let $portal-id := 
        $main-widget/xrx:portal/text()
    return
    $xrx:db-base-collection//xrx:id[.=$portal-id]/parent::xrx:portal
};
