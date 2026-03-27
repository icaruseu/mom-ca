xquery version "3.1";

(:~
 : Single fond page — shows fond details with paginated charter listing.
 :)

declare namespace atom = "http://www.w3.org/2005/Atom";
declare namespace cei = "http://www.monasterium.net/NS/cei";

import module namespace metadata = "http://www.monasterium.net/NS/metadata"
    at "/db/apps/mom-ca/modules/metadata/metadata.xqm";
import module namespace conf = "http://www.monasterium.net/NS/conf"
    at "/db/apps/mom-ca/modules/core/conf.xqm";

declare function local:page-url($p as xs:integer, $archive-key as xs:string, $fond-key as xs:string) as xs:string {
    "/mom/" || $archive-key || "/" || $fond-key || "/fond?block=" || $p
};

let $request-path := request:get-parameter("request-path", "")
let $tokens := tokenize(replace($request-path, '^/+|/+$', ''), '/')[. ne 'fond']
let $archive-key := $tokens[1]
let $fond-key := $tokens[2]

let $fond-entry := (metadata:base-collection('fond', ($archive-key, $fond-key), 'public')/atom:entry[.//*[local-name()='ead']])[1]
let $archive-entry := (metadata:base-collection('archive', $archive-key, 'public')/atom:entry[.//*[local-name()='eag']])[1]

return
    if (empty($fond-entry)) then
        <div class="card" style="max-width: 600px; margin: var(--space-xxl) auto;">
            <div class="card-body text-center">
                <h2>Fond not found</h2>
                <p class="text-muted">No fond "{$fond-key}" in archive "{$archive-key}".</p>
                <p class="text-small text-muted">Path: {$request-path}, Tokens: {string-join($tokens, ' | ')}</p>
                <a href="/mom/fonds" class="btn">Back to Archives</a>
            </div>
        </div>
    else

let $fond-name := normalize-space(($fond-entry//*[local-name()='unittitle'])[1])
let $archive-name := normalize-space(($archive-entry//*[local-name()='autform'])[1])

let $block := xs:integer(request:get-parameter('block', '1'))
let $page-size := 30
let $start := ($block - 1) * $page-size + 1

let $all-charters :=
    for $entry in metadata:base-collection('charter', ($archive-key, $fond-key), 'public')/atom:entry
    let $date := ($entry//cei:issued/cei:date/@value/string(), $entry//cei:issued/cei:dateRange/@from/string(), '99999999')[1]
    order by $date
    return $entry

let $total := count($all-charters)
let $total-pages := xs:integer(ceiling($total div $page-size))
let $page-charters := subsequence($all-charters, $start, $page-size)

(: Load all locks at once for performance :)
let $lock-path := '/db/mom-data/charter-locks'
let $all-locks := collection($lock-path)//*[local-name()='lock']

let $charter-cards :=
    for $entry in $page-charters
    let $idno := normalize-space($entry//cei:body/cei:idno)
    let $date-text := normalize-space(($entry//cei:issued/cei:date/text(), $entry//cei:issued/cei:dateRange/text())[1])
    let $abstract := substring(normalize-space(string-join($entry//cei:abstract//text(), ' ')), 1, 200)
    let $charter-tokens := tokenize(substring-after($entry/atom:id/text(), conf:param('atom-tag-name')), '/')[. ne '']
    let $charter-id := $charter-tokens[last()]
    let $img-count := count($entry//cei:graphic/@url)
    let $atom-id := $entry/atom:id/text()
    let $lock := $all-locks[*[local-name()='charter-id'] = $atom-id]
    let $locked-by := string($lock/*[local-name()='user'])
    return map {
        "idno": if ($idno ne '') then $idno else $charter-id,
        "id": $charter-id,
        "date": $date-text,
        "abstract": $abstract,
        "images": $img-count,
        "locked-by": $locked-by
    }

return
<div>
    <nav class="breadcrumb">
        <a href="/mom/fonds">Archives</a>
        <span class="sep">/</span>
        <a href="/mom/{$archive-key}/archive">{if ($archive-name ne '') then $archive-name else $archive-key}</a>
        <span class="sep">/</span>
        <span>{if ($fond-name ne '') then $fond-name else $fond-key}</span>
    </nav>

    <div class="page-layout">
        <main>
            <h1>{if ($fond-name ne '') then $fond-name else $fond-key}</h1>
            <p class="text-muted">{$total} charters</p>

            {
                if ($total gt 0) then (
                    <div class="charter-list">
                    {
                        for $c in $charter-cards
                        return
                            <div class="charter-item">
                                <div class="charter-date">{$c?date}</div>
                                <div class="charter-idno">
                                    <a href="/mom/{$archive-key}/{$fond-key}/{xmldb:encode($c?id)}/charter">{$c?idno}</a>
                                    {if ($c?("locked-by") ne '') then
                                        <span style="margin-left: 8px; font-size: 0.8rem; color: var(--color-warning, #e67e22);" title="Locked by {$c?('locked-by')}">&#x1F512; {$c?("locked-by")}</span>
                                    else ()}
                                </div>
                                {if ($c?abstract ne '') then
                                    <div class="charter-abstract">{$c?abstract}{if (string-length($c?abstract) ge 200) then '...' else ()}</div>
                                else ()}
                                <div class="charter-meta">
                                    {if ($c?images gt 0) then <span>{$c?images} image{if ($c?images gt 1) then 's' else ()}</span> else ()}
                                </div>
                            </div>
                    }
                    </div>,

                    if ($total-pages gt 1) then
                        <nav class="pagination" style="justify-content: center;">
                            {if ($block gt 1) then <a href="{local:page-url($block - 1, $archive-key, $fond-key)}">&#x2190; Prev</a> else ()}
                            {
                                for $p in 1 to $total-pages
                                return
                                    if ($p = $block) then <span class="active">{$p}</span>
                                    else if (abs($p - $block) le 2 or $p = 1 or $p = $total-pages) then
                                        <a href="{local:page-url($p, $archive-key, $fond-key)}">{$p}</a>
                                    else if (abs($p - $block) = 3) then <span class="text-muted">...</span>
                                    else ()
                            }
                            {if ($block lt $total-pages) then <a href="{local:page-url($block + 1, $archive-key, $fond-key)}">Next &#x2192;</a> else ()}
                        </nav>
                    else ()
                )
                else
                    <div class="card"><div class="card-body text-muted">No charters found in this fond.</div></div>
            }
        </main>

        <aside class="sidebar">
            <div class="card">
                <div class="card-header">Fond Details</div>
                <div class="card-body">
                    <ul>
                        <li><strong>Archive:</strong> <a href="/mom/{$archive-key}/archive">{if ($archive-name ne '') then $archive-name else $archive-key}</a></li>
                        <li><strong>Charters:</strong> {$total}</li>
                    </ul>
                </div>
            </div>
            <div class="card">
                <div class="card-body">
                    <a href="/mom/{$archive-key}/archive" class="btn" style="width: 100%; justify-content: center;">Back to Archive</a>
                </div>
            </div>
        </aside>
    </div>
</div>
