<xsl:stylesheet xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:xrx="http://www.monasterium.net/NS/xrx" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:oai="http://www.openarchives.org/OAI/2.0/" xmlns:cei="http://www.monasterium.net/NS/cei" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.0" id="cei2oaidc">
    <xsl:param name="platform-id"/>
    <xsl:template match="/">
        <oai:metadata>
            <oai_dc:dc xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
                <dc:title>
                    <xsl:apply-templates select=".//cei:abstract"/>
                    <xsl:if test=".//cei:sourceDescRegest/cei:bibl/text()">
                        <xsl:text>&#160;[Source:&#160;</xsl:text>
                        <xsl:apply-templates select=".//cei:sourceDescRegest/cei:bibl"/>
                        <xsl:text>&#160;]</xsl:text>
                    </xsl:if>
                </dc:title>
                <dc:type>charter</dc:type>
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
                    <dc:spatial>
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
                    </dc:spatial>
                </xsl:if>
                <xsl:if test=".//cei:issuer/text()">
                    <dc:creator>
                        <xsl:value-of select=".//cei:issuer"/>
                    </dc:creator>
                </xsl:if>
                <dc:type>Physical Object</dc:type>
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
                        <xsl:value-of select=".//cei:notariusSub"/>
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
                <dc:source/>
            </oai_dc:dc>
        </oai:metadata>
    </xsl:template>
</xsl:stylesheet>