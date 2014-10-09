<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xrx="http://www.monasterium.net/NS/xrx" xmlns:cei="http://www.monasterium.net/NS/cei" xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.0" id="charter2pdf">
    <xsl:param name="arch"/>
    <xsl:param name="fond"/>
    <xsl:param name="collection"/>
    <xsl:param name="id"/>
    <xsl:param name="plattformID"/>
    <xsl:variable name="divNotes" select="//cei:divNotes"/>
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
                        <xsl:choose>
                            <xsl:when test="starts-with($collection, '0')">
                                <xsl:value-of select="$arch"/>
                                <xsl:text>&#160;-&#160;</xsl:text>
                                <xsl:value-of select="$fond"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$collection"/>
                            </xsl:otherwise>
                        </xsl:choose>
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
                        <xsl:choose>
                            <xsl:when test="starts-with($collection, '0')">
                                <xsl:variable name="dest" select="concat('http://monasterium.net/mom/', $arch, '/', $fond, '/', $id, '/charter')"/>
                                <fo:basic-link external-destination="{$dest}">
                                    <xsl:choose>
                                        <xsl:when test="$plattformID = 'mom'">
                                            <xsl:text>http://monasterium.net/mom/</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>http://www.vdu.uni-koeln.de/vdu/</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:value-of select="$arch"/>
                                    <xsl:text>/</xsl:text>
                                    <xsl:value-of select="$fond"/>
                                    <xsl:text>/</xsl:text>
                                    <xsl:value-of select="$id"/>
                                    <xsl:text>/charter</xsl:text>
                                </fo:basic-link>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:variable name="dest" select="concat('http://monasterium.net/mom/', $collection, '/', $id, '/charter')"/>
                                <fo:basic-link external-destination="{$dest}">
                                    <xsl:choose>
                                        <xsl:when test="$plattformID = 'mom'">
                                            <xsl:text>http://monasterium.net/mom/</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>http://www.vdu.uni-koeln.de/vdu/</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:value-of select="$collection"/>
                                    <xsl:text>/</xsl:text>
                                    <xsl:value-of select="$id"/>
                                    <xsl:text>/charter</xsl:text>
                                </fo:basic-link>
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:block>
                </fo:static-content>
                <fo:flow flow-name="xsl-region-body">
                    <fo:block font-family="DejaVuSans">
                        <xsl:for-each select=".//cei:text">
                            <fo:block margin-top="20pt" text-align="center" font-family="DejaVuSans" font-size="18px" margin-bottom="0.5cm">
                                <xsl:value-of select=".//cei:body/cei:idno"/>
                                <xsl:text>.</xsl:text>
                            </fo:block>
                            <xsl:call-template name="abstract"/>
                            <xsl:call-template name="issued"/>
                            <xsl:call-template name="witness"/>
                            <xsl:call-template name="editions"/>
                            <xsl:if test="//cei:graphic/@url">
                                <xsl:call-template name="image"/>
                            </xsl:if>
                            <xsl:call-template name="diplAnal"/>
                            <xsl:call-template name="tenor"/>
                            <xsl:call-template name="back"/>
                        </xsl:for-each>
                    </fo:block>
                </fo:flow>
            </fo:page-sequence>
        </fo:root>
    </xsl:template>
    <xsl:template name="abstract">
        <xsl:variable name="sourceDescRegest" select="//cei:sourceDescRegest"/>
        <fo:block margin-left="5pt" font-family="DejaVuSans">
            <xsl:apply-templates select=".//cei:abstract"/>
            <xsl:if test="$sourceDescRegest/cei:bibl/text()">
                <fo:block font-size="8pt" font-family="DejaVuSans" margin-left="10pt">
                    <xsl:text>&#160;-&#160;(</xsl:text>
                    <xrx:i18n>
                        <xrx:key>source</xrx:key>
                        <xrx:default>Source</xrx:default>
                    </xrx:i18n>
                    <xsl:text>:&#160;</xsl:text>
                    <xsl:value-of select="$sourceDescRegest/cei:bibl"/>
                    <xsl:text>)&#160;-&#160;</xsl:text>
                </fo:block>
            </xsl:if>
        </fo:block>
    </xsl:template>
    <xsl:template name="issued">
    		<xsl:variable name="issued" select="//cei:issued"/>
        <fo:block margin-top="0.2cm" font-family="DejaVuSans" text-align="right">
            <xsl:choose>
                <xsl:when test="$issued/cei:placeName">
                    <xsl:value-of select="$issued/cei:placeName"/>
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="$issued/cei:date|$issued/cei:dateRange"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$issued/cei:date|$issued/cei:dateRange"/>
                </xsl:otherwise>
            </xsl:choose>
        </fo:block>
    </xsl:template>
    <xsl:template name="witness">
        <xsl:for-each select="//cei:witnessOrig|//cei:witListPar/cei:witness">
            <xsl:choose>
                <xsl:when test=".//text()">
                    <fo:block font-size="10pt" font-style="oblique" font-family="DejaVuSans" margin-left="30pt" margin-top="5pt" line-stacking-strategy="font-height">
                        <xsl:value-of select="./cei:traditioForm"/>
                        <xsl:if test="./text()">
                            <xsl:if test="./cei:traditioForm/text()">
                                <xsl:text>&#160;-&#160;</xsl:text>
                            </xsl:if>
                            <xsl:for-each select="./child::node()">
                                <xsl:choose>
                                    <xsl:when test="self::*">
                                        <xsl:if test="self::cei:sup">
                                            <fo:inline font-size="8pt" baseline-shift="super">
                                                <xsl:value-of select="./text()"/>
                                            </fo:inline>
                                        </xsl:if>
                                        <xsl:if test="self::cei:quote">
                                            <fo:inline font-style="normal">
                                                <xsl:value-of select="./text()"/>
                                            </fo:inline>
                                        </xsl:if>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="./cei:archIdentifier">
                            <xsl:if test="./cei:traditioForm/text()">
                                <xsl:text>&#160;-&#160;</xsl:text>
                            </xsl:if>
                            <xrx:i18n>
                                <xrx:key>at</xrx:key>
                                <xrx:default>at</xrx:default>
                            </xrx:i18n>
                            <xsl:text>&#160;</xsl:text>
                            <xsl:value-of select="./cei:archIdentifier"/>
                        </xsl:if>
                        <xsl:if test="./cei:physicalDesc/cei:dimensions">
                            <xsl:if test="./cei:traditioForm/text()|./text()|./cei:archIdentifier/text()">
                                <xsl:text>&#160;-&#160;</xsl:text>
                            </xsl:if>
                            <xsl:value-of select="./cei:physicalDesc/cei:dimensions"/>
                        </xsl:if>
                        <xsl:if test="./cei:physicalDesc/cei:material">
                            <xsl:if test="./cei:traditioForm/text()|./cei:physicalDesc/cei:dimensions/text()|./text()|./cei:archIdentifier/text()">
                                <xsl:text>&#160;-&#160;</xsl:text>
                            </xsl:if>
                            <xsl:value-of select="./cei:physicalDesc/cei:material"/>
                        </xsl:if>
                        <xsl:if test="./cei:physicalDesc/cei:condition">
                            <xsl:if test="./cei:traditioForm/text()|./cei:physicalDesc/cei:dimensions/text()|./cei:physicalDesc/cei:material/text()|./text()|./cei:archIdentifier/text()">
                                <xsl:text>&#160;-&#160;</xsl:text>
                            </xsl:if>
                            <xsl:for-each select="./cei:physicalDesc/cei:condition/child::node()">
                                <xsl:choose>
                                    <xsl:when test="self::*">
                                        <xsl:if test="self::cei:sup">
                                            <fo:inline font-size="8pt" baseline-shift="super">
                                                <xsl:value-of select="./text()"/>
                                            </fo:inline>
                                        </xsl:if>
                                        <xsl:if test="self::cei:quote">
                                            <fo:inline font-style="normal">
                                                <xsl:value-of select="./text()"/>
                                            </fo:inline>
                                        </xsl:if>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="./cei:physicalDesc/cei:nota">
                            <xsl:if test="./cei:traditioForm/text()|./cei:physicalDesc/cei:dimensions/text()|./cei:physicalDesc/cei:material/text()|./cei:physicalDesc/cei:condition/text()|./cei:archIdentifier/text()|./text()">
                                <xsl:text>&#160;-&#160;</xsl:text>
                            </xsl:if>
                            <xsl:for-each select="./cei:physicalDesc/cei:nota/child::node()">
                                <xsl:choose>
                                    <xsl:when test="self::*">
                                        <xsl:if test="self::cei:sup">
                                            <fo:inline font-size="8pt" baseline-shift="super">
                                                <xsl:value-of select="./text()"/>
                                            </fo:inline>
                                        </xsl:if>
                                        <xsl:if test="self::cei:quote">
                                            <fo:inline font-style="normal">
                                                <xsl:value-of select="./text()"/>
                                            </fo:inline>
                                        </xsl:if>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="./cei:auth/cei:sealDesc">
                            <xsl:if test="./cei:traditioForm/text()|./cei:physicalDesc/cei:dimensions/text()|./cei:physicalDesc/cei:material/text()|./cei:physicalDesc/cei:condition/text()|./cei:archIdentifier/text()|./cei:physicalDesc/cei:nota/text()|./text()">
                                <xsl:text>&#160;-&#160;</xsl:text>
                            </xsl:if>
                            <xrx:i18n>
                                <xrx:key>seal-description</xrx:key>
                                <xrx:default>seal description</xrx:default>
                            </xrx:i18n>
                            <xsl:text>:&#160;</xsl:text>
                            <xsl:for-each select="./cei:auth/cei:sealDesc/child::node()">
                                <xsl:choose>
                                    <xsl:when test="self::*">
                                        <xsl:if test="self::cei:sup">
                                            <fo:inline font-size="8pt" baseline-shift="super">
                                                <xsl:value-of select="./text()"/>
                                            </fo:inline>
                                        </xsl:if>
                                        <xsl:if test="self::cei:quote">
                                            <fo:inline font-style="normal">
                                                <xsl:value-of select="./text()"/>
                                            </fo:inline>
                                        </xsl:if>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="./cei:auth/cei:notariusDesc">
                            <xsl:if test="./cei:traditioForm/text()|./cei:physicalDesc/cei:dimensions/text()|./cei:physicalDesc/cei:material/text()|./cei:physicalDesc/cei:condition/text()|./cei:archIdentifier/text()|./cei:physicalDesc/cei:nota/text()|./text()|./cei:auth/cei:sealDesc/text()">
                                <xsl:text>&#160;-&#160;</xsl:text>
                            </xsl:if>
                            <xsl:for-each select="./cei:auth/cei:notariusDesc/child::node()">
                                <xsl:choose>
                                    <xsl:when test="self::*">
                                        <xsl:if test="self::cei:sup">
                                            <fo:inline font-size="8pt" baseline-shift="super">
                                                <xsl:value-of select="./text()"/>
                                            </fo:inline>
                                        </xsl:if>
                                        <xsl:if test="self::cei:quote">
                                            <fo:inline font-style="normal">
                                                <xsl:value-of select="./text()"/>
                                            </fo:inline>
                                        </xsl:if>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="./cei:nota">
                            <xsl:if test="./cei:traditioForm/text()|./cei:physicalDesc/cei:dimensions/text()|./cei:physicalDesc/cei:material/text()|./cei:physicalDesc/cei:condition/text()|./cei:archIdentifier/text()|./cei:physicalDesc/cei:nota/text()|./cei:auth/cei:sealDesc/text()|./text()|./cei:auth/cei:notariusDesc/text()">
                                <xsl:text>&#160;-&#160;</xsl:text>
                            </xsl:if>
                            <xsl:for-each select="./cei:nota/child::node()">
                                <xsl:choose>
                                    <xsl:when test="self::*">
                                        <xsl:if test="self::cei:sup">
                                            <fo:inline font-size="8pt" baseline-shift="super">
                                                <xsl:value-of select="./text()"/>
                                            </fo:inline>
                                        </xsl:if>
                                        <xsl:if test="self::cei:quote">
                                            <fo:inline font-style="normal">
                                                <xsl:value-of select="./text()"/>
                                            </fo:inline>
                                        </xsl:if>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:if>
                    </fo:block>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="editions">
        <xsl:variable name="diplomaticAnalysis" select="//cei:diplomaticAnalysis"/>
    		<xsl:variable name="diplomaticAnalysisBibl" select="$diplomaticAnalysis//cei:bibl"/>
    		<xsl:variable name="diplomaticAnalysisNota" select="$diplomaticAnalysis//cei:nota"/>
        <xsl:if test="$diplomaticAnalysisBibl/text()">
            <fo:block margin-top="10pt" font-size="10pt" font-family="DejaVuSans" font-style="oblique" margin-left="30pt">
                <xsl:for-each select="$diplomaticAnalysisBibl/child::node()">
                    <xsl:choose>
                        <xsl:when test="self::*">
                            <xsl:if test="self::cei:sup">
                                <fo:inline font-size="8pt" baseline-shift="super">
                                    <xsl:value-of select="./text()"/>
                                </fo:inline>
                            </xsl:if>
                            <xsl:if test="self::cei:quote">
                                <fo:inline font-style="normal">
                                    <xsl:value-of select="./text()"/>
                                </fo:inline>
                            </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>&#160;-&#160;</xsl:text>
                </xsl:for-each>
            </fo:block>
        </xsl:if>
        <xsl:if test="$diplomaticAnalysisNota">
            <xsl:if test="$diplomaticAnalysisBibl/text()">
                <xsl:text>&#160;-&#160;</xsl:text>
            </xsl:if>
            <xsl:for-each select="$diplomaticAnalysisNota">
                <xsl:choose>
                    <xsl:when test="self::*">
                        <xsl:if test="self::cei:sup">
                            <fo:inline font-size="8pt" baseline-shift="super">
                                <xsl:value-of select="./text()"/>
                            </fo:inline>
                        </xsl:if>
                        <xsl:if test="self::cei:quote">
                            <fo:inline font-style="normal">
                                <xsl:value-of select="./text()"/>
                            </fo:inline>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>&#160;-&#160;</xsl:text>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    <xsl:template name="image">
        <fo:block font-size="10pt" font-style="oblique" font-family="DejaVuSans" margin-left="30pt" margin-top="5pt">
            <xsl:choose>
                <xsl:when test="$plattformID = 'mom'">
                    <xrx:i18n>
                        <xrx:key>facs-mom-net</xrx:key>
                        <xrx:default>Facs. monasterium.net</xrx:default>
                    </xrx:i18n>
                </xsl:when>
                <xsl:otherwise>
                    <xrx:i18n>
                        <xrx:key>facs-vdu</xrx:key>
                        <xrx:default>Facs. VdU</xrx:default>
                    </xrx:i18n>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>:&#160;</xsl:text>
            <xsl:choose>
                <xsl:when test="starts-with($collection, '0')">
                    <xsl:variable name="dest" select="concat('http://monasterium.net/mom/', $arch, '/', $fond, '/', $id, '/charter')"/>
                    <fo:basic-link external-destination="{$dest}">
                        <xsl:choose>
                            <xsl:when test="$plattformID = 'mom'">
                                <xsl:text>http://monasterium.net/mom/</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>http://www.vdu.uni-koeln.de/vdu/</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:value-of select="$arch"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="$fond"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="$id"/>
                        <xsl:text>/charter</xsl:text>
                    </fo:basic-link>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="dest" select="concat('http://monasterium.net/mom/', $collection, '/', $id, '/charter')"/>
                    <fo:basic-link external-destination="{$dest}">
                        <xsl:choose>
                            <xsl:when test="$plattformID = 'mom'">
                                <xsl:text>http://monasterium.net/mom/</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>http://www.vdu.uni-koeln.de/vdu/</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:value-of select="$collection"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="$id"/>
                        <xsl:text>/charter</xsl:text>
                    </fo:basic-link>
                </xsl:otherwise>
            </xsl:choose>
        </fo:block>
    </xsl:template>
    <xsl:template name="diplAnal">
    		<xsl:variable name="lang_MOM" select="//cei:lang_MOM"/>
    		<xsl:variable name="quoteOriginaldatierung" select="//cei:quoteOriginaldatierung"/>
    		<xsl:variable name="diplomaticAnalysisP" select="//cei:diplomaticAnalysis/cei:p"/>
        <fo:block font-size="10pt" font-style="oblique" font-family="DejaVuSans" margin-left="30pt" margin-top="5pt">
            <xsl:if test="$lang_MOM">
                <xrx:i18n>
                    <xrx:key>lang</xrx:key>
                    <xrx:default>Language</xrx:default>
                </xrx:i18n>
                <xsl:text>:&#160;</xsl:text>
                <xsl:value-of select="$lang_MOM"/>
            </xsl:if>
            <xsl:if test="$quoteOriginaldatierung/text()">
                <xsl:if test="$lang_MOM">
                    <xsl:text>&#160;-&#160;</xsl:text>
                </xsl:if>
                <xrx:i18n>
                    <xrx:key>original-date</xrx:key>
                    <xrx:default>Original Date:</xrx:default>
                </xrx:i18n>
                <xsl:text>:&#160;</xsl:text>
                <xsl:value-of select="$quoteOriginaldatierung"/>
            </xsl:if>
            <xsl:if test="$diplomaticAnalysisP/text()">
                <xsl:if test="$lang_MOM|$quoteOriginaldatierung">
                    <xsl:text>&#160;-&#160;</xsl:text>
                </xsl:if>
                <xsl:for-each select="$diplomaticAnalysisP/child::node()">
                    <xsl:choose>
                        <xsl:when test="self::*">
                            <xsl:if test="self::cei:sup">
                                <fo:inline font-size="8pt" baseline-shift="super">
                                    <xsl:value-of select="./text()"/>
                                </fo:inline>
                            </xsl:if>
                            <xsl:if test="self::cei:quote">
                                <fo:inline font-style="normal">
                                    <xsl:value-of select="./text()"/>
                                </fo:inline>
                            </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:if>
        </fo:block>
    </xsl:template>
    <xsl:template name="tenor">
    		<xsl:variable name="tenor" select="//cei:tenor"/>
    		<xsl:variable name="sourceDescVolltext" select="//cei:sourceDescVolltext/cei:bibl"/>
        <xsl:if test="$tenor/text()">
            <fo:block font-size="10pt" font-family="DejaVuSans" margin-left="5pt" margin-top="10pt" text-indent="10mm" line-height="15pt" line-stacking-strategy="font-height">
                <xsl:apply-templates select="$tenor"/>
            </fo:block>
            <xsl:if test="$sourceDescVolltext/text()">
                <fo:block font-size="8pt" font-family="DejaVuSans" margin-left="10pt">
                    <xsl:text>&#160;-&#160;(</xsl:text>
                    <xrx:i18n>
                        <xrx:key>source</xrx:key>
                        <xrx:default>Source</xrx:default>
                    </xrx:i18n>
                    <xsl:text>:&#160;</xsl:text>
                    <xsl:value-of select="$sourceDescVolltext"/>
                    <xsl:text>)&#160;-&#160;</xsl:text>
                </fo:block>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <xsl:template match="cei:quote">
        <fo:inline font-style="oblique">
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    <xsl:template match="cei:foreign">
        <fo:inline font-style="oblique">
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    <xsl:template match="cei:ref">
        <fo:footnote>
            <fo:inline font-size="8pt" baseline-shift="super" font-family="DejaVuSans">
                <xsl:value-of select="./text()"/>
            </fo:inline>
            <fo:footnote-body>
                <fo:block font-size="8pt" text-align="left" font-style="normal" font-family="DejaVuSans" margin-left="0pt" text-indent="0pt" line-height="12pt">
                    <fo:inline font-size="8pt" baseline-shift="super" font-style="normal">
                        <xsl:value-of select="./text()"/>
                    </fo:inline>
                    <xsl:variable name="x" select="substring(./@target, 2)"/>
                    <xsl:choose>
                        <xsl:when test="$divNotes/cei:note/cei:sup">
                            <xsl:choose>
                                <xsl:when test="$divNotes/cei:note[@n=$x]/cei:sup/following::text() and $divNotes/cei:note[@n=$x]/cei:sup/following::cei:quote">
                                    <xsl:if test="$divNotes/cei:note[@n=$x]/cei:sup/following::node()[1]/self::text()">
                                        <xsl:value-of select="$divNotes/cei:note[@n=$x]/cei:sup/following::node()[1]"/>
                                    </xsl:if>
                                    <xsl:choose>
                                        <xsl:when test="$divNotes/cei:note[@n=$x]/cei:sup/following::cei:quote">
                                            <fo:inline font-style="oblique" font-family="DejaVuSans">
                                                <xsl:value-of select="$divNotes/cei:note[@n=$x]/cei:sup/following::cei:quote"/>
                                            </fo:inline>
                                            <xsl:if test="$divNotes/cei:note[@n=$x]/cei:sup/following::cei:quote/following::node()[1]/self::text()">
                                                <xsl:value-of select="$divNotes/cei:note[@n=$x]/cei:sup/following::cei:quote/following::node()[1]"/>
                                            </xsl:if>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$divNotes/cei:note[@n=$x]/cei:sup/following::node()/text()"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$divNotes/cei:note[@n=$x]/cei:sup/following::text()"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="substring($divNotes/cei:note[substring(./text(),1,string-length($x))=$x]/text(),string-length($x)+1)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:block>
            </fo:footnote-body>
        </fo:footnote>
    </xsl:template>
    <xsl:template match="cei:sup">
        <fo:footnote>
            <fo:inline font-size="8pt" baseline-shift="super" font-family="DejaVuSans">
                <xsl:value-of select="./text()"/>
            </fo:inline>
            <fo:footnote-body>
                <fo:block font-size="8pt" text-align="left" font-style="normal" font-family="DejaVuSans" margin-left="0pt" text-indent="0pt" line-height="12pt">
                    <fo:inline font-size="8pt" baseline-shift="super" font-style="normal">
                        <xsl:value-of select="./text()"/>
                    </fo:inline>
                    <xsl:variable name="x" select="./text()"/>
                    <xsl:choose>
                        <xsl:when test="$divNotes/cei:note/cei:sup">
                            <xsl:choose>
                                <xsl:when test="$divNotes/cei:note/cei:sup[child::text()=$x]/following::text() and $divNotes/cei:note/cei:sup[child::text()=$x]/following::cei:quote">
                                    <xsl:if test="$divNotes/cei:note/cei:sup[child::text()=$x]/following::node()[1]/self::text()">
                                        <xsl:value-of select="$divNotes/cei:note/cei:sup[child::text()=$x]/following::node()[1]"/>
                                    </xsl:if>
                                    <xsl:choose>
                                        <xsl:when test="$divNotes/cei:note/cei:sup[child::text()=$x]/following::cei:quote">
                                            <fo:inline font-style="oblique" font-family="DejaVuSans">
                                                <xsl:value-of select="$divNotes/cei:note/cei:sup[child::text()=$x]/following::cei:quote"/>
                                            </fo:inline>
                                            <xsl:if test="$divNotes/cei:note/cei:sup[child::text()=$x]/following::cei:quote/following::node()[1]/self::text()">
                                                <xsl:value-of select="$divNotes/cei:note/cei:sup[child::text()=$x]/following::cei:quote/following::node()[1]"/>
                                            </xsl:if>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$divNotes/cei:note/cei:sup[child::text()=$x]/following::node()/text()"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$divNotes/cei:note/cei:sup[child::text()=$x]/following::text()"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="substring($divNotes/cei:note[substring(./text(),1,string-length($x))=$x]/text(),string-length($x)+1)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:block>
            </fo:footnote-body>
        </fo:footnote>
    </xsl:template>
    <xsl:template match="cei:expan">
        <xsl:text>(</xsl:text>
        <xsl:value-of select="./text()"/>
        <xsl:text>)</xsl:text>
    </xsl:template>
    <xsl:template match="cei:corr">
        <xsl:value-of select="./text()"/>
        <fo:footnote>
            <fo:inline font-size="8pt" baseline-shift="super">
                <xsl:value-of select="./@n"/>
            </fo:inline>
            <fo:footnote-body>
                <fo:block font-size="8pt" font-family="DejaVuSans" text-align="left" margin-left="0pt" text-indent="0pt" line-height="12pt">
                    <fo:inline font-size="8pt" baseline-shift="super">
                        <xsl:value-of select="./@n"/>
                    </fo:inline>
                    <xsl:text>&#160;</xsl:text>
                    <xsl:value-of select="./@type"/>
                </fo:block>
            </fo:footnote-body>
        </fo:footnote>
    </xsl:template>
    <xsl:template match="cei:add">
        <xsl:value-of select="./text()"/>
        <fo:footnote>
            <fo:inline font-size="8pt" baseline-shift="super">
                <xsl:value-of select="./@n"/>
            </fo:inline>
            <fo:footnote-body>
                <fo:block font-size="8pt" text-align="left" font-family="DejaVuSans" margin-left="0pt" text-indent="0pt" line-height="12pt">
                    <fo:inline font-size="8pt" baseline-shift="super">
                        <xsl:value-of select="./@n"/>
                    </fo:inline>
                    <xsl:text>&#160;</xsl:text>
                    <xsl:value-of select="./@type"/>
                </fo:block>
            </fo:footnote-body>
        </fo:footnote>
    </xsl:template>
    <xsl:template match="cei:del">
        <xsl:value-of select="./text()"/>
        <fo:footnote>
            <fo:inline font-size="8pt" baseline-shift="super">
                <xsl:value-of select="./@n"/>
            </fo:inline>
            <fo:footnote-body>
                <fo:block font-size="8pt" text-align="left" font-family="DejaVuSans" margin-left="0pt" text-indent="0pt" line-height="12pt">
                    <fo:inline font-size="8pt" baseline-shift="super">
                        <xsl:value-of select="./@n"/>
                    </fo:inline>
                    <xsl:text>&#160;</xsl:text>
                    <xsl:value-of select="./@type"/>
                </fo:block>
            </fo:footnote-body>
        </fo:footnote>
    </xsl:template>
    <xsl:template match="cei:gap">
        <xsl:value-of select="./text()"/>
        <fo:footnote>
            <fo:inline font-size="8pt" baseline-shift="super">
                <xsl:value-of select="./@n"/>
            </fo:inline>
            <fo:footnote-body>
                <fo:block font-size="8pt" text-align="left" margin-left="0pt" font-family="DejaVuSans" text-indent="0pt" line-height="12pt">
                    <fo:inline font-size="8pt" baseline-shift="super">
                        <xsl:value-of select="./@n"/>
                    </fo:inline>
                    <xsl:text>&#160;</xsl:text>
                    <xsl:value-of select="./@type"/>
                </fo:block>
            </fo:footnote-body>
        </fo:footnote>
    </xsl:template>
    <xsl:template match="cei:damage">
        <xsl:text>[...]</xsl:text>
        <fo:footnote>
            <fo:inline font-size="8pt" baseline-shift="super">
                <xsl:value-of select="./@n"/>
            </fo:inline>
            <fo:footnote-body>
                <fo:block font-size="8pt" text-align="left" margin-left="0pt" font-family="DejaVuSans" text-indent="0pt" line-height="12pt">
                    <fo:inline font-size="8pt" baseline-shift="super">
                        <xsl:value-of select="./@n"/>
                    </fo:inline>
                    <xsl:text>&#160;</xsl:text>
                    <xsl:value-of select="./text()"/>
                    <xsl:text>&#160;</xsl:text>
                    <xsl:value-of select="./@type"/>
                </fo:block>
            </fo:footnote-body>
        </fo:footnote>
    </xsl:template>
    <xsl:template name="back">
    		<xsl:variable name="persName" select="//cei:persName"/>
    		<xsl:variable name="placeName" select="//cei:placeName"/>
        <xsl:if test=".//cei:back//text() or $persName/@reg or $placeName/@reg">
            <fo:block margin-top="10pt" font-size="8pt" font-family="DejaVuSans" break-before="page">
                <xrx:i18n>
                    <xrx:key>explanations</xrx:key>
                    <xrx:default>Explanations</xrx:default>
                </xrx:i18n>
                <xsl:text>:&#160;</xsl:text>
                <fo:block margin-top="3pt" font-family="DejaVuSans">
                    <xsl:if test="$persName/@reg">
                        <xrx:i18n>
                            <xrx:key>persons</xrx:key>
                            <xrx:default>Persons</xrx:default>
                        </xrx:i18n>
                        <xsl:text>:&#160;</xsl:text>
                    </xsl:if>
                    <xsl:for-each select="$persName">
                        <xsl:if test="./@reg">
                            <xsl:value-of select="./text()"/>
                            <xsl:if test="./@lang">
                                <xsl:text>&#160;(</xsl:text>
                                <xsl:value-of select="./@lang"/>
                                <xsl:text>)</xsl:text>
                            </xsl:if>
                            <xsl:text>&#160;-&#160;</xsl:text>
                            <xsl:value-of select="./@reg"/>
                            <xsl:text>;&#160;</xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </fo:block>
                <fo:block margin-top="3pt" font-family="DejaVuSans">
                    <xsl:if test="$placeName/@reg">
                        <xrx:i18n>
                            <xrx:key>places</xrx:key>
                            <xrx:default>Places</xrx:default>
                        </xrx:i18n>
                        <xsl:text>:&#160;</xsl:text>
                    </xsl:if>
                    <xsl:for-each select="$placeName">
                        <xsl:if test="./@reg">
                            <xsl:value-of select="./text()"/>
                            <xsl:choose>
                                <xsl:when test="./@lang">
                                    <xsl:text>&#160;(</xsl:text>
                                    <xsl:value-of select="./@lang"/>
                                    <xsl:if test="./@type">
                                        <xsl:text>,&#160;</xsl:text>
                                        <xsl:value-of select="./@type"/>
                                    </xsl:if>
                                    <xsl:if test="./@existent">
                                        <xsl:text>,&#160;</xsl:text>
                                        <xsl:choose>
                                            <xsl:when test="./@existent='ja'">
                                                <xrx:i18n>
                                                    <xrx:key>exists</xrx:key>
                                                    <xrx:default>exists</xrx:default>
                                                </xrx:i18n>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xrx:i18n>
                                                    <xrx:key>does-not-exist</xrx:key>
                                                    <xrx:default>does not exist</xrx:default>
                                                </xrx:i18n>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:if>
                                    <xsl:text>)</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:choose>
                                        <xsl:when test="./@type">
                                            <xsl:text>&#160;(</xsl:text>
                                            <xsl:value-of select="./@type"/>
                                            <xsl:if test="./@existent">
                                                <xsl:text>,&#160;</xsl:text>
                                                <xsl:choose>
                                                    <xsl:when test="./@existent='ja'">
                                                        <xrx:i18n>
                                                            <xrx:key>exists</xrx:key>
                                                            <xrx:default>exists</xrx:default>
                                                        </xrx:i18n>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xrx:i18n>
                                                            <xrx:key>does-not-exist</xrx:key>
                                                            <xrx:default>does not exist</xrx:default>
                                                        </xrx:i18n>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:if>
                                            <xsl:text>)</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:if test="./@existent">
                                                <xsl:text>&#160;(</xsl:text>
                                                <xsl:choose>
                                                    <xsl:when test="./@existent='ja'">
                                                        <xrx:i18n>
                                                            <xrx:key>exists</xrx:key>
                                                            <xrx:default>exists</xrx:default>
                                                        </xrx:i18n>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xrx:i18n>
                                                            <xrx:key>does-not-exist</xrx:key>
                                                            <xrx:default>does not exist</xrx:default>
                                                        </xrx:i18n>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                                <xsl:text>)</xsl:text>
                                            </xsl:if>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:text>&#160;-&#160;</xsl:text>
                            <xsl:value-of select="./@reg"/>
                            <xsl:text>;&#160;</xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </fo:block>
            </fo:block>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>