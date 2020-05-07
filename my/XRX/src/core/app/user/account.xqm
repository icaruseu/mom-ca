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



(:
    ##################
    #
    # Account Module
    #
    ##################
    
    
    A module that handles creating, updating or 
    removing a user account. This module was invented 
    in addition to the User Module to have all 
    security critical functions available at one
    place
    
    Since this module is included by xrx.xql
    these functions and variables are visible 
    for all widgets, services, portals ...
:)

module namespace account="http://www.monasterium.net/NS/account";

import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../xrx/conf.xqm";
import module namespace upd="http://www.monasterium.net/NS/upd"
    at "../xrx/upd.xqm";
import module namespace atom="http://www.w3.org/2005/Atom"
    at "../data/atom.xqm";

declare namespace xrx="http://www.monasterium.net/NS/xrx";




(:
    ##################
    #
    # Variables
    #
    ##################
:)

(: all groups which should be set by default for a new user :)
declare variable $account:user-groups := ('guest', 'atom');
(: name of the DB admin user :)
declare variable $account:admin-user := 'admin';
(: password of the DB admin user :)
declare variable $account:admin-pass := conf:param('dba-password');
(:  :)
declare variable $account:current-date-time := current-dateTime();




(:
    ##################
    #
    # Functions
    #
    ##################
:)

(: 
    helper function which removes all passwords
    which were temporarly saved into the user.xml
:)
declare function account:remove-password($user-xml) {
    let $remove-password := 
        upd:replace-element-content($user-xml//xrx:password, text{''})
    let $remove-repeat-password := 
        upd:replace-element-content($remove-password//xrx:username, text{''})
    return
    $remove-repeat-password
    
};

(: 
    function returns true if the user 
    name handed over has a database account, false if not
:)
declare function account:is-known-user($email, $password) {
    
    xmldb:login(conf:param('xrx-user-db-base-uri'), $email, $password, false())
};

(: 
    helper function which creates a char salad
    which can be appended as a request parameter 
    by the account email service
:)
declare function account:confirmation-code($email) {

    let $email-as-binary := util:string-to-binary($email, 'UTF-8')
    let $confirmation-code := util:hash($account:current-date-time, 'MD5')
    return
    concat($email-as-binary, ',', $confirmation-code)

};

(: 
    function creates a new account which has then 
    to be activated  
:)
declare function account:create-user($user-xml) {
   
    let $password := $user-xml//xrx:password/text()
    let $email := $user-xml//xrx:email/text()
    let $resource := concat(xmldb:encode($email), '.xml')
    let $create-user-xml := atom:POST(conf:param('xrx-user-atom-base-uri'), $resource, $user-xml)
    return
    ()
    
};

(: helper function to  :)
declare function account:email-from-code($code as xs:string) as xs:string {

    let $email-binary := substring-before($code, ',')
    let $email := util:binary-to-string(xs:base64Binary($email-binary))
    return
    $email
};

(:
    function activates a account after
    a user has clicked the 'confirm account
    link' sended by the account email service
:)
declare function account:confirm($code as xs:string) as xs:string {

    let $email := account:email-from-code($code)
    let $user-xml := collection(conf:param('xrx-user-db-base-uri'))//xrx:user[xrx:email=$email]
    let $password := $user-xml//xrx:password/text()
    let $login := xmldb:login(conf:param('xrx-user-db-base-uri'), $account:admin-user, $account:admin-pass)
    let $create-user-account := 
        if(not(xmldb:exists-user($email))) then xmldb:create-user($email, $password, $account:user-groups, '')
        else passwd($email, $password, $account:user-groups)
    let $remove-password := account:remove-password($user-xml)
    let $update-user-xml := atom:POST(conf:param('xrx-user-atom-base-uri'), concat(xmldb:encode($email), '.xml'), $remove-password)
    let $logout := xmldb:login(conf:param('xrx-user-db-base-uri'), 'guest', 'guest')
    return
    $email
};

(:
    function sets a new password after a
    user has clicked the 'new password link'
    sended by the account email service
:)
declare function account:reset-password($code) {

    let $code1 := substring-before($code, ',')
    let $confirmation-code := substring-after($code, ',')
    let $new-password := account:new-password($code)
    let $email := util:binary-to-string(xs:base64Binary($code1))
    let $change-user := 
        system:as-user(
            $account:admin-user,
            $account:admin-pass,
            passwd($email, $new-password, $account:user-groups, '')
        )
    return
    $new-password
};

(: 
    helper function to encrypt a email address 
    useful for the account email service 
:)
declare function account:email-as-binary($email) {

    util:string-to-binary($email, 'UTF-8')
};

(: helper function to 'guess' a new password :)
declare function account:new-password($code as xs:string) as xs:string {

    substring($code, 1, 8)
};

(: 
    function handles the reset of a new password sended 
    by the account email service 
:)
declare function account:request-password($email) {
    
    let $user-exists := 
        if(count(collection(conf:param('xrx-user-db-base-uri'))/xrx:user[xrx:email=$email]) = 1) then true()
        else false()
    return
    $user-exists
};

(:  :)
declare function account:update-user($user-xml) {

    let $email := $user-xml//xrx:email/text()
    let $password := $user-xml//xrx:password/text()
    let $auth := account:is-known-user($email, $password)
    let $remove-password := account:remove-password($user-xml)
    let $update-user := 
        if($auth) then
        (
            atom:POST(conf:param('xrx-user-atom-base-uri'), concat(xmldb:encode($email), '.xml'), $remove-password),
            system:as-user(
                $account:admin-user,
                $account:admin-pass,
                passwd($email, $password, $account:user-groups, '')
            )
        )
        else()
    return
    $auth
};

(: function updates the user profile :)
declare function account:change-user-data($data) {
    
    let $email := $data//xrx:email/text()
    return
    system:as-user(
        $account:admin-user,
        $account:admin-pass,
        atom:POST(conf:param('xrx-user-atom-base-uri'), concat(xmldb:encode($email), '.xml'), $data)
    )
};

(: function changes the password of a user :)
declare function account:change-password($email, $data) {
    
    let $oldpassword := $data//xrx:oldpassword/text()
    let $newpassword := $data//xrx:newpassword/text()
    let $auth := account:is-known-user($email, $oldpassword)
    let $change-password :=
        if($auth) then
            system:as-user(
                $account:admin-user,
                $account:admin-pass,
                passwd($email, $newpassword, $account:user-groups, '')
            )
        else()
    return
    $auth
};

(: function removes a user account :)
declare function account:remove-user($email, $password) {
    
    let $auth := account:is-known-user($email, $password)
    let $remove-user-xml :=
        if($auth) then
        (
            (: TODO: remove personal data like saved charters :)
            xmldb:login('/db', $account:admin-user, $account:admin-pass),
            xmldb:remove(conf:param('xrx-user-db-base-uri'), concat(xmldb:encode($email), '.xml')),
            (: 
                The database account should never be removed
                otherwise backup and restore of XML resources
                doesnt work any more
            :)
            (: xmldb:delete-user($email), :)
            xmldb:login('/db', 'guest', 'guest')
        )
        else()
    return
    $auth
};