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

import module namespace config = "http://www.monasterium.net/NS/config"
    at "config.xqm";

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
    else
        (
            response:set-status-code(404),
            serialize(
                map { "status": "error", "message": "Unknown API endpoint: " || $request-path },
                map { "method": "json" }
            )
        )
)
