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


declare namespace geo = "http://www.monasterium.net/NS/geo";
declare namespace eag= "http://www.archivgut-online.de/eag";
import module namespace atom="http://www.w3.org/2005/Atom" at "xmldb:exist:///db/XRX.live/mom/app/data/atom.xqm";


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
                           jsonx:string($result/id)
                          ),
                          jsonx:pair(
                           jsonx:string("displayText"),
                           jsonx:string($result/name)
                          ),
                         jsonx:pair(
                          jsonx:string("url"),
                          jsonx:string($result/url)
                          )

                        ))
                      )
                    )     
                ))
               )
              )
             )
     return $json

};





