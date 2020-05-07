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

module namespace xrx="http://www.monasterium.net/NS/xrx";

declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../xrx/conf.xqm";
import module namespace resolver="http://www.monasterium.net/NS/resolver"
    at "../xrx/resolver.xqm";
import module namespace htdoc="http://www.monasterium.net/NS/htdoc"
    at "../htdoc/htdoc.xqm";
import module namespace i18n="http://www.monasterium.net/NS/i18n"
    at "../i18n/i18n.xqm";
import module namespace catalog="http://www.monasterium.net/NS/catalog"
    at "../i18n/catalog.xqm";


(:
    ##################
    #
    # Platform Variables
    #
    ##################
:)
(: ID of the platform = first URI token :)
declare variable $xrx:platform-id := 
    substring-before(substring-after(request:get-uri(), '/'), '/');
    
(: XRX++ live collection :)
declare variable $xrx:live-db-base-collection-path := '/db/XRX.live';
declare variable $xrx:live-project-db-base-collection-path := concat($xrx:live-db-base-collection-path, '/', $xrx:platform-id);
declare variable $xrx:live-project-db-base-collection := collection($xrx:live-project-db-base-collection-path);

(: XRX++ src collection :)
declare variable $xrx:src-db-base-collection-path := '/db/XRX.src';
declare variable $xrx:src-db-base-collection :=
    collection($xrx:src-db-base-collection-path);

(: XRX++ resource collection :)
declare variable $xrx:resource-db-base-collection-path := '/db/XRX.res';
declare variable $xrx:resource-db-base-collection :=
    collection($xrx:resource-db-base-collection-path);

(: for backward compatibility :)
declare variable $xrx:db-base-collection :=
    collection($xrx:live-db-base-collection-path);
    
(:
    ##################
    #
    # Pointers for the current
    # xrx object(s)
    #
    ##################    
    these variables are visible for
    all widgets, services, portals ... 
    
    inside a <xrx:widget/> $xrx:mainwidget 
    can be used as a self-reference
    
    inside a <xrx:service/> $xrx:service 
    can be used as a self-reference
    
    ...
:)
(: the resolver :)
declare variable $xrx:resolver :=
    resolver:resolve($xrx:live-project-db-base-collection);
(: the mode defined in the resolver :)
declare variable $xrx:mode := 
    $xrx:resolver/xrx:mode/text();
(: the xrx mainwidget :)
declare variable $xrx:mainwidget :=
    xrx:mainwidget();
(: xforms on or off? :)
declare variable $xrx:xformsflag :=
    xrx:xformsflag();
declare variable $xrx:embeddedwidget :=
    xrx:embeddedwidget();
(: the xrx service :)
declare variable $xrx:service := 
    xrx:service();
declare variable $xrx:htdoc := 
    xrx:htdoc();
declare variable $xrx:translateflag :=
    xrx:translateflag();
declare variable $xrx:serializeas := 
    xrx:serializeas();

(: 
    so, we also have a this 
    pointer now for services and 
    main widgets
:)
declare variable $xrx:this :=
    (
        $xrx:mainwidget,
        $xrx:service
    )[1];




(:
    ##################
    #
    # Request Context 
    # Parameters
    #
    ##################    
    these variables are visible for
    all widgets, services, portals ... 
:)
(: calling protocoll version :)
declare variable $xrx:protocol := substring-before(request:get-url(), "://");
(: the server port :)
declare variable $xrx:port := request:get-server-port();
(: the full server name, with or without port :)
declare variable $xrx:servername := substring-before(substring-after(request:get-url(), concat($xrx:protocol, '://') ), '/');
(: sometimes it is helpful to have the complete URL :)
declare variable $xrx:http-request-root := concat($xrx:protocol, '://', $xrx:servername, concat('/', $xrx:platform-id, '/'));
(: 
    URI path relative to the request root
    e.g.: '../../../' 
:)
declare variable $xrx:request-relative-path :=
    let $tokens := subsequence(tokenize(request:get-uri(), '/'), 4)
    return
    string-join(
        for $token in $tokens
        return
        '../'
        ,
        ''
    );
declare variable $xrx:localhost-request-base-url :=
    concat($xrx:protocol, '://localhost:', conf:param('jetty-port'), conf:param('request-root'));
declare variable $xrx:jetty-request-base-url := if(contains(conf:param('jetty-servername'), "monasterium")) then
    concat($xrx:protocol, '://', conf:param('jetty-servername'), conf:param('request-root')) else
    concat($xrx:protocol, '://', conf:param('jetty-servername'), ":", conf:param('jetty-port'), conf:param('request-root')) ; 
declare variable $xrx:http-icon-root := concat($xrx:protocol, '://', request:get-server-name(), $xrx:port, concat('/', $xrx:platform-id, '/'), 'icon/');    
(: tokenize each incoming URI :)
declare variable $xrx:_teed-help := 
    tokenize(substring-after(request:get-uri(), concat('/', $xrx:platform-id, '/')), '/');
(: decode and encode it again to have it really consistent :)
declare variable $xrx:tokenized-uri :=
    for $tok in $xrx:_teed-help
    return
    xmldb:encode(xmldb:decode($tok));


(:
    ##################
    #
    # Filesystem Context 
    # Parameters
    #
    ##################    
    these variables are visible for
    all widgets, services, portals ... 
:)

declare variable $xrx:data-home := 
    concat(system:get-exist-home(), '/../../', $xrx:platform-id, '.eXist-A-data');
declare variable $xrx:binary-data-home := 
    concat($xrx:data-home, '/fs');

(:
    ##################
    #
    # Session Parameters
    #
    ##################
    
    these variables are visible for
    all widgets, services, portals ... 
:)
(: languages configured for this platform :)
declare variable $xrx:configured-languages :=
    conf:param('languages');
    
(: the preferred language of the browser :)
declare variable $xrx:client-lang-key := 
    if(contains(request:get-header('Accept-Language'), '-')) then
    	substring-before(request:get-header('Accept-Language'), '-')
    else 
    	(:Ajax-calls with IE9 have Accept-Language: de :)
    	request:get-header('Accept-Language');
    
(: only for internal usage :)
declare variable $xrx:_platform-lang-key :=
    $xrx:configured-languages/xrx:lang[@old=$xrx:client-lang-key]/@key/string();


(: the ID of the current user :)
declare variable $xrx:user-id := if(request:get-header('userid') != '') then xmldb:decode(request:get-header('userid')[1]) else sm:id()//sm:username/text();
(: the XML description of the current user :)
declare variable $xrx:user-xml := 
    doc(concat(conf:param('xrx-user-db-base-uri'), xmldb:encode($xrx:user-id), '.xml'))/xrx:user;
(: only for internal usage :)
declare variable $xrx:lang-as-string := 
    xs:string(session:get-attribute('lang'));
(: the current language as xs:string :)

declare variable $xrx:session-id := 
    xs:string(session:get-id());


declare variable $xrx:lang := 
    if($xrx:lang-as-string != '') then $xrx:lang-as-string
    
    else if($xrx:_platform-lang-key != '') then $xrx:_platform-lang-key
    
    else conf:param('default-lang');
(: set the current language as session attribute :)

declare variable $xrx:_create-session := 
    if(not(session:exists())) then
    (
        session:create(),
        $xrx:lang
    )
    else();
(: only for internal usage :)
declare variable $xrx:_actual-i18n-catalog-db-collection-path :=
    concat(conf:param('xrx-i18n-db-base-uri')[1], $xrx:lang[1]);
(: the actual i18n catalog db base uri :)
declare variable $xrx:i18n-catalog :=
    collection($xrx:_actual-i18n-catalog-db-collection-path);




(:
    ##################
    #
    # Helper Functions
    #
    ##################
:)

declare function xrx:messages($widget as element(xrx:widget)) {

    let $catalogs := $widget/xrx:init/xrx:client/xrx:messages/xrx:catalog
    let $catalog-names := $catalogs/text()
    return
    (
        $widget/xrx:init/xrx:client/xrx:messages/xrx:i18n,
        for $catalog-name in $catalog-names return catalog:base-collection($xrx:lang, $catalog-name)//xrx:i18n
    )
};

declare function xrx:eval($xrx as element()) {

    let $serialize := serialize($xrx, ())
    return
    if($serialize != '') then util:eval($serialize, false())
    else()
};

(: function to get the mainwidget in a optimized way :)
declare function xrx:mainwidget() as element()* {

    if($xrx:mode = 'mainwidget') then 
    
        let $atomid := $xrx:resolver/xrx:atomid/text()
        return
        collection($xrx:live-project-db-base-collection-path)//xrx:id[.=$atomid]/parent::xrx:widget
    
    else if($xrx:mode = 'htdoc') then

        (: ID of the htdoc main widget :)
        let $htdocwidget-id := 
            conf:param('xrx-htdoc-main-widget')    
        (: the htdoc main widget :)
        let $htdoc-widget := 
            $xrx:db-base-collection//xrx:id[.=$htdocwidget-id]/parent::xrx:widget
        return
        $htdoc-widget
          
    else()
};

declare function xrx:embeddedwidget() as element()* {
    
    if($xrx:mode = 'embeddedwidget') then
    
        let $atomid := $xrx:resolver/xrx:atomid/text()
        return
        collection($xrx:live-project-db-base-collection-path)//xrx:id[.=$atomid]/parent::xrx:widget
        
    else()
};

(: 
    function returns the xforms flag as xs:boolean
    xforms flag 'true' = xforms 'on'
    xforms flag 'false' = xforms 'off' 
:)
declare function xrx:xformsflag() as xs:boolean {

    if($xrx:mode = 'mainwidget') then
    
        (: processor init defined by widget :)
        let $flag := $xrx:mainwidget/xrx:init/xrx:processor/xrx:xformsflag/text()
        return
        if(($flag = 'true' and sm:id()//sm:username/text() != 'guest') or matches($xrx:tokenized-uri[last()], '(registration|request-password|iipmooviewer)')) then true()
        else false()
    
    else false()
};

(: function to get the service in a optimized way :)
declare function xrx:service() as element()* {
  
    if($xrx:mode = 'service') then
        
        (: ID of the service :)
        let $atomid := $xrx:resolver/xrx:atomid/text()
        return
        collection($xrx:live-project-db-base-collection-path)//xrx:id[.=$atomid]/parent::xrx:service
        
    else()
};

declare function xrx:htdoc() as element()* {

    if($xrx:mode = 'htdoc') then
        
        (: ID of the static htdoc :)
        let $htdoc-id := $xrx:resolver/xrx:atomid/text()
        (: the htdoc entry :)
        let $htdoc-entry := htdoc:get($htdoc-id)
        (: browser title :)
        return
        $htdoc-entry
        
    else()    
};

declare function xrx:translateflag() as xs:boolean {

    if($xrx:mode = 'service') then
    
        let $flag := $xrx:service/xrx:init/xrx:processor/xrx:translateflag/text()
        return
        if($flag = 'true') then true()
        else if($flag = 'false') then false()
        else false()
        
    else false()
};

declare function xrx:serializeas() as xs:string {

    if($xrx:mode = 'service') then
    
        let $option := $xrx:service/xrx:init/xrx:processor/xrx:serializeas/text()
        return
        if(exists($option)) then xs:string($option)
        else 'method=xml media-type=application/xml indent=no'
        
    else ''
};

(: 
    get the atom ID of the xrx objects 
    which are not controlled by the resolver,
    e.g. services or css resources
:)
declare function xrx:object-id() as xs:string {

    request:get-parameter('atomid', '')
};

declare function xrx:request-query-string($param-name as xs:string*, $param-value as xs:string*) {
    let $query-string := 
        string-join(
        (
            for $name in request:get-parameter-names()
            return
            if($name != $param-name and not(starts-with($name, '_'))) then
                concat(
                    $name,
                    '=',
                    request:get-parameter($name, '')
                )
            else(),
            concat(
                $param-name,
                '=',
                $param-value
            )
        )
            ,'&amp;'
        )
    return
    concat(
        '?', 
        $query-string
    )
};

