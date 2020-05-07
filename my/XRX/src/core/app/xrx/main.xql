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
along with VdU/VRET.  If not, see http://www.gnu.org/licenses/.

We expect VdU/VRET to be distributed in the future with a license more lenient towards the inclusion of components into other systems, once it leaves the active development stage.
:)

(: w3c namespaces :)
declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace xf="http://www.w3.org/2002/xforms";
declare namespace ev="http://www.w3.org/2001/xml-events";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace xs="http://www.w3.org/2001/XMLSchema";
(: xforms processor specific namespaces :)
declare namespace bf="http://betterform.sourceforge.net/xforms";
declare namespace bfc="http://betterform.sourceforge.net/xforms/controls";
(: database specific namespaces :)
declare namespace file="http://exist-db.org/xquery/file";
declare namespace exist="http://exist.sourceforge.net/NS/exist";
(: XRX specific namespaces :)
declare namespace constructor="http://www.monasterium.net/NS/constructor";

#DECLARE_XRX_NAMESPACES

import module namespace kwic="http://exist-db.org/xquery/kwic";
import module namespace excel="http://exist-db.org/xquery/excel";
import module namespace datetime="http://exist-db.org/xquery/datetime";
import module namespace json="http://www.json.org";


#IMPORT_XRX_MODULES

declare default collation "?lang=de-DE"; 
declare option exist:serialize "indent=no";

(:
    ##################
    #
    # Internal Variables
    #
    ##################
:)

(: get the request data stream :)
declare variable $data :=
    request:get-data();

(:
    ##################
    #
    # Get cached resources
    #
    ##################
:)
declare function local:etag($path-to-binary-resource as xs:string, $last-modified as xs:dateTime, $domain-tag as xs:string) as xs:string {

    concat( $domain-tag, 
            '-', 
            util:document-id($path-to-binary-resource),
            '-', 
            translate(substring($last-modified, 1, 19), ':-T', '')
    )
};

declare function local:etag-from-uri($path-to-binary-resource as xs:string, $domain-tag as xs:string) as xs:string {

    local:etag( $path-to-binary-resource,
                xmldb:last-modified(util:collection-name($path-to-binary-resource), util:document-name($path-to-binary-resource)), 
                $domain-tag
    )
};
 
declare function local:cached-resource( 
    $original-path as xs:string?,
    $path-to-binary-resource as xs:string,
    $expires-after as xs:dayTimeDuration?,
    $must-revalidate as xs:boolean,
    $do-not-cache as xs:string,
    $domain as xs:string?,
    $content
) {

    let $collection := util:collection-name($path-to-binary-resource)
    let $file := util:document-name($path-to-binary-resource)
    return
    if(string-length($path-to-binary-resource) = 0) then 
    (
        response:set-status-code(404),
        concat($original-path, ' ( ', $path-to-binary-resource, ' ) not found.')        
    ) 
    else 
    (
        let $last-modified := xmldb:last-modified($collection, $file)
        let $etag := local:etag($path-to-binary-resource, $last-modified, $domain)
        let $if-modified-since := request:get-header('If-Modified-Since')
        let $expire-after := if(empty($expires-after)) then xs:dayTimeDuration('P365D') else $expires-after
        let $pragma:= response:set-header('Pragma', 'o')
        return
        if(not($do-not-cache = 'true') = true() and (
                (request:get-header('If-None-Match') = $etag ) = true() and
                ((string-length($if-modified-since) > 0) = true() and ($if-modified-since >= xs:string($last-modified)) = true()) = true()
            )
        ) 
        then
        (
            response:set-status-code(304),
            response:set-header("Cache-Control", concat('public, max-age=', $expire-after div xs:dayTimeDuration('PT1S'))),
            304
        )
        else 
        (
            let $max-age := $expire-after div xs:dayTimeDuration('PT1S')
            let $headers := 
            (
                response:set-header('ETag', $etag),
                response:set-header('Last-Modified', xs:string($last-modified)),
                response:set-header('Expires', xs:string(dateTime(current-date(), util:system-time()) + $expire-after)),
                if($do-not-cache = 'true') then 
                (
                    response:set-header('Cache-Control', 'no-cache, no-store, max-age=0, must-revalidate'),
                    response:set-header('X-Content-Type-Options', 'nosniff')
                )
                else
                    response:set-header('Cache-Control', concat('public, max-age=', $max-age, if($must-revalidate) then ', must-revalidate' else ''))
            )
            return
            $content
        )
     )                                       
};

(:
    ##################
    #
    # Helper Functions
    #
    ##################
:)
declare function local:eval($xrx as element()) {

    let $serialize := serialize($xrx, ())
    return
    if($serialize != '') then util:eval($serialize, false())
    else()
};

(:
    ##################
    #
    # Main Functions
    #
    ##################
:)
(: main function to process atom requests :)
declare function local:mode-atom() {
    
    let $atom-action := $xrx:tokenized-uri[2]
    
    return
    
    if($atom-action = 'GET') then atom:GET()
    else if($atom-action = 'PUT') then atom:PUT($data)
    else if($atom-action = 'POST') then atom:POST($data)
    else if($atom-action = 'DELETE') then atom:DELETE()
    else if($atom-action = 'CONTRIBUTE') then atom:CONTRIBUTE($data)
    else()
};

(: main function to process css requests :)
declare function local:mode-css() {
    
    let $atomid := request:get-parameter('atomid', '')
    let $compiled-css := collection($xrx:live-project-db-base-collection-path)/xhtml:style[@id=$atomid]
    let $cached-resource := 
        local:cached-resource(
            request:get-url(),
            concat(util:collection-name($compiled-css), '/', util:document-name($compiled-css)),
            xs:dayTimeDuration('P30D'),
            true(),
            request:get-parameter("doNotCache", ''),
            request:get-server-name(),
            $compiled-css
        )
    return
    typeswitch($cached-resource)
    case (xs:integer) return ()
    default return local:eval($cached-resource)
};

declare function local:mode-javascript() {

    let $atomid := request:get-parameter('atomid', '')
    let $compiled-javascript := collection($xrx:live-project-db-base-collection-path)/xhtml:script[@id=$atomid]
    let $cached-resource := 
        local:cached-resource(
            request:get-url(),
            concat(util:collection-name($compiled-javascript), '/', util:document-name($compiled-javascript)),
            xs:dayTimeDuration('P30D'),
            true(),
            request:get-parameter("doNotCache", ''),
            request:get-server-name(),
            $compiled-javascript
        )
    return
    typeswitch($cached-resource)
    case (xs:integer) return ()
    default return xs:string($cached-resource)
};

(: main function to process htdocs :)
declare function local:mode-htdoc() {

    let $mainwidgetid := widget:mainwidgetid($xrx:mainwidget/xrx:id/text())
    let $compiled-htdocwidget := collection($xrx:live-project-db-base-collection-path)/xhtml:html[@id=$mainwidgetid]
    let $xforms := request:set-attribute('betterform.filter.ignoreResponseBody', 'true')
    return
    local:eval($compiled-htdocwidget)

};

(: main function to process embedded widgets :)
declare function local:mode-embeddedwidget() {

    let $embeddedwidgetid := widget:embeddedwidgetid($xrx:embeddedwidget/xrx:id/text())
    let $compiled-embeddedwidget := collection($xrx:live-project-db-base-collection-path)/xhtml:div[@id=$embeddedwidgetid]
    let $xforms := 
        if($xrx:xformsflag) then 
            ()
        else
            request:set-attribute('betterform.filter.ignoreResponseBody', 'true')
    return
    local:eval($compiled-embeddedwidget)
};

(: main function to process main widgets :)
declare function local:mode-mainwidget() {

    let $mainwidgetid := widget:mainwidgetid($xrx:mainwidget/xrx:id/text())
    let $compiled-mainwidget := collection($xrx:live-project-db-base-collection-path)/xhtml:html[@id=$mainwidgetid]
    let $xforms := 
        if($xrx:xformsflag) then 
            ()
        else
            request:set-attribute('betterform.filter.ignoreResponseBody', 'true')
    let $xsl := 
        <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            xmlns:xf="http://www.w3.org/2002/xforms"
            xmlns:xhtml="http://www.w3.org/1999/xhtml" 
            version="1.0"
            xmlns="http://www.w3.org/1999/xhtml">
            <xsl:template match="//xf:submission/*[last()]">
              <xsl:copy-of select="."/>
              <xf:header>
                <xf:name>userid</xf:name>
                <xf:value>{ $xrx:user-id }</xf:value>
              </xf:header>
            </xsl:template>
            <xsl:template match="//xf:submission[not(./*)]">
              <xf:submission>
                <xsl:copy-of select="@*"/>
                <xf:header>
                    <xf:name>userid</xf:name>
                    <xf:value>{ $xrx:user-id }</xf:value>
                </xf:header>
              </xf:submission>
            </xsl:template>
            <xsl:template match="@*|*" priority="-2">
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()" />
                </xsl:copy>
            </xsl:template>
        </xsl:stylesheet>
    return
    if(not($xrx:xformsflag)) then local:eval($compiled-mainwidget)
    else local:eval(transform:transform($compiled-mainwidget, $xsl, ()))
};

(: main function to process services :)
declare function local:mode-service() {

    let $serviceid := $xrx:service/xrx:id/text()
    let $compiled-service := collection($xrx:live-project-db-base-collection-path)/xrx:service[@id=$serviceid]
    return
    if($xrx:translateflag) then
        i18n:translate-xml(local:eval($compiled-service)/xrx:body/node())
    else
        local:eval($compiled-service)/xrx:body/node()
};

declare function local:mode-resource() {

    let $resourceid := xs:string(request:get-parameter('atomid', ''))
    let $uri := resource:uri($resourceid, ($xrx:live-project-db-base-collection, $xrx:resource-db-base-collection))
    let $mime-type := resource:mime-type($uri)
    let $resource := resource:document($uri)
    let $name := resource:name($resourceid, ($xrx:live-project-db-base-collection, $xrx:resource-db-base-collection))
    let $serialize := util:declare-option('exist:serialize', concat('media-type=', $mime-type))
    let $cached-resource :=         
        local:cached-resource(
            request:get-url(),
            $uri,
            xs:dayTimeDuration('P30D'),
            true(),
            request:get-parameter("doNotCache", ''),
            request:get-server-name(),
            $resource
        )
    
    return
    typeswitch($cached-resource)
    case (xs:integer) return ()
    default return     
        if(util:binary-doc-available($uri)) then
            response:stream-binary(
                $cached-resource,
                $mime-type,
                $name
            )
        else $cached-resource
};

(:
    ##################
    #
    # Function Calls
    #
    ##################
:)
(:
    Function calls depending on the 
    XRX mode. This XQuery script (xrx.xql)
    only accepts incoming URIs of the
    following form
    
    /atom/?atomid=%SOME_ATOM_ID%
    /css/?atomid=%SOME_ATOM_ID%
    /htdoc/?atomid=%SOME_ATOM_ID%
    /embeddedwidget/?atomid=%SOME_ATOM_ID%
    /mainwidget/?atomid=%SOME_ATOM_ID%
    
    where %SOME_ATOM_ID% should follow the rules
    described in the Atom Syndication Format
    (http://www.ietf.org/rfc/rfc4287.txt)
    
    e.g.:
    tag:www.monasterium.net,2011:/mom/widget/tei2pdf 
:)
declare function local:main() {

    let $timeout := util:declare-option('exist:timeout', conf:param("timeout-in-ms") )
    let $mode := 
    (: mode atom :)
    if($xrx:mode = 'atom') then
    
        (
            util:declare-option('exist:serialize', 'method=xml media-type=application/xml'),
            local:mode-atom()
        )

    (: mode css :)
    else if($xrx:mode = 'css') then
    
        (
            util:declare-option('exist:serialize', 'method=text media-type=text/css'),
            local:mode-css()
        )

    (: mode css :)
    else if($xrx:mode = 'javascript') then
    
        (
            util:declare-option('exist:serialize', 'method=text media-type=text/javascript'),
            local:mode-javascript()
        )
    
    (: mode htdoc :)
    else if($xrx:mode = 'htdoc') then
    
        (
            util:declare-option('exist:serialize', 'method=xhtml media-type=text/html indent=no'),
            local:mode-htdoc()
        )
    
    (: mode service :)
    else if($xrx:mode = 'service') then
    
        (
            util:declare-option('exist:serialize', $xrx:serializeas),
            local:mode-service()
        )
    
    (: mode embedded widget :)    
    else if($xrx:mode = 'embeddedwidget') then
    
        (
            util:declare-option('exist:serialize', 'method=xml media-type=application/xml'),
            local:mode-embeddedwidget()
        )
    
    (: mode main widget (XForms enabled or disabled) :)
    else if($xrx:mode = 'mainwidget') then

        if($xrx:xformsflag) then
        (
            util:declare-option('exist:serialize', 'method=xhtml media-type=text/html omit-xml-declaration=no indent=no'),
            local:mode-mainwidget()
        )
        else
        (
            util:declare-option('exist:serialize', 'method=html5 media-type=text/html indent=no'),
            local:mode-mainwidget()        
        )

    (: mode resource :)
    else if($xrx:mode = 'resource') then

        local:mode-resource()
            
    else ()
    return $mode
};

(: 
    we resolve the incoming URI and
    call the xrx mode we found in the
    project's URI resolver
:)
local:main()
