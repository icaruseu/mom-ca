xquery version "3.1";

(:~
 : Single charter page with image viewer.
 : Loads preferences for image-server-base-url and displays charter images
 : using OpenSeadragon.
 :)

declare namespace atom = "http://www.w3.org/2005/Atom";
declare namespace cei = "http://www.monasterium.net/NS/cei";
declare namespace xrx = "http://www.monasterium.net/NS/xrx";

import module namespace metadata = "http://www.monasterium.net/NS/metadata"
    at "/db/apps/mom-ca/modules/metadata/metadata.xqm";
import module namespace conf = "http://www.monasterium.net/NS/conf"
    at "/db/apps/mom-ca/modules/core/conf.xqm";

(:~ Render mixed content with inline CEI annotations visible :)
declare function local:render-mixed($nodes as node()*) as node()* {
    for $node in $nodes
    return
        if ($node instance of text()) then $node
        else if ($node instance of element()) then
            let $name := local-name($node)
            let $known := ('persName','placeName','orgName','geogName','foreign','date','dateRange',
                           'num','measure','hi','sup','lb','index','issuer','recipient',
                           'invocatio','intitulatio','inscriptio','arenga','publicatio','narratio',
                           'dispositio','sanctio','corroboratio','datatio','subscriptio',
                           'expan','sic','corr','del','add','supplied','unclear','rolename','testis')
            let $reg := string($node/@reg)
            let $tooltip := if ($reg ne '') then $name || ': ' || $reg else $name
            return
                if ($name = $known) then
                    if ($name = 'lb') then
                        <br/>
                    else if ($name = 'sup') then
                        <sup title="sup">{local:render-mixed($node/node())}</sup>
                    else
                        <span class="cei-inline" title="{$tooltip}" data-cei="{$name}">{local:render-mixed($node/node())}</span>
                else
                    local:render-mixed($node/node())
        else ()
};

(: Parse URL tokens :)
let $request-path := request:get-parameter("request-path", "")
let $tokens := tokenize(replace($request-path, '^/+|/+$', ''), '/')[. ne 'charter']
let $token-count := count($tokens)

let $context := if ($token-count ge 3) then 'fond' else 'collection'
let $archive-key := if ($context = 'fond') then $tokens[1] else ()
let $fond-key := if ($context = 'fond') then $tokens[2] else ()
let $collection-key := if ($context = 'collection') then $tokens[1] else ()
let $charter-id := $tokens[last()]

(: Determine current user :)
let $session-user := try { string(session:get-attribute('mom.user')) } catch * { '' }
let $xquery-user := string(request:get-attribute('xquery.user'))
let $current-user := if ($session-user ne '') then $session-user
    else if ($xquery-user ne 'guest' and $xquery-user ne '') then $xquery-user else ''

(: Find the charter — public first, then user's private :)
let $charter-collection :=
    if ($context = 'fond') then
        metadata:base-collection('charter', ($archive-key, $fond-key), 'public')
    else
        metadata:base-collection('charter', $collection-key, 'public')

let $charter-entry := ($charter-collection/atom:entry[ends-with(atom:id, '/' || $charter-id)])[1]

let $is-private := empty($charter-entry) and $current-user ne '' and $context = 'collection'
let $charter-entry :=
    if ($is-private) then
        let $priv-path := '/db/mom-data/xrx.user/' || $current-user || '/metadata.charter/' || $collection-key
        return
            if (xmldb:collection-available($priv-path)) then
                (collection($priv-path)/atom:entry[ends-with(atom:id, '/' || $charter-id)])[1]
            else ()
    else $charter-entry

return
    if (empty($charter-entry)) then
        <div class="card" style="max-width: 600px; margin: var(--space-xxl) auto;">
            <div class="card-body text-center">
                <h2>Charter not found</h2>
                <p class="text-muted">"{$charter-id}" not found.</p>
                <a href="/mom/fonds" class="btn">Back to Archives</a>
            </div>
        </div>
    else

let $cei := $charter-entry//cei:text

(: Prev/Next navigation within the same fond/collection :)
let $sibling-collection :=
    if ($is-private) then
        collection('/db/mom-data/xrx.user/' || $current-user || '/metadata.charter/' || $collection-key)
    else $charter-collection
let $all-siblings :=
    for $e in $sibling-collection/atom:entry
    let $d := ($e//cei:issued/cei:date/@value/string(), $e//cei:issued/cei:dateRange/@from/string(), '99999999')[1]
    order by $d
    return $e
let $current-pos := for $e at $p in $all-siblings
    where $e/atom:id = $charter-entry/atom:id
    return $p
let $current-pos := $current-pos[1]
let $prev-entry := if ($current-pos gt 1) then $all-siblings[$current-pos - 1] else ()
let $next-entry := if ($current-pos lt count($all-siblings)) then $all-siblings[$current-pos + 1] else ()
let $tag := conf:param('atom-tag-name')
let $prev-id := if (exists($prev-entry)) then tokenize(substring-after($prev-entry/atom:id, $tag), '/')[last()] else ''
let $next-id := if (exists($next-entry)) then tokenize(substring-after($next-entry/atom:id, $tag), '/')[last()] else ''
let $prev-url := if ($prev-id ne '') then
    if ($context = 'fond') then '/mom/' || $archive-key || '/' || $fond-key || '/' || xmldb:encode($prev-id) || '/charter'
    else '/mom/' || $collection-key || '/' || xmldb:encode($prev-id) || '/charter'
else ''
let $next-url := if ($next-id ne '') then
    if ($context = 'fond') then '/mom/' || $archive-key || '/' || $fond-key || '/' || xmldb:encode($next-id) || '/charter'
    else '/mom/' || $collection-key || '/' || xmldb:encode($next-id) || '/charter'
else ''

(: Metadata :)
let $idno := normalize-space($cei//cei:body/cei:idno)
let $date-text := normalize-space(($cei//cei:issued/cei:date/text(), $cei//cei:issued/cei:dateRange/text())[1])
let $date-value := ($cei//cei:issued/cei:date/@value/string(), $cei//cei:issued/cei:dateRange/@from/string())[1]
let $abstract := $cei//cei:abstract
let $tenor := $cei//cei:tenor
let $issued-place := normalize-space($cei//cei:issued/cei:placeName)
let $images := $cei//cei:graphic/@url/string()

(: Load fond preferences for image-server-base-url :)
let $prefs-path :=
    if ($context = 'fond') then
        concat('/db/mom-data/metadata.fond.public/', $archive-key, '/', $fond-key, '/', $fond-key, '.preferences.xml')
    else
        concat('/db/mom-data/metadata.collection.public/', $collection-key, '/', $collection-key, '.preferences.xml')

let $prefs := if (doc-available($prefs-path)) then doc($prefs-path) else ()
let $image-base-url := normalize-space($prefs//xrx:param[@name='image-server-base-url'])
let $image-access := normalize-space($prefs//xrx:param[@name='image-access'])

(: Build full image URLs :)
let $image-urls :=
    for $img in $images
    return
        if ($image-base-url ne '') then
            let $base := replace($image-base-url, 'http://', 'https://')
            return $base || '/' || $img
        else $img

(: Breadcrumb names :)
let $archive-name :=
    if ($context = 'fond') then
        normalize-space((metadata:base-collection('archive', $archive-key, 'public')/atom:entry[.//*[local-name()='eag']])[1]//*[local-name()='autform'])
    else ()
let $fond-name :=
    if ($context = 'fond') then
        normalize-space((metadata:base-collection('fond', ($archive-key, $fond-key), 'public')/atom:entry[.//*[local-name()='ead']])[1]//*[local-name()='unittitle'])
    else ()

(: Diplomatic analysis :)
let $da := $cei//cei:diplomaticAnalysis
let $witnessOrig := $cei//cei:witnessOrig

return
<div>
    <nav class="breadcrumb">
        {if ($is-private) then
            <a href="/mom/my-collections">My Collections</a>
        else
            <a href="/mom/fonds">Archives</a>
        }
        {
            if ($context = 'fond') then (
                <span class="sep">/</span>,
                <a href="/mom/{$archive-key}/archive">{if ($archive-name ne '') then $archive-name else $archive-key}</a>,
                <span class="sep">/</span>,
                <a href="/mom/{$archive-key}/{$fond-key}/fond">{if ($fond-name ne '') then $fond-name else $fond-key}</a>
            ) else (
                <span class="sep">/</span>,
                <a href="/mom/{$collection-key}/collection">{$collection-key}</a>
            )
        }
        <span class="sep">/</span>
        <span>{if ($idno ne '') then $idno else $charter-id}</span>
    </nav>

    <!-- Prev/Next Navigation -->
    {if ($prev-url ne '' or $next-url ne '') then
        <nav class="charter-nav" style="display:flex; justify-content:space-between; align-items:center; margin-bottom:var(--space-md);">
            {if ($prev-url ne '') then
                <a href="{$prev-url}" style="display:flex; align-items:center; gap:6px; text-decoration:none; color:var(--color-text-muted); font-size:0.9rem;">
                    <span>&#x2190;</span>
                    <span>Previous charter</span>
                </a>
            else <span/>}
            {if (exists($current-pos)) then
                <span class="text-small text-muted">{$current-pos} of {count($all-siblings)}</span>
            else ()}
            {if ($next-url ne '') then
                <a href="{$next-url}" style="display:flex; align-items:center; gap:6px; text-decoration:none; color:var(--color-text-muted); font-size:0.9rem;">
                    <span>Next charter</span>
                    <span>&#x2192;</span>
                </a>
            else <span/>}
        </nav>
    else ()}

    <!-- Charter Header -->
    <div class="card" style="margin-bottom: var(--space-lg);">
        <div class="card-body">
            <h1 style="margin-bottom: var(--space-xs);">{if ($idno ne '') then $idno else $charter-id}</h1>
            {if ($date-text ne '') then
                <p style="font-family: var(--font-heading); font-size: 1.1rem; color: var(--color-text-muted);">{$date-text}</p>
            else ()}
            {if ($issued-place ne '') then
                <p class="text-muted">Issued at: {$issued-place}</p>
            else ()}
        </div>
    </div>

    <!-- Image Viewer -->
    {
        if (count($image-urls) gt 0 and ($image-access = 'free' or $image-access = '')) then
            <details class="card" style="margin-bottom: var(--space-lg);" open="open">
                <summary class="card-header" style="display: flex; justify-content: space-between; align-items: center; cursor: pointer; user-select: none;">
                    <span>&#x1F4F7; Images ({count($image-urls)}) <span class="text-small text-muted">&#x2014; click to collapse</span></span>
                    <div id="image-nav" style="display: flex; gap: var(--space-xs);">
                        {
                            for $url at $pos in $image-urls
                            let $label := if (ends-with($url, '_r.jpg') or ends-with($url, '_r.png')) then 'recto'
                                         else if (ends-with($url, '_v.jpg') or ends-with($url, '_v.png')) then 'verso'
                                         else 'Image ' || $pos
                            return
                                <button class="btn{if ($pos = 1) then ' btn--primary' else ''}" onclick="event.stopPropagation(); switchImage({$pos - 1})" style="font-size: 0.8rem; padding: 4px 12px;">{$label}</button>
                        }
                    </div>
                </summary>
                <div class="card-body" style="padding: 0;">
                    <div id="openseadragon-viewer" style="width: 100%; height: 600px; background: #1a1a1a;"></div>
                </div>
            </details>
        else if (count($images) gt 0 and $image-access ne 'free') then
            <div class="card" style="margin-bottom: var(--space-lg);">
                <div class="card-header">Images</div>
                <div class="card-body text-center text-muted">
                    <p>Image access is restricted for this fond.</p>
                </div>
            </div>
        else ()
    }

    <div class="page-layout">
        <main>
            <!-- Abstract -->
            {
                if (exists($abstract) and normalize-space($abstract) ne '') then
                    <div class="card" style="margin-bottom: var(--space-lg);">
                        <div class="card-header">Abstract</div>
                        <div class="card-body" style="line-height:1.8;">
                            <p>{local:render-mixed($abstract/node())}</p>
                        </div>
                    </div>
                else ()
            }

            <!-- Tenor -->
            {
                if (exists($tenor) and normalize-space($tenor) ne '') then
                    <div class="card" style="margin-bottom: var(--space-lg);">
                        <div class="card-header">Full Text (Tenor)</div>
                        <div class="card-body" style="line-height: 1.8; font-size: 1.05rem;">
                            {local:render-mixed($tenor/node())}
                        </div>
                    </div>
                else ()
            }

            <!-- Diplomatic Analysis -->
            {
                let $listBiblEdition := normalize-space($da/cei:listBiblEdition)
                let $listBiblRegest := normalize-space($da/cei:listBiblRegest)
                let $listBibl := normalize-space($da/cei:listBibl)
                let $listBiblFaksimile := normalize-space($da/cei:listBiblFaksimile)
                let $listBiblErw := normalize-space($da/cei:listBiblErw)
                let $nota := normalize-space($da/cei:nota)
                return
                    if ($listBiblEdition ne '' or $listBiblRegest ne '' or $listBibl ne '' or $nota ne '') then
                        <div class="card" style="margin-bottom: var(--space-lg);">
                            <div class="card-header">Diplomatic Analysis</div>
                            <div class="card-body">
                                {if ($listBiblEdition ne '') then <div style="margin-bottom: var(--space-md);"><h4>Editions</h4><p>{$listBiblEdition}</p></div> else ()}
                                {if ($listBiblRegest ne '') then <div style="margin-bottom: var(--space-md);"><h4>Regesta</h4><p>{$listBiblRegest}</p></div> else ()}
                                {if ($listBibl ne '') then <div style="margin-bottom: var(--space-md);"><h4>Bibliography</h4><p>{$listBibl}</p></div> else ()}
                                {if ($listBiblFaksimile ne '') then <div style="margin-bottom: var(--space-md);"><h4>Facsimiles</h4><p>{$listBiblFaksimile}</p></div> else ()}
                                {if ($listBiblErw ne '') then <div style="margin-bottom: var(--space-md);"><h4>References</h4><p>{$listBiblErw}</p></div> else ()}
                                {if ($nota ne '') then <div><h4>Notes</h4><p>{$nota}</p></div> else ()}
                            </div>
                        </div>
                    else ()
            }

            <!-- Physical Description -->
            {
                let $traditioForm := normalize-space($witnessOrig/cei:traditioForm)
                let $archId := normalize-space(string-join($witnessOrig/cei:archIdentifier//text(), ' '))
                let $auth := normalize-space(string-join($witnessOrig/cei:auth//text(), ' '))
                let $physDesc := normalize-space(string-join($witnessOrig/cei:physicalDesc//text(), ' '))
                return
                    if ($traditioForm ne '' or $archId ne '' or $auth ne '' or $physDesc ne '') then
                        <div class="card" style="margin-bottom: var(--space-lg);">
                            <div class="card-header">Original Witness</div>
                            <div class="card-body">
                                <table>
                                    {if ($traditioForm ne '') then <tr><th>Tradition</th><td>{$traditioForm}</td></tr> else ()}
                                    {if ($archId ne '') then <tr><th>Archive</th><td>{$archId}</td></tr> else ()}
                                    {if ($auth ne '') then <tr><th>Authentication</th><td>{$auth}</td></tr> else ()}
                                    {if ($physDesc ne '') then <tr><th>Physical Desc.</th><td>{$physDesc}</td></tr> else ()}
                                </table>
                            </div>
                        </div>
                    else ()
            }
        </main>

        <aside class="sidebar">
            <div class="card">
                <div class="card-header">Charter Info</div>
                <div class="card-body">
                    <ul>
                        {if ($idno ne '') then <li><strong>Signatur:</strong> {$idno}</li> else ()}
                        {if ($date-text ne '') then <li><strong>Date:</strong> {$date-text}</li> else ()}
                        {if ($date-value ne '') then <li><strong>Normalized:</strong> {$date-value}</li> else ()}
                        {if ($issued-place ne '') then <li><strong>Place:</strong> {$issued-place}</li> else ()}
                        <li><strong>Images:</strong> {count($images)}</li>
                    </ul>
                </div>
            </div>
            {
                if (count($image-urls) gt 0) then
                    <div class="card">
                        <div class="card-header">Image Files</div>
                        <div class="card-body">
                            <ul>
                            {
                                for $url at $pos in $image-urls
                                let $filename := tokenize($url, '/')[last()]
                                return <li class="text-small"><a href="{$url}" target="_blank">{$filename}</a></li>
                            }
                            </ul>
                        </div>
                    </div>
                else ()
            }
            {
                if (not($is-private) and $current-user ne '') then
                    let $charter-atom-id := $charter-entry/atom:id/text()
                    let $lock-path := '/db/mom-data/charter-locks'
                    let $lock-doc := collection($lock-path)//*[local-name()='lock'][*[local-name()='charter-id'] = $charter-atom-id]
                    let $locked-by := string($lock-doc/*[local-name()='user'])
                    let $private-id := string($lock-doc/*[local-name()='private-id'])
                    return
                        if ($locked-by ne '' and $locked-by ne $current-user) then
                            <div class="card">
                                <div class="card-header">Actions</div>
                                <div class="card-body">
                                    <p style="color: var(--color-warning, #e67e22); font-weight: 600;">&#x1F512; Locked by {$locked-by}</p>
                                    <p class="text-muted text-small">This charter is being edited and cannot be saved to your collection right now.</p>
                                </div>
                            </div>
                        else if ($locked-by = $current-user) then
                            let $tag := conf:param('atom-tag-name')
                            let $priv-tokens := tokenize(substring-after($private-id, $tag), '/')[. ne '']
                            let $priv-coll := $priv-tokens[2]
                            let $priv-id := $priv-tokens[last()]
                            return
                            <div class="card">
                                <div class="card-header">Actions</div>
                                <div class="card-body">
                                    <p style="color: var(--color-success, #27ae60); font-weight: 600;">&#x2705; You have a private copy</p>
                                    <a href="/mom/{$priv-coll}/{$priv-id}/charter" class="btn btn--primary" style="width:100%;justify-content:center;">Go to Private Copy</a>
                                </div>
                            </div>
                        else
                    let $mycoll-path := '/db/mom-data/xrx.user/' || $current-user || '/metadata.mycollection'
                    let $my-colls :=
                        if (xmldb:collection-available($mycoll-path)) then
                            for $e in collection($mycoll-path)/atom:entry
                            let $cid := tokenize($e/atom:id/text(), '/')[last()]
                            let $ctitle := normalize-space(($e//cei:titleStmt/cei:title, $e//cei:title)[1])
                            return map { "id": $cid, "title": if ($ctitle ne '') then $ctitle else $cid }
                        else ()
                    return
                    <div class="card">
                        <div class="card-header">Actions</div>
                        <div class="card-body">
                            {if (exists($my-colls)) then
                                <form method="POST" action="/mom/save-charter">
                                    <input type="hidden" name="charter-id" value="{$charter-atom-id}" />
                                    <select name="collection-id" style="width:100%; padding:6px 8px; margin-bottom:8px; border:1px solid var(--color-border); border-radius:4px;">
                                        {for $c in $my-colls return
                                            <option value="{$c?id}">{$c?title}</option>
                                        }
                                    </select>
                                    <button type="submit" class="btn btn--primary" style="width:100%;justify-content:center;">Save to My Collection</button>
                                </form>
                            else
                                <p class="text-muted text-small">No collections yet.</p>
                            }
                        </div>
                    </div>
                else ()
            }
            {if ($is-private and $current-user ne '') then
                <div class="card">
                    <div class="card-body">
                        <a href="/mom/{$collection-key}/{$charter-id}/edit-charter" class="btn btn--primary" style="width:100%;justify-content:center;">Edit Charter</a>
                    </div>
                </div>
            else ()}
            <div class="card">
                <div class="card-body">
                    {
                        if ($context = 'fond') then
                            <a href="/mom/{$archive-key}/{$fond-key}/fond" class="btn" style="width:100%;justify-content:center;">Back to Fond</a>
                        else if ($is-private) then
                            <a href="/mom/{$collection-key}/collection" class="btn" style="width:100%;justify-content:center;">Back to My Collection</a>
                        else
                            <a href="/mom/{$collection-key}/collection" class="btn" style="width:100%;justify-content:center;">Back to Collection</a>
                    }
                </div>
            </div>
        </aside>
    </div>

    <!-- OpenSeadragon -->
    {
        if (count($image-urls) gt 0 and ($image-access = 'free' or $image-access = '')) then
            <script src="https://cdn.jsdelivr.net/npm/openseadragon@4.1/build/openseadragon/openseadragon.min.js">&#160;</script>
        else ()
    }
    {
        if (count($image-urls) gt 0 and ($image-access = 'free' or $image-access = '')) then
            <script>
                var imageUrls = [{
                    string-join(
                        for $url in $image-urls
                        return concat('"', $url, '"'),
                        ','
                    )
                }];
                var viewer = OpenSeadragon({{
                    id: "openseadragon-viewer",
                    prefixUrl: "https://cdn.jsdelivr.net/npm/openseadragon@4.1/build/openseadragon/images/",
                    tileSources: {{
                        type: "image",
                        url: imageUrls[0]
                    }},
                    showNavigator: true,
                    navigatorPosition: "BOTTOM_RIGHT",
                    navigatorSizeRatio: 0.15,
                    animationTime: 0.5,
                    minZoomLevel: 0.5,
                    maxZoomLevel: 10,
                    visibilityRatio: 0.8,
                    constrainDuringPan: true
                }});
                function switchImage(index) {{
                    viewer.open({{ type: "image", url: imageUrls[index] }});
                    document.querySelectorAll('#image-nav button').forEach(function(btn, i) {{
                        btn.className = i === index ? 'btn btn--primary' : 'btn';
                    }});
                }}
            </script>
        else ()
    }
</div>
