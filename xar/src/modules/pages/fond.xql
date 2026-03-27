xquery version "3.1";

(:~
 : Single fond page — dynamic XQuery version.
 : Shows fond details with charter listing.
 :)

declare namespace atom = "http://www.w3.org/2005/Atom";
declare namespace cei = "http://www.monasterium.net/NS/cei";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace eag = "http://www.archivgut-online.de/eag";

import module namespace metadata = "http://www.monasterium.net/NS/metadata"
    at "../metadata/metadata.xqm";
import module namespace conf = "http://www.monasterium.net/NS/conf"
    at "../core/conf.xqm";

let $request-path := request:get-parameter("request-path", "")
let $tokens := tokenize(replace($request-path, '^/+|/+$', ''), '/')
let $archive-key := $tokens[1]
let $fond-key := $tokens[2]

let $fond-entry := (metadata:base-collection('fond', ($archive-key, $fond-key), 'public')/atom:entry)[1]
let $archive-entry := (metadata:base-collection('archive', $archive-key, 'public')/atom:entry)[1]

return
    if (empty($fond-entry)) then
        <div class="card">
            <div class="card-body text-center">
                <h2>Fond not found</h2>
                <p class="text-muted">No fond "{ $fond-key }" in archive "{ $archive-key }".</p>
                <a href="fonds" class="btn">Back to Archives</a>
            </div>
        </div>
    else

let $fond-name := normalize-space(($fond-entry//ead:unittitle/text())[1])
let $archive-name := normalize-space($archive-entry//eag:autform/text())

(: Charter listing with pagination :)
let $block := xs:integer(request:get-parameter('block', '1'))
let $page-size := 30
let $start := ($block - 1) * $page-size + 1

let $all-charters :=
    for $entry in metadata:base-collection('charter', ($archive-key, $fond-key), 'public')/atom:entry
    let $date := ($entry//cei:issued/cei:date/@value/string(), $entry//cei:issued/cei:dateRange/@from/string(), '99999999')[1]
    order by $date
    return $entry

let $total := count($all-charters)
let $total-pages := ceiling($total div $page-size)
let $page-charters := subsequence($all-charters, $start, $page-size)

return
<div>
    <nav class="breadcrumb">
        <a href="fonds">Archives</a>
        <span class="sep">/</span>
        <a href="{ $archive-key }/archive">{ if ($archive-name != '') then $archive-name else $archive-key }</a>
        <span class="sep">/</span>
        <span>{ if ($fond-name != '') then $fond-name else $fond-key }</span>
    </nav>

    <div class="page-layout">
        <main>
            <h1>{ if ($fond-name != '') then $fond-name else $fond-key }</h1>
            <p class="text-muted">{ $total } charters</p>

            {
                if ($total > 0) then (
                    <div class="charter-list">
                    {
                        for $entry in $page-charters
                        let $idno := normalize-space($entry//cei:body/cei:idno/text())
                        let $date-text := normalize-space(($entry//cei:issued/cei:date/text(), $entry//cei:issued/cei:dateRange/text())[1])
                        let $abstract := substring(normalize-space(string-join($entry//cei:abstract//text(), ' ')), 1, 200)
                        let $charter-tokens := tokenize(substring-after($entry/atom:id/text(), conf:param('atom-tag-name')), '/')[. != '']
                        let $charter-id := $charter-tokens[last()]
                        let $img-count := count($entry//cei:graphic/@url)
                        return
                            <div class="charter-item">
                                <div class="charter-date">{ $date-text }</div>
                                <div class="charter-idno">
                                    <a href="{ $archive-key }/{ $fond-key }/{ xmldb:encode($charter-id) }/charter">
                                        { if ($idno != '') then $idno else $charter-id }
                                    </a>
                                </div>
                                { if ($abstract != '') then
                                    <div class="charter-abstract">{ $abstract }{ if (string-length($abstract) >= 200) then '...' else () }</div>
                                  else () }
                                <div class="charter-meta">
                                    { if ($img-count > 0) then <span>{ $img-count } image{ if ($img-count > 1) then 's' else () }</span> else () }
                                </div>
                            </div>
                    }
                    </div>,

                    if ($total-pages > 1) then
                        <nav class="pagination">
                        {
                            for $p in 1 to xs:integer($total-pages)
                            return
                                if ($p = $block) then
                                    <span class="active">{ $p }</span>
                                else
                                    <a href="{ $archive-key }/{ $fond-key }/fond?block={ $p }">{ $p }</a>
                        }
                        </nav>
                    else ()
                )
                else
                    <div class="card">
                        <div class="card-body text-muted">No charters found in this fond.</div>
                    </div>
            }
        </main>

        <aside class="sidebar">
            <div class="card">
                <div class="card-header">Fond Details</div>
                <div class="card-body">
                    <ul>
                        <li><strong>Archive:</strong> <a href="{ $archive-key }/archive">{ if ($archive-name != '') then $archive-name else $archive-key }</a></li>
                        <li><strong>Charters:</strong> { $total }</li>
                    </ul>
                </div>
            </div>
        </aside>
    </div>
</div>
