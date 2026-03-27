xquery version "3.1";

(:~
 : Fond module for MOM-CA.
 : Ported from mom/app/fond/fond.xqm and fonds.xqm.
 :)

module namespace fond = "http://www.monasterium.net/NS/fond";

declare namespace atom = "http://www.w3.org/2005/Atom";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace eag = "http://www.archivgut-online.de/eag";

import module namespace conf = "http://www.monasterium.net/NS/conf"
    at "../core/conf.xqm";
import module namespace metadata = "http://www.monasterium.net/NS/metadata"
    at "../metadata/metadata.xqm";

(:~
 : Get a fond entry by archive key and fond key.
 :)
declare function fond:get($archive-key as xs:string, $fond-key as xs:string) as element(atom:entry)? {
    let $coll := metadata:base-collection('fond', ($archive-key, $fond-key), 'public')
    return ($coll/atom:entry)[1]
};

(:~
 : Get all fonds for an archive.
 :)
declare function fond:by-archive($archive-key as xs:string) as element(atom:entry)* {
    let $coll := metadata:base-collection('fond', $archive-key, 'public')
    return $coll/atom:entry[.//ead:ead]
};

(:~
 : Get the display name of a fond.
 :)
declare function fond:name($entry as element(atom:entry)) as xs:string {
    normalize-space(($entry//ead:unittitle/text())[1])
};

(:~
 : Get the fond key from an entry.
 :)
declare function fond:key($entry as element(atom:entry)) as xs:string {
    let $tokens := tokenize(substring-after($entry/atom:id/text(), conf:param('atom-tag-name')), '/')[. != '']
    return $tokens[last()]
};

(:~
 : Get the archive key from a fond entry.
 :)
declare function fond:archive-key($entry as element(atom:entry)) as xs:string {
    let $tokens := tokenize(substring-after($entry/atom:id/text(), conf:param('atom-tag-name')), '/')[. != '']
    return $tokens[2]
};

(:~
 : Build a permalink for a fond.
 :)
declare function fond:permalink($entry as element(atom:entry)) as xs:string {
    let $archive-key := fond:archive-key($entry)
    let $fond-key := fond:key($entry)
    return concat(conf:param('request-root'), $archive-key, '/', $fond-key, '/fond')
};

(:~
 : Get the archive entry for a fond.
 :)
declare function fond:archive($entry as element(atom:entry)) as element(atom:entry)? {
    let $archive-key := fond:archive-key($entry)
    return (metadata:base-collection('archive', $archive-key, 'public')/atom:entry)[1]
};

(:~
 : Get recently published fonds (top 10).
 :)
declare function fond:recently-published() as element(atom:entry)* {
    let $all-fonds := metadata:base-collection('fond', 'public')/atom:entry[.//ead:ead]
    let $sorted :=
        for $entry in $all-fonds
        let $published := $entry/atom:published/text()
        where $published != ''
        order by $published descending
        return $entry
    return subsequence($sorted, 1, 10)
};

(:~
 : Count charters in a fond.
 :)
declare function fond:charter-count($archive-key as xs:string, $fond-key as xs:string) as xs:integer {
    let $coll := metadata:base-collection('charter', ($archive-key, $fond-key), 'public')
    return count($coll/atom:entry)
};
