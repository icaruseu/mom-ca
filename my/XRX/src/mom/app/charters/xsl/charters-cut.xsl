<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ead="urn:isbn:1-931666-22-9" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.0" id="charters-cut">
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="ead:*">
        <xsl:choose>
            <xsl:when test="@level and @level='item'"/>
            <xsl:otherwise>
                <!--xsl:variable name="name">
                    <xsl:value-of select="name()"/>
                </xsl:variable-->
                <xsl:copy>
                    <xsl:copy-of select="./@*"/> 
                    <!--xsl:if test="@level">
                        <xsl:attribute name="level">
                            <xsl:value-of select="@level"/>
                        </xsl:attribute>
                    </xsl:if-->
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>