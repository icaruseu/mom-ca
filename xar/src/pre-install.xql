xquery version "3.1";

(:~
 : Pre-installation script for the MOM-CA eXist-db application package.
 :
 : Deploys collection-level index configuration files (collection.xconf) into
 : /db/system/config/ so that the required full-text and range indexes are in
 : place before the application data is used.
 :
 : The source .xconf files are stored in the collection-configs/ directory of
 : the XAR package and are mapped to their target paths under /db/system/config/
 : during installation.
 :)

import module namespace xmldb = "http://exist-db.org/xquery/xmldb";

(: Passed by the package manager :)
declare variable $home external;
declare variable $dir  external;
declare variable $target external;

(:~
 : Store a collection.xconf file in the system configuration hierarchy.
 :
 : @param $source-name  filename inside collection-configs/ within the package
 : @param $target-collection  absolute path under /db/system/config/ where
 :        the file will be stored as collection.xconf
 :)
declare function local:deploy-xconf(
    $source-name as xs:string,
    $target-collection as xs:string
) as empty-sequence() {
    let $source-path := $dir || "/collection-configs/" || $source-name
    let $source-doc  := doc($source-path)
    return
        if (exists($source-doc))
        then (
            (: ensure the target collection exists :)
            let $parts := tokenize($target-collection, "/")[. ne ""]
            let $_ :=
                for $i in 1 to count($parts)
                let $parent := "/" || string-join(subsequence($parts, 1, $i - 1), "/")
                let $child  := $parts[$i]
                return
                    if (xmldb:collection-available($parent || "/" || $child))
                    then ()
                    else xmldb:create-collection($parent, $child)
            return
                xmldb:store($target-collection, "collection.xconf",
                            $source-doc, "application/xml")
        )
        else
            util:log("WARN",
                "MOM-CA pre-install: source config not found: " || $source-path)
};

(: ===== Deploy all collection configuration files ===== :)

(: /db/mom-data :)
local:deploy-xconf(
    "mom-data.xconf",
    "/db/system/config/db/mom-data"),

(: /db/mom-data/metadata.charter.public :)
local:deploy-xconf(
    "charter-public.xconf",
    "/db/system/config/db/mom-data/metadata.charter.public"),

(: /db/mom-data/metadata.collection.public :)
local:deploy-xconf(
    "collection-public.xconf",
    "/db/system/config/db/mom-data/metadata.collection.public"),

(: /db/mom-data/metadata.imagecollections :)
local:deploy-xconf(
    "imagecollections.xconf",
    "/db/system/config/db/mom-data/metadata.imagecollections"),

(: /db/mom-data/xrx.i18n :)
local:deploy-xconf(
    "i18n.xconf",
    "/db/system/config/db/mom-data/xrx.i18n"),

(: /db/mom-data/xrx.user :)
local:deploy-xconf(
    "user.xconf",
    "/db/system/config/db/mom-data/xrx.user")
