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

declare namespace cei="http://www.monasterium.net/NS/cei";

(:~ 
  request parameter 
:)
declare variable $charters:rblock := xs:integer(request:get-parameter('block', '-1'));
declare variable $charters:start := $charters:rblock * 30 - 30;
declare variable $charters:stop := $charters:rblock * 30;
declare variable $charters:previous-block := if($charters:rblock = 1) then 1 else $charters:rblock - 1;

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

    for $year in $charter-base-collection//cei:text//(cei:date/@value|cei:dateRange/@from)
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
