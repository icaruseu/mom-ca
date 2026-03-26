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
    let $db-path :=
        if (starts-with($module-path, "xmldb:exist://")) then
            (: Strip xmldb:exist://embedded-eXist-server or xmldb:exist:// :)
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

(:~
 : Render a page inside the default template.
 :)
declare function local:render-page($page as xs:string) {

    let $app-root  := local:app-root()
    let $page-path := $app-root || "/pages/" || $page || ".html"

    return
        if (util:binary-doc-available($page-path)) then
            (: HTML pages stored as binary — serve as raw HTML :)
            let $binary := util:binary-doc($page-path)
            let $html := util:binary-to-string($binary, "UTF-8")
            return
                response:stream(
                    <html xmlns="http://www.w3.org/1999/xhtml">
                        <head>
                            <meta charset="UTF-8"/>
                            <title>MOM-CA — { $page }</title>
                            <script type="module" src="../resources/fore/fore.js"/>
                            <link rel="stylesheet" href="../resources/fore/fore.css"/>
                            <style>body {{ font-family: sans-serif; margin: 20px; }}</style>
                        </head>
                        <body>
                            { util:parse-html($html) }
                        </body>
                    </html>,
                    "method=html5 media-type=text/html"
                )
        else if (doc-available($page-path)) then
            (: XML pages stored as XML — return directly :)
            doc($page-path)
        else
            <html xmlns="http://www.w3.org/1999/xhtml">
                <head><meta charset="UTF-8"/><title>MOM-CA — { $page }</title></head>
                <body>
                    <h2>{ $page }</h2>
                    <p>This page has not been migrated yet.</p>
                    <p><a href="home">Back to Home</a></p>
                </body>
            </html>
};

(: Entry point — read "page" parameter from controller.xql :)
let $page := request:get-parameter("page", "home")
return local:render-page($page)
