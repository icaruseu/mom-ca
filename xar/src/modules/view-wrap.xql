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

(: User nav — same logic as view.xql :)
let $session-user := try { string(session:get-attribute('mom.user')) } catch * { '' }
let $xquery-user := string(request:get-attribute('xquery.user'))
let $is-logged-in := ($session-user != '' and $session-user != ())
    or ($xquery-user != 'guest' and $xquery-user != '')
let $display-user := if ($session-user != '' and $session-user != ()) then $session-user else $xquery-user

let $user-nav :=
    if ($is-logged-in) then
        '<li class="text-small" style="display:flex;align-items:center;gap:8px;">'
        || '<span style="color:var(--color-text-muted);">' || $display-user || '</span>'
        || '<a href="#" onclick="fetch(''/mom/api/auth/logout'',{method:''POST'',credentials:''same-origin''}).then(function(){window.location.href=''/mom/home'';});return false;" class="nav-cta">Logout</a>'
        || '</li>'
    else
        '<li><a href="/mom/login" class="nav-cta">Login</a></li>'

let $auth-nav :=
    if ($is-logged-in) then
        '<li><a href="/mom/my-collections">My Collections</a></li>'
        || '<li><a href="/mom/bookmarks">Bookmarks</a></li>'
    else ''

(: Template injection :)
let $placeholder := "<!-- Page content injected by view.xql -->"
let $auth-placeholder := "<!-- auth-nav injected by view.xql -->"
let $user-placeholder := "<!-- user-nav injected by view.xql -->"

let $merged := substring-before($template-str, $placeholder) || $content-str || substring-after($template-str, $placeholder)
let $merged := substring-before($merged, $auth-placeholder) || $auth-nav || substring-after($merged, $auth-placeholder)
let $merged := substring-before($merged, $user-placeholder) || $user-nav || substring-after($merged, $user-placeholder)

let $_ := response:set-header("Cache-Control", "no-cache, no-store, must-revalidate")

return
    response:stream(
        util:parse-html($merged),
        "method=html5 media-type=text/html"
    )
