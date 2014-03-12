xquery version "3.0";

module namespace migrate21="http://www.monasterium.net/NS/migrate21";

declare function migrate21:chmod-collections($base-uri as xs:string) {

    let $chmod := sm:chmod($base-uri, 'rwxrwxrwx')
    let $chmod-resources := migrate21:chmod-resources($base-uri)
    let $child-collections := xmldb:get-child-collections($base-uri)
    for $collection in $child-collections
    let $next-base-uri := concat($base-uri, '/', $collection)
    return
    migrate21:chmod-collections($next-base-uri)
};

declare function migrate21:chmod-resources($base-collection as xs:string) {

    let $resources := xmldb:get-child-resources($base-collection)
    for $resource in $resources
    let $uri := concat($base-collection, '/', $resource)
    return
    sm:chmod($uri, 'rwxrwxrwx')
};