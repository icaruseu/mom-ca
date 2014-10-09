<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xrx="http://www.monasterium.net/NS/xrx" xmlns:cei="http://www.monasterium.net/NS/cei" xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.0" id="notes2pdf">
    <xsl:param name="plattformID"/>
    <xsl:param name="charter-context"/>
    <xsl:variable name="platform-dest">
        <xsl:choose>
            <xsl:when test="$plattformID = 'mom'">http://monasterium.net/mom/</xsl:when>
            <xsl:otherwise>http://www.vdu.uni-koeln.de/vdu/</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:template match="/">
        <fo:root>
            <fo:layout-master-set>
                <fo:simple-page-master master-name="charter" margin-top="2cm" margin-bottom="2cm" margin-left="2cm" margin-right="2cm">
                    <fo:region-body/>
                    <fo:region-before/>
                    <fo:region-after/>
                </fo:simple-page-master>
            </fo:layout-master-set>
            <fo:page-sequence master-reference="charter">
                <fo:static-content flow-name="xsl-region-before">
                    <fo:block margin-top="-1.5cm" font-size="9px" font-family="DejaVuSans" border-bottom="1pt grey solid">
                        <xsl:choose>
                            <xsl:when test="$plattformID = 'mom'">
                                <xsl:text>Monasterium.net&#160;-&#160;</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>VdU&#160;-&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xrx:i18n>
                            <xrx:key>bookmark-notes</xrx:key>
                            <xrx:default>Bookmark notes</xrx:default>
                        </xrx:i18n>
                    </fo:block>
                </fo:static-content>
                <fo:static-content flow-name="xsl-region-after">
                    <fo:block font-size="9px" padding-top="2pt" font-family="DejaVuSans" text-align="center" border-top="1pt grey solid">
                        <xsl:choose>
                            <xsl:when test="$plattformID = 'mom'">
                                <xrx:i18n>
                                    <xrx:key>data-from-monasterium</xrx:key>
                                    <xrx:default>Data from monasterium.net</xrx:default>
                                </xrx:i18n>
                            </xsl:when>
                            <xsl:otherwise>
                                <xrx:i18n>
                                    <xrx:key>data-from-vdu</xrx:key>
                                    <xrx:default>Data from VdU</xrx:default>
                                </xrx:i18n>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>&#160;-&#160;</xsl:text>
                        <fo:basic-link external-destination="{$platform-dest}bookmarks">
                            <xsl:value-of select="$platform-dest"/>
                            <xsl:text>bookmarks</xsl:text>
                        </fo:basic-link>
                    </fo:block>
                </fo:static-content>
                <fo:flow flow-name="xsl-region-body">
                    <fo:block font-family="DejaVuSans">
                        <xsl:for-each select=".//xrx:bookmark-note">
                            <fo:block margin-top="10pt" padding="10pt" text-align="center" font-family="DejaVuSans" margin-bottom="0.5cm" background-color="#f5f5f5" keep-together.within-page="always">
                                <xsl:call-template name="charter-info"/>
                                <xsl:call-template name="date"/>
                                <xsl:call-template name="abstract"/>
                                <xsl:call-template name="bookmark"/>
                                <xsl:call-template name="note"/>
                            </fo:block>
                        </xsl:for-each>
                    </fo:block>
                </fo:flow>
            </fo:page-sequence>
        </fo:root>
    </xsl:template>
    <xsl:template name="charter-info">
        <fo:block margin-top="0.2cm" font-family="DejaVuSans" text-align="left" font-size="10pt">
            <xsl:choose>
                <xsl:when test=".//xrx:charter-context/text() = 'fond'">
                    <fo:inline font-weight="bold">
                        <xrx:i18n>
                            <xrx:key>archive</xrx:key>
                            <xrx:default>Archive</xrx:default>
                        </xrx:i18n>
                    </fo:inline>
                    <xsl:text>:&#160;</xsl:text>
                    <xsl:variable name="archive-id" select=".//xrx:archive-id"/>
                    <fo:basic-link external-destination="'{$platform-dest}{$archive-id}/archive'">
                        <xsl:value-of select="$archive-id"/>
                    </fo:basic-link>
                    <xsl:text>&#160;-&#160;</xsl:text>
                    <fo:inline font-weight="bold">
                        <xrx:i18n>
                            <xrx:key>Fond</xrx:key>
                            <xrx:default>Fond</xrx:default>
                        </xrx:i18n>
                    </fo:inline>
                    <xsl:text>:&#160;</xsl:text>
                    <xsl:variable name="fond-id" select=".//xrx:fond-id"/>
                    <fo:basic-link external-destination="'{$platform-dest}{$archive-id}/{$fond-id}/archive'">
                        <xsl:value-of select="$fond-id"/>
                    </fo:basic-link>
                    <fo:block margin-top="0.2cm">
                        <fo:inline font-weight="bold">
                            <xrx:i18n>
                                <xrx:key>charter</xrx:key>
                                <xrx:default>Charter</xrx:default>
                            </xrx:i18n>
                        </fo:inline>
                        <xsl:text>:&#160;</xsl:text>
                        <xsl:variable name="charter-id" select=".//xrx:charter-id"/>
                        <fo:basic-link external-destination="'{$platform-dest}{$archive-id}/{$fond-id}/{$charter-id}/charter'">
                            <xsl:value-of select="$charter-id"/>
                        </fo:basic-link>
                    </fo:block>
                </xsl:when>
                <xsl:otherwise>
                    <fo:inline font-weight="bold">
                        <xrx:i18n>
                            <xrx:key>collection</xrx:key>
                            <xrx:default>Collection</xrx:default>
                        </xrx:i18n>
                    </fo:inline>
                    <xsl:text>:&#160;</xsl:text>
                    <xsl:variable name="collection-id" select=".//xrx:collection-id"/>
                    <fo:basic-link external-destination="'{$platform-dest}{$collection-id}/collection'">
                        <xsl:value-of select="$collection-id"/>
                    </fo:basic-link>
                    <fo:block margin-top="0.2cm">
                        <fo:inline font-weight="bold">
                            <xrx:i18n>
                                <xrx:key>charter</xrx:key>
                                <xrx:default>Charter</xrx:default>
                            </xrx:i18n>
                        </fo:inline>
                        <xsl:text>:&#160;</xsl:text>
                        <xsl:variable name="charter-id" select=".//xrx:charter-id"/>
                        <fo:basic-link external-destination="'{$platform-dest}{$collection-id}/{$charter-id}/charter'">
                            <xsl:value-of select="$charter-id"/>
                        </fo:basic-link>
                    </fo:block>
                </xsl:otherwise>
            </xsl:choose>
        </fo:block>
    </xsl:template>
    <xsl:template name="date">
        <fo:block margin-top="0.2cm" font-family="DejaVuSans" text-align="left" font-size="10pt">
            <fo:inline font-weight="bold">
                <xrx:i18n>
                    <xrx:key>date</xrx:key>
                    <xrx:default>Date</xrx:default>
                </xrx:i18n>
            </fo:inline>
            <xsl:text>:&#160;</xsl:text>
            <xsl:value-of select=".//cei:date/text()"/>
            <xsl:value-of select=".//cei:dateRange/text()"/>
            <xsl:value-of select=".//cei:date_sort/text()"/>
        </fo:block>
    </xsl:template>
    <xsl:template name="abstract">
        <fo:block margin-top="0.2cm" font-family="DejaVuSans" text-align="left" font-size="10pt">
            <fo:inline font-weight="bold">
                <xrx:i18n>
                    <xrx:key>Abstract</xrx:key>
                    <xrx:default>Abstract</xrx:default>
                </xrx:i18n>
            </fo:inline>
            <xsl:text>:&#160;</xsl:text>
            <xsl:value-of select=".//cei:abstract/text()"/>
        </fo:block>
    </xsl:template>
    <xsl:template name="note">
        <fo:block margin-top="0.2cm" font-family="DejaVuSans" text-align="left" font-size="10pt">
            <fo:inline font-weight="bold">
                <xrx:i18n>
                    <xrx:key>bookmark-note</xrx:key>
                    <xrx:default>Bookmark Note</xrx:default>
                </xrx:i18n>
            </fo:inline>
            <xsl:text>:&#160;</xsl:text>
            <xsl:value-of select=".//xrx:note/text()"/>
        </fo:block>
    </xsl:template>
    <xsl:template name="bookmark">
        <fo:block margin-top="0.2cm" font-family="DejaVuSans" text-align="left" font-size="10pt">
            <fo:inline font-weight="bold">
                <xrx:i18n>
                    <xrx:key>bookmark</xrx:key>
                    <xrx:default>Bookmark</xrx:default>
                </xrx:i18n>
            </fo:inline>
            <xsl:text>:&#160;</xsl:text>
            <xsl:choose>
                <xsl:when test=".//xrx:charter-context/text() = 'fond'">
                    <xsl:variable name="archive-id" select=".//xrx:archive-id"/>
                    <xsl:variable name="fond-id" select=".//xrx:fond-id"/>
                    <xsl:variable name="charter-id" select=".//xrx:charter-id"/>
                    <fo:basic-link external-destination="'{$platform-dest}{$archive-id}/{$fond-id}/{$charter-id}/charter'">
                        <xsl:value-of select="$platform-dest"/>
                        <xsl:value-of select="$archive-id"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="$fond-id"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="$charter-id"/>
                        <xsl:text>/charter</xsl:text>
                    </fo:basic-link>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="collection-id" select=".//xrx:collection-id"/>
                    <xsl:variable name="charter-id" select=".//xrx:charter-id"/>
                    <fo:basic-link external-destination="'{$platform-dest}{$collection-id}/{$charter-id}/charter'">
                        <xsl:value-of select="$platform-dest"/>
                        <xsl:value-of select="$collection-id"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="$charter-id"/>
                        <xsl:text>/charter</xsl:text>
                    </fo:basic-link>
                </xsl:otherwise>
            </xsl:choose>
        </fo:block>
    </xsl:template>
</xsl:stylesheet>