xquery version "3.0";


declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=yes";


import module namespace xrxe="http://www.monasterium.net/NS/xrxe" at "../editor/xrxe.xqm";
import module namespace qxrxa="http://www.monasterium.net/NS/qxrxa" at "../editor/qxrxa.xqm";
import module namespace qxsd='http://www.monasterium.net/NS/qxsd' at '../editor/qxsd.xqm';
import module namespace qxrxe='http://www.monasterium.net/NS/qxrxe' at '../editor/qxrxe.xqm';
import module namespace xrxe-conf="http://www.monasterium.net/NS/xrxe-conf" at "../editor/xrxe-conf.xqm";

let $method := request:get-method()
let $service-name := request:get-parameter("service", "")

let $data := root(request:get-data())/element()
let $xsdloc := xs:string($data/xsdloc[1]/text())

let $annofile := doc("/db/mom-data/metadata.annotation/annotations.xml")

let $service :=
if($service-name!='') then

if($service-name='unescape-mixed-content') then
xrxe:get-unescape-mixed-content($data)
else
let $path := xs:string($data/path[1]/text())

let $xsdloc := xs:string($data/xsdloc[1]/text())

return

(:########## QXRXA SERVIVES ###########:)

if($service-name='get-menu') then

let $content := $data/content[1]
let $selection := $data/selection[1]

let $log := util:log("INFO", $content)
let $log := util:log("INFO", $selection)
let $log := util:log("INFO", $path)
let $Log := util:log("INFO", $xsdloc)

let $menue := if(exists($annofile) and exists($annofile//value[@key = $path]) ) then
                $annofile//value[@key = $path]/menu
            else
                qxrxa:get-menu($path, $content, $selection, $xsdloc)

return
$menue

else if($service-name='get-annotation') then
qxrxa:get-annotation($path, $xsdloc)

else if($service-name='get-attribute') then
qxrxa:get-attribute($path, $xsdloc)

else if($service-name='get-attribute-options') then
let $element :=$data/element[1]
return
qxrxa:get-attribute-options($path, $element, $xsdloc)

else if($service-name='get-ui-text') then
        doc('../xrxa-ui-texts.xml')/element()

else
(:########## DEBUG SERVICES wrapped in element to display in browser ###########:)

<xrxe:service name="{$service-name}" xsdloc="{$xsdloc}" context="{$path}">
    {

    (:########## QXSD SERVIVES ##########:)

    if($service-name='get-xsd') then
    qxsd:xsd($xsdloc)

    else if($service-name='get-node') then
    qxsd:get-node($path, $xsdloc)

    else if($service-name='get-node-definition') then
    qxsd:get-node-definition($path, $xsdloc)

    else if($service-name='get-node-content') then
    qxsd:get-node-content($path, $xsdloc)

    else if($service-name='get-node-elements') then
    qxsd:get-node-elements($path, $xsdloc)

    else if($service-name='get-node-attributes') then
    qxsd:get-node-attributes($path, $xsdloc)


    (:########## QXRXE SERVIVES ##########:)

    else if($service-name='get-node-info') then
    qxrxe:get-node-info($path, (), $xsdloc)

    else if($service-name='get-node-appinfos') then
    qxrxe:get-node-appinfos($path, $xsdloc)

    else if($service-name='get-node-content') then
    qxrxe:get-node-content($path, $xsdloc)

    else if($service-name='get-node-relevant-elements') then
    qxrxe:get-node-relevant-elements($path, $xsdloc)

    else if($service-name='get-node-relevant-attributes') then
    qxrxe:get-node-relevant-attributes($path, $xsdloc)

    else if($service-name='get-node-template') then
    qxrxe:get-node-template($path, $xsdloc)

    else if($service-name='get-node-prefix-namespaces') then
    qxrxe:get-node-prefix-namespaces($path, $xsdloc)

    else
    <xrxe:error>{concat('service ', $service-name, ' not found')}</xrxe:error>

    }
</xrxe:service>

else  <xrxe:error>no service was named</xrxe:error>
return
    xrxe-conf:translate($service)
