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

module namespace mycollectionsearch="http://www.monasterium.net/NS/mycollectionsearch";


import module namespace cei="http://www.monasterium.net/NS/cei" at "xmldb:exist:///db/XRX.live/mom/app/metadata/cei.xqm";
import module namespace atom="http://www.w3.org/2005/Atom" at "xmldb:exist:///db/XRX.live/mom/app/data/atom.xqm";
import module namespace conf="http://www.monasterium.net/NS/conf" at "xmldb:exist:///db/XRX.live/mom/app/xrx/conf.xqm";


declare function mycollectionsearch:createResults($resultsXml){
    
    let $debug := util:log("ERROR", $resultsXml)
    
    let $params := <parameters>
                        <param name="searchterm" value="{$resultsXml//searchterm}"/>
                   </parameters>
    
    for $charter in $resultsXml//atom:entry 
        let $charterUrl :=  concat(conf:param('request-root'), $resultsXml//collectionid, "/" ,tokenize($charter//atom:id, "/")[last()], "/my-charter")
       (: let $newXml := mycollectionsearch:transformResult($charter, $params) :)
      
    return <a href="{$charterUrl}">abc</a>
};


declare function mycollectionsearch:transformResult($charter, $params){
    let $xslt := <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
        xmlns:ead="urn:isbn:1-931666-22-9"
        xmlns:atom="http://www.w3.org/2005/Atom"
        xmlns:cei="http://www.monasterium.net/NS/cei"
        version="2.0">
        <xsl:param name="searchterm"/>
     <!--   <xsl:param name="tagname"/> -->
        <xsl:template match="@* | node()">
            <xsl:copy>
                <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
        </xsl:template>
        <xsl:template match="@|node()" mode="copy">
            <xsl:copy>
                <xsl:apply-templates select="@|node()" mode="copy"/>
            </xsl:copy>
        </xsl:template>
        </xsl:stylesheet>
        
        return $xslt
};