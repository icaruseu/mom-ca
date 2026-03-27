xquery version "3.1";

(:~
 : REST API dispatcher for MOM-CA.
 :
 : Invoked by controller.xql for all /api/* and /service/* requests.
 : Routes based on the request-path parameter.
 :
 : Endpoints:
 :   POST /api/auth/login   - authenticate a user
 :   POST /api/auth/logout  - end a session
 :   GET  /api/health       - application health check
 :)

declare namespace atom = "http://www.w3.org/2005/Atom";
declare namespace cei = "http://www.monasterium.net/NS/cei";

import module namespace config = "http://www.monasterium.net/NS/config"
    at "config.xqm";
import module namespace conf = "http://www.monasterium.net/NS/conf"
    at "/db/apps/mom-ca/modules/core/conf.xqm";

declare function local:login() {
    let $body     := util:binary-to-string(request:get-data())
    let $json     := parse-json($body)
    let $username := $json?username
    let $password := $json?password
    return
        if (not($username) or not($password)) then
            (
                response:set-status-code(400),
                map { "status": "error", "message": "Username and password are required" }
            )
        else if (xmldb:login('/db', $username, $password, true())) then
            let $_ := session:create()
            let $_ := session:set-attribute('mom.user', $username)
            let $_ := session:set-attribute('mom.pass', $password)
            let $sid := session:get-id()
            let $_ := response:set-header('Set-Cookie',
                'JSESSIONID=' || $sid || '; Path=/; HttpOnly; SameSite=Lax')
            return map {
                "status":  "ok",
                "message": "Login successful",
                "user":    $username
            }
        else
            (
                response:set-status-code(401),
                map { "status": "error", "message": "Invalid username or password" }
            )
};

declare function local:logout() {
    let $_ := try { session:invalidate() } catch * { () }
    let $_ := xmldb:login('/db', 'guest', 'guest')
    let $_ := response:set-header('Set-Cookie', 'JSESSIONID=; Path=/; Max-Age=0')
    return map {
        "status":  "ok",
        "message": "Logged out"
    }
};

(:~ Save a public charter to the user's private mycollection :)
declare function local:save-charter() {
    let $user := try { string(session:get-attribute('mom.user')) } catch * { '' }
    return
        if ($user = '') then (
            response:set-status-code(401),
            map { "status": "error", "message": "Login required" }
        )
        else
            let $body := parse-json(util:binary-to-string(request:get-data()))
            let $charter-atom-id := $body?charterId
            let $target-coll := $body?collectionId
            return
                if (not($charter-atom-id) or not($target-coll)) then (
                    response:set-status-code(400),
                    map { "status": "error", "message": "charterId and collectionId required" }
                )
                else
                    (: Parse atom:id to find source charter efficiently :)
                    let $tag := conf:param('atom-tag-name')
                    let $tokens := tokenize(substring-after($charter-atom-id, $tag), '/')[. ne '']
                    let $ctx-tokens := subsequence($tokens, 2, count($tokens) - 2)
                    let $charter-key := $tokens[last()]
                    let $source-path :=
                        if (count($ctx-tokens) = 1) then
                            '/db/mom-data/metadata.charter.public/' || $ctx-tokens[1]
                        else
                            '/db/mom-data/metadata.charter.public/' || string-join($ctx-tokens, '/')
                    let $source-entry :=
                        if (xmldb:collection-available($source-path)) then
                            (collection($source-path)/atom:entry[ends-with(atom:id, '/' || $charter-key)])[1]
                        else
                            let $fond-path := '/db/mom-data/metadata.fond.public/' || string-join($ctx-tokens, '/')
                            return if (xmldb:collection-available($fond-path)) then
                                (collection($fond-path)/atom:entry[ends-with(atom:id, '/' || $charter-key)])[1]
                            else ()

                    return
                        if (empty($source-entry)) then (
                            response:set-status-code(404),
                            map { "status": "error", "message": "Charter not found" }
                        )
                        else
                            (: Create target collection if needed :)
                            let $user-base := '/db/mom-data/xrx.user/' || $user || '/metadata.charter'
                            let $target-path := $user-base || '/' || $target-coll
                            let $_ := if (not(xmldb:collection-available($user-base))) then
                                xmldb:create-collection('/db/mom-data/xrx.user/' || $user, 'metadata.charter') else ()
                            let $_ := if (not(xmldb:collection-available($target-path))) then
                                xmldb:create-collection($user-base, $target-coll) else ()

                            (: Generate new charter ID and build private copy :)
                            let $new-id := util:uuid()
                            let $new-atom-id := $tag || '/charter/' || $target-coll || '/' || $new-id

                            let $private-entry :=
                                <atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
                                    <atom:id>{$new-atom-id}</atom:id>
                                    <atom:title/>
                                    <atom:published>{current-dateTime()}</atom:published>
                                    <atom:updated>{current-dateTime()}</atom:updated>
                                    <atom:author><atom:email>{$user}</atom:email></atom:author>
                                    <app:control xmlns:app="http://www.w3.org/2007/app">
                                        <app:draft>yes</app:draft>
                                    </app:control>
                                    {$source-entry/atom:content}
                                </atom:entry>

                            let $filename := $new-id || '.cei.xml'
                            let $_ := xmldb:store($target-path, $filename, $private-entry)
                            return map {
                                "status": "ok",
                                "message": "Charter saved to your collection",
                                "charterId": $new-atom-id,
                                "url": "/mom/" || $target-coll || "/" || $new-id || "/charter"
                            }
};

(:~ List the user's mycollections (for the save dialog) :)
declare function local:my-collections() {
    let $user := try { string(session:get-attribute('mom.user')) } catch * { '' }
    return
        if ($user = '') then (
            response:set-status-code(401),
            map { "status": "error", "message": "Login required" }
        )
        else
            let $mycoll-path := '/db/mom-data/xrx.user/' || $user || '/metadata.mycollection'
            let $entries := if (xmldb:collection-available($mycoll-path)) then
                collection($mycoll-path)/atom:entry else ()
            return map {
                "status": "ok",
                "collections": array {
                    for $e in $entries
                    let $id := tokenize($e/atom:id/text(), '/')[last()]
                    let $title := normalize-space(($e//cei:titleStmt/cei:title, $e//cei:title)[1])
                    return map {
                        "id": $id,
                        "title": if ($title ne '') then $title else $id
                    }
                }
            }
};

declare function local:health() {
    map {
        "status":  "ok",
        "app":     $config:app-name,
        "version": $config:app-version,
        "db":      system:get-version()
    }
};

let $request-path := request:get-parameter("request-path", "")
let $method := request:get-method()
return (
    response:set-header("Content-Type", "application/json"),
    if ($request-path = "/api/health") then
        serialize(local:health(), map { "method": "json" })
    else if ($request-path = "/api/auth/login" and $method = "POST") then
        serialize(local:login(), map { "method": "json" })
    else if ($request-path = "/api/auth/logout" and $method = "POST") then
        serialize(local:logout(), map { "method": "json" })
    else if ($request-path = "/api/charter/save" and $method = "POST") then
        serialize(local:save-charter(), map { "method": "json" })
    else if ($request-path = "/api/my-collections" and $method = "GET") then
        serialize(local:my-collections(), map { "method": "json" })
    else
        (
            response:set-status-code(404),
            serialize(
                map { "status": "error", "message": "Unknown API endpoint: " || $request-path },
                map { "method": "json" }
            )
        )
)
