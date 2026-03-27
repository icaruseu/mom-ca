xquery version "3.1";

(:~
 : Single collection page — shows collection details with paginated charter listing.
 :)

declare namespace atom = "http://www.w3.org/2005/Atom";
declare namespace cei = "http://www.monasterium.net/NS/cei";

import module namespace metadata = "http://www.monasterium.net/NS/metadata"
    at "/db/apps/mom-ca/modules/metadata/metadata.xqm";
import module namespace conf = "http://www.monasterium.net/NS/conf"
    at "/db/apps/mom-ca/modules/core/conf.xqm";

declare function local:page-url($p as xs:integer, $coll-key as xs:string) as xs:string {
    "/mom/" || $coll-key || "/collection?block=" || $p
};

let $request-path := request:get-parameter("request-path", "")
let $tokens := tokenize(replace($request-path, '^/+|/+$', ''), '/')[. ne 'collection']
let $coll-key := $tokens[1]

(: Collection metadata :)
let $coll-entry := (collection(concat("/db/mom-data/metadata.collection.public/", $coll-key))/atom:entry)[1]

return
    if (empty($coll-entry)) then
        <div class="card" style="max-width: 600px; margin: var(--space-xxl) auto;">
            <div class="card-body text-center">
                <h2>Collection not found</h2>
                <p class="text-muted">No collection "{$coll-key}" found.</p>
                <a href="/mom/collections" class="btn">Back to Collections</a>
            </div>
        </div>
    else

let $title := normalize-space(($coll-entry//cei:sourceDesc/cei:title)[1])
let $author := normalize-space(($coll-entry//cei:sourceDesc/cei:author)[1])
let $prov := normalize-space(($coll-entry//cei:provenance/text())[1])
let $country := normalize-space(($coll-entry//cei:country)[1])
let $preface-raw := string(($coll-entry//*[local-name()='div'][@type='preface'])[1])
let $preface := if (normalize-space($preface-raw) ne '') then
    util:parse-html(concat("<div>", $preface-raw, "</div>"))/HTML/BODY/div/node()
else ()
let $display-name := if ($title ne '') then $title else if ($prov ne '') then $prov else $coll-key

(: Pagination :)
let $block := xs:integer(request:get-parameter('block', '1'))
let $page-size := 30
let $start := ($block - 1) * $page-size + 1

(: Load charters :)
let $charter-coll := collection(concat("/db/mom-data/metadata.charter.public/", $coll-key))
let $all-charters :=
    for $entry in $charter-coll/atom:entry
    let $date := ($entry//cei:issued/cei:date/@value/string(), $entry//cei:issued/cei:dateRange/@from/string(), '99999999')[1]
    order by $date
    return $entry

let $total := count($all-charters)
let $total-pages := xs:integer(ceiling($total div $page-size))
let $page-charters := subsequence($all-charters, $start, $page-size)

let $charter-cards :=
    for $entry in $page-charters
    let $idno := normalize-space($entry//cei:body/cei:idno)
    let $date-text := normalize-space(($entry//cei:issued/cei:date/text(), $entry//cei:issued/cei:dateRange/text())[1])
    let $abstract := substring(normalize-space(string-join($entry//cei:abstract//text(), ' ')), 1, 200)
    let $charter-tokens := tokenize(substring-after($entry/atom:id/text(), conf:param('atom-tag-name')), '/')[. ne '']
    let $charter-id := $charter-tokens[last()]
    let $img-count := count($entry//cei:graphic/@url)
    return map {
        "idno": if ($idno ne '') then $idno else $charter-id,
        "id": $charter-id,
        "date": $date-text,
        "abstract": $abstract,
        "images": $img-count
    }

return
<div>
    <nav class="breadcrumb">
        <a href="/mom/collections">Collections</a>
        <span class="sep">/</span>
        <span>{$display-name}</span>
    </nav>

    <div class="page-layout">
        <main>
            <h1>{$display-name}</h1>
            {if ($author ne '') then <p class="text-muted">by {$author}</p> else ()}
            <p class="text-muted">{$total} charters</p>

            {
                if (exists($preface)) then
                    <div class="card" style="margin-bottom: var(--space-lg);">
                        <div class="card-header">Preface</div>
                        <div class="card-body preface-content">
                            {$preface}
                        </div>
                    </div>
                else ()
            }

            {
                if ($total gt 0) then (
                    <div class="charter-list">
                    {
                        for $c in $charter-cards
                        return
                            <div class="charter-item">
                                <div class="charter-date">{$c?date}</div>
                                <div class="charter-idno">
                                    <a href="/mom/{$coll-key}/{xmldb:encode($c?id)}/charter">{$c?idno}</a>
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
                            {if ($block gt 1) then <a href="{local:page-url($block - 1, $coll-key)}">Prev</a> else ()}
                            {
                                for $p in 1 to $total-pages
                                return
                                    if ($p = $block) then <span class="active">{$p}</span>
                                    else if (abs($p - $block) le 2 or $p = 1 or $p = $total-pages) then
                                        <a href="{local:page-url($p, $coll-key)}">{$p}</a>
                                    else if (abs($p - $block) = 3) then <span class="text-muted">...</span>
                                    else ()
                            }
                            {if ($block lt $total-pages) then <a href="{local:page-url($block + 1, $coll-key)}">Next</a> else ()}
                        </nav>
                    else ()
                )
                else
                    <div class="card"><div class="card-body text-muted">No charters found in this collection.</div></div>
            }
        </main>

        <aside class="sidebar">
            <div class="card">
                <div class="card-header">Collection Info</div>
                <div class="card-body">
                    <ul>
                        {if ($title ne '') then <li><strong>Title:</strong> {$title}</li> else ()}
                        {if ($author ne '') then <li><strong>Author:</strong> {$author}</li> else ()}
                        {if ($country ne '') then <li><strong>Country:</strong> {$country}</li> else ()}
                        <li><strong>Charters:</strong> {$total}</li>
                        <li><strong>Key:</strong> <span class="text-small">{$coll-key}</span></li>
                    </ul>
                </div>
            </div>
            <div class="card">
                <div class="card-body">
                    <a href="/mom/collections" class="btn" style="width:100%;justify-content:center;">Back to Collections</a>
                </div>
            </div>
        </aside>
    </div>
</div>
