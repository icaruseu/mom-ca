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

module namespace mycharter="http://www.monasterium.net/NS/mycharter";

declare namespace cei="http://www.monasterium.net/NS/cei";

import module namespace upd="http://www.monasterium.net/NS/upd"
    at "../xrx/upd.xqm";
import module namespace xrx="http://www.monasterium.net/NS/xrx"
    at "../xrx/xrx.xqm";
import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../xrx/conf.xqm";
import module namespace atom="http://www.w3.org/2005/Atom"
    at "../data/atom.xqm";
import module namespace charter="http://www.monasterium.net/NS/charter"
    at "../charter/charter.xqm";


declare function mycharter:is-shared-with($entry as element(atom:entry), $userid as xs:string) as xs:boolean {

    let $collection-name-charter := util:collection-name($entry)
    let $document-name-charter := util:document-name($entry)
    let $collection-name-charter-shared := replace($collection-name-charter, 'charter', 'charter.share')
    let $document-name-charter-shared := replace($document-name-charter, 'charter', 'charter.share')
    let $document-share := doc(concat($collection-name-charter-shared, '/', $document-name-charter-shared))
    return
    count($document-share//xrx:userid[.=$userid]) gt 0
};




declare function mycharter:shared-users($base-collection-path as xs:string, $entryname as xs:string) {
    doc(concat($base-collection-path, $entryname))//xrx:userid[not(@type="owner")]/text()
};


declare function mycharter:share($base-collection-path as xs:string, $entryname as xs:string, $userid as xs:string) {
    

    let $document := doc(concat($base-collection-path, $entryname))
    let $feed := substring-after($base-collection-path, conf:param('atom-db-base-uri'))
    
    let $document-exists := exists($document/*)
    let $user-exists := exists($document//xrx:userid[.=$userid])
    
    let $update := 

        if(not(xmldb:exists-user($userid))) then
            false()
            
        else if(not($document-exists)) then
            let $data := 
                <xrx:share>
                  <xrx:userid type="owner">{$xrx:user-id}</xrx:userid>
                  <xrx:userid>{ $userid }</xrx:userid>
                </xrx:share>
            let $post := 
                atom:POST($feed, $entryname, $data)
            return
            true()

        else if($user-exists) then
            true()

        else
            let $data := upd:insert-into($document/xrx:share, 
                <xrx:userid>{ $userid }</xrx:userid>)
            let $post := 
                atom:POST($feed, $entryname, $data)
            return
            true()

    return
    $update
};



declare function mycharter:toggle-just-linked($entry as element(atom:entry)) as element() {

    let $is-just-linked := exists($entry//atom:content/@src)
    let $link := $entry/atom:link[@rel='versionOf']/@ref/string()
    return
    if($is-just-linked) then
        upd:delete($entry//atom:content/@src)
    else
        upd:insert-attributes($entry//atom:content, attribute src { $link })
};



declare function mycharter:get-charter-list($metadata-charter-collection) {
    
    for $entry in $metadata-charter-collection/atom:entry
    let $linked-charter-atomid := $entry//atom:content/@src/string()
    let $cei:text := 
        if($linked-charter-atomid != '') then
            charter:public-entry($linked-charter-atomid)//cei:text
        else
            $entry//cei:text
    order by xs:integer(($cei:text//cei:issued/cei:date/@value|$cei:text//cei:issued/cei:dateRange/@from)[1])
    return
    $entry   
};


declare function mycharter:transformCharter($charter, $params){

let $xslt :=        
    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
        xmlns:ead="urn:isbn:1-931666-22-9"
        xmlns:atom="http://www.w3.org/2005/Atom"
        xmlns:cei="http://www.monasterium.net/NS/cei"
        version="2.0">
        <xsl:param name="atom_link_url"/>
        <xsl:param name="bibl_string"/>
        <xsl:param name="new_atom_id"/>
        <xsl:param name="new_url_string"/>
        <xsl:template match="@* | node()">
            <xsl:copy>
                <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
        </xsl:template>
        <xsl:template match="@|node()" mode="copy">
            <xsl:copy>
                <xsl:apply-templates select="@|node()" mode="copy"/>
            </xsl:copy>
        </xsl:template>
        <xsl:template match="atom:id/text()">
            <xsl:value-of select="$new_atom_id"/>       
        </xsl:template>
        <xsl:template match="atom:content">
            <atom:link rel="versionOf">
                <xsl:attribute name="ref"><xsl:value-of select="$atom_link_url"/></xsl:attribute>
            </atom:link>
            <atom:content type="application/xml">
                <xsl:apply-templates/>
            </atom:content>
        </xsl:template>
        <xsl:template match="cei:sourceDescRegest/cei:bibl">
            <cei:bibl>
                <xsl:value-of select="concat(. ,' ', $bibl_string)"/>
            </cei:bibl>
        </xsl:template>
        <xsl:template match="cei:sourceDescVolltext/cei:bibl">
            <cei:bibl>
                <xsl:value-of select="concat(. ,' ', $bibl_string)"/>
            </cei:bibl>
        </xsl:template>
        <xsl:template match="@url[parent::cei:graphic]">
        <xsl:if test="not(contains(., '/'))">
            <xsl:attribute name="url">
                <xsl:value-of select="concat($new_url_string, '/' ,. )"/>
            </xsl:attribute>
            </xsl:if>
       </xsl:template>
    </xsl:stylesheet>

let $newXml := transform:transform($charter, $xslt, $params)
return $newXml
};
