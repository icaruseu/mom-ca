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

module namespace oai-harvester="http://www.monasterium.net/NS/oai-harvester";

declare namespace oai="http://www.openarchives.org/OAI/2.0/";

declare function oai-harvester:list-records($base-url as xs:anyURI, 
        $metadata-prefix as xs:string, 
        $resumption-token as xs:string?, 
        $callback) {
    
    let $prepare := 
            (
            session:remove-attribute('next-resumption-token'),
            session:set-attribute('next-resumption-token', '')
            )
    let $max := 100000
    return
    try {
    
        for $i in (1 to $max)
        return
            let $get := doc(xs:anyURI(concat(
                $base-url,
                '?verb=ListRecords',
                '&amp;metadataPrefix=', $metadata-prefix,
                if(xs:string(session:get-attribute('next-resumption-token')) != '') then 
                    concat('&amp;resumptionToken=', xs:string(session:get-attribute('next-resumption-token'))) 
                else ''
            )))
            let $next-resumption-token := $get//oai:resumptionToken
            return
                if ($next-resumption-token) then
                    (
                    session:remove-attribute('next-resumption-token'),
                    session:set-attribute('next-resumption-token', xs:string($next-resumption-token/text())),
                    util:log('error', xs:string(session:get-attribute('next-resumption-token')))
                    )
                else xs:string(break)
    } catch * {
        ()
    }
};
