<?xml version="1.0" encoding="UTF-8"?>
<!-- @author: Jochen Graf -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="xml" indent="no"
  omit-xml-declaration="no" 
  doctype-public="-//Mort Bay Consulting//DTD Configure 1.2//EN" 
  doctype-system="http://jetty.mortbay.org/configure_1_2.dtd"/>

  <xsl:template match="//New[@class='org.eclipse.jetty.server.ssl.SslSelectChannelConnector']">
    <xsl:copy>
      <xsl:apply-templates select="@* | * | text()"/>
      <xsl:element name="Set">
        <xsl:attribute name="name">forwarded</xsl:attribute>
      </xsl:element>
    </xsl:copy>
  </xsl:template> 

</xsl:stylesheet>