<xsl:stylesheet id="cei2edm" version="1.0" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:cei="http://www.monasterium.net/NS/cei" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:edm="http://www.europeana.eu/schemas/edm/" xmlns:ese="http://www.europeana.eu/schemas/ese/" xmlns:oai="http://www.openarchives.org/OAI/2.0/" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:ore="http://www.openarchives.org/ore/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:svcs="http://rdfs.org/sioc/services#" xmlns:xrx="http://www.mom-ca.uni-koeln.de/NS/xrx" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xsi:schemaLocation="http://www.w3.org/1999/XSL/Transform https://www.w3.org/2007/schema-for-xslt20.xsd">
  <xsl:param name="platform-id" />
  <xsl:param name="data-provider" />
  <xsl:param name="base-image-url" />
  <xsl:param name="fond-id" />
  <xsl:template match="/">
    <!-- Create the ids that the elements will use -->
    <xsl:variable name="provided-cho-id" select="concat('#', .//atom:id)" />
    <xsl:variable name="aggregation-id">
      <xsl:text>https://www.monasterium.net/mom/</xsl:text>
      <xsl:value-of select="substring-after(.//atom:id, 'charter/')" />
      <xsl:text>/charter</xsl:text>
    </xsl:variable>
    <xsl:variable name="image-ids">
      <xsl:for-each select="//cei:graphic">
        <id base="{concat($base-image-url, @url)}" name="{substring-before(@url, '.')}" iiif="{concat($base-image-url, @url, '/full/512,/0/default.jpg')}" />
      </xsl:for-each>
    </xsl:variable>
    <!-- Start OAI output -->
    <oai:metadata>
      <rdf:RDF>
        <!-- Aggregation -->
        <ore:Aggregation rdf:about="{$aggregation-id}">
          <!-- Connected CHO -->
          <edm:aggregatedCHO rdf:resource="{$provided-cho-id}" />
          <!-- Connected WebResources -->
          <edm:isShownAt rdf:resource="{$aggregation-id}" />
          <xsl:for-each select="$image-ids/id">
            <xsl:sort select="@name" data-type="text" order="ascending" />
            <xsl:choose>
              <xsl:when test="position() = 1">
                <edm:isShownBy rdf:resource="{@iiif}" />
              </xsl:when>
              <xsl:otherwise>
                <edm:hasView rdf:resource="{@iiif}" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
          <!-- License -->
          <edm:rights rdf:resource="http://creativecommons.org/licenses/by-nc/3.0/" />
          <!-- Data provider -->
          <edm:dataProvider>Monasterium.net</edm:dataProvider>
        </ore:Aggregation>
        <!-- Image related elements -->
        <xsl:for-each select="$image-ids/id">
          <!-- Image webresource -->
          <edm:WebResource rdf:about="{@iiif}">
            <svcs:has_service rdf:resource="{@base}" />
          </edm:WebResource>
          <!-- Service for IIIF-->
          <svcs:Service rdf:about="{@base}">
            <dcterms:conformsTo rdf:resource="http://iiif.io/api/image" />
          </svcs:Service>
        </xsl:for-each>
        <!-- CHO -->
        <edm:ProvidedCHO rdf:about="{$provided-cho-id}">
          <!-- Title -->
          <dc:title>
            <xsl:value-of select="concat('Charter: ', $fond-id, ' ', .//cei:idno/@id)" />
          </dc:title>
          <!-- Types -->
          <dc:type rdf:resource="http://purl.org/dc/dcmitype/PhysicalObject" />
          <dc:type rdf:resource="http://purl.org/dc/dcmitype/Text" />
          <dc:type>Charter</dc:type>
          <edm:type>TEXT</edm:type>
          <!-- Identifier -->
          <dc:identifier>
            <xsl:value-of select=".//cei:idno" />
          </dc:identifier>
          <!-- Abstract -->
          <xsl:if test=".//cei:abstract/text()">
            <dc:description>
              <xsl:value-of select="normalize-space(.//cei:abstract)" />
            </dc:description>
          </xsl:if>
          <!-- Language -->
          <xsl:if test=".//cei:lang_MOM/text()">
            <dc:language>
              <xsl:value-of select=".//cei:lang_MOM" />
            </dc:language>
          </xsl:if>
          <!-- Dimensions -->
          <xsl:if test=".//cei:physicalDesc/cei:dimensions/text()">
            <dcterms:extent>
              <xsl:value-of select=".//cei:physicalDesc/cei:dimensions" />
            </dcterms:extent>
          </xsl:if>
          <!-- Material -->
          <xsl:if test=".//cei:material/text()">
            <dcterms:medium>
              <xsl:value-of select=".//cei:material" />
            </dcterms:medium>
          </xsl:if>
          <!-- Issuer -->
          <xsl:if test=".//cei:issuer/text()">
            <dc:creator>
              <xsl:value-of select=".//cei:issuer" />
            </dc:creator>
          </xsl:if>
          <!-- Notarius -->
          <xsl:if test=".//cei:notariusSub/text()">
            <dc:creator>
              <xsl:value-of select=".//cei:notariusSub" />
            </dc:creator>
          </xsl:if>
          <!-- Associated place names -->
          <xsl:if test=".//cei:placeName/text()">
            <xsl:for-each select=".//cei:abstract/cei:placeName">
              <dcterms:spatial>
                <xsl:value-of select="./text()" />
              </dcterms:spatial>
            </xsl:for-each>
          </xsl:if>
          <!-- Associated geography names -->
          <xsl:if test=".//cei:geogName/text()">
            <xsl:for-each select=".//cei:geogName">
              <dcterms:spatial>
                <xsl:value-of select="./text()" />
              </dcterms:spatial>
            </xsl:for-each>
          </xsl:if>
          <!-- Keywords -->
          <xsl:if test=".//cei:keyword">
            <xsl:for-each select=".//cei:keyword">
              <dc:subject>
                <xsl:value-of select="./text()" />
              </dc:subject>
            </xsl:for-each>
          </xsl:if>
          <!-- Date -->
          <xsl:if test=".//cei:issued/cei:date/text() or .//cei:issued/cei:dateRange/text()">
            <dcterms:issued>
              <xsl:choose>
                <xsl:when test=".//cei:issued/cei:date/@value != 99999999">
                  <xsl:variable name="date" select=".//cei:issued/cei:date/@value" />
                  <xsl:variable name="mm">
                    <xsl:value-of select="substring($date,5,2)" />
                  </xsl:variable>
                  <xsl:variable name="dd">
                    <xsl:value-of select="substring($date,7,2)" />
                  </xsl:variable>
                  <xsl:variable name="yyyy">
                    <xsl:value-of select="substring($date,1,4)" />
                  </xsl:variable>
                  <xsl:value-of select="$yyyy" />
                  <xsl:value-of select="'-'" />
                  <xsl:value-of select="$mm" />
                  <xsl:value-of select="'-'" />
                  <xsl:value-of select="$dd" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:choose>
                    <xsl:when test="(.//cei:issued/cei:dateRange/@from = .//cei:issued/cei:dateRange/@to) and (.//cei:issued/cei:dateRange/@from != '99999999')">
                      <xsl:variable name="date" select=".//cei:issued/cei:dateRange/@from" />
                      <xsl:variable name="mm">
                        <xsl:value-of select="substring($date,5,2)" />
                      </xsl:variable>
                      <xsl:variable name="dd">
                        <xsl:value-of select="substring($date,7,2)" />
                      </xsl:variable>
                      <xsl:variable name="yyyy">
                        <xsl:value-of select="substring($date,1,4)" />
                      </xsl:variable>
                      <xsl:value-of select="$yyyy" />
                      <xsl:value-of select="'-'" />
                      <xsl:value-of select="$mm" />
                      <xsl:value-of select="'-'" />
                      <xsl:value-of select="$dd" />
                    </xsl:when>
                    <xsl:when test="(.//cei:issued/cei:dateRange/@from != .//cei:issued/cei:dateRange/@to) and (.//cei:issued/cei:dateRange/@from = '99999999')">
                      <xsl:variable name="date_from" select=".//cei:issued/cei:dateRange/@from" />
                      <xsl:variable name="date_to" select=".//cei:issued/cei:dateRange/@to" />
                      <xsl:variable name="mm">
                        <xsl:value-of select="substring($date_from,5,2)" />
                      </xsl:variable>
                      <xsl:variable name="dd">
                        <xsl:value-of select="substring($date_from,7,2)" />
                      </xsl:variable>
                      <xsl:variable name="yyyy">
                        <xsl:value-of select="substring($date_from,1,4)" />
                      </xsl:variable>
                      <xsl:value-of select="$yyyy" />
                      <xsl:value-of select="'-'" />
                      <xsl:value-of select="$mm" />
                      <xsl:value-of select="'-'" />
                      <xsl:value-of select="$dd" />
                      <xsl:text> - </xsl:text>
                      <xsl:variable name="mmt">
                        <xsl:value-of select="substring($date_to,5,2)" />
                      </xsl:variable>
                      <xsl:variable name="ddt">
                        <xsl:value-of select="substring($date_to,7,2)" />
                      </xsl:variable>
                      <xsl:variable name="yyyyt">
                        <xsl:value-of select="substring($date_to,1,4)" />
                      </xsl:variable>
                      <xsl:value-of select="$yyyyt" />
                      <xsl:value-of select="'-'" />
                      <xsl:value-of select="$mmt" />
                      <xsl:value-of select="'-'" />
                      <xsl:value-of select="$ddt" />
                    </xsl:when>
                    <xsl:otherwise />
                  </xsl:choose>
                </xsl:otherwise>
              </xsl:choose>
            </dcterms:issued>
          </xsl:if>
        </edm:ProvidedCHO>
      </rdf:RDF>
    </oai:metadata>
  </xsl:template>
</xsl:stylesheet>
