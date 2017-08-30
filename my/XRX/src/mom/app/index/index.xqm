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
declare namespace skos="http://www.w3.org/2004/02/skos/core#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace atom="http://www.w3.org/2005/Atom";

declare variable $index:chartercollection := collection(concat(conf:param("data-db-base-uri"), "/metadata.charter.public"));
declare variable $index:personcollection := collection(concat(conf:param("data-db-base-uri"), "/metadata.person.public"));
declare variable $index:vocabularycollection := collection(concat(conf:param("data-db-base-uri"), "/metadata.controlledVocabulary.public"));

(: function searches hits of a lemma in @ of published charters. It returns the ids of the hits
and saves the hits in a session variable in order to be able to browse through the hits :)
declare function index:index-abfrage($term){
      if (starts-with($term, 'P_')) then
      let $resultat := session:set-attribute('result', $index:chartercollection//cei:text[.//@key= $term])
      let $treffergesamt := $index:chartercollection//cei:text[.//@key = $term]
      for $treffer in $treffergesamt
      order by $treffer//cei:issued/(cei:dateRange/@from | cei:date/@value) ascending
      return  $treffer/ancestor::atom:entry/atom:id   
      
      
      else(
      let $resultat := session:set-attribute('result', $index:chartercollection//cei:text[.//@lemma = substring-after($term, '#')])
      let $treffergesamt := $index:chartercollection//cei:text[.//@lemma = substring-after($term, '#')]
      for $treffer in $treffergesamt
      order by $treffer//cei:issued/(cei:dateRange/@from | cei:date/@value) ascending
      return   $treffer/ancestor::atom:entry/atom:id  
       )                
};

(: the following two functions are needed to cut TEI data in order to get a userfriendly representation of the text in the UI :)
declare function index:if-absent
  ( $arg as item()* ,
    $value as item()* )  as item()* {

    if (exists($arg))
    then $arg
    else $value
 };
 
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
  
 (: function that reads terms from RDF :)
 declare function index:read-hierarchie($glossarlabel,$rdf, $label, $voc, $sprache){       
             for $g in $glossarlabel//skos:Concept[skos:broader/@rdf:resource = $rdf]
                  
                  let $newrdf := data($g/@rdf:about)
                  let $newlabel := <a class="filter" href="{concat(conf:param('request-root'),'index/',$voc, '/',  replace($newrdf, '#', ''))}">{if($g/skos:prefLabel/@xml:lang= $sprache) then $g/skos:prefLabel[@xml:lang= $sprache]/text() else($g/skos:prefLabel[1]/text())}</a>
               
                  let $memo:= session:set-attribute(replace($newrdf,'#', ''), $newlabel)
            return  <div class="narrower">{$newlabel}<span>{index:read-hierarchie($glossarlabel, $newrdf, $newlabel, $voc, $sprache)}</span></div>    
            };