<?xml version="1.0" encoding="UTF-8"?>
<!-- @author: Jochen Graf -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="xml" indent="yes" 
  omit-xml-declaration="no" 
  doctype-public="-//Mort Bay Consulting//DTD Configure 1.2//EN" 
  doctype-system="http://jetty.mortbay.org/configure_1_2.dtd"/>

  <xsl:param name="jetty-port"/>
  <xsl:param name="jetty-port-ssl"/>

  <xsl:template match="//New[@id='exist-webapp-context']/Set[@name='contextPath']/text()">
    <xsl:text>/</xsl:text>
  </xsl:template>
  
  <xsl:template match="//New[@class='org.eclipse.jetty.server.nio.SelectChannelConnector']/Set[@name='port']/SystemProperty[@name='jetty.port']/@default">
    <xsl:attribute name="default">
      <xsl:value-of select="$jetty-port"/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="//Set[@name='maxIdleTime']">
    <xsl:copy-of select="."/>
    <Set name="requestHeaderSize">32768</Set>
  </xsl:template>

  <xsl:template match="//SystemProperty[@name='jetty.port.ssl']/@default">
    <xsl:attribute name="default">
      <xsl:value-of select="$jetty-port-ssl"/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="@*|*|comment()" priority="-2">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
