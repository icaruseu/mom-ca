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

import module namespace search="http://www.monasterium.net/NS/search"
      at "../search/search.xqm";
 
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
(: Sprachabkuerzel sind bisher in den Vokabularen nur 2stellig, deshalb $index:sprache :)
declare variable $index:sprache := substring($xrx:lang, 0,3);



 declare function index:index-check($voc){
    for $file in $index:personcollection   
    let $file-lastname := tokenize($file//atom:id, '/')[last()]      
    return
     if ($file-lastname = $voc)
     then true()
     else()    
};

(: function searches hits of a lemma in @ of published charters. 
and searches hits from narrower terms as well.
It returns the entries (atom:entry):
In the person index a specific value in the @key is searched
in other index a specific value in the @lemma is searched in the public collection
:)

declare function index:index-abfrage($term){
      let $treffergesamt := 
          if (starts-with($term, 'P_')) then $index:chartercollection//cei:text[.//@key = $term] 
          else( let $mehr :=  for $jeweils in index:narrower($term)
                              let $st := if(starts-with($jeweils, '#') ) then substring-after($jeweils, '#') else($jeweils)
                              return $index:chartercollection//cei:text[.//@lemma = $st]                   
                let $treffer := $index:chartercollection//cei:text[.//@lemma = substring-after($term, '#')]
                return $treffer union $mehr
                )            
      for $treffer in $treffergesamt
      let $date := data($treffer//cei:issued/(cei:dateRange/@from | cei:date/@value))
      order by number($date) ascending
      return 
      $treffer/ancestor::atom:entry 

};
 
 declare function index:narrower($term as xs:string) {
           let $suchterm := if(starts-with($term, '#')) then  $term else (concat('#', $term))
           let $voc := if( $index:vocabularycollection//skos:Concept[@rdf:about= $suchterm]/skos:narrower) then $index:vocabularycollection//skos:Concept[@rdf:about= $suchterm]/skos:narrower else ()
           let $narrow := data($voc/@rdf:resource)          
           return $narrow
 }; (: $narrow ist eine Sequenz an Strings, die auch gesucht werden sollen :)
 

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
 declare function index:read-hierarchie($glossarlabel,$rdf, $label, $voc){       
             for $g in $glossarlabel//skos:Concept[skos:broader/@rdf:resource = $rdf]
                  
                  let $newrdf := data($g/@rdf:about)
                  let $newlabel := <a class="filter" href="{concat(conf:param('request-root'),'index/',$voc, '/',  replace($newrdf, '#', ''))}">{if($g/skos:prefLabel/@xml:lang= $index:sprache) then $g/skos:prefLabel[@xml:lang= $index:sprache]/text() else($g/skos:prefLabel[1]/text())}</a>
               
                  
            return  <div class="narrower">{$newlabel}<span>{index:read-hierarchie($glossarlabel, $newrdf, $newlabel, $voc)}</span></div>    
            };
            
            
