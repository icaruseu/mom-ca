<?xml version="1.0" encoding="UTF-8"?>
<!-- @author: Daniel Jeller -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="xml" indent="no"
                omit-xml-declaration="no"/>

    <xsl:param name="betterform-debug-allowed"/>

    <xsl:template match="//properties/property[@name='betterform.debug-allowed']/@value">
        <xsl:attribute name="value">
            <xsl:value-of select="$betterform-debug-allowed"/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="@*|*|comment()" priority="-2">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>