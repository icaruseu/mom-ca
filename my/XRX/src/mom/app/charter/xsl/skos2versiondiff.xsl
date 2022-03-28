<xsl:stylesheet xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xrx="http://www.monasterium.net/NS/xrx" 
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    id="skos2versiondiff"
    xmlns:xhtml="http://www.w3.org/1999/xhtml" 
    version="1.0"
    xmlns="http://www.w3.org/1999/xhtml">
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:for-each select="@*">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>] </xsl:text>
        </xsl:for-each>
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="text()[not(following-sibling::text()) and not(preceding-sibling::text())]">
        <xsl:value-of select="."/>
        <xsl:text> </xsl:text>
    </xsl:template>
    
</xsl:stylesheet>