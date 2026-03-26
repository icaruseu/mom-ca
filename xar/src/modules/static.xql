xquery version "3.1";

(:~
 : Serves static binary resources with correct Content-Type headers.
 : eXist-db sometimes serves .js files as text/plain which breaks
 : ES module loading in browsers.
 :)

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "binary";

declare variable $app-root := "/db/apps/mom-ca";

let $rel-path := request:get-parameter("path", "")
let $full-path := $app-root || "/resources/" || $rel-path

let $ext := lower-case(tokenize($rel-path, '\.')[last()])
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
    case 'png'   return 'image/png'
    case 'jpg'   return 'image/jpeg'
    case 'jpeg'  return 'image/jpeg'
    case 'gif'   return 'image/gif'
    case 'ico'   return 'image/x-icon'
    default      return 'application/octet-stream'

return
    if (util:binary-doc-available($full-path)) then (
        response:set-header("Content-Type", $mime),
        response:set-header("Cache-Control", "public, max-age=86400"),
        response:stream-binary(util:binary-doc($full-path), $mime)
    )
    else (
        response:set-status-code(404),
        response:set-header("Content-Type", "text/plain"),
        "Not found: " || $full-path
    )
