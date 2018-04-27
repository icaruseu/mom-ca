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
[descendant::cei:figure/cei:graphic/@url] [descendant::cei:graphic]
:)

module namespace img="http://www.monasterium.net/NS/img";

declare namespace cei="http://www.monasterium.net/NS/cei";
declare namespace atom="http://www.w3.org/2005/Atom";

import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../xrx/conf.xqm";
import module namespace metadata="http://www.monasterium.net/NS/metadata"
    at "../metadata/metadata.xqm";
import module namespace xrx="http://www.monasterium.net/NS/xrx"
    at "../xrx/xrx.xqm";

declare variable $img:bildserver := 'http://images.icar-us.eu/iiif/2/';
declare variable $img:thumbnail := '/full/120,/0/default.jpg';
declare variable $img:collection :=  collection(concat(conf:param("data-db-base-uri"), "/metadata.collection.public"));
(: declare variable $img:mycollection :=  collection(concat(conf:param("data-db-base-uri"), "/metadata.mycollection.public"));:)


(: function does same as charters:years in the year-navi but has condition to get charters with graphics only   
:)
declare function img:years($charter-base-coll) {
    for $entry in $charter-base-coll//atom:entry
    let $year := if($entry/atom:content/@src) then 
                 let $src := data($entry/atom:content/@src)
                 let $linkedcharters := collection("/db/mom-data/metadata.charter.public")//atom:entry[atom:id = $src]
                 return if($linkedcharters//cei:text[descendant::cei:graphic/@url !='']//cei:issued/cei:date/@value) then
                 $linkedcharters//cei:text[descendant::cei:graphic/@url !='']//cei:issued/cei:date/@value 
                 else($linkedcharters//cei:text[descendant::cei:graphic/@url !='']//cei:issued/cei:dateRange/@from)  
                 else(
                 if($entry//cei:text[descendant::cei:graphic/@url !='']//cei:issued/cei:date/@value) then
                 $entry//cei:text[descendant::cei:graphic/@url !='']//cei:issued/cei:date/@value 
                 else($entry//cei:text[descendant::cei:graphic/@url !='']//cei:issued/cei:dateRange/@from))  
    order by xs:integer($year)
    return   
    $year    
};

(: function takes graphic/@url and the atomid and returns a new url-string to the IIIF-server
http://images.monasterium.net/pics/AES<
:)

declare function img:get-url($url as xs:string, $atomid  as xs:string?, $context as xs:string){     
      if(starts-with($url, 'http://images.monasterium.net')) then
          let $cropend := string-length($url)          
          let $cropstart := string-length('http://images.monasterium.net/')+1
          let $imageurl := substring($url, $cropstart, $cropend)      
          return img:iiif($imageurl)
     else if($context = 'collection' and not(starts-with($url, 'http')))then
       let $collectionname := tokenize($atomid, '/')[3]
       let $address := $img:collection//atom:entry[ends-with(atom:id, $collectionname)]
       let $serveraddress := $address//cei:image_server_address/text()
       return
       if (contains($serveraddress, 'images.monasterium.net') ) then
              let $imageurl := concat($address//cei:image_server_folder/text(), '%2F', $url)         
              return img:iiif($imageurl)
        else()
      else if($context = 'fond' and not(starts-with($url, 'http')))then
      let $archive := tokenize($atomid, '/')[3]
      let $fond := tokenize($atomid, '/')[4]
      let $path := concat('/metadata.fond.public/', $archive, '/', $fond)
      let $fondcollection := collection(concat(conf:param("data-db-base-uri"), $path))
      let $archiv-image-server := $fondcollection//xrx:preferences//xrx:param[@name='image-server-base-url']/text()
      return     
      if (contains($archiv-image-server, 'monasterium.net')) then
      let $archivbilder := substring-after($archiv-image-server,'.net/')
      let $imageurl := concat($archivbilder, '/', $url)     
      return img:iiif($imageurl)
      else()
      
      
        else()
};

declare function img:iiif ($imageurl as xs:string){
let $filename := replace(replace(replace($imageurl, '%', '%25'), '&amp;', '%27'), '/', '%2F')
let $iiifurl := concat($img:bildserver, $filename, $img:thumbnail)
return $iiifurl
};



(:declare function img:checkifmycollection ($urltoken){
let $atomabgleich := $img:mycollection//ends-with(atom:id/text(), $urltoken)
let $entscheidung := if ($atomabgleich) then 'mycollection' else('collection')

return $entscheidung
    
};:)

declare function img:suchebilder($charter){
if ($charter//atom:content/@src) then 
let $src := data($charter//atom:content/@src)
let $charters := collection("/db/mom-data/metadata.charter.public")//atom:entry[atom:id = $src]
let $bilder := data($charters//cei:graphic/@url)
return if($charters//cei:graphic/@n = 'thumbnail') (: there are archives which provide own thumbnails e.g.: HU-MNL-DLBIRL :)
            then let $thumbs := for $bild in $bilder
                                let $thumbnail := concat($bild, 'isthumb')
                                return $thumbnail
            return $thumbs
            else($bilder)
else(
let $bilder := data($charter//cei:graphic/@url)
            return 
            if($charter//cei:graphic/@n = 'thumbnail') (: there are archives which provide own thumbnails e.g.: HU-MNL-DLBIRL :)
            then let $thumbs := for $bild in $bilder
                                let $thumbnail := concat($bild, 'isthumb')
                                return $thumbnail
            return $thumbs
            else($bilder)
    )
};
