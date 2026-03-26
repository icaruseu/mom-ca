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

declare variable $app-root := substring-before(
    system:get-module-load-path(), "/modules"
);

(:~
 : Render a page inside the default template.
 :)
declare function local:render-page($page as xs:string) as node() {

    let $page-path := $app-root || "/pages/" || $page || ".html"

    let $page-content :=
        if (doc-available($page-path)) then
            doc($page-path)
        else
            <div class="page-placeholder">
                <h2>{ $page }</h2>
                <p>This page has not been migrated yet.</p>
                <p><a href="home">Back to Home</a></p>
            </div>

    return $page-content
};

(: Entry point — read "page" parameter from controller.xql :)
let $page := request:get-parameter("page", "home")
return local:render-page($page)
