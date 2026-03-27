xquery version "3.1";

(:~
 : Page rendering module for MOM-CA.
 : Loads the default.html template and injects page content.
 :
 : Priority order for page resolution:
 : 1. modules/pages/{page}.xql — dynamic XQuery page (returns XML/HTML nodes)
 : 2. pages/{page}.html — static HTML fragment
 : 3. Fallback placeholder
 :)

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

declare variable $local:app-root := "/db/apps/mom-ca";

declare function local:load-html($path as xs:string) as node()* {
    if (util:binary-doc-available($path)) then
        util:parse-html(util:binary-to-string(util:binary-doc($path), "UTF-8"))
    else if (doc-available($path)) then
        doc($path)
    else
        ()
};

(:~
 : Try to execute a dynamic XQuery page module.
 : Returns the result or empty if no .xql exists.
 :)
declare function local:exec-xql($page as xs:string) as node()* {
    let $xql-path := $local:app-root || "/modules/page-" || $page || ".xql"
    return
        if (util:binary-doc-available($xql-path)) then
            try {
                util:eval(util:binary-doc($xql-path), false(),
                    (xs:QName("request-path"), request:get-parameter("request-path", "")))
            } catch * {
                <div class="card" style="border-left:4px solid var(--color-accent)">
                    <div class="card-header">Error in {$page}.xql</div>
                    <div class="card-body">
                        <p><strong>{$err:code}</strong></p>
                        <p>{$err:description}</p>
                        <p class="text-small text-muted">XQL path: {$xql-path}</p>
                    </div>
                </div>
            }
        else ()
};

let $page := request:get-parameter("page", "home")

(: 1. Try dynamic XQuery page :)
let $xql-content := local:exec-xql($page)

(: 2. Try static HTML page :)
let $html-content :=
    if (exists($xql-content)) then ()
    else local:load-html($local:app-root || "/pages/" || $page || ".html")

(: 3. Fallback :)
let $content :=
    if (exists($xql-content)) then $xql-content
    else if (exists($html-content)) then $html-content
    else
        <div class="page-placeholder">
            <h2>{ $page }</h2>
            <p>This page has not been migrated yet.</p>
            <p><a href="home">Back to Home</a></p>
        </div>

(: Inject into template :)
let $template-path := $local:app-root || "/templates/default.html"
let $template-str := util:binary-to-string(util:binary-doc($template-path), "UTF-8")
let $content-str := serialize($content, map { "method": "html", "indent": true() })
let $merged := replace($template-str, "<!-- Page content injected by view.xql -->", $content-str)

return
    response:stream(
        util:parse-html($merged),
        "method=html5 media-type=text/html"
    )
