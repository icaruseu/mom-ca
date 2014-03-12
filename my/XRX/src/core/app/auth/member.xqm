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
module namespace member="http://www.monasterium.net/NS/member";
(:
    ##################
    #
    # Member module
    #
    ##################
    
    This module is part of the authentification 
    app and provides functions to be shared by
    module role.xqm and community.xqm
:)
declare namespace xrx="http://www.monasterium.net/NS/xrx";
import module namespace user="http://www.monasterium.net/NS/user"
    at "../user/user.xqm";
import module namespace atom="http://www.w3.org/2005/Atom"
    at "../data/atom.xqm";
(: 
    list of users with member specific permissions
:)
declare function member:emails($memberid as xs:string, $unit as element()) as xs:string* {

    let $member-elements := 
    
        typeswitch($unit)
        
        case element(xrx:role) return
            $user:db-base-collection//xrx:role[.=$memberid]
        
        case element(xrx:community) return
            $user:db-base-collection//xrx:community[.=$memberid]
        
        default return ()
            
    let $emails := 
        for $element in $member-elements
        let $collection-name := util:collection-name($element)
        let $tokens := tokenize($collection-name, '/')
        let $email := xmldb:decode($tokens[last()])
        return
        $email
        
    return
    
    $emails
};
(: update the user specific document :)
declare function member:update($userid as xs:string, $document as element(), $entry-name as xs:string) {

    atom:POST(
        user:home-feed($userid),
        $entry-name,
        $document
    )
        
};