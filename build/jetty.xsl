<?xml version="1.0" encoding="UTF-8"?>
<!-- @author: Jochen Graf -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="xml" indent="no"
                omit-xml-declaration="no"
                doctype-public="-//Mort Bay Consulting//DTD Configure 1.2//EN"
                doctype-system="http://jetty.mortbay.org/configure_1_2.dtd"/>

    <xsl:template match="//New[@id='httpConfig']">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:element name="Call">
                <xsl:attribute name="name">addCustomizer</xsl:attribute>
                <xsl:element name="Arg">
                    <xsl:element name="New">
                        <xsl:attribute name="class">org.eclipse.jetty.server.ForwardedRequestCustomizer</xsl:attribute>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*|*|comment()" priority="-2">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>