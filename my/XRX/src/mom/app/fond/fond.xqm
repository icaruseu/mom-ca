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

module namespace fond="http://www.monasterium.net/NS/fond";

declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace eag="http://www.archivgut-online.de/eag";

import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../xrx/conf.xqm";
import module namespace metadata="http://www.monasterium.net/NS/metadata"
    at "../metadata/metadata.xqm";

declare function fond:new($template as element(atom:entry), $atom-id as xs:string, $fond-id as xs:string) as element() {

    let $xslt :=
    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
        xmlns:ead="urn:isbn:1-931666-22-9"
        xmlns:atom="http://www.w3.org/2005/Atom"
        version="1.0">
      <xsl:template match="//atom:id">
        <xsl:element name="atom:id">{ $atom-id }</xsl:element>
      </xsl:template>
      <xsl:template match="//ead:c[@level='fonds']/ead:did/ead:unitid">
        <xsl:element name="ead:unitid">
          <xsl:attribute name="identifier">{ xmldb:encode($fond-id) }</xsl:attribute>
          <xsl:text>{ $fond-id }</xsl:text>
        </xsl:element>
      </xsl:template>
      <xsl:template match="@*|*" priority="-2">
        <xsl:copy>
          <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
      </xsl:template>
    </xsl:stylesheet>
    
    return
    
    transform:transform($template, $xslt, ())
};

declare function fond:key($entry as element(atom:entry)) as xs:string {
    
    tokenize($entry//atom:id/text(), '/')[last()]
};

declare function fond:permalink($entry as element(atom:entry)) as xs:string {

    let $archiveid := fond:archive-base-collection($entry)//eag:repositorid/text()
    return
    concat(conf:param('request-root'), $archiveid, '/', fond:key($entry), '/fond')
};

declare function fond:archive-base-collection($entry as element(atom:entry)) {

    let $fond-atomid := $entry//atom:id/text()
    let $archive-key := tokenize($fond-atomid, '/')[last() - 1]
    return
    metadata:base-collection('archive', $archive-key, 'public')
};

