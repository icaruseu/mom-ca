xquery version "3.0";

module namespace register="http://www.monasterium.net/NS/register";

import module namespace kwic="http://exist-db.org/xquery/kwic";

declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace xrx="http://www.monasterium.net/NS/xrx";
declare namespace cei="http://www.monasterium.net/NS/cei";
declare namespace tei="http://www.monasterium.net/NS/tei";
declare namespace svg="http://www.w3.org/2000/svg";
declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace image="http://exist-db.org/xquery/image";

declare function register:index-abfrage($term){
      if (starts-with($term, 'P_')) then
      let $resultat := session:set-attribute('result', collection("/db/mom-data/metadata.charter.public")//cei:text[ft:query(.//@key, $term)])
      for $m in collection("/db/mom-data/metadata.charter.public")//cei:text[ft:query(.//@key, $term)]      
      order by ft:score($m) descending      
      return  $m
   
      (:/ancestor::atom:entry/atom:id:)
      
      
      else(
      let $resultat := session:set-attribute('result', collection("/db/mom-data/metadata.charter.public")//cei:text[ft:query(.//@lemma, substring-after($term, '#'))])
      for $m in collection("/db/mom-data/metadata.charter.public")//cei:text[ft:query(.//@lemma, substring-after($term, '#'))]      
      order by ft:score($m) descending      
      return   $m
       )                
};


declare function register:years($register:index-abfrage){
    for $year in $register:index-abfrage//cei:issued/(cei:date/@value|cei:dateRange/@from)
    order by xs:integer($year)
    return
          $year 

};

declare function register:if-absent
  ( $arg as item()* ,
    $value as item()* )  as item()* {

    if (exists($arg))
    then $arg
    else $value
 } ;
 
declare function register:replace-multi
  ( $arg as xs:string? ,
    $changeFrom as xs:string* ,
    $changeTo as xs:string* )  as xs:string? {

   if (count($changeFrom) > 0)
   then register:replace-multi(
          replace($arg, $changeFrom[1],
                     register:if-absent($changeTo[1],'')),
          $changeFrom[position() > 1],
          $changeTo[position() > 1])
   else $arg
 } ;