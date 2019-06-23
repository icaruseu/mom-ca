<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:atom="http://www.w3.org/2005/Atom" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:i18n="http://www.mom-ca.uni-koeln.de/NS/i18n" xmlns:ead="urn:isbn:1-931666-22-9" xmlns:exist="http://exist.sourceforge.net/NS/exist" id="eadp2html" version="1.0">
    <xsl:template match="ead:p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="ead:emph">
        <xsl:element name="span">
            <xsl:attribute name="title">
                <xsl:value-of select="name(.)"/>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="./@render='italic'">
                    <xsl:attribute name="style">
		                font-style:italic;
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="./@render='underline'">
                    <xsl:attribute name="style">
		               text-decoration:underline;
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="./@render='sub'">
                    <xsl:attribute name="style">
		               vertical-align:sub;
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="./@render='super'">
                    <xsl:attribute name="style">
		               vertical-align:super;
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="style">
		                font-weight:bold;
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="ead:lb">
        <xsl:element name="br">
        </xsl:element>
    </xsl:template>

    <xsl:template match="ead:blockquote">
        <xsl:element name="blockquote">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="ead:table">

        <table border="1">
            <xsl:apply-templates/>
        </table>
    </xsl:template>

    <xsl:template match="ead:tgroup">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="ead:thead">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="ead:tbody">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="ead:row">
        <xsl:element name="tr">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*//ead:tbody/ead:row/ead:entry">
        <xsl:element name="td">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*//ead:thead/ead:row/ead:entry">
        <xsl:element name="th">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="ead:note">
        <xsl:element name="p">
            <xsl:attribute name="class">
                note
            </xsl:attribute>
            <xsl:if test="./@label">
                <xsl:attribute name="id">
                    <xsl:value-of select="./@label"/>
                </xsl:attribute>
                <xsl:value-of select="./@label"/>
                <xsl:text></xsl:text>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <!--not tested-->
    <xsl:template match="ead:dao">
        <xsl:element name="img">
            <xsl:if test="./daodesc/text()">
                <xsl:attribute name="alt">
                    <xsl:value-of select="./daodesc/text()"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="./@xlink:href">
                <xsl:attribute name="src">
                    <xsl:value-of select="./daodesc/text()"/>
                </xsl:attribute>
            </xsl:if>
        </xsl:element>
    </xsl:template>


    <xsl:template match="ead:list">
        <xsl:choose>
            <xsl:when test="./@type='ordered'">
                <xsl:element name="ol">
                    <xsl:attribute name="class">
          		        list
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="ul">
                    <xsl:attribute name="class">
				        list
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="ead:item">
        <xsl:element name="li">
            <xsl:attribute name="class">
                item
            </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="ead:ref | ead:ptr">
        <xsl:choose>
            <xsl:when test="./@xlink:href">
                <xsl:element name="a">
                    <xsl:if test="./@role='footnote' or ./@xlink:role='footnote'">
                        <xsl:attribute name="style">
                            vertical-align:super;
                        </xsl:attribute>
                        <xsl:attribute name="href">
                            <xsl:text>#</xsl:text>
                            <xsl:value-of select="./@xlink:href"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="@target">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="@target"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="span">
                    <xsl:attribute name="title">
                        <xsl:value-of select="name(.)"/>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="ead:extref | ead:extptr | ead:archref |ead:title">
        <xsl:choose>
            <xsl:when test="./@xlink:href">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="./@xlink:href"/>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="span">
                    <xsl:attribute name="title">
                        <xsl:value-of select="name(.)"/>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="ead:bibref">
        <xsl:choose>
            <xsl:when test="./@xlink:href">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="./@xlink:href"/>
                    </xsl:attribute>
                    <xsl:attribute name="class">
                        bibref
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="p">
                    <xsl:attribute name="title">
                        <xsl:value-of select="name(.)"/>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="*">
        <xsl:element name="span">
            <xsl:attribute name="title">
                <xsl:value-of select="name(.)"/>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>