<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ead="urn:isbn:1-931666-22-9" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:fn="http://www.w3.org/2005/xpath-functions" version="1.0" id="post-script">    
 
<!--  Einfache rekursive Kopierung - aufgrund der Überprüfung der Inhalte unbrauchbar
    <xsl:template match="@*|node()">
            <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
            </xsl:copy> 
    </xsl:template>
-->
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="ead:ead">
        <ead:ead>
            <xsl:apply-templates/>
        </ead:ead>
    </xsl:template>
    <xsl:template match="ead:eadheader">
        <ead:eadheader>
            <ead:eadid/>
            <ead:filedesc>
                <ead:titlestmt>
                    <ead:titleproper/>
                </ead:titlestmt>
            </ead:filedesc>
        </ead:eadheader>
    </xsl:template>

    <!--################# FOND ###################-->
    <xsl:template match="ead:archdesc">
        <ead:archdesc>
            <xsl:attribute name="level">otherlevel</xsl:attribute>
            <xsl:apply-templates/>
        </ead:archdesc>
    </xsl:template>
    <xsl:template match="ead:dsc">
        <ead:dsc>
            <xsl:apply-templates/>
        </ead:dsc>
    </xsl:template>
    <xsl:template match="ead:archdesc/ead:did">
        <ead:did>
            <ead:abstract/>
        </ead:did>
    </xsl:template>
    <xsl:template match="ead:c[@level='fonds']">
        <xsl:element name="ead:c">
            <xsl:attribute name="level">fonds</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="ead:c[@level='fonds']/ead:did">
        <ead:did>
            <xsl:apply-templates/>
        </ead:did>
    </xsl:template>
    <xsl:template match="ead:c[@level='fonds']/ead:did/ead:unitdate">
        <!--Bestandslaufzeit wird in VDU nicht gespeichert sondern aus den Daten der Urkunden dynamisch ermittelt-->
    </xsl:template>
    
    <!-- Tags bis hierhin sind notwendig und dürfen auch leer sein -->
    
    <!-- Nachfolgende Tags jeweils nach Inhalt prüfen und bei fehlendem Inhalt entsprechend löschen -->
    <xsl:template match="ead:bioghist">
        <xsl:if test="./ead:head/text() or ./ead:p/text()">
            <ead:bioghist>
                <xsl:if test="./ead:head/text()">
                    <ead:head>
                        <xsl:value-of select="./ead:head/text()"/>
                    </ead:head>
                </xsl:if>
                <xsl:if test="./ead:p/text()">
                    <ead:p>
                        <xsl:value-of select="./ead:p/text()"/>
                    </ead:p>
                </xsl:if>
            </ead:bioghist>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:custodhist">
        <xsl:if test="./ead:head/text() or ./ead:p/text()">
            <ead:custodhist>
                <xsl:if test="./ead:head/text()">
                    <ead:head>
                        <xsl:value-of select="./ead:head/text()"/>
                    </ead:head>
                </xsl:if>
                <xsl:if test="./ead:p/text()">
                    <ead:p>
                        <xsl:value-of select="./ead:p/text()"/>
                    </ead:p>
                </xsl:if>
            </ead:custodhist>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:c[@level='fonds']/ead:did/ead:bibliography">
        <xsl:if test="./ead:head/text() or ./ead:bibref/text()">
            <ead:bibliography>
                <xsl:if test="./ead:head/text()">
                    <ead:head>
                        <xsl:value-of select="./ead:head/text()"/>
                    </ead:head>
                </xsl:if>
                <xsl:variable name="x" select="./ead:bibref"/>
                <xsl:for-each select="x">
                    <xsl:if test="./text()">
                        <ead:bibref>
                            <xsl:value-of select="./text()"/>
                        </ead:bibref>
                    </xsl:if>
                </xsl:for-each>
            </ead:bibliography>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:odd">
        <xsl:if test="./ead:head/text() or ./ead:p/text()">
            <ead:odd>
                <xsl:if test="./ead:head/text()">
                    <ead:head>
                        <xsl:value-of select="./ead:head/text()"/>
                    </ead:head>
                </xsl:if>
                <xsl:if test="./ead:p/text()">
                    <ead:p>
                        <xsl:value-of select="./ead:p/text()"/>
                    </ead:p>
                </xsl:if>
            </ead:odd>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:accruals">
        <xsl:if test="./ead:head/text() or ./ead:p/text()">
            <ead:accruals>
                <xsl:if test="./ead:head/text()">
                    <ead:head>
                        <xsl:value-of select="./ead:head/text()"/>
                    </ead:head>
                </xsl:if>
                <xsl:if test="./ead:p/text()">
                    <ead:p>
                        <xsl:value-of select="./ead:p/text()"/>
                    </ead:p>
                </xsl:if>
            </ead:accruals>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:appraisal">
        <xsl:if test="./ead:head/text() or ./ead:p/text()">
            <ead:appraisal>
                <xsl:if test="./ead:head/text()">
                    <ead:head>
                        <xsl:value-of select="./ead:head/text()"/>
                    </ead:head>
                </xsl:if>
                <xsl:if test="./ead:p/text()">
                    <ead:p>
                        <xsl:value-of select="./ead:p/text()"/>
                    </ead:p>
                </xsl:if>
            </ead:appraisal>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:arrangement">
        <xsl:if test="./ead:head/text() or ./ead:p/text()">
            <ead:arrangement>
                <xsl:if test="./ead:head/text()">
                    <ead:head>
                        <xsl:value-of select="./ead:head/text()"/>
                    </ead:head>
                </xsl:if>
                <xsl:if test="./ead:p/text()">
                    <ead:p>
                        <xsl:value-of select="./ead:p/text()"/>
                    </ead:p>
                </xsl:if>
            </ead:arrangement>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:scopecontent">
        <xsl:if test="./ead:head/text() or ./ead:p/text()">
            <ead:scopecontent>
                <xsl:if test="./ead:head/text()">
                    <ead:head>
                        <xsl:value-of select="./ead:head/text()"/>
                    </ead:head>
                </xsl:if>
                <xsl:if test="./ead:p/text()">
                    <ead:p>
                        <xsl:value-of select="./ead:p/text()"/>
                    </ead:p>
                </xsl:if>
            </ead:scopecontent>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:processinfo">
        <xsl:if test="./ead:head/text() or ./ead:p/text()">
            <ead:processinfo>
                <xsl:if test="./ead:head/text()">
                    <ead:head>
                        <xsl:value-of select="./ead:head/text()"/>
                    </ead:head>
                </xsl:if>
                <xsl:if test="./ead:p/text()">
                    <ead:p>
                        <xsl:value-of select="./ead:p/text()"/>
                    </ead:p>
                </xsl:if>
            </ead:processinfo>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:relatedmaterial">
        <xsl:if test="./ead:head/text() or ./ead:p/text()">
            <ead:relatedmaterial>
                <xsl:if test="./ead:head/text()">
                    <ead:head>
                        <xsl:value-of select="./ead:head/text()"/>
                    </ead:head>
                </xsl:if>
                <xsl:if test="./ead:p/text()">
                    <ead:p>
                        <xsl:value-of select="./ead:p/text()"/>
                    </ead:p>
                </xsl:if>
            </ead:relatedmaterial>
        </xsl:if>
    </xsl:template>
    
    
    
    <!--######################## Charter- Ebene #####################################-->
    <xsl:template match="ead:c[@level='item']">
        <xsl:choose>
            <xsl:when test="./ead:did/ead:unitid/text()">
                <xsl:element name="ead:c">
                    <xsl:attribute name="level">item</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
        </xsl:choose>
    </xsl:template> 
    
     <!-- Bei fehlendem Datum automatisch einen Platzhalter erzeugen -->
    <xsl:template match="ead:c[@level='item']/ead:did">
        <ead:did>
            <xsl:choose>
                <xsl:when test="./ead:unitdate">
                        <!-- unitdate normalisieren bei doppeltem Tag-->
                    <xsl:choose>
                            <!-- Tags zusammenführen -->
                        <xsl:when test="./ead:unitdate/ead:emph[@altrender]">
                            <xsl:if test="./ead:unitdate/ead:emph[@altrender]">
                                <ead:unitdate>
                                    <xsl:attribute name="normal">
                                        <xsl:value-of select="./ead:unitdate/@normal"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="./ead:unitdate[@normal]"/>
                                    <ead:emph altrender="cei:foreign">
                                        <xsl:value-of select="./ead:unitdate/ead:emph[@altrender]/text()"/>
                                    </ead:emph>
                                </ead:unitdate>
                            </xsl:if>
                        </xsl:when>
                            <!-- kein emph Tag vorhanden, Datum normal ausgeben -->
                        <xsl:otherwise>
                            <ead:unitdate>
                                <xsl:attribute name="normal">
                                    <xsl:value-of select="./ead:unitdate/@normal"/>
                                </xsl:attribute>
                                <xsl:value-of select="./ead:unitdate/text()"/>
                            </ead:unitdate>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                    <!-- Platzhalter einfügen -->
                <xsl:otherwise>
                    <ead:unitdate>
                        <xsl:attribute name="normal">9999-99-99</xsl:attribute>
                    </ead:unitdate>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </ead:did>
    </xsl:template>
    <xsl:template match="ead:unitid[@encodinganalog]">
        <xsl:if test="./text()">
            <ead:unitid>
                <xsl:attribute name="encodinganalog">cei:altIdentifier</xsl:attribute>
                <xsl:apply-templates/>
            </ead:unitid>
        </xsl:if>
    </xsl:template>
    
    <!-- title und id von geschweiften Klammern befreien -->
    <xsl:template match="ead:unittitle">
        <xsl:if test="./text()">
            <ead:unittitle encodinganalog="cei:abstract">
                <xsl:apply-templates/>
            </ead:unittitle>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:unittitle/text()">
        <!-- geschweifte Klammern löschen -->
        <xsl:variable name="x" select="translate(., '{', '')"/>
        <xsl:value-of select="translate($x, '}', '')"/>
    </xsl:template>
    <xsl:template match="ead:unittitle/ead:emph[@altrender]">
        <xsl:if test="./text()">
            <ead:emph altrender="cei:foreign">
                <xsl:value-of select="./text()"/>
            </ead:emph>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:unittitle/ead:emph[@render]">
        <xsl:if test="./text()">
            <ead:emph render="super">
                <xsl:value-of select="./text()"/>
            </ead:emph>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:unittitle/ead:ref">
        <xsl:if test="./text()">
            <xsl:element name="ead:ref">
                <xsl:attribute name="target">
                    <xsl:value-of select="./@target"/>
                </xsl:attribute>
                <xsl:value-of select="./text()"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:unittitle/ead:geogname">
        <xsl:if test="./text()">
            <ead:geogname>
                <xsl:value-of select="./text()"/>
            </ead:geogname>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:unittitle/ead:persname">
        <xsl:if test="./text()">
            <ead:persname>
                <xsl:value-of select="./text()"/>
            </ead:persname>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:unitid">
        <ead:unitid>
            <!-- geschweifte Klammern löschen -->
            <xsl:variable name="x" select="translate(./text(), '{', '')"/>
            <xsl:value-of select="translate($x, '}', '')"/>
        </ead:unitid>
    </xsl:template>
    <xsl:template match="ead:materialspec[@encodinganalog='cei:issuedPlace']">
        <xsl:if test="./text()">
            <ead:materialspec encodinganalog="cei:issuedPlace">
                <xsl:apply-templates/>
            </ead:materialspec>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:materialspec[@encodinganalog='cei:nota']">
        <xsl:if test="./text()">
            <ead:materialspec encodinganalog="cei:nota">
                <xsl:apply-templates/>
            </ead:materialspec>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:materialspec[@encodinganalog='cei:nota']/ead:emph[@altrender='cei:foreign']">
        <xsl:if test="./text()">
            <ead:emph altrender="cei:foreign">
                <xsl:apply-templates/>
            </ead:emph>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:physloc">
        <xsl:if test="./text()">
            <ead:physloc>
                <xsl:apply-templates/>
            </ead:physloc>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:langmaterial">
        <xsl:if test="./text()">
            <ead:langmaterial>
                <xsl:apply-templates/>
            </ead:langmaterial>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:physdesc">
        <xsl:if test="./*">
            <ead:physdesc>
                <xsl:apply-templates/>
            </ead:physdesc>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:dimensions">
        <xsl:if test="./text()">
            <ead:dimensions>
                <xsl:apply-templates/>
            </ead:dimensions>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:physfacet[@encodinganalog='cei:material']">
        <xsl:if test="./text()">
            <ead:physfacet encodinganalog="cei:material">
                <xsl:apply-templates/>
            </ead:physfacet>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:physfacet[@encodinganalog='cei:condition']">
        <xsl:if test="./text()">
            <ead:physfacet encodinganalog="cei:condition">
                <xsl:apply-templates/>
            </ead:physfacet>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:physfacet[@encodinganalog='cei:seal']">
        <xsl:if test="./text()">
            <ead:physfacet encodinganalog="cei:seal">
                <xsl:apply-templates/>
            </ead:physfacet>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:physfacet[@encodinganalog='cei:sealDesc']">
        <xsl:if test="./text()">
            <ead:physfacet encodinganalog="cei:sealDesc">
                <xsl:apply-templates/>
            </ead:physfacet>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:physfacet/ead:emph[@altrender='cei:legend']">
        <xsl:if test="./text()">
            <ead:emph altrender="cei:legend">
                <xsl:apply-templates/>
            </ead:emph>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:physfacet/ead:persname[@encodinganalog='cei:sigillant']">
        <xsl:if test="./text()">
            <ead:persname encodinganalog="cei:sigillant">
                <xsl:apply-templates/>
            </ead:persname>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:physfacet/ead:emph[@altrender='cei:foreign']">
        <xsl:if test="./text()">
            <ead:emph altrender="cei:foreign">
                <xsl:apply-templates/>
            </ead:emph>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:daogrp">
        <xsl:if test="./*">
            <ead:daogrp>
                <xsl:attribute name="xlink:type">
                    <xsl:choose>
                        <xsl:when test="./@type">
                            <xsl:value-of select="./@type"/>
                        </xsl:when>
                        <xsl:otherwise>extended</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:apply-templates/>
            </ead:daogrp>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:daoloc">
        <xsl:if test="not(./@xlink:href='')">
            <xsl:element name="ead:daoloc">
                <xsl:attribute name="xlink:href">
                    <xsl:value-of select="./@xlink:href"/>
                </xsl:attribute>
                <xsl:attribute name="xlink:type">
                    <xsl:choose>
                        <xsl:when test="./@type">
                            <xsl:value-of select="./@type"/>
                        </xsl:when>
                        <xsl:otherwise>locator</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:if test="./@role">
                    <xsl:attribute name="xlink:role">
                        <xsl:value-of select="./@role"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:daodesc">
        <xsl:if test="./ead:p/text()">
            <ead:daodesc>
                <ead:p>
                    <xsl:apply-templates/>
                </ead:p>
            </ead:daodesc>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:materialspec">
        <xsl:if test="./text()">
            <ead:materialspec encodinganalog="cei:traditioform">
                <xsl:apply-templates/>
            </ead:materialspec>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:otherfindaid">
        <xsl:if test="./*">
            <ead:otherfindaid>
                <xsl:apply-templates/>
            </ead:otherfindaid>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:extref">
        <xsl:if test="./text() or not(./@xlink:href='')">
            <xsl:element name="ead:extref">
                <xsl:attribute name="xlink:href">
                    <xsl:value-of select="./@xlink:href"/>
                </xsl:attribute>
                <xsl:attribute name="xlink:type">
                    <xsl:choose>
                        <xsl:when test="./@type">
                            <xsl:value-of select="./@type"/>
                        </xsl:when>
                        <xsl:otherwise>simple</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:if test="./@role">
                    <xsl:attribute name="xlink:role">
                        <xsl:value-of select="./@role"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:odd[@encodinganalog='cei:notarialSub']">
        <xsl:if test="./ead:p/text()">
            <ead:odd encodinganalog="cei:notarialSub">
                <ead:p>
                    <xsl:apply-templates/>
                </ead:p>
            </ead:odd>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:scopecontent[@encodinganalog='cei:issuer']">
        <xsl:if test="./ead:p/ead:persname/text()">
            <ead:scopecontent encodinganalog="cei:issuer">
                <ead:p>
                    <xsl:variable name="x" select="./ead:p/ead:persname"/>
                    <xsl:for-each select="x">
                        <xsl:if test="./text()">
                            <ead:persname>
                                <xsl:value-of select="./text()"/>
                            </ead:persname>
                        </xsl:if>
                    </xsl:for-each>
                </ead:p>
            </ead:scopecontent>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:scopecontent[@encodinganalog='cei:recipient']">
        <xsl:if test="./ead:p/ead:persname/text()">
            <ead:scopecontent encodinganalog="cei:recipient">
                <ead:p>
                    <xsl:variable name="x" select="./ead:p/ead:persname"/>
                    <xsl:for-each select="x">
                        <xsl:if test="./text()">
                            <ead:persname>
                                <xsl:value-of select="./text()"/>
                            </ead:persname>
                        </xsl:if>
                    </xsl:for-each>
                </ead:p>
            </ead:scopecontent>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:odd[@encodinganalog='cei:diplomaticAnalysis']">
        <xsl:if test="./ead:p/text()">
            <ead:odd encodinganalog="cei:diplomaticAnalysis">
                <ead:p>
                    <xsl:apply-templates/>
                </ead:p>
            </ead:odd>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:altformavail">
        <xsl:if test="./ead:p">
            <ead:altformavail>
                <xsl:choose>
                    <xsl:when test="./ead:p[@altrender='cei:traditioform']/text()">
                        <ead:p altrender="cei:traditioform">
                            <xsl:value-of select="./ead:p[@altrender='cei:traditioform']/text()"/>
                        </ead:p>
                    </xsl:when>
                    <xsl:when test="./ead:p/ead:archref/text() or ./ead:p/ead:archref/*">
                        <ead:p>
                            <ead:archref>
                                <xsl:value-of select="./ead:p/ead:archref/text()"/>
                                <xsl:if test="./ead:p/ead:archref/ead:unitid">
                                    <xsl:call-template name="id"/>
                                </xsl:if>
                                <xsl:if test="./ead:p/ead:archref/ead:repository">
                                    <xsl:call-template name="repository"/>
                                </xsl:if>
                            </ead:archref>
                        </ead:p>
                    </xsl:when>
                </xsl:choose>
            </ead:altformavail>
        </xsl:if>
    </xsl:template>
    <xsl:template name="id">
        <xsl:if test="./ead:p/ead:archref/ead:unitid/text()">
            <ead:unitid>
                <xsl:value-of select="./ead:p/ead:archref/ead:unitid/text()"/>
            </ead:unitid>
        </xsl:if>
    </xsl:template>
    <xsl:template name="repository">
        <xsl:if test="./ead:p/ead:archref/ead:repository/text()">
            <ead:repository>
                <xsl:value-of select="./ead:p/ead:archref/ead:repository/text()"/>
            </ead:repository>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:bibliography">
        <xsl:if test="./ead:bibref/text()">
            <xsl:element name="ead:bibliography">
                <xsl:attribute name="encodinganalog">
                    <xsl:value-of select="./@encodinganalog"/>
                </xsl:attribute>
                <ead:bibref>
                    <xsl:value-of select="./ead:bibref/text()"/>
                </ead:bibref>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:note">
        <xsl:if test="./ead:p/text()">
            <xsl:element name="ead:note">
                <xsl:attribute name="encodinganalog">cei:note</xsl:attribute>
                <xsl:attribute name="label">
                    <xsl:value-of select="./@label"/>
                </xsl:attribute>
                <xsl:attribute name="id">
                    <xsl:value-of select="./@id"/>
                </xsl:attribute>
                <ead:p>
                    <xsl:value-of select="./ead:p/text()"/>
                </ead:p>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:index">
        <xsl:if test="./*/*/text()">
            <ead:index>
                <xsl:apply-templates/>
            </ead:index>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:indexentry">
        <ead:indexentry>
            <xsl:apply-templates/>
        </ead:indexentry>
    </xsl:template>
    <xsl:template match="ead:indexentry/ead:persname">
        <xsl:if test="./text()">
            <ead:persname>
                <xsl:apply-templates/>
            </ead:persname>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:indexentry/ead:persname[@encodinganalog='cei:testis']">
        <xsl:if test="./text()">
            <ead:persname encodinganalog="cei:testis">
                <xsl:apply-templates/>
            </ead:persname>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:indexentry/ead:persname[@encodinganalog='cei:testisSigilli']">
        <xsl:if test="./text()">
            <ead:persname encodinganalog="cei:testisSigilli">
                <xsl:apply-templates/>
            </ead:persname>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:indexentry/ead:geogname">
        <xsl:if test="./text()">
            <ead:geogname>
                <xsl:apply-templates/>
            </ead:geogname>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ead:indexentry/ead:subject">
        <xsl:if test="./text()">
            <ead:subject>
                <xsl:apply-templates/>
            </ead:subject>
        </xsl:if>
    </xsl:template>
    
    <!--################# IGNORE #################-->
    <xsl:template match="ead:unitdate"/>
</xsl:stylesheet>