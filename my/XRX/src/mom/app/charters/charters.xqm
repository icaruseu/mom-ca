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

module namespace charters="http://www.monasterium.net/NS/charters";

import module namespace xrx="http://www.monasterium.net/NS/xrx"
    at "../xrx/xrx.xqm";

import module namespace metadata="http://www.monasterium.net/NS/metadata"
    at "../metadata/metadata.xqm";

declare namespace cei="http://www.monasterium.net/NS/cei";
declare namespace atom="http://www.w3.org/2005/Atom";
(:~ 
  request parameter 
:)
declare variable $charters:rblock := xs:integer(request:get-parameter('block', '-1'));
declare variable $charters:start := $charters:rblock * 30 - 30;
declare variable $charters:stop := $charters:rblock * 30;
declare variable $charters:previous-block := if($charters:rblock = 1) then 1 else $charters:rblock - 1;
declare variable $charters:base-collection := metadata:base-collection('charter', 'public');
(:~
  request related functions
:)
declare function charters:rcontext() as xs:string {

    if(count($xrx:tokenized-uri) = 2) then 'collection' else 'fond'
};

declare function charters:rarchiveid() as xs:string* {
    
    if(charters:rcontext() = 'fond') then $xrx:tokenized-uri[1] else ''
};

declare function charters:rfondid() as xs:string* {

    if(charters:rcontext() = 'fond') then $xrx:tokenized-uri[2] else ''
};

declare function charters:rcollectionid() as xs:string* {

    if(charters:rcontext() = 'collection') then $xrx:tokenized-uri[1] else ''
};

declare function charters:ruri-tokens() as xs:string* {

    if(charters:rcontext() = 'fond') then (charters:rarchiveid(), charters:rfondid()) else charters:rcollectionid()
};

(:~
  charter view
:)
declare function charters:years($charter-base-collection) {

    for $year in $charter-base-collection//cei:text//cei:issued/(cei:date/@value|cei:dateRange/@from)
    order by xs:integer($year)
    return
    $year    
};

declare function charters:year-from-date($date as xs:string) as xs:string {

    if(string-length($date) = 7) then substring($date, 1, 3) else substring($date, 1, 4)
};

declare function charters:block-strings($sorted-dates as xs:string*) as xs:string* {
    let $log := util:log('error', $sorted-dates)
    return
    for $dates at $pos in $sorted-dates
    let $group := xs:integer($pos div 30)
    group by $group
    order by $group
    return
    concat(charters:year-from-date($dates[1]), ' - ', charters:year-from-date($dates[last()]))
     
};

(:  Get all Google Charters 
~   At first get all Collections which have "Google" inside their descriptions
~   After this, get all Charters from the previous fetched Collections
~   Return Charters with their cei:date or cei:dateRange Nodes
:)
declare function charters:getGoogleCharters() {

    (: Base-Collection for all Collections :)
    let $col-collection := metadata:base-collection('collection', 'public')

    (: Query with an index -> cei:sourceDesc->cei:p :)
    let $google_hits := $col-collection//cei:fileDesc/cei:sourceDesc[ft:query(cei:p, 'Google')]
    
    (: First Part for the Build-String :)
    let $base-col := "/db/mom-data/metadata.charter.public/"
    
    (: Optionstring for optimized Query :)
    let $options := 
                        <options xmlns="">
                            <default-operator>and</default-operator>
                            <phrase-slop>0</phrase-slop>
                            <leading-wildcard>no</leading-wildcard>
                            <filter-rewrite>yes</filter-rewrite>
                        </options>
    
    (: Get all charters from the fetched Collections:)
    let $google :=
            let $return :=
                (: Itereate through all Collections :)
                (: Limited to 20 Collections due Lag of Performance :)
                for $hit in $google_hits[position() = 1 to 20]
                    (: Get AtomId from Charter :)
                    let $atomid := root($hit)//atom:id/text()
                    (: Replace collection inside the string for a search for charters:)
                    let $cleared-id := replace($atomid, "collection", "charter")
                    
                    (: Build a:)
                    let $charter :=
                            let $token_atomid := tokenize($cleared-id, "/")
                            
                            (: Charter mit Transkriptionen :)
                            let $query := 
                                            element query {
                                                element bool {
                                                           for $token in $token_atomid
                                                                let $return := element {"term"} {
                                                                            attribute occur {"must"},
                                                                            $token }
                                                                return $return
                                                            }
                                                }
                                            
                                            
                            let $result := $charters:base-collection/atom:entry[ft:query(atom:id, $query, $options)] 
                            return
                                $result 
            
                    let $chars := if(exists($charter//cei:dateRange)) then $charter//cei:dateRange/@to else $charter//cei:date/@value
                    
                    return
                       $chars
            return
                $return
    return
        (: Order all Charters -> cei:date/dateRange :)       
         charters:orderDate($google)
};

(: Order all Charters and return them in an ordered state :)
declare function charters:orderDate($quantity) {
        let $return := for $hit in $quantity
            let $atomentry := $hit
            order by $atomentry
            return
                $atomentry 

return $return
};

(: Return all Charters with Date/DateRange '99999999' :)
declare function charters:GetDateCharters()  {
    (: Get all Charters without any Consideration of Archive, Fond or Collection  :)
    let $hits := $charters:base-collection//cei:issued//descendant-or-self::*[ft:query(@value, '99999999')]
    (:let $hits_r := $charters:base-collection//cei:issued//descendant-or-self::*[ft:query(@to, '99999999')] :)
    (: Return all Charters in an ordered State :)
    return
        ($hits)
};
(: Return all Charters with Images :)
declare function charters:GetTranscriptionCharters() {
    let $trans := $charters:base-collection//atom:entry[.//cei:figure/cei:graphic/@url][.//cei:tenor/normalize-space(text()[1]) !='' ]
    let $return := for $char in $trans[position() = 1 to 2000]
        let $single_char := root($char)//cei:text//cei:issued/(cei:date/@value|cei:dateRange/@from)
        return
            $single_char

    return
        charters:orderDate($return)
};

(: Main Function which calles the individual Function depending on the $parameter-Attribute :)
declare function charters:GetMomathonCharter($parameter as xs:string)  {

(: In Dependency of the given Parm, return Charterlist :)
let $hits := 
    switch($parameter)
        case "date" return charters:GetDateCharters()
        case "google" return charters:getGoogleCharters()
        case "transcription" return charters:GetTranscriptionCharters()
        default return charters:GetDateCharters()

return
    $hits
};