<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" encoding="UTF-8"/>
<xsl:strip-space elements="*"/>

<xsl:variable name="Entities">
  <entities>
    <entity value="&quot;" escaped="&amp;quot;"/>
    <entity value="&amp;" escaped="&amp;amp;"/>
    <entity value="&lt;" escaped="&amp;lt;"/>
    <entity value="&gt;" escaped="&amp;gt;"/>
    <entity value="&apos;" escaped="&amp;apos;"/>
  </entities>
</xsl:variable>

<xsl:template match="/">
  <html>
    <head>
      <meta charset="utf-8"/>
    </head>
    <body>
      <xsl:apply-templates/>
    </body>
  </html>
</xsl:template>

<xsl:template match="*">
  <xsl:variable name="currentNode" select="."/>
  <xsl:text>&lt;</xsl:text>
  <xsl:value-of select="name(.)"/>
  <xsl:apply-templates select="@*"/>
  <xsl:for-each select="namespace::*[name() != 'xml'][not(. = $currentNode/../namespace::*)]">
    <xsl:call-template name="EscapeNamespace">
      <xsl:with-param name="namespace" select="."/>
    </xsl:call-template>
  </xsl:for-each>
  <xsl:text>&gt;</xsl:text>
  <xsl:apply-templates select="node()"/>
  <xsl:text>&lt;/</xsl:text>
  <xsl:value-of select="name(.)"/>
  <xsl:text>&gt;</xsl:text>
</xsl:template>

<xsl:template match="@*">
  <xsl:text> </xsl:text>
  <xsl:value-of select="name(.)"/>
  <xsl:text>=&quot;</xsl:text>
  <xsl:call-template name="EscapeText">
    <xsl:with-param name="text" select="."/>
  </xsl:call-template>
  <xsl:text>&quot;</xsl:text>
</xsl:template>

<xsl:template match="text()">
  <xsl:call-template name="EscapeText">
    <xsl:with-param name="text" select="."/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="EscapeNamespace">
  <xsl:param name="namespace"/>

  <xsl:variable name="prefix">
    <xsl:choose>
      <xsl:when test="name($namespace) = ''">
        <xsl:value-of select="'xmlns'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat('xmlns:', name($namespace))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:value-of select="concat(' ', $prefix, '=&quot;')"/>
  <xsl:call-template name="EscapeText">
    <xsl:with-param name="text" select="$namespace"/>
  </xsl:call-template>
  <xsl:value-of select="'&quot;'"/>
</xsl:template>

<xsl:template name="EscapeText">
  <xsl:param name="text"/>

  <xsl:variable name="apos" value="&apos;"/>
  <xsl:variable name="foundEntity">
    <xsl:choose>
      <xsl:when test="contains($text, '&quot;')">
        <xsl:value-of select="'&quot;'"/>
      </xsl:when>
      <xsl:when test="contains($text, '&amp;')">
        <xsl:value-of select="'&amp;'"/>
      </xsl:when>
      <xsl:when test="contains($text, '&lt;')">
        <xsl:value-of select="'&lt;'"/>
      </xsl:when>
      <xsl:when test="contains($text, '&gt;')">
        <xsl:value-of select="'&gt;'"/>
      </xsl:when>
      <xsl:when test='contains($text, "&apos;")'>
        <xsl:value-of select="$apos"/>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="escapedEntity">
    <xsl:choose>
      <xsl:when test="contains($text, '&quot;')">
        <xsl:value-of select="'&amp;quot;'"/>
      </xsl:when>
      <xsl:when test="contains($text, '&amp;')">
        <xsl:value-of select="'&amp;amp;'"/>
      </xsl:when>
      <xsl:when test="contains($text, '&lt;')">
        <xsl:value-of select="'&amp;lt;'"/>
      </xsl:when>
      <xsl:when test="contains($text, '&gt;')">
        <xsl:value-of select="'&amp;gt;'"/>
      </xsl:when>
      <xsl:when test='contains($text, "&apos;")'>
        <xsl:value-of select="'&amp;apos;'"/>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="$foundEntity != ''">
      <xsl:call-template name="EscapeText">
        <xsl:with-param name="text" select="substring-before($text, $foundEntity)"/>
      </xsl:call-template>
      <xsl:value-of select="$escapedEntity" />
      <xsl:call-template name="EscapeText">
        <xsl:with-param name="text" select="substring-after($text, $foundEntity)"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$text"/>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>

</xsl:stylesheet>