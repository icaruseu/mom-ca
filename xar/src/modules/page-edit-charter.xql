xquery version "3.1";

(:~
 : Charter editor page.
 : GET  — renders the editor form for a private charter.
 : POST — saves the edited charter back to the user's private collection.
 :)

declare namespace atom = "http://www.w3.org/2005/Atom";
declare namespace cei  = "http://www.monasterium.net/NS/cei";
declare namespace app  = "http://www.w3.org/2007/app";

import module namespace conf = "http://www.monasterium.net/NS/conf"
    at "/db/apps/mom-ca/modules/core/conf.xqm";

(:~
 : Convert CEI inline elements to HTML spans with data attributes.
 :)
declare function local:cei-to-html($nodes as node()*) as node()* {
    for $node in $nodes
    return
        if ($node instance of text()) then $node
        else if ($node instance of element()) then
            let $name := local-name($node)
            let $known := ('persName','placeName','orgName','geogName','foreign','date','dateRange',
                           'num','measure','hi','sup','lb','index','issuer','recipient',
                           'invocatio','intitulatio','inscriptio','arenga','publicatio','narratio',
                           'dispositio','sanctio','corroboratio','datatio','subscriptio',
                           'expan','sic','corr','del','add','supplied','unclear','note','bibl','pTenor')
            return
                if ($name = $known) then
                    <span class="cei-anno" data-cei="{$name}">{
                        for $attr in $node/@*
                        where not(starts-with(name($attr), 'xmlns'))
                        return attribute { concat('data-', local-name($attr)) } { string($attr) },
                        if ($name = 'lb') then text { '&#x23CE;' }
                        else local:cei-to-html($node/node())
                    }</span>
                else
                    local:cei-to-html($node/node())
        else ()
};

(: ---- Determine current user ---- :)
let $session-user := try { string(session:get-attribute('mom.user')) } catch * { '' }
let $xquery-user  := string(request:get-attribute('xquery.user'))
let $user := if ($session-user ne '') then $session-user
    else if ($xquery-user ne 'guest' and $xquery-user ne '') then $xquery-user else ''

return
    if ($user = '') then
        <div class="card" style="max-width:600px;margin:var(--space-xxl) auto;">
            <div class="card-body text-center">
                <h2>Login Required</h2>
                <p class="text-muted">Please log in to edit charters.</p>
                <a href="/mom/login" class="btn btn--primary">Login</a>
            </div>
        </div>
    else

(: ---- Parse URL tokens ---- :)
let $request-path := request:get-parameter("request-path", "")
let $tokens := tokenize(replace($request-path, '^/+|/+$', ''), '/')[. ne 'edit-charter']
let $collection-key := $tokens[1]
let $charter-key    := $tokens[2]

(: ---- Find private charter ---- :)
let $priv-path := '/db/mom-data/xrx.user/' || $user || '/metadata.charter/' || $collection-key
let $charter-entry :=
    if (xmldb:collection-available($priv-path)) then
        (collection($priv-path)/atom:entry[ends-with(atom:id, '/' || $charter-key)])[1]
    else ()

return
    if (empty($charter-entry)) then
        <div class="card" style="max-width:600px;margin:var(--space-xxl) auto;">
            <div class="card-body text-center">
                <h2>Charter not found</h2>
                <p class="text-muted">No private charter "{$charter-key}" found in collection "{$collection-key}".</p>
                <a href="/mom/my-collections" class="btn">Back to My Collections</a>
            </div>
        </div>
    else

(: ---- POST: save charter ---- :)
if (request:get-method() = 'POST') then
    let $abstract-raw := request:get-parameter('abstract', '')
    let $tenor-raw    := request:get-parameter('tenor', '')
    let $date-value   := request:get-parameter('date-value', '')
    let $date-text    := request:get-parameter('date-text', '')
    let $place        := request:get-parameter('place', '')

    let $source-bibl-regest   := request:get-parameter('source-bibl-regest', '')
    let $source-bibl-volltext := request:get-parameter('source-bibl-volltext', '')

    let $traditioForm   := request:get-parameter('traditioForm', '')
    let $archIdentifier := request:get-parameter('archIdentifier', '')
    let $physicalDesc   := request:get-parameter('physicalDesc', '')
    let $sealDesc       := request:get-parameter('sealDesc', '')

    let $witListPar := request:get-parameter('witListPar', '')

    let $listBiblEdition   := request:get-parameter('listBiblEdition', '')
    let $listBiblRegest    := request:get-parameter('listBiblRegest', '')
    let $listBibl          := request:get-parameter('listBibl', '')
    let $listBiblFaksimile := request:get-parameter('listBiblFaksimile', '')
    let $listBiblErw       := request:get-parameter('listBiblErw', '')
    let $quoteOrig         := request:get-parameter('quoteOriginaldatierung', '')
    let $nota              := request:get-parameter('nota', '')
    let $langMOM           := request:get-parameter('lang_MOM', '')

    let $pn-texts := request:get-parameter('back-persName-text[]', ())
    let $pn-regs  := request:get-parameter('back-persName-reg[]', ())
    let $pl-texts := request:get-parameter('back-placeName-text[]', ())
    let $pl-regs  := request:get-parameter('back-placeName-reg[]', ())
    let $pl-types := request:get-parameter('back-placeName-type[]', ())
    let $gn-texts := request:get-parameter('back-geogName-text[]', ())
    let $gn-regs  := request:get-parameter('back-geogName-reg[]', ())

    (: Parse mixed-content fields with error handling :)
    let $abstract-xml := if ($abstract-raw ne '') then
        try {
            parse-xml('<cei:abstract xmlns:cei="http://www.monasterium.net/NS/cei">' || $abstract-raw || '</cei:abstract>')/*
        } catch * {
            <cei:abstract xmlns:cei="http://www.monasterium.net/NS/cei">{$abstract-raw}</cei:abstract>
        }
    else <cei:abstract xmlns:cei="http://www.monasterium.net/NS/cei"/>

    let $tenor-xml := if ($tenor-raw ne '') then
        try {
            parse-xml('<cei:tenor xmlns:cei="http://www.monasterium.net/NS/cei">' || $tenor-raw || '</cei:tenor>')/*
        } catch * {
            <cei:tenor xmlns:cei="http://www.monasterium.net/NS/cei">{$tenor-raw}</cei:tenor>
        }
    else ()

    (: Preserve original identifiers :)
    let $orig-id        := $charter-entry/atom:id/text()
    let $orig-published := $charter-entry/atom:published/text()
    let $orig-idno      := normalize-space($charter-entry//cei:body/cei:idno)
    let $orig-sameAs    := $charter-entry//cei:text/@sameAs/string()

    (: Build back index :)
    let $back-persNames :=
        for $t at $i in $pn-texts
        where normalize-space($t) ne ''
        return
            <cei:persName xmlns:cei="http://www.monasterium.net/NS/cei">{
                if (exists($pn-regs[$i]) and normalize-space($pn-regs[$i]) ne '') then
                    attribute reg { $pn-regs[$i] }
                else (),
                $t
            }</cei:persName>

    let $back-placeNames :=
        for $t at $i in $pl-texts
        where normalize-space($t) ne ''
        return
            <cei:placeName xmlns:cei="http://www.monasterium.net/NS/cei">{
                if (exists($pl-regs[$i]) and normalize-space($pl-regs[$i]) ne '') then
                    attribute reg { $pl-regs[$i] }
                else (),
                if (exists($pl-types[$i]) and normalize-space($pl-types[$i]) ne '') then
                    attribute type { $pl-types[$i] }
                else (),
                $t
            }</cei:placeName>

    let $back-geogNames :=
        for $t at $i in $gn-texts
        where normalize-space($t) ne ''
        return
            <cei:geogName xmlns:cei="http://www.monasterium.net/NS/cei">{
                if (exists($gn-regs[$i]) and normalize-space($gn-regs[$i]) ne '') then
                    attribute reg { $gn-regs[$i] }
                else (),
                $t
            }</cei:geogName>

    (: Build new atom:entry :)
    let $new-entry :=
        <atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
            <atom:id>{$orig-id}</atom:id>
            <atom:title/>
            <atom:published>{$orig-published}</atom:published>
            <atom:updated>{current-dateTime()}</atom:updated>
            <atom:author><atom:email>{$user}</atom:email></atom:author>
            <app:control xmlns:app="http://www.w3.org/2007/app">
                <app:draft>yes</app:draft>
            </app:control>
            <atom:content type="application/xml">
                <cei:text xmlns:cei="http://www.monasterium.net/NS/cei" type="charter">{
                    if ($orig-sameAs ne '') then attribute sameAs { $orig-sameAs } else ()
                }
                    <cei:front>
                        <cei:sourceDesc>{
                            if ($source-bibl-regest ne '') then
                                <cei:sourceDescRegest><cei:bibl>{$source-bibl-regest}</cei:bibl></cei:sourceDescRegest>
                            else (),
                            if ($source-bibl-volltext ne '') then
                                <cei:sourceDescVolltext><cei:bibl>{$source-bibl-volltext}</cei:bibl></cei:sourceDescVolltext>
                            else ()
                        }</cei:sourceDesc>
                    </cei:front>
                    <cei:body>
                        <cei:idno>{$orig-idno}</cei:idno>
                        <cei:chDesc>
                            {$abstract-xml}
                            <cei:issued>
                                <cei:placeName>{$place}</cei:placeName>
                                <cei:date value="{$date-value}">{$date-text}</cei:date>
                            </cei:issued>
                            <cei:witnessOrig>
                                <cei:traditioForm>{$traditioForm}</cei:traditioForm>
                                <cei:archIdentifier>{$archIdentifier}</cei:archIdentifier>
                                <cei:physicalDesc>{$physicalDesc}</cei:physicalDesc>
                                <cei:auth>
                                    <cei:sealDesc>{$sealDesc}</cei:sealDesc>
                                </cei:auth>
                            </cei:witnessOrig>
                            <cei:witListPar>{$witListPar}</cei:witListPar>
                            <cei:diplomaticAnalysis>
                                <cei:listBiblEdition>{$listBiblEdition}</cei:listBiblEdition>
                                <cei:listBiblRegest>{$listBiblRegest}</cei:listBiblRegest>
                                <cei:listBibl>{$listBibl}</cei:listBibl>
                                <cei:listBiblFaksimile>{$listBiblFaksimile}</cei:listBiblFaksimile>
                                <cei:listBiblErw>{$listBiblErw}</cei:listBiblErw>
                                <cei:quoteOriginaldatierung>{$quoteOrig}</cei:quoteOriginaldatierung>
                                <cei:nota>{$nota}</cei:nota>
                            </cei:diplomaticAnalysis>
                            <cei:lang_MOM>{$langMOM}</cei:lang_MOM>
                        </cei:chDesc>
                        {$tenor-xml}
                    </cei:body>
                    <cei:back>{
                        $back-persNames,
                        $back-placeNames,
                        $back-geogNames
                    }</cei:back>
                </cei:text>
            </atom:content>
        </atom:entry>

    (: Store — find the document path and overwrite :)
    let $doc-uri  := document-uri(root($charter-entry))
    let $doc-coll := replace($doc-uri, '/[^/]+$', '')
    let $doc-name := replace($doc-uri, '^.*/', '')
    let $_ := xmldb:store($doc-coll, $doc-name, $new-entry)
    let $_ := response:redirect-to(xs:anyURI('/mom/' || $collection-key || '/' || $charter-key || '/charter'))
    return ()

(: ---- GET: render editor form ---- :)
else

let $cei := $charter-entry//cei:text

(: Extract data :)
let $idno        := normalize-space($cei//cei:body/cei:idno)
let $date-value  := $cei//cei:issued/cei:date/@value/string()
let $date-text   := normalize-space($cei//cei:issued/cei:date/text())
let $place       := normalize-space($cei//cei:issued/cei:placeName)
let $abstract    := $cei//cei:body/cei:chDesc/cei:abstract
let $tenor       := $cei//cei:body/cei:tenor

let $source-bibl-regest   := normalize-space($cei//cei:front//cei:sourceDescRegest/cei:bibl)
let $source-bibl-volltext := normalize-space($cei//cei:front//cei:sourceDescVolltext/cei:bibl)

let $traditioForm  := normalize-space($cei//cei:witnessOrig/cei:traditioForm)
let $archIdentifier := normalize-space(string-join($cei//cei:witnessOrig/cei:archIdentifier//text(), ' '))
let $physicalDesc  := normalize-space(string-join($cei//cei:witnessOrig/cei:physicalDesc//text(), ' '))
let $sealDesc      := normalize-space(string-join($cei//cei:witnessOrig/cei:auth/cei:sealDesc//text(), ' '))

let $witListPar := normalize-space(string-join($cei//cei:witListPar//text(), ' '))

let $listBiblEdition   := normalize-space($cei//cei:diplomaticAnalysis/cei:listBiblEdition)
let $listBiblRegest    := normalize-space($cei//cei:diplomaticAnalysis/cei:listBiblRegest)
let $listBibl          := normalize-space($cei//cei:diplomaticAnalysis/cei:listBibl)
let $listBiblFaksimile := normalize-space($cei//cei:diplomaticAnalysis/cei:listBiblFaksimile)
let $listBiblErw       := normalize-space($cei//cei:diplomaticAnalysis/cei:listBiblErw)
let $nota              := normalize-space(string-join($cei//cei:diplomaticAnalysis/cei:nota//text(), ' '))
let $quoteOrig         := normalize-space(string-join($cei//cei:quoteOriginaldatierung//text(), ' '))
let $langMOM           := normalize-space($cei//cei:lang_MOM)

let $back-persNames  := $cei//cei:back/cei:persName
let $back-placeNames := $cei//cei:back/cei:placeName
let $back-geogNames  := $cei//cei:back/cei:geogName

return
<div>
    <nav class="breadcrumb">
        <a href="/mom/my-collections">My Collections</a>
        <span class="sep">/</span>
        <a href="/mom/{$collection-key}/collection">{$collection-key}</a>
        <span class="sep">/</span>
        <span>Edit: {if ($idno ne '') then $idno else $charter-key}</span>
    </nav>

    <link rel="stylesheet" href="/mom/css/charter-editor.css"/>

    <form method="POST" action="/mom/{$collection-key}/{$charter-key}/edit-charter">

        <!-- Tab buttons -->
        <div class="editor-tabs">
            <button type="button" class="editor-tab-btn active" data-tab="abstract">Abstract</button>
            <button type="button" class="editor-tab-btn" data-tab="fulltext">Fulltext</button>
            <button type="button" class="editor-tab-btn" data-tab="source">Source</button>
            <button type="button" class="editor-tab-btn" data-tab="original">Original</button>
            <button type="button" class="editor-tab-btn" data-tab="copies">Copies</button>
            <button type="button" class="editor-tab-btn" data-tab="commentary">Commentary</button>
            <button type="button" class="editor-tab-btn" data-tab="appendix">Appendix</button>
        </div>

        <!-- Tab: Abstract -->
        <div class="editor-tab active" data-tab="abstract">
            <div class="form-group">
                <label>Abstract</label>
                <div class="mixed-editor-wrapper" data-context="abstract" data-field="abstract">
                    <div class="mixed-editor-toolbar">
                        <div class="mode-toggle">
                            <button type="button" class="mode-btn active" data-mode="visual">Standard</button>
                            <button type="button" class="mode-btn" data-mode="xml">XML</button>
                        </div>
                        <span class="text-small text-muted" style="margin-left:12px;">Select text &#x2192; right-click to annotate</span>
                    </div>
                    <div class="cei-editor" contenteditable="true">{local:cei-to-html($abstract/node())}</div>
                    <div class="cm-wrapper"></div>
                    <input type="hidden" name="abstract" value=""/>
                </div>
            </div>
            <div class="form-group">
                <label for="date-value">Date (normalized)</label>
                <input type="text" id="date-value" name="date-value" value="{$date-value}" placeholder="e.g. 12340101"/>
            </div>
            <div class="form-group">
                <label for="date-text">Date (text)</label>
                <input type="text" id="date-text" name="date-text" value="{$date-text}" placeholder="e.g. 1. Januar 1234"/>
            </div>
            <div class="form-group">
                <label for="place">Place</label>
                <input type="text" id="place" name="place" value="{$place}"/>
            </div>
        </div>

        <!-- Tab: Fulltext -->
        <div class="editor-tab" data-tab="fulltext">
            <div class="form-group">
                <label>Tenor (Full Text)</label>
                <div class="mixed-editor-wrapper" data-context="tenor" data-field="tenor">
                    <div class="mixed-editor-toolbar">
                        <div class="mode-toggle">
                            <button type="button" class="mode-btn active" data-mode="visual">Standard</button>
                            <button type="button" class="mode-btn" data-mode="xml">XML</button>
                        </div>
                        <span class="text-small text-muted" style="margin-left:12px;">Select text &#x2192; right-click to annotate</span>
                    </div>
                    <div class="cei-editor" contenteditable="true">{if (exists($tenor)) then local:cei-to-html($tenor/node()) else ()}</div>
                    <div class="cm-wrapper"></div>
                    <input type="hidden" name="tenor" value=""/>
                </div>
            </div>
        </div>

        <!-- Tab: Source -->
        <div class="editor-tab" data-tab="source">
            <div class="form-group">
                <label for="source-bibl-regest">Source Description (Regest)</label>
                <textarea id="source-bibl-regest" name="source-bibl-regest" rows="3">{$source-bibl-regest}</textarea>
            </div>
            <div class="form-group">
                <label for="source-bibl-volltext">Source Description (Volltext)</label>
                <textarea id="source-bibl-volltext" name="source-bibl-volltext" rows="3">{$source-bibl-volltext}</textarea>
            </div>
        </div>

        <!-- Tab: Original -->
        <div class="editor-tab" data-tab="original">
            <div class="form-group">
                <label for="traditioForm">Tradition Form</label>
                <input type="text" id="traditioForm" name="traditioForm" value="{$traditioForm}"/>
            </div>
            <div class="form-group">
                <label for="archIdentifier">Archive Identifier</label>
                <textarea id="archIdentifier" name="archIdentifier" rows="2">{$archIdentifier}</textarea>
            </div>
            <div class="form-group">
                <label for="physicalDesc">Physical Description</label>
                <textarea id="physicalDesc" name="physicalDesc" rows="3">{$physicalDesc}</textarea>
            </div>
            <div class="form-group">
                <label for="sealDesc">Seal Description</label>
                <textarea id="sealDesc" name="sealDesc" rows="3">{$sealDesc}</textarea>
            </div>
        </div>

        <!-- Tab: Copies -->
        <div class="editor-tab" data-tab="copies">
            <div class="form-group">
                <label for="witListPar">Copies / Witness List</label>
                <textarea id="witListPar" name="witListPar" rows="6">{$witListPar}</textarea>
            </div>
        </div>

        <!-- Tab: Commentary -->
        <div class="editor-tab" data-tab="commentary">
            <div class="form-group">
                <label for="listBiblEdition">Editions</label>
                <textarea id="listBiblEdition" name="listBiblEdition" rows="3">{$listBiblEdition}</textarea>
            </div>
            <div class="form-group">
                <label for="listBiblRegest">Regesta</label>
                <textarea id="listBiblRegest" name="listBiblRegest" rows="3">{$listBiblRegest}</textarea>
            </div>
            <div class="form-group">
                <label for="listBibl">Bibliography</label>
                <textarea id="listBibl" name="listBibl" rows="3">{$listBibl}</textarea>
            </div>
            <div class="form-group">
                <label for="listBiblFaksimile">Facsimiles</label>
                <textarea id="listBiblFaksimile" name="listBiblFaksimile" rows="3">{$listBiblFaksimile}</textarea>
            </div>
            <div class="form-group">
                <label for="listBiblErw">References</label>
                <textarea id="listBiblErw" name="listBiblErw" rows="3">{$listBiblErw}</textarea>
            </div>
            <div class="form-group">
                <label for="quoteOriginaldatierung">Original Dating (Quote)</label>
                <textarea id="quoteOriginaldatierung" name="quoteOriginaldatierung" rows="2">{$quoteOrig}</textarea>
            </div>
            <div class="form-group">
                <label for="nota">Notes</label>
                <textarea id="nota" name="nota" rows="4">{$nota}</textarea>
            </div>
            <div class="form-group">
                <label for="lang_MOM">Language</label>
                <select id="lang_MOM" name="lang_MOM">
                    <option value="">-- select --</option>
                    <option value="Deutsch">{if ($langMOM = 'Deutsch') then attribute selected {'selected'} else ()}Deutsch</option>
                    <option value="Latein">{if ($langMOM = 'Latein') then attribute selected {'selected'} else ()}Latein</option>
                    <option value="Italienisch">{if ($langMOM = 'Italienisch') then attribute selected {'selected'} else ()}Italienisch</option>
                    <option value="Französisch">{if ($langMOM = 'Französisch') then attribute selected {'selected'} else ()}Französisch</option>
                    <option value="Spanisch">{if ($langMOM = 'Spanisch') then attribute selected {'selected'} else ()}Spanisch</option>
                    <option value="Englisch">{if ($langMOM = 'Englisch') then attribute selected {'selected'} else ()}Englisch</option>
                    <option value="Tschechisch">{if ($langMOM = 'Tschechisch') then attribute selected {'selected'} else ()}Tschechisch</option>
                    <option value="Polnisch">{if ($langMOM = 'Polnisch') then attribute selected {'selected'} else ()}Polnisch</option>
                    <option value="Ungarisch">{if ($langMOM = 'Ungarisch') then attribute selected {'selected'} else ()}Ungarisch</option>
                    <option value="Niederländisch">{if ($langMOM = 'Niederländisch') then attribute selected {'selected'} else ()}Niederländisch</option>
                    <option value="Portugiesisch">{if ($langMOM = 'Portugiesisch') then attribute selected {'selected'} else ()}Portugiesisch</option>
                </select>
            </div>
        </div>

        <!-- Tab: Appendix -->
        <div class="editor-tab" data-tab="appendix">

            <!-- Person Names -->
            <fieldset class="repeatable-group" data-group="persName">
                <legend>Person Names (Index)</legend>
                <div class="repeatable-entries">{
                    if (exists($back-persNames)) then
                        for $pn at $i in $back-persNames
                        return
                            <div class="repeatable-entry">
                                <div class="form-row">
                                    <div class="form-group">
                                        <label>Regularized</label>
                                        <input type="text" name="back-persName-reg[]" value="{$pn/@reg/string()}"/>
                                    </div>
                                    <div class="form-group">
                                        <label>Name</label>
                                        <input type="text" name="back-persName-text[]" value="{normalize-space($pn)}"/>
                                    </div>
                                    <button type="button" class="btn btn--danger repeatable-remove">Remove</button>
                                </div>
                            </div>
                    else
                        <div class="repeatable-entry">
                            <div class="form-row">
                                <div class="form-group">
                                    <label>Regularized</label>
                                    <input type="text" name="back-persName-reg[]" value=""/>
                                </div>
                                <div class="form-group">
                                    <label>Name</label>
                                    <input type="text" name="back-persName-text[]" value=""/>
                                </div>
                                <button type="button" class="btn btn--danger repeatable-remove">Remove</button>
                            </div>
                        </div>
                }</div>
                <button type="button" class="btn repeatable-add" data-group="persName">+ Add Person</button>
            </fieldset>

            <!-- Place Names -->
            <fieldset class="repeatable-group" data-group="placeName">
                <legend>Place Names (Index)</legend>
                <div class="repeatable-entries">{
                    if (exists($back-placeNames)) then
                        for $pl at $i in $back-placeNames
                        return
                            <div class="repeatable-entry">
                                <div class="form-row">
                                    <div class="form-group">
                                        <label>Regularized</label>
                                        <input type="text" name="back-placeName-reg[]" value="{$pl/@reg/string()}"/>
                                    </div>
                                    <div class="form-group">
                                        <label>Type</label>
                                        <input type="text" name="back-placeName-type[]" value="{$pl/@type/string()}"/>
                                    </div>
                                    <div class="form-group">
                                        <label>Name</label>
                                        <input type="text" name="back-placeName-text[]" value="{normalize-space($pl)}"/>
                                    </div>
                                    <button type="button" class="btn btn--danger repeatable-remove">Remove</button>
                                </div>
                            </div>
                    else
                        <div class="repeatable-entry">
                            <div class="form-row">
                                <div class="form-group">
                                    <label>Regularized</label>
                                    <input type="text" name="back-placeName-reg[]" value=""/>
                                </div>
                                <div class="form-group">
                                    <label>Type</label>
                                    <input type="text" name="back-placeName-type[]" value=""/>
                                </div>
                                <div class="form-group">
                                    <label>Name</label>
                                    <input type="text" name="back-placeName-text[]" value=""/>
                                </div>
                                <button type="button" class="btn btn--danger repeatable-remove">Remove</button>
                            </div>
                        </div>
                }</div>
                <button type="button" class="btn repeatable-add" data-group="placeName">+ Add Place</button>
            </fieldset>

            <!-- Geographic Names -->
            <fieldset class="repeatable-group" data-group="geogName">
                <legend>Geographic Names (Index)</legend>
                <div class="repeatable-entries">{
                    if (exists($back-geogNames)) then
                        for $gn at $i in $back-geogNames
                        return
                            <div class="repeatable-entry">
                                <div class="form-row">
                                    <div class="form-group">
                                        <label>Regularized</label>
                                        <input type="text" name="back-geogName-reg[]" value="{$gn/@reg/string()}"/>
                                    </div>
                                    <div class="form-group">
                                        <label>Name</label>
                                        <input type="text" name="back-geogName-text[]" value="{normalize-space($gn)}"/>
                                    </div>
                                    <button type="button" class="btn btn--danger repeatable-remove">Remove</button>
                                </div>
                            </div>
                    else
                        <div class="repeatable-entry">
                            <div class="form-row">
                                <div class="form-group">
                                    <label>Regularized</label>
                                    <input type="text" name="back-geogName-reg[]" value=""/>
                                </div>
                                <div class="form-group">
                                    <label>Name</label>
                                    <input type="text" name="back-geogName-text[]" value=""/>
                                </div>
                                <button type="button" class="btn btn--danger repeatable-remove">Remove</button>
                            </div>
                        </div>
                }</div>
                <button type="button" class="btn repeatable-add" data-group="geogName">+ Add Geographic Name</button>
            </fieldset>
        </div>

        <!-- Save bar -->
        <div class="editor-save-bar">
            <a href="/mom/{$collection-key}/{$charter-key}/charter" class="btn">Cancel</a>
            <button type="submit" class="btn btn--primary">Save Charter</button>
        </div>

    </form>

    <script src="/mom/js/charter-editor.js">&#160;</script>
</div>
