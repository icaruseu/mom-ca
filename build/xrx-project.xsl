<?xml version="1.0" encoding="UTF-8"?>
<!-- @author: Jochen Graf -->
<xsl:stylesheet xmlns:xrx="http://www.monasterium.net/NS/xrx" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:param name="project-name"/>
  <xsl:param name="xrx-live-collection-name"/>
  
  <xsl:template match="/">
    <xrx:conf>
      <xsl:apply-templates/>
      <xrx:param name="project-name"><xsl:value-of select="$project-name"/></xrx:param>
      <xrx:param name="xrx-live-collection-name"><xsl:value-of select="$xrx-live-collection-name"/></xrx:param>
    </xrx:conf>
  </xsl:template>
  
  <xsl:template match="//XRX/password">
    <xrx:param name="dba-password"><xsl:value-of select="."/></xrx:param>
  </xsl:template>
  
  <xsl:template match="//XRX/jetty/port">
    <xrx:param name="jetty-port"><xsl:value-of select="."/></xrx:param>
  </xsl:template>
  
  <xsl:template match="//XRX/jetty/servername">
    <xrx:param name="jetty-servername"><xsl:value-of select="."/></xrx:param>
  </xsl:template>

  <xsl:template match="text()" priority="-2"/>
  
</xsl:stylesheet>