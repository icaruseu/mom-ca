<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ead="urn:isbn:1-931666-22-9" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:fn="http://www.w3.org/2005/xpath-functions" version="1.0" id="stuttgart">
    <xsl:param name="fond-id"/>
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="ead">
        <ead:ead>
            <xsl:apply-templates/>
        </ead:ead>
    </xsl:template>
    <xsl:template match="eadheader">
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
    <xsl:template match="archdesc[@level='collection']">
        <ead:archdesc>
            <xsl:attribute name="level">otherlevel</xsl:attribute>
            <ead:did>
                <ead:abstract/>
            </ead:did>
            <ead:dsc>
                <xsl:element name="ead:c">
                    <xsl:attribute name="level">fonds</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </ead:dsc>
        </ead:archdesc>
    </xsl:template>
    <xsl:template match="archdesc[@level='collection']/did">
        <ead:did>
            <!--xsl:element name="ead:unitid">
                <xsl:value-of select="$fond-id"/>
            </xsl:element-->
            <xsl:apply-templates/>
        </ead:did>
    </xsl:template>
    <xsl:template match="archdesc[@level='collection']/did/unitid">
        <xsl:element name="ead:unitid">
            <xsl:attribute name="identifier">
                <xsl:variable name="ida" select="translate(./text(), '{', '')"/>
                <xsl:value-of select="translate($ida, ' ', '_')"/>
            </xsl:attribute>
            <!-- geschweifte Klammern löschen -->
            <xsl:variable name="x" select="translate(./text(), '{', '')"/>
            <xsl:value-of select="translate($x, '}', '')"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="archdesc[@level='collection']/did/unittitle">
        <ead:unittitle>
            <!-- geschweifte Klammern löschen -->
            <xsl:variable name="x" select="translate(./text(), '{', '')"/>
            <xsl:value-of select="translate($x, '}', '')"/>
        </ead:unittitle>
    </xsl:template>
    <xsl:template match="archdesc[@level='collection']/did/unitdate">
        <!--Bestandslaufzeit wird in VDU nicht gespeichert sondern aus den Daten der Urkunden dynamisch ermittelt-->
    </xsl:template>
    <xsl:template match="c[@level='collection']">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="archdesc[@level='collection']/*/head">
        <ead:head>
            <xsl:apply-templates/>
        </ead:head>
    </xsl:template>
    <xsl:template match="archdesc[@level='collection']/*/list/item">
        <ead:p>
            <xsl:apply-templates/>
        </ead:p>
    </xsl:template>
    <xsl:template match="archdesc[@level='collection']/*/p">
        <ead:p>
            <xsl:apply-templates/>
        </ead:p>
    </xsl:template>
    <xsl:template match="archdesc[@level='collection']/accruals">
        <ead:accruals>
            <xsl:apply-templates/>
        </ead:accruals>
    </xsl:template>
    <xsl:template match="archdesc[@level='collection']/appraisal">
        <ead:appraisal>
            <xsl:apply-templates/>
        </ead:appraisal>
    </xsl:template>
    <xsl:template match="archdesc[@level='collection']/altformavail">
        <ead:altformavail>
            <xsl:apply-templates/>
        </ead:altformavail>
    </xsl:template>
    <xsl:template match="archdesc[@level='collection']/arrangement">
        <ead:arrangement>
            <xsl:apply-templates/>
        </ead:arrangement>
    </xsl:template>
    <xsl:template match="archdesc[@level='collection']/bioghist">
        <ead:bioghist>
            <xsl:apply-templates/>
        </ead:bioghist>
    </xsl:template>
    <xsl:template match="archdesc[@level='collection']/scopecontent">
        <ead:custodhist>
            <xsl:apply-templates/>
        </ead:custodhist>
    </xsl:template>
    <xsl:template match="archdesc[@level='collection']/processinfo">
        <ead:processinfo>
            <xsl:apply-templates/>
        </ead:processinfo>
    </xsl:template>
    <xsl:template match="archdesc[@level='collection']/relatedmaterial">
        <ead:relatedmaterial>
            <xsl:apply-templates/>
        </ead:relatedmaterial>
    </xsl:template>
    <xsl:template match="archdesc[@level='collection']/otherfindaid">
        <ead:otherfindaid>
            <xsl:apply-templates/>
        </ead:otherfindaid>
    </xsl:template>


    <!--%%%%%%%%%%%%% IGNORE %%%%%%%%%%%%%%%%%-->

    <!--Folgende Informationen sind redundant und wurden bereits aus der archdesc-Ebene geholt-->
    <xsl:template match="c[@level='collection']/did"/>
    <xsl:template match="c[@level='collection']/did/unitid"/>
    <xsl:template match="c[@level='collection']/did/unittitle"/>
    <xsl:template match="c[@level='collection']/did/unitdate"/>

    <!--Folgende Informationen werden in VDU nicht auf Bestandsebene gespeichert-->
    <xsl:template match="archdesc[@level='collection']/did/repository"/>
    <xsl:template match="archdesc[@level='collection']/did/repository/corpname"/>
    <xsl:template match="archdesc[@level='collection']/did/repository/address"/>
    <xsl:template match="archdesc[@level='collection']/did/repository/address/addressline"/>
    <xsl:template match="c[@level='file' and did/physdesc/genreform='Sachakten']/did"/>
    <xsl:template match="c[@level='file' and did/physdesc/genreform='Sachakten']/otherfindaid"/>
    
    <!--Folgende Informationen werden in VDU nicht benötigt und nur für einen möglichen Reimport ins Ausgangssystem gespeichert-->
    <xsl:template match="archdesc[@level='collection']/did/physdesc">
        <ead:physdesc>
            <xsl:apply-templates/>
        </ead:physdesc>
    </xsl:template>
    <xsl:template match="archdesc[@level='collection']/did/abstract">
        <ead:abstract>
            <xsl:apply-templates/>
        </ead:abstract>
    </xsl:template>
    <xsl:template match="archdesc[@level='collection']/did/note">
        <ead:note>
            <xsl:apply-templates/>
        </ead:note>
    </xsl:template>
    <xsl:template match="archdesc[@level='collection']/did/note/p">
        <ead:p>
            <xsl:apply-templates/>
        </ead:p>
    </xsl:template>
    <xsl:template match="archdesc[@level='collection']/did/origination">
        <ead:origination>
            <xsl:apply-templates/>
        </ead:origination>
    </xsl:template>
    <xsl:template match="archdesc[@level='collection']/did/physloc">
        <ead:physloc>
            <xsl:apply-templates/>
        </ead:physloc>
    </xsl:template>
    <xsl:template match="archdesc[@level='collection']/did/langmaterial">
        <ead:langmaterial>
            <xsl:apply-templates/>
        </ead:langmaterial>
    </xsl:template>
    <xsl:template match="archdesc[@level='collection']/accessrestrict">
        <ead:accessrestrict>
            <xsl:apply-templates/>
        </ead:accessrestrict>
    </xsl:template>
    <xsl:template match="archdesc[@level='collection']/index">
        <ead:index>
            <xsl:apply-templates/>
        </ead:index>
    </xsl:template>
    <xsl:template match="archdesc[@level='collection']/index/indexentry">
        <ead:indexentry>
            <xsl:apply-templates/>
        </ead:indexentry>
    </xsl:template>
    <xsl:template match="archdesc[@level='collection']/index/indexentry/persname">
        <ead:persname>
            <xsl:apply-templates/>
        </ead:persname>
    </xsl:template>
    <xsl:template match="archdesc[@level='collection']/index/indexentry/geogname">
        <ead:geogname>
            <xsl:apply-templates/>
        </ead:geogname>
    </xsl:template>
    <xsl:template match="archdesc[@level='collection']/index/indexentry/subject">
        <ead:subject>
            <xsl:apply-templates/>
        </ead:subject>
    </xsl:template>
    
    <!--################# ZWISCHENEBENEN ###################-->
    <xsl:template match="c[@level='class']">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="c[@level='class']/did">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="c[@level='class']/did/unittitle"/>


    <!--################# CHARTER ###################-->
    <xsl:template match="c[@level='file']">
        <!-- Differenzierung in der Angabe einer Urkunde -->
        <xsl:choose>
            <!-- Urkunde anzeigen -->
            <xsl:when test="did/physdesc/genreform='Urkunden'">
                <ead:c>
                    <xsl:attribute name="level">item</xsl:attribute>
                    <xsl:apply-templates/>
                </ead:c>
            </xsl:when>
            <xsl:otherwise>
                <!-- Informationen doppelt im XML- file, daher nicht anzeigen -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="c[@level='file' and did/physdesc/genreform='Urkunden']/did">
        <ead:did>
            <xsl:choose>
                <xsl:when test="./unitdate">
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:otherwise>
                    <ead:unitdate>
                        <xsl:attribute name="normal">9999-99-99</xsl:attribute>
                    </ead:unitdate>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="daogrp">
                <xsl:with-param name="did" select="."/>
            </xsl:call-template>
            <xsl:call-template name="materialspec">
                <xsl:with-param name="did" select="."/>
            </xsl:call-template>
        </ead:did>
    </xsl:template>
    <xsl:template match="c[@level='file' and did/physdesc/genreform='Urkunden']/did/unitid">
        <xsl:element name="ead:unitid">
            <xsl:attribute name="identifier">
                <xsl:variable name="i" select="translate(./text(), '{', '')"/>
                <xsl:value-of select="translate($i, ' ', '_')"/>
            </xsl:attribute>
            <!-- geschweifte Klammern löschen -->
            <xsl:variable name="x" select="translate(./text(), '{', '')"/>
            <xsl:value-of select="translate($x, '}', '')"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="c[@level='file' and did/physdesc/genreform='Urkunden']/did/unittitle">
        <ead:unittitle encodinganalog="cei:abstract">
            <!-- geschweifte Klammern löschen -->
            <xsl:variable name="y" select="translate(./text(), '{', '')"/>
            <xsl:value-of select="translate($y, '}', '')"/>
        </ead:unittitle>
    </xsl:template>
    <xsl:template match="c[@level='file' and did/physdesc/genreform='Urkunden']/did/unitdate">
        <ead:unitdate>
            <xsl:if test="@normal">
                <!-- Normalisieren des 'normal' - Attributs -->
                <xsl:attribute name="normal">
                    <xsl:value-of select="@normal"/>
                </xsl:attribute>
                <!--xsl:attribute name="normal"><xsl:value-of select="translate(@normal, '-', '')"/></xsl:attribute-->
                <!-- Kein Slash am Anfang und Ende des 'normal' Attributs erlaubt 
                <xsl:if test="starts-with(./@normal,'/')">
                   <xsl:attribute name="normal"><xsl:value-of select="translate(@normal, '/', '')"/></xsl:attribute> 
                </xsl:if>
                <xsl:variable name="t" select="./@normal"/>
                <xsl:if test="substring($t,string-length($t),1)='/'">
                    <xsl:attribute name="normal"><xsl:value-of select="translate(@normal, '/', '')"/></xsl:attribute> 
                </xsl:if>-->
            </xsl:if>
            <xsl:apply-templates/>
        </ead:unitdate>
    </xsl:template>
    <xsl:template match="c[@level='file' and did/physdesc/genreform='Urkunden']/did/physdesc">
        <ead:physdesc>
            <xsl:apply-templates/>
        </ead:physdesc>
    </xsl:template>
    <xsl:template match="c[@level='file' and did/physdesc/genreform='Urkunden']/did/physdesc/genreform">
        <!--<genreform>Urkunden</genreform> nicht notwendig da VDU ausschließlich Urkunden beinhaltet-->
    </xsl:template>
    <xsl:template match="c[@level='file' and did/physdesc/genreform='Urkunden']/did/physdesc/dimensions">
        <ead:dimensions>
            <xsl:apply-templates/>
        </ead:dimensions>
    </xsl:template>
    <xsl:template match="c[@level='file' and did/physdesc/genreform='Urkunden']/did/physdesc/physfacet">
        <ead:physfacet>
            <xsl:choose>
                <xsl:when test="./@type='material' or ./@label='material'">
                    <xsl:attribute name="encodinganalog">cei:material</xsl:attribute>
                </xsl:when>
                <xsl:when test="./@type='Siegel' or ./@label='Siegel'">
                    <xsl:attribute name="encodinganalog">cei:seal</xsl:attribute>
                </xsl:when>
                <xsl:when test="./@type='Erhaltungszustand' or ./@label='Erhaltungszustand'">
                    <xsl:attribute name="encodinganalog">cei:condition</xsl:attribute>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates/>
        </ead:physfacet>
    </xsl:template>
    <xsl:template match="c[@level='file' or @level='collection']/did/langmaterial">
        <ead:langmaterial>
            <xsl:apply-templates/>
        </ead:langmaterial>
    </xsl:template>
    <xsl:template name="daogrp">
        <xsl:param name="did"/>
        <xsl:variable name="daos" select="../daogrp/daoloc"/>
        <xsl:if test="count($daos)&gt;0">
            <ead:daogrp>
                <xsl:attribute name="xlink:type">
                    <xsl:choose>
                        <xsl:when test="./@type">
                            <xsl:value-of select="./@type"/>
                        </xsl:when>
                        <xsl:otherwise>extended</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:for-each select="$daos">
                    <xsl:if test="./@role!='image_thumb' and ./@role!='image_viewer'">
                        <ead:daoloc>
                            <xsl:attribute name="xlink:href">
                                <xsl:value-of select="./@href"/>
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
                            <ead:daodesc>
                                <ead:p>
                                    <xsl:value-of select="./@title"/>
                                </ead:p>
                            </ead:daodesc>
                        </ead:daoloc>
                    </xsl:if>
                </xsl:for-each>
            </ead:daogrp>
        </xsl:if>
    </xsl:template>
    <xsl:template match="c[@level='file' and did/physdesc/genreform='Urkunden']/odd">
        <xsl:choose>
            <xsl:when test="./head/text()='Aussteller'">
                <ead:scopecontent encodinganalog="cei:issuer">
                    <ead:p>
                        <xsl:value-of select="./list/item"/>
                    </ead:p>
                </ead:scopecontent>
            </xsl:when>
            <xsl:when test="./head/text()='Empfänger'">
                <ead:scopecontent encodinganalog="cei:recipient">
                    <ead:p>
                        <xsl:value-of select="./list/item"/>
                    </ead:p>
                </ead:scopecontent>
            </xsl:when>
            <xsl:when test="./head/text()='Vermerke'">
                <ead:odd>
                    <ead:head>Vermerke</ead:head>
                    <ead:p>
                        <xsl:value-of select="./list/item"/>
                    </ead:p>
                </ead:odd>
            </xsl:when>
        </xsl:choose>
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- materialspec muss innerhalb des did- Tag aufgeführt werden -->
    <xsl:template name="materialspec">
        <xsl:param name="did"/>
        <xsl:variable name="materials" select="../odd"/>
        <xsl:for-each select="$materials">
            <xsl:choose>
                <xsl:when test="./head/text()='Überlieferungsart'">
                    <ead:materialspec encodinganalog="cei:traditioform">
                        <xsl:value-of select="./list/item"/>
                    </ead:materialspec>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="c[@level='file' and did/physdesc/genreform='Urkunden']/bibliography">
        <ead:bibliography encodinganalog="cei:listBibl">
            <xsl:apply-templates/>
        </ead:bibliography>
    </xsl:template>
    <xsl:template match="c[@level='file' and did/physdesc/genreform='Urkunden']/bibliography/bibref">
        <ead:bibref>
            <xsl:apply-templates/>
        </ead:bibref>
    </xsl:template>
    <xsl:template match="c[@level='file' and did/physdesc/genreform='Urkunden']/otherfindaid">
        <ead:otherfindaid>
            <xsl:apply-templates/>
        </ead:otherfindaid>
    </xsl:template>
    <xsl:template match="extref">
        <ead:extref>
            <xsl:attribute name="xlink:href">
                <xsl:value-of select="./@href"/>
            </xsl:attribute>
            <xsl:attribute name="xlink:role">
                <xsl:value-of select="./@role"/>
            </xsl:attribute>
            <xsl:attribute name="xlink:type">
                <xsl:choose>
                    <xsl:when test="./@type">
                        <xsl:value-of select="./@type"/>
                    </xsl:when>
                    <xsl:otherwise>simple</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates/>
        </ead:extref>
    </xsl:template>
    <xsl:template match="c[@level='file' and did/physdesc/genreform='Urkunden']/index">
        <ead:index>
            <xsl:apply-templates/>
        </ead:index>
    </xsl:template>
    <xsl:template match="c[@level='file' and did/physdesc/genreform='Urkunden']/index/indexentry">
        <ead:indexentry>
            <xsl:apply-templates/>
        </ead:indexentry>
    </xsl:template>
    <xsl:template match="c[@level='file' and did/physdesc/genreform='Urkunden']/index/indexentry/persname">
        <ead:persname>
            <xsl:apply-templates/>
        </ead:persname>
    </xsl:template>
    <xsl:template match="c[@level='file' and did/physdesc/genreform='Urkunden']/index/indexentry/geogname">
        <ead:geogname>
            <xsl:apply-templates/>
        </ead:geogname>
    </xsl:template>
    <xsl:template match="c[@level='file' and did/physdesc/genreform='Urkunden']/index/indexentry/subject">
        <ead:subject>
            <xsl:apply-templates/>
        </ead:subject>
    </xsl:template>

    <!--Wird gespeichert um Datenverlust beim Reimport in die Systeme zu vermeiden-->
    <xsl:template match="c/accessrestrict">
        <ead:accessrestrict>
            <xsl:apply-templates/>
        </ead:accessrestrict>
    </xsl:template>
    <xsl:template match="c/accessrestrict/p">
        <ead:p>
            <xsl:apply-templates/>
        </ead:p>
    </xsl:template>
    <xsl:template match="c[@level='class']/did/materialspec"/>
    <xsl:template match="odd/head"/>
    <xsl:template match="odd/list"/>
    <xsl:template match="odd/list/item"/>
</xsl:stylesheet>