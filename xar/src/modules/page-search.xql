xquery version "3.1";

(:~
 : Fulltext search page for MOM-CA charters with Lucene facets.
 : Runs via util:eval(xs:anyURI(...)) from view-wrap.xql.
 :)

declare namespace atom = "http://www.w3.org/2005/Atom";
declare namespace cei = "http://www.monasterium.net/NS/cei";

import module namespace kwic = "http://exist-db.org/xquery/kwic";
import module namespace conf = "http://www.monasterium.net/NS/conf"
    at "/db/apps/mom-ca/modules/core/conf.xqm";

declare function local:search-url($query as xs:string, $filter-country as xs:string,
    $filter-language as xs:string, $filter-place as xs:string, $filter-person as xs:string,
    $filter-indexPlace as xs:string, $from as xs:string, $to as xs:string,
    $sort as xs:string, $params as map(*)) as xs:string {
    let $base := 'search'
    let $all-params := map:merge((
        map { 'q': $query },
        if ($filter-country ne '') then map { 'country': $filter-country } else (),
        if ($filter-language ne '') then map { 'language': $filter-language } else (),
        if ($filter-place ne '') then map { 'place': $filter-place } else (),
        if ($filter-person ne '') then map { 'person': $filter-person } else (),
        if ($filter-indexPlace ne '') then map { 'indexPlace': $filter-indexPlace } else (),
        if ($from ne '') then map { 'from': $from } else (),
        if ($to ne '') then map { 'to': $to } else (),
        if ($sort ne '' and $sort ne 'relevance') then map { 'sort': $sort } else (),
        $params
    ), map { 'duplicates': 'use-last' })
    let $pairs := for $key in map:keys($all-params)
        let $val := $all-params($key)
        where $val ne ''
        return $key || '=' || encode-for-uri($val)
    return $base || '?' || string-join($pairs, codepoints-to-string(38))
};

declare function local:facet-url($query as xs:string, $filter-country as xs:string,
    $filter-language as xs:string, $filter-place as xs:string, $filter-person as xs:string,
    $filter-indexPlace as xs:string, $from as xs:string, $to as xs:string,
    $sort as xs:string, $param-name as xs:string, $value as xs:string) as xs:string {
    local:search-url($query, $filter-country, $filter-language, $filter-place,
        $filter-person, $filter-indexPlace, $from, $to, $sort,
        map { $param-name: $value, 'p': '1' })
};

declare function local:render-kwic($hit as element()) as node()* {
    let $summary := kwic:summarize($hit, <config width="80"/>)
    return
        if (exists($summary)) then
            for $s in $summary
            return
                <span class="kwic-line">
                    {for $node in $s/node()
                     return
                        if ($node instance of element() and (
                            local-name($node) = 'match' or
                            ($node/@class = 'hi')
                        )) then
                            <mark>{$node/string()}</mark>
                        else $node
                    }
                </span>
        else
            <span class="text-muted">No preview available</span>
};

declare function local:render-result($hit as element(), $tag as xs:string) as element() {
    let $entry := $hit/ancestor::atom:entry
    let $atom-id := string($entry/atom:id)
    let $tokens := tokenize(substring-after($atom-id, $tag), '/')[. ne '']
    let $context-tokens := subsequence($tokens, 2, count($tokens) - 2)
    let $charter-id := $tokens[last()]
    let $context := string-join($context-tokens, ' / ')
    let $idno := normalize-space(($hit//cei:body/cei:idno)[1])
    let $date-text := normalize-space(($hit//cei:issued/cei:date/text(), $hit//cei:issued/cei:dateRange/text())[1])
    let $date-value := string(($hit//cei:issued/cei:date/@value, $hit//cei:issued/cei:dateRange/@from)[1])
    (: Show human date if available, otherwise try to format the value :)
    let $display-date :=
        if ($date-text ne '') then $date-text
        else if (string-length($date-value) = 8 and $date-value ne '99999999') then
            substring($date-value, 7, 2) || '.' || substring($date-value, 5, 2) || '.' || substring($date-value, 1, 4)
        else ''
    let $url := '/mom/' || string-join($context-tokens, '/') || '/' || xmldb:encode($charter-id) || '/charter'
    return
        <div class="charter-item">
            {if ($display-date ne '') then
                <div class="charter-date">{$display-date}</div>
            else ()}
            <div class="charter-idno">
                <a href="{$url}">{if ($idno ne '') then $idno else $charter-id}</a>
            </div>
            <div class="charter-abstract">{local:render-kwic($hit)}</div>
            <div class="charter-meta text-small text-muted">{$context}</div>
        </div>
};

declare function local:render-facet($title as xs:string, $facet-map as map(*),
    $param-name as xs:string, $active-value as xs:string,
    $query as xs:string, $filter-country as xs:string,
    $filter-language as xs:string, $filter-place as xs:string,
    $filter-person as xs:string, $filter-indexPlace as xs:string,
    $from as xs:string, $to as xs:string, $sort as xs:string) as element()? {
    if (map:size($facet-map) gt 0) then
        <div class="card" style="margin-bottom: var(--space-md);">
            <div class="card-header">{$title}</div>
            <div class="card-body" style="max-height:250px; overflow-y:auto;">
                <ul class="nostyle" style="list-style:none; margin:0; padding:0;">
                    {for $key in map:keys($facet-map)
                     let $count := $facet-map($key)
                     let $is-active := $key = $active-value
                     order by $count descending
                     return
                        <li style="padding:3px 0; border-bottom:1px solid var(--color-border-light);">
                            <a href="{local:facet-url($query, $filter-country, $filter-language,
                                $filter-place, $filter-person, $filter-indexPlace, $from, $to, $sort,
                                $param-name, if ($is-active) then '' else $key)}"
                               style="{if ($is-active) then 'font-weight:700; color:var(--color-accent);' else ''}">
                                {$key}
                            </a>
                            <span class="text-small text-muted" style="float:right;">{$count}</span>
                        </li>
                    }
                </ul>
            </div>
        </div>
    else ()
};

declare function local:render-active-filter($label as xs:string, $value as xs:string,
    $param-name as xs:string, $query as xs:string, $filter-country as xs:string,
    $filter-language as xs:string, $filter-place as xs:string,
    $filter-person as xs:string, $filter-indexPlace as xs:string,
    $from as xs:string, $to as xs:string, $sort as xs:string) as element()? {
    if ($value ne '') then
        <a href="{local:facet-url($query, $filter-country, $filter-language,
            $filter-place, $filter-person, $filter-indexPlace, $from, $to, $sort,
            $param-name, '')}"
           class="badge" style="display:inline-flex; align-items:center; gap:4px; padding:4px 10px; background:var(--color-accent); color:#fff; border-radius:12px; font-size:0.8rem; text-decoration:none; margin-right:6px;">
            {$label}: {$value} &#x2715;
        </a>
    else ()
};

(: Signal to view-wrap.xql that this page should be cacheable :)
let $_ := request:set-attribute("mom.cacheable", "true")

(: === URL Parameters === :)
let $query := request:get-parameter('q', '')
let $filter-country := request:get-parameter('country', '')
let $filter-language := request:get-parameter('language', '')
let $filter-place := request:get-parameter('place', '')
let $filter-person := request:get-parameter('person', '')
let $filter-indexPlace := request:get-parameter('indexPlace', '')
let $from := request:get-parameter('from', '')
let $to := request:get-parameter('to', '')
let $sort := request:get-parameter('sort', 'relevance')
let $page := xs:integer(request:get-parameter('p', '1'))
let $per-page := 20

let $tag := conf:param('atom-tag-name')

return
    if ($query = '') then
        (: No query — show search form only :)
        <div>
            <div class="hero" style="padding: var(--space-xl) 0; margin-bottom: var(--space-xl); text-align:center;">
                <h1>Search Charters</h1>
                <form method="GET" action="search" style="max-width:700px; margin:0 auto;">
                    <div style="display:flex; gap:8px; margin-bottom: var(--space-sm);">
                        <input type="text" name="q" value="" placeholder="Search abstract, tenor, persons, places..."
                               style="flex:1; padding:10px 14px; border:1px solid var(--color-border); border-radius:4px; font-size:1rem;"/>
                        <button type="submit" class="btn btn--primary">Search</button>
                    </div>
                    <div style="display:flex; gap:12px; align-items:center; flex-wrap:wrap; font-size:0.85rem; justify-content:center; margin-top:var(--space-sm);">
                        <div style="display:flex; align-items:center; gap:6px;">
                            <span class="text-muted">From</span>
                            <input type="text" name="from" value="" placeholder="YYYYMMDD" style="width:100px; padding:6px 10px; border:1px solid var(--color-border); border-radius:4px; font-size:0.85rem;"/>
                        </div>
                        <div style="display:flex; align-items:center; gap:6px;">
                            <span class="text-muted">To</span>
                            <input type="text" name="to" value="" placeholder="YYYYMMDD" style="width:100px; padding:6px 10px; border:1px solid var(--color-border); border-radius:4px; font-size:0.85rem;"/>
                        </div>
                    </div>
                </form>
                <p class="text-muted" style="margin-top: var(--space-md);">Full-text search across all public charters in Monasterium.net</p>
            </div>
        </div>
    else

    (: Query present — execute search :)
    let $options := <options>
        <default-operator>and</default-operator>
        <leading-wildcard>no</leading-wildcard>
        <filter-rewrite>yes</filter-rewrite>
    </options>

    let $hits := collection('/db/mom-data/metadata.charter.public')//cei:text[ft:query(., $query, $options)]

    (: Apply facet filters :)
    let $filtered := $hits
    let $filtered := if ($filter-country ne '') then
        $filtered[ancestor::atom:entry//cei:country = $filter-country]
    else $filtered
    let $filtered := if ($filter-language ne '') then
        $filtered[.//cei:lang_MOM = $filter-language]
    else $filtered
    let $filtered := if ($filter-place ne '') then
        $filtered[.//cei:issued/cei:placeName/@reg = $filter-place]
    else $filtered
    let $filtered := if ($filter-person ne '') then
        $filtered[ancestor::atom:entry//cei:back/cei:persName/@reg = $filter-person]
    else $filtered
    let $filtered := if ($filter-indexPlace ne '') then
        $filtered[ancestor::atom:entry//cei:back/cei:placeName/@reg = $filter-indexPlace]
    else $filtered

    (: Date range filter :)
    let $filtered := if ($from ne '') then
        $filtered[ancestor::atom:entry//cei:issued/(cei:date/@value|cei:dateRange/@from) >= $from]
    else $filtered
    let $filtered := if ($to ne '') then
        $filtered[ancestor::atom:entry//cei:issued/(cei:date/@value|cei:dateRange/@to) <= $to]
    else $filtered

    (: Facet counts with try/catch fallback :)
    let $country-facets :=
        try { ft:facets($filtered, "country", 20) }
        catch * {
            map:merge(
                for $h in $filtered
                let $c := normalize-space($h/ancestor::atom:entry//cei:country[1])
                where $c ne ''
                group by $c
                return map:entry($c, count($h))
            )
        }
    let $language-facets :=
        try { ft:facets($filtered, "language", 10) }
        catch * {
            map:merge(
                for $h in $filtered
                let $c := normalize-space($h//cei:lang_MOM[1])
                where $c ne ''
                group by $c
                return map:entry($c, count($h))
            )
        }
    let $place-facets :=
        try { ft:facets($filtered, "place", 20) }
        catch * {
            map:merge(
                for $h in $filtered
                let $c := normalize-space($h//cei:issued/cei:placeName/@reg)
                where $c ne ''
                group by $c
                return map:entry($c, count($h))
            )
        }
    let $person-facets :=
        try { ft:facets($filtered, "person", 20) }
        catch * {
            map:merge(
                for $h in $filtered
                let $c := normalize-space($h/ancestor::atom:entry//cei:back/cei:persName/@reg)
                where $c ne ''
                group by $c
                return map:entry($c, count($h))
            )
        }
    let $indexPlace-facets :=
        try { ft:facets($filtered, "indexPlace", 20) }
        catch * {
            map:merge(
                for $h in $filtered
                let $c := normalize-space($h/ancestor::atom:entry//cei:back/cei:placeName/@reg)
                where $c ne ''
                group by $c
                return map:entry($c, count($h))
            )
        }

    (: Sort :)
    let $sorted := if ($sort = 'date') then
        for $h in $filtered
        let $d := string(($h//cei:issued/cei:date/@value, $h//cei:issued/cei:dateRange/@from, '99999999')[1])
        order by $d ascending
        return $h
    else
        for $h in $filtered
        order by ft:score($h) descending
        return $h

    (: Pagination :)
    let $total := count($sorted)
    let $total-pages := xs:integer(ceiling($total div $per-page))
    let $page := min(($page, max(($total-pages, 1))))
    let $start := ($page - 1) * $per-page + 1
    let $end := min(($start + $per-page - 1, $total))
    let $paged := subsequence($sorted, $start, $per-page)

    return
        <div>
            <!-- Hero with search form -->
            <div class="hero" style="padding: var(--space-xl) 0; margin-bottom: var(--space-xl); text-align:center;">
                <h1>Search Charters</h1>
                <form method="GET" action="search" style="max-width:700px; margin:0 auto;">
                    <div style="display:flex; gap:8px; margin-bottom: var(--space-sm);">
                        <input type="text" name="q" value="{$query}" placeholder="Search abstract, tenor, persons, places..."
                               style="flex:1; padding:10px 14px; border:1px solid var(--color-border); border-radius:4px; font-size:1rem;"/>
                        <button type="submit" class="btn btn--primary">Search</button>
                    </div>
                    <div style="display:flex; gap:12px; align-items:center; flex-wrap:wrap; font-size:0.85rem; justify-content:center; margin-top:var(--space-sm);">
                        <div style="display:flex; align-items:center; gap:6px;">
                            <span class="text-muted">From</span>
                            <input type="text" name="from" value="{$from}" placeholder="YYYYMMDD" style="width:100px; padding:6px 10px; border:1px solid var(--color-border); border-radius:4px; font-size:0.85rem;"/>
                        </div>
                        <div style="display:flex; align-items:center; gap:6px;">
                            <span class="text-muted">To</span>
                            <input type="text" name="to" value="{$to}" placeholder="YYYYMMDD" style="width:100px; padding:6px 10px; border:1px solid var(--color-border); border-radius:4px; font-size:0.85rem;"/>
                        </div>
                        <div style="display:flex; align-items:center; gap:6px;">
                            <span class="text-muted">Sort</span>
                            <select name="sort" style="padding:6px 10px; border:1px solid var(--color-border); border-radius:4px; font-size:0.85rem; background:white;">
                                <option value="relevance">{if ($sort ne 'date') then attribute selected {'selected'} else ()}Relevance</option>
                                <option value="date">{if ($sort = 'date') then attribute selected {'selected'} else ()}Date</option>
                            </select>
                        </div>
                    </div>
                    {if ($filter-country ne '') then <input type="hidden" name="country" value="{$filter-country}"/> else ()}
                    {if ($filter-language ne '') then <input type="hidden" name="language" value="{$filter-language}"/> else ()}
                    {if ($filter-place ne '') then <input type="hidden" name="place" value="{$filter-place}"/> else ()}
                    {if ($filter-person ne '') then <input type="hidden" name="person" value="{$filter-person}"/> else ()}
                    {if ($filter-indexPlace ne '') then <input type="hidden" name="indexPlace" value="{$filter-indexPlace}"/> else ()}
                </form>
            </div>

            <!-- Results layout -->
            <div class="page-layout" style="display:grid; grid-template-columns:1fr 280px; gap:var(--space-lg); align-items:start;">

                <!-- Main content -->
                <div>
                    <!-- Active filters -->
                    <div style="margin-bottom: var(--space-md);">
                        {local:render-active-filter('Country', $filter-country, 'country',
                            $query, $filter-country, $filter-language, $filter-place,
                            $filter-person, $filter-indexPlace, $from, $to, $sort)}
                        {local:render-active-filter('Language', $filter-language, 'language',
                            $query, $filter-country, $filter-language, $filter-place,
                            $filter-person, $filter-indexPlace, $from, $to, $sort)}
                        {local:render-active-filter('Place', $filter-place, 'place',
                            $query, $filter-country, $filter-language, $filter-place,
                            $filter-person, $filter-indexPlace, $from, $to, $sort)}
                        {local:render-active-filter('Person', $filter-person, 'person',
                            $query, $filter-country, $filter-language, $filter-place,
                            $filter-person, $filter-indexPlace, $from, $to, $sort)}
                        {local:render-active-filter('Index Place', $filter-indexPlace, 'indexPlace',
                            $query, $filter-country, $filter-language, $filter-place,
                            $filter-person, $filter-indexPlace, $from, $to, $sort)}
                        {if ($from ne '') then
                            local:render-active-filter('From', $from, 'from',
                                $query, $filter-country, $filter-language, $filter-place,
                                $filter-person, $filter-indexPlace, $from, $to, $sort)
                        else ()}
                        {if ($to ne '') then
                            local:render-active-filter('To', $to, 'to',
                                $query, $filter-country, $filter-language, $filter-place,
                                $filter-person, $filter-indexPlace, $from, $to, $sort)
                        else ()}
                    </div>

                    <!-- Result count -->
                    <p style="margin-bottom: var(--space-md); color: var(--color-text-muted);">
                        {$total} results for <strong>'{$query}'</strong>
                        {if ($total gt 0) then
                            concat(' (showing ', $start, '–', $end, ')')
                        else ()}
                    </p>

                    <!-- Result list -->
                    {if ($total = 0) then
                        <div class="card" style="padding: var(--space-lg); text-align:center;">
                            <p class="text-muted">No charters found matching your query. Try broadening your search terms.</p>
                        </div>
                    else
                        for $hit in $paged
                        return local:render-result($hit, $tag)
                    }

                    <!-- Pagination -->
                    {if ($total-pages gt 1) then
                        <nav style="display:flex; justify-content:center; gap:4px; margin-top:var(--space-lg); flex-wrap:wrap;">
                            {if ($page gt 1) then
                                <a href="{local:search-url($query, $filter-country, $filter-language,
                                    $filter-place, $filter-person, $filter-indexPlace, $from, $to, $sort,
                                    map { 'p': string($page - 1) })}"
                                   class="btn btn--small">&#x2190; Prev</a>
                            else ()}
                            {for $p in 1 to $total-pages
                             where $p = 1 or $p = $total-pages
                                or ($p >= $page - 2 and $p <= $page + 2)
                             return (
                                if ($p gt 1 and not($p = $page - 2) and $p != 2) then
                                    <span style="padding:6px 4px; color:var(--color-text-muted);">...</span>
                                else (),
                                if ($p = $page) then
                                    <span class="btn btn--small" style="font-weight:700; background:var(--color-accent); color:#fff;">{$p}</span>
                                else
                                    <a href="{local:search-url($query, $filter-country, $filter-language,
                                        $filter-place, $filter-person, $filter-indexPlace, $from, $to, $sort,
                                        map { 'p': string($p) })}"
                                       class="btn btn--small">{$p}</a>
                             )}
                            {if ($page lt $total-pages) then
                                <a href="{local:search-url($query, $filter-country, $filter-language,
                                    $filter-place, $filter-person, $filter-indexPlace, $from, $to, $sort,
                                    map { 'p': string($page + 1) })}"
                                   class="btn btn--small">Next &#x2192;</a>
                            else ()}
                        </nav>
                    else ()}
                </div>

                <!-- Sidebar: Facets -->
                <aside>
                    {local:render-facet('Country', $country-facets, 'country', $filter-country,
                        $query, $filter-country, $filter-language, $filter-place,
                        $filter-person, $filter-indexPlace, $from, $to, $sort)}
                    {local:render-facet('Language', $language-facets, 'language', $filter-language,
                        $query, $filter-country, $filter-language, $filter-place,
                        $filter-person, $filter-indexPlace, $from, $to, $sort)}
                    {local:render-facet('Issuing Place', $place-facets, 'place', $filter-place,
                        $query, $filter-country, $filter-language, $filter-place,
                        $filter-person, $filter-indexPlace, $from, $to, $sort)}
                    {local:render-facet('Person', $person-facets, 'person', $filter-person,
                        $query, $filter-country, $filter-language, $filter-place,
                        $filter-person, $filter-indexPlace, $from, $to, $sort)}
                    {local:render-facet('Index Place', $indexPlace-facets, 'indexPlace', $filter-indexPlace,
                        $query, $filter-country, $filter-language, $filter-place,
                        $filter-person, $filter-indexPlace, $from, $to, $sort)}
                </aside>
            </div>
        </div>
