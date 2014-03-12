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

module namespace service="http://www.monasterium.net/NS/service";

declare namespace xrx="http://www.monasterium.net/NS/xrx";

declare function service:variable-expression($variables as element(xrx:variables)*) {

    let $variable-string := 
        for $variable in $variables/xrx:variable
        let $name := $variable/xrx:name/text()
        let $expression := $variable/xrx:expression/node()
        return
        ('let ', $name, ' := ', $expression, ' ')
    return
    ('let $x___ := "" ', $variable-string)
};

declare function service:key($atomid as xs:string) {

    tokenize($atomid, '/')[last()]
};

declare function service:auth($service as element()*) {

    if(not($service)) then
        response:set-status-code(404)
    
    else
        $service/xrx:body
};

declare function service:compile($service) {

    let $serviceid := $service/xrx:id/text()
    return
    service:preprocess($service, $serviceid)
};

(: basic wrapper construction for services :)
declare function service:preprocess($service as element(xrx:service), $serviceid) as element() {

    element { 'xrx:service' } {
        
        attribute id { $serviceid },
        '{ let $x___ := "" ',
        (: are there local variables defined? :)
        service:variable-expression($service/xrx:variables),
        
        ' return ',
        
        service:parse($service/xrx:body),
        
        '}'
    }
    
};

(: function parses the service body :)
declare function service:parse($element as element()) as element() {

    element { node-name($element) } {
    
        $element/@*,
        for $child in $element/child::node()
        return
        typeswitch($child)
        
        case element(xrx:sendmail) return
        
            let $mail :=
                root($child)//xrx:emails/xrx:email[xrx:key=$child/xrx:key/text()]/mail
            return
            (
                ' mail:send-email(',
                $mail,
                ', (), "UTF-8") '
            )
            
        case element(xrx:i18n) return
        
            (
                '{ i18n:translate(',
                $child,
                ') }'
            )
            
        case element() return
            
            service:parse($child)
            
        default return $child
        
    }    
};