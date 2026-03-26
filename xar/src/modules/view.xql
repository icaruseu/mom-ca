xquery version "3.1";

(:~
 : Page rendering module for MOM-CA.
 : Loads the default.html template and injects page content.
 :)

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

declare function local:app-root() as xs:string {
    let $module-path := system:get-module-load-path()
    let $db-path :=
        if (starts-with($module-path, "xmldb:exist://")) then
            let $after := substring-after($module-path, "xmldb:exist://")
            return
                if (contains($after, "/db/")) then
                    "/db/" || substring-after($after, "/db/")
                else
                    $after
        else
            $module-path
    return
        if (contains($db-path, "/modules")) then
            substring-before($db-path, "/modules")
        else
            "/db/apps/mom-ca"
};

declare function local:load-html($path as xs:string) as node()* {
    if (util:binary-doc-available($path)) then
        util:parse-html(util:binary-to-string(util:binary-doc($path), "UTF-8"))
    else if (doc-available($path)) then
        doc($path)
    else
        ()
};

let $page := request:get-parameter("page", "home")
let $app-root := local:app-root()

(: Load page content :)
let $page-path := $app-root || "/pages/" || $page || ".html"
let $page-content := local:load-html($page-path)

let $content :=
    if (exists($page-content)) then
        $page-content
    else
        <div class="page-placeholder">
            <h2>{ $page }</h2>
            <p>This page has not been migrated yet.</p>
            <p><a href="home">Back to Home</a></p>
        </div>

(: Load template and inject content :)
let $template-path := $app-root || "/templates/default.html"
let $template := local:load-html($template-path)

return
    if (exists($template)) then
        (: Find the template HTML and inject page content into #content :)
        let $template-str := util:binary-to-string(util:binary-doc($template-path), "UTF-8")
        let $content-str := serialize($content, map { "method": "html", "indent": true() })
        let $merged := replace($template-str, "<!-- Page content injected by view.xql -->", $content-str)
        return
            response:stream(
                util:parse-html($merged),
                "method=html5 media-type=text/html"
            )
    else
        (: Fallback: serve page content directly :)
        $content
