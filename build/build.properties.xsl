<?xml version="1.0" encoding="UTF-8"?>
<!-- @author: Jochen Graf -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:param name="exist-absolute-path"/>
  
  <xsl:template match="//eXist/home/text()">
    <xsl:value-of select="$exist-absolute-path"/>
  </xsl:template>
  
  <xsl:template match="@*|*|comment()" priority="-2">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>