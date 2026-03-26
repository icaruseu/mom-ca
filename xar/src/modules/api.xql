xquery version "3.1";

(:~
 : REST API module for MOM-CA.
 :
 : Provides JSON endpoints that replace the legacy *.service.xml files.
 : Uses RESTXQ annotations for routing. The controller.xql forwards all
 : requests under /api/* and /service/* to this module.
 :
 : Endpoints:
 :   POST /api/auth/login   - authenticate a user (placeholder)
 :   POST /api/auth/logout  - end a session (placeholder)
 :   GET  /api/health       - application health check
 :)

module namespace api = "http://www.monasterium.net/NS/api";

import module namespace config = "http://www.monasterium.net/NS/config"
    at "config.xqm";

declare namespace rest = "http://exquery.org/ns/restxq";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";


(: =================================================================
   POST /api/auth/login
   Placeholder authentication endpoint.
   Expects JSON: { "username": "...", "password": "..." }
   ================================================================= :)
declare
    %rest:POST
    %rest:path("/api/auth/login")
    %rest:consumes("application/json")
    %output:method("json")
    %output:media-type("application/json")
function api:login() {
    let $body     := util:binary-to-string(request:get-data())
    let $json     := parse-json($body)
    let $username := $json?username
    let $password := $json?password
    return
        (: TODO: Replace with real xmldb:authenticate() call :)
        if ($username and $password) then
            map {
                "status":  "ok",
                "message": "Login placeholder - authentication not yet implemented",
                "user":    $username
            }
        else
            (
                response:set-status-code(400),
                map {
                    "status":  "error",
                    "message": "Username and password are required"
                }
            )
};


(: =================================================================
   POST /api/auth/logout
   Placeholder session termination endpoint.
   ================================================================= :)
declare
    %rest:POST
    %rest:path("/api/auth/logout")
    %output:method("json")
    %output:media-type("application/json")
function api:logout() {
    (: TODO: call session:invalidate() and xmldb:login() as guest :)
    map {
        "status":  "ok",
        "message": "Logout placeholder - session handling not yet implemented"
    }
};


(: =================================================================
   GET /api/health
   Simple health-check endpoint. Returns application status and
   version from the package descriptor.
   ================================================================= :)
declare
    %rest:GET
    %rest:path("/api/health")
    %output:method("json")
    %output:media-type("application/json")
function api:health() {
    map {
        "status":  "ok",
        "app":     $config:app-name,
        "version": $config:app-version,
        "db":      system:get-version()
    }
};


(: =================================================================
   Fallback dispatcher for non-RESTXQ invocation.
   When controller.xql forwards to this module directly (via
   add-parameter "request-path"), this entry point routes manually.
   This covers the transitional period where RESTXQ may not be
   registered for all paths.
   ================================================================= :)
let $request-path := request:get-parameter("request-path", "")
return
    if ($request-path = "/api/health") then
        (
            response:set-header("Content-Type", "application/json"),
            serialize(api:health(), map { "method": "json" })
        )
    else if ($request-path = "/api/auth/login" and request:get-method() = "POST") then
        (
            response:set-header("Content-Type", "application/json"),
            serialize(api:login(), map { "method": "json" })
        )
    else if ($request-path = "/api/auth/logout" and request:get-method() = "POST") then
        (
            response:set-header("Content-Type", "application/json"),
            serialize(api:logout(), map { "method": "json" })
        )
    else
        (
            response:set-status-code(404),
            response:set-header("Content-Type", "application/json"),
            serialize(
                map {
                    "status":  "error",
                    "message": concat("Unknown API endpoint: ", $request-path)
                },
                map { "method": "json" }
            )
        )
