xquery version "3.1";

(:~
 : Template wrapper for dynamic XQL pages.
 : Called as a view step in the controller pipeline after page-{name}.xql.
 : Takes the output from the page and wraps it in the default.html template.
 :)

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

declare variable $local:app-root := "/db/apps/mom-ca";

(: The page content comes from the request attribute set by the pipeline :)
let $content := request:get-data()

let $template-path := $local:app-root || "/templates/default.html"
let $template-str := util:binary-to-string(util:binary-doc($template-path), "UTF-8")

let $content-str :=
    if (exists($content)) then
        serialize($content, map { "method": "html", "indent": true() })
    else
        "<p>No content</p>"

let $merged := replace($template-str, "<!-- Page content injected by view.xql -->", $content-str)

return
    response:stream(
        util:parse-html($merged),
        "method=html5 media-type=text/html"
    )
