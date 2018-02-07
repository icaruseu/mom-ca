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
module namespace role="http://www.monasterium.net/NS/role";
(:
    ##################
    #
    # Role module
    #
    ##################
    
    This module is part of the authentification 
    app and handles role specific permissions
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
declare variable $role:object-type := 'role';
declare variable $role:default-apply-service := 'tag:www.monasterium.net,2011:/core/service/apply-role';
declare variable $role:rapply-service := request:get-parameter('applyservice', $role:default-apply-service);
(:
    ##################
    #
    # Functions
    #
    ##################
:)
(: 
    list of users with a special role, 
    i.e. their emails 
:)
declare function role:emails($roleid as xs:string) as xs:string* {

    member:emails($roleid, <xrx:role/>)
};
(: 
    apply a role to a user
    (a) insert element <xrx:role>ID</xrx:role>
        into <xrx:roles/>
    (b) update the user specific document in the database
:) 
declare function role:add($userid as xs:string, $roleid as xs:string) as element(){

    let $document := role:document($userid)
    return
    if(not(role:exists($userid,  $roleid))) then
    
        let $element := <xrx:role xmlns="http://www.monasterium.net/NS/xrx">{ $roleid }</xrx:role>
        let $updated-document := 
            root(
                <xrx:roles xmlns="http://www.monasterium.net/NS/xrx">
                    {(
                        $element,
                        $document//xrx:role
                    )}
                </xrx:roles>
            )
        let $update-document := role:update($userid, $updated-document/xrx:roles)
        return
        $updated-document/xrx:roles
        
    else 
        $document/xrx:roles
};
(: always use this function to create the resource name :)
declare function role:entry-name($userid) as xs:string {

    xmldb:encode(
        concat(
            $userid,
            '.',
            $role:object-type,
            '.xml'
        )
    )
};
(: update the user specific document :)
declare function role:update($userid as xs:string, $document as element(xrx:roles)) {

    member:update($userid, $document, role:entry-name($userid)) 
};
(: 
    cancel a role
    (a) remove element <xrx:role>ID</xrx:role>
        from <xrx:roless/>
    (b) update the user specific document in the database
:)
declare function role:remove($userid as xs:string, $roleid as xs:string) as element(){

    let $document := role:document($userid)
    return
    if(role:exists($userid, $roleid)) then

        let $updated-document :=
            root(
                <xrx:roles xmlns="http://www.monasterium.net/NS/xrx">
                    {
                        $document//xrx:role[.!=$roleid]
                    }
                </xrx:roles>
            )
        let $update-document := role:update($userid, $updated-document/xrx:roles)
        return
        $updated-document/xrx:roles

    else
        $document/xrx:roles
};
(: get the user specific document :)
declare function role:document($userid as xs:string) as node() {

    let $existing-document := root(user:home-collection($userid)/xrx:roles)
    return
    if(exists($existing-document)) then 
        $existing-document
    else
        root(
            <xrx:roles xmlns="http://www.monasterium.net/NS/xrx">
                <xrx:role/>
            </xrx:roles>
        )
};
(: check if the user already has this role :)
declare function role:exists($userid as xs:string, $roleid as xs:string) as xs:boolean {
    
    exists(user:home-collection($userid)//xrx:role[.=$roleid])
};
(:
    hand over a list of userids which shall 
    represent the current user list whith 
    role permissions, which means
    a complete refresh
    (a)     remove all existing <xrx:role>ID</xrx:role>
            elements
    (b)     insert the new ones handed over
:)
declare function role:refresh($userids as xs:string*, $roleid as xs:string) {

    let $existing-users := role:emails($roleid)
    
    let $clear-users := 
        for $existing-user in $existing-users
        return
        role:remove($existing-user, $roleid)
    
    
    let $update-users :=
        for $userid in $userids
        return
        role:add($userid, $roleid)
    
    return
    for $u in $existing-users return <xrx:removed>{ $u }</xrx:removed>
};

    