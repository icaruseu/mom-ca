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


module namespace resolver = "http://www.monasterium.net/NS/resolver";

declare namespace atom = "http://www.w3.org/2005/Atom";
declare namespace request = "http://exist-db.org/xquery/request";
declare namespace xrx = "http://www.monasterium.net/NS/xrx";

(: Resolves to the requested resource or an error page if the current request is requesting a non-existing mom-ca
 : resource like a invalid charter url :)
declare function resolver:resolve($live-project-db-base-collection) as element()* {
    let $uri := resolver:get-clean-request-uri()
    let $first-match := (
        for $uri-pattern in $live-project-db-base-collection//xrx:resolver/xrx:map/xrx:uripattern
        let $priority := ($uri-pattern/parent::xrx:map/@priority/string(), '999')[1]
        order by $priority ascending
        return
            if (matches($uri, $uri-pattern)) then
                $uri-pattern/parent::xrx:map
            else
                ()
    )[1]
    return
        if (resolver:is-resource-existing($uri)) then
            $first-match
        else
            <xrx:map>
                <xrx:uripattern>/error$</xrx:uripattern>
                <xrx:mode>mainwidget</xrx:mode>
                <xrx:atomid>tag:www.monasterium.net,2011:/mom/widget/error</xrx:atomid>
            </xrx:map>
};

(:  Returns true if the provided uri represents either any non-metadata resource like a stylesheet or
 :  an existing metadata resource. Returns false for non-existing mom-ca resources :)
declare function resolver:is-resource-existing($uri as xs:string) as xs:boolean {
    let $uri-tokens := tokenize($uri, "/")
    let $resource-type := $uri-tokens[last()]
    return
        if ($resource-type = ("archive", "charter", "collection", "fond", "images", "my-charter", "my-collection")) then
            resolver:is-metadata-resource-existing($uri-tokens, $resource-type)
        else
            true()
};

(: Returns true if the provided URI tokens and resource type stand for an existing metadata resource, e.g. an existing
 : charter or archive. Returns false if the resource doesn't exist. :)
declare function resolver:is-metadata-resource-existing($uri-tokens as xs:string*, $resource-type as xs:string) as xs:boolean {
    let $resource-db-paths := resolver:create-possible-resource-db-paths($uri-tokens, $resource-type)
    let $existing-resources :=
        for $resource-db-path in $resource-db-paths
        return
            if (exists(doc($resource-db-path))) then
                $resource-db-path
            else
                ()
    let $is-resource-existing := not(empty($existing-resources))
    return
        if ($is-resource-existing = false() and $resource-type = ("collection", "my-charter", "my-collection")) then
            resolver:is-private-metadata-resource-existing($uri-tokens, $resource-type)
        else
            $is-resource-existing
};

(: Tests whether or not a private resource (collection or charter) as indicated by the provided URI tokens and resource type is existing :)
declare function resolver:is-private-metadata-resource-existing($uri-tokens as xs:string*, $resource-type as xs:string) as xs:boolean {
    let $atomid-string :=
        if ($resource-type = "my-charter") then
            "tag:www.monasterium.net,2011:/charter/" || $uri-tokens[last() - 2] || "/" || $uri-tokens[last() - 1]
        else
            "tag:www.monasterium.net,2011:/mycollection/" || $uri-tokens[last() - 1]
    let $atomid := collection("/db/mom-data/xrx.user")//atom:id[. = $atomid-string]
    return
        exists($atomid)
};

(: Gets the decoded URI of the current request without leading slash "/" :)
declare function resolver:get-clean-request-uri() as xs:string {
    let $encoded-uri := request:get-uri()
    let $decoded-uri := xmldb:decode($encoded-uri)
    return
        if (starts-with($decoded-uri, "/")) then
            substring-after($decoded-uri, "/")
        else
            $decoded-uri
};

(: Creates mom-ca database resource paths from the provided URI tokens and resource type. Returns all possible database paths to
 : the resource or an empty sequence. :)
declare function resolver:create-possible-resource-db-paths($uri-tokens as xs:string*, $resource-type as xs:string) as xs:string* {
    let $paths :=
        switch ($resource-type)
            case "archive" return
                (
                    "/db/mom-data/metadata.archive.public/" || $uri-tokens[last() - 1] || "/" || $uri-tokens[last() - 1] || ".eag.xml"
                )
            case "charter" return
                (
                    "/db/mom-data/metadata.charter.public/" || $uri-tokens[last() - 3] || "/" || $uri-tokens[last() - 2] || "/" || $uri-tokens[last() - 1] || ".cei.xml",
                    "/db/mom-data/metadata.charter.public/" || $uri-tokens[last() - 2] || "/" || $uri-tokens[last() - 1] || ".cei.xml",
                    "/db/mom-data/metadata.charter.public/" || $uri-tokens[last() - 2] || "/" || $uri-tokens[last() - 1] || ".charter.xml"
                )
            case "collection" return
                (
                    "/db/mom-data/metadata.collection.public/" || $uri-tokens[last() - 1] || "/" || $uri-tokens[last() - 1] || ".cei.xml",
                    "/db/mom-data/metadata.mycollection.public/" || $uri-tokens[last() - 1] || "/" || $uri-tokens[last() - 1] || ".mycollection.xml"
                )
            case "fond" return
                (
                    "/db/mom-data/metadata.fond.public/" || $uri-tokens[last() - 2] || "/" || $uri-tokens[last() - 1] || "/" || $uri-tokens[last() - 1] || ".ead.xml"
                )
            case "images" return
                (
                    "/db/mom-data/metadata.fond.public/" || $uri-tokens[last() - 2] || "/" || $uri-tokens[last() - 1] || "/" || $uri-tokens[last() - 1] || ".ead.xml",
                    "/db/mom-data/metadata.collection.public/" || $uri-tokens[last() - 1] || "/" || $uri-tokens[last() - 1] || ".cei.xml",
                    "/db/mom-data/metadata.mycollection.public/" || $uri-tokens[last() - 1] || "/" || $uri-tokens[last() - 1] || ".mycollection.xml"
                )
            default return
                ()
    return
        for $path in $paths
        return
            xmldb:encode($path)
};