xquery version "1.0";

declare option exist:serialize "method=xhtml media-type=text/html";

let $archive-id := request:get-parameter('archive-id', '')
let $fond-id := request:get-parameter('fond-id', '')
let $collection-id := request:get-parameter('collection-id', '')
let $charter-id := request:get-parameter('charter-id', '')
let $start := request:get-parameter('start', '')
let $imagedata := request:get-parameter('imagedata', '')
let $lang := request:get-parameter('lang', '')

return


<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="de" lang="de">
    <head>
        <meta http-equiv="Content-Type" content="text/html; UTF-8" />

        <style type="text/css">
        <!--
        body {
            margin-left: 0px;
            margin-top: 0px;
            margin-right: 0px;
            margin-bottom: 0px;
        }
        -->
        </style>
    </head>
    <body>
        <table width="100%" height="100%" border="0" cellspacing="0" cellpadding="0">
            <tr>
                <td height="100%" align="center" valign="middle">
                    <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=8,0,0,0" id="blackelegance" width="100%" height="100%" align="middle">
                        <param name="allowScriptAccess" value="sameDomain" />
                        <param name="movie" value="viewer.swf?lang={ $lang }&amp;imagedata={ $imagedata }&amp;archive-id={ $archive-id }&amp;fond-id={ $fond-id }&amp;collection-id={ $collection-id }&amp;charter-id={ $charter-id }&amp;start={ $start }" />
                        <param name="quality" value="high" />
                        <param name="scale" value="noscale" />
                        <param name="bgcolor" value="#333333" />
                        <param name="salign" value="lt" />
                        <embed src="viewer.swf?lang={ $lang }&amp;imagedata={ $imagedata }&amp;archive-id={ $archive-id }&amp;fond-id={ $fond-id }&amp;collection-id={ $collection-id }&amp;charter-id={ $charter-id }&amp;start={ $start }" width="100%" height="100%" align="middle" quality="high" name="blackelegance" scale="noscale" salign="lt" bgcolor="#333333" allowscriptaccess="sameDomain" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" />      
                    </object>
                </td>
            </tr>
        </table>
    </body>
</html>