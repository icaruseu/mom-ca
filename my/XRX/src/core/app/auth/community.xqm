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

module namespace community="http://www.monasterium.net/NS/community";

(:
    ##################
    #
    # Community module
    #
    ##################
    
    This module is part of the authentification 
    app and handles community specific
    permissions
:)

declare namespace xrx="http://www.monasterium.net/NS/xrx";

import module namespace user="http://www.monasterium.net/NS/user"
    at "../user/user.xqm";
import module namespace atom="http://www.w3.org/2005/Atom"
    at "../data/atom.xqm";
import module namespace member="http://www.monasterium.net/NS/member"
    at "../auth/member.xqm";
    
(:
    ##################
    #
    # Variables
    #
    ##################
:)

declare variable $community:object-type := 'community';

(:
    ##################
    #
    # Functions
    #
    ##################
:)

(: 
    apply community rights to a user
    (a) insert element <xrx:community>ID</xrx:community>
        into <xrx:communities/>
    (b) update the user specific document in the database
:) 
declare function community:add($userid as xs:string, $communityid as xs:string) as element(){

    let $document := community:document($userid)
    return
    if(not(community:exists($userid, $communityid))) then
    
        let $element := <xrx:community xmlns="http://www.monasterium.net/NS/xrx">{ $communityid }</xrx:community>
        let $updated-document := 
            root(
                <xrx:communities xmlns="http://www.monasterium.net/NS/xrx">
                    {(
                        $element,
                        $document//xrx:community
                    )}
                </xrx:communities>
            )
        let $update-document := community:update($userid, $updated-document/xrx:communities)
        return
        $updated-document/xrx:communities
        
    else 
        $document/xrx:communities
};
(: 
    cancel community rights
    (a) remove element <xrx:community>ID</xrx:community>
        from <xrx:communities/>
    (b) update the user specific document in the database
:)
declare function community:remove($userid as xs:string, $communityid as xs:string) as element(){

    let $document := community:document($userid)
    return
    if(community:exists($userid, $communityid)) then

        let $updated-document :=
            root(
                <xrx:communities xmlns="http://www.monasterium.net/NS/xrx">
                    {
                        $document//xrx:community[.!=$communityid]
                    }
                </xrx:communities>
            )
        let $update-document := community:update($userid, $updated-document/xrx:communities)
        return
        $updated-document/xrx:communities

    else
        $document/xrx:communities
};

(: check if the user already has rights for the community :)
declare function community:exists($userid as xs:string, $communityid as xs:string) as xs:boolean {
    
    exists(user:home-collection($userid)//xrx:community[.=$communityid])
};
(: update the user specific document :)
declare function community:update($userid as xs:string, $document as element(xrx:communities)) {

    member:update($userid, $document, community:entry-name($userid))
};
(: get the user specific document :)
declare function community:document($userid as xs:string) as node() {

    let $existing-document := root(user:home-collection($userid)/xrx:communities)
    return
    if(exists($existing-document)) then 
        $existing-document
    else
        root(
            <xrx:communities xmlns="http://www.monasterium.net/NS/xrx">
                <xrx:community/>
            </xrx:communities>
        )
};
(: always use this function to create the resource name :)
declare function community:entry-name($userid) as xs:string {

    xmldb:encode(
        concat(
            $userid,
            '.',
            $community:object-type,
            '.xml'
        )
    )
};
(: 
    list of users with community permission, 
    i.e. their emails 
:)
declare function community:emails($communityid as xs:string) as xs:string* {

    member:emails($communityid, <xrx:community/>)
};

(:
    hand over a list of userids which shall 
    represent the current user list whith 
    instituional permissions, which means
    a comlete refresh
    (a)     remove all existing <xrx:community>ID</xrx:community>
            elements
    (b)     insert the new ones
:)
declare function community:refresh($userids as xs:string*, $communityid as xs:string) {

    let $existing-users := community:emails($communityid)
    
    let $clear-users := 
        for $existing-user in $existing-users
        return
        community:remove($existing-user, $communityid)
    
    let $update-users :=
        for $userid in $userids
        return
        community:add($userid, $communityid)
    
    return
    for $u in $existing-users return <xrx:removed>{ $u }</xrx:removed>
};

