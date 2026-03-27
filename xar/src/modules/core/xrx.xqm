xquery version "3.1";

(:~
 : Slimmed-down XRX context module for MOM-CA .xar package.
 : Provides session/request variables used throughout the codebase.
 : Routing/resolver logic is handled by controller.xql instead.
 :)

module namespace xrx = "http://www.monasterium.net/NS/xrx";

declare namespace xmldb = "http://exist-db.org/xquery/xmldb";

import module namespace conf = "http://www.monasterium.net/NS/conf"
    at "conf.xqm";

(: --- User session --- :)
declare variable $xrx:user-id :=
    let $session-user := xmldb:get-current-user()
    return
        if ($session-user = 'guest') then ''
        else $session-user;

declare variable $xrx:user-xml :=
    if ($xrx:user-id != '') then
        let $path := conf:param('xrx-user-db-base-uri') || $xrx:user-id || '/' || $xrx:user-id || '.xml'
        return
            if (doc-available($path)) then doc($path)/xrx:user
            else ()
    else ();

(: --- Request context --- :)
declare variable $xrx:request-uri := request:get-uri();

declare variable $xrx:tokenized-uri :=
    let $path := request:get-parameter("request-path", $xrx:request-uri)
    let $clean := replace($path, '^/+|/+$', '')
    let $tokens := tokenize($clean, '/')
    (: Skip leading segments like 'mom', 'exist', 'apps', 'mom-ca' :)
    let $start :=
        if ($tokens[1] = ('mom', 'exist')) then
            for $t at $p in $tokens
            return if ($t = ('home','fonds','collections','search','charter','archive','fond',
                            'collection','my-collection','my-collections','login','login2',
                            'registration','my-account','bookmarks','charters')) then $p else ()
        else 1
    let $first := ($start, count($tokens))[1]
    return subsequence($tokens, $first)
;

(: --- Language --- :)
declare variable $xrx:lang :=
    let $param := request:get-parameter('lang', '')
    return
        if ($param != '') then $param
        else
            let $cookie := request:get-cookie-value('lang')
            return if ($cookie) then $cookie else 'deu';

(: --- Collection paths (backward compatibility) --- :)
declare variable $xrx:live-db-base-collection-path := '/db/apps/mom-ca';
declare variable $xrx:live-project-db-base-collection-path := '/db/apps/mom-ca';
declare variable $xrx:live-project-db-base-collection := collection('/db/apps/mom-ca');
