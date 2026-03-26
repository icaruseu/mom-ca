xquery version "3.1";

(:~
 : Page rendering module for MOM-CA.
 :
 : Replaces the legacy main.xql mode-mainwidget dispatcher. Receives a
 : "page" parameter from controller.xql, loads the default HTML template,
 : and injects page-specific content into it.
 :)

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

(:~
 : Resolve the app root collection path.
 : Tries multiple strategies since eXist-db versions differ.
 :)
declare function local:app-root() as xs:string {
    let $module-path := system:get-module-load-path()
    return
        (: If loaded from the database :)
        if (starts-with($module-path, "xmldb:exist://")) then
            substring-before(
                substring-after($module-path, "xmldb:exist://"),
                "/modules"
            )
        else if (starts-with($module-path, "/db/")) then
            substring-before($module-path, "/modules")
        else
            (: Fallback: standard app location :)
            "/db/apps/mom-ca"
};

(:~
 : Render a page inside the default template.
 :)
declare function local:render-page($page as xs:string) as node() {

    let $app-root  := local:app-root()
    let $page-path := $app-root || "/pages/" || $page || ".html"

    let $page-content :=
        if (doc-available($page-path)) then
            doc($page-path)
        else
            <div class="page-placeholder">
                <h2>{ $page }</h2>
                <p>This page has not been migrated yet.</p>
                <p>App root: { $app-root }</p>
                <p>Tried: { $page-path }</p>
                <p>Module path: { system:get-module-load-path() }</p>
                <p><a href="home">Back to Home</a></p>
            </div>

    return $page-content
};

(: Entry point — read "page" parameter from controller.xql :)
let $page := request:get-parameter("page", "home")
return local:render-page($page)
