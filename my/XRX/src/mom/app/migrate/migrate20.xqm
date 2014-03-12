xquery version "3.0";

module namespace migrate20="http://www.monasterium.net/NS/migrate20";

import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../xrx/conf.xqm";

declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace i18n="http://www.monasterium.net/NS/i18n";
declare namespace xrx="http://www.monasterium.net/NS/xrx";

declare function migrate20:htdoc-transform($entry as element(atom:entry)) as element() {

    let $xslt := 
    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:i18n="http://www.monasterium.net/NS/i18n"
        xmlns:xrx="http://www.monasterium.net/NS/xrx"
        xmlns:atom="http://www.w3.org/2005/Atom" version="1.0">
      <xsl:template match="//atom:id">
        <xsl:element name="atom:id">
          <xsl:text>{ conf:param('atom-tag-name') }/mom/htdoc/</xsl:text>
          <xsl:value-of select="."/>
        </xsl:element>
      </xsl:template>
      <xsl:template match="//i18n:label">
        <xsl:element name="xrx:i18n">
          <xsl:element name="xrx:key"><xsl:value-of select="@key"/></xsl:element>
          <xsl:element name="xrx:default"><xsl:value-of select="@default"/></xsl:element>
        </xsl:element>
      </xsl:template>
      <xsl:template match="@*|*" priority="-2">
        <xsl:copy>
          <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
      </xsl:template>
    </xsl:stylesheet>
    return
    transform:transform($entry, $xslt, ())
};

declare function migrate20:user-transform($user-xml as element(xrx:user)) as element() {

    let $xslt := 
    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xrx="http://www.monasterium.net/NS/xrx" version="1.0">
      <xsl:template match="//xrx:role"/>
      <xsl:template match="@*|*" priority="-2">
        <xsl:copy>
          <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
      </xsl:template>
    </xsl:stylesheet>
    return
    transform:transform($user-xml, $xslt, ())
};

declare function migrate20:atomid-transform($entry as element(atom:entry), $atomid, $objectid) as element() {

    let $xslt := 
    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:atom="http://www.w3.org/2005/Atom" xmlns:cei="http://www.monasterium.net/NS/cei" version="1.0">
      <xsl:template match="//atom:id">
        <xsl:element name="atom:id">{ $atomid }</xsl:element>
      </xsl:template>
      <xsl:template match="//cei:body/cei:idno/@id">
        <xsl:attribute name="id">{ $objectid }</xsl:attribute>
      </xsl:template>
      <xsl:template match="@*|*" priority="-2">
        <xsl:copy>
          <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
      </xsl:template>
    </xsl:stylesheet>
    return
    transform:transform($entry, $xslt, ())
};

declare function migrate20:extend-eag($entry as element(atom:entry)) as element() {

    let $xslt := 
    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:eag="http://www.archivgut-online.de/eag"
        version="1.0">
      <xsl:template match="//eag:telephone">
        <xsl:copy-of select="."/>
        <eag:fax/>
      </xsl:template>
      <xsl:template match="//eag:repositorguides">
        <xsl:copy-of select="."/>
        <eag:extptr href="" entityref=""/>
      </xsl:template>
      <xsl:template match="@*|*" priority="-2">
        <xsl:copy>
          <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
      </xsl:template>
    </xsl:stylesheet>
    return
    transform:transform($entry, $xslt, ())    
};

declare function migrate20:doza($entry as element(atom:entry)) as element() {

    let $atomid := $entry/atom:id/text()
    let $new-atomid := replace($atomid, 'Urkunden2', 'Urkunden')
    let $xslt := 
    <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:eag="http://www.archivgut-online.de/eag"
        xmlns:atom="http://www.w3.org/2005/Atom"
        version="1.0">
      <xsl:template match="//atom:id">
        <xsl:element name="atom:id">{ $new-atomid }</xsl:element>
      </xsl:template>
      <xsl:template match="@*|*" priority="-2">
        <xsl:copy>
          <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
      </xsl:template>
    </xsl:stylesheet>
    return
    transform:transform($entry, $xslt, ())    
};
