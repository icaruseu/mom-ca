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

module namespace charter="http://www.monasterium.net/NS/charter";

declare namespace cei="http://www.monasterium.net/NS/cei";
declare namespace atom="http://www.w3.org/2005/Atom";

import module namespace xrx="http://www.monasterium.net/NS/xrx"
    at "../xrx/xrx.xqm";
import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../xrx/conf.xqm";
import module namespace user="http://www.monasterium.net/NS/user"
    at "../user/user.xqm";
import module namespace metadata="http://www.monasterium.net/NS/metadata"
    at "../metadata/metadata.xqm";
import module namespace kwic="http://exist-db.org/xquery/kwic";
    
(: request parameter :)
declare variable $charter:ratomid := request:get-parameter('id', '');
declare variable $charter:rarchiveid := $xrx:tokenized-uri[1];
declare variable $charter:rfondid := if($xrx:tokenized-uri[2]) then $xrx:tokenized-uri[2] else '';
declare variable $charter:rcharterid := if($xrx:tokenized-uri[4] != '') then $xrx:tokenized-uri[3] else $xrx:tokenized-uri[2];
declare variable $charter:rcollectionid := $xrx:tokenized-uri[1];
    
declare variable $charter:translations :=
    <mapper>
        <replace pattern="\. " replacement=" " description="Punkt mit nachfolgendem Leerzeichen '. ' wird entfernt."/>
        <replace pattern=", " replacement=" " description="Komma mit nachfolgendem Leerzeichen ', ' wird entfernt."/>
        <replace pattern=" \(" replacement="(" description="Bei öffnender Klammer mit vorhergehendem Leerzeichen wird Leerzeichen entfernt."/>
        <replace pattern=" - " replacement="-" description="Leerzeichen, die einen Bindestrich umschließen werden entfernt."/>
        <translate from=" " to="_" description="Leerzeichen werden nach '_' umgewandelt"/>
        <translate from="/" to="|" description="Querbalken '/' werden zu Hochbalken '|'"/>
        <translate from="?" to="" description="Fragezeichen '?' werden entfernt"/>
        <translate from="=" to="" description="Gleichheitszeichen '=' werden entfernt"/>
        <translate from=":" to="" description="Doppelpunkt ':' wird entfernt"/>
        <translate from=":" to="" description="Strichpunkt ';' wird entfernt"/>
        <translate from="%" to="" description="Prozentzeichen '%' wird entfernt"/>
        <translate from="#" to="" description="Pfundzeichen '#' wird entfernt"/>
        <translate from="$" to="" description="Dollarzeichen '$' wird entfernt"/>
    </mapper>;

(:~
######################
#
#
# Metadata and Atom related 
# functions
#
#
######################
:)
(:
    returns all tokens of a charter Atom ID except the object type, e.g.:
    tag:www.monasterium.net,2011:/charter/AT-ATF/TirolOFM/Urkunde_002
    would return the follwoing string sequence:
    ('AT-ATF', 'TirolOFM', 'Urkunde_002')
:)
declare function charter:object-uri-tokens($atomid as xs:string, $atom-tag-name as xs:string) as xs:string* {

    let $object-uri := substring-after($atomid, $atom-tag-name)
    let $object-uri-tokens := tokenize($object-uri, '/')
    return
    subsequence($object-uri-tokens, 3)
};



declare function charter:object-uri-tokens($atomid as xs:string) as xs:string* {

    charter:object-uri-tokens($atomid, conf:param('atom-tag-name'))
};



(: 
    returns the arch ID of a charter's Atom ID by 
    handing over the Atom ID and the Atom tag name 
:)
declare function charter:context($atomid as xs:string, $atom-tag-name as xs:string) as xs:string {

    let $tokens := charter:object-uri-tokens($atomid, $atom-tag-name)
    return
    if(count($tokens) = 3) then 'fond'
    else 'collection'
};



declare function charter:context($atomid as xs:string) as xs:string {

    charter:context($atomid, conf:param('atom-tag-name'))
};



(: 
    returns the arch ID of a charter's Atom ID by 
    handing over the Atom ID and the Atom tag name 
:)
declare function charter:archid($atomid as xs:string, $atom-tag-name as xs:string) as xs:string* {

    let $tokens := charter:object-uri-tokens($atomid, $atom-tag-name)
    return
    $tokens[1]
};



declare function charter:archid($atomid as xs:string) as xs:string {

    charter:archid($atomid, conf:param('atom-tag-name'))
};



(: 
    returns the fond ID of a charter's Atom ID by 
    handing over the Atom ID and the Atom tag name 
:)
declare function charter:fondid($atomid as xs:string, $atom-tag-name as xs:string) as xs:string {

    let $tokens := charter:object-uri-tokens($atomid, $atom-tag-name)
    return
    $tokens[2]
};



declare function charter:fondid($atomid as xs:string) as xs:string {

    charter:fondid($atomid, conf:param('atom-tag-name'))
};



(: 
    returns the collection ID of a charter's Atom ID by 
    handing over the Atom ID and the Atom tag name 
:)
declare function charter:collectionid($atomid as xs:string, $atom-tag-name as xs:string) as xs:string {

    let $tokens := charter:object-uri-tokens($atomid, $atom-tag-name)
    return
    $tokens[1]
};



declare function charter:collectionid($atomid as xs:string) as xs:string {

    charter:collectionid($atomid, conf:param('atom-tag-name'))
};



(: 
    returns the charter ID of a charter's Atom ID by 
    handing over the Atom ID and the Atom tag name 
:)
declare function charter:charterid($atomid as xs:string, $atom-tag-name as xs:string) as xs:string {

    let $tokens := charter:object-uri-tokens($atomid, $atom-tag-name)
    return
      xmldb:decode($tokens[last()])
};

declare function charter:charterid($atomid as xs:string?) as xs:string {

  let $return :=
    if($atomid != "") then
      charter:charterid($atomid, conf:param('atom-tag-name'))
    else
      ()
  return
    $return[1]
};

declare function charter:permalink($entry as element(atom:entry)) as xs:string {

    let $atomid := $entry/atom:id/text()
    return
    concat(conf:param('request-root'), string-join(charter:object-uri-tokens($atomid, conf:param('atom-tag-name')), '/'), '/charter')
};



declare function charter:linked-fond-base-collection($entry as element(atom:entry)) {

    let $atomid := $entry/atom:id/text()
    let $atom-tag-name := conf:param('atom-tag-name')
    return
    metadata:base-collection('fond', (charter:archid($atomid, $atom-tag-name), charter:fondid($atomid, $atom-tag-name)), 'public')
};



declare function charter:public-entry($atomid as xs:string) as element()* {
    
    let $atom-tag-name := conf:param('atom-tag-name')
    let $charter-context := charter:context($atomid, $atom-tag-name)
    let $base-collection := 
        if($charter-context = 'collection') then
            metadata:base-collection('charter', charter:collectionid($atomid, $atom-tag-name), 'public')
        else
            metadata:base-collection('charter', (charter:archid($atomid, $atom-tag-name), charter:fondid($atomid, $atom-tag-name)), 'public')
    let $charter-entry := $base-collection//atom:id[.=$atomid]/parent::atom:entry
    return
    $charter-entry
};



(:~
######################
#
#
# publication status
#
#
######################
:)
declare function charter:is-bookmarked($user-xml as element(xrx:user)?, $atom-id as xs:string) as xs:boolean {

    if($user-xml//xrx:bookmark[.=$atom-id]) 
    then true()
    else false()    
};

declare function charter:in-use-by($user-db-base-collection as node()+, $atom-id as xs:string, $actual-user as xs:string) as xs:string? {

    let $id-element := $user-db-base-collection//xrx:id[.=$atom-id]
    let $email := root($id-element)//xrx:email/text()
    return
    xs:string($email)
};

(:~
######################
#
#
# charter view
#
#
######################
:)
declare function charter:get-charter-list($metadata-charter-collection as node()+, $uri-token as xs:string, $user-xml as element(xrx:user)?) {

    (: XML root nodes inside a fond related DB collection :)
    if($uri-token='charter' or $uri-token='imported-charter' or $uri-token='my-charter') then
        for $c in $metadata-charter-collection//cei:text
        order by xs:integer(($c//cei:issued/cei:date/@value|$c//cei:issued/cei:dateRange/@from)[1])
        return
        $c
    
    (: ID list of saved charters :)
    else if($uri-token='saved-charter' or $uri-token='edit-charter') then
        $user-xml//xrx:saved[xrx:freigabe='no']
        
    (: ID list of released charters :)
    else if($xrx:tokenized-uri[last()]='released-charter') then
        $user-xml//xrx:saved[xrx:freigabe='yes']

    (: ID list of charters to publish :)
    else if($xrx:tokenized-uri[last()]='charter-to-publish') then
        $user:db-base-collection/xrx:user[xrx:moderator=$xrx:user-id]//xrx:saved[xrx:freigabe='yes']
    
    else()
}; 

declare function charter:next-and-previous($charters, $charter, $count as xs:integer, $atom-id as xs:string, $uri-token as xs:string) {

    (: navigating through a fond or a collection:)
    if($uri-token='charter' or $uri-token='imported-charter' or $uri-token='my-charter') then
        for $c at $pos in $charters
        return
        if(util:document-id($charter)=util:document-id($c) and $pos = 1) 
        then ($c, $charters[$pos + 1])
        else if(util:document-id($charter)=util:document-id($c) and $pos=$count) 
        then ($charters[$pos - 1], $c)
        else if(util:document-id($charter)=util:document-id($c)) 
        then ($charters[$pos - 1], $charters[$pos + 1])
        else()

    (: navigating through saved charters :)
    else if($uri-token='saved-charter' or $uri-token='edit-charter' or $uri-token='charter-to-publish') then
        for $c at $index in $charters/xrx:id/text()
        return
        (: last in list? :)
        if($atom-id = $charters[last()]/xrx:id/text()) then 
        ($charters[last()]/xrx:id/text(), $charters[last() - 1]/xrx:id/text())
        (: first in list? :)
        else if($atom-id = $charters[1]/xrx:id/text()) then
        ($charters[$index + 1]/xrx:id/text(), $charters[1]/xrx:id/text())
        else if($c = $atom-id) then 
        ($charters[$index + 1]/xrx:id/text(),$charters[$index - 1]/xrx:id/text())
        else()
        
    else()

};

declare function charter:position($charters, $charter, $user-xml as element(xrx:user)?, $atom-id as xs:string, $uri-token as xs:string) {

    (: position in fond or collection :)
    if($uri-token='charter' or $uri-token='imported-charter' or $uri-token='my-charter') then
        for $c at $p in $charters
        return
        if(util:document-id($charter) = util:document-id($c)) then $p
        else()

    (: index of saved charter :)
    else if($uri-token='saved-charter' or $uri-token='edit-charter') then
        for $saved at $index in $user-xml//xrx:saved[./xrx:freigabe='no']/xrx:id/text()
        return
        if($saved=$atom-id) then xs:string($index)
        else()
    
    (: index of charter to publish :)
    else if($uri-token='charter-to-publish') then
        for $saved at $index in $user:db-base-collection/xrx:user[xrx:moderator=$xrx:user-id]//xrx:saved[xrx:freigabe='yes']/xrx:id/text()
        return
        if($saved=$atom-id) then xs:string($index)
        else()
            
    else()    
};

declare function charter:block($charter-pos as xs:integer*) as xs:integer* {
    
    $charter-pos idiv 30 + 1
};

declare function charter:anchor($charter-pos as xs:integer*) as xs:integer* {

    if($charter-pos < 30) then $charter-pos mod 30 else $charter-pos mod 30 + 1
};

(:~
######################
#
#
# charter import
#
#
######################
:)
(:
    helper function for charter import
    returns a sequence of cei:idno elements,
    sorted, by handing over a cei document
    or a database collection
:)
declare function charter:ordered-idnos($cei) {

    for $text in $cei//cei:text[@type='charter']
    let $i := $text//cei:body/cei:idno
    order by $i
    return
    $i  
};

(:
    helper function for charter import
    evaluates the rules defined in 
    $charter:translations
:)
declare function charter:do-map($idno as xs:string, $mapper, $counter as xs:integer) {

    let $mapping := $mapper[$counter]
    let $new-idno := 
        
        typeswitch($mapping)

        case element(translate) return
        translate($idno, data($mapping/@from), data($mapping/@to))

        case element(replace) return
        replace($idno, $mapping/@pattern/string(), $mapping/@replacement/string())

        default return ()

    return
    if($counter lt count($mapper)) then charter:do-map($new-idno, $mapper, $counter + 1)
    else $new-idno
};

(:
    helper function for charter import
    returns a sequence of cleaned charter idnos 
    as xs:string which can be used as a URL name
:)
declare function charter:map-idnos($idnos as element(cei:idno)+, $isId as xs:boolean?) as xs:string+ {

    for $idno in $idnos
    let $mapped-idno :=
     if( $isId = true() ) then
      charter:do-map(string-join(data($idno/@id), ''), root($charter:translations)/mapper/*, 1)
    else
      charter:do-map(string-join($idno/text(), ''), root($charter:translations)/mapper/*, 1)
     

      
    return
    if($mapped-idno != '') then $mapped-idno
    else '0000'
};

(:
    helper function for charter import
:)
declare function charter:make-unique($idnos as xs:string+) {

    for $unique-idno at $pos in $idnos
    let $actual := $idnos[$pos]
    return
    if($pos = 1) then 
        if($actual != '') then $actual else '0'
    else if($actual = $idnos[$pos - 1]) then
        let $subsequence := subsequence($idnos, 0, $pos)
        let $notunique := 
            for $i at $p in $subsequence
            return
            if($i = $subsequence[$p - 1] and $i = $unique-idno) then $i else ()
        let $howmany := xs:string(count($notunique) + 1)
        return
            concat(if($actual) then $actual else '0', '.', $howmany)
    else
        if($actual) then $actual else '0'
};

(:
    helper function for charter import
:)
declare function charter:insert-unique-idno($charter as element(cei:text), $unique-idno as xs:string) as element() {

    let $xslt := 
    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cei="http://www.monasterium.net/NS/cei" version="1.0">
      <xsl:template match="//cei:body/cei:idno">
        <xsl:element name="cei:idno">
          <xsl:attribute name="id">{ $unique-idno }</xsl:attribute>
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:template>
      <xsl:template match="@*|*" priority="-2">
        <xsl:copy>
          <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
      </xsl:template>
    </xsl:stylesheet>
    return
    transform:transform($charter, $xslt, ())
};



declare function charter:summarize($charter) {

  try {
    let $summarized := kwic:summarize($charter, <config xmlns="" width="100"/>)    
    let $attribute-matches := charter:attributes-matching-search-regEx($charter) (: kwic did not look inside attributes. :)
    return
      if( not(empty($summarized)) and empty($attribute-matches) ) then
        $summarized
      else if( empty($summarized) and not(empty($attribute-matches)) ) then
        $attribute-matches
      else
        ($summarized, $attribute-matches)

  } catch * {   
    concat(substring($charter//cei:abstract, 1, 200), '...')
  }
}; (: catch tritt bei indexsuche ein, verzicht auf highlighting weil Suche in @ :)

declare function charter:attributes-matching-search-regEx($charter){

  let $charter-attributes := $charter//@*
  let $charter-attributes-matching-q := (: q is search parameter. :)
    for $attribute in $charter-attributes
    let $attribute-string := string($attribute)
    where matches(lower-case($attribute-string), lower-case(request:get-parameter("q", "")))
    return $attribute
  let $matches-made-pretty :=
    for $match in $charter-attributes-matching-q
    let $attribute-name := name($match)
    let $attribute-value := string($match)
    let $number-of-matches-in-attribute := charter:number-of-matches-case-insensitive($attribute-value, request:get-parameter("q", ""))
    let $best-performance-depending-on-number-of-search-matches :=
      if($number-of-matches-in-attribute = 1) then
      (: there is only one search match in the respective attribute :)
        let $substring-before-match := tokenize($attribute-value, request:get-parameter("q", ""), "i")[1]
        let $substring-after-match := replace($attribute-value, concat('^.*?', request:get-parameter("q", "")), '', "i")
        let $match-itself :=
        (: reconstructs match by cutting off substrings after match, or before and after, or before, or not at all.
           Depending on match's position inside attribute string. :)
          let $match-at-beginning-or-in-middle := substring-after(substring-before($attribute-value, $substring-after-match), $substring-before-match)
          return
            if ($match-at-beginning-or-in-middle != '') then
              $match-at-beginning-or-in-middle
            else
              let $match-at-end := substring-after($attribute-value, $substring-before-match)
              return
                if($match-at-end != '') then
                  $match-at-end
                else $attribute-value (: match equals entire attribute string. :)
        (: in case the "hardcoded" span inside function charter:highlight-string becomes problematic:
         : a different approach is to surround the $match-itself with <exist:match> tags, put the whole string together, then feed it to kwic:summarize. :)
        let $highlighted-match := charter:highlight-string($match-itself)
        return (concat("@", $attribute-name, " => ", $substring-before-match), $highlighted-match, $substring-after-match, " ")
      else
      (: attribute contains multiple search hits. :)
        (: taking the attribute apart. Obtaining strings between search hits. :)
        let $tokenized-attribute-with-hits-removed := tokenize($attribute-value, request:get-parameter("q", ""), "i")
        let $attribute-starts-with-search-hit :=
          if(charter:index-of-string($attribute-value, request:get-parameter("q", ""))[1] = 1) then
            true()
          else
            false()
        (: Reconstructing the original search hits by cutting of respective substrings before and after hit from the original attribute string.
         : Only faulty, when text between individual search hits repeats inside original attribute. Not a likely case. :)
        let $hits :=
          for $token at $pos in $tokenized-attribute-with-hits-removed
          let $hit :=
            if($attribute-starts-with-search-hit) then
              substring-after(substring-before($attribute-value, $token), $tokenized-attribute-with-hits-removed[$pos - 1])
            else
              substring-after(substring-before($attribute-value, $tokenized-attribute-with-hits-removed[$pos+1]), $token)
          return $hit
        (: reconstructing attribute from tokenized attribute (delimiter: search-term) and hits. Highlighting hit. :)
        let $highlighted-hits-with-surrounding-tokens :=
          for $hit at $pos in $hits
          let $highlighted-hit := charter:highlight-string($hit)
          return
            if( $attribute-starts-with-search-hit) then
              (: attribute looked like: "hit|string" :)
              ($highlighted-hit, $tokenized-attribute-with-hits-removed[$pos])
            else
              (: attribute looked like: "string|hit|string" :)
              ($tokenized-attribute-with-hits-removed[$pos], $highlighted-hit)
        return ( concat("@", $attribute-name, " => ") , $highlighted-hits-with-surrounding-tokens, " ")
    return $best-performance-depending-on-number-of-search-matches
  return $matches-made-pretty

};

declare function charter:highlight-string($arg as xs:string) as node() {
  <span class="hi">{$arg}</span>
};

declare function charter:index-of-string (: see functx:index-of-string :)
  ( $arg as xs:string? ,
    $substring as xs:string )  as xs:integer* {

  if (contains($arg, $substring))
  then (string-length(substring-before($arg, $substring))+1,
        for $other in
           charter:index-of-string(substring-after($arg, $substring),
                               $substring)
        return
          $other +
          string-length(substring-before($arg, $substring)) +
          string-length($substring))
  else ()
 };

 declare function charter:number-of-matches-case-insensitive (: see functx:number-of-matches; changed to case-insensitive! :)
  ( $arg as xs:string? ,
    $pattern as xs:string )  as xs:integer {

   count(tokenize($arg,$pattern, "i")) - 1
 } ;
