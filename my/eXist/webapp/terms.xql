xquery version "3.0";


import module namespace json="http://www.json.org";



declare namespace cei="http://www.monasterium.net/NS/cei";



declare option exist:serialize "method=json media-type=text/javascript";



declare function local:term-callback($term as xs:string, $data as xs:int+) as element()? {

    <term frequency="{ $data[1] }">{ $term }</term>
};



declare function local:terms() {

    let $terms :=
        util:index-keys-by-qname(QName('http://www.monasterium.net/NS/cei', 'cei:text'), 
            xs:string(request:get-parameter('term', '')), 
            (util:function(xs:QName('local:term-callback'), 2)), 
            100, 
            'lucene-index')
    for $t in $terms
    order by $t/@frequency descending
    return
    $t/text()
};



<terms>
  {
  for $term in local:terms()
  return
  <json:value>{ $term }</json:value>
  }
</terms>
