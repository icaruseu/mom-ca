<?xml version="1.0" encoding="UTF-8"?>
<!-- @author: Jochen Graf -->
<xsl:stylesheet xmlns:javaee="http://xmlns.jcp.org/xml/ns/javaee" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:param name="project-name"/>
  
  <xsl:template match="//javaee:filter-mapping[javaee:filter-name='XFormsFilter'][1]">
    <xsl:copy-of select="."/>
    <xsl:element name="filter-mapping" namespace="http://xmlns.jcp.org/xml/ns/javaee">
      <xsl:element name="filter-name" namespace="http://xmlns.jcp.org/xml/ns/javaee">XFormsFilter</xsl:element>
      <xsl:element name="url-pattern" namespace="http://xmlns.jcp.org/xml/ns/javaee">
        <xsl:text>/</xsl:text>
        <xsl:value-of select="$project-name"/>
        <xsl:text>/*</xsl:text>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="//javaee:servlet[javaee:servlet-name='EXistServlet']">
    <xsl:element name="servlet" namespace="http://xmlns.jcp.org/xml/ns/javaee">
      <xsl:copy-of select="./javaee:servlet-name"/>
      <xsl:copy-of select="./javaee:servlet-class"/>
      <xsl:copy-of select="./javaee:init-param"/>
      
      <xsl:element name="init-param" namespace="http://xmlns.jcp.org/xml/ns/javaee">
        <xsl:element name="param-name" namespace="http://xmlns.jcp.org/xml/ns/javaee">
          <xsl:text>hidden</xsl:text>
        </xsl:element>
        <xsl:element name="param-value" namespace="http://xmlns.jcp.org/xml/ns/javaee">
          <xsl:text>true</xsl:text>
        </xsl:element>
      </xsl:element>
      
      <xsl:copy-of select="./javaee:load-on-startup"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="@*|*|comment()" priority="-2">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>