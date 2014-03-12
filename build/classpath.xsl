<?xml version="1.0" encoding="UTF-8"?>
<!-- @author: Jochen Graf -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:param name="exist-home"/>
  <xsl:param name="my-exist-src"/>
  <xsl:param name="my-betterform-src"/>
  <xsl:param name="my-applet-src"/>
  <xsl:param name="my-xrx-src"/>
  <xsl:param name="my-exist-webapp"/>
  
  <xsl:template match="/">
    <classpath>
      <xsl:apply-templates/>
      <!-- TODO: a dynamic list should be possible -->
      <xsl:element name="classpathentry">
        <xsl:attribute name="kind">src</xsl:attribute>
        <xsl:attribute name="path">
          <xsl:value-of select="$my-exist-src"/>
        </xsl:attribute>
      </xsl:element>
      <xsl:element name="classpathentry">
        <xsl:attribute name="kind">src</xsl:attribute>
        <xsl:attribute name="path">
          <xsl:value-of select="$my-exist-webapp"/>
        </xsl:attribute>
      </xsl:element>
      <xsl:element name="classpathentry">
        <xsl:attribute name="kind">src</xsl:attribute>
        <xsl:attribute name="path">
          <xsl:value-of select="$my-betterform-src"/>
        </xsl:attribute>
      </xsl:element>
      <xsl:element name="classpathentry">
        <xsl:attribute name="kind">src</xsl:attribute>
        <xsl:attribute name="path">
          <xsl:value-of select="$my-applet-src"/>
        </xsl:attribute>
      </xsl:element>
      <xsl:element name="classpathentry">
        <xsl:attribute name="kind">src</xsl:attribute>
        <xsl:attribute name="path">
          <xsl:value-of select="$my-xrx-src"/>
        </xsl:attribute>
      </xsl:element>
      <classpathentry kind="lib">
        <xsl:attribute name="path">
          <xsl:text>./</xsl:text>
          <xsl:value-of select="$exist-home"/>
          <xsl:text>/exist.jar</xsl:text>
        </xsl:attribute>
      </classpathentry>
      <classpathentry kind="output" path="bin"/>
      <classpathentry kind="con" path="org.eclipse.jdt.launching.JRE_CONTAINER/org.eclipse.jdt.internal.debug.ui.launcher.StandardVMType/JavaSE-1.6"/>
    </classpath>
  </xsl:template>
  
  <xsl:template match="classpathentry">
    <xsl:if test="@kind='lib'">
      <xsl:element name="classpathentry">
        <xsl:copy-of select="@kind"/>
        <xsl:attribute name="path">
          <xsl:value-of select="$exist-home"/>
          <xsl:text>/</xsl:text>
          <xsl:value-of select="@path"/>
        </xsl:attribute>
      </xsl:element>
    </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>
