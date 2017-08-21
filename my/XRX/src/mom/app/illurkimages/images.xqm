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

declare variable $img:bildserver := 'http://images.icar-us.eu/iiif/2/';
declare variable $img:thumbnail := '/full/120,/0/default.jpg';

(: function does same as charters:years in the year-navi but has condition to get charters with graphics only :)
declare function img:years($charter-base-collection) {

    for $year in $charter-base-collection//cei:text[descendant::cei:graphic/@url !='']//cei:issued/(cei:date/@value|cei:dateRange/@from)
    order by xs:integer($year)
    return
    $year    
};

declare function img:get-url($url as xs:string, $atomid  as xs:string?){     
      if(starts-with($url, 'http://images.monasterium.net')) then
          let $cropend := string-length($url)          
          let $cropstart := string-length('http://images.monasterium.net/')+1          
          let $filename := replace(replace(substring($url, $cropstart, $cropend), '%', '%25'), '/', '%2F')          
          let $iiifurl :=  concat($img:bildserver, $filename, $img:thumbnail)
          return $iiifurl
      else if(not(starts-with($url, 'http'))) then
              let $tokens := tokenize($atomid, '/')
              let $teile := for $num in 3 to count($tokens)-1 return $tokens[$num]
              let $filename := concat(string-join($teile, '%2F'), '%2F', replace(replace($url, '%', '%25'), '/', '%2F'))
              let $iiifurl :=  concat($img:bildserver, $filename, $img:thumbnail)
              return $iiifurl
        else('no')
};
