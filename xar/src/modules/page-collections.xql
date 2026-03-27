xquery version "3.1";

(:~
 : Collections overview — all Monasterium collections as cards with pagination.
 :)

declare namespace atom = "http://www.w3.org/2005/Atom";
declare namespace cei = "http://www.monasterium.net/NS/cei";

import module namespace metadata = "http://www.monasterium.net/NS/metadata"
    at "/db/apps/mom-ca/modules/metadata/metadata.xqm";
import module namespace conf = "http://www.monasterium.net/NS/conf"
    at "/db/apps/mom-ca/modules/core/conf.xqm";

declare function local:page-url($p as xs:integer, $country as xs:string) as xs:string {
    let $base := "collections?p=" || $p
    return
        if ($country ne '') then $base || codepoints-to-string(38) || "country=" || encode-for-uri($country)
        else $base
};

let $page := xs:integer(request:get-parameter('p', '1'))
let $per-page := 12
let $filter-country := request:get-parameter('country', '')

let $all-collections := collection("/db/mom-data/metadata.collection.public")/atom:entry

(: Pre-compute data to avoid namespace issues :)
let $coll-data :=
    for $e in $all-collections
    let $key := tokenize($e/atom:id/text(), '/')[last()]
    let $title := normalize-space(($e//cei:sourceDesc/cei:title)[1])
    let $prov := normalize-space(($e//cei:provenance/text())[1])
    let $country := normalize-space(($e//cei:country)[1])
    let $author := normalize-space(($e//cei:sourceDesc/cei:author)[1])
    let $charter-count := count(collection(concat("/db/mom-data/metadata.charter.public/", $key))/atom:entry)
    let $display-name := if ($title ne '') then $title else if ($prov ne '') then $prov else $key
    order by $display-name
    return map {
        "key": $key,
        "title": $display-name,
        "country": $country,
        "author": $author,
        "charters": $charter-count
    }

(: Country filter :)
let $country-list :=
    for $c in $coll-data
    let $cn := $c?country
    where $cn ne ''
    group by $cn
    order by $cn
    return map { "name": $cn, "count": count($c) }

let $filtered :=
    if ($filter-country ne '') then
        $coll-data[?country = $filter-country]
    else $coll-data

let $total := count($filtered)
let $total-pages := xs:integer(ceiling($total div $per-page))
let $start := ($page - 1) * $per-page + 1
let $page-items := subsequence($filtered, $start, $per-page)

return
<div>
    <div class="hero" style="padding: var(--space-xl) 0; margin-bottom: var(--space-xl);">
        <h1>Collections</h1>
        <p class="subtitle">{count($all-collections)} scholarly collections with charter editions and regesta</p>
    </div>

    <div class="page-layout">
        <main>
            {
                if ($filter-country ne '') then
                    <div style="margin-bottom: var(--space-lg); display: flex; align-items: center; gap: var(--space-sm);">
                        <span class="text-muted">Filtered by:</span>
                        <strong>{$filter-country}</strong>
                        <a href="collections" class="text-small" style="color: var(--color-accent);">Clear</a>
                    </div>
                else ()
            }

            <p class="text-muted text-small" style="margin-bottom: var(--space-lg);">
                Showing {$start}&#x2013;{min(($start + $per-page - 1, $total))} of {$total} collections
            </p>

            <div class="archive-grid">
            {
                for $c in $page-items
                return
                    <a href="/mom/{$c?key}/collection" class="card archive-card">
                        <div class="card-body archive-card-body">
                            <div class="archive-card-name">{$c?title}</div>
                            {if ($c?author ne '') then
                                <div class="archive-card-id">{$c?author}</div>
                            else ()}
                            <div class="archive-card-location">
                                {if ($c?country ne '') then $c?country else ()}
                            </div>
                            <div class="archive-card-footer">
                                <span class="archive-card-badge">{$c?charters}</span>
                                <span class="text-small text-muted">charter{if ($c?charters ne 1) then 's' else ()}</span>
                            </div>
                        </div>
                    </a>
            }
            </div>

            {
                if ($total-pages gt 1) then
                    <nav class="pagination" style="margin-top: var(--space-xl); justify-content: center;">
                        {if ($page gt 1) then <a href="{local:page-url($page - 1, $filter-country)}">&#x2190; Prev</a> else ()}
                        {
                            for $p in 1 to $total-pages
                            return
                                if ($p = $page) then <span class="active">{$p}</span>
                                else if (abs($p - $page) le 2 or $p = 1 or $p = $total-pages) then
                                    <a href="{local:page-url($p, $filter-country)}">{$p}</a>
                                else if (abs($p - $page) = 3) then <span class="text-muted">...</span>
                                else ()
                        }
                        {if ($page lt $total-pages) then <a href="{local:page-url($page + 1, $filter-country)}">Next &#x2192;</a> else ()}
                    </nav>
                else ()
            }
        </main>

        <aside class="sidebar">
            <div class="card">
                <div class="card-header">Overview</div>
                <div class="card-body" style="text-align: center;">
                    <span class="stat-value" style="font-size: 2rem; display: block;">{count($all-collections)}</span>
                    <span class="text-small text-muted">Collections</span>
                </div>
            </div>

            <div class="card">
                <div class="card-header">Filter by Country</div>
                <div class="card-body" style="max-height: 400px; overflow-y: auto;">
                    <ul class="nostyle">
                        <li style="padding: 4px 0; border-bottom: 1px solid var(--color-border-light);">
                            <a href="collections" style="{if ($filter-country = '') then 'font-weight:700;color:var(--color-accent);' else ''}">All countries</a>
                            <span class="text-small text-muted" style="float:right;">{count($coll-data)}</span>
                        </li>
                        {
                            for $c in $country-list
                            return
                                <li style="padding: 4px 0; border-bottom: 1px solid var(--color-border-light);">
                                    <a href="collections?country={encode-for-uri($c?name)}" style="{if ($filter-country = $c?name) then 'font-weight:700;color:var(--color-accent);' else ''}">{$c?name}</a>
                                    <span class="text-small text-muted" style="float:right;">{$c?count}</span>
                                </li>
                        }
                    </ul>
                </div>
            </div>
        </aside>
    </div>
</div>
