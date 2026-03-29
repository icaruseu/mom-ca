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

(: Check if charter is already locked :)
let $lock-path := '/db/mom-data/charter-locks'
let $_ := if (not(xmldb:collection-available($lock-path))) then
    xmldb:create-collection('/db/mom-data', 'charter-locks') else ()
let $lock-doc := collection($lock-path)//*[local-name()='lock'][*[local-name()='charter-id'] = $charter-atom-id]
let $locked-by := string($lock-doc/*[local-name()='user'])

(: Fallback: check if user already has a private copy with sameAs matching this charter :)
let $existing-copy :=
    if ($locked-by = '') then
        let $user-charter-path := '/db/mom-data/xrx.user/' || xmldb:encode($user) || '/metadata.charter'
        return if (xmldb:collection-available($user-charter-path)) then
            let $sub-colls := xmldb:get-child-collections($user-charter-path)
            return (
                for $sc in $sub-colls
                let $sc-path := $user-charter-path || '/' || $sc
                return collection($sc-path)/atom:entry[.//cei:text/@sameAs = $charter-atom-id]
            )[1]
        else ()
    else ()

return
    if ($locked-by ne '' and $locked-by ne $user) then
        <div class="card" style="max-width:600px;margin:var(--space-xxl) auto;">
            <div class="card-body text-center">
                <h2>Charter Locked</h2>
                <p class="text-muted">This charter is already being edited by <strong>{$locked-by}</strong>.</p>
                <a href="javascript:history.back()" class="btn">Go Back</a>
            </div>
        </div>
    else if ($locked-by = $user or exists($existing-copy)) then
        let $existing-id := if ($locked-by = $user) then
            string($lock-doc/*[local-name()='private-id'])
        else string($existing-copy/atom:id)
        let $priv-tokens := tokenize(substring-after($existing-id, conf:param('atom-tag-name')), '/')[. ne '']
        let $priv-coll := $priv-tokens[2]
        let $priv-id := $priv-tokens[last()]
        let $_ := response:redirect-to(xs:anyURI('/mom/' || $priv-coll || '/' || $priv-id || '/charter'))
        return <div>Redirecting to existing copy...</div>
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

(: Build private copy with sameAs reference :)
let $new-id := util:uuid()
let $new-atom-id := $tag || '/charter/' || $target-coll || '/' || $new-id

(: Add @sameAs to cei:text pointing back to original :)
let $source-content := $source-entry/atom:content
let $modified-content :=
    element { node-name($source-content) } {
        $source-content/@*,
        for $child in $source-content/node()
        return
            if ($child instance of element() and local-name($child) = 'text' and namespace-uri($child) = 'http://www.monasterium.net/NS/cei') then
                element { node-name($child) } {
                    $child/@* except $child/@sameAs,
                    attribute sameAs { $charter-atom-id },
                    $child/node()
                }
            else $child
    }

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
        {$modified-content}
    </atom:entry>

let $filename := $new-id || '.cei.xml'
let $_ := xmldb:store($target-path, $filename, $private-entry)

(: Create lock file :)
let $lock-filename := xmldb:encode($charter-atom-id) || '.xml'
let $lock-xml :=
    <lock xmlns="http://www.monasterium.net/NS/lock">
        <charter-id>{$charter-atom-id}</charter-id>
        <user>{$user}</user>
        <date>{current-dateTime()}</date>
        <private-id>{$new-atom-id}</private-id>
    </lock>
let $_ := xmldb:store($lock-path, $lock-filename, $lock-xml)

(: Redirect to the private copy :)
let $_ := response:redirect-to(xs:anyURI('/mom/' || $target-coll || '/' || $new-id || '/charter'))
return ()
