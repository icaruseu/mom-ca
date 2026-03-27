xquery version "3.1";

(:~
 : Metadata module for MOM-CA.
 : Ported from core/app/metadata/metadata.xqm.
 :)

module namespace metadata = "http://www.monasterium.net/NS/metadata";

declare namespace atom = "http://www.w3.org/2005/Atom";
declare namespace xrx = "http://www.monasterium.net/NS/xrx";

import module namespace data = "http://www.monasterium.net/NS/data"
    at "/db/apps/mom-ca/modules/data/data.xqm";
import module namespace conf = "http://www.monasterium.net/NS/conf"
    at "/db/apps/mom-ca/modules/core/conf.xqm";

declare variable $metadata:datatype := <xrx:metadata/>;

(:~
 : Find an atom:entry by ID in a collection.
 :)
declare function metadata:entry($base-collection-path as xs:string, $atomid as xs:string) as element()* {
    data:entry($base-collection-path, $atomid)
};

(:~
 : Extract the object ID from an atom ID.
 :)
declare function metadata:objectid($atomid as xs:string) as xs:string {
    data:objectid($atomid, $metadata:datatype)
};

(:~
 : Extract URI tokens from an atom ID.
 :)
declare function metadata:uri-tokens($atomid as xs:string) as xs:string+ {
    data:uri-tokens($atomid, $metadata:datatype)
};

(:~
 : Extract the object type from an atom ID.
 :)
declare function metadata:object-type($atomid as xs:string) as xs:string {
    data:object-type($atomid, $metadata:datatype)
};

(:~
 : Compose an atom ID from type and URI tokens.
 :)
declare function metadata:atomid($object-type as xs:string, $object-uri-tokens as xs:string*) as xs:string {
    let $tag := conf:param('atom-tag-name')
    return concat($tag, $object-type, '/', string-join($object-uri-tokens, '/'))
};

(:~
 : Construct an entry filename.
 :)
declare function metadata:entryname($object-type as xs:string, $objectid as xs:string) as xs:string {
    xmldb:encode($objectid) || '.' || $object-type || '.xml'
};

(:~
 : Get a base collection by type and scope (no URI tokens).
 :)
declare function metadata:base-collection(
    $object-type as xs:string,
    $metadata-scope as xs:string
) as node()* {
    collection(
        metadata:base-collection-path($object-type, $metadata-scope)
    )
};

(:~
 : Get a base collection by type, URI tokens, and scope.
 :)
declare function metadata:base-collection(
    $object-type as xs:string,
    $object-uri-tokens as xs:string*,
    $metadata-scope as xs:string
) as node()* {
    collection(
        metadata:base-collection-path($object-type, $object-uri-tokens, $metadata-scope)
    )
};

(:~
 : Construct collection path without URI tokens.
 :)
declare function metadata:base-collection-path(
    $object-type as xs:string,
    $metadata-scope as xs:string
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
    return data:uri($base)
};

(:~
 : Construct collection path with URI tokens.
 :)
declare function metadata:base-collection-path(
    $object-type as xs:string,
    $object-uri-tokens as xs:string*,
    $metadata-scope as xs:string
) as xs:string {
    data:base-collection-path($object-type, $object-uri-tokens, $metadata-scope, false(), $metadata:datatype)
};
