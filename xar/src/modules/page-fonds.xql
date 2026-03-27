xquery version "3.1";

(:~
 : Fonds listing page — archives as cards with pagination and country filter.
 :)

declare namespace atom = "http://www.w3.org/2005/Atom";
declare namespace ead = "urn:isbn:1-931666-22-9";

import module namespace metadata = "http://www.monasterium.net/NS/metadata"
    at "/db/apps/mom-ca/modules/metadata/metadata.xqm";
import module namespace conf = "http://www.monasterium.net/NS/conf"
    at "/db/apps/mom-ca/modules/core/conf.xqm";

declare function local:page-url($p as xs:integer, $country as xs:string) as xs:string {
    let $base := "fonds?p=" || $p
    return
        if ($country ne '') then $base || codepoints-to-string(38) || "country=" || encode-for-uri($country)
        else $base
};

declare function local:archive-name($entry as element(atom:entry)) as xs:string {
    normalize-space(($entry//*[local-name()='autform'])[1])
};

declare function local:archive-repoid($entry as element(atom:entry)) as xs:string {
    normalize-space(($entry//*[local-name()='repositorid'])[1])
};

declare function local:archive-country($entry as element(atom:entry)) as xs:string {
    normalize-space(($entry//*[local-name()='country'])[1])
};

declare function local:archive-city($entry as element(atom:entry)) as xs:string {
    normalize-space(($entry//*[local-name()='municipalityPostalcode'])[1])
};

declare function local:archive-key($entry as element(atom:entry)) as xs:string {
    let $tag := conf:param('atom-tag-name')
    let $tokens := tokenize(substring-after($entry/atom:id/text(), $tag), '/')[. ne '']
    return $tokens[last()]
};

let $page := xs:integer(request:get-parameter('p', '1'))
let $per-page := 12
let $filter-country := request:get-parameter('country', '')

let $all-archives := metadata:base-collection('archive', 'public')/atom:entry[.//*[local-name()='eag']]

(: Country filter sidebar data :)
let $country-list :=
    for $entry in $all-archives
    let $c := local:archive-country($entry)
    where $c ne ''
    group by $c
    order by $c
    return map { "name": $c, "count": count($entry) }

let $filtered :=
    if ($filter-country ne '') then
        for $a in $all-archives
        where local:archive-country($a) = $filter-country
        return $a
    else $all-archives

let $sorted :=
    for $a in $filtered
    let $n := local:archive-name($a)
    order by $n
    return $a

let $total := count($sorted)
let $total-pages := xs:integer(ceiling($total div $per-page))
let $start := ($page - 1) * $per-page + 1
let $page-items := subsequence($sorted, $start, $per-page)
let $total-fonds := count(metadata:base-collection('fond', 'public')/atom:entry[.//*[local-name()='ead']])

(: Pre-compute card data to avoid namespace issues in XML constructors :)
let $cards :=
    for $archive in $page-items
    let $name := local:archive-name($archive)
    let $key := local:archive-key($archive)
    let $repoid := local:archive-repoid($archive)
    let $city := local:archive-city($archive)
    let $country := local:archive-country($archive)
    let $fond-count := count(metadata:base-collection('fond', $key, 'public')/atom:entry[.//*[local-name()='ead']])
    return map {
        "name": if ($name ne '') then $name else $key,
        "key": $key,
        "repoid": if ($repoid ne '') then $repoid else $key,
        "city": $city,
        "country": $country,
        "fonds": $fond-count
    }

return
<div>
    <div class="hero" style="padding: var(--space-xl) 0; margin-bottom: var(--space-xl);">
        <h1>Archives and Fonds</h1>
        <p class="subtitle">{count($all-archives)} archives with {$total-fonds} fonds from across Europe</p>
    </div>

    <div class="page-layout">
        <main>
            {
                if ($filter-country ne '') then
                    <div style="margin-bottom: var(--space-lg); display: flex; align-items: center; gap: var(--space-sm);">
                        <span class="text-muted">Filtered by:</span>
                        <strong>{$filter-country}</strong>
                        <a href="fonds" class="text-small" style="color: var(--color-accent);">Clear</a>
                    </div>
                else ()
            }

            <p class="text-muted text-small" style="margin-bottom: var(--space-lg);">
                Showing {$start}&#x2013;{min(($start + $per-page - 1, $total))} of {$total} archives
            </p>

            <div class="archive-grid">
            {
                for $c in $cards
                return
                    <a href="{$c?key}/archive" class="card archive-card">
                        <div class="card-body archive-card-body">
                            <div class="archive-card-name">{$c?name}</div>
                            <div class="archive-card-id">{$c?repoid}</div>
                            <div class="archive-card-location">
                                {if ($c?city ne '') then $c?city else ()}
                                {if ($c?city ne '' and $c?country ne '') then ' &#x00B7; ' else ()}
                                {if ($c?country ne '') then $c?country else ()}
                            </div>
                            <div class="archive-card-footer">
                                <span class="archive-card-badge">{$c?fonds}</span>
                                <span class="text-small text-muted">fond{if ($c?fonds ne 1) then 's' else ()}</span>
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
                <div class="card-body">
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: var(--space-sm); text-align: center;">
                        <div><span class="stat-value" style="font-size: 1.5rem; display: block;">{count($all-archives)}</span><span class="text-small text-muted">Archives</span></div>
                        <div><span class="stat-value" style="font-size: 1.5rem; display: block;">{$total-fonds}</span><span class="text-small text-muted">Fonds</span></div>
                    </div>
                </div>
            </div>

            <div class="card">
                <div class="card-header">Filter by Country</div>
                <div class="card-body" style="max-height: 400px; overflow-y: auto;">
                    <ul class="nostyle">
                        <li style="padding: 4px 0; border-bottom: 1px solid var(--color-border-light);">
                            <a href="fonds" style="{if ($filter-country = '') then 'font-weight:700;color:var(--color-accent);' else ''}">All countries</a>
                            <span class="text-small text-muted" style="float:right;">{count($all-archives)}</span>
                        </li>
                        {
                            for $c in $country-list
                            return
                                <li style="padding: 4px 0; border-bottom: 1px solid var(--color-border-light);">
                                    <a href="fonds?country={encode-for-uri($c?name)}" style="{if ($filter-country = $c?name) then 'font-weight:700;color:var(--color-accent);' else ''}">{$c?name}</a>
                                    <span class="text-small text-muted" style="float:right;">{$c?count}</span>
                                </li>
                        }
                    </ul>
                </div>
            </div>
        </aside>
    </div>
</div>
