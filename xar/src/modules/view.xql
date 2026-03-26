xquery version "3.1";

(:~
 : Page rendering module for MOM-CA.
 :
 : Replaces the legacy main.xql mode-mainwidget dispatcher. Receives a
 : "page" parameter from controller.xql, loads the default HTML template,
 : and injects page-specific content into it.
 :
 : This is a minimal dispatcher that will be extended as more pages are
 : migrated from XRX widgets to Fore-based HTML pages.
 :)

module namespace view = "http://www.monasterium.net/NS/view";

import module namespace config = "http://www.monasterium.net/NS/config"
    at "config.xqm";

(:~
 : Render a page inside the default template.
 :
 : @param $page  the page identifier passed by controller.xql
 : @return       a complete HTML document
 :)
declare function view:render-page($page as xs:string) as node() {

    let $app-root  := $config:app-root
    let $page-path := $app-root || "/pages/" || $page || ".html"

    (: Try to load the page-specific HTML fragment from pages/ :)
    let $page-content :=
        if (doc-available($page-path)) then
            doc($page-path)
        else
            <div class="page-placeholder">
                <h1>{ $page }</h1>
                <p>This page has not been migrated yet.</p>
            </div>

    (: Load the default HTML shell :)
    let $template := doc($app-root || "/templates/default.html")

    return $template
};

(:~
 : Entry point called by controller.xql via forward.
 :
 : Reads the "page" request parameter and delegates to view:render-page().
 :)
declare function view:dispatch() {
    let $page := request:get-parameter("page", "home")
    return view:render-page($page)
};

(: Self-invocation when called as a main module :)
view:dispatch()
