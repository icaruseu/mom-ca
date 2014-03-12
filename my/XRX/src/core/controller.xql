xquery version "3.0";

(: lang change request? :)
declare variable $_lang-changed := 
    if(request:get-parameter('_lang', '') != '') then
        session:set-attribute('lang', request:get-parameter('_lang', ''))
    else();
    
(: relative path to the xrx system :)  
declare variable $xrx-relative-path :=

    string-join(
        for $pos in ( 1 to (count(tokenize($exist:path, '/')) - 1) )
        return
        '../',
        ''
    );

declare variable $xrx-project-relative-path := 

    string-join(
        for $pos in ( 1 to (count(tokenize($exist:path, '/')) - 2) )
        return
        '../',
        ''
    );

(: redirect :)
if($exist:path = '/') then
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <redirect url="/#XRX_PROJECT_NAME/home"/>
</dispatch>

(: resources :)
else if(starts-with($exist:path, '/icon/')) then
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <forward url="{ $xrx-relative-path }core/res/tango-icon-theme/32x32/{ substring-after($exist:path, '/icon/') }"/>
</dispatch>

else if(starts-with($exist:path, '/jssaxparser/')) then
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <forward url="{ $xrx-relative-path }lib/jssaxparser{ substring-after($exist:path, 'jssaxparser') }"/>
</dispatch>

else if(starts-with($exist:path, '/jquery/jquery.js')) then
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <forward url="{ $xrx-relative-path }lib/jQuery/jquery-1.8.0.js"/>
</dispatch>

else if(starts-with($exist:path, '/jquery/')) then
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <forward url="{ $xrx-relative-path }../XRX.res/jquery{ substring-after($exist:path, 'jquery') }"/>
</dispatch>

else if(starts-with($exist:path, '/codemirror/')) then
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <forward url="{ $xrx-relative-path }../XRX.res/codemirror{ substring-after($exist:path, 'codemirror') }"/>
</dispatch>

else if(starts-with($exist:path, '/font/')) then
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <forward url="{ concat('../res/font/', $exist:resource) }"/>
</dispatch>

else if(ends-with($exist:resource, '.jpg') or ends-with($exist:resource, '.png') or ends-with($exist:resource, '.gif')) then
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <forward url="{ concat('res/img/', $exist:resource) }"/>
</dispatch>

else if(ends-with($exist:resource, '.xsl')) then
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <forward url="{ concat('res/xsl/', $exist:resource) }"/>
</dispatch>

else if(ends-with($exist:resource, '.xsd')) then
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <forward url="{ concat('res/xsd/', $exist:resource) }"/>
</dispatch>

else if(ends-with($exist:resource, '.js')) then
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <forward url="{ concat('res/js/', $exist:resource) }"/>
</dispatch>

else if(ends-with($exist:path, 'xrxe-services.xql')) then
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <forward url="../#XRX_PROJECT_NAME/app/editor/xrxe-services.xql"/>
</dispatch>

else if(ends-with($exist:path, '.xml') and not(contains($exist:path, '/atom/'))) then
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <forward url="{ concat('res/xml/', $exist:resource) }"/>
</dispatch>

(: main dispatcher :)
else
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <forward url="{ $xrx-relative-path }#XRX_PROJECT_NAME/app/xrx/main.xql"/>
    <cache-control cache="no"/>
</dispatch>