xquery version "1.0";

if($exist:resource eq 'imagedata.php') then
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <forward url="imagedata.xql">
        <add-parameter name="country-id" value="{ request:get-parameter('country-id', '') }"/>
        <add-parameter name="archive-id" value="{ request:get-parameter('archive-id', '') }"/>
        <add-parameter name="fond-id" value="{ request:get-parameter('fond-id', '') }"/>
        <add-parameter name="collection-id" value="{ request:get-parameter('collection-id', '') }"/>
        <add-parameter name="charter-id" value="{ request:get-parameter('charter-id', '') }"/>
        <add-parameter name="start" value="{ request:get-parameter('start', '') }"/>
        <add-parameter name="imagedata" value="{ request:get-parameter('imagedata', '') }"/>
        <add-parameter name="lang" value="{ request:get-parameter('lang', '') }"/>
    </forward>
</dispatch>

else if($exist:resource eq 'charter') then
<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <forward url="viewer.xql"/>
</dispatch>

else
<ignore xmlns="http://exist.sourceforge.net/NS/exist">
    <cache-control cache="yes"/>
</ignore>
