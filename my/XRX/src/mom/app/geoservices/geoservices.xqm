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
module namespace geoservices="http://www.monasterium.net/NS/geoservices";


import module namespace jsonx="http://www.monasterium.net/NS/jsonx" at "xmldb:exist:///db/XRX.live/mom/app/xrx/jsonx.xqm";
import module namespace metadata="http://www.monasterium.net/NS/metadata" at "xmldb:exist:///db/XRX.live/mom/app/metadata/metadata.xqm";
import module namespace cei="http://www.monasterium.net/NS/cei" at "xmldb:exist:///db/XRX.live/mom/app/metadata/cei.xqm";
import module namespace conf="http://www.monasterium.net/NS/conf" at "xmldb:exist:///db/XRX.src/core/app/xrx/conf.xqm";
import module namespace atom="http://www.w3.org/2005/Atom" at "xmldb:exist:///db/XRX.live/mom/app/data/atom.xqm";


declare namespace geo = "http://www.monasterium.net/NS/geo";
declare namespace eag= "http://www.archivgut-online.de/eag";


(:get all locations stored in the archive xml. Needs the path to the collection in which the archive xml is stored. Returns the result as xml  :)
declare function geoservices:get_archive_locations($archivesCollection){
let $locations := 
    for $location in $archivesCollection//eag:location
     let $lng := $location/@longitude
     group by $lng
        return $lng/../..
            
let $locationsXml :=           
    for $location in $locations
        return <location>
                    <name>{$location/eag:municipality/text()}</name>
                    <longitude>{data($location/eag:location/@longitude)}</longitude>
                    <latitude>{data($location/eag:location/@latitude)}</latitude>
                    <results>
                        {
                        for $archive in $archivesCollection
                            return if($archive//eag:location/@longitude = $location/eag:location/@longitude and $archive//eag:location/@latitude = $location/eag:location/@latitude) then 
                                    <result>
                                    <id>{$archive//atom:id/text()}</id>
                                    <name>{$archive//eag:autform/text()}</name>
                                        <url>{concat(conf:param('request-root'),tokenize($archive//atom:id/text(),'/')[3] ,"/archive")}</url>
                                    </result>
                                else()
                        }
                    </results>
               </location>

return <locations>{$locationsXml}</locations>

};

(:Get all charters with ..//cei:issued/cei:place/@key in a collection. Needs the path to the collection returns the result as xml :)
declare function geoservices:get_charter_over_key($collectionPath){

    let $collection := collection($collectionPath)
    let $geodoc := doc("/db/mom-data/metadata.geo.public/geo.xml")


    let $keys := distinct-values($collection//cei:issued/cei:placeName/@key)

    for $key in $keys
    let $locations := $geodoc//geo:location[@id=$key]

    let $xml := for $location in $locations
    return <location>
        <name>{$location//geo:name/text()}</name>
        <longitude>{$location//geo:lng/text()}</longitude>
        <latitude>{$location/geo:lat/text()}</latitude>
        <count>{count($collection[.//cei:issued/cei:placeName/@key = $key])}</count>
        <results>
            {
                for $charter in $collection[.//cei:issued/cei:placeName/@key = $key]
                order by $charter//cei:date/@value
                return
                    <result>
                        {$charter//cei:date}
                    <id>{$charter//atom:id/text()}</id>
                    </result>
            }
        </results>
    </location>
    let $locationXml := <locations>{$xml}</locations>

    return $locationXml

};



(: Get as many charters as $steps, from Charter at position $pos with the $clickedLocation in cei:issued/cei:place :)
declare function geoservices:charter_results($clickedLocation, $locationsXml, $pos as xs:int, $steps as xs:int){

    let $location := $locationsXml/location[name=$clickedLocation]

    let $startpos := ($pos - 1 )* $steps +1


    let $results := $location/results/result/id
    let $ids := subsequence($results, $startpos, $steps)

    let $charters := for $id in $ids
        let $charter-path := geoservices:charter_path_from_id($id)
        let $fileName := metadata:entryname("cei", tokenize($id,"/")[last()])
        return doc(concat($charter-path,"/",$fileName))

    let $setSessionCharterResults := session:set-attribute("_GeoCharterResults", $charters)

    return <result>{$charters}</result>
};





(: creates from a charter id a path to the charter.xml:)
declare function geoservices:charter_path_from_id($id){
    let $tokenizedId := tokenize($id, "/")
    let $context := if(count($tokenizedId) = 4) then "collection" else("fond")
    let $base-path := metadata:base-collection-path("charter", "public")
    let $charter-path := if($context = "fond") then concat($base-path, $tokenizedId[3],"/", $tokenizedId[4]) else(concat($base-path, $tokenizedId[3]))

    return $charter-path


};

(:Converts a xml with results from geoservices:get_charter_over_key($collectionPath) into json:)
declare function geoservices:xmlToJsonForCharters($locationsXml){
    let $json := jsonx:object(
            jsonx:pair(
                jsonx:string("geolocations"),
                    jsonx:array(
                        for $location in $locationsXml/location
                            return   jsonx:object((
                                jsonx:pair(
                                        jsonx:string("name"),
                                        jsonx:string($location/name)
                                ),
                                jsonx:pair(
                                        jsonx:string("lat"),
                                        jsonx:string($location/latitude)
                                ),
                                jsonx:pair(
                                        jsonx:string("lng"),
                                        jsonx:string($location/longitude)
                                ),
                                jsonx:pair(
                                    jsonx:string("count"),
                                    jsonx:string($location/count)
                                ),
                                jsonx:pair(
                                        jsonx:string("results"),
                                        jsonx:array(
                                                for $result in $location//results/result
                                                return jsonx:object((
                                                    jsonx:pair(
                                                            jsonx:string("id"),
                                                            jsonx:string(if(empty($result/id)) then 'none' else($result/id))
                                                    ),
                                                    jsonx:pair(
                                                            jsonx:string("displayText"),
                                                            jsonx:string(if(empty($result/name)) then 'none' else($result/name))
                                                    ),
                                                    jsonx:pair(
                                                            jsonx:string("url"),
                                                            jsonx:string(if(empty($result/url)) then 'none' else($result/name))
                                                    )))
                                        )
                                )
                            ))
                    )
            )
    )
    return $json
};

(: converts a xml with resuls from geoservices:get_archive_locations into json:)
declare function geoservices:xmltoJson($locationsXml){

            let $json := jsonx:object(
               jsonx:pair(
                jsonx:string("geolocations"),
                jsonx:array(
                 for $location in $locationsXml/location
                  return   jsonx:object(( 
                            jsonx:pair(
                             jsonx:string("name"),
                             jsonx:string($location/name)
                            ),
                            jsonx:pair(
                            jsonx:string("lat"),
                            jsonx:string($location/latitude)
                           ),
                           jsonx:pair(
                            jsonx:string("lng"),
                            jsonx:string($location/longitude)
                           ),
                           jsonx:pair(
                           jsonx:string("results"),
                        jsonx:array(
                         for $result in $location//results/result
                         return jsonx:object((
                          jsonx:pair(
                           jsonx:string("id"),
                           jsonx:string(if(empty($result/id)) then 'none' else($result/id))
                          ),
                          jsonx:pair(
                           jsonx:string("displayText"),
                           jsonx:string(if(empty($result/name)) then 'none' else($result/name))
                          ),
                         jsonx:pair(
                          jsonx:string("url"),
                          jsonx:string(if(empty($result/url)) then 'none' else($result/name))
                        )))
                      )
                    )     
                ))
               )
              )
             )
     return $json

};





