xquery version "3.1";

(:~
 : URL Rewriting Controller for MOM-CA eXist-db App Package
 :
 : Replaces the legacy XRX resolver system. Handles all URL routing
 : for the app deployed at /db/apps/mom-ca/.
 :
 : eXist-db binds these variables before invoking the controller:
 :   $exist:root       - root of the app on disk
 :   $exist:prefix     - URL prefix (/exist or empty)
 :   $exist:controller - path to this controller (e.g. /db/apps/mom-ca)
 :   $exist:path       - remaining path after the controller
 :   $exist:resource   - last segment of $exist:path
 :)

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;


(: =====================================================================
   Helper: extract file extension from a resource name
   ===================================================================== :)
declare function local:get-extension($resource as xs:string) as xs:string? {
    let $parts := tokenize($resource, '\.')
    return
        if (count($parts) gt 1) then
            lower-case($parts[last()])
        else
            ()
};

(: =====================================================================
   Helper: check whether a resource is a static file type
   ===================================================================== :)
declare function local:is-static-resource($resource as xs:string) as xs:boolean {
    local:get-extension($resource) = (
        'js', 'css',
        'png', 'jpg', 'jpeg', 'gif', 'svg', 'ico',
        'woff', 'woff2', 'ttf', 'eot', 'otf',
        'map', 'json'
    )
};

(: =====================================================================
   All known page routes (mainwidget patterns).
   The last URI segment is looked up in this set.
   ===================================================================== :)
declare variable $local:page-routes := (
    (: Home and top-level navigation :)
    'home', 'fonds', 'publish-fond', 'subdivision', 'country',

    (: My workspace :)
    'my-archive', 'my-users', 'mailing-list', 'oai-interface',

    (: Archive management :)
    'archive', 'edit-archive', 'manage-archivists', 'new-archive', 'remove-archive',

    (: Charter views and editing :)
    'charter', 'my-charter', 'saved-charter', 'edit-charter',
    'revise-charter', 'charter-to-publish', 'imported-charter',

    (: Fond management :)
    'fond', 'fond-preferences', 'imported-fond', 'new-fond', 'edit-fond', 'remove-fond',

    (: Collection management :)
    'collection', 'collections', 'my-collection', 'my-collections',
    'new-collection', 'publish-collection', 'imported-collection',
    'edit-collection-info', 'edit-my-collection-info', 'remove-collection',
    'my-collections-edit', 'my-collection-remove',
    'collection-register', 'charters-on-map',
    'edit', (: my-collection-charter-edit :)

    (: Search :)
    'search', 'search-result',

    (: Authentication and user accounts :)
    'login', 'login2', 'registration', 'registration-successful',
    'my-account', 'change-password', 'remove-account',
    'request-password', 'reset-password',

    (: Miscellaneous pages :)
    'bookmarks', 'glossar', 'images',

    (: Momathon :)
    'momathon', 'momathon-tutorial', 'momathon-charters',
    'momathon-detail', 'momathon-result', 'momathon-overview',

    (: Import :)
    'charters', 'cei-import', 'ead-import', 'excel-import',
    'xml-import', 'vdu-import', 'sql-import', 'oai-import',
    'import-charters', 'import-charters-howto', 'tag-library',

    (: Workflow and moderation :)
    'saved-charters', 'saved-vocabularies', 'released-charters',
    'charters-to-publish', 'vocabularies-to-publish',
    'charter-versions', 'charter-version-difference', 'patch-charter',

    (: Translation :)
    'translate', 'translation-progress',

    (: Role management :)
    'manage-roles', 'apply-role',

    (: SKOS and error :)
    'skos-editor', 'error',

    (: Image tools :)
    'user-image-collections', 'image-collections', 'view-images',
    'annotation-requests', 'image-requests', 'image-tools',
    'annotation-overview', 'demo-annotation',

    (: Navigation :)
    'year-navi', 'block-navi', 'goto-search', 'index',

    (: Documentation and static HTML :)
    'editmom-documentation', 'static-htdoc', 'edit-htdoc',

    (: Embedded widgets :)
    'charter-editor', 'charter-subeditor', 'moderator-info'
);

(: =====================================================================
   Htdoc page names — served via modules/view.xql with page=htdoc
   ===================================================================== :)
declare variable $local:htdoc-routes := (
    'contact', 'help', 'terms-of-use'
);


(: =====================================================================
   MAIN ROUTING LOGIC
   ===================================================================== :)

let $path     := $exist:path
let $resource := $exist:resource

(: Derive the last path segment for page matching :)
let $segments    := tokenize(replace($path, '^/|/$', ''), '/')
let $last-segment := $segments[last()]

return

(: -----------------------------------------------------------------
   1. Root request → redirect to "home"
   ----------------------------------------------------------------- :)
if ($path = ('', '/')) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{$exist:controller}/home"/>
    </dispatch>

(: -----------------------------------------------------------------
   2. Static resources — serve directly from resources/ directory
   ----------------------------------------------------------------- :)
else if (local:is-static-resource($resource)) then
    let $rel-path := replace($path, '^/', '')
    let $ext := local:get-extension($resource)
    let $mime := switch ($ext)
        case 'js'    return 'application/javascript'
        case 'mjs'   return 'application/javascript'
        case 'css'   return 'text/css'
        case 'json'  return 'application/json'
        case 'svg'   return 'image/svg+xml'
        case 'map'   return 'application/json'
        case 'woff'  return 'font/woff'
        case 'woff2' return 'font/woff2'
        case 'ttf'   return 'font/ttf'
        default      return ()
    return
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$exist:controller}/resources/{$rel-path}">
                { if ($mime) then <set-header name="Content-Type" value="{$mime}"/> else () }
                <cache-control cache="yes"/>
            </forward>
        </dispatch>

(: -----------------------------------------------------------------
   3. Fore resources — XForms engine assets at /fore/*
   ----------------------------------------------------------------- :)
else if (starts-with($path, '/fore/')) then
    let $fore-path := substring-after($path, '/fore/')
    let $ext := local:get-extension($fore-path)
    let $mime := if ($ext = 'js') then 'application/javascript'
                 else if ($ext = 'css') then 'text/css'
                 else ()
    return
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$exist:controller}/resources/fore/{$fore-path}">
                { if ($mime) then <set-header name="Content-Type" value="{$mime}"/> else () }
                <cache-control cache="yes"/>
            </forward>
        </dispatch>

(: -----------------------------------------------------------------
   4. API / Service endpoints → modules/api.xql
   ----------------------------------------------------------------- :)
else if (starts-with($path, '/service/') or starts-with($path, '/api/')) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/modules/api.xql">
            <add-parameter name="request-path" value="{$path}"/>
        </forward>
    </dispatch>

(: -----------------------------------------------------------------
   5. OAI-PMH endpoint → modules/api.xql with oai flag
   ----------------------------------------------------------------- :)
else if ($path = '/oai') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/modules/api.xql">
            <add-parameter name="request-path" value="{$path}"/>
            <add-parameter name="oai" value="true"/>
        </forward>
    </dispatch>

(: -----------------------------------------------------------------
   7. Htdoc routes (contact, help, terms-of-use)
      Checked before generic page routes so they get special params.
   ----------------------------------------------------------------- :)
else if ($last-segment = $local:htdoc-routes) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/modules/view.xql">
            <add-parameter name="page"  value="htdoc"/>
            <add-parameter name="htdoc" value="{$last-segment}"/>
            <add-parameter name="request-path" value="{$path}"/>
        </forward>
    </dispatch>

(: -----------------------------------------------------------------
   6. Page routes — all mainwidget patterns
      The last URI segment determines the page name.
   ----------------------------------------------------------------- :)
else if ($last-segment = $local:page-routes) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/modules/view.xql">
            <add-parameter name="page" value="{$last-segment}"/>
            <add-parameter name="request-path" value="{$path}"/>
        </forward>
    </dispatch>

(: -----------------------------------------------------------------
   8. Atom protocol — /atom/* → modules/atom.xql (placeholder)
   ----------------------------------------------------------------- :)
else if (starts-with($path, '/atom/') or $path = '/atom') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/modules/atom.xql">
            <add-parameter name="request-path" value="{$path}"/>
        </forward>
    </dispatch>

(: -----------------------------------------------------------------
   9. CSS aggregation — /css/* → modules/css.xql (placeholder)
   ----------------------------------------------------------------- :)
else if (starts-with($path, '/css/')) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/modules/css.xql">
            <add-parameter name="request-path" value="{$path}"/>
        </forward>
    </dispatch>

(: -----------------------------------------------------------------
   10. Default fallback → error page
   ----------------------------------------------------------------- :)
else
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/modules/view.xql">
            <add-parameter name="page" value="error"/>
            <add-parameter name="request-path" value="{$path}"/>
        </forward>
    </dispatch>
