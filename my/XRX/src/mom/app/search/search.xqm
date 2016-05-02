xquery version "3.0";
(:~
This is a component file of the VdU Software for a Virtual Research Environment for the handling of Medieval charters.

As the source code is available here, it is somewhere between an alpha- and a beta-release, may be changed without any consideration of backward compatibility of other parts of the system, therefore, without any notice.

This file is part of the VdU Virtual Research Environment Toolkit (VdU/VRET).

The VdU/VRET is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

VdU/VRET is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with VdU/VRET.  If not, see <http://www.gnu.org/licenses/>.

We expect VdU/VRET to be distributed in the future with a license more lenient towards the inclusion of components into other systems, once it leaves the active development stage.
:)

module namespace search="http://www.monasterium.net/NS/search";

import module namespace xrx="http://www.monasterium.net/NS/xrx"
    at "../xrx/xrx.xqm";
import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../xrx/conf.xqm";
import module namespace i18n="http://www.monasterium.net/NS/i18n"
    at "../i18n/i18n.xqm";
import module namespace charter="http://www.monasterium.net/NS/charter"
    at "../charter/charter.xqm";

declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace cei="http://www.monasterium.net/NS/cei";
declare namespace tei="http://www.tei-c.org/ns/1.0";

(: request parameters :)
declare variable $search:q := 
    translate(request:get-parameter('q', ''), "'", '"');
declare variable $search:img := request:get-parameter('img', '');
declare variable $search:annotations := request:get-parameter('annotations', '');
declare variable $search:sort := request:get-parameter('sort', 'date');
declare variable $search:p := request:get-parameter('p', 'results');
declare variable $search:from := request:get-parameter('from', '');
declare variable $search:to := request:get-parameter('to', '');
declare variable $search:arch-id := request:get-parameter('arch', '');
declare variable $search:fond-id := request:get-parameter('col', '');
declare variable $search:context := request:get-parameter('context', '');
declare variable $search:categories := request:get-parameter('categories', '');

declare variable $search:filter := ($search:q, $search:img, $search:annotations, $search:arch-id, $search:from, $search:to);

declare variable $search:options :=
    <options xmlns="">
        <default-operator>and</default-operator>
        <phrase-slop>0</phrase-slop>
        <leading-wildcard>no</leading-wildcard>
        <filter-rewrite>yes</filter-rewrite>
    </options>;



(: session parameters :)
declare variable $search:RESULT := 'result';
declare variable $search:CATEGORIES := 'categories';
declare variable $search:CATEGORIES_FILTERED := 'categories-filtered';
declare variable $search:CONTEXT := 'archives';
declare variable $search:CONTEXT_FILTERED := 'archives-filtered';
declare variable $search:HITS := 'hits';
declare variable $search:HITS_FILTERED := 'hits-filtered';
declare variable $search:QUERY := 'query';
declare variable $search:ATTRIBUTES := ($search:RESULT, $search:CATEGORIES,
    $search:CATEGORIES_FILTERED, $search:CONTEXT, $search:CONTEXT_FILTERED,
    $search:HITS, $search:HITS_FILTERED, $search:QUERY);



declare function search:categories() {

    if($search:categories = '') then
        search:all-categories()
    else
        search:categories-included()
};



(:~
  All possible categories configured in the database index.
:)
declare function search:all-categories() {

    ('cei:abstract', 'cei:altIdentifier', 'cei:apprecatio', 'cei:arch', 'cei:archFond', 'cei:archIdentifier',
    'cei:arenga', 'cei:auth', 'cei:class', 'cei:condition', 'cei:corroboratio', 'cei:country', 'cei:datatio',
    'cei:date', 'cei:dateRange', 'cei:dimensions', 'cei:dispositio', 'cei:divNotes', 'cei:figDesc', 'cei:geogName',
    'cei:idno', 'cei:index', 'cei:inscriptio', 'cei:intitulatio', 'cei:invocatio', 'cei:issuer', 'cei:lang_MOM',
    'cei:legend', 'cei:listBibl', 'cei:listBiblEdition', 'cei:listBiblErw', 'cei:listBiblFaksimile',
    'cei:listBiblRegest', 'cei:material', 'cei:msIdentifier', 'cei:narratio', 'cei:nota', 'cei:notariusDesc',
    'cei:notariusSign', 'cei:notariusSub', 'cei:note', 'cei:persName', 'cei:physicalDesc', 'cei:placeName',
    'cei:publicatio', 'cei:quoteOriginaldatierung', 'cei:recipient', 'cei:region', 'cei:sanctio', 'cei:seal',
    'cei:sealCondition', 'cei:sealDesc', 'cei:sealDimensions', 'cei:sealMaterial', 'cei:setPhrase',
    'cei:settlement', 'cei:sigillant', 'cei:sourceDescRegest', 'cei:sourceDescVolltext', 'cei:subscriptio',
    'cei:tenor', 'cei:testis', 'cei:traditioForm', 'cei:witListPar', 'cei:witnessOrig',
    '@abbr', '@class', '@corr', '@expan', '@from', '@function', '@hand', '@key', '@lemma', '@reason',
    '@reg', '@sublemma', '@sic', '@to', '@value', 'tei:span')
};



(:~
  Categories currently selected by the user.
:)
declare function search:categories-included() {
    tokenize(xmldb:decode($search:categories), ',')
};



(:~
  Categories currently deselected by the user
:)
declare function search:categories-excluded() {
    
    let $included := search:categories-included()
    for $cat in session:get-attribute($search:CATEGORIES)//@key/string()
    return
    if($cat = $included) then ()
    else $cat
};



(:~
  Context (collection/fond) currently selected by the user.
:)
declare function search:context() {

    let $tok := tokenize(xmldb:decode($search:context), ',')
    return
    if($search:context = '') then
        ()
    else if(empty($tok)) then
        xmldb:encode($search:context)
    else 
        for $t in $tok
        let $arch := contains($t, ';')
        return
        if($arch) then replace(xmldb:encode(replace($t, ';', '____')), '____', ';')
        else xmldb:encode($t) 
};



declare function search:scope-query-string($metadata-charter-db-base-collection-path) as xs:string {

    (: do we search inside a fond? :)
    if($search:fond-id != '') then
    concat('let $context := collection(concat("', $metadata-charter-db-base-collection-path, '", "/', $search:arch-id, '", "/', $search:fond-id, '")) ')
    
    (: do we search inside an archive? :)
    else if($search:arch-id != '') then
    concat('let $context := collection(concat("', $metadata-charter-db-base-collection-path, '", "/', $search:arch-id, '")) ')
            
    (: a global search? :)
    else 
    concat('let $context := collection("', $metadata-charter-db-base-collection-path, '") ')
    
};



declare function search:query-string-scope($metadata-charter-db-base-collection-path) as xs:string {
    
    (: do we search inside selected fonds or collections? :)
    if($search:context != '') then
        let $contexts := 
            for $ctx in search:context()
            return
            concat("'", $metadata-charter-db-base-collection-path, replace($ctx, ';', '/'), "'")
        return
        concat('let $context := collection(', string-join($contexts, ','), ') ')
            
    (: a global search? :)
    else 
    concat('let $context := collection("', $metadata-charter-db-base-collection-path, '") ')
    
};



(: the basic full text query string :)
declare function search:term-query-string() as xs:string {

    concat("$context//cei:text[ft:query(.,'", $search:q, "',$search:options)]")
};



(: only hits with images? :)
declare function search:img-query-string() {

    if($search:img = 'true') then '[.//cei:graphic/@url]'
    else ''
    
};

(: only hits with annotations? :)
declare function search:anno-query-string() {

    if($search:annotations = 'true') then "[.//@facs]"
    else ''
    
};

(: sort by date or by internal ranking? :)
declare function search:sort-query-string() {

    if($search:sort = 'date') then
    ' order by ($charter//cei:date/@value, $charter//cei:dateRange/@from, $charter//cei:dateRange/@to)[1] ascending '
    else
    ' order by ft:score($charter) descending '    
};



(: compose the query string to be evaluated :)
declare function search:query-string($metadata-charter-db-base-collection-path) as xs:string {

    concat(
        if($xrx:tokenized-uri[last()] = 'search') then
            search:scope-query-string($metadata-charter-db-base-collection-path)
        else
            search:query-string-scope($metadata-charter-db-base-collection-path),
        'for $charter in ',
        search:term-query-string(),
        search:img-query-string(),
        search:anno-query-string(),
        if(search:is-first-action()) then search:sort-query-string() else '',
        ' return $charter'
    )

};



declare function search:i18n-category-name($category) {

    if ($category != 'cei:text') then
        i18n:value(replace($category, ':', '_'), $xrx:lang, $category)
    else
        i18n:value('charter', $xrx:lang, 'charter')
};



declare function search:compile-categories-map($result) {

    map:new(
        for $category in search:categories()
        let $query-string := concat("$result/root()//", $category, "[ft:query(., '", $search:q, "', $search:options)]", 
                              if($search:annotations = 'true') then "[@facs or ./descendant::node()/@facs]" else())
        let $r := util:eval($query-string)
        let $count := count($r)
        return
        if($count gt 0) then map:entry($category, $r) else ()
    )    
};



declare function search:compile-categories-xml($map) {
    
    let $categories :=
        <categories xmlns="">
            {
            for $key in map:keys($map)
            let $count := count(map:get($map, $key))
            return
            <category key="{ $key }" name="{ search:i18n-category-name($key) }" count="{ $count }"/>
            }
        </categories>
    return $categories
};



declare function search:compile-context($result) {

    let $tag-name := conf:param('atom-tag-name')
    let $context :=
        <context xmlns="">
            {
            for $charters in $result
            let $atomid := root($charters[1])/atom:entry/atom:id/text()
            let $ctx := charter:context($atomid, $tag-name)
            let $archid := charter:archid($atomid, $tag-name)
            let $key := 
                if($ctx = 'fond') then concat($archid, ';', charter:fondid($atomid, $tag-name))
                else charter:collectionid($atomid, $tag-name)
            group by $key
            order by $key
            return
            if($ctx = 'fond') then 
                <fond key="{ $key }" name="{ $key }" count="{ count($charters) }"/>
            else
                <collection key="{ $key }" name="{ $key }" count="{ count($charters) }"/>
            }
        </context>
    return $context
};



declare function search:clear-session() {

    for $attr in $search:ATTRIBUTES
    return
    session:remove-attribute($attr)
};



declare function search:is-first-action() {
    $search:categories = '' and $search:context = '' 
        and $search:img = '' and $search:q != ''
        and $search:annotations = ''
};



declare function search:is-browse-action($query-string) {
    xs:string(session:get-attribute($search:QUERY)) = $query-string || string-join(search:categories-included(), '') 
};



declare function search:is-filter-action() {
    $search:categories != '' or $search:context != '' or $search:img != '' or $search:annotations != ''
};



declare function search:set-categories($map) {

    let $categories := search:compile-categories-xml($map)
    let $remove := session:remove-attribute($search:CATEGORIES)
    let $set := session:set-attribute($search:CATEGORIES, $categories)
    return $categories
};



declare function search:set-categories-filtered($map, $categories) {

    let $cat := 
        if(empty($categories)) then 
            search:compile-categories-xml($map)
        else
            $categories
    let $remove := session:remove-attribute($search:CATEGORIES_FILTERED)
    let $set := session:set-attribute($search:CATEGORIES_FILTERED, $cat)
    return $cat
};



declare function search:set-context($result) {

    let $context := search:compile-context($result)
    let $remove := session:remove-attribute($search:CONTEXT)
    let $set := session:set-attribute($search:CONTEXT, $context)
    return $context
};



declare function search:set-context-filtered($result, $context) {

    let $ctx := 
        if(empty($context)) then 
            search:compile-context($result)
        else
            $context
    let $remove := session:remove-attribute($search:CONTEXT_FILTERED)
    let $set := session:set-attribute($search:CONTEXT_FILTERED, $ctx)
    return ()
};



declare function search:set-query($string) {

    let $remove := session:remove-attribute($search:QUERY)
    let $set := session:set-attribute($search:QUERY, $string || string-join(search:categories-included(), ''))
    return ()
};



declare function search:set-result($result) {

    let $remove := session:remove-attribute($search:RESULT)
    let $set := session:set-attribute($search:RESULT, $result)
    return ()
};



declare function search:set-hits($result-unique) {

    let $remove := session:remove-attribute($search:HITS)
    let $count := count($result-unique)
    let $set := session:set-attribute($search:HITS, 
        <hits xmlns="">
            <count>{ $count }</count>
        </hits>
    )
    return $count
};



declare function search:set-hits-filtered($result-unique, $count) {

    let $remove := session:remove-attribute($search:HITS_FILTERED)
    let $c := 
        if(empty($count)) then
            count($result-unique)
        else 
            $count
    let $set := session:set-attribute($search:HITS_FILTERED, 
        <hits xmlns="">
            <count>{ $c }</count>
        </hits>
    )
    return ()
};



declare function search:filter-result($result, $map) {

    for $charter in ($result except 
        (for $ex in search:categories-excluded()
        return 
            map:get($map, $ex)/ancestor::cei:text)) intersect
            ((for $in in search:categories-included()
            return
                map:get($map, $in)/ancestor::cei:text))
    order by 
        if($search:sort = 'date') then
             ($charter//cei:date/@value, $charter//cei:dateRange/@from, $charter//cei:dateRange/@to)[1]
        else
            ft:score($charter)
    return
    $charter
};



declare function search:eval2($query-string) {

    if(search:is-browse-action($query-string)) then ()
        
    else if(search:is-first-action()) then 

        let $result := util:eval($query-string)

        let $map := search:compile-categories-map($result)

let $Log := util:log("ERROR", "categries")
        let $do := search:set-categories($map)

        let $do := search:set-categories-filtered($map, 
                session:get-attribute($search:CATEGORIES))
        
        let $do := search:set-context($result)
        
        let $do := search:set-context-filtered($result, 
                session:get-attribute($search:CONTEXT))
        
        let $do := search:set-query($query-string)

        let $do := search:set-result($result)
        
        let $count := search:set-hits($result)
        
        let $do := search:set-hits-filtered($result, $count)

        return ()

    else if(search:is-filter-action()) then

        let $result := util:eval($query-string)
        
        let $map := search:compile-categories-map($result)
        
        let $result := search:filter-result($result, $map)

        let $map := search:set-categories-filtered($map, ())
        
        let $do := search:set-context-filtered($result, ())
        
        let $do := search:set-query($query-string)

        let $do := search:set-result($result)
        
        let $do := search:set-hits-filtered($result, ())
        
        return ()
        
    else

        search:clear-session()
};



declare function search:eval($query-string) {

    let $session-query-string := xs:string(session:get-attribute('querystring'))
    let $session-result := session:get-attribute('result')
    let $query-exists := 
        if($search:q != '') then true()
        else false()
    let $result-exists := 
      if($query-exists and $session-query-string = $query-string) then true()
      else false()
    return
    if($result-exists) then session:get-attribute('result')
    else if($query-exists) then 
        
        let $result := util:eval($query-string)
        let $remove1 := session:remove-attribute('querystring')
        let $set1 := session:set-attribute('querystring', $query-string)
        let $remove2 := session:remove-attribute('result')
        let $set2 := session:set-attribute('result', $result)
        return session:get-attribute('result')
        
    else()
};
