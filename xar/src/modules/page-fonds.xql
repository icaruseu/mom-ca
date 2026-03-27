xquery version "3.1";

(:~
 : Fonds listing page — archives grouped by country with cards and pagination.
 :)

declare namespace atom = "http://www.w3.org/2005/Atom";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace eag = "http://www.archivgut-online.de/eag";

import module namespace metadata = "http://www.monasterium.net/NS/metadata"
    at "/db/apps/mom-ca/modules/metadata/metadata.xqm";
import module namespace conf = "http://www.monasterium.net/NS/conf"
    at "/db/apps/mom-ca/modules/core/conf.xqm";

declare function local:page-url($p as xs:integer, $country as xs:string) as xs:string {
    let $base := "fonds?p=" || $p
    return
        if ($country != '') then $base || codepoints-to-string(38) || "country=" || encode-for-uri($country)
        else $base
};

(: Pagination params :)
let $page := xs:integer(request:get-parameter('p', '1'))
let $per-page := 12
let $filter-country := request:get-parameter('country', '')

(: Gather all archives :)
let $all-archives := metadata:base-collection('archive', 'public')/atom:entry

(: Build country list for filter :)
let $country-list :=
    for $entry in $all-archives
    let $c := normalize-space($entry//eag:country/text())
    where $c != ''
    group by $c
    order by $c
    return map { "name": $c, "count": count($entry) }

(: Filter by country if selected :)
let $filtered-archives :=
    if ($filter-country != '') then
        $all-archives[normalize-space(.//eag:country/text()) = $filter-country]
    else
        $all-archives

(: Sort alphabetically :)
let $sorted-archives :=
    for $a in $filtered-archives
    let $name := normalize-space($a//eag:autform/text())
    order by $name
    return $a

let $total := count($sorted-archives)
let $total-pages := xs:integer(ceiling($total div $per-page))
let $start := ($page - 1) * $per-page + 1
let $page-archives := subsequence($sorted-archives, $start, $per-page)

let $total-fonds := count(metadata:base-collection('fond', 'public')/atom:entry[.//ead:ead])

return
<div>
    <!-- Hero header -->
    <div class="hero" style="padding: var(--space-xl) 0; margin-bottom: var(--space-xl);">
        <h1>Archives and Fonds</h1>
        <p class="subtitle">
            { count($all-archives) } archives with { $total-fonds } fonds from across Europe
        </p>
    </div>

    <div class="page-layout">
        <main>
            <!-- Active filter indicator -->
            {
                if ($filter-country != '') then
                    <div style="margin-bottom: var(--space-lg); display: flex; align-items: center; gap: var(--space-sm);">
                        <span class="text-muted">Filtered by:</span>
                        <span style="background: var(--color-bg-alt); padding: 2px 10px; border-radius: var(--radius); font-weight: 600;">
                            { $filter-country }
                        </span>
                        <a href="fonds" class="text-small" style="color: var(--color-accent);">Clear filter</a>
                    </div>
                else ()
            }

            <p class="text-muted text-small" style="margin-bottom: var(--space-lg);">
                Showing { $start }–{ min(($start + $per-page - 1, $total)) } of { $total } archives
                { if ($filter-country != '') then concat(' in ', $filter-country) else () }
            </p>

            <!-- Archive cards grid -->
            <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: var(--space-md);">
            {
                for $archive in $page-archives
                let $autform := normalize-space($archive//eag:autform)
                let $repoid := normalize-space($archive//eag:repositorid)
                let $country := normalize-space($archive//eag:country)
                let $city := normalize-space($archive//eag:municipalityPostalcode)
                let $tokens := tokenize(substring-after($archive/atom:id/text(), conf:param('atom-tag-name')), '/')[. != '']
                let $archive-key := $tokens[last()]
                let $fond-count := count(metadata:base-collection('fond', $archive-key, 'public')/atom:entry[.//ead:ead])
                let $display-name := if ($autform != '') then $autform else $archive-key
                let $display-id := if ($repoid != '') then $repoid else $archive-key
                return
                    <a href="{ $archive-key }/archive" class="card archive-card">
                        <div class="card-body archive-card-body">
                            <div class="archive-card-name">{ $display-name }</div>
                            <div class="archive-card-id">{ $display-id }</div>
                            <div class="archive-card-location">
                                { if ($city != '') then <span>{ $city }</span> else () }
                                { if ($city != '' and $country != '') then <span> · </span> else () }
                                { if ($country != '') then <span>{ $country }</span> else () }
                            </div>
                            <div class="archive-card-footer">
                                <span class="archive-card-badge">{ $fond-count }</span>
                                <span class="text-small text-muted">fond{ if ($fond-count != 1) then 's' else () }</span>
                            </div>
                        </div>
                    </a>
            }
            </div>

            <!-- Pagination -->
            {
                if ($total-pages > 1) then
                    <nav class="pagination" style="margin-top: var(--space-xl); justify-content: center;">
                        {
                            if ($page > 1) then
                                <a href="{ local:page-url($page - 1, $filter-country) }">&#x2190; Prev</a>
                            else ()
                        }
                        {
                            for $p in 1 to $total-pages
                            return
                                if ($p = $page) then
                                    <span class="active">{ $p }</span>
                                else if (abs($p - $page) le 2 or $p = 1 or $p = $total-pages) then
                                    <a href="{ local:page-url($p, $filter-country) }">{ $p }</a>
                                else if (abs($p - $page) = 3) then
                                    <span class="text-muted">...</span>
                                else ()
                        }
                        {
                            if ($page lt $total-pages) then
                                <a href="{ local:page-url($page + 1, $filter-country) }">Next &#x2192;</a>
                            else ()
                        }
                    </nav>
                else ()
            }
        </main>

        <aside class="sidebar">
            <!-- Stats card -->
            <div class="card">
                <div class="card-header">Overview</div>
                <div class="card-body">
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: var(--space-sm); text-align: center;">
                        <div>
                            <span class="stat-value" style="font-size: 1.5rem; display: block;">{ count($all-archives) }</span>
                            <span class="text-small text-muted">Archives</span>
                        </div>
                        <div>
                            <span class="stat-value" style="font-size: 1.5rem; display: block;">{ $total-fonds }</span>
                            <span class="text-small text-muted">Fonds</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Country filter -->
            <div class="card">
                <div class="card-header">Filter by Country</div>
                <div class="card-body" style="max-height: 400px; overflow-y: auto;">
                    <ul class="nostyle">
                        <li style="padding: 4px 0; border-bottom: 1px solid var(--color-border-light);">
                            <a href="fonds" style="{ if ($filter-country = '') then 'font-weight: 700; color: var(--color-accent);' else '' }">
                                All countries
                            </a>
                            <span class="text-small text-muted" style="float: right;">{ count($all-archives) }</span>
                        </li>
                        {
                            for $c in $country-list
                            return
                                <li style="padding: 4px 0; border-bottom: 1px solid var(--color-border-light);">
                                    <a href="fonds?country={ encode-for-uri($c?name) }"
                                       style="{ if ($filter-country = $c?name) then 'font-weight: 700; color: var(--color-accent);' else '' }">
                                        { $c?name }
                                    </a>
                                    <span class="text-small text-muted" style="float: right;">{ $c?count }</span>
                                </li>
                        }
                    </ul>
                </div>
            </div>

            <!-- Recently added -->
            <div class="card">
                <div class="card-header">Recently Added Fonds</div>
                <div class="card-body">
                    <ul class="nostyle">
                    {
                        for $entry in subsequence(
                            for $f in metadata:base-collection('fond', 'public')/atom:entry[.//ead:ead]
                            order by $f/atom:published descending
                            return $f
                        , 1, 5)
                        let $name := normalize-space(($entry//ead:unittitle/text())[1])
                        let $tokens := tokenize(substring-after($entry/atom:id/text(), conf:param('atom-tag-name')), '/')[. != '']
                        let $archive-key := $tokens[2]
                        let $fond-key := $tokens[last()]
                        return
                            <li style="padding: 4px 0; border-bottom: 1px solid var(--color-border-light);">
                                <a href="{ $archive-key }/{ $fond-key }/fond" class="text-small">
                                    { if ($name != '') then $name else $fond-key }
                                </a>
                            </li>
                    }
                    </ul>
                </div>
            </div>
        </aside>
    </div>
</div>
