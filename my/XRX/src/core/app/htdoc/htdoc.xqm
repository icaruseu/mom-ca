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

module namespace htdoc="http://www.monasterium.net/NS/htdoc";

declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../xrx/conf.xqm";
import module namespace i18n="http://www.monasterium.net/NS/i18n"
    at "../i18n/i18n.xqm";
import module namespace user="http://www.monasterium.net/NS/user"
    at "../user/user.xqm";
import module namespace xrx="http://www.monasterium.net/NS/xrx"
    at "../xrx/xrx.xqm";
    



(:
    ##################
    #
    # Htdoc System
    # (for handling static html pages)
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
(: DB base collection of all htdocs :)
declare variable $htdoc:db-base-collection-path :=
    conf:param('xrx-htdoc-db-base-uri');
(: DB base collection where all static htdocs are stored :)
declare variable $htdoc:db-base-collection :=
    collection(
        $htdoc:db-base-collection-path
    );
(: DB base collection for default htdocs :)
declare variable $htdoc:default-lang-db-base-collection := 
    collection(
        concat(
            $htdoc:db-base-collection-path,
            conf:param('default-lang')
        )
    );
(: 
    DB base collection for htdocs of 
    the currently selected language 
:)
declare variable $htdoc:actual-lang-db-base-collection := 
    collection(
        concat(
            $htdoc:db-base-collection-path,
            $xrx:lang
        )
    );


(:
    ##################
    #
    # Functions
    #
    ##################
:)
(: 
    returns a element of type atom:entry since
    all htdocs are treated as Atom entries.
    returns a empty sequence if no entry with the
    given Atom ID was found
:)       
declare function htdoc:get($atom-id as xs:string) as element()* {

    (
        $htdoc:actual-lang-db-base-collection//atom:id[.=$atom-id]/parent::atom:entry,
        $htdoc:default-lang-db-base-collection//atom:id[.=$atom-id]/parent::atom:entry
    )[1]
};

(:
    same as htdoc:get($atom-id as xs:string) but
    the language can be handed over to check 
    the existence of a specific htdoc
    entry
:)
declare function htdoc:get($atom-id as xs:string, $lang as xs:string) as element()* {

    collection(
        concat(
            $htdoc:db-base-collection-path,
            $lang
        )
    )//atom:id[.=$atom-id]/parent::atom:entry
};

(: 
    returns a element of type xhtml:div by 
    handing over a Atom entry
:)
declare function htdoc:process($htdoc-entry as element(atom:entry)*) as element()* {

    let $atom-content-element := $htdoc-entry//atom:content
    
    return
    
    if($htdoc-entry) then
	    htdoc:xhtml(
	        <div>
	            { util:parse-html(concat('<div>', $atom-content-element/text(), '</div>'))//BODY/child::node() }
	        </div>
	    )
	else ()
};

(:
    add namespace xhtml to each html element
:)
declare function htdoc:xhtml($html as element()) as element() {

    element { QName('http://www.w3.org/1999/xhtml', xs:string(node-name($html))) } {
        
        $html/@*,
        for $child in $html/child::node()
        return
        typeswitch($child)
            
        case element() return
            
            htdoc:xhtml($child)
                    
        default return $child 
    }
};

declare function htdoc:id($htdoc-entry as element(atom:entry)) as xs:string* {

    $htdoc-entry/atom:id/text()
};

(:
    returns the Atom title of a htdoc entry
:)
declare function htdoc:title($htdoc-entry as element(atom:entry)*) as element()* {

    <xhtml:span>{ i18n:translate($htdoc-entry/atom:title/xrx:i18n) }</xhtml:span>
};

(:
    returns the name of the author in 
    a readable form (firstname name)
    by handing over a atom:entry element
:)
declare function htdoc:author($htdoc-entry as element(atom:entry)) as xs:string* {
    
    let $user-id := $htdoc-entry/atom:author/atom:email/text()
    return
    user:firstname-name($user-id)
};

declare function htdoc:updated($htdoc-entry as element(atom:entry)) as xs:string* {

    substring-before($htdoc-entry/atom:updated/text(), 'T')
};
