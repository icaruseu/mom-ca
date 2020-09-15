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

module namespace auth="http://www.monasterium.net/NS/auth";

declare namespace xrx="http://www.monasterium.net/NS/xrx";

import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../xrx/conf.xqm";
import module namespace user="http://www.monasterium.net/NS/user"
    at "../user/user.xqm";
    
(:
    the auth processing main function
:)    
declare function auth:process($auth as element(xrx:auth)) {

    let $expression := auth:preprocess($auth)
    return
    util:eval($expression)
};

(: 
    auth function for recursive call
    if two sibling units are defined we 
    assume a logical AND operator 
:)
declare function auth:preprocess($element as element()) {
    
    auth:parse(<xrx:and>{ $element/xrx:rules/xrx:* }</xrx:and>)
};

(:
    auth parser
:)
declare function auth:parse($element) as item()*{

    typeswitch($element)
    
    case element(xrx:or) return 
    
        (
            '(',
            for $e in $element/*
            return
            auth:parse($e),
            ')'
        )

    case element(xrx:and) return 

        (
            '(',
            for $e in $element/*
            return
            auth:parse($e),
            ')'
        )
    
    case element(xrx:not) return
    
        (
            'not(',
            auth:preprocess($element),
            ')'
        )
    
    case element(xrx:true) return ()
    
    case element(xrx:false) return ()
       
    default return 
    
        if(exists($element/parent::xrx:or) and exists($element/preceding-sibling::*)) then
        (
            ' or auth:matches(',
             $element,
            ')'
        )        
        else if(exists($element/parent::xrx:and) and exists($element/preceding-sibling::*)) then
        (
            ' and auth:matches(',
             $element,
            ')'
        ) 
        else
        (
            'auth:matches(',
             $element,
            ')'
        )
};

(:
    test if the given unit matches
    TODO: this function should be more generic
:)
declare function auth:matches($rule as element(xrx:rule)) as xs:boolean {

    let $agent := 
        if($rule/xrx:not) then $rule/xrx:not/xrx:*[1]
        else $rule/xrx:*[1]
    let $unit := 
        if($rule/xrx:not) then $rule/xrx:not/xrx:*[2]
        else $rule/xrx:*[2]
    let $matches :=
    typeswitch($unit)
    
    (:
        Do we auth against a DB group?
        For auth unit 'dbgroup' there are only 
        three values allowed:
        
        'guest' for not logged-in users
        'atom' for normal logged-in users
        'dba' for logged-in users with special DB permissions
    :)
    case element(xrx:dbgroup) return
    
        let $user-db-groups := 
            if(sm:id()//sm:username/text() != 'guest') then 
                system:as-user('admin', conf:param('dba-password'), xmldb:get-user-groups(sm:id()//sm:username/text())) 
            else 
                ()
        let $match := 
            for $user-dbgroup in $user-db-groups
            return
            if($user-dbgroup = $unit/text()) then true()
            else()
        return
        if(count($match) gt 0) then $match[1]
        else false()
    
    (: Do we authenticate against a role? :)
    case element(xrx:role) return
    
        let $user-roles := user:home-collection(sm:id()//sm:username/text())//xrx:role
        let $match := 
            for $user-role in $user-roles
            return
            if(deep-equal($unit, $user-role)) then true()
            else()
        return
        if(count($match) gt 0) then $match[1]
        else false()
        
    (: Do we authenticate against a community? :)
    case element(xrx:community) return
    
        let $user-communities := user:home-collection(sm:id()//sm:username/text())//xrx:community
        let $match := 
            for $user-community in $user-communities
            return
            if(deep-equal($unit, $user-community)) then true()
            else()
        return
        if(count($match) gt 0) then $match[1]
        else false()
    
    default return false()
    
    return
    
    if($rule/xrx:not) then not($matches)
    else $matches
    
};