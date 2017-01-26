xquery version "3.0";

module namespace register="http://www.monasterium.net/NS/register";

declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace xrx="http://www.monasterium.net/NS/xrx";
declare namespace cei="http://www.monasterium.net/NS/cei";
declare namespace tei="http://www.monasterium.net/NS/tei";
declare namespace svg="http://www.w3.org/2000/svg";
declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace image="http://exist-db.org/xquery/image";


declare function register:index-abfrage($term){
      let $resultat := session:set-attribute('resultat', collection("/db/mom-data/metadata.charter.public")//cei:text[ft:query(.//@lemma, substring-after($term, '#'))])
      for $m in collection("/db/mom-data/metadata.charter.public")//cei:text[ft:query(.//@lemma, substring-after($term, '#'))]      
      order by ft:score($m) descending      
      return   $m/ancestor::atom:entry/atom:id
                       
};


declare function register:years($register:index-abfrage){
    for $year in $register:index-abfrage/cei:text//cei:issued/(cei:date/@value|cei:dateRange/@from)
    order by xs:integer($year)
    return
          $year 

};