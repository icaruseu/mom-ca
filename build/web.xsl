<?xml version="1.0" encoding="UTF-8"?>
<!-- @author: Jochen Graf -->
<xsl:stylesheet xmlns:j2ee="http://java.sun.com/xml/ns/j2ee" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:param name="project-name"/>
  
  <xsl:template match="//j2ee:filter-mapping[j2ee:filter-name='XFormsFilter'][1]">
    <xsl:copy-of select="."/>
    <xsl:element name="filter-mapping" namespace="http://java.sun.com/xml/ns/j2ee">
      <xsl:element name="filter-name" namespace="http://java.sun.com/xml/ns/j2ee">XFormsFilter</xsl:element>
      <xsl:element name="url-pattern" namespace="http://java.sun.com/xml/ns/j2ee">
        <xsl:text>/</xsl:text>
        <xsl:value-of select="$project-name"/>
        <xsl:text>/*</xsl:text>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="//j2ee:servlet[j2ee:servlet-name='EXistServlet']">
    <xsl:element name="servlet" namespace="http://java.sun.com/xml/ns/j2ee">
      <xsl:copy-of select="./j2ee:servlet-name"/>
      <xsl:copy-of select="./j2ee:servlet-class"/>
      <xsl:copy-of select="./j2ee:init-param"/>
      
      <xsl:element name="init-param" namespace="http://java.sun.com/xml/ns/j2ee">
        <xsl:element name="param-name" namespace="http://java.sun.com/xml/ns/j2ee">
          <xsl:text>hidden</xsl:text>
        </xsl:element>
        <xsl:element name="param-value" namespace="http://java.sun.com/xml/ns/j2ee">
          <xsl:text>true</xsl:text>
        </xsl:element>
      </xsl:element>
      
      <xsl:copy-of select="./j2ee:load-on-startup"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="@*|*|comment()" priority="-2">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>