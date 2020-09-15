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

(: TODO
- check for uniqueness of XRX Objects
- check for ID constructions
- check for missing app files in projects' subcollections
- check if app files exist in invalid collections
- inherit by type extend, test it with inheritance:modules
- interface concept, test it with app conf
- dynamically load css and js for embedded widgets
:)

declare namespace compiler="http://www.monasterium.net/NS/compiler";
declare namespace xrx="http://www.monasterium.net/NS/xrx";

import module namespace app="http://www.monasterium.net/NS/app"
    at "../xrx/app.xqm";
import module namespace xsd="http://www.monasterium.net/NS/xsd"
    at "../xrx/xsd.xqm";
import module namespace inheritance="http://www.monasterium.net/NS/inheritance"
    at "../xrx/inheritance.xqm";
import module namespace widget="http://www.monasterium.net/NS/widget"
    at "../xrx/widget.xqm";
import module namespace css="http://www.monasterium.net/NS/css"
    at "../xrx/css.xqm";
import module namespace javascript="http://www.monasterium.net/NS/javascript"
    at "../xrx/javascript.xqm";
import module namespace service="http://www.monasterium.net/NS/service"
    at "../xrx/service.xqm";

declare variable $TARGET as xs:string external;    
declare variable $PROJECT_NAME as xs:string external;
declare variable $APP_NAME as xs:string external;

(: XRX base collections :)
declare variable $xrx-src-db-base-collection-path := '/db/XRX.src';
declare variable $xrx-live-db-base-collection-path := '/db/XRX.live';
declare variable $xrx-resources-db-base-collection-path := '/db/XRX.res';
declare variable $xrx-src-db-base-collection := collection($xrx-src-db-base-collection-path);
declare variable $xrx-resources-db-base-collection := collection($xrx-resources-db-base-collection-path);

(: XRX++ project collections :)
declare variable $xrx-src-project-db-base-collection-path := 
    concat($xrx-src-db-base-collection-path, '/', $PROJECT_NAME);
declare variable $xrx-src-core-db-base-collection-path := 
    concat($xrx-src-db-base-collection-path, '/core');
declare variable $xrx-src-project-db-base-collection := 
    collection($xrx-src-project-db-base-collection-path);
declare variable $xrx-live-project-db-base-collection-path := 
    concat($xrx-live-db-base-collection-path, '/', $PROJECT_NAME);

(: XRX++ target :)
declare variable $compiler:target-src-collection-path := compiler:target-collection-path($xrx-src-db-base-collection-path);
declare variable $compiler:target-src-collection := collection($compiler:target-src-collection-path);
declare variable $compiler:target-live-collection-path := compiler:target-collection-path($xrx-live-db-base-collection-path);

(: XRX++ Objects :)
declare variable $compiler:object-types := ('app', 'css', 'portal', 'service', 'template', 'widget', 'xsd');
declare variable $compiler:src-objects := $xrx-src-db-base-collection/(xrx:app|xrx:css|xrx:portal|xrx:service|xrx:template|xrx:widget|xrx:xsd);

(: XRX++ Schema :)
declare variable $xrx-schema := $xrx-src-db-base-collection/xs:schema[@id='xrx'];
declare variable $xrx-object-child-elements := 
    map(
        for $object-type in $compiler:object-types
        return
        map:entry($object-type, xsd:child-element-names($object-type, $object-type, $xrx-schema))
    );

(: XRX++ compiler errors :)
declare variable $xrx-compiler-error := 
    map {
        "ERR1"  : "Object '{1}' inherits object '{2}' but '{2}' does not exist.",
        "ERR2"  : "Invalid resource name '{1}'. Expected name is '{2}'.",
        "ERR3"  : "Unknown target '{1}'",
        "ERR4"  : "Widget or Service '{1}' is mapped by App '{2}' but Widget or Service '{1}' does not exist in App '{2}'",
        "ERR5"  : "No Mapping found for Service '{1}' in App '{2}' but a Mapper is required for each Service."
    };

(: compile XRX++ controller :)
declare function compiler:compile-controller($null) {
    
    let $step := "Compile XRX++ controller"
    let $project-controller-files := xmldb:get-child-resources($xrx-src-project-db-base-collection-path)
    let $copy-project-files :=
        for $file in $project-controller-files
        return
        compiler:copy($xrx-src-project-db-base-collection-path, $xrx-live-project-db-base-collection-path, $file)
    let $core-controller-files := xmldb:get-child-resources($xrx-src-core-db-base-collection-path)
    let $copy-core-files :=
        for $file in $core-controller-files
        return
        compiler:copy($xrx-src-core-db-base-collection-path, $xrx-live-project-db-base-collection-path, $file)
    let $controller-as-string := util:binary-to-string(util:binary-doc(concat($xrx-src-core-db-base-collection-path, '/controller.xql')))
    let $patch-controller := replace($controller-as-string, '#XRX_PROJECT_NAME', $PROJECT_NAME)
    let $store-controller := compiler:store($xrx-live-project-db-base-collection-path, 'controller.xql', $patch-controller)
    let $src-resource-collection := concat($xrx-src-project-db-base-collection-path, '/res')
    let $copy-resource-collection := 
        if(xmldb:collection-available($src-resource-collection)) then xmldb:copy($src-resource-collection, $xrx-live-project-db-base-collection-path) else()
    return
    compiler:report($step, 'SUCCESSFUL')
};

(: inherited XRX++ objects :)
declare function compiler:inherited-objects($xrx-objects as element()*) as element()* {

    let $xrx-object := $xrx-objects[1]
    let $inheritsid := $xrx-object/xrx:inherits/text()
    let $id := $xrx-object/xrx:id/text()
    let $inherited-object := $xrx-src-db-base-collection//xrx:id[.=$inheritsid]/parent::element()
    return
    if(exists($xrx-objects[1]/xrx:inherits) and count($inherited-object) = 0) then
        compiler:error($xrx-object, "ERR1", ($id, $inheritsid))
    else if(exists($xrx-objects[1]/xrx:inherits) and exists($inherited-object)) then
        compiler:inherited-objects(($inherited-object, $xrx-objects))
    else 
        $xrx-objects
};

(: inherit XRX++ object :)
declare function compiler:inherit($xrx-object as element()) as element()* {

    let $objects := compiler:inherited-objects($xrx-object)
    let $object-type := local-name($xrx-object)
    let $secondlevel-element-names := $xrx-object-child-elements($object-type)
    let $second-level-elements := 
        for $element-name in $secondlevel-element-names
        let $qname := concat('xrx:', $element-name)
        let $parts := 
            for $object in $objects
            let $part := $object/*[name(.) = $qname]
            return
            $part
        return
        switch($element-name)
        case('modules') return inheritance:modules($parts)
        case('resources') return inheritance:resources($parts)
        default return $parts[count($parts)]
    return
    if(exists($objects/self::xrx:error)) then $objects/self::xrx:error
    else element { name($xrx-object) }{ $second-level-elements }
};

(: implement XRX++ object :)
declare function compiler:implement($xrx-object as element()) as element()* {

    let $implementedid := $xrx-object/xrx:implements/text()
    let $implemented-object := compiler:inherit($xrx-src-db-base-collection//xrx:id[.=$implementedid]/parent::element())
    let $second-level-elements := $implemented-object/*[local-name(.) != 'id']
    return
    element { name($xrx-object) }{ (<xrx:id>{ $implementedid }</xrx:id>, $second-level-elements) }
};

(: inherit XRX++ objects :)
declare function compiler:inherit-objects($appkey as xs:string, $object-type as xs:string) {

    let $step := concat('Inherit XRX++ ', $object-type, 's')
    let $app := compiler:target-src-collection($appkey)/xrx:app
    let $target-src-collection := 
        if($app/xrx:implements) then
            let $implementid := $app/xrx:implements/text()
            let $app := $xrx-src-db-base-collection//xrx:id[.=$implementid]/parent::xrx:app
            return
            collection(util:collection-name($app))
        else 
            compiler:target-src-collection($appkey)
    let $objects :=
        switch($object-type)
        case('app') return $target-src-collection/xrx:app
        case('css') return $target-src-collection/xrx:css
        case('portal') return $target-src-collection/xrx:portal
        case('service') return $target-src-collection/xrx:service
        case('template') return $target-src-collection/xrx:template
        case('widget') return $target-src-collection/xrx:widget
        case('xsd') return $target-src-collection/xrx:xsd
        default return ()
    let $compile-objects := 
        for $object in $objects
        let $src-resource-name := util:document-name($object)
        let $src-collection-name := util:collection-name($object)
        let $live-collection-name := compiler:_xrx-live-app-db-base-collection-path($src-collection-name)
        let $prepare-collection := compiler:prepare-collection($live-collection-name)
        let $compiled-object := 
            if($object/xrx:implements) then compiler:implement($object) else compiler:inherit($object)
        let $store := if(exists($compiled-object)) then compiler:store($live-collection-name, $src-resource-name, $compiled-object) else ()
        return
        if(exists($compiled-object/self::xrx:error)) then $compiled-object/self::xrx:error
        else ()
    return
    if(count($compile-objects) = 0) then compiler:report($step, 'SUCCESSFUL')
    else compiler:report($step, $compile-objects)
};

(: compile XRX++ modules :)
declare function compiler:compile-modules($appkey as xs:string) {

    let $step := "Compile XRX++ modules"
    let $live-modules := compiler:target-live-collection($appkey)//xrx:module
    let $compile-modules :=
        for $module in $live-modules
        let $resource-name := $module/xrx:resource/text()
        let $uri := $module/xrx:resource/@origin/string()
        let $live-module-uri := compiler:_xrx-live-app-db-base-collection-path($uri)
        let $copy := compiler:copy($uri, $live-module-uri, $resource-name)
        return
        ()
    return
    compiler:report($step, 'SUCCESSFUL')
};

(: compile XRX++ resources :)
declare function compiler:compile-resources($appkey as xs:string) {
    
    let $step := "Compile XRX++ resources"
    let $live-resources := compiler:target-live-collection($appkey)//xrx:resources/xrx:resource
    let $compile-resources := 
        for $resource in $live-resources
        let $name := $resource/xrx:name/text()
        let $uri := $resource/xrx:name/@origin/string()
        let $relative-path := $resource/xrx:relativepath/text()
        let $live-resource-uri := compiler:_xrx-live-app-db-base-collection-path($uri)
        let $prepare-collection := compiler:prepare-collection($live-resource-uri)
        let $copy := compiler:copy($uri, $live-resource-uri, $name)
        return
        ()
    return
    compiler:report($step, 'SUCCESSFUL')
};

(: compile XRX++ widgets :)
declare function compiler:test-widget-resolver-mapping($app as element(xrx:app), $mapped-ids as xs:string*, $widget-ids as xs:string*) {

    let $appid := $app/xrx:id/text()
    for $mapped-id in $mapped-ids
    return
    if($mapped-id = $widget-ids) then ()
    else compiler:error($app, 'ERR4', ($mapped-id, $appid))
};

declare function compiler:compile-mainwidgets($appkey as xs:string) {
    
    let $step := "Compiling XRX++ widgets"
    let $xrx-live-project-db-base-collection := collection($xrx-live-project-db-base-collection-path)
    let $xrx-resources-base-collection := ($xrx-live-project-db-base-collection, $xrx-resources-db-base-collection)
    let $app := compiler:target-live-collection($appkey)/xrx:app
    let $compile-appwise := 
        let $appid := $app/xrx:id/text()
        let $app-name := tokenize($appid, '/')[last()]
        let $mainwidget-mappings := $app/xrx:resolver/xrx:map[matches(xrx:mode, '(mainwidget|embeddedwidget)')]
        let $mapped-mainwidget-ids := $mainwidget-mappings/xrx:atomid/text()
        let $app-base-collection := collection(util:collection-name($app))
        let $widgets := $app-base-collection//xrx:id[.=$mapped-mainwidget-ids]/parent::xrx:widget
        let $widget-ids := $widgets/xrx:id/text()
        let $test-resolver-mapping := compiler:test-widget-resolver-mapping($app, $mapped-mainwidget-ids, $widget-ids)
        let $compile-widgets :=
            if(count($test-resolver-mapping) = 0) then
                for $widget in $widgets
                let $base-collection := util:collection-name($widget)
                let $widgetid := $widget/xrx:id/text()
                let $widget-key := widget:key($widgetid)
                let $mode := ($mainwidget-mappings[xrx:atomid=xs:string($widgetid)]/xrx:mode/text())[1]
                (: compile and store widget :)
                let $compiled-widget := widget:compile-widget($app-name, $widget, $xrx-live-project-db-base-collection, $PROJECT_NAME, $mode)
                let $mainwidget-resource-name := concat($widget-key, '.', $mode, '.xml')
                let $store-mainwidget := compiler:store($base-collection, $mainwidget-resource-name, $compiled-widget)
                (: get widgetlist :)
                let $idlist := $compiled-widget//@data-xrx-widget/string()
                let $widgetlist := $xrx-live-project-db-base-collection//xrx:id[.=$idlist]/parent::xrx:*
                (: compile and store CSS :)
                let $csss := $widgetlist//xrx:csss
                let $compiled-css := css:compile($widget, $csss, $xrx-live-project-db-base-collection, $xrx-resources-base-collection)
                let $css-resource-name := concat($widget-key, '.', $mode, '.css.xml')
                let $store-css := compiler:store($base-collection, $css-resource-name, $compiled-css)
                (: compile and store Javascript 
                sämtliche xrx:jss auch aus subwidgets in eines zusammengefasst, 
                damit sie in javascript compile funktion leichter zu ordnen sind :)
                let $jss := <xrx:jss>{$widgetlist//xrx:jss/xrx:resource}</xrx:jss>              
                let $compiled-javascript := javascript:compile($widget, $jss, $xrx-live-project-db-base-collection, $xrx-resources-base-collection, $PROJECT_NAME)
                let $javascript-resource-name := concat($widget-key, '.', $mode, '.javascript.xml')
                let $store-javascript := if($compiled-javascript != '') then compiler:store($base-collection, $javascript-resource-name, $compiled-javascript) else()
                return
                ()
            else()
        return
        $test-resolver-mapping
    return
    if(count($compile-appwise) = 0) then compiler:report($step, 'SUCCESSFUL')
    else compiler:report($step, $compile-appwise)
};

declare function compiler:compile-embeddedwidgets($appkey as xs:string) {

    ()
    (:
    let $step := "Compiling XRX++ embedded Widgets"
    return
    compiler:report($step, "SUCCESSFUL")
    :)
};

(: compile XRX++ services :)
declare function compiler:test-service-resolver-mapping($app as element(xrx:app), $mapped-ids as xs:string*, $service-ids as xs:string*) {

    let $appid := $app/xrx:id/text()
    return
    (
        for $mapped-id in $mapped-ids
        return
        if($mapped-id = $service-ids) then ()
        else compiler:error($app, 'ERR4', ($mapped-id, $appid))
        ,
        for $service-id in $service-ids
        return
        if($service-id = $mapped-ids) then ()
        else compiler:error($app, 'ERR5', ($service-id, $appid))        
    )
};

declare function compiler:compile-services($appkey as xs:string) {

    let $step := "Compiling XRX++ services"
    let $xrx-live-project-db-base-collection := collection($xrx-live-project-db-base-collection-path)
    let $apps := compiler:target-live-collection($appkey)/xrx:app
    let $compile-appwise := 
        for $app in $apps
        let $app-base-collection := collection(util:collection-name($app))
        let $services := $app-base-collection/xrx:service
        let $service-ids := $services/xrx:id/text()
        let $service-mappings := $app/xrx:resolver/xrx:map[xrx:mode='service']
        let $mapped-service-ids := $service-mappings/xrx:atomid/text()
        let $test-resolver-mapping := compiler:test-service-resolver-mapping($app, $mapped-service-ids, $service-ids)
        let $compile-services :=
            if(count($test-resolver-mapping) = 0) then
                for $service in $services
                let $base-collection := util:collection-name($service)
                let $service-key := service:key($service/xrx:id/text())
                (: compile and store service :)
                let $compiled-service := service:compile($service)
                let $service-resource-name := concat($service-key, '.service.compiled.xml')
                let $store-service := compiler:store($base-collection, $service-resource-name, $compiled-service)
                return()        
            else()
        return
        $test-resolver-mapping
    return
    if(count($compile-appwise) = 0) then compiler:report($step, 'SUCCESSFUL')
    else compiler:report($step, $compile-appwise)
};

declare function compiler:compile-main($null) {

    let $step := "Compiling XRX++ main"
    let $project-live-collection := collection($xrx-live-project-db-base-collection-path)
    (: modules :)
    let $modules := $project-live-collection//xrx:module
    let $main-resource := $project-live-collection//xrx:resource[xrx:atomid='tag:www.monasterium.net,2011:/core/resource/xquery/main']
    let $path := concat($main-resource/xrx:name/@origin/string(), '/', $main-resource/xrx:name/text())
    let $binary-doc := util:binary-doc($path)
    let $xquery-string := util:binary-to-string($binary-doc)
    let $import-statements := 
        for $module in $modules
        let $uri := $module/xrx:uri/text()
        let $prefix := $module/xrx:prefix/text()
        let $resource := $module/xrx:resource/text()
        let $app := $module/ancestor::xrx:app
        let $appid := $app/xrx:id/text()
        let $app-name := tokenize($appid, '/')[last()]
        return
        concat(
            'import module namespace ',
            $prefix,
            '="',
            $uri,
            '" at "../',
            $app-name,
            '/',
            $resource,
            '"; '
        )
    (: objects :)
    let $declare-statements := 
        distinct-values(
            for $object in $compiler:src-objects
            let $id := $object/xrx:id/text()
            let $first-char := substring($object/self::element()/local-name(), 1, 1)
            let $key := tokenize($id, '/')[last()]
            let $prefix := concat($first-char, $key)
            return
            concat(
                'declare namespace ',
                $prefix,
                '="http://www.monasterium.net/NS/',
                $prefix,
                '"; '
            )
        )
    let $patch-imports := replace($xquery-string, '#IMPORT_XRX_MODULES', string-join($import-statements, ''))
    let $patch-declares := replace($patch-imports, '#DECLARE_XRX_NAMESPACES', string-join($declare-statements, ''))
    let $base-collection := util:collection-name($main-resource)
    let $store-main := xmldb:store($base-collection, 'main.xql', $patch-declares)
    return
    compiler:report($step, 'SUCCESSFUL')
};

(: validate XRX++ source :)
declare function compiler:validate-src($appkey as xs:string) as element()* {

    let $compiler-step := "Validate XRX++ source"

    let $validate-resource-names :=
        for $object in compiler:src-objects($appkey)
        let $id := $object/xrx:id/text()
        let $key := tokenize($id, '/')[last()]
        let $type := local-name($object)
        let $expected-name := string-join(($key, $type, 'xml'), '.')
        let $resource-name := util:document-name($object)
        let $validate := validation:jaxv-report($object, $xrx-schema, 'http://www.w3.org/XML/XMLSchema/v1.1')
        let $validate-report := 
            if($validate//status/text() = 'invalid') then
                <error xmlns="http://www.monasterium.net/NS/xrx">
                  <object>{ $object/xrx:id/text() }</object>
                  <path>{ util:collection-name($object) }/{ util:document-name($object) }</path>
                  { $validate }
                </error>
            else()
        return
        if(exists($validate-report)) then $validate-report
        else if($expected-name = $resource-name) then ()
        else compiler:error($object, 'ERR2', ($resource-name, $expected-name))
    return
    if(count($validate-resource-names) = 0) then compiler:report($compiler-step, 'SUCCESSFUL')
    else compiler:report($compiler-step, $validate-resource-names)
};

(: XRX++ compiler main functions :)
declare function compiler:proceed($functions, $pos as xs:integer, $appkey) {

    let $execute := $functions[$pos]($appkey)
    return
    if($execute//xrx:error) then $execute
    else if(count($functions) = $pos) then $execute
    else ($execute, compiler:proceed($functions, $pos + 1, $appkey))
};

declare function compiler:inherit-apps($appkey as xs:string) { compiler:inherit-objects($appkey, 'app') };
declare function compiler:inherit-csss($appkey as xs:string) { compiler:inherit-objects($appkey, 'css') };
declare function compiler:inherit-portals($appkey as xs:string) { compiler:inherit-objects($appkey, 'portal') };
declare function compiler:inherit-templates($appkey as xs:string) { compiler:inherit-objects($appkey, 'template') };
declare function compiler:inherit-services($appkey as xs:string) { compiler:inherit-objects($appkey, 'service') };
declare function compiler:inherit-widgets($appkey as xs:string) { compiler:inherit-objects($appkey, 'widget') };
declare function compiler:inherit-xsds($appkey as xs:string) { compiler:inherit-objects($appkey, 'xsd') };

declare function compiler:compile() {

    let $compiler-step := "Initialize Compiler"
    
    (: functions :)
    let $validate-functions := (
        compiler:validate-src#1
    )

    let $project-functions1 := (
        compiler:prepare-project-collection#1,
        compiler:compile-controller#1
    )
    
    let $inherit-functions := (
        compiler:prepare-app-collection#1,
        compiler:inherit-apps#1,
        compiler:compile-modules#1,
        compiler:compile-resources#1,
        compiler:inherit-csss#1,
        compiler:inherit-portals#1,
        compiler:inherit-templates#1,
        compiler:inherit-services#1,
        compiler:inherit-widgets#1,
        compiler:inherit-xsds#1
    )
    
    let $compile-functions := (
        compiler:compile-mainwidgets#1,
        compiler:compile-embeddedwidgets#1,
        compiler:compile-services#1
    )

    let $project-functions2 := (
        compiler:compile-main#1
    )

    let $compile := 
    
        switch($TARGET)
        
        case('compile-xrx-project') return 
            
            let $proceed1 := compiler:proceed($project-functions1, 1, '')
            let $appkeys := xmldb:get-child-collections(concat($xrx-src-project-db-base-collection-path, '/app'))
            let $inherit := 
                for $appkey in $appkeys
                return
                <xrx:app>
                    <xrx:key>{ $appkey }</xrx:key>
                    { if($proceed1[.//xrx:error]) then() else compiler:proceed(($validate-functions, $inherit-functions), 1, $appkey) }
                </xrx:app>
            let $comp :=
                for $appkey in $appkeys
                return
                <xrx:app>
                    <xrx:key>{ $appkey }</xrx:key>
                    { if($inherit[.//xrx:error]) then() else compiler:proceed($compile-functions, 1, $appkey) }
                </xrx:app>
            let $proceed2 := if($comp[.//xrx:error]) then() else compiler:proceed($project-functions2, 1, '')
            return
            ($proceed1[.//xrx:error], $inherit[.//xrx:error], $comp[.//xrx:error], $proceed2[.//xrx:error], 'Build successful')[1]
            
        case('compile-xrx-app') return 
        
            let $appkeys := tokenize($APP_NAME, ',')
            let $proceed :=
                for $appkey in $appkeys
                return
                <xrx:app>
                    <xrx:key>{ $appkey }</xrx:key>
                    { compiler:proceed(($validate-functions, $inherit-functions, $compile-functions, $project-functions2), 1, $appkey) }
                </xrx:app>
            return
            ($proceed[.//xrx:error], 'Build successful')[1]
        
        default return compiler:error((), 'ERR3', $TARGET)
        
    return
    <compiler xmlns="http://www.monasterium.net/NS/xrx">
      { $compile }
    </compiler>
};

(: shared utility functions :)
declare function compiler:src-objects($appkey as xs:string) as element()* {

    compiler:target-src-collection($appkey)/(xrx:app|xrx:css|xrx:portal|xrx:service|xrx:template|xrx:widget|xrx:xsd)
};

declare function compiler:target-src-collection($appkey as xs:string) {

    collection(concat($xrx-src-project-db-base-collection-path, '/app/', $appkey))
};

declare function compiler:target-live-collection($appkey as xs:string) {

    collection(compiler:target-live-collection-path($appkey))
};

declare function compiler:target-live-collection-path($appkey as xs:string) {

    concat($xrx-live-project-db-base-collection-path, '/app/', $appkey)
};

declare function compiler:prepare-app-collection($appkey as xs:string) {

    let $target-live-collection-path := compiler:target-live-collection-path($appkey)
    let $remove := if(xmldb:collection-available($target-live-collection-path)) then xmldb:remove($target-live-collection-path) else()
    let $wait := util:wait(100)
    let $prepare := compiler:prepare-collection($target-live-collection-path)
    return 
    $prepare
};

declare function compiler:prepare-project-collection($null) {

    let $target-live-collection-path := compiler:target-live-collection-path($PROJECT_NAME)
    let $remove := if(xmldb:collection-available($target-live-collection-path)) then xmldb:remove($target-live-collection-path) else()
    let $wait := util:wait(100)
    let $prepare := compiler:prepare-collection($target-live-collection-path)
    return 
    $prepare
};

declare function compiler:report($step as xs:string, $report) {

    <report xmlns="http://www.monasterium.net/NS/xrx" step="{ $step }">{ $report }</report>
};

declare function compiler:error($object as element()*, $message-key as xs:string, $message-params as xs:string*) as element() {
    
    <error xmlns="http://www.monasterium.net/NS/xrx">
        { if($object) then <object>{ $object/xrx:id/text() }</object> else() }
        { if($object) then <path>{ util:collection-name($object) }/{ util:document-name($object) }</path> else() }
        <message>{ compiler:message($message-key, $message-params) }</message>
    </error>
};

declare function compiler:_message($message as xs:string, $message-params as xs:string*, $pos as xs:integer) {

    let $pattern := concat('\{', xs:string($pos), '\}')
    let $replace := if($message-params[$pos]) then replace($message, $pattern, $message-params[$pos]) else $message
    return
    if(count($message-params) = $pos - 1) then $replace
    else compiler:_message($replace, $message-params, $pos + 1)
};

declare function compiler:message($message-key as xs:string, $message-params as xs:string*) {

    let $message := $xrx-compiler-error($message-key)
    return
    compiler:_message($message, $message-params, 1)
};

declare function compiler:store($collection-uri as xs:string, $resource-name as xs:string, $object) {

    let $store := xmldb:store($collection-uri, $resource-name, $object)
    let $target-path := concat($collection-uri, '/', $resource-name)
    let $chmod := sm:chmod($target-path, 'rwxr-xr-x')
    return
    ()
};

declare function compiler:copy($source-collection as xs:string, $target-collection as xs:string, $resource-name as xs:string) {

    let $copy := xmldb:copy($source-collection, $target-collection, $resource-name)
    let $target-path := concat($target-collection, '/', $resource-name)
    let $chmod := sm:chmod($target-path, 'rwxr-xr-x')
    return
    ()
};

declare function compiler:target-collection-path($base-collection-path) {

    let $items := (
            $base-collection-path,
            if($PROJECT_NAME != '') then $PROJECT_NAME else(),
            if($APP_NAME != '') then ('app', $APP_NAME) else()
        )
    return
    string-join($items, '/')
};

declare function compiler:_xrx-live-app-db-base-collection-path($src-collection-name as xs:string) {

    concat($xrx-live-project-db-base-collection-path, '/', string-join(subsequence(tokenize($src-collection-name, '/'), 5), '/'))
};

declare function compiler:_prepare-collection($base-collection as xs:string, $collections-to-create as xs:string*, $num) {

    let $new-collection := concat($base-collection, '/', $collections-to-create[$num])
    let $create-collection := 
        if($collections-to-create[$num] != '') then
            xmldb:create-collection($base-collection, $collections-to-create[$num])
        else()
    return
    if($num le count($collections-to-create)) then compiler:_prepare-collection($new-collection, $collections-to-create, $num + 1)
    else()    
};

declare function compiler:prepare-collection($collection as xs:string) {
    
    let $collections-to-prepare := 
        for $col in tokenize($collection, '/')
        return
        if($col != '') then $col else ()
    let $prepare-collections := 
        for $collection-to-prepare in $collections-to-prepare
        return
        compiler:_prepare-collection('/db', $collections-to-prepare, 2)
    return
    $prepare-collections
};

compiler:compile()