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

module namespace widget="http://www.monasterium.net/NS/widget";

declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace xrx="http://www.monasterium.net/NS/xrx";
declare namespace atom="http://www.w3.org/2005/Atom";

import module namespace auth="http://www.monasterium.net/NS/auth"
    at "../auth/auth.xqm";
    
declare function widget:key($atomid as xs:string) as xs:string { tokenize($atomid, '/')[last()] };
declare function widget:mainwidgetid($atomid as xs:string) as xs:string { replace($atomid, '/widget/', '/mainwidget/') };
declare function widget:embeddedwidgetid($atomid as xs:string) as xs:string { replace($atomid, '/widget/', '/embeddedwidget/') };
declare function widget:atomid($widgetkey as xs:string) as xs:string { () };

declare function widget:variable-expression($variables as element(xrx:variables)*) {

    let $variable-string := 
        for $variable in $variables/xrx:variable
        let $name := $variable/xrx:name/text()
        let $expression := $variable/xrx:expression/node()
        return
        ('let ', $name, ' := ', $expression, ' ')
    return
    ('let $x___ := "" ', $variable-string)
};

declare function widget:constructor-expression($constructor as element(xrx:constructor)*, $pass as element(xrx:pass)*) {

    let $variable-string :=
        for $parameter in $constructor/xrx:parameter
        let $name := $parameter/xrx:name/text()
        let $passed-expression := xs:string($pass/xrx:parameter[xrx:name=$name]/xrx:expression/text())
        let $default-expression := $parameter/xrx:default/text()
        let $expression := if($passed-expression != '') then $passed-expression else $default-expression
        return
        ('let ', $name, ' := ', $expression, ' ')
    return
    ('let $x___ := "" ', $variable-string, ' return ')
};

declare function widget:options-expression($options as element(xrx:options)*) as xs:string* {

    if($options) then
        concat('return {{',
            string-join(
                for $option in $options/xrx:option
                let $key := $option/@key/string()
                let $value := $option/text()
                return
                concat($key, ':', $value),
                ','
            ),
            '}}'
        )
    else''
};

declare function widget:compile-binds($binds as element(xrx:binds)*) as element()* {

    if($binds) then
        <div class="xrx-binds" style="display:none" xmlns="http://www.w3.org/1999/xhtml">
        {
            for $bind in $binds/xrx:bind
            return
            <div class="xrx-bind">
            { 
                $bind/@id,
                attribute data-xrx-nodeset { $bind/@nodeset }
            }
            </div>
        }
        </div>
    else()
};

declare function widget:compile-instances($instances as element(xrx:instances)*) as element()* {

    if($instances) then
        <div class="xrx-instances" style="display:none" xmlns="http://www.w3.org/1999/xhtml">
        {
            for $instance in $instances/xrx:instance
            return
            <div class="xrx-instance">{ $instance/@* }{ $instance/text() }</div>
        }
        </div>
    else()
};

declare function widget:compile-widget($app-name as xs:string, 
                                       $widget as element(xrx:widget), 
                                       $xrx-live-project-db-base-collection, 
                                       $project-name as xs:string, 
                                       $mode as xs:string) as element() {
   
    let $portalid := $widget/xrx:portal/text()
    let $portal := $xrx-live-project-db-base-collection//xrx:id[.=$portalid]/parent::xrx:portal
    let $widgetid := $widget/xrx:id/text()
    let $mainwidgetid := widget:mainwidgetid($widgetid)
    let $embeddedwidgetid := widget:embeddedwidgetid($widgetid)
    let $widgetkey := widget:key($widgetid)
    let $flag := $widget/xrx:init/xrx:processor/xrx:xformsflag/text()
    let $xforms-flag := 
        if(($flag = 'true' and sm:id()//sm:username/text() != 'guest') or matches($widgetkey, '(registration|request-password|iipmooviewer)')) then 
            true()
        else
            false()
    let $jqueryflag := if($widget/xrx:init/xrx:processor/xrx:jqueryflag/text() = 'true') then true() else false()
    let $javascript-debug := if($widget/xrx:jss/@debug/string() = 'true') then true() else false()
    let $variables := $widget//xrx:variable
    let $variable-expression := widget:variable-expression($widget/xrx:variables)
    return
    if($mode = 'mainwidget') then
        if($xforms-flag) then
            <html xmlns="http://www.w3.org/1999/xhtml"
                xmlns:xf="http://www.w3.org/2002/xforms"
                xmlns:bffn="java:de.betterform.xml.xforms.xpath.BetterFormXPathFunctions"
                xmlns:ev="http://www.w3.org/2001/xml-events"
                xmlns:exist="http://exist.sourceforge.net/NS/exist"
                xmlns:bf="http://betterform.sourceforge.net/xforms"
                xmlns:xrx="http://www.monasterium.net/NS/xrx"
                xmlns:bfc="http://betterform.sourceforge.net/xforms/controls"
                xmlns:ead="urn:isbn:1-931666-22-9"
                xmlns:atom="http://www.w3.org/2005/Atom"
                xmlns:i18n="http://www.monasterium.net/NS/i18n"
                xmlns:tei="http://www.tei-c.org/ns/1.0/"
                xmlns:vre="http://www.monasterium.net/NS/vre"
                xmlns:eap="http://www.monasterium.net/NS/eap"
                xmlns:eag="http://www.archivgut-online.de/eag"
                xmlns:cei="http://www.monasterium.net/NS/cei"
                xmlns:excel="http://exist-db.org/xquery/excel"
                id="{ $mainwidgetid }">
                {{
                    { $variable-expression }
                    return
                    (
                <head>
                    <title>{{ if($xrx:mainwidget/xrx:title/xrx:i18n) then i18n:translate($xrx:mainwidget/xrx:title/xrx:i18n) else() }}{{ if($xrx:htdoc//xrx:i18n) then i18n:translate($xrx:htdoc//xrx:i18n) else() }}&#160;{{ string-join(subsequence($xrx:tokenized-uri, 1, count($xrx:tokenized-uri) - 1), '|') }}&#160;-&#160;{{ conf:param("platform-browser-title") }}</title>
                    { 
                        if($jqueryflag) then 
                            <link rel="stylesheet" href="/{ $project-name }/jquery/themes/base/jquery.ui.all.css"/>
                        else () 
                    } 
                    <link rel="stylesheet" type="text/css" href="/{ $project-name }/css/?atomid={ $widgetid }"/>
                    { 
                        if(not($javascript-debug)) then
                            if($widget/xrx:jss/xrx:resource or $jqueryflag) then 
                                (
                                <script type="text/javascript" src="/{ $project-name }/javascript/?atomid={ $widgetid }"/>,
                                $widget/xrx:jss/xhtml:script,
                                $portal/xrx:jss/xhtml:script
                                )
                            else() 
                        else
                            for $resource in $widget/xrx:jss/xrx:resource
                            let $id := $resource/text()
                            return
                            (
                            <script type="text/javascript" src="/{ $project-name }/resource/?atomid={ $id }"/>,
                            $widget/xrx:jss/xhtml:script,
                            $portal/xrx:jss/xhtml:script
                            )
                    }
		<meta http-equiv="X-UA-Compatible" content="IE=9,chrome=1" /> 
                </head>,
                <body data-xrx-widget="{ $portalid }">
                    {{
                        if(auth:matches(<xrx:rule xmlns:xrx="http://www.monasterium.net/NS/xrx"><xrx:user/><xrx:role>translator</xrx:role></xrx:rule>)) then
                        <div class="xrx-translate-page-link">
                          <a href="/{ $project-name }/translate?id={ $widgetid }">‣&#160;{{ i18n:translate(<xrx:i18n><xrx:key>translate-page</xrx:key><xrx:default>Translate page</xrx:default></xrx:i18n>) }}</a>
                        </div>
                        else()
                    }}
                    { if($portal) then widget:preprocess($portal, $widget, $xrx-live-project-db-base-collection) else() }
                    <div class="xrx-data-messages" style="display:none">{{ i18n:as-json(xrx:messages($xrx:mainwidget)) }}</div>
                </body>
                    )
                }}
            </html>
        else
            <html xmlns="http://www.w3.org/1999/xhtml" 
                id="{ $mainwidgetid }">
            {{
                { $variable-expression }
                return
                (
                <head>
                    <title>{{ if($xrx:mainwidget/xrx:title/xrx:i18n) then i18n:translate($xrx:mainwidget/xrx:title/xrx:i18n) else() }}{{ if($xrx:htdoc//xrx:i18n) then i18n:translate($xrx:htdoc//xrx:i18n) else() }}&#160;{{ string-join(subsequence($xrx:tokenized-uri, 1, count($xrx:tokenized-uri) - 1), '|') }}&#160;-&#160;{{ conf:param("platform-browser-title") }}</title>
                    { 
                        if($jqueryflag) then
                            <link rel="stylesheet" href="/{ $project-name }/jquery/themes/base/jquery.ui.all.css"/>
                        else () 
                    }          
                    <link rel="stylesheet" type="text/css" href="/{ $project-name }/css/?atomid={ $widgetid }"/>
                    { 
                        if(not($javascript-debug)) then
                            if($widget/xrx:jss/xrx:resource or $jqueryflag) then 
                                (
                                <script type="text/javascript" src="/{ $project-name }/javascript/?atomid={ $widgetid }"/> ,
                                $widget/xrx:jss/xhtml:script,
                                $portal/xrx:jss/xhtml:script
                                )
                            else() 
                        else
                            for $resource in $widget/xrx:jss/xrx:resource
                            let $id := $resource/text()
                            return
                            (
                            <script type="text/javascript" src="/{ $project-name }/resource/?atomid={ $id }"/>,
                            $widget/xrx:jss/xhtml:script,
                            $portal/xrx:jss/xhtml:script
                            )
                    }
		<meta http-equiv="X-UA-Compatible" content="IE=9,chrome=1" /> 
                </head>,
                <body data-xrx-widget="{ $portalid }">
                    {{
                        if(auth:matches(<xrx:rule xmlns:xrx="http://www.monasterium.net/NS/xrx"><xrx:user/><xrx:role>translator</xrx:role></xrx:rule>)) then
                        <div class="xrx-translate-page-link">
                          <a href="/{ $project-name }/translate?id={ $widgetid }">‣&#160;{{ i18n:translate(<xrx:i18n><xrx:key>translate-page</xrx:key><xrx:default>Translate page</xrx:default></xrx:i18n>) }}</a>
                        </div>
                        else()
                    }}
                    { if($portal) then widget:preprocess($portal, $widget, $xrx-live-project-db-base-collection) else() }
                    <div class="xrx-data-messages" style="display:none">{{ i18n:as-json(xrx:messages($xrx:mainwidget)) }}</div>
                </body>
                )
            }}
            </html>
    else
        <div xmlns="http://www.w3.org/1999/xhtml" id="{ $embeddedwidgetid }">{ if($portal) then widget:preprocess($portal, $widget, $xrx-live-project-db-base-collection) else() }</div>
};

(:
    function for recursive call
    ( we ignore the xrx:view element )
:)
declare function widget:preprocess($super-widget as element(), $mainwidget as element()*, $base-collection) {

    (widget:parse($super-widget/xrx:view, $mainwidget, $base-collection))/child::node()
};

(:
    widget parser
:)
declare function widget:parse($element as element(), $main-widget as element()*, $base-collection) {
    
    if($element) then
    element { node-name($element) }  {
    
        $element/@*,
        if($element/self::xrx:view) then 
        (
            widget:compile-binds($element/parent::xrx:widget/xrx:binds),
            widget:compile-instances($element/parent::xrx:widget/xrx:instances)
        )
        else(),
        for $child in $element/child::node()
        return
        typeswitch($child)
            
        case element(xrx:subwidget) return
        
            let $subwidgetid := if($child/xrx:atomid) then $child/xrx:atomid/text() else $child/text()
            let $widgetkey := widget:key($subwidgetid)
            let $subwidget := $base-collection//xrx:id[.=$subwidgetid]/parent::xrx:widget
            let $subwidget-constructor := $subwidget/xrx:constructor
            let $passed := $child/xrx:pass
            return
            if($subwidget) then 
            <div xmlns="http://www.w3.org/1999/xhtml" class="xrx-subwidget">
            {(
                <div style="display:none">{ $subwidget/xrx:model/node() }</div>,
                '{ ',
                widget:constructor-expression($subwidget-constructor, $passed),
                widget:variable-expression($subwidget/xrx:variables),
                ' return ',
                <div class="xrx-widget" xmlns="http://www.w3.org/1999/xhtml" data-xrx-widget="{ $subwidgetid }">{ widget:preprocess($subwidget, $main-widget, $base-collection) }</div>,
                '}'
            )}
            </div>
            else()
        
        case element(xrx:mainwidget) return
        
            if($main-widget) then 
            (
                <div style="display:none" xmlns="http://www.w3.org/1999/xhtml">{ $main-widget/xrx:model/node() }</div>,
                <div class="xrx-widget" xmlns="http://www.w3.org/1999/xhtml" data-xrx-widget="{ $main-widget/xrx:id/text() }">{ widget:preprocess($main-widget, <span xmlns="http://www.w3.org/1999/xhtml"/>, $base-collection) }</div>
            )
            else()
        
        case element(xrx:i18n) return
        
            (
                '{ i18n:translate(',
                $child,
                ') }'
            )
        
        case element(xrx:auth) return
            
            (
                '{ if(',
                auth:preprocess($child),
                ') then ',
                widget:parse($child/xrx:true/*, $main-widget, $base-collection),
                ' else',
                widget:parse($child/xrx:false/*, $main-widget, $base-collection),
                '}'
            )
        
        case element(xrx:elements) return
        
            <div class="xrx-elements" xmlns="http://www.w3.org/1999/xhtml"/> 
        
        case element(xrx:attributes) return
        
            <div class="xrx-attributes" xmlns="http://www.w3.org/1999/xhtml"/> 
                    
        case element(xrx:resource) return
        
            if(starts-with($child/@type, 'image')) then
            
                let $atomid := $child/text()
                let $resource := $base-collection//xrx:resource[xrx:atomid=$atomid]
                let $relative-path := $resource/xrx:relativepath/text()
                let $name := $resource/xrx:name/text()
                let $uri := concat(util:collection-name($resource), '/', $relative-path, $name)
                let $binary := if(util:binary-doc-available($uri)) then util:binary-doc($uri) else ()  
                return
                <img src="{ concat('data:', $child/@type/string(), ';base64,', $binary) }" xmlns="http://www.w3.org/1999/xhtml">{ $child/@*[name(.) != 'type'] }</img>
            
            else()
        
        case element(xrx:div) return
        
            let $key := $child/text()
            let $div := root($child)//xrx:divs/xrx:div[xrx:key=$key]
            return
            if($div/xrx:view) then widget:preprocess($div, (), $base-collection) else()

                
        case element(xrx:layout) return
        
            let $options := $child/xrx:options
            return
            <div class="xrx-layout" xmlns="http://www.w3.org/1999/xhtml">
            {
                $child/@*,
                attribute { 'onclick' } { widget:options-expression($options) },
                for $e in $child/*
                return
                typeswitch($e)
                case element(xrx:options) return ()
                case element(xrx:center) return widget:parse(<div class="ui-layout-center">{ $e/* }</div>, $main-widget, $base-collection)
                case element(xrx:north) return widget:parse(<div class="ui-layout-north">{ $e/* }</div>, $main-widget, $base-collection)
                case element(xrx:east) return widget:parse(<div class="ui-layout-east">{ $e/* }</div>, $main-widget, $base-collection)
                case element(xrx:south) return widget:parse(<div class="ui-layout-south">{ $e/* }</div>, $main-widget, $base-collection)
                case element(xrx:west) return widget:parse(<div class="ui-layout-west">{ $e/* }</div>, $main-widget, $base-collection)
                default return widget:parse($e, $main-widget, $base-collection)  
            }
            </div>
            
        case element(xrx:repeat) return
        
            widget:parse(
                <div class="xrx-repeat" xmlns="http://www.w3.org/1999/xhtml" data-xrx-bind="{ $child/@bind/string() }">{ $child/* }</div>,
                $main-widget,
                $base-collection
            )  
        case element(xrx:select) return
       
            widget:parse(
            
                <div class="xrx-select" xmlns="http://www.w3.org/1999/xhtml" data-xrx-bind="{ $child/@bind/string() }">{ $child/* }</div>,
                $main-widget,
                $base-collection
            )  
                  
        case element(xrx:select1) return
        
            <div class="xrx-select1" xmlns="http://www.w3.org/1999/xhtml">
            {
                attribute id { $child/@id },
                attribute data-xrx-appearance { $child/@appearance },
                for $item at $num in $child/xrx:item
                let $select1-id := $child/@id/string()
                let $value := $item/xrx:value/text()
                let $input-id := concat('xrx-id-', $select1-id, $num)
                return
                (
                    <input type="radio" id="{ $input-id }" name="radio" value="{ $value }">
                    { if($num = 1) then attribute { 'checked' } { 'checked' } else () }
                    </input>,
                    widget:parse(<label for="{ $input-id }">{ $item/xrx:label/node() }</label>, $main-widget, $base-collection)
                )
            }
            </div>
        
        case element(xrx:switch) return
        
            <div class="xrx-switch" xmlns="http://www.w3.org/1999/xhtml">
            {
                $child/@*,
                for $e at $pos in $child/*
                return
                typeswitch($e)
                case element(xrx:case) return 
                
                    widget:parse(
                        <div class="xrx-case" xmlns="http://www.w3.org/1999/xhtml">{ if($pos > 1) then attribute style { 'display:none' } else () }{ $e/@* }{ $e/* }</div>, 
                        $main-widget, 
                        $base-collection
                    )
                default return widget:parse($e, $main-widget, $base-collection) 
            }
            </div>
        
        case element(xrx:tagname) return
        
            <span class="xrx-tagname" xmlns="http://www.w3.org/1999/xhtml"/> 
                    
        
        case element(xrx:visualxml) return
        
            <textarea class="xrx-visualxml" xmlns="http://www.w3.org/1999/xhtml">
                { if(exists($child/@attributes)) then attribute data-xrx-attributes { $child/@attributes/string() } else() }
                { if(exists($child/@elements)) then attribute data-xrx-elements { $child/@elements/string() } else() }
                { 
                if(exists($child/@bind)) then 
                    attribute data-xrx-bind { $child/@bind/string() } 
                else if(exists($child/@ref)) then
                    attribute data-xrx-ref { $child/@ref/string() }
                else()
                }
            </textarea>
            
        case element() return
            
            widget:parse($child, $main-widget, $base-collection)
                    
        default return $child 
    }
    else()
};
