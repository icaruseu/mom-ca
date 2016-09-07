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

module namespace translate="http://www.monasterium.net/NS/translate";

declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace atom="http://www.w3.org/2005/Atom";

import module namespace xrx="http://www.monasterium.net/NS/xrx"
    at "../xrx/xrx.xqm";
import module namespace i18n="http://www.monasterium.net/NS/i18n"
    at "../i18n/i18n.xqm";

(:
    ##################
    #
    # Variables
    #
    ##################
:)

(: request parameter :)                    
declare variable $translate:rcatalog := request:get-parameter('catalog', 'all');
declare variable $translate:rlang := request:get-parameter('lang', $xrx:lang);
declare variable $translate:rid := request:get-parameter('id', ());
declare variable $translate:rq := translate(request:get-parameter('q', ''), "'", '"');
declare variable $translate:ronly-untranslated := xs:boolean(request:get-parameter('only-untranslated', true()));
declare variable $translate:rkey :=  request:get-parameter('key', ());

(: lucene options :)
declare variable $translate:options :=
    <options xmlns="">
        <default-operator>and</default-operator>
        <phrase-slop>0</phrase-slop>
        <leading-wildcard>no</leading-wildcard>
        <filter-rewrite>yes</filter-rewrite>
    </options>;

(: current mainwidget to translate :)
declare variable $translate:mainwidget := 
    if($translate:rid) then $xrx:live-project-db-base-collection//xrx:id[.=$translate:rid]/parent::xrx:widget else();
declare variable $translate:mainwidget-title := translate:mainwidget-title();
declare variable $translate:keys := translate:keys();

(:
    ##################
    #
    # Functions
    #
    ##################
:)

(: get i18n entries according to the current request parameters :)
declare function translate:entries() {    
   
    util:eval(translate:query-string())
};

(: compose query string :)
declare function translate:query-string() as xs:string {

    translate:query-string($translate:rcatalog, $translate:rlang, $translate:rid, $translate:rq, $translate:ronly-untranslated)
};

(: compose query string :)
declare function translate:query-string($catalog as xs:string, $lang as xs:string*, $id as xs:string*, $q as xs:string*, $only-untranslated as xs:boolean) as xs:string { 

    concat(
        'for $entry in ',
        translate:context-query-string($catalog, $lang, $id, $q),
        translate:constrain-query-string($only-untranslated),
        ' order by lower-case($key) ascending',
        ' return $entry'
    )

};

(: compose context query string :)
declare function translate:context-query-string($catalog as xs:string, $lang as xs:string*, $id as xs:string*, $q as xs:string*) as xs:string {

    concat(
        'collection("',  
        $i18n:db-base-collection-path , 
        if($lang='all') then '' else $lang,
        if($catalog='all' or $lang='all' or $id) then '' else concat('/app.',  $translate:rcatalog),
        '")//atom:entry', 
        if($q and $q!='') then concat("[ft:query(./atom:content/xrx:i18n ,'", $q, "',$translate:options)]") else ''
    )
};

(: compose constrain query string :)
declare function translate:constrain-query-string($only-untranslated as xs:boolean) as xs:string {

    concat(
        ' let $i18n := $entry/atom:content/xrx:i18n', 
        ' let $key := $i18n/xrx:key/text()',
        ' where ($i18n/@activeflag!="false" or not($i18n/@activeflag))',   
        ' and $key ',        
        translate:constrain-page-ids-query-string(),
        if($only-untranslated) then ' and ($i18n/xrx:text/text()="" or not($i18n/xrx:text/text()) )' else ''  
        )
};

(: compose constrain page ids query string :)
declare function translate:constrain-page-ids-query-string() as xs:string {

    if($translate:rid) then
        concat(
            'and (',
            let $key-compares :=
                for $key in $translate:keys
                return
                concat('$key="', $key, '"')
            return 
            string-join($key-compares, ' or '),
            ')'
        )
    else ''
};

(: widget translate helper function:)
declare function translate:index($entries as element(atom:entry)*, $entry as element(atom:entry)*) {
    
    if($entries and $entry) then index-of($entries, $entry) else 0
};

(: widget translate helper function :)
declare function translate:translations($key as xs:string*, $language as xs:string*) as element() {

    let $languages := $i18n:languages
    let $translations :=
         if($key and $language) then
            for $lang  in $languages
            let $translation := i18n:value($key, $lang/@key/string())
            return
                 if($lang/@key/string() != $language) then
                        <translation lang="{$lang/@name/string()}">{ if($translation != '') then $translation else '-' }</translation>
                 else
            ()    
         else ()          
    
    return <translations xmlns="">{$translations}</translations>
};

(: title of the page currently translated :)
declare function translate:mainwidget-title() {

    if($translate:mainwidget) then 
        let $message := $translate:mainwidget/xrx:title/xrx:i18n
        let $title := if($message) then i18n:translate($message) else ''
        return
        if($title != '') then $title
        else $translate:rid
    else $translate:rid
};

(: sequence of all keys related to the currently translated page :)
declare function translate:keys() as xs:string* {

    if($translate:mainwidget) then
        let $mainwidgetid := replace($translate:rid, '/widget/', '/mainwidget/')
        let $mainwidget := $xrx:live-project-db-base-collection/xhtml:html[@id=$mainwidgetid]
        let $mainwidget-keys := $mainwidget//xrx:key/text()
        (: related catalogs and messages :)
        let $widget := $xrx:live-project-db-base-collection//xrx:id[.=$translate:rid]/parent::xrx:widget
        let $messages := xrx:messages($widget)
        let $related-keys := $messages//xrx:key/text()
        let $keys := ($mainwidget-keys, $related-keys)
        return
        if(count($keys) > 0) then distinct-values($keys) else()
    else()
};

