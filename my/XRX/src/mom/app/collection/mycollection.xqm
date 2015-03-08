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

module namespace mycollection="http://www.monasterium.net/NS/mycollection";

declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace xrx="http://www.monasterium.net/NS/xrx";
declare namespace cei="http://www.monasterium.net/NS/cei";

import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../xrx/conf.xqm";
import module namespace user="http://www.monasterium.net/NS/user"
    at "../user/user.xqm";
import module namespace template="http://www.monasterium.net/NS/template"
    at "../xrx/template.xqm";
import module namespace metadata="http://www.monasterium.net/NS/metadata"
    at "../metadata/metadata.xqm";

declare function mycollection:linked-fond-charter-base-collection($collection-base-collection) {

    let $linked-fonds-atomid := $collection-base-collection//cei:text[@type='fond']/@id/string()
    let $linked-fonds-fondid := 
        for $id in $linked-fonds-atomid 
        return 
        tokenize($id, '/')[last()]
    let $linked-fonds-archiveid :=
        for $id in $linked-fonds-atomid 
        return tokenize($id, '/')[last() - 1]
    let $linked-fond-charter-base-collection :=
        for $id at $pos in $linked-fonds-atomid 
        return metadata:base-collection('charter', ($linked-fonds-archiveid[$pos], $linked-fonds-fondid[$pos]), 'public')
    return
    $linked-fond-charter-base-collection
};

declare function mycollection:uuid($base-collection) as xs:string {

    let $uuid := util:uuid()
    return
    if(exists($base-collection//atom:id[ends-with(., $uuid)])) then mycollection:uuid($base-collection)
    else $uuid
};

declare function mycollection:is-public($entry as element(atom:entry)) as xs:boolean {

    xs:string($entry/xrx:sharing/xrx:visibility/text()) = 'public'
};

declare function mycollection:owner($entry as element(atom:entry)) as xs:string* {

    let $collection-name := util:collection-name($entry)
    let $userid := xmldb:decode(substring-before(substring-after($collection-name, 'xrx.user/'), '/'))
    return
    $userid
};

declare function mycollection:key($entry as element(atom:entry)) as xs:string* {

    let $atomid := $entry/atom:id/text()
    let $tokens := tokenize($atomid, '/')
    let $key := $tokens[3]
    return
    $key
};

declare function mycollection:link($entry as element(atom:entry)) as xs:string* {

    let $key := mycollection:key($entry)
    return
    concat(conf:param('request-root'), $key, '/mycollection')
};

declare function mycollection:charter-new-empty($atom-id as xs:string, $charter-id as xs:string, $charter-name) {

    let $template := template:get('tag:www.monasterium.net,2011:/mom/template/mycollection-charter', false())
    let $xslt := 
    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xrx="http://www.monasterium.net/NS/xrx"
        xmlns:cei="http://www.monasterium.net/NS/cei"
        xmlns:atom="http://www.w3.org/2005/Atom" version="1.0">
      <xsl:template match="//atom:id">
        <xsl:element name="atom:id">
          <xsl:text>{ $atom-id }</xsl:text>
        </xsl:element>
      </xsl:template>
      <xsl:template match="//cei:body/cei:idno">
        <xsl:element name="cei:idno">
          <xsl:attribute name="id">{ $charter-id }</xsl:attribute>
          <xsl:text>{ $charter-name }</xsl:text>
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

declare function mycollection:charter-new-version($atom-id as xs:string, $charter-id as xs:string, $charter-name as xs:string, $linked-charter-atomid as xs:string) {

    let $template := template:get('tag:www.monasterium.net,2011:/mom/template/mycollection-charter', false())
    let $xslt := 
    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xrx="http://www.monasterium.net/NS/xrx"
        xmlns:cei="http://www.monasterium.net/NS/cei"
        xmlns:atom="http://www.w3.org/2005/Atom" 
        version="1.0">
      <xsl:template match="//atom:id">
        <xsl:element name="atom:id">
          <xsl:text>{ $atom-id }</xsl:text>
        </xsl:element>
      </xsl:template>
      <xsl:template match="//atom:content">
        <atom:link rel="versionOf" ref="{ $linked-charter-atomid }"/>
        <xsl:element name="atom:content">
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:template>
      <xsl:template match="//cei:body/cei:idno">
        <xsl:element name="cei:idno">
          <xsl:attribute name="id">{ $charter-id }</xsl:attribute>
          <xsl:text>{ $charter-name }</xsl:text>
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

