xquery version "3.1";

(:~
 : Archive module for MOM-CA.
 : Ported from mom/app/archive/archive.xqm.
 :)

module namespace archive = "http://www.monasterium.net/NS/archive";

declare namespace atom = "http://www.w3.org/2005/Atom";
declare namespace eag = "http://www.archivgut-online.de/eag";

import module namespace conf = "http://www.monasterium.net/NS/conf"
    at "/db/apps/mom-ca/modules/core/conf.xqm";
import module namespace metadata = "http://www.monasterium.net/NS/metadata"
    at "/db/apps/mom-ca/modules/metadata/metadata.xqm";

declare variable $archive:metadata-object-type := 'archive';

(:~
 : Get all public archives.
 :)
declare function archive:all() as element(atom:entry)* {
    metadata:base-collection('archive', 'public')/atom:entry
};

(:~
 : Get an archive by its key (ID).
 :)
declare function archive:get($archive-key as xs:string) as element(atom:entry)? {
    let $coll := metadata:base-collection('archive', $archive-key, 'public')
    return ($coll/atom:entry)[1]
};

(:~
 : Get the display name of an archive.
 :)
declare function archive:name($entry as element(atom:entry)) as xs:string {
    normalize-space($entry//eag:autform/text())
};

(:~
 : Get the country of an archive.
 :)
declare function archive:country($entry as element(atom:entry)) as xs:string {
    normalize-space($entry//eag:country/text())
};

(:~
 : Build a permalink for an archive.
 :)
declare function archive:permalink($entry as element(atom:entry)) as xs:string {
    let $tokens := tokenize(substring-after($entry/atom:id/text(), conf:param('atom-tag-name')), '/')[. != '']
    let $archive-key := $tokens[last()]
    return concat(conf:param('request-root'), $archive-key, '/archive')
};

(:~
 : Get all archives grouped by country.
 :)
declare function archive:by-country() as map(*)* {
    let $archives := archive:all()
    for $entry in $archives
    let $country := archive:country($entry)
    where $country != ''
    group by $country
    order by $country
    return map {
        "country": $country,
        "archives": $entry
    }
};
