<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:cei="http://www.monasterium.net/NS/cei" version="1.0" id="xml2cei">
  <xsl:template match="/">
    <cei:cei>
      <cei:teiHeader>
        <cei:fileDesc>
          <cei:titleStmt>
            <cei:title />
            <cei:author />
          </cei:titleStmt>
        </cei:fileDesc>
      </cei:teiHeader>
      <cei:text>
      </cei:text>
    </cei:cei>
  </xsl:template>
</xsl:stylesheet>