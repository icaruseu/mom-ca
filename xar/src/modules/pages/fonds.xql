xquery version "3.1";

(:~
 : Fonds listing page — dynamic XQuery version.
 : Lists all archives grouped by country with their fonds.
 :)

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace atom = "http://www.w3.org/2005/Atom";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace eag = "http://www.archivgut-online.de/eag";

import module namespace metadata = "http://www.monasterium.net/NS/metadata"
    at "../metadata/metadata.xqm";
import module namespace conf = "http://www.monasterium.net/NS/conf"
    at "../core/conf.xqm";

let $archives := metadata:base-collection('archive', 'public')/atom:entry
let $countries :=
    for $entry in $archives
    let $country := normalize-space($entry//eag:country/text())
    where $country != ''
    group by $country
    order by $country
    return
        <div class="country-group">
            <h3>{ $country } <span class="text-muted text-small">({ count($entry) } archives)</span></h3>
            <div class="charter-list">
            {
                for $archive in $entry
                let $name := normalize-space($archive//eag:autform/text())
                let $tokens := tokenize(substring-after($archive/atom:id/text(), conf:param('atom-tag-name')), '/')[. != '']
                let $archive-key := $tokens[last()]
                let $fond-count := count(metadata:base-collection('fond', $archive-key, 'public')/atom:entry[.//ead:ead])
                order by $name
                return
                    <div class="charter-item">
                        <div class="charter-idno">
                            <a href="{ $archive-key }/archive">{ $name }</a>
                        </div>
                        <div class="charter-meta">
                            <span>{ $fond-count } fonds</span>
                        </div>
                    </div>
            }
            </div>
        </div>

let $total-archives := count($archives)
let $total-fonds := count(metadata:base-collection('fond', 'public')/atom:entry[.//ead:ead])

return
<div class="page-layout">
    <main>
        <h1>Archives &amp; Fonds</h1>
        <p class="text-muted">
            { $total-archives } archives with { $total-fonds } fonds available.
        </p>

        {
            if (count($countries) > 0) then
                $countries
            else
                <div class="card">
                    <div class="card-body text-center text-muted">
                        <p>No archives found in the database.</p>
                        <p class="text-small">Import archive data into /db/mom-data/metadata.archive.public/</p>
                    </div>
                </div>
        }
    </main>

    <aside class="sidebar">
        <div class="card">
            <div class="card-header">Quick Stats</div>
            <div class="card-body">
                <ul>
                    <li><span class="stat-value">{ $total-archives }</span> Archives</li>
                    <li><span class="stat-value">{ $total-fonds }</span> Fonds</li>
                </ul>
            </div>
        </div>
        <div class="card">
            <div class="card-header">Recently Added</div>
            <div class="card-body">
                <ul>
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
                        <li class="text-small">
                            <a href="{ $archive-key }/{ $fond-key }/fond">{ if ($name != '') then $name else $fond-key }</a>
                        </li>
                }
                </ul>
            </div>
        </div>
    </aside>
</div>
