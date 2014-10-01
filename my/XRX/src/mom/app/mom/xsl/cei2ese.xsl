<xsl:stylesheet xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:xrx="http://www.mom-ca.uni-koeln.de/NS/xrx" xmlns:oai="http://www.openarchives.org/OAI/2.0/" xmlns:cei="http://www.monasterium.net/NS/cei" xmlns:europeana="http://www.europeana.eu/schemas/ese/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.0" id="cei2ese">
    <xsl:param name="platform-id"/>
    <xsl:param name="data-provider"/>
    <xsl:param name="base-image-url"/>
    <xsl:template match="/">
        <oai:metadata>
            <europeana:record xmlns="http://www.europeana.eu/schemas/ese/">
                <dc:title>
                    <xsl:apply-templates select=".//cei:abstract"/>
                    <xsl:if test=".//cei:sourceDescRegest/cei:bibl/text()">
                        <xsl:text>&#160;[Source:&#160;</xsl:text>
                        <xsl:apply-templates select=".//cei:sourceDescRegest/cei:bibl"/>
                        <xsl:text>&#160;]</xsl:text>
                    </xsl:if>
                </dc:title>
                <xsl:if test=".//cei:lang_MOM/text()">
                    <dc:language>
                        <xsl:apply-templates select=".//cei:lang_MOM"/>
                    </dc:language>
                </xsl:if>
                <xsl:if test=".//cei:physicalDesc/cei:dimensions/text()">
                    <dc:extent>
                        <xsl:apply-templates select=".//cei:physicalDesc/cei:dimensions"/>
                    </dc:extent>
                </xsl:if>
                <dc:identifier>
                    <xsl:apply-templates select=".//atom:id"/>
                </dc:identifier>
                <xsl:if test=".//cei:issued/cei:placeName/text() or .//cei:abstract/cei:placeName/text() or .//cei:abstract/cei:geogName/text() or .//cei:tenor/cei:placeName/text() or .//cei:tenor/cei:geogName/text()">
                    <dc:spacial>
                        <xsl:if test=".//cei:issued/cei:placeName/text()">
                            <xsl:text>Issued-place-name:&#160;</xsl:text>
                            <xsl:apply-templates select=".//cei:issued/cei:placeName"/>
                        </xsl:if>
                        <xsl:if test=".//cei:abstract/cei:placeName/text() or .//cei:abstract/cei:geogName/text() or .//cei:tenor/cei:placeName/text() or .//cei:tenor/cei:geogName/text()">
                            <xsl:text>;&#160;Place-names:</xsl:text>
                            <xsl:for-each select=".//cei:abstract/cei:placeName">
                                <xsl:value-of select="./text()"/>
                                <xsl:text>,&#160;</xsl:text>
                            </xsl:for-each>
                            <xsl:for-each select=".//cei:abstract/cei:geogName">
                                <xsl:value-of select="./text()"/>
                                <xsl:text>,&#160;</xsl:text>
                            </xsl:for-each>
                            <xsl:for-each select=".//cei:tenor/cei:placeName">
                                <xsl:value-of select="./text()"/>
                                <xsl:text>,&#160;</xsl:text>
                            </xsl:for-each>
                            <xsl:for-each select=".//cei:tenor/cei:geogName">
                                <xsl:value-of select="./text()"/>
                                <xsl:text>,&#160;</xsl:text>
                            </xsl:for-each>
                        </xsl:if>
                    </dc:spacial>
                </xsl:if>
                <xsl:if test=".//cei:issuer/text()">
                    <dc:creator>
                        <xsl:value-of select=".//cei:issuer"/>
                    </dc:creator>
                </xsl:if>
                <xsl:if test=".//cei:witness/cei:physicalDesc/cei:material/text() or .//cei:witness/cei:physicalDesc/condition/text()">
                    <dc:format>
                        <xsl:if test=".//cei:witness/cei:physicalDesc/cei:material/text()">
                            <xsl:text>Material:&#160;</xsl:text>
                            <xsl:apply-templates select=".//cei:witness/cei:physicalDesc/cei:material"/>
                            <xsl:text>;&#160;</xsl:text>
                        </xsl:if>
                        <xsl:if test=".//cei:witness/cei:physicalDesc/cei:condition/text()">
                            <xsl:text>Condition:&#160;</xsl:text>
                            <xsl:apply-templates select=".//cei:witness/cei:physicalDesc/cei:condition"/>
                        </xsl:if>
                    </dc:format>
                </xsl:if>
                <xsl:if test=".//cei:subscriptio or .//cei:notariusSub">
                    <dc:publisher>
                        <xsl:value-of select=".//cei:subscriptio"/>
                        <xsl:if test=".//cei:notariusSub">
                            <xsl:text>,&#160;</xsl:text>
                            <xsl:value-of select=".//cei:notariusSub"/>
                        </xsl:if>
                    </dc:publisher>
                </xsl:if>
                <xsl:if test=".//cei:index">
                    <dc:subject>
                        <xsl:for-each select=".//cei:index">
                            <xsl:value-of select="./text()"/>
                            <xsl:text>,&#160;</xsl:text>
                        </xsl:for-each>
                    </dc:subject>
                </xsl:if>
                <xsl:if test=".//cei:issued/cei:date/text() or .//cei:issued/cei:dateRange/text()">
                    <dc:date>
                        <xsl:text>Issued-date:&#160;</xsl:text>
                        <xsl:choose>
                            <xsl:when test=".//cei:issued/cei:date/@value">
                                <xsl:value-of select=".//cei:issued/cei:date/@value"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test=".//cei:issued/cei:dateRange/@from = .//cei:issued/cei:dateRange/@to">
                                        <xsl:value-of select=".//cei:issued/cei:dateRange/@from"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select=".//cei:issued/cei:dateRange/@from"/>
                                        <xsl:text>&#160;-&#160;</xsl:text>
                                        <xsl:value-of select=".//cei:issued/cei:dateRange/@to"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>&#160;(</xsl:text>
                        <xsl:value-of select="concat(.//cei:issued/cei:dateRange/text(), .//cei:issued/cei:date/text())"/>
                        <xsl:if test=".//cei:quoteOriginaldatierung/text()[1]">
                            <xsl:text>,&#160;"</xsl:text>
                            <xsl:value-of select=".//cei:quoteOriginaldatierung/text()[1]"/>
                        </xsl:if>
                        <xsl:text>)</xsl:text>
                    </dc:date>
                </xsl:if>
                <europeana:provider>
                    <xsl:choose>
                        <xsl:when test="$platform-id = 'mom'">
                            <xsl:text>Monasterium.net</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>VdU - Virtuelles deutsches Urkundennetzwerk</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </europeana:provider>
                <europeana:dataProvider>
                    <xsl:value-of select="$data-provider"/>
                </europeana:dataProvider>
                <europeana:rights>http://creativecommons.org/licenses/by-nc/3.0/</europeana:rights>
                <europeana:type>IMAGE</europeana:type>
                <europeana:isShownAt>
                    <xsl:choose>
                        <xsl:when test="$platform-id = 'mom'">
                            <xsl:text>http://monasterium.net/mom/</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>http://www.vdu.uni-koeln.de/vdu/</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:value-of select="substring-after(.//atom:id, 'charter/')"/>
                    <xsl:text>/charter</xsl:text>
                </europeana:isShownAt>
                <xsl:if test=".//cei:graphic[string-length(@url)&gt;0]">
                    <europeana:isShownBy>
                        <xsl:variable name="charter-image-url" select=".//cei:witnessOrig/cei:figure/cei:graphic[string-length(@url)&gt;0]/@url"/>
                        <xsl:variable name="length-charter-url" select="string-length($charter-image-url)"/>
                        <xsl:variable name="length-base-url" select="string-length($base-image-url)"/>
                        <xsl:choose>
                            <xsl:when test="((substring($base-image-url, $length-base-url)='/') and not(substring($charter-image-url, $length-charter-url)='/')) or (not(substring($base-image-url, $length-base-url)='/') and (substring($charter-image-url, $length-charter-url)='/'))">
                                <xsl:value-of select="$base-image-url"/>
                                <xsl:value-of select="$charter-image-url"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$base-image-url"/>
                                <xsl:text>/</xsl:text>
                                <xsl:value-of select="$charter-image-url"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </europeana:isShownBy>
                </xsl:if>
            </europeana:record>
        </oai:metadata>
    </xsl:template>
</xsl:stylesheet>