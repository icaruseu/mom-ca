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

module namespace pdf="http://www.monasterium.net/NS/pdf";

import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../xrx/conf.xqm";
import module namespace i18n="http://www.monasterium.net/NS/i18n"
    at "../xrx/i18n.xqm";
    
declare namespace fo="http://www.w3.org/1999/XSL/Format";
declare namespace xslfo="http://exist-db.org/xquery/xslfo";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace httpclient="http://exist-db.org/xquery/httpclient";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";

import module "http://exist-db.org/xquery/util";
    
declare option exist:serialize "media-type=application/pdf";

declare function pdf:render($xml as element(), $xsl as element(xsl:stylesheet), $params as element(), $fopConfig as element(), $lang as xs:string, $fileName as xs:string)
{
(: transform the content of the xml-document:)
let $xml-transformed := transform:transform($xml, $xsl, $params)
(: translate it to the current language:) 
let $xml-translated := i18n:translate-xml($xml-transformed)
(: render the pdf- file :)
let $pdf := xslfo:render($xml-translated, "application/pdf", (), $fopConfig)
return
(: return the completed PDF-file :)
response:stream-binary($pdf, "application/pdf", $fileName)
};