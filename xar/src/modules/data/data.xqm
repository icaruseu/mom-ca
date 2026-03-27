xquery version "3.1";

(:~
 : Atom data layer for MOM-CA.
 : Ported from core/app/data/data.xqm with imports adapted for .xar package.
 :)

module namespace data = "http://www.monasterium.net/NS/data";

declare namespace atom = "http://www.w3.org/2005/Atom";
declare namespace xrx = "http://www.monasterium.net/NS/xrx";

import module namespace conf = "http://www.monasterium.net/NS/conf"
    at "../core/conf.xqm";

(:~
 : Extract the object ID (last URI token) from an atom ID.
 :)
declare function data:objectid($atomid as xs:string, $datatype as element()) as xs:string {
    let $tag := conf:param('atom-tag-name')
    let $tokens := tokenize(substring-after($atomid, $tag), '/')
    return xmldb:decode($tokens[last()])
};

(:~
 : Extract URI tokens from an atom ID.
 :)
declare function data:uri-tokens($atomid as xs:string, $datatype as element()) as xs:string+ {
    let $tag := conf:param('atom-tag-name')
    let $tokens := tokenize(substring-after($atomid, $tag), '/')[. != '']
    return
        typeswitch($datatype)
        case element(xrx:metadata) return subsequence($tokens, 2, count($tokens) - 2)
        default return $tokens
};

(:~
 : Extract the object type from an atom ID.
 :)
declare function data:object-type($atomid as xs:string, $datatype as element()) as xs:string {
    let $tag := conf:param('atom-tag-name')
    let $tokens := tokenize(substring-after($atomid, $tag), '/')[. != '']
    return $tokens[1]
};

(:~
 : Find an atom:entry by its atom:id in a collection.
 :)
declare function data:entry($base-collection-path as xs:string, $atomid as xs:string) {
    collection($base-collection-path)/atom:entry[atom:id = $atomid]
};

(:~
 : Construct the database collection path for metadata.
 :)
declare function data:base-collection-path(
    $object-type as xs:string,
    $object-uri-tokens as xs:string*,
    $metadata-scope as xs:string,
    $revision-flag as xs:boolean,
    $datatype as element()
) as xs:string {
    let $base :=
        if ($metadata-scope = 'private') then
            concat(
                conf:param('xrx-user-db-base-uri'),
                xmldb:get-current-user(),
                '/metadata.', $object-type
            )
        else
            concat(
                conf:param('atom-db-base-uri'),
                '/metadata.', $object-type, '.', $metadata-scope
            )
    let $tokens-path :=
        if (exists($object-uri-tokens)) then
            '/' || string-join($object-uri-tokens, '/')
        else ''
    return data:uri($base || $tokens-path)
};

(:~
 : Construct a feed URI.
 :)
declare function data:feed(
    $object-type as xs:string,
    $metadata-scope as xs:string,
    $revision-flag as xs:boolean,
    $datatype as element()
) as xs:string {
    data:base-collection-path($object-type, (), $metadata-scope, $revision-flag, $datatype)
};

declare function data:feed(
    $object-type as xs:string,
    $object-uri-tokens as xs:string*,
    $metadata-scope as xs:string,
    $revision-flag as xs:boolean,
    $datatype as element()
) as xs:string {
    data:base-collection-path($object-type, $object-uri-tokens, $metadata-scope, $revision-flag, $datatype)
};

(:~
 : Encode a URI for eXist-db collection paths.
 :)
declare function data:uri($uri as xs:string) as xs:anyURI {
    xs:anyURI(xmldb:encode-uri(xmldb:decode($uri)))
};
