xquery version "3.1";

(:~
 : Single archive page — shows archive details and its fonds.
 :)

declare namespace atom = "http://www.w3.org/2005/Atom";

import module namespace metadata = "http://www.monasterium.net/NS/metadata"
    at "/db/apps/mom-ca/modules/metadata/metadata.xqm";
import module namespace conf = "http://www.monasterium.net/NS/conf"
    at "/db/apps/mom-ca/modules/core/conf.xqm";

let $request-path := request:get-parameter("request-path", "")
let $tokens := tokenize(replace($request-path, '^/+|/+$', ''), '/')[. ne 'archive']
let $archive-key := $tokens[1]

let $archive-coll := metadata:base-collection('archive', $archive-key, 'public')
let $archive-entry := ($archive-coll/atom:entry[.//*[local-name()='eag']])[1]

let $fond-coll := metadata:base-collection('fond', $archive-key, 'public')
let $fonds := $fond-coll/atom:entry[.//*[local-name()='ead']]

return
    if (empty($archive-entry)) then
        <div class="card" style="max-width: 600px; margin: var(--space-xxl) auto;">
            <div class="card-body text-center">
                <h2>Archive not found</h2>
                <p class="text-muted">No archive with key "{$archive-key}" found.</p>
                <p class="text-small text-muted">Path: {$request-path}</p>
                <a href="/mom/fonds" class="btn">Back to Archives</a>
            </div>
        </div>
    else

let $name := normalize-space(($archive-entry//*[local-name()='autform'])[1])
let $repoid := normalize-space(($archive-entry//*[local-name()='repositorid'])[1])
let $country := normalize-space(($archive-entry//*[local-name()='country'])[1])
let $address := normalize-space(($archive-entry//*[local-name()='street'])[1])
let $city := normalize-space(($archive-entry//*[local-name()='municipalityPostalcode'])[1])
let $phone := normalize-space(($archive-entry//*[local-name()='telephone'])[1])
let $email := normalize-space(($archive-entry//*[local-name()='email'])[1])
let $webpage := ($archive-entry//*[local-name()='webpage']/@href/string())[1]

let $fond-data :=
    for $fond in $fonds
    let $fond-name := normalize-space(($fond//*[local-name()='unittitle'])[1])
    let $fond-tokens := tokenize(substring-after($fond/atom:id/text(), conf:param('atom-tag-name')), '/')[. ne '']
    let $fond-key := $fond-tokens[last()]
    let $charter-count := count(metadata:base-collection('charter', ($archive-key, $fond-key), 'public')/atom:entry)
    order by $fond-name
    return map {
        "name": if ($fond-name ne '') then $fond-name else $fond-key,
        "key": $fond-key,
        "charters": $charter-count
    }

return
<div>
    <nav class="breadcrumb">
        <a href="/mom/fonds">Archives</a>
        <span class="sep">/</span>
        <span>{if ($name ne '') then $name else $archive-key}</span>
    </nav>

    <div class="page-layout">
        <main>
            <h1>{if ($name ne '') then $name else $archive-key}</h1>
            {if ($repoid ne '') then <p class="text-muted">{$repoid}</p> else ()}

            {
                if (count($fond-data) gt 0) then (
                    <h2>Fonds <span class="text-muted text-small">({count($fond-data)})</span></h2>,
                    <div class="charter-list">
                    {
                        for $f in $fond-data
                        return
                            <div class="charter-item">
                                <div class="charter-idno">
                                    <a href="/mom/{$archive-key}/{$f?key}/fond">{$f?name}</a>
                                </div>
                                <div class="charter-meta">
                                    <span>{$f?charters} charters</span>
                                </div>
                            </div>
                    }
                    </div>
                )
                else
                    <div class="card">
                        <div class="card-body text-muted">No fonds available for this archive.</div>
                    </div>
            }
        </main>

        <aside class="sidebar">
            <div class="card">
                <div class="card-header">Archive Details</div>
                <div class="card-body">
                    <ul>
                        {if ($repoid ne '') then <li><strong>ID:</strong> {$repoid}</li> else ()}
                        {if ($country ne '') then <li><strong>Country:</strong> {$country}</li> else ()}
                        {if ($city ne '') then <li><strong>City:</strong> {$city}</li> else ()}
                        {if ($address ne '') then <li><strong>Address:</strong> {$address}</li> else ()}
                        {if ($phone ne '') then <li><strong>Phone:</strong> {$phone}</li> else ()}
                        {if ($email ne '') then <li><strong>Email:</strong> <a href="mailto:{$email}">{$email}</a></li> else ()}
                        {if ($webpage ne '') then <li><strong>Website:</strong> <a href="{$webpage}" target="_blank">{$webpage}</a></li> else ()}
                    </ul>
                </div>
            </div>
            <div class="card">
                <div class="card-header">Statistics</div>
                <div class="card-body">
                    <ul>
                        <li><span class="stat-value">{count($fond-data)}</span> Fonds</li>
                    </ul>
                </div>
            </div>
            <div class="card">
                <div class="card-body">
                    <a href="/mom/fonds" class="btn" style="width: 100%; justify-content: center;">Back to Archives</a>
                </div>
            </div>
        </aside>
    </div>
</div>
