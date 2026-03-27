xquery version "3.1";

(:~
 : Single archive page — dynamic XQuery version.
 : Shows archive details and its fonds.
 :)

declare namespace atom = "http://www.w3.org/2005/Atom";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace eag = "http://www.archivgut-online.de/eag";

import module namespace metadata = "http://www.monasterium.net/NS/metadata"
    at "metadata/metadata.xqm";
import module namespace conf = "http://www.monasterium.net/NS/conf"
    at "core/conf.xqm";

let $request-path := request:get-parameter("request-path", "")
let $tokens := tokenize(replace($request-path, '^/+|/+$', ''), '/')
(: First meaningful token is the archive key :)
let $archive-key := $tokens[1]

let $archive-entry := (metadata:base-collection('archive', $archive-key, 'public')/atom:entry)[1]
let $fonds := metadata:base-collection('fond', $archive-key, 'public')/atom:entry[.//ead:ead]

return
    if (empty($archive-entry)) then
        <div class="card">
            <div class="card-body text-center">
                <h2>Archive not found</h2>
                <p class="text-muted">No archive with key "{ $archive-key }" found.</p>
                <a href="fonds" class="btn">Back to Archives</a>
            </div>
        </div>
    else

let $name := normalize-space($archive-entry//eag:autform/text())
let $country := normalize-space($archive-entry//eag:country/text())
let $address := normalize-space($archive-entry//eag:street/text())
let $city := normalize-space($archive-entry//eag:municipalityPostalcode/text())
let $phone := normalize-space($archive-entry//eag:telephone/text())
let $email := normalize-space($archive-entry//eag:email/text())
let $webpage := normalize-space($archive-entry//eag:webpage/@href)

return
<div>
    <nav class="breadcrumb">
        <a href="fonds">Archives</a>
        <span class="sep">/</span>
        <span>{ $name }</span>
    </nav>

    <div class="page-layout">
        <main>
            <h1>{ $name }</h1>

            {
                if (count($fonds) > 0) then
                    <div>
                        <h2>Fonds <span class="text-muted text-small">({ count($fonds) })</span></h2>
                        <div class="charter-list">
                        {
                            for $fond in $fonds
                            let $fond-name := normalize-space(($fond//ead:unittitle/text())[1])
                            let $fond-tokens := tokenize(substring-after($fond/atom:id/text(), conf:param('atom-tag-name')), '/')[. != '']
                            let $fond-key := $fond-tokens[last()]
                            let $charter-count := count(metadata:base-collection('charter', ($archive-key, $fond-key), 'public')/atom:entry)
                            order by $fond-name
                            return
                                <div class="charter-item">
                                    <div class="charter-idno">
                                        <a href="{ $archive-key }/{ $fond-key }/fond">
                                            { if ($fond-name != '') then $fond-name else $fond-key }
                                        </a>
                                    </div>
                                    <div class="charter-meta">
                                        <span>{ $charter-count } charters</span>
                                    </div>
                                </div>
                        }
                        </div>
                    </div>
                else
                    <div class="card">
                        <div class="card-body text-muted">
                            No fonds available for this archive.
                        </div>
                    </div>
            }
        </main>

        <aside class="sidebar">
            <div class="card">
                <div class="card-header">Archive Details</div>
                <div class="card-body">
                    <ul>
                        { if ($country != '') then <li><strong>Country:</strong> { $country }</li> else () }
                        { if ($address != '') then <li><strong>Address:</strong> { $address }</li> else () }
                        { if ($city != '') then <li><strong>City:</strong> { $city }</li> else () }
                        { if ($phone != '') then <li><strong>Phone:</strong> { $phone }</li> else () }
                        { if ($email != '') then <li><strong>Email:</strong> <a href="mailto:{ $email }">{ $email }</a></li> else () }
                        { if ($webpage != '') then <li><strong>Website:</strong> <a href="{ $webpage }" target="_blank">{ $webpage }</a></li> else () }
                    </ul>
                </div>
            </div>
            <div class="card">
                <div class="card-header">Statistics</div>
                <div class="card-body">
                    <ul>
                        <li><span class="stat-value">{ count($fonds) }</span> Fonds</li>
                    </ul>
                </div>
            </div>
        </aside>
    </div>
</div>
