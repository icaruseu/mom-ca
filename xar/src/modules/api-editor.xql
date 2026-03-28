xquery version "3.1";

(:~
 : Editor Schema API — parses the CEI XSD and returns JSON describing
 : allowed child elements and attributes for each CEI element.
 :
 : Endpoint:
 :   GET /api/editor/schema
 :
 : Invoked by controller.xql with request-path parameter.
 :)

declare namespace xs  = "http://www.w3.org/2001/XMLSchema";
declare namespace cei = "http://www.monasterium.net/NS/cei";
declare namespace xrxe = "http://www.monasterium.net/NS/xrxe";
declare namespace xrx  = "http://www.monasterium.net/NS/xrx";

(:~
 : Resolve element group references to their member element names.
 : Built from the CEI XSD group definitions — kept as a static map
 : so we never need to walk the XSD groups at runtime.
 :)
declare function local:element-groups() as map(*) {
    let $transcription := ("expan","add","supplied","del","corr","space","damage","c","sic","handShift","unclear","w","pc")
    let $sachauszeichnung := ("persName","rolename","orgName","placeName","geogName","index","testis","date","dateRange","num","measure")
    return map {
        "transcription":    $transcription,
        "Sachauszeichnung": $sachauszeichnung,
        "Sachliches":       ($sachauszeichnung, "quote","cit","foreign","anchor","ref","note"),
        "Originalbefund":   ($transcription, "hi","pb","lb","sup","pict","app"),
        "layout":           ("hi","lb","pb","sup","c"),
        "Formular":         ("invocatio","intitulatio","inscriptio","publicatio","arenga",
                             "narratio","rogatio","intercessio","dispositio","sanctio",
                             "corroboratio","datatio","subscriptio","notariusSub","setPhrase"),
        "date":             ("date","dateRange","w"),
        "Referenz":         ("anchor","ref"),
        "reference":        ("ptr","note","ref"),
        "BibliographicInformation": ("author","title","imprint","issued"),
        "biblArch":         ("country","region","settlement","arch","archFond","idno",
                             "provenance","bibl","msIdentifier","archIdentifier",
                             "institution","repository")
    }
};

(:~
 : Resolve attribute group references to lists of attribute descriptors.
 : Each entry is a map with at least "name" and "label".
 :)
declare function local:attr-groups() as map(*) {
    map {
        "identification": (
            map { "name": "reg",       "label": "Regularized" },
            map { "name": "key",       "label": "Key/ID" },
            map { "name": "certainty", "label": "Certainty" }
        ),
        "lang":   ( map { "name": "lang", "label": "Language" } ),
        "type":   ( map { "name": "type", "label": "Type" } ),
        "geog":   ( map { "name": "existent", "label": "Existent" } ),
        "rend":   ( map { "name": "rend", "label": "Rendition" } ),
        "gap":    ( map { "name": "reason", "label": "Reason" } ),
        "target": ( map { "name": "target", "label": "Target" } ),
        "key":    ( map { "name": "key", "label": "Key/ID" } ),
        "reg":    ( map { "name": "reg", "label": "Regularized" } ),
        "resp":   ( map { "name": "resp", "label": "Responsible" } ),
        "certainty": ( map { "name": "certainty", "label": "Certainty" } ),
        "picture": ( map { "name": "picture", "label": "Picture" } ),
        "function": ( map { "name": "function", "label": "Function" } ),
        "id":     ( map { "name": "id", "label": "ID" } ),
        "n":      ( map { "name": "n",  "label": "Number" } ),
        "facs":   ( map { "name": "facs", "label": "Facsimile" } ),
        "abbr":   ( map { "name": "abbr", "label": "Abbreviation" } ),
        "expan":  ( map { "name": "expan", "label": "Expansion" } ),

        (: composite attribute groups — expand to their member groups :)
        "standard": (
            map { "name": "id",   "label": "ID" },
            map { "name": "n",    "label": "Number" },
            map { "name": "facs", "label": "Facsimile" },
            map { "name": "resp", "label": "Responsible" },
            map { "name": "rend", "label": "Rendition" }
        ),
        "certain": (
            map { "name": "certainty", "label": "Certainty" },
            map { "name": "resp",      "label": "Responsible" }
        ),
        "reference": (
            map { "name": "type",   "label": "Type" },
            map { "name": "resp",   "label": "Responsible" },
            map { "name": "target", "label": "Target" },
            map { "name": "key",    "label": "Key/ID" }
        ),
        "abbreviation": (
            map { "name": "expan", "label": "Expansion" },
            map { "name": "abbr",  "label": "Abbreviation" }
        ),
        "date": (
            map { "name": "value",     "label": "Normalized date", "required": true(),
                  "pattern": "-?[0-9]{8}", "default": "99999999" },
            map { "name": "certainty", "label": "Certainty" },
            map { "name": "notBefore", "label": "Not before" },
            map { "name": "notAfter",  "label": "Not after" }
        ),
        "dateRequired": (
            map { "name": "value",     "label": "Normalized date", "required": true(),
                  "pattern": "-?[0-9]{8}", "default": "99999999" },
            map { "name": "certainty", "label": "Certainty" }
        ),
        "value": (
            map { "name": "value", "label": "Normalized date", "required": true(),
                  "pattern": "-?[0-9]{8}", "default": "99999999" }
        ),
        "valueRequired": (
            map { "name": "value", "label": "Normalized date", "required": true(),
                  "pattern": "-?[0-9]{8}", "default": "99999999" }
        )
    }
};

(:~
 : The set of element names the editor cares about.  Only elements in
 : this list will appear in the children / attributes output.
 :)
declare function local:editor-elements() as xs:string* {
    (: inline / annotation elements :)
    "persName", "rolename", "orgName", "placeName", "geogName",
    "index", "testis", "date", "dateRange", "num", "measure",
    "quote", "cit", "foreign", "anchor", "ref", "note",
    (: transcription / Originalbefund :)
    "expan", "add", "supplied", "del", "corr", "sic", "unclear",
    "hi", "lb", "pb", "sup", "pict", "app", "space", "damage",
    "c", "handShift", "w", "pc",
    (: Formular :)
    "invocatio", "intitulatio", "inscriptio", "publicatio", "arenga",
    "narratio", "rogatio", "intercessio", "dispositio", "sanctio",
    "corroboratio", "datatio", "subscriptio", "notariusSub", "setPhrase",
    (: container / structural elements that appear in the editor :)
    "abstract", "tenor", "pTenor", "p", "bibl", "figure",
    "issuer", "recipient", "witness", "witDetail",
    "seal", "sealDesc", "legend", "material", "dimensions",
    "arch", "archFond", "scope", "country", "region", "settlement",
    "repository", "institution", "archIdentifier", "msIdentifier",
    "idno", "class", "provenance", "head"
};

(:~
 : Hard-coded children map — derived from the CEI XSD element
 : definitions and their xs:group refs.  Only editor-relevant
 : children are listed (filtered through local:editor-elements()).
 :
 : This is the pragmatic approach: instead of parsing 5800 lines of
 : XSD at request time, we encode the structure once.
 :)
declare function local:children-map() as map(*) {
    let $groups := local:element-groups()
    let $editor := local:editor-elements()

    (: helper: flatten group refs + direct refs, then filter :)
    let $filter := function($names as xs:string*) as xs:string* {
        distinct-values($names[. = $editor])
    }

    return map {
        (: abstract: Sachliches + layout + class + recipient + issuer :)
        "abstract": $filter((
            $groups?("Sachliches"), $groups?("layout"),
            "class", "recipient", "issuer"
        )),

        (: tenor: Originalbefund + Sachliches + Formular + pTenor + witDetail + head :)
        "tenor": $filter((
            $groups?("Originalbefund"), $groups?("Sachliches"),
            $groups?("Formular"), "pTenor", "witDetail", "head"
        )),

        (: pTenor: same as tenor without pTenor itself :)
        "pTenor": $filter((
            $groups?("Originalbefund"), $groups?("Sachliches"),
            $groups?("Formular"), "witDetail", "head"
        )),

        (: p: Sachliches + archIdentifier + msIdentifier + Originalbefund + layout :)
        "p": $filter((
            $groups?("Sachliches"), $groups?("Originalbefund"),
            $groups?("layout"), "archIdentifier", "msIdentifier"
        )),

        (: persName: name elements + foreign + note + Originalbefund :)
        "persName": $filter((
            "persName", "orgName", "placeName", "geogName",
            "rolename", "foreign", "note",
            $groups?("Originalbefund")
        )),

        (: placeName: similar to persName :)
        "placeName": $filter((
            "persName", "placeName", "orgName", "geogName",
            "foreign", "index", "note",
            $groups?("Originalbefund")
        )),

        (: orgName :)
        "orgName": $filter((
            "persName", "placeName", "orgName", "geogName",
            "foreign", "note",
            $groups?("Originalbefund")
        )),

        (: geogName :)
        "geogName": $filter((
            "persName", "placeName", "orgName", "geogName",
            "foreign", "note",
            $groups?("Originalbefund")
        )),

        (: hi: Originalbefund + Sachliches + Formular :)
        "hi": $filter((
            $groups?("Originalbefund"), $groups?("Sachliches"),
            $groups?("Formular")
        )),

        (: date: foreign + num + Originalbefund + ref + note + placeName :)
        "date": $filter((
            "foreign", "num", "ref", "note", "placeName",
            $groups?("Originalbefund")
        )),

        (: dateRange: foreign + num + note + Originalbefund :)
        "dateRange": $filter((
            "foreign", "num", "note",
            $groups?("Originalbefund")
        )),

        (: note: Sachliches + Originalbefund + layout :)
        "note": $filter((
            $groups?("Sachliches"), $groups?("Originalbefund"),
            $groups?("layout")
        )),

        (: foreign: Sachliches + Originalbefund + layout :)
        "foreign": $filter((
            $groups?("Sachliches"), $groups?("Originalbefund"),
            $groups?("layout")
        )),

        (: bibl (mixed): Sachliches + layout :)
        "bibl": $filter((
            $groups?("Sachliches"), $groups?("layout")
        )),

        (: issuer / recipient: like persName :)
        "issuer": $filter((
            "persName", "orgName", "placeName", "geogName",
            "rolename", "foreign", "note",
            $groups?("Originalbefund")
        )),
        "recipient": $filter((
            "persName", "orgName", "placeName", "geogName",
            "rolename", "foreign", "note",
            $groups?("Originalbefund")
        )),

        (: witness: Sachliches + Originalbefund + layout + bibl :)
        "witness": $filter((
            $groups?("Sachliches"), $groups?("Originalbefund"),
            $groups?("layout"), "bibl", "archIdentifier", "msIdentifier",
            "figure"
        )),

        (: witDetail: Sachliches + Originalbefund :)
        "witDetail": $filter((
            $groups?("Sachliches"), $groups?("Originalbefund")
        )),

        (: legend: Sachliches + Originalbefund + layout :)
        "legend": $filter((
            $groups?("Sachliches"), $groups?("Originalbefund"),
            $groups?("layout")
        )),

        (: seal / sealDesc: child elements :)
        "sealDesc": $filter(("seal", "legend", "note")),
        "seal":     $filter(("legend", "note", "figure")),

        (: material / dimensions: Originalbefund + layout :)
        "material": $filter((
            $groups?("Originalbefund"), $groups?("layout")
        )),
        "dimensions": $filter((
            $groups?("Originalbefund"), $groups?("layout")
        )),

        (: measure: num + index + Originalbefund :)
        "measure": $filter((
            "num", "index", $groups?("Originalbefund")
        )),

        (: index: Sachliches + Originalbefund :)
        "index": $filter((
            $groups?("Sachliches"), $groups?("Originalbefund")
        )),

        (: expan: Originalbefund :)
        "expan":    $filter($groups?("Originalbefund")),
        "add":      $filter($groups?("Originalbefund")),
        "supplied": $filter($groups?("Originalbefund")),
        "del":      $filter($groups?("Originalbefund")),
        "corr":     $filter($groups?("Originalbefund")),
        "sic":      $filter($groups?("Originalbefund")),
        "unclear":  $filter($groups?("Originalbefund")),
        "damage":   $filter($groups?("Originalbefund")),

        (: num: Originalbefund :)
        "num": $filter($groups?("Originalbefund")),

        (: quote / cit: Sachliches + Originalbefund :)
        "quote": $filter((
            $groups?("Sachliches"), $groups?("Originalbefund")
        )),
        "cit": $filter((
            $groups?("Sachliches"), $groups?("Originalbefund"),
            "quote"
        )),

        (: Formular elements: Sachliches + Originalbefund + layout :)
        "invocatio":     $filter(($groups?("Sachliches"), $groups?("Originalbefund"), $groups?("layout"))),
        "intitulatio":   $filter(($groups?("Sachliches"), $groups?("Originalbefund"), $groups?("layout"))),
        "inscriptio":    $filter(($groups?("Sachliches"), $groups?("Originalbefund"), $groups?("layout"))),
        "publicatio":    $filter(($groups?("Sachliches"), $groups?("Originalbefund"), $groups?("layout"))),
        "arenga":        $filter(($groups?("Sachliches"), $groups?("Originalbefund"), $groups?("layout"))),
        "narratio":      $filter(($groups?("Sachliches"), $groups?("Originalbefund"), $groups?("layout"))),
        "rogatio":       $filter(($groups?("Sachliches"), $groups?("Originalbefund"), $groups?("layout"))),
        "intercessio":   $filter(($groups?("Sachliches"), $groups?("Originalbefund"), $groups?("layout"))),
        "dispositio":    $filter(($groups?("Sachliches"), $groups?("Originalbefund"), $groups?("layout"))),
        "sanctio":       $filter(($groups?("Sachliches"), $groups?("Originalbefund"), $groups?("layout"))),
        "corroboratio":  $filter(($groups?("Sachliches"), $groups?("Originalbefund"), $groups?("layout"))),
        "datatio":       $filter(($groups?("Sachliches"), $groups?("Originalbefund"), $groups?("layout"))),
        "subscriptio":   $filter(($groups?("Sachliches"), $groups?("Originalbefund"), $groups?("layout"))),
        "notariusSub":   $filter(($groups?("Sachliches"), $groups?("Originalbefund"), $groups?("layout"))),
        "setPhrase":     $filter(($groups?("Sachliches"), $groups?("Originalbefund"), $groups?("layout"))),

        (: idno / scope / archFond: mixed text, mostly layout :)
        "idno":     $filter($groups?("layout")),
        "scope":    $filter($groups?("layout")),
        "archFond": $filter($groups?("layout")),

        (: ref: Sachliches + layout :)
        "ref": $filter((
            $groups?("Sachliches"), $groups?("layout")
        )),

        (: sup: typically leaf, but allow Originalbefund :)
        "sup": $filter($groups?("Originalbefund")),

        (: rolename :)
        "rolename": $filter((
            "persName", "placeName", "orgName", "foreign", "note",
            $groups?("Originalbefund")
        )),

        (: testis :)
        "testis": $filter((
            "persName", "placeName", "orgName", "foreign", "note",
            $groups?("Originalbefund")
        ))
    }
};

(:~
 : Hard-coded attributes map — derived from xs:attribute and
 : xs:attributeGroup refs in each element's complexType.
 : Only editor-relevant attributes are included.
 :)
declare function local:attributes-map() as map(*) {
    let $ag := local:attr-groups()
    return map {
        "persName": array {
            $ag?("identification"), $ag?("lang"), $ag?("type")
        },
        "rolename": array {
            $ag?("identification"), $ag?("lang"), $ag?("type")
        },
        "orgName": array {
            $ag?("identification"), $ag?("lang"), $ag?("type")
        },
        "placeName": array {
            $ag?("identification"), $ag?("lang"), $ag?("type"),
            $ag?("geog")
        },
        "geogName": array {
            $ag?("identification"), $ag?("lang"), $ag?("type"),
            $ag?("geog")
        },
        "index": array {
            map { "name": "indexName", "label": "Index name" },
            map { "name": "lemma",     "label": "Lemma" },
            map { "name": "sublemma",  "label": "Sub-lemma" }
        },
        "testis": array {
            $ag?("identification"), $ag?("lang")
        },
        "date": array {
            $ag?("date"), $ag?("lang")
        },
        "dateRange": array {
            map { "name": "from", "label": "From date", "required": true(),
                  "pattern": "-?[0-9]{8}", "default": "99999999" },
            map { "name": "to",   "label": "To date",   "required": true(),
                  "pattern": "-?[0-9]{8}", "default": "99999999" },
            $ag?("certainty"), $ag?("lang")
        },
        "num": array {
            map { "name": "value", "label": "Value" },
            $ag?("lang")
        },
        "measure": array {
            map { "name": "type", "label": "Type" },
            $ag?("lang")
        },
        "quote": array { $ag?("lang") },
        "cit":   array { $ag?("lang") },
        "foreign": array { $ag?("lang") },
        "anchor": array { $ag?("target") },
        "ref": array {
            $ag?("reference")
        },
        "note": array {
            $ag?("type"), $ag?("lang"),
            map { "name": "place", "label": "Place" }
        },
        "hi": array {
            $ag?("rend")
        },
        "lb": array {},
        "pb": array {
            $ag?("facs")
        },
        "sup": array {},
        "pict": array {
            map { "name": "url", "label": "URL" }
        },
        "app": array {},
        "expan": array { $ag?("abbreviation") },
        "add": array {
            map { "name": "hand", "label": "Hand" },
            map { "name": "place", "label": "Place" }
        },
        "supplied": array {
            map { "name": "source", "label": "Source" }
        },
        "del": array {
            $ag?("type"),
            map { "name": "hand", "label": "Hand" }
        },
        "corr": array {
            map { "name": "sic", "label": "Original (sic)" },
            $ag?("type")
        },
        "sic": array {
            map { "name": "corr", "label": "Correction" }
        },
        "unclear": array {
            $ag?("gap")
        },
        "damage": array {
            $ag?("gap")
        },
        "space": array {
            map { "name": "dim", "label": "Dimension" },
            map { "name": "extent", "label": "Extent" }
        },
        "handShift": array {
            map { "name": "hand", "label": "Hand" }
        },
        "abstract": array { $ag?("lang") },
        "tenor": array {},
        "pTenor": array { $ag?("type") },
        "p": array { $ag?("type") },
        "bibl": array {
            $ag?("type"), $ag?("key")
        },
        "figure": array {},
        "issuer": array {
            $ag?("identification"), $ag?("lang"), $ag?("type")
        },
        "recipient": array {
            $ag?("identification"), $ag?("lang"), $ag?("type")
        },
        "witness": array {
            $ag?("type"), $ag?("lang")
        },
        "witDetail": array {
            map { "name": "wit", "label": "Witness sigil" }
        },
        "seal": array {
            $ag?("type"), $ag?("lang")
        },
        "sealDesc": array {},
        "legend": array { $ag?("lang") },
        "material": array { $ag?("lang") },
        "dimensions": array { $ag?("lang") },
        "idno": array {
            map { "name": "id", "label": "ID" },
            map { "name": "n",  "label": "Number" }
        },
        "class": array {
            $ag?("type")
        },
        "scope": array {},
        "archFond": array {},
        "arch": array {},

        (: Formular elements typically inherit standard attrs :)
        "invocatio":    array { $ag?("lang") },
        "intitulatio":  array { $ag?("lang") },
        "inscriptio":   array { $ag?("lang") },
        "publicatio":   array { $ag?("lang") },
        "arenga":       array { $ag?("lang") },
        "narratio":     array { $ag?("lang") },
        "rogatio":      array { $ag?("lang") },
        "intercessio":  array { $ag?("lang") },
        "dispositio":   array { $ag?("lang") },
        "sanctio":      array { $ag?("lang") },
        "corroboratio": array { $ag?("lang") },
        "datatio":      array { $ag?("lang") },
        "subscriptio":  array { $ag?("lang") },
        "notariusSub":  array { $ag?("lang") },
        "setPhrase":    array { $ag?("lang"), $ag?("type") }
    }
};

(:~
 : Deduplicate attribute arrays by name, keeping the first occurrence.
 :)
declare function local:dedup-attrs($attrs as map(*)*) as array(*) {
    let $seen := map {}
    return array {
        fold-left($attrs, (), function($acc, $attr) {
            let $name := $attr?name
            return
                if (some $a in $acc satisfies $a?name = $name) then $acc
                else ($acc, $attr)
        })
    }
};

(:~
 : Normalize an attribute entry into the JSON output format.
 :)
declare function local:normalize-attr($attr as map(*)) as map(*) {
    map:merge((
        map { "name":  $attr?name },
        map { "label": ($attr?label, $attr?name)[1] },
        map { "required": ($attr?required, false())[1] },
        if (exists($attr?pattern)) then map { "pattern": $attr?pattern } else (),
        if (exists($attr?default)) then map { "default": $attr?default } else ()
    ))
};

(:~
 : Build the full schema response.
 :)
declare function local:schema() as map(*) {
    let $children-raw  := local:children-map()
    let $attrs-raw     := local:attributes-map()
    let $editor        := local:editor-elements()

    (: Build children — convert sequences to arrays :)
    let $children := map:merge(
        for $elem in $editor
        let $kids := $children-raw($elem)
        where exists($kids)
        return map:entry($elem, array { $kids })
    )

    (: Build attributes — deduplicate and normalize :)
    let $attributes := map:merge(
        for $elem in $editor
        let $raw := $attrs-raw($elem)
        where exists($raw)
        let $items := if ($raw instance of array(*)) then
            for $i in 1 to array:size($raw) return $raw($i)
        else ()
        let $deduped := local:dedup-attrs($items)
        where array:size($deduped) > 0
        return map:entry($elem, array {
            for $i in 1 to array:size($deduped)
            return local:normalize-attr($deduped($i))
        })
    )

    return map {
        "children":   $children,
        "attributes": $attributes
    }
};


(: ── Request routing ─────────────────────────────────────────────── :)

let $request-path := request:get-parameter("request-path", "")
return (
    response:set-header("Content-Type", "application/json"),
    if ($request-path = "/api/editor/schema") then
        serialize(local:schema(), map { "method": "json" })
    else (
        response:set-status-code(404),
        serialize(
            map { "status": "error", "message": "Unknown editor API endpoint: " || $request-path },
            map { "method": "json" }
        )
    )
)
