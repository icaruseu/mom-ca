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

module namespace user="http://www.monasterium.net/NS/user";

declare namespace xrx="http://www.monasterium.net/NS/xrx";

import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../xrx/conf.xqm";
import module namespace atom="http://www.w3.org/2005/Atom"
    at "../data/atom.xqm";

(:
    ##################
    #
    # User System
    #
    ##################
    
    Since this module is included by xrx.xql
    these functions and variables are visible 
    for all widgets, services, portals ...
:)




(:
    ##################
    #
    # Variables
    #
    ##################
:)
(: DB base collection path where all user data are stored :)
declare variable $user:db-base-collection-path :=
    conf:param('xrx-user-db-base-uri');

(: DB base collection where all user data are stored :)
declare variable $user:db-base-collection :=
    collection(
        $user:db-base-collection-path
    );
declare variable $user:feed :=
    substring-after($user:db-base-collection-path, conf:param('atom-db-base-uri'));

declare variable $user:is-loggedin := sm:id()//sm:username/text() != 'guest';

(:
    ##################
    #
    # Functions
    #
    ##################
:)

declare function user:entry-name($userid as xs:string) as xs:string {

    concat(xmldb:encode($userid), '.xml')
};

declare function user:update($user-xml as element(xrx:user)) {

    let $userid := $user-xml/xrx:email/text()
    return
    atom:POST($user:feed, user:entry-name($userid), $user-xml)
};

(: returns a user document by handing over a email address :)
declare function user:document($email as xs:string*) as node()* {

    root($user:db-base-collection//xrx:email[.=$email])
};

declare function user:home-feed($email as xs:string) as xs:string {

    xmldb:encode-uri(
        concat(
            conf:param('xrx-user-atom-base-uri'),
            $email
        )
    )
};

declare function user:home-collection-path($email as xs:string) as xs:string {

    xmldb:encode-uri(
        concat(
            conf:param('xrx-user-db-base-uri'),
            $email
        )
    )
};

declare function user:home-collection($email as xs:string) as node()* {

    collection(user:home-collection-path($email))
};

(: returns the user name (firstname name) by handing over a email address :)
declare function user:firstname-name($email as xs:string*) as xs:string* {

    let $doc := user:document($email)
    let $firstname := $doc//xrx:firstname/text()
    let $name := $doc//xrx:name/text()
    return
    concat($firstname, ' ', $name)
};

declare function user:name-firstname($email as xs:string*) as xs:string* {

    let $doc := user:document($email)
    let $firstname := $doc//xrx:firstname/text()
    let $name := $doc//xrx:name/text()
    return
    concat($name, ', ', $firstname)    
};

(: logout a user returning the success status :)
declare function user:logout() as xs:boolean {

    let $logout := xmldb:login(conf:param('atom-db-base-uri'), 'guest', 'guest')
    let $invalidate := session:invalidate()
    return
    $logout
};
