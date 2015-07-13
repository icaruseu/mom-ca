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

module namespace sqlimport="http://www.monasterium.net/NS/sqlimport";

declare namespace cei="http://www.monasterium.net/NS/cei";

import module namespace xrx="http://www.monasterium.net/NS/xrx"
    at "../xrx/xrx.xqm";
import module namespace data="http://www.monasterium.net/NS/data"
    at "../data/data.xqm";
import module namespace metadata="http://www.monasterium.net/NS/metadata"
    at "../data/metadata.xqm";
import module namespace atom="http://www.w3.org/2005/Atom"
    at "../atom/atom.xqm";
import module namespace charter="http://www.monasterium.net/NS/charter"
    at "../charter/charter.xqm";

(:~
  readout a database row by row, transform the row
  into CEI and validate CEI. If valid continue reading
  else stop and return the rownum which led to invalid 
  CEI
:)
declare function sqlimport:do($driverclass, 
    $connectionURL, 
    $driveruri, 
    $dbusername, 
    $dbpassword,
    $sql-script as xs:string, 
    $stylesheet, 
    $uri-tokens,
    $destination-feed,
    $cacheid as xs:string,
    $processid as xs:string,
    $rownum-start as xs:integer) {
    
    let $clear-grammar-chache := validation:clear-grammar-cache()
    let $schema := $xrx:db-base-collection/xs:schema[@id='cei']
    let $sql-connection := sql:get-connection($driverclass, $connectionURL, $driveruri, $dbusername, $dbpassword)
    let $max := 25000
    
    let $do :=
    try {
        for $rownum at $num in ($rownum-start to $max)
        return     
        let $progress := 
            <xrx:progress>
              <xrx:cacheid>{ $cacheid }</xrx:cacheid>
              <xrx:processid>{ $processid }</xrx:processid>
              <xrx:actual>{ $rownum }</xrx:actual>
              <xrx:total>0</xrx:total>
              <xrx:message>Importing row { $rownum }...</xrx:message>        
            </xrx:progress>
        let $cache := cache:put($cacheid, $processid, $progress)
        (: query the remote database :)
        let $sql := replace($sql-script, '%i%', xs:string($rownum))
        let $execute := sql:execute($sql-connection, $sql, true())
        let $result := sqlimport:transform($execute)
        
        (: transform the queried XML result into CEI :)
        let $data-transformed := transform:transform($result, $stylesheet, ())
        
        
        (: validate CEI :)
        let $validation-report := data:validate($data-transformed, $schema)
        let $is-valid := if($validation-report//status[.='valid']) then true() else false()
        let $break := if(not($is-valid) or $execute/@count/string() = '0') then xs:string(break) else()
        
        (: charter info :)
        let $idno := charter:map-idnos($data-transformed//cei:body/cei:idno, false())
        let $atomid := metadata:atomid('charter', ($uri-tokens, $idno))
        let $entry-name := xmldb:encode(concat($idno, '.cei.xml'))
        let $charter-entry := 
        <atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
            <atom:id>{ $atomid }</atom:id>
            <atom:title/>
            <atom:published/>
            <atom:updated/>
            <atom:author>
                <atom:email/>
            </atom:author>
            <app:control xmlns:app="http://www.w3.org/2007/app">
              <app:draft>no</app:draft>
            </app:control>
            <atom:content type="application/xml">{ charter:insert-unique-idno($data-transformed, $idno) }</atom:content>
        </atom:entry>  
        let $post := 
            atom:POST(
                $destination-feed,
                $entry-name,
                $charter-entry
            )
        return
        $result
    }
    catch * { 
        let $rownum := cache:get($cacheid, $processid)//xrx:actual/text()
        let $clear-cache := cache:clear($cacheid) 
        return 
        <error>{ $rownum }</error> 
    }
    (: clear cache :)
    let $clear-cache := cache:clear($cacheid)
    return
    $do
};

(:~
  check if SQL connection can be established
:)
declare function sqlimport:connect($driverclass as xs:string?, $connectionURL as xs:string?, $driveruri as xs:string?, $dbusername as xs:string?, $dbpassword as xs:string?) {

    try { sql:get-connection($driverclass, $connectionURL, $driveruri, $dbusername, $dbpassword) } catch * { <error>{ $err:description }</error> }
};

(:~
 if sql:row is of type 'xml' parse its content
:)
declare function sqlimport:transform($result as element(sql:result)) {

    element { node-name($result) }
    {
        $result/@*,
        for $row in $result/sql:row
        return
        element { node-name($row) } 
        {
            $row/@*,
            for $child in $row/*
            return
            element { node-name($child) }
            {
                $child/@*,
                if($child/@sql:type/string() = 'xml') then
                    util:parse(util:parse-html($child/text()))
                else
                    $child/text()
            }
        }
        
    }
};
