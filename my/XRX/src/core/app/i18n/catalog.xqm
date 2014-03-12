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

module namespace catalog="http://www.monasterium.net/NS/catalog";

declare namespace i18n="http://www.monasterium.net/NS/i18n";

import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../xrx/conf.xqm";
import module namespace atom="http://www.w3.org/2005/Atom"
    at "../data/atom.xqm";
import module namespace xrx="http://www.monasterium.net/NS/xrx"
    at "../xrx/xrx.xqm";

declare variable $catalog:catalogs := conf:param('xrx-i18n-catalogs');

declare function catalog:update() {

    let $apps := $xrx:live-project-db-base-collection/xrx:app
    return
    <xrx:updated>
        <xrx:new>
            {
            for $app in $apps
            let $app-db-base-collection-path := util:collection-name($app)
            let $app-db-base-collection := collection($app-db-base-collection-path)
            let $appid := $app-db-base-collection/xrx:app/xrx:id/text()
            let $app-new-messages := catalog:new-messages($app-db-base-collection)
            let $catalog-name := catalog:name($appid)
            return
            <xrx:app path="{ $app-db-base-collection-path }">
                <xrx:new>{ catalog:update($catalog-name, $app-new-messages) }</xrx:new>
            </xrx:app>
            }
        </xrx:new>
        <xrx:nonactive>
            { 
            let $nonactive-messages := catalog:nonactive-messages()
            return
            catalog:mark-nonactive($nonactive-messages)
            }
        </xrx:nonactive>
    </xrx:updated>
};

declare function catalog:mark-nonactive($nonactive-messages as element()*) {

    let $xslt := 
    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
        xmlns:xrx="http://www.monasterium.net/NS/xrx" 
        version="1.0">
      <xsl:template match="xrx:i18n">
        <xsl:element name="xrx:i18n">
          <xsl:attribute name="activeflag">false</xsl:attribute>
          <xsl:copy-of select="*"/>
        </xsl:element>
      </xsl:template>
      <xsl:template match="@*|*" priority="-2">
        <xsl:copy>
          <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
      </xsl:template>
    </xsl:stylesheet>  
    for $message in $nonactive-messages
    let $message-key := xs:string($message/xrx:key/text())
    let $entries := $i18n:db-base-collection//xrx:key[.=$message-key]/ancestor::atom:entry
    return
        for $entry in $entries
        return
        if(exists($entries//xrx:i18n[@activeflag='false'])) then ()
        else
            let $feed := substring-after(util:collection-name($entry), conf:param('atom-db-base-uri'))
            let $entry-name := util:document-name($entry)
            let $entry := transform:transform($entry, $xslt, ())
            let $put := atom:PUT($feed, $entry-name, $entry)
            return
            <xrx:post>
              <xrx:feed>{ $feed }</xrx:feed>
              <xrx:entryname>{ $entry-name }</xrx:entryname>
              <xrx:entry>{ $entry }</xrx:entry>
            </xrx:post>    
};

declare function catalog:nonactive-messages() as element()* {
    
    let $first-lang := (xmldb:get-child-collections($i18n:db-base-collection-path))[1]
    let $first-path := concat($i18n:db-base-collection-path, $first-lang)
    let $messages := collection($first-path)//xrx:i18n
    return
    for $message in $messages
    let $key := $message/xrx:key/text()
    return
    if(not($xrx:live-project-db-base-collection//xrx:i18n[xrx:key=$key])) then $message
    else ()
};

declare function catalog:update($catalog-name as xs:string, $messages as element(xrx:i18n)*) {

    let $lang-keys := $i18n:languages/@key/string()
    return
    for $message in $messages
    let $message-key := string($message/xrx:key/text())
    return
        for $lang-key in $lang-keys
        let $feed := catalog:feed($lang-key, $catalog-name)
        let $entry-name := catalog:entry-name($message-key, $lang-key)
        let $new-entry := catalog:new-entry($lang-key, $message)
        let $post := atom:POST($feed, $entry-name, $new-entry)
        return
        <xrx:post>
          <xrx:feed>{ $feed }</xrx:feed>
          <xrx:entryname>{ $entry-name }</xrx:entryname>
          <xrx:entry>{ $post }</xrx:entry>
        </xrx:post>
};

declare function catalog:base-collection($lang-key as xs:string, $catalog-name as xs:string) {

    collection(catalog:base-collection-path($lang-key, $catalog-name))
};

declare function catalog:base-collection-path($lang-key as xs:string, $catalog-name as xs:string) as xs:string {

    concat(conf:param('xrx-i18n-db-base-uri'), $lang-key, '/app.', $catalog-name)
};

declare function catalog:feed($lang-key as xs:string, $catalog-name as xs:string) as xs:string {
    
    concat(conf:param('xrx-i18n-atom-base-uri'), $lang-key, '/app.', $catalog-name)
};

declare function catalog:entry-name($message-key as xs:string, $lang-key as xs:string) as xs:string {
    
    concat($message-key, '.', $lang-key, '.xml')
};

declare function catalog:new-entry($lang-key as xs:string, $message as element(xrx:i18n)) as element() {
    
    <atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
        <atom:id/>
        <atom:title/>
        <atom:published/>
        <atom:updated/>
        <atom:author>
            <atom:email/>
        </atom:author>
        <app:control xmlns:app="http://www.w3.org/2007/app">
            <app:draft>no</app:draft>
        </app:control>
        <atom:content type="application/xml" xml:lang="{ $lang-key }">{ $message }</atom:content>
    </atom:entry>    
};

declare function catalog:new-messages($app-db-base-collection) as element()* {

    let $new-messages :=
        for $message in $app-db-base-collection//xrx:i18n
        let $key := xs:string($message/xrx:key/text())
        return
        if($key = '' or not($key)) then ()
        else if($i18n:db-base-collection//xrx:key[.=$key]) then ()
        else catalog:new-message($message)
    return
    catalog:distinct-messages($new-messages)
};

declare function catalog:new-message($app-message as element(xrx:i18n)) as element() {

    element { name($app-message/self::xrx:i18n) } {
    
        $app-message/@*,
        $app-message/*,
        <xrx:text/>
    }
};

declare function catalog:distinct-messages($messages as element(xrx:i18n)*) as element()* {

    let $distinct-keys := distinct-values($messages/xrx:key/text())
    for $key in $distinct-keys
    return
    ($messages[xrx:key=$key])[1]
};

declare function catalog:name($objectid as xs:string) as xs:string {

    let $default-catalog-name := $catalog:catalogs//xrx:catalog[@default='true']/@name/string()
    let $catalog-name := $catalog:catalogs//xrx:record[.=$objectid]/parent::xrx:catalog/@name/string()
    return
    ($catalog-name, $default-catalog-name)[1]
};

declare function catalog:add-language($language as xs:string) {

    let $default-lang := conf:param('default-lang')
    let $base-collection-path := concat(conf:param('xrx-i18n-db-base-uri'), $default-lang)
    let $base-collection := collection($base-collection-path)
    let $catalog-exists := xs:boolean($language = xmldb:get-child-collections(conf:param('xrx-i18n-db-base-uri')))
    return
    if(not($catalog-exists)) then
        <update>
        {
            for $entry in $base-collection/atom:entry
            let $uri := concat(util:collection-name($entry), '/', util:document-name($entry))
            let $catalog-name := substring-after(tokenize($uri, '/')[6], 'app.')
            let $new-message := catalog:new-message(
                <xrx:i18n>
                  <xrx:key>{ $entry//xrx:i18n/xrx:key/text() }</xrx:key>
                  <xrx:default>{ $entry//xrx:i18n/xrx:default/text() }</xrx:default>
                </xrx:i18n>
            )
            let $new-entry := catalog:new-entry($language, $new-message)
            let $feed := catalog:feed($language, $catalog-name)
            let $entry-name := replace(util:document-name($entry), 
                concat('.', $default-lang, '.xml'), concat('.', $language, '.xml'))
            let $post := atom:POST($feed, $entry-name, $new-entry)
            return
            <entry uri="{ $uri }" catalog-name="{ $catalog-name }" feed="{ $feed }" entry-name="{ $entry-name }"/>
        }
        </update>
    else <catalogExists/>
};
