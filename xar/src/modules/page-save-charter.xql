xquery version "3.1";

(:~
 : Handles POST from charter page "Save to My Collection" form.
 : Copies the public charter to the user's private collection and redirects.
 :)

declare namespace atom = "http://www.w3.org/2005/Atom";
declare namespace cei = "http://www.monasterium.net/NS/cei";

import module namespace conf = "http://www.monasterium.net/NS/conf"
    at "/db/apps/mom-ca/modules/core/conf.xqm";

let $user := try { string(session:get-attribute('mom.user')) } catch * { '' }
let $xquery-user := string(request:get-attribute('xquery.user'))
let $user := if ($user ne '') then $user
    else if ($xquery-user ne 'guest' and $xquery-user ne '') then $xquery-user else ''

return
    if ($user = '') then
        <div class="card" style="max-width:600px;margin:var(--space-xxl) auto;">
            <div class="card-body text-center">
                <h2>Login Required</h2>
                <p class="text-muted">Please log in to save charters.</p>
                <a href="/mom/login" class="btn btn--primary">Login</a>
            </div>
        </div>
    else

let $charter-atom-id := request:get-parameter('charter-id', '')
let $target-coll := request:get-parameter('collection-id', '')

return
    if ($charter-atom-id = '' or $target-coll = '') then
        <div class="card" style="max-width:600px;margin:var(--space-xxl) auto;">
            <div class="card-body text-center">
                <h2>Error</h2>
                <p class="text-muted">Missing charter or collection ID.</p>
                <a href="/mom/home" class="btn">Back to Home</a>
            </div>
        </div>
    else

(: Parse atom:id to find source charter efficiently :)
let $tag := conf:param('atom-tag-name')
let $tokens := tokenize(substring-after($charter-atom-id, $tag), '/')[. ne '']
(: tokens: ('charter', 'context1', ['context2',] 'charter-key') :)
let $ctx-tokens := subsequence($tokens, 2, count($tokens) - 2)
let $charter-key := $tokens[last()]
let $source-path :=
    if (count($ctx-tokens) = 1) then
        '/db/mom-data/metadata.charter.public/' || $ctx-tokens[1]
    else
        '/db/mom-data/metadata.charter.public/' || string-join($ctx-tokens, '/')
let $source-entry :=
    if (xmldb:collection-available($source-path)) then
        (collection($source-path)/atom:entry[ends-with(atom:id, '/' || $charter-key)])[1]
    else
        (: Try fond path :)
        let $fond-path := '/db/mom-data/metadata.fond.public/' || string-join($ctx-tokens, '/')
        return if (xmldb:collection-available($fond-path)) then
            (collection($fond-path)/atom:entry[ends-with(atom:id, '/' || $charter-key)])[1]
        else ()

return
    if (empty($source-entry)) then
        <div class="card" style="max-width:600px;margin:var(--space-xxl) auto;">
            <div class="card-body text-center">
                <h2>Charter not found</h2>
                <p class="text-muted">The source charter could not be found.</p>
                <a href="/mom/home" class="btn">Back to Home</a>
            </div>
        </div>
    else

(: Create target collection if needed :)
let $user-base := '/db/mom-data/xrx.user/' || $user || '/metadata.charter'
let $target-path := $user-base || '/' || $target-coll
let $_ := if (not(xmldb:collection-available($user-base))) then
    xmldb:create-collection('/db/mom-data/xrx.user/' || $user, 'metadata.charter') else ()
let $_ := if (not(xmldb:collection-available($target-path))) then
    xmldb:create-collection($user-base, $target-coll) else ()

(: Build private copy :)
let $new-id := util:uuid()
let $new-atom-id := $tag || '/charter/' || $target-coll || '/' || $new-id

let $private-entry :=
    <atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
        <atom:id>{$new-atom-id}</atom:id>
        <atom:title/>
        <atom:published>{current-dateTime()}</atom:published>
        <atom:updated>{current-dateTime()}</atom:updated>
        <atom:author><atom:email>{$user}</atom:email></atom:author>
        <app:control xmlns:app="http://www.w3.org/2007/app">
            <app:draft>yes</app:draft>
        </app:control>
        {$source-entry/atom:content}
    </atom:entry>

let $filename := $new-id || '.cei.xml'
let $_ := xmldb:store($target-path, $filename, $private-entry)

(: Redirect to the private copy :)
let $_ := response:redirect-to(xs:anyURI('/mom/' || $target-coll || '/' || $new-id || '/charter'))
return ()
