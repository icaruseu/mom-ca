xquery version "3.0";

module namespace url="http://www.monasterium.net/NS/url";


declare function url:atom-id-from-url($atom-tag-name, $url-encoded-atom-id) {

   let $decoded-atom-id := xmldb:decode($url-encoded-atom-id)
   let $encoded-charter-url := xmldb:encode-uri(substring-after($decoded-atom-id, $atom-tag-name))
   return
   concat($atom-tag-name, $encoded-charter-url)
   
};