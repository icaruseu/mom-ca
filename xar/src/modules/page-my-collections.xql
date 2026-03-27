xquery version "3.1";

(:~
 : My Collections page — shows the logged-in user's private collections,
 : saved charters, and bookmarks.
 :)

declare namespace atom = "http://www.w3.org/2005/Atom";
declare namespace cei = "http://www.monasterium.net/NS/cei";
declare namespace xrx = "http://www.monasterium.net/NS/xrx";

import module namespace conf = "http://www.monasterium.net/NS/conf"
    at "/db/apps/mom-ca/modules/core/conf.xqm";

let $user := try { string(session:get-attribute('mom.user')) } catch * { '' }
let $xquery-user := string(request:get-attribute('xquery.user'))
let $user := if ($user != '') then $user else if ($xquery-user != 'guest' and $xquery-user != '') then $xquery-user else ''

return
    if ($user = '') then
        <div class="card" style="max-width: 600px; margin: var(--space-xxl) auto;">
            <div class="card-body text-center">
                <h2>Login Required</h2>
                <p class="text-muted">Please log in to view your collections.</p>
                <a href="/mom/login" class="btn btn--primary">Login</a>
            </div>
        </div>
    else

let $user-base := '/db/mom-data/xrx.user/' || $user

(: My Collections :)
let $mycoll-base := $user-base || '/metadata.mycollection'
let $mycollections :=
    if (xmldb:collection-available($mycoll-base)) then
        collection($mycoll-base)/atom:entry
    else ()

(: Private saved charters :)
let $charter-base := $user-base || '/metadata.charter'
let $charter-colls :=
    if (xmldb:collection-available($charter-base)) then
        xmldb:get-child-collections($charter-base)
    else ()

(: Bookmarks :)
let $bookmarks-base := $user-base || '/metadata.bookmark-notes'
let $bookmarks :=
    if (xmldb:collection-available($bookmarks-base)) then
        collection($bookmarks-base)/xrx:bookmark_note
    else ()

return
<div>
    <div class="hero" style="padding: var(--space-xl) 0; margin-bottom: var(--space-xl);">
        <h1>My Workspace</h1>
        <p class="subtitle">Welcome, {$user}</p>
    </div>

    <div class="page-layout">
        <main>
            <!-- My Collections -->
            <div class="card" style="margin-bottom: var(--space-lg);">
                <div class="card-header">My Collections ({count($mycollections)})</div>
                <div class="card-body">
                {
                    if (exists($mycollections)) then
                        <div class="charter-list">
                        {
                            for $entry in $mycollections
                            let $id := $entry/atom:id/text()
                            let $coll-id := tokenize($id, '/')[last()]
                            let $title := normalize-space($entry//*[local-name()='title'][1])
                            let $display := if ($title ne '') then $title else $coll-id
                            return
                                <div class="charter-item">
                                    <div class="charter-idno">
                                        <a href="/mom/{$coll-id}/collection">{$display}</a>
                                    </div>
                                    <div class="charter-meta text-small text-muted">{$coll-id}</div>
                                </div>
                        }
                        </div>
                    else
                        <p class="text-muted">No collections yet. You can create your own collections to organize charters.</p>
                }
                </div>
            </div>

            <!-- Saved Charters -->
            {
                if (exists($charter-colls)) then
                    <div class="card" style="margin-bottom: var(--space-lg);">
                        <div class="card-header">Saved Charters</div>
                        <div class="card-body">
                            <div class="charter-list">
                            {
                                for $coll-name in $charter-colls
                                let $coll-path := $charter-base || '/' || $coll-name
                                let $charters := if (xmldb:collection-available($coll-path)) then collection($coll-path)/atom:entry else ()
                                return
                                    for $charter in $charters
                                    let $charter-id := $charter/atom:id/text()
                                    let $idno := normalize-space($charter//cei:body/cei:idno)
                                    let $abstract := substring(normalize-space(string-join($charter//cei:abstract//text(), ' ')), 1, 200)
                                    return
                                        <div class="charter-item">
                                            <div class="charter-idno">{if ($idno ne '') then $idno else tokenize($charter-id, '/')[last()]}</div>
                                            {if ($abstract ne '') then
                                                <div class="charter-abstract">{$abstract}{if (string-length($abstract) ge 200) then '...' else ()}</div>
                                            else ()}
                                            <div class="charter-meta text-small text-muted">Collection: {$coll-name}</div>
                                        </div>
                            }
                            </div>
                        </div>
                    </div>
                else ()
            }

            <!-- Bookmarks -->
            <div class="card" style="margin-bottom: var(--space-lg);">
                <div class="card-header">Bookmarks ({count($bookmarks)})</div>
                <div class="card-body">
                {
                    if (exists($bookmarks)) then
                        <div class="charter-list">
                        {
                            for $bm in $bookmarks
                            let $bookmark-uri := xmldb:decode($bm/xrx:bookmark/text())
                            let $note := normalize-space($bm/xrx:note)
                            let $tokens := tokenize(substring-after($bookmark-uri, conf:param('atom-tag-name')), '/')[. ne '']
                            let $charter-id := $tokens[last()]
                            let $context := string-join(subsequence($tokens, 1, count($tokens) - 1), '/')
                            return
                                <div class="charter-item">
                                    <div class="charter-idno">
                                        <a href="/mom/{$context}/{xmldb:encode($charter-id)}/charter">{$charter-id}</a>
                                    </div>
                                    {if ($note ne '') then <div class="charter-abstract">{$note}</div> else ()}
                                    <div class="charter-meta text-small text-muted">{$context}</div>
                                </div>
                        }
                        </div>
                    else
                        <p class="text-muted">No bookmarks yet. Browse charters and bookmark them for quick access.</p>
                }
                </div>
            </div>
        </main>

        <aside class="sidebar">
            <div class="card">
                <div class="card-header">Account</div>
                <div class="card-body">
                    <ul>
                        <li><strong>User:</strong> {$user}</li>
                        <li><strong>Collections:</strong> {count($mycollections)}</li>
                        <li><strong>Bookmarks:</strong> {count($bookmarks)}</li>
                    </ul>
                </div>
            </div>
        </aside>
    </div>
</div>
