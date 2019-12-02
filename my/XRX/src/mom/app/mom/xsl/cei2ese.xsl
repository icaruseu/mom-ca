<xsl:stylesheet xmlns:europeana="http://www.europeana.eu/schemas/ese/" xmlns:cei="http://www.monasterium.net/NS/cei" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:oai="http://www.openarchives.org/OAI/2.0/" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xrx="http://www.mom-ca.uni-koeln.de/NS/xrx" xmlns:dcterms="http://purl.org/dc/terms/" version="1.0" id="cei2ese" >
    <xsl:param name="platform-id"/>
    <xsl:param name="data-provider"/>
    <xsl:param name="base-image-url"/>
    <xsl:param name="fond-id"/>
    <xsl:template match="/">
        <oai:metadata>
            <europeana:record xmlns="http://www.europeana.eu/schemas/ese/">
                <dc:title>
                    <xsl:text>Charter: </xsl:text>
                    <xsl:value-of select="$fond-id"/>
                    <xsl:text> </xsl:text>
                    <xsl:apply-templates select=".//cei:idno/@id"/>
                </dc:title>
                <dc:type>
                    <xsl:text>Charter</xsl:text>
                </dc:type>
                <xsl:if test=".//cei:lang_MOM/text()">
                    <dc:language>
                        <xsl:apply-templates select=".//cei:lang_MOM"/>
                    </dc:language>
                </xsl:if>
                <xsl:if test=".//cei:physicalDesc/cei:dimensions/text()">
                    <dcterms:extent>
                        <xsl:apply-templates select=".//cei:physicalDesc/cei:dimensions"/>
                    </dcterms:extent>
                </xsl:if>
                <xsl:if test=".//cei:material/text()">
                    <dcterms:medium>
                        <xsl:apply-templates select=".//cei:material"/>
                    </dcterms:medium>
                </xsl:if>
                <dc:identifier>
                    <xsl:apply-templates select=".//atom:id"/>
                </dc:identifier>
                <xsl:if test=".//cei:abstract/text()">
                    <dc:description>
                        <xsl:apply-templates select=".//cei:abstract"/>
                    </dc:description>
                </xsl:if>
                <xsl:if test=".//cei:placeName/text()">
                    <xsl:for-each select=".//cei:abstract/cei:placeName">
                        <dc:spatial>
                            <xsl:value-of select="./text()"/>
                        </dc:spatial>
                    </xsl:for-each>
                </xsl:if>
                <xsl:if test=".//cei:geogName/text()">
                    <xsl:for-each select=".//cei:geogName">
                        <dc:spatial>
                            <xsl:value-of select="./text()"/>
                        </dc:spatial>
                    </xsl:for-each>
                </xsl:if>
                <xsl:if test=".//cei:issuer/text()">
                    <dc:creator>
                        <xsl:value-of select=".//cei:issuer"/>
                    </dc:creator>
                </xsl:if>
                <xsl:if test=".//cei:witness/cei:physicalDesc/cei:material/text() or .//cei:witness/cei:physicalDesc/condition/text()">
                    <dc:format>
                        <xsl:if test=".//cei:witness/cei:physicalDesc/cei:material/text()">
                            <xsl:text>Material: </xsl:text>
                            <xsl:apply-templates select=".//cei:witness/cei:physicalDesc/cei:material"/>
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                        <xsl:if test=".//cei:witness/cei:physicalDesc/cei:condition/text()">
                            <xsl:text>Condition: </xsl:text>
                            <xsl:apply-templates select=".//cei:witness/cei:physicalDesc/cei:condition"/>
                        </xsl:if>
                    </dc:format>
                </xsl:if>
                <xsl:if test=".//cei:subscriptio or .//cei:notariusSub">
                    <dc:publisher>
                        <xsl:value-of select=".//cei:subscriptio"/>
                        <xsl:if test=".//cei:notariusSub">
                            <xsl:text>, </xsl:text>
                            <xsl:value-of select=".//cei:notariusSub"/>
                        </xsl:if>
                    </dc:publisher>
                </xsl:if>
                <xsl:if test=".//cei:abstract">
                    <xsl:for-each select=".//cei:abstract">
                        <dc:subject>
                            <xsl:value-of select="./text()"/>
                        </dc:subject>
                    </xsl:for-each>  
                </xsl:if>
                <xsl:if test=".//cei:keyword">
                    <xsl:for-each select=".//cei:keyword">
                        <dc:subject>
                            <xsl:value-of select="./text()"/>
                        </dc:subject>
                    </xsl:for-each>  
                </xsl:if>
                <xsl:if test=".//cei:issued/cei:date/text() or .//cei:issued/cei:dateRange/text()">
                    <dc:date><!--
                        <xsl:text>Issued-date: </xsl:text>
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
                                        <xsl:text> - </xsl:text>
                                        <xsl:value-of select=".//cei:issued/cei:dateRange/@to"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text> (</xsl:text>
                        <xsl:value-of select="concat(.//cei:issued/cei:dateRange/text(), .//cei:issued/cei:date/text())"/>
                        <xsl:if test=".//cei:quoteOriginaldatierung/text()[1]">
                            <xsl:text>, "</xsl:text>
                            <xsl:value-of select=".//cei:quoteOriginaldatierung/text()[1]"/>
                        </xsl:if>
                        <xsl:text>)</xsl:text> -->
                        <xsl:choose>
                            <xsl:when test=".//cei:issued/cei:date/@value != 99999999">
                                <xsl:variable name="date" select=".//cei:issued/cei:date/@value"/>
                                <xsl:variable name="mm">
                                   <xsl:value-of select="substring($date,1,2)"/>
                                </xsl:variable>
                             
                                <xsl:variable name="dd">
                                   <xsl:value-of select="substring($date,3,2)"/>
                                </xsl:variable>
                             
                                <xsl:variable name="yyyy">
                                   <xsl:value-of select="substring($date,5,4)"/>
                                </xsl:variable>
                             
                                <xsl:value-of select="$yyyy"/>
                                <xsl:value-of select="'-'"/>
                                <xsl:value-of select="$mm"/>
                                <xsl:value-of select="'-'"/>
                                <xsl:value-of select="$dd"/>
                            
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="(.//cei:issued/cei:dateRange/@from = .//cei:issued/cei:dateRange/@to) and (.//cei:issued/cei:dateRange/@from != '99999999')">
                                        <xsl:variable name="date" select=".//cei:issued/cei:dateRange/@from"/>
                                        <xsl:variable name="mm">
                                             <xsl:value-of select="substring($date,5,2)"/>
                                        </xsl:variable>
                                     
                                        <xsl:variable name="dd">
                                           <xsl:value-of select="substring($date,7,2)"/>
                                        </xsl:variable>
                                     
                                        <xsl:variable name="yyyy">
                                           <xsl:value-of select="substring($date,1,4)"/>
                                        </xsl:variable>
                                     
                                        <xsl:value-of select="$yyyy"/>
                                        <xsl:value-of select="'-'"/>
                                        <xsl:value-of select="$mm"/>
                                        <xsl:value-of select="'-'"/>
                                        <xsl:value-of select="$dd"/>
                                    </xsl:when>

                                    <xsl:when test="(.//cei:issued/cei:dateRange/@from != .//cei:issued/cei:dateRange/@to) and (.//cei:issued/cei:dateRange/@from = '99999999')">
                                        <xsl:variable name="date_from" select=".//cei:issued/cei:dateRange/@from"/>
                                        <xsl:variable name="date_to" select=".//cei:issued/cei:dateRange/@to"/>
                                        <xsl:variable name="mm">
                                            <xsl:value-of select="substring($date_from,5,2)"/>
                                        </xsl:variable>
                                     
                                        <xsl:variable name="dd">
                                           <xsl:value-of select="substring($date_from,7,2)"/>
                                        </xsl:variable>
                                     
                                        <xsl:variable name="yyyy">
                                           <xsl:value-of select="substring($date_from,1,4)"/>
                                        </xsl:variable>
                                     
                                        <xsl:value-of select="$yyyy"/>
                                        <xsl:value-of select="'-'"/>
                                        <xsl:value-of select="$mm"/>
                                        <xsl:value-of select="'-'"/>
                                        <xsl:value-of select="$dd"/>
                                        <xsl:text> - </xsl:text>
                                        <xsl:variable name="mmt">
                                            <xsl:value-of select="substring($date_to,5,2)"/>
                                        </xsl:variable>
                                     
                                        <xsl:variable name="ddt">
                                           <xsl:value-of select="substring($date_to,7,2)"/>
                                        </xsl:variable>
                                     
                                        <xsl:variable name="yyyyt">
                                           <xsl:value-of select="substring($date_to,1,4)"/>
                                        </xsl:variable>
                                     
                                        <xsl:value-of select="$yyyyt"/>
                                        <xsl:value-of select="'-'"/>
                                        <xsl:value-of select="$mmt"/>
                                        <xsl:value-of select="'-'"/>
                                        <xsl:value-of select="$ddt"/>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
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
                        <xsl:variable name="option" select="'/full/1200,/0/default.jpg'"/>
                        <xsl:variable name="charter-image-url" select=".//cei:graphic[string-length(@url)&gt;0]/@url"/>
                        <xsl:value-of select="$base-image-url"/>

                        <xsl:value-of select="$charter-image-url"/>
                        <xsl:value-of select="$option"/>

                    </europeana:isShownBy>
                </xsl:if>
            </europeana:record>
        </oai:metadata>
    </xsl:template>
</xsl:stylesheet>
