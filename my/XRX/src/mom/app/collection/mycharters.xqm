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

module namespace mycharters="http://www.monasterium.net/NS/mycharters";

declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace cei="http://www.monasterium.net/NS/cei";

import module namespace charter="http://www.monasterium.net/NS/charter"
    at "../charter/charter.xqm";
import module namespace charters="http://www.monasterium.net/NS/charters"
    at "../charters/charters.xqm";

(:~
  charter view
:)
declare function mycharters:entries($charter-base-collection) {
    for $entry in $charter-base-collection/atom:entry
    let $just-linked-atomid := $entry/atom:content/@src/string()
    let $cei-text := 
        if($just-linked-atomid != '') then charter:public-entry($just-linked-atomid)
        else $entry
    let $date := if(exists($cei-text//cei:issued/cei:date/@value)) then $cei-text//cei:issued/cei:date/@value
    else $cei-text//cei:issued/cei:dateRange/@from
    order by xs:integer($date)
    return
    $entry
};

declare function mycharters:block-strings($entries as element(atom:entry)*) as xs:string* {

    let $sorted-dates :=
        for $entry in $entries
        let $just-linked-atomid := $entry//atom:content/@src/string()
        let $cei-text := 
            if($just-linked-atomid) then charter:public-entry($just-linked-atomid)
            else $entry
        let $date := ($cei-text//cei:date/@value/string(), $cei-text//cei:dateRange/@from/string(), '99999999')[1]
        order by xs:integer($date)
        return
        $date
    return 
        charters:block-strings($sorted-dates)
};
