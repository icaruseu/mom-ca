xquery version "3.1";

(:~
 : Application configuration module for MOM-CA.
 :
 : Provides shared constants and helper functions used across all
 : modules (view.xql, api.xql, etc.). Reads values from repo.xml
 : and expath-pkg.xml at deploy time.
 :)

module namespace config = "http://www.monasterium.net/NS/config";

declare namespace repo = "http://exist-db.org/xquery/repo";
declare namespace expath = "http://expath.org/ns/pkg";


(: Path to this app's root collection in the database :)
declare variable $config:app-root :=
    let $raw-uri := system:get-module-load-path()
    return
        (: Strip /modules from the path to get the app root :)
        if (starts-with($raw-uri, "xmldb:exist://")) then
            substring-before($raw-uri, "/modules")
        else
            $raw-uri || "/.."
;

(: Package metadata from expath-pkg.xml :)
declare variable $config:expath-descriptor :=
    doc($config:app-root || "/expath-pkg.xml")/expath:package;

declare variable $config:app-name    := $config:expath-descriptor/@name/string();
declare variable $config:app-version := $config:expath-descriptor/@version/string();
declare variable $config:app-abbrev  := $config:expath-descriptor/@abbrev/string();

(: Repository metadata from repo.xml :)
declare variable $config:repo-descriptor :=
    doc($config:app-root || "/repo.xml")/repo:meta;

(:~
 : Resolve the app root as a URL-safe path for use in HTML templates.
 :)
declare function config:app-root-link($node as node(), $model as map(*)) {
    element { node-name($node) } {
        attribute href { request:get-context-path() || "/" || $config:app-abbrev || "/" },
        $node/node()
    }
};

(:~
 : Return the application title for use in templates.
 :)
declare function config:app-title($node as node(), $model as map(*)) {
    $config:expath-descriptor/expath:title/text()
};

(:~
 : Return the current year for copyright notices.
 :)
declare function config:current-year($node as node(), $model as map(*)) {
    year-from-date(current-date())
};
