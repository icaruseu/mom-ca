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

module namespace assertion="http://www.monasterium.net/NS/assertion";

declare namespace xrx="http://www.monasterium.net/NS/xrx";

import module namespace template="http://www.monasterium.net/NS/template"
    at "../xrx/template.xqm";
import module namespace i18n="http://www.monasterium.net/NS/i18n"
    at "../i18n/i18n.xqm";


declare variable $assertion:template := template:get('tag:www.monasterium.net,2011:/core/template/assertion');

declare function assertion:translate($message as xs:string) as xs:string* {

    let $key := substring-before($message, ':')
    let $assertion := $assertion:template//xrx:assertion[xrx:key=$key]
    let $translation := if($assertion) then assertion:translation($assertion, $message) else $message
    let $fatalindicator := if($assertion) then $assertion//xrx:fatal/text() else "0"
    let $return := ($translation, $key, $fatalindicator)
    return
        $return
};

declare function assertion:translation($assertion as element(xrx:assertion), $message as xs:string) as xs:string {

    let $composed := 
        for $e in $assertion/xrx:translation/*
        return
        typeswitch($e) 
        case(element(xrx:i18n)) return
            
            i18n:translate($e)
        
        case(element(xrx:string)) return
        
            $e/text()
        
        case(element(xrx:function)) return
        
            let $function := function-lookup(QName('http://www.monasterium.net/NS/assertion', $e/xrx:name/text()), 1)
            let $stringposition := xs:integer($e/xrx:parameter/@stringposition/string())
            let $string := assertion:string-at-position($message, $stringposition)
            return
            $function($string)
            
        default return ' '
        
    return
    normalize-space(string-join($composed, ''))
};

declare function assertion:string-value($string as xs:string) as xs:string {

    concat('"', $string, '"')
};

declare function assertion:translate-element-sequence($string as xs:string) as xs:string {
    
    let $remove-bracket := substring-before(substring-after($string, '{'), '}')
    let $tokens := tokenize($remove-bracket, ',')
    let $i18n-messages :=
        for $token at $pos in $tokens
        let $namespace := replace(substring-before($token, '":'), "'", '')
        let $prefix := (tokenize($namespace, '/'))[last()]
        let $element-name := substring-after($token, '":')
        let $i18n-key := concat($prefix, '_', $element-name)
        let $i18n-message := i18n:message($i18n-key, $xrx:lang)
        return
        if($i18n-message) then concat('"', i18n:translate($i18n-message), ' (', $element-name, ')', '"')
        else $token
    return
    string-join($i18n-messages, ', ')
};

declare function assertion:translate-attribute-name($string as xs:string) as xs:string {

    (: how can we compose the i18n key without knowing the namespace of the attribute? :)
    concat('"', $string, '"')
};

declare function assertion:translate-element-name($string as xs:string) as xs:string {

    let $i18n-key := replace($string, ':', '_')
    let $i18n-message := i18n:message($i18n-key, $xrx:lang)
    let $translated :=
        if($i18n-message) then
            i18n:translate($i18n-message)
        else
            $string
    return
    concat('"', $translated, '"')
};

declare function assertion:string-at-position($message as xs:string, $position as xs:integer) as xs:string {

    let $tokens := tokenize($message, "'")
    return
    $tokens[$position * 2]
};
