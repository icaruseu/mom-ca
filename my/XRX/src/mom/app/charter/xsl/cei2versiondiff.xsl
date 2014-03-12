<xsl:stylesheet xmlns:atom="http://www.w3.org/2005/Atom"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xrx="http://www.monasterium.net/NS/xrx" 
	xmlns:cei="http://www.monasterium.net/NS/cei" 
	id="cei2versiondiff"
	xmlns:xhtml="http://www.w3.org/1999/xhtml" 
	version="1.0"
	xmlns="http://www.w3.org/1999/xhtml">
	
	<xsl:template match="/">
	  <xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="*">
	  <xsl:choose>
	    <xsl:when test="name(.) = 'cei:text'">
	      <xsl:text>&#10;</xsl:text>
	      <xsl:text>&#10;</xsl:text>
				<xrx:i18n>
				  <xrx:key>charter</xrx:key>
				  <xrx:default>Charter</xrx:default>
				</xrx:i18n>
	      <xsl:text>: </xsl:text>
	    </xsl:when>
	    <xsl:when test="name(.) = 'cei:sourceDesc'">
	      <xsl:text>&#10;</xsl:text>
	      <xsl:text>&#10;</xsl:text>
				<xrx:i18n>
				  <xrx:key>source</xrx:key>
				  <xrx:default>Source</xrx:default>
				</xrx:i18n>
	      <xsl:text>: </xsl:text>
	    </xsl:when>
	    <xsl:when test="name(.) = 'cei:abstract'">
	      <xsl:text>&#10;</xsl:text>
	      <xsl:text>&#10;</xsl:text>
        <xrx:i18n>
          <xrx:key>abstract</xrx:key>
          <xrx:default>Abstract</xrx:default>
        </xrx:i18n>
	      <xsl:text>: </xsl:text>
	    </xsl:when>
	    <xsl:when test="name(.) = 'cei:idno'">
	      <xsl:text>&#10;</xsl:text>
	      <xsl:text>&#10;</xsl:text>
        <xrx:i18n>
          <xrx:key>signature</xrx:key>
          <xrx:default>Signature</xrx:default>
        </xrx:i18n>
	      <xsl:text>: </xsl:text>
	    </xsl:when>
	    <xsl:when test="name(.) = 'cei:issued'">
	      <xsl:text>&#10;</xsl:text>
	      <xsl:text>&#10;</xsl:text>
        <xrx:i18n>
          <xrx:key>issued</xrx:key>
          <xrx:default>Issued</xrx:default>
        </xrx:i18n>
	      <xsl:text>: </xsl:text>
	    </xsl:when>
	    <xsl:when test="name(.) = 'cei:tenor'">
	      <xsl:text>&#10;</xsl:text>
	      <xsl:text>&#10;</xsl:text>
        <xrx:i18n>
          <xrx:key>transcription</xrx:key>
          <xrx:default>Transcription</xrx:default>
        </xrx:i18n>
	      <xsl:text>: </xsl:text>
	    </xsl:when>
	    <xsl:when test="name(.) = 'cei:back'">
	      <xsl:text>&#10;</xsl:text>
	      <xsl:text>&#10;</xsl:text>
        <xrx:i18n>
          <xrx:key>appendix</xrx:key>
          <xrx:default>Appendix</xrx:default>
        </xrx:i18n>
	      <xsl:text>: </xsl:text>
	    </xsl:when>
	    <xsl:when test="name(.) = 'cei:witnessOrig'">
	      <xsl:text>&#10;</xsl:text>
	      <xsl:text>&#10;</xsl:text>
        <xrx:i18n>
          <xrx:key>description-of-original</xrx:key>
          <xrx:default>Description of Original</xrx:default>
        </xrx:i18n>
	      <xsl:text>: </xsl:text>
	    </xsl:when>
	    <xsl:when test="name(.) = 'cei:witListPar'">
	      <xsl:text>&#10;</xsl:text>
	      <xsl:text>&#10;</xsl:text>
        <xrx:i18n>
          <xrx:key>copies</xrx:key>
          <xrx:default>Copies</xrx:default>
        </xrx:i18n>
	      <xsl:text>: </xsl:text>
	    </xsl:when>
	    <xsl:when test="name(.) = 'cei:diplomaticAnalysis'">
	      <xsl:text>&#10;</xsl:text>
	      <xsl:text>&#10;</xsl:text>
        <xrx:i18n>
          <xrx:key>commentary</xrx:key>
          <xrx:default>Commentary</xrx:default>
        </xrx:i18n>
	      <xsl:text>: </xsl:text>
	    </xsl:when>
	  </xsl:choose>
	  <xsl:for-each select="@*">
	    <xsl:text>[</xsl:text>
	    <xsl:value-of select="."/>
	    <xsl:text>] </xsl:text>
	  </xsl:for-each>
	  <xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="text()">
	  <xsl:choose>
	    <xsl:when test="./following-sibling::text()">
	      <xsl:value-of select="."/>
	    </xsl:when>
	    <xsl:when test="./preceding-sibling::text()">
	      <xsl:value-of select="."/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="."/>
	      <xsl:text> </xsl:text>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>