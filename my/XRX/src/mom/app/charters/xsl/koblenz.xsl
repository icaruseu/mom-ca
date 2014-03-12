<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ead="urn:isbn:1-931666-22-9" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:fn="http://www.w3.org/2005/xpath-functions" version="1.0" id="koblenz">
    <xsl:param name="fond-id"/>
    <xsl:template match="/">
        <ead:ead xmlns:cei="http://www.monasterium.net/NS/cei" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:isbn:1-931666-22-9 http://sandbox.itineranova.be/rest/db/www/core/res/xsd/vdu-ead.xsd">
            <ead:eadheader>
                <ead:eadid/>
                <ead:filedesc>
                    <ead:titlestmt>
                        <ead:titleproper/>
                    </ead:titlestmt>
                </ead:filedesc>
            </ead:eadheader>
            <ead:archdesc level="otherlevel">
                <ead:did>
                    <ead:abstract/>
                </ead:did>
                <ead:dsc>
                    <ead:c level="fonds">
                        <ead:did>
                            <ead:unitid>
                                <xsl:value-of select=".//Record[1]/Field[1]/Value[1]/text()"/>
                            </ead:unitid>
                            <ead:unittitle>
                                <xsl:value-of select=".//Record[1]/Field[1]/Value[1]/text()"/>
                            </ead:unittitle>
                        </ead:did>
                        <xsl:apply-templates/>
                    </ead:c>
                </ead:dsc>
            </ead:archdesc>
        </ead:ead>
    </xsl:template>
    <xsl:template match="drdoc">
        <xsl:if test=".//Field[Name/text()='Nummer']/Value/text() | .//Field[Name/text()='Unternummer']/Value/text()">
            <ead:c level="item">
                <ead:did>
                    <ead:unitid>
                        <xsl:choose>
                            <xsl:when test=".//Field[Name/text()='Nummer']/Value/text()='0'">
                                <xsl:value-of select=".//Field[Name/text()='Unternummer']/Value/text()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select=".//Field[Name/text()='Nummer']/Value/text()"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </ead:unitid>
                    <xsl:if test=".//Field[Name/text()='Datensatz']/Value/text()">
                        <ead:unitid encodinganalog="cei:altIdentifier">
                            <xsl:value-of select=".//Field[Name/text()='Datensatz']/Value/text()"/>
                        </ead:unitid>
                    </xsl:if>
                    <xsl:if test=".//Field[Name/text()='UInSignatur']/Value/text()">
                        <ead:unitid encodinganalog="cei:altIdentifier">
                            <xsl:value-of select=".//Field[Name/text()='UInSignatur']/Value/text()"/>
                        </ead:unitid>
                    </xsl:if>
                    
                    <!--issuedPlace not handled yet-->
                    <xsl:if test=".//Field[Name/text()='Sortierdatum']/Value/text() | .//Field[Name/text()='Datum']/Value/text()">
                        <ead:unitdate>
                            <xsl:if test=".//Field[Name/text()='Sortierdatum']/Value/text()">
                                <xsl:attribute name="normal">
                                    <xsl:value-of select=".//Field[Name/text()='Sortierdatum']/Value/text()"/>
                                </xsl:attribute>
                            </xsl:if>
                            <xsl:choose>
                                <xsl:when test=".//Field[Name/text()='Datum']/Value/text()">
                                    <xsl:value-of select=".//Field[Name/text()='Datum']/Value/text()"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select=".//Field[Name/text()='Sortierdatum']/Value/text()"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </ead:unitdate>
                    </xsl:if>
                    <xsl:if test=".//Field[Name/text()='Regest']/Value/text()">
                        <ead:unittitle encodinganalog="cei:abstract">
                            <xsl:value-of select=".//Field[Name/text()='Regest']/Value/text()"/>
                        </ead:unittitle>
                    </xsl:if>
                </ead:did>
                <xsl:if test=".//Field[Name/text()='Kanzleivermerke']/Value/text()">
                    <ead:materialspec encodinganalog="cei:nota">
                        <xsl:value-of select=".//Field[Name/text()='Kanzleivermerke']/Value/text()"/>
                    </ead:materialspec>
                </xsl:if>
                <xsl:if test=".//Field[Name/text()='Sprache']/Value/text()">
                    <ead:langmaterial>
                        <xsl:value-of select=".//Field[Name/text()='Sprache']/Value/text()"/>
                    </ead:langmaterial>
                </xsl:if>
                <xsl:if test=".//Field[Name/text()='Siegel']/Value/text() | .//Field[Name/text()='UGroesse']/Value/text()">
                    <ead:physdesc>
                        <xsl:if test=".//Field[Name/text()='UGroesse']/Value/text()">
                            <ead:dimensions>
                                <xsl:value-of select=".//Field[Name/text()='UGroesse']/Value/text()"/>
                            </ead:dimensions>
                        </xsl:if>
                        <xsl:if test=".//Field[Name/text()='Siegel']/Value/text()">
                            <ead:physfacet encodinganalog="cei:sealDesc">
                                <xsl:value-of select=".//Field[Name/text()='Siegel']/Value/text()"/>
                            </ead:physfacet>
                        </xsl:if>
                    </ead:physdesc>
                </xsl:if>
                <xsl:if test=".//Field[Name/text()='bildnummern']/Value/text()">
                    <ead:daogrp>
                        <!--xsl:call-template name="string-replace-all"> 
                            <xsl:with-param name="text" select=".//Field[Name/text()='bildnummern']/Value/text()"/> 
                            <xsl:with-param name="replace" select="TIF"/> 
                            <xsl:with-param name="by" select="JPG"/> 
                        </xsl:call-template-->
                        <xsl:call-template name="tokenize">
                            <xsl:with-param name="string" select=".//Field[Name/text()='bildnummern']/Value/text()"/>
                        </xsl:call-template>
                        
                        <!--XSLT 2.0 neccessary?-->
                        <!--xsl:for-each select="fn:tokenize(.//Field[Name/text()='bildnummern']/Value/text(), ',')">-->  <!--fn:replace(//Field[Name/text()='bildnummern']/Value/text(), 'TIF', 'JPG'-->
                        <!--ead:daoloc>
                            <xsl:attribute name="xlink:href">
                                <xsl:value-of select="."/>
                            </xsl:attribute>
                            <ead:daodesc/>
                        </ead:daoloc>
                        </xsl:for-each-->
                    </ead:daogrp>
                </xsl:if>
                <xsl:if test=".//Field[Name/text()='Ueberlieferungsa']/Value/text()">
                    <ead:materialspec encodinganalog="cei:traditioform">
                        <xsl:value-of select=".//Field[Name/text()='Ueberlieferungsa']/Value/text()"/>
                    </ead:materialspec>
                </xsl:if>
                <xsl:if test=".//Field[Name/text()='Unterschriften']/Value/text()">
                    <ead:odd encodinganalog="cei:notarialSub">
                        <ead:p>
                            <xsl:value-of select=".//Field[Name/text()='Unterschriften']/Value/text()"/>
                        </ead:p>
                    </ead:odd>
                </xsl:if>
                <!--Notarszeichen = Sonstige Beglaubigung-->
                <xsl:if test=".//Field[Name/text()='Notarszeichen']/Value/text()">
                    <ead:odd encodinganalog="cei:notarialSub">
                        <ead:p>
                            <xsl:value-of select=".//Field[Name/text()='Notarszeichen']/Value/text()"/>
                        </ead:p>
                    </ead:odd>
                </xsl:if>
                <xsl:if test=".//Field[Name/text()='Bemerkungen']/Value/text()">
                    <ead:odd encodinganalog="cei:diplomaticAnalysis">
                        <ead:p>
                            <xsl:value-of select=".//Field[Name/text()='Bemerkungen']/Value/text()"/>
                        </ead:p>
                    </ead:odd>
                </xsl:if>
                <xsl:if test=".//TField[TName/text()='Drucke']/TValue/text()">
                    <ead:bibliography encodinganalog="cei:listBibl">
                        <ead:bibref>
                            <xsl:value-of select=".//TField[TName/text()='Drucke']/TValue/text()"/>
                        </ead:bibref>
                    </ead:bibliography>
                </xsl:if>
                <xsl:if test=".//TField[TName/text()='Literatur']/TValue/text()">
                    <ead:bibliography encodinganalog="cei:listBibl">
                        <ead:bibref>
                            <xsl:value-of select=".//TField[TName/text()='Literatur']/TValue/text()"/>
                        </ead:bibref>
                    </ead:bibliography>
                </xsl:if>
                
                <!--Not yet handled Fileds -->
                <xsl:if test=".//Field[Name/text()='Urkunde']/Value/text()"/>
                <xsl:if test=".//Field[Name/text()='Rueckvermerke']/Value/text()"/>
                <xsl:if test=".//Field[Name/text()='Ubild']/Value/text()"/>
            </ead:c>
        </xsl:if>
    </xsl:template>
    <xsl:template name="tokenize">
        <xsl:param name="string"/>
        <xsl:param name="delimiter" select="','"/>
        <xsl:choose>
            <xsl:when test="$delimiter and contains($string, $delimiter)">
                <ead:daoloc>
                    <xsl:attribute name="xlink:href">
                        <xsl:call-template name="string-replace-all">
                            <xsl:with-param name="text" select="substring-before($string, $delimiter)"/>
                        </xsl:call-template> 
                        
                        <!--xsl:value-of select="substring-before($string, $delimiter)" /-->
                    </xsl:attribute>
                </ead:daoloc>
                <xsl:text> </xsl:text>
                <xsl:call-template name="tokenize">
                    <xsl:with-param name="string" select="substring-after($string, $delimiter)"/>
                    <xsl:with-param name="delimiter" select="$delimiter"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <ead:daoloc>
                    <xsl:attribute name="xlink:href">
                        <xsl:call-template name="string-replace-all">
                            <xsl:with-param name="text" select="$string"/>
                        </xsl:call-template>                         
                    
                        <!--xsl:value-of select="$string" /-->
                    </xsl:attribute>
                </ead:daoloc>
                <xsl:text> </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="string-replace-all">
        <xsl:param name="text"/>
        <xsl:param name="replace" select="'TIF'"/>
        <xsl:param name="by" select="'JPG'"/>
        <xsl:choose>
            <xsl:when test="contains($text,$replace)">
                <!--xsl:value-of select="$text"/-->
                <!--xsl:value-of select="$replace"/-->
                <xsl:value-of select="substring-before($text,$replace)"/>
                <xsl:value-of select="$by"/> 

                <!--Recursion not neccarssary-->
                <!--xsl:call-template name="string-replace-all"> 
                    <xsl:with-param name="text" select="substring-after($text,$replace)"/> 
                    <xsl:with-param name="replace" select="$replace"/> 
                    <xsl:with-param name="by" select="$by"/> 
                </xsl:call-template-->
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>