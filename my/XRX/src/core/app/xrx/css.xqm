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



(:
    ##################
    #
    # CSS Module
    #
    ##################
    
    
    A module that handles CSS rules which are
    defined in XRX widgets or portals
    
    Since this module is included by xrx.xql
    these functions and variables are visible 
    for all widgets, services, portals ...
:)

module namespace css="http://www.monasterium.net/NS/css";

declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace xrx="http://www.monasterium.net/NS/xrx";

import module namespace resource="http://www.monasterium.net/NS/resource"
    at "../xrx/resource.xqm";

declare variable $css:jquery-theme-base-atomid := 'tag:www.monasterium.net,2011:/xrx/resource/jquery/theme/';

declare function css:compile($widget as element(xrx:widget), $csss as element(xrx:csss)*, $xrx-live-project-db-base-collection, $xrx-resources-base-collection as node()*) {

    let $widgetid := $widget/xrx:id/text()
    let $css-strings :=
        for $css in $csss/*
        let $cssid := $css/text()
        return
        typeswitch($css)
        case(element(xhtml:style)) return $cssid
        case(element(xrx:resource)) return 
            let $string := resource:document($cssid, $xrx-resources-base-collection)
            return
            if($string != '') then replace(replace($string, '\{', '{{'), '\}', '}}') else ' '
        case(element(xrx:css)) return
            let $external-css := $xrx-live-project-db-base-collection//xrx:id[.=$cssid]/parent::xrx:css/xrx:style/text()
            return
            $external-css
        default return ''
    return
    <xhtml:style id="{ $widgetid }">{ minify:css($css-strings) }</xhtml:style>
};

