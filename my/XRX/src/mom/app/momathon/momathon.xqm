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

module namespace momathon = "http://www.monasterium.net/NS/momathon";
import module namespace upd="http://www.monasterium.net/NS/upd" at "xmldb:exist:///db/XRX.live/mom/app/xrx/upd.xqm";
import module namespace xrx="http://www.monasterium.net/NS/xrx" at "xmldb:exist:///db/XRX.live/mom/app/xrx/xrx.xqm";
import module namespace conf="http://www.monasterium.net/NS/conf" at "xmldb:exist:///db/XRX.live/mom/app/xrx/conf.xqm";
declare namespace xf="http://www.w3.org/2002/xforms";
declare namespace ev="http://www.w3.org/2001/xml-events";
declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace bfc="http://betterform.sourceforge.net/xforms/controls";
declare namespace atom="http://www.w3.org/2005/Atom";

declare variable $momathon:cur-date := current-dateTime();
declare variable $momathon:date := format-dateTime($momathon:cur-date, "[Y,4][M,2][D,2]");
declare variable $momathon:user := $xrx:user-id;
declare variable $momathon:base-mom-collection := collection("/db/mom-data/metadata.momathon/");

declare function momathon:CheckForCollection() {
(: If collection doesn't exist, create collection and mom-log-file :)

    let $col := collection("/db/mom-data/metadata.momathon/")
    
    let $check := if(not(exists($col))) then
        let $new-col := xmldb:create-collection("/db/mom-data", "metadata.momathon")
        let $new-file := element xrx:momathons{
            namespace xrx { "http://www.monasterium.net/NS/xrx" }, 
            element xrx:momathon { 
                attribute id {util:uuid()}, 
                attribute from{$momathon:date}, 
                attribute to{$momathon:date}, 
                element xrx:users{} 
                } 
            }
        let $put-file := xmldb:store("/db/mom-data/metadata.momathon/", "momathon-log.xml", $new-file )
        return $put-file
        else ()
    
    return
        $check

}; 
declare function momathon:WriteMomLog($atomid as xs:string) {

    
    (: Check if collection and initial File exists :)
    let $col-Check := momathon:CheckForCollection()
    
    (: Get MOMathon-LogFile :)
    let $momathon-XML := $momathon:base-mom-collection/xrx:momathons
    
    (: extract current momathon :)
    let $momathon := $momathon-XML/xrx:momathon[@from <= $momathon:date][@to >= $momathon:date]
    
    (: just do if momathon exists :)    
    let $result := if (exists($momathon)) then
        
        (: get user entries for given user:)
        let $user-entry := $momathon//xrx:users/xrx:user[@id = $momathon:user]/xrx:charters
        
        (: Write Entry if not already there :)
        let $update := if(exists($user-entry)) then 
                
             (: if there arent any entries, create entry :)
            let $charter := element xrx:charter {namespace xrx {"http://www.monasterium.net/NS/xrx"}, attribute atomid {$atomid} } 
    
            let $update-entry := if(not(exists($user-entry/xrx:charter[@atomid=$atomid]))) then
                    
                    (: update file to disk :)
                    let $update-db := update insert $charter into $user-entry 
        
                    return 
                        $update-db
                    
                else ()
                
            return
                $update-entry
                
            else 
            
            (: if user-entry isn't there, create entry :)
            let $new-entry := 
                element xrx:user{
                    namespace xrx { "http://www.monasterium.net/NS/xrx" },
                    attribute id{$momathon:user}, 
                    element xrx:charters{
                        element xrx:charter {
                            attribute atomid {$atomid} 
                        }
                    }
                }
            
            (: insert new node to file :)
            let $insert-db := update insert $new-entry into $momathon//xrx:users 
            
            return
                $insert-db
                
        (: Return entry:)
        return 
            $update
        
        else ()
    
    return
        $result
};

declare function momathon:DoneCharters($user-id as xs:string, $mom-charter as element()*) as xs:int {
    (: Get user-XML :)
    let $user-xml := collection(conf:param('xrx-user-db-base-uri'))//xrx:user[xrx:email=$user-id]//xrx:saved_list
   
    (: Iterate through all done Charters per User and check, if xrx:freigabe is set to "yes":)
    (:for $entry in :)
        
    let $user-entry := $user-xml//xrx:id[text() = data($mom-charter/@atomid)]/ancestor::*[local-name() = "saved"]/xrx:freigabe[text() = "yes"]

    return
        count($user-entry)    

};