<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:ead="urn:isbn:1-931666-22-9" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:cei="http://www.monasterium.net/NS/cei" xmlns:fn="http://www.w3.org/2005/xpath-functions"
  version="1.0" id="momEAD2cei">
  <!-- Script to convert ead (charters) to cei Modified version GV last change:2013-05-06 
    ToDo: Grundmodell wäre eigentlich, daß nur Elemente bearbeitet werden, die 
    @encodinganalog oder @altrender besitzen oder die explizit aufgerufen werden. 
    ToDo: ead:repository und ead:origination fehlen noch ToDo: Validierungen 
    von mehrfach vorkommenden Feldern, wie behandeln? -->
  <xsl:template match="/">
    <xsl:apply-templates />
  </xsl:template>
  <xsl:template match="ead:ead">
    <cei:cei>
      <xsl:apply-templates />
    </cei:cei>
  </xsl:template>
  <xsl:template match="ead:eadheader">
    <cei:teiHeader>
      <cei:fileDesc>
        <cei:titleStmt>
          <cei:title />
          <cei:author />
        </cei:titleStmt>
      </cei:fileDesc>
    </cei:teiHeader>
  </xsl:template>
  <xsl:template match="ead:archdesc">
    <cei:text type="collection">
      <cei:front />
      <xsl:apply-templates />
    </cei:text>
  </xsl:template>
  <xsl:template match="ead:archdesc/ead:dsc">
    <cei:group>
      <xsl:apply-templates />
    </cei:group>
  </xsl:template>
  <xsl:template match="ead:c[@level='fonds']">
    <xsl:apply-templates />
  </xsl:template>
  <xsl:template match="ead:c[@level='fonds']/ead:did">
    <xsl:apply-templates />
  </xsl:template>

  <!--######################## Charter- Ebene ##################################### -->
  <xsl:template match="ead:*[@level='item' or @level='file']">
    <!-- Validate: Was ist zu tun, wenn es beide Level gibt? -->
    <cei:text>
      <xsl:attribute name="type">charter</xsl:attribute>
      <xsl:attribute name="id">
        <xsl:variable name="i"
          select="translate(./ead:did/ead:unitid[not(@encodinganalog)]/text(), '{', '')" />
        <!-- Validate: Test, ob es nur genau eine unitid gibt! -->
        <xsl:value-of select="translate($i, ' ', '_')" />
      </xsl:attribute>
      <xsl:apply-templates />
    </cei:text>
  </xsl:template>
  <xsl:template match="ead:*[@level='item' or @level='file']/ead:did">
    <cei:front />
    <cei:body>
      <xsl:call-template name="unitid" />
      <cei:chDesc>
        <xsl:call-template name="unittitle" />
        <xsl:apply-templates />
        <!-- ToDo: ead:origination fehlt noch! -->
        <cei:witnessOrig>
          <xsl:if test="./ead:daogrp">
            <xsl:variable name="u" select="./ead:daogrp/ead:daoloc" />
            <xsl:for-each select="$u">
              <xsl:call-template name="daogrp" />
            </xsl:for-each>
          </xsl:if>
          <cei:auth>
            <xsl:if test="..//ead:*[@encodinganalog='cei:seal']">
              <xsl:variable name="k"
                select=".//ead:*[@encodinganalog='cei:seal']" />
              <cei:sealDesc>
                <xsl:for-each select="$k">
                  <cei:seal>
                    <xsl:value-of select="text()" />
                    <xsl:apply-templates />
                  </cei:seal>
                </xsl:for-each>
              </cei:sealDesc>
            </xsl:if>
            <xsl:if test="..//ead:*[@encodinganalog='cei:sealDesc']">
              <xsl:variable name="i"
                select="..//ead:*[@encodinganalog='cei:sealDesc']" />
              <cei:sealDesc>
                <xsl:for-each select="$i">
                  <cei:seal>
                    <xsl:value-of select="text()" />
                    <xsl:apply-templates />
                  </cei:seal>
                </xsl:for-each>
              </cei:sealDesc>
            </xsl:if>
            <xsl:if test="..//ead:*[@encodinganalog='cei:notarialSub']">
              <xsl:variable name="j"
                select="..//ead:*[@encodinganalog='cei:notarialSub']" />
              <cei:notariusDesc>
                <cei:notariusSub>
                  <xsl:for-each select="$j">
                    <xsl:value-of select="text()" />
                    <xsl:apply-templates />
                  </xsl:for-each>
                </cei:notariusSub>
              </cei:notariusDesc>
            </xsl:if>
          </cei:auth>
          <cei:physicalDesc>
            <xsl:if test="..//ead:*[@encodinganalog='cei:material']">
              <xsl:variable name="o"
                select="..//ead:*[@encodinganalog='cei:material']" />
              <xsl:for-each select="$o">
                <xsl:call-template name="material" />
              </xsl:for-each>
            </xsl:if>
            <xsl:if test="..//ead:*[@encodinganalog='cei:condition']">
              <xsl:variable name="t"
                select="..//ead:*[@encodinganalog='cei:condition']" />
              <xsl:for-each select="$t">
                <xsl:call-template name="condition" />
              </xsl:for-each>
            </xsl:if>
            <xsl:if test="./ead:physdesc/ead:dimensions">
              <xsl:variable name="h" select="./ead:physdesc/ead:dimensions" />
              <xsl:for-each select="$h">
                <xsl:call-template name="dimensions" />
              </xsl:for-each>
            </xsl:if>
          </cei:physicalDesc>
          <xsl:if test="..//ead:*[@encodinganalog='cei:nota']">
            <xsl:variable name="m"
              select="..//ead:*[@encodinganalog='cei:nota']" />
            <xsl:for-each select="$m">
              <xsl:call-template name="nota" />
            </xsl:for-each>
          </xsl:if>
          <xsl:if test="..//ead:*[@encodinganalog='cei:traditioform']">
            <xsl:variable name="r"
              select="..//ead:*[@encodinganalog='cei:traditioform']" />
            <xsl:for-each select="$r">
              <xsl:call-template name="traditioform" />
            </xsl:for-each>
          </xsl:if>
          <xsl:if test="../ead:otherfindaid">
            <xsl:variable name="l" select="../ead:otherfindaid" />
            <xsl:for-each select="$l">
              <xsl:call-template name="archId" />
            </xsl:for-each>
          </xsl:if>
        </cei:witnessOrig>
        <cei:witListPar>
          <xsl:if test="../ead:altformavail">
            <xsl:variable name="q" select="../ead:altformavail" />
            <xsl:for-each select="$q">
              <xsl:call-template name="witness" />
            </xsl:for-each>
          </xsl:if>
        </cei:witListPar>
        <xsl:if test="../ead:odd[not(@encodinganalog)] or ../ead:bibliography">
          <!-- noch andere die diplomaticAnalysis vermantsch werden? -->
          <xsl:call-template name="diplomaticAnalysis" />
        </xsl:if>
      </cei:chDesc>
    </cei:body>
  </xsl:template>
  <xsl:template name="unitid">
    <xsl:element name="cei:idno">
      <xsl:value-of select="./ead:unitid/text()" />
    </xsl:element>
  </xsl:template>
  <xsl:template name="oldid">
    <cei:altIdentifier>
      <xsl:value-of
       select="./ead:unitid[@encodinganalog='cei:altIdentifier']/text()" />
    </cei:altIdentifier>
  </xsl:template>
  <xsl:template name="unittitle">
    <xsl:if test="./ead:unittitle">
      <xsl:variable name="b" select="./ead:unittitle" />
      <cei:abstract>
        <xsl:for-each select="$b">
          <xsl:if test="not(./@encodinganalog='cei:abstract')">
            <xsl:apply-templates />
          </xsl:if>
          <xsl:if test="./@encodinganalog='cei:abstract'">
            <xsl:apply-templates />
          </xsl:if>
        </xsl:for-each>
        <xsl:if test="..//ead:*[@encodinganalog='cei:issuer']">
          <xsl:call-template name="issuer" />
        </xsl:if>
        <xsl:if test="..//ead:*[@encodinganalog='cei:recipient']">
          <xsl:call-template name="recipient" />
        </xsl:if>
      </cei:abstract>
    </xsl:if>
  </xsl:template>
  <xsl:template match="ead:unittitle/ead:emph[@altrender]">
    <cei:foreign>
      <xsl:apply-templates />
    </cei:foreign>
  </xsl:template>
  <xsl:template match="ead:unittitle/ead:emph[@render]">
    <cei:sup>
      <xsl:apply-templates />
    </cei:sup>
  </xsl:template>
  <xsl:template match="ead:unittitle/ead:ref">
    <xsl:element name="cei:ref">
      <xsl:attribute name="target">
        <xsl:value-of select="./@target" />
      </xsl:attribute>
      <xsl:value-of select="./text()" />
    </xsl:element>
  </xsl:template>
  <xsl:template match="ead:unittitle/ead:geogname">
    <cei:placeName>
      <xsl:apply-templates />
    </cei:placeName>
  </xsl:template>
  <xsl:template match="ead:unittitle/ead:persname">
    <cei:persName>
      <xsl:apply-templates />
    </cei:persName>
  </xsl:template>
  <xsl:template match="ead:unitdate">
    <cei:issued>
      <cei:placeName>
        <xsl:apply-templates select="ead:*[@encodinganalog='cei:issuedPlace']" />
      </cei:placeName>
      <xsl:choose>
        <xsl:when test="contains(./@normal, '/')">
          <xsl:element name="cei:dateRange">
            <xsl:attribute name="from">
              <xsl:choose>
                <xsl:when
              test="string-length(substring-before(./@normal, '/'))&gt;3">
                  <xsl:value-of
                  select="substring-before(translate(./@normal, '-', ''), '/')" />
                </xsl:when>
                <xsl:otherwise>01010000</xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="to">
              <xsl:choose>
                <xsl:when
                test="string-length(substring-after(./@normal, '/'))&gt;3">
                  <xsl:value-of
                  select="substring-after(translate(./@normal, '-', ''), '/')" />
                </xsl:when>
                <xsl:otherwise>00000000</xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates />
            <xsl:if
              test="../ead:unitdate[@encodinganalog='mom:quoteOriginaldatierung']">
              (
              <xsl:element name="cei:foreign">
                <xsl:apply-templates
                  select="../ead:unitdate[@encodinganalog='mom:quoteOriginaldatierung']" />
              </xsl:element>
              )
            </xsl:if>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="cei:date">
            <xsl:attribute name="value">
              <xsl:value-of select="translate(./@normal, '-', '')" />
            </xsl:attribute>
            <xsl:value-of select="./text()" />
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </cei:issued>
  </xsl:template>
  <xsl:template match="ead:unitdate/ead:emph">
    <xsl:element name="cei:foreign">
      <xsl:apply-templates />
    </xsl:element>
  </xsl:template>
  <xsl:template name="nota">
    <cei:nota>
      <xsl:apply-templates />
    </cei:nota>
  </xsl:template>
  <xsl:template
    match="ead:*[@encodinganalog='cei:nota']/ead:emph[@altrender='cei:foreign']">
    <!-- ToDo: kann man ead:emph -> cei:foreign nicht verallgemeinern? -->
    <cei:foreign>
      <xsl:apply-templates />
    </cei:foreign>
  </xsl:template>
  <xsl:template match="ead:langmaterial">
    <cei:lang_MOM>
      <xsl:apply-templates />
    </cei:lang_MOM>
  </xsl:template>
  <xsl:template name="dimensions">
    <cei:dimensions>
      <xsl:apply-templates />
    </cei:dimensions>
  </xsl:template>
  <xsl:template name="material">
    <cei:material>
      <xsl:apply-templates />
    </cei:material>
  </xsl:template>
  <xsl:template name="condition">
    <cei:condition>
      <xsl:apply-templates />
    </cei:condition>
  </xsl:template>
  <!-- Was machen die folgenden? -->
  <xsl:template match="ead:*[@encodinganalog='cei:seal']/text()" />
  <xsl:template match="ead:*[@encodinganalog='cei:sealDesc']/text()" />
  <xsl:template
    match="ead:*[@encodinganalog='cei:seal' or @encodinganalog='cei:sealDesc']/ead:emph[@altrender='cei:legend']">
    <!-- Kann ich so explizit sein? -->
    <cei:legend>
      <xsl:apply-templates />
    </cei:legend>
  </xsl:template>
  <xsl:template
    match="ead:*[@encodinganalog='cei:seal' or @encodinganalog='cei:sealDesc']/ead:persname[@encodinganalog='cei:sigillant']">
    <cei:sigillant>
      <xsl:apply-templates />
    </cei:sigillant>
  </xsl:template>
  <xsl:template match="ead:physfacet/ead:emph[@altrender='cei:foreign']">
    <cei:foreign>
      <xsl:apply-templates />
    </cei:foreign>
  </xsl:template>
  <xsl:template name="daogrp">
    <cei:figure>
      <xsl:if test="./ead:daodesc/ead:p/text()">
        <xsl:call-template name="daodesc" />
      </xsl:if>
      <xsl:element name="cei:graphic">
        <xsl:attribute name="url">
          <xsl:value-of select="./@xlink:href" />
        </xsl:attribute>
        <xsl:apply-templates />
      </xsl:element>
    </cei:figure>
  </xsl:template>
  <xsl:template name="daodesc">
    <cei:figDesc>
      <xsl:value-of select="./ead:daodesc/ead:p/text()" />
    </cei:figDesc>
  </xsl:template>
  <xsl:template name="traditioform">
    <cei:traditioForm>
      <xsl:apply-templates />
    </cei:traditioForm>
  </xsl:template>

  <!-- did ende -->
  <xsl:template name="archId">
    <cei:archIdentifier>
      <xsl:apply-templates />
    </cei:archIdentifier>
  </xsl:template>
  <xsl:template match="ead:extref">
    <xsl:element name="cei:ref">
      <xsl:attribute name="target">
        <xsl:value-of select="./@xlink:href" />
      </xsl:attribute>
      <xsl:attribute name="type">
        <xsl:value-of select="./@xlink:role" />
      </xsl:attribute>
      <xsl:apply-templates />
    </xsl:element>
  </xsl:template>
  <xsl:template name="issuer">
    <xsl:variable name="x"
      select="..//ead:*[@encodinganalog='cei:issuer']/ead:p/ead:persname" />
    <xsl:for-each select="$x">
      <cei:issuer>
        <xsl:value-of select="./text()" />
      </cei:issuer>
    </xsl:for-each>
  </xsl:template>
  <xsl:template name="recipient">
    <xsl:variable name="x"
      select="..//ead:*[@encodinganalog='cei:recipient']/ead:p/ead:persname" />
    <xsl:for-each select="$x">
      <cei:recipient>
        <xsl:value-of select="./text()" />
      </cei:recipient>
    </xsl:for-each>
  </xsl:template>
  <xsl:template name="diplomaticAnalysis">
    <cei:diplomaticAnalysis>
      <xsl:variable name="y" select="../ead:odd" />
      <xsl:for-each select="$y">
        <xsl:if
          test="./@encodinganalog='cei:diplomaticAnalysis' or not(./@encodinganalog='cei:notarialSub')">
          <cei:p>
            <xsl:if test="./ead:head/text()">
              <xsl:value-of select="./ead:head/text()" />
            </xsl:if>
            <xsl:value-of select="./ead:p/text()" />
          </cei:p>
        </xsl:if>
      </xsl:for-each>
      <xsl:variable name="z" select="../ead:bibliography" />
      <xsl:for-each select="$z">
        <xsl:choose>
          <xsl:when test="./@encodinganalog='cei:listBibl'">
            <cei:listBibl>
              <xsl:for-each select="./ead:bibref">
                <cei:bibl>
                  <xsl:value-of select="." />
                </cei:bibl>
              </xsl:for-each>
            </cei:listBibl>
          </xsl:when>
          <xsl:when test="./@encodinganalog='cei:listBiblEdition'">
            <cei:listBiblEdition>
              <xsl:for-each select="./ead:bibref">
                <cei:bibl>
                  <xsl:value-of select="." />
                </cei:bibl>
              </xsl:for-each>
            </cei:listBiblEdition>
          </xsl:when>
          <xsl:when test="./@encodinganalog='cei:listBiblErw'">
            <cei:listBiblErw>
              <xsl:for-each select="./ead:bibref">
                <cei:bibl>
                  <xsl:value-of select="." />
                </cei:bibl>
              </xsl:for-each>
            </cei:listBiblErw>
          </xsl:when>
          <xsl:when test="./@encodinganalog='cei:listBiblFaksimile'">
            <cei:listBiblFaksimile>
              <xsl:for-each select="./ead:bibref">
                <cei:bibl>
                  <xsl:value-of select="." />
                </cei:bibl>
              </xsl:for-each>
            </cei:listBiblFaksimile>
          </xsl:when>
          <xsl:when test="./@encodinganalog='cei:listBiblRegest'">
            <cei:listBiblRegest>
              <xsl:for-each select="./ead:bibref">
                <cei:bibl>
                  <xsl:value-of select="." />
                </cei:bibl>
              </xsl:for-each>
            </cei:listBiblRegest>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
    </cei:diplomaticAnalysis>
  </xsl:template>
  <xsl:template name="witness">
    <cei:witness>
      <xsl:if test="./ead:p[@altrender='cei:traditioform']/text()">
        <cei:traditioForm>
          <xsl:value-of select="./ead:p[@altrender='cei:traditioform']/text()" />
        </cei:traditioForm>
      </xsl:if>
      <xsl:if test="./ead:p/ead:archref/node()">
        <cei:archIdentifier>
          <xsl:value-of select="./ead:p/ead:archref/text()" />
          <xsl:if test="./ead:p/ead:archref/ead:unitid">
            <cei:idno>
              <xsl:value-of select="./ead:p/ead:archref/ead:unitid/text()" />
            </cei:idno>
          </xsl:if>
          <xsl:if test="./ead:p/ead:archref/ead:repository">
            <cei:archFond>
              <xsl:value-of select="./ead:p/ead:archref/ead:repository/text()" />
            </cei:archFond>
          </xsl:if>
          <xsl:if test="//*[@encodinganalog='cei:altIdentifier']/text()">
            <xsl:call-template name="oldid" />
          </xsl:if>
        </cei:archIdentifier>
      </xsl:if>
    </cei:witness>
  </xsl:template>
  <xsl:template name="note">
    <xsl:variable name="n" select="../ead:note" />
    <cei:divNotes>
      <xsl:for-each select="$n">
        <xsl:element name="cei:note">
          <xsl:attribute name="place">
            <xsl:value-of select="./@label" />
          </xsl:attribute>
          <xsl:attribute name="id">
            <xsl:value-of select="./@id" />
          </xsl:attribute>
          <xsl:value-of select="./ead:p/text()" />
        </xsl:element>
      </xsl:for-each>
    </cei:divNotes>
  </xsl:template>
  <xsl:template match="ead:index">
    <cei:back>
      <xsl:apply-templates />
      <xsl:if test="../ead:note">
        <xsl:call-template name="note" />
      </xsl:if>
    </cei:back>
  </xsl:template>
  <xsl:template match="ead:indexentry">
    <xsl:apply-templates />
  </xsl:template>
  <xsl:template match="ead:indexentry/ead:persname">
    <xsl:choose>
      <xsl:when test="./@encodinganalog='cei:testisSigilli'">
        <xsl:element name="cei:testisSigilli">
          <xsl:apply-templates />
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="cei:persName">
          <xsl:if test="./@encodinganalog='cei:testis'">
            <xsl:attribute name="type">Zeuge</xsl:attribute>
          </xsl:if>
          <xsl:apply-templates />
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="ead:indexentry/ead:geogname">
    <cei:geogName>
      <xsl:apply-templates />
    </cei:geogName>
  </xsl:template>
  <xsl:template match="ead:indexentry/ead:subject">
    <cei:index>
      <xsl:apply-templates />
    </cei:index>
  </xsl:template>

  <!--################# IGNORE ################# -->
  <xsl:template match="ead:*[@encodinganalog='cei:issuedPlace']" />
  <xsl:template match="ead:eadid" />
  <xsl:template match="ead:archdesc/ead:did" />
  <xsl:template match="ead:c[@level='fonds']/ead:did/ead:physloc" />
  <xsl:template match="ead:c[@level='fonds']/ead:did/ead:langmaterial" />
  <xsl:template match="ead:c[@level='fonds']/ead:bioghist" />
  <xsl:template match="ead:c[@level='fonds']/ead:custodhist" />
  <xsl:template match="ead:c[@level='fonds']/*/ead:p" />
  <xsl:template match="ead:c[@level='fonds']/*/ead:head" />
  <xsl:template match="ead:custodhist" />
  <xsl:template match="ead:filedesc" />
  <xsl:template match="ead:profiledesc" />
  <xsl:template match="ead:repository" />
  <xsl:template match="ead:unitid" />
  <xsl:template match="ead:unitid[@encodinganalog]" />
  <xsl:template match="ead:daodesc" />
  <xsl:template match="ead:bibliography" />
  <xsl:template match="ead:note" />
  <xsl:template match="ead:daogrp" />
  <xsl:template match="ead:daoloc" />
  <xsl:template match="ead:materialspec[@encodinganalog='cei:traditioform']" />
  <xsl:template match="ead:physfacet[@encodinganalog='cei:material']" />
  <xsl:template match="ead:physfacet[@encodinganalog='cei:condition']" />
  <xsl:template match="ead:physfacet[@encodinganalog='cei:seal']" />
  <xsl:template match="ead:physfacet[@encodinganalog='cei:sealDesc']" />
  <xsl:template match="ead:altformavail" />
  <xsl:template match="ead:otherfindaid" />
  <xsl:template match="ead:scopecontent[@encodinganalog='cei:issuer']" />
  <xsl:template match="ead:scopecontent[@encodinganalog='cei:recipient']" />
  <xsl:template match="ead:materialspec[@encodinganalog='cei:nota']" />
  <xsl:template match="ead:dimensions" />
  <xsl:template match="ead:odd" />
  <xsl:template match="ead:unittitle" />
  <xsl:template match="ead:p">
    <!-- Es gibt ein paar Fälle, in denen ich die Absätze übernehmen will, 
      nämlich? -->
    <xsl:apply-templates />
  </xsl:template>
  <xsl:template match="*[string-length(@encodinganalog) > 0]"
    priority="-1">
    <xsl:element name="{./@encodinganalog}">
      <xsl:apply-templates />
    </xsl:element>
  </xsl:template>
  <xsl:template match="*[not(@encodinganalog or @level)]"
    priority="-10">
    <xsl:apply-templates select="*[not(text())]" />
  </xsl:template>
</xsl:stylesheet>