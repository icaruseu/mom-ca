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


module namespace index="http://www.monasterium.net/NS/index";

import module namespace kwic="http://exist-db.org/xquery/kwic";

import module namespace conf="http://www.monasterium.net/NS/conf" 
      at "../xrx/conf.xqm";

declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace xrx="http://www.monasterium.net/NS/xrx";
declare namespace cei="http://www.monasterium.net/NS/cei";
declare namespace tei="http://www.monasterium.net/NS/tei";
declare namespace svg="http://www.w3.org/2000/svg";
declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace image="http://exist-db.org/xquery/image";

declare variable $index:chartercollection := collection(concat(conf:param("data-db-base-uri"), "/metadata.charter.public"));

declare function index:index-abfrage($term){
      if (starts-with($term, 'P_')) then
      let $resultat := session:set-attribute('result', $index:chartercollection//cei:text[ft:query(.//@key, $term)])
      for $m in collection("/db/mom-data/metadata.charter.public")//cei:text[ft:query(.//@key, $term)]      
      order by ft:score($m) descending      
      return  $m   
      
      
      else(
      let $resultat := session:set-attribute('result', $index:chartercollection//cei:text[ft:query(.//@lemma, substring-after($term, '#'))])

      for $m in collection("/db/mom-data/metadata.charter.public")//cei:text[ft:query(.//@lemma, substring-after($term, '#'))]      
      order by ft:score($m) descending      
      return   $m
       )                
};


declare function index:years($index:index-abfrage){
    for $year in $index:index-abfrage//cei:issued/(cei:date/@value|cei:dateRange/@from)
    order by xs:integer($year)
    return
          $year 

};

declare function index:if-absent
  ( $arg as item()* ,
    $value as item()* )  as item()* {

    if (exists($arg))
    then $arg
    else $value
 } ;
 
declare function index:replace-multi
  ( $arg as xs:string? ,
    $changeFrom as xs:string* ,
    $changeTo as xs:string* )  as xs:string? {

   if (count($changeFrom) > 0)
   then index:replace-multi(
          replace($arg, $changeFrom[1],
                     index:if-absent($changeTo[1],'')),
          $changeFrom[position() > 1],
          $changeTo[position() > 1])
   else $arg
 } ;