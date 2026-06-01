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

module namespace skos-edit = "http://www.monasterium.net/NS/skos-edit";

import module namespace conf = "http://www.monasterium.net/NS/conf"
at "../xrx/conf.xqm";
import module namespace metadata = "http://www.monasterium.net/NS/metadata"
at "../metadata/metadata.xqm";

declare namespace xmldb = "http://exist-db.org/xquery/xmldb";
declare namespace atom = "http://www.w3.org/2005/Atom";

(: splits up the given atom:id and returns those parts after the atom-tag :)
declare function skos-edit:object-uri-tokens($atomid as xs:string, $atom-tag-name as xs:string) as xs:string* {
    
    let $object-uri := substring-after($atomid, $atom-tag-name)
    let $object-uri-tokens := tokenize($object-uri, '/')
    return
        subsequence($object-uri-tokens, 2)
};

(: single argument version of the above function :)
declare function skos-edit:object-uri-tokens($atomid as xs:string) as xs:string* {
    
    skos-edit:object-uri-tokens($atomid, conf:param('atom-tag-name'))
};


(: returns the type of file of the given atom:id - fond charter, collection charter, or vocabulary file :)
declare function skos-edit:context($atomid as xs:string, $atom-tag-name as xs:string) as xs:string {
    
    let $tokens := skos-edit:object-uri-tokens($atomid, $atom-tag-name)
    return
        if ($tokens[1] = 'controlledVocabulary') then
            'vocab'
        else
            if (count($tokens) = 4) then
                'fond'
            else
                'collection'
};

(: creates the file name of the vocabulary file based on the atom:id :)
declare function skos-edit:translate-filename($atomid as xs:string) as xs:string {
    
    let $shorten := substring-after($atomid, 'controlledVocabulary/')
    let $add-ending := concat($shorten, '.xml')
    return
        xmldb:encode($add-ending)
};

(: find the name (without extension) of an existing public vocabulary file from its atom:id :)
declare function skos-edit:get-vocab-filename($atomid as xs:string) as xs:string* {
    
    let $vocab-collection := metadata:base-collection('controlledVocabulary', 'public')
    let $vocab-entry := $vocab-collection//atom:id[. = $atomid]/ancestor::atom:entry
    let $vocab-uri := base-uri($vocab-entry)
    let $vocab-name := substring-before(substring-after($vocab-uri, 'metadata.controlledVocabulary.public/'), '.xml')
    return
        $vocab-name
};

(: check well-formedness of an XML element:)
declare function skos-edit:is-wellformed($xml as element()){
    try { $xml/* } catch * { <error>{ $err:description }</error> }
};
