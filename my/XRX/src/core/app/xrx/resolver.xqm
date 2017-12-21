xquery version "3.0";
(:~
This is a component file of the VdU Software for a Virtual Research Environment for the handling of Medieval charters.

As the source code is available here, it is somewhere between an alpha- and a beta-release, may be changed without any consideration of backward compatibility of other parts of the system, therefore, without any notice.

This file is part of the VdU Virtual Research Environment Toolkit (VdU/VRET).

The VdU/VRET is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

VdU/VRET is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with VdU/VRET.  If not, see <http://www.gnu.org/licenses/>.

We expect VdU/VRET to be distributed in the future with a license more lenient towards the inclusion of components into other systems, once it leaves the active development stage.
:)


module namespace resolver="http://www.monasterium.net/NS/resolver";

declare namespace xrx="http://www.monasterium.net/NS/xrx";
declare namespace atom="http://www.w3.org/2005/Atom";
declare function resolver:resolve($live-project-db-base-collection) as element()* {

    let $first-match :=
        (
            for $uri-pattern in $live-project-db-base-collection//xrx:resolver/xrx:map/xrx:uripattern
            let $priority := ($uri-pattern/parent::xrx:map/@priority/string(), '999')[1]
            order by $priority ascending
            return
            if(matches(request:get-uri(), $uri-pattern/text())) then
                $uri-pattern/parent::xrx:map
            else()
        )[1]
        
        let $test := resolver:start-check()        
        let $result := 
        if ($test = "false") then <xrx:map><xrx:uripattern>/error$</xrx:uripattern><xrx:mode>mainwidget</xrx:mode><xrx:atomid>tag:www.monasterium.net,2011:/mom/widget/error</xrx:atomid></xrx:map> 
        else $first-match
        
        return
    $result
};



declare function resolver:start-check(){
let $uri := request:get-uri()
let $sub-uri := substring-after($uri, "mom/")
let $tokenized-uri := tokenize($uri, "/")
let $uripattern := $tokenized-uri[last()]

let $result := 
switch($uripattern)
case "charter" return resolver:check-charter($tokenized-uri)
case "collection" return resolver:check-collection($tokenized-uri)
case "fond" return resolver:check-fond($tokenized-uri) 
case "archive" return resolver:check-archive($tokenized-uri)
default return "true"

return $result 
};


declare function resolver:check-charter($tokenized-uri){
    let $charter-atomid := concat("tag:www.monasterium.net,2011:/charter/",$tokenized-uri[last()-2],"/", $tokenized-uri[last()-1])
    let $charter := collection("/db/mom-data/metadata.charter.public")//atom:id[.=$charter-atomid]
    return
        if (empty($charter)) then (let $found-charter := "false" return $found-charter)
    else (let $found-charter := "true" return $found-charter)
    
};

declare function resolver:check-archive($tokenized-uri){
    let $archive-atomid := concat("tag:www.monasterium.net,2011:/archive/",$tokenized-uri[last()-1])
    let $archive := collection("/db/mom-data/metadata.archive.public")//atom:id[.=$archive-atomid]
    let $debug := util:log("ERROR", $archive)
    return 
        if(empty($archive)) then (let $found-archive := "false" return $found-archive)
        else (let $found-archive := "true" return $found-archive)

};

declare function resolver:check-fond($tokenized-uri){
    let $fond-atomid := concat("tag:www.monasterium.net,2011:/fond/",$tokenized-uri[last()-2],"/",$tokenized-uri[last()-1])
    let $fond := collection("/db/mom-data/metadata.fond.public")//atom:id[.=$fond-atomid]
    return if(empty($fond)) then (let $found-fond := "false" return $found-fond)
    else (let $found-fond := "true" return $found-fond)
};


declare function resolver:check-collection($tokenized-uri){
 let $collection-atomid := concat("tag:www.monasterium.net,2011:/collection/",$tokenized-uri[last()-1])
 let $collection := collection("/db/mom-data/metadata.collection.public")//atom:id[.=$collection-atomid]
 
 let $result := 
    if(empty($collection)) then (
        let $mycollection-atomid := concat("tag:www.monasterium.net,2011:/mycollection/", $tokenized-uri[last()-1])
        let $mycollection := collection("/db/mom-data/metadata.mycollection.public")//atom:id[.=$mycollection-atomid]    
        let $res :=
            if(empty($mycollection)) then (let $found-mycollection := "false" return $found-mycollection)
            else (let $found-mycollection := "true" return $found-mycollection)
            return $res
            )
    else (  let $found-collection := "true"
            return $found-collection
         )
         
   return $result

};