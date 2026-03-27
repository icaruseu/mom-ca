xquery version "3.1";

(:~
 : Single charter page — dynamic XQuery version.
 : Shows charter details using cei2html.xsl transformation.
 :
 : URL patterns:
 :   /{archive}/{fond}/{charter}/charter  (fond context)
 :   /{collection}/{charter}/charter      (collection context)
 :)

declare namespace atom = "http://www.w3.org/2005/Atom";
declare namespace cei = "http://www.monasterium.net/NS/cei";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace eag = "http://www.archivgut-online.de/eag";
declare namespace xhtml = "http://www.w3.org/1999/xhtml";

import module namespace metadata = "http://www.monasterium.net/NS/metadata"
    at "/db/apps/mom-ca/modules/metadata/metadata.xqm";
import module namespace conf = "http://www.monasterium.net/NS/conf"
    at "/db/apps/mom-ca/modules/core/conf.xqm";

declare variable $local:app-root := "/db/apps/mom-ca";

(: Parse request path to determine context :)
let $request-path := request:get-parameter("request-path", "")
let $tokens := tokenize(replace($request-path, '^/+|/+$', ''), '/')[. != 'charter']
let $token-count := count($tokens)

(: Determine context: fond (3 tokens) or collection (2 tokens) :)
let $context := if ($token-count ge 3) then 'fond' else 'collection'

let $archive-key := if ($context = 'fond') then $tokens[1] else ()
let $fond-key := if ($context = 'fond') then $tokens[2] else ()
let $collection-key := if ($context = 'collection') then $tokens[1] else ()
let $charter-id := $tokens[last()]

(: Find the charter entry :)
let $charter-collection :=
    if ($context = 'fond') then
        metadata:base-collection('charter', ($archive-key, $fond-key), 'public')
    else
        metadata:base-collection('charter', $collection-key, 'public')

let $tag := conf:param('atom-tag-name')
let $charter-entry := $charter-collection/atom:entry[ends-with(atom:id, '/' || $charter-id)]
let $charter-entry := if (count($charter-entry) > 1) then $charter-entry[1] else $charter-entry

return
    if (empty($charter-entry)) then
        <div class="card" style="max-width: 600px; margin: var(--space-xxl) auto;">
            <div class="card-body text-center">
                <h2>Charter not found</h2>
                <p class="text-muted">No charter "{ $charter-id }" found.</p>
                <p class="text-small text-muted">Context: { $context }, Path: { $request-path }</p>
                <a href="fonds" class="btn">Back to Archives</a>
            </div>
        </div>
    else

let $cei := $charter-entry//cei:text

(: Extract metadata :)
let $idno := normalize-space($cei//cei:body/cei:idno)
let $date-text := normalize-space(($cei//cei:issued/cei:date/text(), $cei//cei:issued/cei:dateRange/text())[1])
let $date-value := ($cei//cei:issued/cei:date/@value/string(), $cei//cei:issued/cei:dateRange/@from/string())[1]
let $abstract := $cei//cei:abstract
let $tenor := $cei//cei:tenor
let $images := $cei//cei:graphic/@url/string()

(: Archive/Fond/Collection names for breadcrumb :)
let $archive-name :=
    if ($context = 'fond') then
        let $ae := (metadata:base-collection('archive', $archive-key, 'public')/atom:entry)[1]
        return normalize-space($ae//eag:autform)
    else ()
let $fond-name :=
    if ($context = 'fond') then
        let $fe := (metadata:base-collection('fond', ($archive-key, $fond-key), 'public')/atom:entry)[1]
        return normalize-space(($fe//ead:unittitle/text())[1])
    else ()
let $collection-name :=
    if ($context = 'collection') then
        let $ce := (metadata:base-collection('collection', $collection-key, 'public')/atom:entry)[1]
        return normalize-space(($ce//cei:titleStmt/cei:title)[1])
    else ()

(: CEI sections :)
let $issued-place := normalize-space($cei//cei:issued/cei:placeName)
let $diplomaticAnalysis := $cei//cei:diplomaticAnalysis
let $listBibl := $diplomaticAnalysis/cei:listBibl
let $listBiblEdition := $diplomaticAnalysis/cei:listBiblEdition
let $listBiblRegest := $diplomaticAnalysis/cei:listBiblRegest
let $listBiblFaksimile := $diplomaticAnalysis/cei:listBiblFaksimile
let $listBiblErw := $diplomaticAnalysis/cei:listBiblErw
let $witnessOrig := $cei//cei:witnessOrig
let $physicalDesc := $witnessOrig/cei:physicalDesc
let $traditioForm := $witnessOrig/cei:traditioForm
let $archIdentifier := $witnessOrig/cei:archIdentifier
let $auth := $witnessOrig/cei:auth
let $nota := $diplomaticAnalysis/cei:nota

return
<div>
    <!-- Breadcrumb -->
    <nav class="breadcrumb">
        <a href="fonds">Archives</a>
        {
            if ($context = 'fond') then (
                <span class="sep">/</span>,
                <a href="{ $archive-key }/archive">{ if ($archive-name != '') then $archive-name else $archive-key }</a>,
                <span class="sep">/</span>,
                <a href="{ $archive-key }/{ $fond-key }/fond">{ if ($fond-name != '') then $fond-name else $fond-key }</a>
            ) else (
                <span class="sep">/</span>,
                <a href="collections">Collections</a>,
                <span class="sep">/</span>,
                <a href="{ $collection-key }/collection">{ if ($collection-name != '') then $collection-name else $collection-key }</a>
            )
        }
        <span class="sep">/</span>
        <span>{ if ($idno != '') then $idno else $charter-id }</span>
    </nav>

    <div class="page-layout">
        <main>
            <!-- Charter Header -->
            <div class="card" style="margin-bottom: var(--space-lg);">
                <div class="card-body">
                    <h1 style="margin-bottom: var(--space-xs);">{ if ($idno != '') then $idno else $charter-id }</h1>
                    {
                        if ($date-text != '') then
                            <p style="font-family: var(--font-heading); font-size: 1.1rem; color: var(--color-text-muted); margin-bottom: var(--space-sm);">{ $date-text }</p>
                        else ()
                    }
                    {
                        if ($issued-place != '') then
                            <p class="text-muted">Issued at: { $issued-place }</p>
                        else ()
                    }
                </div>
            </div>

            <!-- Abstract / Regest -->
            {
                if (exists($abstract) and normalize-space($abstract) != '') then
                    <div class="card" style="margin-bottom: var(--space-lg);">
                        <div class="card-header">Abstract</div>
                        <div class="card-body">
                            <p>{ normalize-space(string-join($abstract//text(), ' ')) }</p>
                        </div>
                    </div>
                else ()
            }

            <!-- Tenor / Full Text -->
            {
                if (exists($tenor) and normalize-space($tenor) != '') then
                    <div class="card" style="margin-bottom: var(--space-lg);">
                        <div class="card-header">Tenor (Full Text)</div>
                        <div class="card-body" style="line-height: 1.8; font-size: 1.05rem;">
                            { serialize($tenor/node(), map { "method": "html" }) }
                        </div>
                    </div>
                else ()
            }

            <!-- Diplomatic Analysis -->
            {
                if (exists($diplomaticAnalysis) and (
                    normalize-space($listBibl) != '' or
                    normalize-space($listBiblEdition) != '' or
                    normalize-space($listBiblRegest) != '' or
                    normalize-space($nota) != ''
                )) then
                    <div class="card" style="margin-bottom: var(--space-lg);">
                        <div class="card-header">Diplomatic Analysis</div>
                        <div class="card-body">
                            {
                                if (normalize-space($listBiblEdition) != '') then
                                    <div style="margin-bottom: var(--space-md);">
                                        <h4>Editions</h4>
                                        <p>{ normalize-space(string-join($listBiblEdition//text(), ' ')) }</p>
                                    </div>
                                else ()
                            }
                            {
                                if (normalize-space($listBiblRegest) != '') then
                                    <div style="margin-bottom: var(--space-md);">
                                        <h4>Regesta</h4>
                                        <p>{ normalize-space(string-join($listBiblRegest//text(), ' ')) }</p>
                                    </div>
                                else ()
                            }
                            {
                                if (normalize-space($listBibl) != '') then
                                    <div style="margin-bottom: var(--space-md);">
                                        <h4>Bibliography</h4>
                                        <p>{ normalize-space(string-join($listBibl//text(), ' ')) }</p>
                                    </div>
                                else ()
                            }
                            {
                                if (normalize-space($listBiblFaksimile) != '') then
                                    <div style="margin-bottom: var(--space-md);">
                                        <h4>Facsimiles</h4>
                                        <p>{ normalize-space(string-join($listBiblFaksimile//text(), ' ')) }</p>
                                    </div>
                                else ()
                            }
                            {
                                if (normalize-space($listBiblErw) != '') then
                                    <div style="margin-bottom: var(--space-md);">
                                        <h4>References</h4>
                                        <p>{ normalize-space(string-join($listBiblErw//text(), ' ')) }</p>
                                    </div>
                                else ()
                            }
                            {
                                if (normalize-space($nota) != '') then
                                    <div>
                                        <h4>Notes</h4>
                                        <p>{ normalize-space(string-join($nota//text(), ' ')) }</p>
                                    </div>
                                else ()
                            }
                        </div>
                    </div>
                else ()
            }

            <!-- Physical Description -->
            {
                if (exists($witnessOrig) and (
                    normalize-space($physicalDesc) != '' or
                    normalize-space($traditioForm) != '' or
                    normalize-space($auth) != ''
                )) then
                    <div class="card" style="margin-bottom: var(--space-lg);">
                        <div class="card-header">Original Witness</div>
                        <div class="card-body">
                            <table>
                                {
                                    if (normalize-space($traditioForm) != '') then
                                        <tr><th>Tradition</th><td>{ normalize-space($traditioForm) }</td></tr>
                                    else ()
                                }
                                {
                                    if (normalize-space($archIdentifier) != '') then
                                        <tr><th>Archive</th><td>{ normalize-space(string-join($archIdentifier//text(), ' ')) }</td></tr>
                                    else ()
                                }
                                {
                                    if (normalize-space($auth) != '') then
                                        <tr><th>Authentication</th><td>{ normalize-space(string-join($auth//text(), ' ')) }</td></tr>
                                    else ()
                                }
                                {
                                    if (normalize-space($physicalDesc) != '') then
                                        <tr><th>Physical Description</th><td>{ normalize-space(string-join($physicalDesc//text(), ' ')) }</td></tr>
                                    else ()
                                }
                            </table>
                        </div>
                    </div>
                else ()
            }
        </main>

        <aside class="sidebar">
            <!-- Images -->
            {
                if (count($images) > 0) then
                    <div class="card">
                        <div class="card-header">Images ({ count($images) })</div>
                        <div class="card-body">
                            {
                                for $img-url at $pos in $images
                                return
                                    <div style="margin-bottom: var(--space-sm);">
                                        <a href="{ $img-url }" target="_blank" class="text-small">
                                            Image { $pos }
                                        </a>
                                    </div>
                            }
                        </div>
                    </div>
                else ()
            }

            <!-- Charter Info -->
            <div class="card">
                <div class="card-header">Charter Info</div>
                <div class="card-body">
                    <ul>
                        { if ($idno != '') then <li><strong>Signatur:</strong> { $idno }</li> else () }
                        { if ($date-text != '') then <li><strong>Date:</strong> { $date-text }</li> else () }
                        { if ($date-value != '') then <li><strong>Date (norm.):</strong> { $date-value }</li> else () }
                        { if ($issued-place != '') then <li><strong>Place:</strong> { $issued-place }</li> else () }
                        <li><strong>Images:</strong> { count($images) }</li>
                        <li><strong>Atom ID:</strong> <span class="text-small" style="word-break: break-all;">{ $charter-entry/atom:id/text() }</span></li>
                    </ul>
                </div>
            </div>

            <!-- Navigation -->
            <div class="card">
                <div class="card-header">Navigation</div>
                <div class="card-body">
                    {
                        if ($context = 'fond') then
                            <a href="{ $archive-key }/{ $fond-key }/fond" class="btn" style="width: 100%; justify-content: center;">
                                Back to Fond
                            </a>
                        else
                            <a href="{ $collection-key }/collection" class="btn" style="width: 100%; justify-content: center;">
                                Back to Collection
                            </a>
                    }
                </div>
            </div>
        </aside>
    </div>
</div>
