xquery version "3.1";

(:~
 : Configuration module for MOM-CA.
 : Provides conf:param() compatible with the legacy XRX conf module.
 : Reads parameters from /db/apps/mom-ca/config.xml.
 :)

module namespace conf = "http://www.monasterium.net/NS/conf";

declare namespace xrx = "http://www.monasterium.net/NS/xrx";

declare variable $conf:app-root := "/db/apps/mom-ca";

declare variable $conf:config-doc := doc($conf:app-root || "/config.xml");

(:~
 : Retrieve a configuration parameter by name.
 : Returns child elements for structured params or string text for simple ones.
 : Compatible with the legacy conf:param() API.
 :)
declare function conf:param($name as xs:string) as item()* {
    let $param := $conf:config-doc//xrx:param[@name = $name]
    return
        if (exists($param/*)) then
            $param/*
        else
            $param/text()
};
