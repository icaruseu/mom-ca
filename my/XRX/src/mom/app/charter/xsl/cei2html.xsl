<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:cei="http://www.monasterium.net/NS/cei" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:tei="http://www.tei-c.org/ns/1.0/" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:xrx="http://www.monasterium.net/NS/xrx" id="cei2html" version="2.0">
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="cei:*"/>
    <xsl:variable name="sitemap" select="/xhtml:page/xhtml:div"/>
    <xsl:variable name="cei" select="/xhtml:page//cei:text"/>

    <xsl:template match="/">
        <xsl:apply-templates select="$sitemap"/>
    </xsl:template>

    <xsl:param name="sprache"/>

    <xsl:param name="image-base-uri"/>
    <xsl:param name="controlledvocabularies"/>
    <xsl:param name="personfilelist"/>

    <!--
   ***********************************************************

   New Workaround for i18n terms in xsl:attribute elements:
   These following parameters are used to get i18n:translations used in @title of respective elements
   this is necessary because the eXist transform module skips i18n out of xsl:attribute.
   The workaround is as follows:
   in charter.widget and my-charter widget
   the variable $wcharter:params takes all i18n of this xsl document and translate it.
   The value is stored in parameters/param and are available in the xsl.
   If we want to use a new translation as attribute value,
   a new <xsl:param> has to be introduced and
   at the respective element a <xsl:variable name="i18n><xrx:i18n>....</> is set.
   When calling the $param, the translation will be available.
   I don't know if this takes too much performance!

   *************************************************************
      -->

    <xsl:param name="cei_persName"/>
    <xsl:param name="cei_placeName"/>
    <xsl:param name="cei_geogName"/>
    <xsl:param name="cei_issuer"/>
    <xsl:param name="cei_recipient"/>
    <xsl:param name="cei_measure"/>
    <xsl:param name="cei_pb"/>
    <xsl:param name="cei_handshift"/>
    <xsl:param name="cei_add"/>
    <xsl:param name="cei_expan"/>
    <xsl:param name="cei_corr"/>
    <xsl:param name="cei_sic"/>
    <xsl:param name="cei_reg"/>
    <xsl:param name="cei_del"/>
    <xsl:param name="cei_pict"/>
    <xsl:param name="cei_quote"/>
    <xsl:param name="cei_damage"/>
    <xsl:param name="cei_supplied"/>
    <xsl:param name="cei_unclear"/>


    <!-- function that looks, if there is a controlled vocabulary for cei:index/@indexName and @lemma.
       the Index (Item) has still many exceptions to deal with. Maybe this has to be compound in another way:
       the cases: - cei:index just with a text node
                  - cei:index with @lemma (@sublemma)
                  - with @indexName general
                  (belong to category general)
                  - with @indexName that refers to a controlled vocabulary
                  - with @indexName without controlled vocabulary name
  -->
    <xsl:function name="xrx:getvocabularies">
        <xsl:param name="indexname"/>
        <xsl:param name="lemma"/>
        <xsl:param name="sprache"/>

        <xsl:choose>
            <xsl:when test="$lemma = '' and contains($controlledvocabularies, $indexname)">
                <xsl:variable name="url" select="concat('/db/mom-data/metadata.controlledVocabulary.public/', $indexname, '.xml')"/>
                <xsl:choose>
                    <xsl:when test="document($url)//atom:entry/atom:content//skos:ConceptScheme/skos:prefLabel/@xml:lang= $sprache">
                        <xsl:value-of select="document($url)//atom:entry/atom:content//skos:ConceptScheme/skos:prefLabel[@xml:lang= $sprache]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="document($url)//atom:entry/atom:content//skos:ConceptScheme/skos:prefLabel[1]"/>
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:when>
            <xsl:when test="contains($controlledvocabularies, $indexname)">
                <xsl:variable name="url" select="concat('/db/mom-data/metadata.controlledVocabulary.public/', $indexname, '.xml')"/>

                <xsl:choose>
                    <xsl:when test="document($url)//skos:prefLabel[upper-case(parent::*/@*) = $lemma]/@xml:lang = $sprache">
                        <xsl:value-of select="document($url)//skos:prefLabel[upper-case(parent::*/@*) = $lemma][@xml:lang = $sprache]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="document($url)//skos:prefLabel[upper-case(parent::*/@*) = $lemma][1]"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    <!-- calling main templates to insert CEI content into the sitemap -->
    <xsl:template match="xhtml:insert-idno">
        <span>
            <xsl:value-of select="$cei//cei:body/cei:idno/text()"/>
        </span>
    </xsl:template>
    <xsl:template match="xhtml:insert-imageselect">
        <xsl:call-template name="imageselect"/>
    </xsl:template>
    <xsl:template match="insert-image">
        <xsl:choose>
            <xsl:when test="count($cei//cei:witnessOrig/cei:figure/cei:graphic) > 0">

                <xsl:call-template name="image"/>
            </xsl:when>
            <xsl:otherwise>
                <div class="no-graphic">
                    <xrx:i18n>
                        <xrx:key>no-graphic-available</xrx:key>
                        <xrx:default>No graphic available</xrx:default>
                    </xrx:i18n>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="xhtml:insert-witnesselect">
        <xsl:choose>
            <xsl:when test="count($cei//cei:witList/cei:witness) > 0">
                <xsl:call-template name="witnesselect">
                    <xsl:with-param name="witList" select="$cei//cei:witList/cei:witness"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="xhtml:insert-witList">
        <xsl:param name="count" select="count($cei//cei:witList/cei:witness)"/>
        <xsl:variable name="ordered-witListPar">
            <xsl:for-each select="$cei//cei:witListPar/cei:witness">
                <xsl:sort select="cei:archIdentifier"/>
                <xsl:copy-of select="."/>
            </xsl:for-each>
        </xsl:variable>
        <div data-demoid="e3e02d49-4038-4de9-b9dc-65f1c420b1af" id="witList">
            <xsl:choose>
            <!--   <xsl:when test="$cei//cei:witnessOrig/* != ''">-->
            <xsl:when test="$cei//cei:witnessOrig/cei:traditioForm != '' or                     $cei//cei:witnessOrig/cei:figure != '' or                     $cei//cei:witnessOrig/cei:archIdentifier != '' or                     $cei//cei:witnessOrig/cei:auth != '' or                     $cei//cei:witnessOrig/cei:nota != '' or                     $cei//cei:witnessOrig/cei:rubrum != ''">
                <div data-demoid="e3e02d49-4038-4de9-b9dc-65f1c420b1af">
                    <xsl:for-each select="$cei//cei:witnessOrig">
                        <!-- <xsl:value-of select="position()"/> -->
                        <xsl:call-template name="witness">
                            <xsl:with-param name="num" select="position()"/>
                        </xsl:call-template>

                    </xsl:for-each>
                </div>
            </xsl:when>
            <xsl:when test="                     $cei//cei:witnessOrig/cei:physicalDesc/cei:material != '' or                     $cei//cei:witnessOrig/cei:physicalDesc/cei:dimensions != '' or                     $cei//cei:witnessOrig/cei:physicalDesc/cei:condition != ''">

                <div data-demoid="e3e02d49-4038-4de9-b9dc-65f1c420b1af">

                    <!--<div class="p"> Material wurde 2mal angezeigt!! deshalb das weg
      <ul class="nostyle">
       <xsl:apply-templates select="$cei//cei:witnessOrig/cei:physicalDesc"/>
      <xsl:apply-templates select="$cei//cei:witnessOrig/cei:physicalDesc/cei:material"/>
       <xsl:apply-templates select="$cei//cei:witnessOrig/cei:physicalDesc/cei:dimensions"/>
       <xsl:apply-templates select="$cei//cei:witnessOrig/cei:physicalDesc/cei:condition"/>
       </ul>
       </div> -->
                    <xsl:for-each select="$cei//cei:witnessOrig">

                        <!-- <xsl:value-of select="position()"/> -->
                        <xsl:call-template name="witness">
                            <xsl:with-param name="num" select="position()"/>
                        </xsl:call-template>

                    </xsl:for-each>
                </div>
            </xsl:when>
            <xsl:when test="$cei//cei:witnessOrig/cei:physicalDesc/cei:decoDesc/cei:p != ''">
                <div style="display:none"/>
            </xsl:when>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="$ordered-witListPar/cei:witness//text() != ''">
                <div>
                    <xsl:for-each select="$ordered-witListPar/cei:witness">
                        <!-- <xsl:value-of select="position()"/> -->
                        <xsl:call-template name="witness">
                            <xsl:with-param name="num" select="position()"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <div style="display:none"/>
            </xsl:otherwise>
        </xsl:choose>
        </div>
    </xsl:template>
    <xsl:template match="xhtml:insert-issued">
        <xsl:choose>
            <xsl:when test="$cei//cei:issued//text() != ''">
                <div id="issued">
                    <xsl:call-template name="issued"/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>&#160;</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="xhtml:insert-abstract">
        <xsl:choose>
            <xsl:when test="$cei//cei:chDesc/cei:abstract/node() != ''">
                <!-- <div data-demoid="b8e0ecd8-c6f1-49c3-bae2-c8b0b8c7074c" id="abstract">
        <div class="p" data-demoid="9d6496f6-8645-4dd5-8804-ddf89e4fbc78"> -->
                <xsl:call-template name="abstract"/>
                <!--  </div>
        </div> -->
            </xsl:when>
            <xsl:otherwise>
                <!-- <div class="p" id="abstract" style="display:none"> -->
                <xsl:text>&#160;</xsl:text>
                <!--  </div> -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="xhtml:insert-biblabstract">
        <xsl:choose>
            <xsl:when test="$cei//cei:sourceDesc/cei:sourceDescRegest/cei:bibl != ''">
                <div id="biblabstract">
                    <xrx:i18n>
                        <xrx:key>source-regest</xrx:key>
                        <xrx:default>Source Regest</xrx:default>
                    </xrx:i18n>
                    <xsl:text>:&#160;</xsl:text>
                    <xsl:call-template name="biblabstract"/>
                </div>
            </xsl:when>
            <xsl:when test="$cei//cei:chDesc/cei:abstract/text() != ''">
                <xsl:text>&#160;</xsl:text>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="xhtml:insert-abstractnotes">
        <xsl:choose>
            <xsl:when test="count($cei//cei:abstract//cei:hi) > 0">
                <div class="note">
                    <xsl:call-template name="abstractnotes"/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>&#160;</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="xhtml:insert-diplomaticAnalysis">
        <xsl:choose>
            <xsl:when test="count($cei//cei:chDesc/cei:diplomaticAnalysis//text()) > 0 or $cei//cei:lang_MOM or $cei//cei:note">
                <div data-demoid="24296c88-84bc-45f1-a8c5-2703a58dfe95" id="diplomaticAnalysis">
                    <xsl:call-template name="diplomaticAnalysis"/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <div data-demoid="24296c88-84bc-45f1-a8c5-2703a58dfe95" id="diplomaticAnalysis" style="display:none"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="xhtml:insert-tenor">
        <xsl:choose>
            <xsl:when test="$cei//cei:body/cei:tenor//text() != ''">
                <div id="tenor">
                    <xsl:call-template name="tenor"/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <div id="tenor" style="display:none"/>
                <!-- <div class="p">&#160;</div> -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="xhtml:insert-bibltenor">
        <xsl:choose>
            <xsl:when test="count($cei//cei:sourceDesc/cei:sourceDescVolltext/cei:bibl/node()) > 0">
                <!-- Klasse entfernt -->
                <div id="bibltenor">
                    <xsl:call-template name="bibltenor"/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <div id="bibltenor" style="display:none"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="xhtml:insert-tenornotes">
        <xsl:choose>
            <xsl:when test="count($cei//cei:tenor//cei:hi) > 0">
                <!--  <div class="line">x</div> -->
                <xsl:call-template name="tenornotes"/>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>

    </xsl:template>


    <xsl:template match="xhtml:insert-enhancedView">
        <!--creates a div for presenting a map or glossar in index category see charter-view.template-->
    </xsl:template>

    <xsl:template match="xhtml:insert-persName">
        <xsl:choose>
            <xsl:when test="count($cei//cei:persName/node()) > 0">
                <div id="persName">
                    <b>
                        <xrx:i18n>
                            <xrx:key>persons</xrx:key>
                            <xrx:default>Persons</xrx:default>
                        </xrx:i18n>
                    </b>
                    <ul>
                        <xsl:call-template name="persName"/>
                    </ul>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>&#160;</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="xhtml:insert-decoDesc">
        <xsl:choose>
            <!-- <xsl:when test="count($cei//cei:decoDesc/cei:p/node()) > 0"> -->
            <xsl:when test="$cei//cei:decoDesc/cei:p != ''">
                <div id="decoDesc">
                    <xsl:element name="div">
                        <xsl:attribute name="class">p</xsl:attribute>
                        <xsl:call-template name="decoDesc"/>
                        <span style="color:white">x</span>
                    </xsl:element>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <div id="decoDesc" style="display:none"/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>
    <xsl:template match="xhtml:insert-placeName">
        <xsl:choose>
            <xsl:when test="count($cei//cei:placeName/node()) > 0">
                <div id="placeName">
                    <b>
                        <xrx:i18n>
                            <xrx:key>places</xrx:key>
                            <xrx:default>Places</xrx:default>
                        </xrx:i18n>
                    </b>
                    <ul>
                        <xsl:call-template name="placeName"/>
                    </ul>
                </div>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="xhtml:insert-geogName">
        <xsl:choose>
            <xsl:when test="count($cei//cei:geogName/node()) > 0">
                <div id="geogName">
                    <b>
                        <xrx:i18n>
                            <xrx:key>cei_geogName</xrx:key>
                            <xrx:default>geographical names</xrx:default>
                        </xrx:i18n>
                    </b>
                    <ul>
                        <xsl:call-template name="geogName"/>
                    </ul>
                </div>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="xhtml:insert-item">
        <xsl:choose>
            <xsl:when test="$cei//cei:index[@*] | $cei//cei:index[text()]">
                <div id="item">
                    <b>
                        <xrx:i18n>
                            <xrx:key>items</xrx:key>
                            <xrx:default>Items</xrx:default>
                        </xrx:i18n>
                    </b>
                    <ul>
                        <xsl:if test="//cei:index[@indexName]">
                            <xsl:for-each-group select="//cei:index[@indexName != 'general'][@indexName !='']" group-by="@indexName">
                                <xsl:sort select="@indexName" order="descending"/>
                                <xsl:variable name="indexname" select="@indexName"/>
                                <li class="indexname">
                                    <xsl:choose>
                                        <xsl:when test="xrx:getvocabularies($indexname, '', $sprache)">
                                            <xsl:value-of select="xrx:getvocabularies($indexname, '', $sprache)"/>

                                            <xsl:text>: </xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$indexname"/>
                                            <xsl:text>: </xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </li>
                                <xsl:call-template name="item"/>
                                <xsl:if test="((count(./@*) = 1) and @indexName)">
                                    <ul class="indexname">

                                        <xsl:for-each-group select="current-group()" group-by="text()">

                                            <xsl:call-template name="text">
                                                <xsl:with-param name="txt" select="text()"/>
                                            </xsl:call-template>
                                        </xsl:for-each-group>
                                    </ul>
                                </xsl:if>
                            </xsl:for-each-group>
                        </xsl:if>
                        <xsl:if test="//cei:index[not(@*)]/node() | //cei:index[@lemma][not(@indexName)] | //cei:index[@indexName = 'general']">

                            <li>
                                <xrx:i18n>
                                    <xrx:key>general</xrx:key>
                                    <xrx:default>General</xrx:default>
                                </xrx:i18n>
                                <xsl:text>:&#160;</xsl:text>
                            </li>
                            <ul class="inline glossary">
                                <xsl:for-each select="//cei:index[not(@*)]/node()">
                                    <xsl:sort select="cei:index"/>
                                    <li>
                                        <xsl:value-of select="."/>
                                    </li>
                                </xsl:for-each>
                                <xsl:for-each select="//cei:index[@lemma][not(@indexName)] | //cei:index[@indexName = 'general']">
                                    <xsl:sort select="cei:index"/>
                                    <li>
                                        <xsl:value-of select="@lemma"/>
                                        <xsl:if test="@sublemma">
                                            <xsl:text> - </xsl:text>
                                            <xsl:value-of select="@sublemma"/>
                                        </xsl:if>
                                        <xsl:if test="./text()">
                                            <xsl:if test="@sublemma">
                                                <xsl:text> - </xsl:text>
                                            </xsl:if>
                                            <xsl:value-of select="."/>
                                        </xsl:if>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </xsl:if>
                    </ul>
                </div>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="xhtml:insert-dummy"/>
    <xsl:template name="message">
        <xsl:param name="message"/>
        <xsl:element name="{concat('xrx:', $message/@form)}">
            <xsl:attribute name="key">
                <xsl:value-of select="$message/@key"/>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>

    <xsl:template match="insert-entry">
        <xsl:call-template name="entry"/>
    </xsl:template>

    <xsl:template match="xhtml:insert-howToCite">
        <xsl:call-template name="howToCite"/>
    </xsl:template>

    <!-- imageselect -->
    <xsl:template name="imageselect">

        <xsl:for-each select="$cei//cei:witnessOrig//cei:graphic/@url">
            <xsl:sort select="." order="ascending"/>

            <span>
                <p>
                    <xsl:value-of select="$image-base-uri"/>
                </p>
                <a href="javascript:changeImage('{concat($image-base-uri, .)}, 'position()')" class="imageLink">
                    <xsl:value-of select="position()"/>
                </a>
                <xsl:text>&#160;</xsl:text>
            </span>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="image">
        <xsl:for-each select="$cei//cei:witnessOrig/cei:figure/cei:graphic/@url">
            <xsl:sort select="." order="ascending"/>
            <xsl:if test="position() = 1">

                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="concat($image-base-uri, .)"/>
                    </xsl:attribute>
                    <xsl:element name="img">
                        <xsl:attribute name="id">
                            <xsl:text>img</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="src">
                            <xsl:value-of select="$image-base-uri"/>
                            <xsl:value-of select="."/>
                        </xsl:attribute>
                        <xsl:attribute name="name">
                            <xsl:text>image</xsl:text>
                        </xsl:attribute>

                    </xsl:element>
                </a>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!-- witnesselect -->
    <xsl:template name="witnesselect">
        <xsl:param name="num" select="1"/>
        <xsl:param name="witList"/>
        <xsl:variable name="count" select="count($witList)"/>
        <xsl:choose>
            <xsl:when test="$num &lt;= $count">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:text>javascript:showHideDiv_neu('</xsl:text>
                        <xsl:value-of select="concat('wit', $num)"/>
                        <xsl:text>')</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="class">dark-green</xsl:attribute>
                    <xsl:value-of select="$num"/>
 &#160; </xsl:element>
                <xsl:call-template name="witnesselect">
                    <xsl:with-param name="witList" select="$witList"/>
                    <xsl:with-param name="num" select="$num + 1"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- notes -->
    <xsl:template name="hi">
        <xsl:param name="scope"/>
        <xsl:param name="num" select="1"/>
        <xsl:variable name="count" select="count($scope)"/>
        <xsl:for-each select="$cei//cei:back//cei:hi">
            <xsl:if test="$scope[$num] = .">
                <sup>
                    <xsl:value-of select="$scope[$num]"/>
                </sup>
                <xsl:value-of select="./following-sibling::text()"/>
                <xsl:if test="./following-sibling::cei:quote">
                    <i>
                        <xsl:value-of select="./following-sibling::cei:quote"/>
                    </i>
                </xsl:if>
                <br/>
            </xsl:if>
        </xsl:for-each>
        <xsl:choose>
            <xsl:when test="$num &lt;= $count">
                <xsl:call-template name="hi">
                    <xsl:with-param name="scope" select="$scope"/>
                    <xsl:with-param name="num" select="$num + 1"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- cei matching -->
    <xsl:template match="cei:quote">
        <xsl:variable name="i18n">
            <xrx:i18n>
                <xrx:key>cei_quote</xrx:key>
                <xrx:default>quote</xrx:default>
            </xrx:i18n>
        </xsl:variable>
        <i title="{$cei_quote}">
            <xsl:apply-templates/>
        </i>
    </xsl:template>
    <xsl:template match="cei:foreign">
        <i>
            <xsl:apply-templates/>
        </i>
    </xsl:template>
    <xsl:template match="cei:hi">
        <xsl:choose>
            <xsl:when test="@rend = 'sup'">
                <sup>
                    <xsl:apply-templates/>
                </sup>
            </xsl:when>
            <xsl:when test="@rend = 'italics'">
                <i>
                    <xsl:apply-templates/>
                </i>
            </xsl:when>
            <xsl:otherwise>
                <span style="background-color:#E6E6E6">
                    <xsl:attribute name="title">
                        <xsl:value-of select="@rend"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="cei:p">
        <xsl:choose>
            <xsl:when test="./ancestor::cei:physicalDesc">
                <xsl:apply-templates/>
            </xsl:when>

            <xsl:otherwise>
                <p>
                    <xsl:apply-templates/>
                </p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="cei:sup">
        <sup>
            <xsl:apply-templates/>
        </sup>
    </xsl:template>
    <xsl:template match="cei:lb[ancestor::cei:tenor]">
        <span class="cei-lb">||</span>
        <br/>
    </xsl:template>
    <xsl:template match="cei:lb">
        <br/>
    </xsl:template>


    <!-- common elements -->
    <xsl:template match="cei:ref[not(parent::cei:archIdentifier)]">
        <xsl:element name="a">
            <xsl:attribute name="class"/>
            <xsl:attribute name="href">
                <xsl:value-of select="@target"/>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="starts-with(./@target, '#')">
                    <xsl:if test="./@type = 'footnote'">
                        <xsl:attribute name="class">
                            <xsl:text>fn-link</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="id">
                            <xsl:text>ref</xsl:text>
                            <xsl:value-of select="substring-after(./@target, '#')"/>
                        </xsl:attribute>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="target">
                        <xsl:text>_blank</xsl:text>
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="cei:persName">
        <xsl:variable name="i18n">
            <xrx:i18n>
                <xrx:key>cei_persName</xrx:key>
                <xrx:default>person name</xrx:default>
            </xrx:i18n>
        </xsl:variable>
        <span class="cei-persname" title="{$cei_persName}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="cei:issuer">
        <xsl:variable name="i18n">
            <xrx:i18n>
                <xrx:key>cei_issuer</xrx:key>
                <xrx:default>issuer</xrx:default>
            </xrx:i18n>
        </xsl:variable>
        <span class="cei-issuer">
            <xsl:attribute name="title">
                <xsl:value-of select="$cei_issuer"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="cei:recipient">
        <xsl:variable name="i18n">
            <xrx:i18n>
                <xrx:key>cei_recipient</xrx:key>
                <xrx:default>recipient</xrx:default>
            </xrx:i18n>
        </xsl:variable>
        <span class="cei-recipient">
            <xsl:attribute name="title">
                <xsl:value-of select="$cei_recipient"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="cei:index">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="cei:measure">
        <xsl:variable name="i18n">
            <xrx:i18n>
                <xrx:key>cei_measure</xrx:key>
                <xrx:default>measure</xrx:default>
            </xrx:i18n>
        </xsl:variable>
        <span class="cei-measure">
            <xsl:attribute name="title">
                <xsl:value-of select="$cei_measure"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="cei:pb">
        <xsl:variable name="i18n">
            <xrx:i18n>
                <xrx:key>cei_pb</xrx:key>
                <xrx:default>page break</xrx:default>
            </xrx:i18n>
        </xsl:variable>
        <span class="cei-pb">
            <xsl:attribute name="title">
                <xsl:value-of select="$cei_pb"/>
            </xsl:attribute>
            <text>||</text>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="cei:handshift">
        <xsl:variable name="i18n">
            <xrx:i18n>
                <xrx:key>cei_handshift</xrx:key>
                <xrx:default>new hand</xrx:default>
            </xrx:i18n>
        </xsl:variable>
        <span class="cei-handshift">
            <xsl:attribute name="title">
                <xsl:value-of select="$cei_handshift"/>
            </xsl:attribute>
            <xsl:text>//</xsl:text>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="cei:add">
        <xsl:variable name="i18n">
            <xrx:i18n>
                <xrx:key>cei_add</xrx:key>
                <xrx:default>addition</xrx:default>
            </xrx:i18n>
        </xsl:variable>
        <span class="cei-add">
            <xsl:attribute name="title">
                <xsl:value-of select="$cei_add"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="cei:add[@rend = 'show']">
        <span class="cei-add-orig">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="cei:expan">
        <xsl:variable name="i18n">
            <xrx:i18n>
                <xrx:key>cei_expan</xrx:key>
                <xrx:default>expanded abbreviation</xrx:default>
            </xrx:i18n>
        </xsl:variable>
        <span class="cei-expan">
            <xsl:attribute name="title">
                <xsl:value-of select="$cei_expan"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="cei:corr">
        <xsl:variable name="i18n">
            <xrx:i18n>
                <xrx:key>cei_corr</xrx:key>
                <xrx:default>correction</xrx:default>
            </xrx:i18n>
        </xsl:variable>
        <span class="cei-corr">
            <xsl:attribute name="title">
                <xsl:value-of select="$cei_corr"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="cei:sic">
        <xsl:variable name="i18n">
            <xrx:i18n>
                <xrx:key>cei_sic</xrx:key>
                <xrx:default>sic</xrx:default>
            </xrx:i18n>
        </xsl:variable>
        <span class="cei-sic">
            <xsl:attribute name="title">
                <xsl:value-of select="$cei_sic"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="cei:reg">
        <xsl:variable name="i18n">
            <xrx:i18n>
                <xrx:key>cei_reg</xrx:key>
                <xrx:default>normalized</xrx:default>
            </xrx:i18n>
        </xsl:variable>
        <span class="cei-reg">
            <xsl:attribute name="title">
                <xsl:value-of select="$cei_reg"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="cei:del">
        <xsl:variable name="i18n">
            <xrx:i18n>
                <xrx:key>cei_del</xrx:key>
                <xrx:default>deleted</xrx:default>
            </xrx:i18n>
        </xsl:variable>

        <span class="cei-del" style="text-decoration:line-through">
            <xsl:attribute name="title">
                <xsl:value-of select="$cei_del"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="cei:abbr">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="cei:del[@rend = 'show']">
        <span class="cei-del-orig">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="cei:pict">
        <xsl:variable name="i18n">
            <xrx:i18n>
                <xrx:key>cei_pict</xrx:key>
                <xrx:default>graphical element</xrx:default>
            </xrx:i18n>
        </xsl:variable>
        <span class="cei-pict">
            <xsl:attribute name="title">
                <xsl:value-of select="$cei_pict"/>
            </xsl:attribute>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="@type"/>
            <xsl:text>) </xsl:text>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="cei:damage">
        <xsl:variable name="i18n">
            <xrx:i18n>
                <xrx:key>cei_damage</xrx:key>
                <xrx:default>damage</xrx:default>
            </xrx:i18n>
        </xsl:variable>
        <span class="cei-damage">
            <xsl:attribute name="title">
                <xsl:value-of select="$cei_damage"/>
            </xsl:attribute>
            <xsl:text>[</xsl:text>
            <xsl:choose>
                <xsl:when test=".//text()/normalize-space() != '' or node()">
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>...</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>]</xsl:text>
        </span>
    </xsl:template>

    <xsl:template match="cei:c">
        <span class="cei-c">
            <xsl:attribute name="title">
                <xsl:text>palaeographical observation on characters</xsl:text>
                <xsl:if test="normalize-space(@type) != ''">
                    <xsl:text>: </xsl:text>
                    <xsl:value-of select="@type"/>
                </xsl:if>
            </xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="cei:supplied">
        <xsl:variable name="i18n">
            <xrx:i18n>
                <xrx:key>cei_supplied</xrx:key>
                <xrx:default>supplied</xrx:default>
            </xrx:i18n>
        </xsl:variable>
        <span class="cei-supplied">
            <xsl:attribute name="title">
                <xsl:value-of select="$cei_supplied"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="cei:unclear">
        <xsl:variable name="i18n">
            <xrx:i18n>
                <xrx:key>cei_unclear</xrx:key>
                <xrx:default>unclear</xrx:default>
            </xrx:i18n>
        </xsl:variable>
        <span class="cei-supplied">
            <xsl:attribute name="title">
                <xsl:value-of select="$cei_unclear"/>
                <xsl:if test="normalize-space(@type) != ''">
                    <xsl:text/>
                    <xsl:value-of select="@type"/>
                </xsl:if>
            </xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- witness -->
    <xsl:template name="witness">
        <xsl:param name="num"/>
        <xsl:element name="div">
            <xsl:attribute name="class">p</xsl:attribute>
            <xsl:attribute name="id">
                <xsl:value-of select="concat('wit', $num)"/>
            </xsl:attribute>
            <div class="witness-text" name="wit">
                <br/>
                <xsl:if test="./@n !=''">
                    <b>
                        <xrx:i18n>
                            <xrx:key>charter-view-witness</xrx:key>
                            <xrx:default>Textual witness</xrx:default>
                        </xrx:i18n>
                        <span>:&#160;</span>
                        <xsl:value-of select="./@n"/>
                    </b>
                    <br/>
                </xsl:if>
                <xsl:call-template name="traditioForm"/>
                <div class="p">
                    <xsl:if test="./cei:archIdentifier/node()">
                            <b>
                                <xrx:i18n>
                                    <xrx:key>actual-repository</xrx:key>
                                    <xrx:default>Current repository</xrx:default>
                                </xrx:i18n>
                                <span>:&#160;</span>
                            </b>
                        <xsl:apply-templates select="cei:archIdentifier"/>
                    </xsl:if>
                </div>
                <br/>

                <xsl:choose>
                    <xsl:when test="./cei:auth/cei:sealDesc/cei:seal/cei:sigillant/text() != ''">
                        <li>
                            <b>
                                <xrx:i18n>
                                    <xrx:key>sigillant</xrx:key>
                                    <xrx:default>Sigillant</xrx:default>
                                </xrx:i18n>
                                <span>:&#160;</span>
                            </b>
                            <xsl:for-each select="./cei:auth/cei:sealDesc/cei:seal/cei:sigillant">
                                <xsl:apply-templates select="."/>
                                <xsl:if test="position() != last()">
                                    <xsl:text>,</xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </li>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="./cei:auth/cei:sealDesc/cei:seal/text() != ''">
                        <li>
                            <b>
                                <xrx:i18n>
                                    <xrx:key>seal</xrx:key>
                                    <xrx:default>Seal</xrx:default>
                                </xrx:i18n>
                                <span>:&#160;</span>
                            </b>
                            <xsl:for-each select="./cei:auth/cei:sealDesc/cei:seal">
                                <xsl:apply-templates select="."/>
                                <xsl:if test="position() != last()">
                                    <xsl:text>,</xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </li>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="./cei:auth/cei:sealDesc/text() != ''">
                        <li>
                            <b>
                                <xrx:i18n>
                                    <xrx:key>sealDescription</xrx:key>
                                    <xrx:default>Seal</xrx:default>
                                </xrx:i18n>
                                <span>:&#160;</span>
                            </b>
                            <xsl:apply-templates select="./cei:auth/cei:sealDesc"/>
                            <xsl:apply-templates select="./cei:auth/cei:sealDesc/cei:dimensions"/>
                        </li>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="count(./cei:auth/cei:notariusDesc/node()) > 0">
                        <li>
                            <b>
                                <xrx:i18n>
                                    <xrx:key>notarius-description</xrx:key>
                                    <xrx:default>Notarius Description</xrx:default>
                                </xrx:i18n>
                                <span>:&#160;</span>
                            </b>
                            <xsl:apply-templates select="./cei:auth/cei:notariusDesc"/>
                        </li>
                    </xsl:when>
                </xsl:choose>
                <xsl:apply-templates select="./cei:physicalDesc"/>
                <ul>
                    <xsl:if test="./cei:nota//text()/normalize-space() != ''">
                        <li>
                            <b>
                                <xrx:i18n>
                                    <xrx:key>cei_nota</xrx:key>
                                    <xrx:default>nota</xrx:default>
                                </xrx:i18n>
                                <span>:&#160;</span>
                            </b>
                            <ul>
                                <xsl:apply-templates select="./cei:nota"/>
                            </ul>
                        </li>
                    </xsl:if>
                    <xsl:if test="./cei:rubrum//text()/normalize-space() != ''">
                        <li>
                            <b>
                                <xrx:i18n>
                                    <xrx:key>cei_rubrum</xrx:key>
                                    <xrx:default>rubrum</xrx:default>
                                </xrx:i18n>
                                <span>:&#160;</span>
                            </b>
                            <ul>
                                <xsl:apply-templates select="./cei:rubrum"/>
                            </ul>
                        </li>
                    </xsl:if>
                </ul>
            </div>
            <xsl:choose>
                <xsl:when test="count(./cei:figure/cei:graphic) != 0">
                    <b>
                        <xrx:i18n>
                            <xrx:key>graphics</xrx:key>
                            <xrx:default>Graphics</xrx:default>
                        </xrx:i18n>
                        <xsl:text>:&#160;</xsl:text>
                    </b>
                    <div class="witness-graphic">

                        <xsl:for-each select="cei:figure/cei:graphic/@url">
                            <xsl:sort select="."/>
                            <!-- <xsl:if test="position() = 1"> -->
                            <xsl:element name="img">
                                <xsl:attribute name="src">
                                    <xsl:if test="not(contains(., '/'))">
                                        <xsl:value-of select="$image-base-uri"/>
                                    </xsl:if>
                                    <xsl:value-of select="."/>
                                </xsl:attribute>
                                <xsl:attribute name="name">
                                    <xsl:text>wit</xsl:text>
                                    <xsl:value-of select="$num"/>
                                </xsl:attribute>
                                <xsl:attribute name="id">
                                    <xsl:text>graphic</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="title">
                                    <xsl:value-of select="."/>
                                </xsl:attribute>
                            </xsl:element>
                            <!-- </xsl:if> -->
                        </xsl:for-each>
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <div class="no-graphic">
                        <xsl:copy-of select="$sitemap//xrx:*[@key = 'noGraphicAvailable']"/>
                    </div>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <xsl:template match="cei:rubrum|cei:nota">
        <li>
            <xsl:apply-templates/>
        </li>
    </xsl:template>
  <xsl:template match="cei:archIdentifier | cei:altIdentifier">
<!--    <xsl:if test="self::cei:archIdentifier">
      <xsl:text>  </xsl:text>
    </xsl:if>-->
      <br/>
    <xsl:if test=".[@type='old']">
        <xrx:i18n>
            <xrx:key>formerly: </xrx:key>
            <xrx:default>ehem.: </xrx:default>
        </xrx:i18n>
    </xsl:if>
        <xsl:choose>
            <xsl:when test="text()[normalize-space() != '']">
                <xsl:value-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:if test="cei:ref/@target">
            <li style="list-style:none">
                <a target="_blank">
                    <xsl:attribute name="href">
                        <xsl:value-of select="//cei:archIdentifier/cei:ref/@target"/>
                    </xsl:attribute>
                    <xrx:i18n>
                        <xrx:key>charter-on-archives-website</xrx:key>
                        <xrx:default>Charter on the archive's website</xrx:default>
                    </xrx:i18n>alt
                </a>
            </li>
        </xsl:if>
    </xsl:template>
    <xsl:template match="cei:idno">
      <span>
        <xsl:value-of select="normalize-space(replace(., ',', ''))"/>
        <xsl:if test="parent::cei:altIdentifier|parent::ceiarchIdentifier">
          <xsl:text>.</xsl:text>
        </xsl:if>
      </span>
    </xsl:template>
     <!--<xsl:template match="cei:altIdentifier">
        <li>
             <span>
                  <xrx:i18n>
                    <xrx:key>old-signature</xrx:key>
                    <xrx:default>Old Signature</xrx:default>
                  </xrx:i18n>
                  <span>: </span>
                </span>
            <xsl:value-of select="."/>
        </li>
    </xsl:template> -->
    <!--  <xsl:if test="cei:idno/@n">
              <li>
                <span>
                  <xrx:i18n>
                    <xrx:key>internal-signature</xrx:key>
                    <xrx:default>Internal Signature</xrx:default>
                  </xrx:i18n>
                  <span>:&#160;</span>
                </span>
                <xsl:value-of select="cei:idno/@n" />
              </li>
            </xsl:if> -->

    <xsl:template match="cei:physicalDesc">
        <xsl:apply-templates select="*[not(name() = 'cei:decoDesc')]"/>
    </xsl:template>
    <xsl:template name="traditioForm">
        <xsl:apply-templates select="./cei:traditioForm"/>
        <br/>
        <xsl:apply-templates select="./child::text()"/>
    </xsl:template>
    <xsl:template match="cei:material">
        <xsl:if test="./node()">
            <li>
                <b>
                    <xrx:i18n>
                        <xrx:key>material</xrx:key>
                        <xrx:default>Material</xrx:default>
                    </xrx:i18n>
                    <xsl:text>:&#160;</xsl:text>
                </b>
                <xsl:apply-templates/>
            </li>
        </xsl:if>
    </xsl:template>
    <xsl:template match="cei:condition">
        <xsl:if test="./node()">
            <li>
                <b>
                    <xrx:i18n>
                        <xrx:key>condition</xrx:key>
                        <xrx:default>Condition</xrx:default>
                    </xrx:i18n>
                    <xsl:text>:&#160;</xsl:text>
                </b>
                <xsl:apply-templates/>
            </li>
        </xsl:if>
    </xsl:template>
    <xsl:template match="cei:dimensions">
        <xsl:choose>
            <xsl:when test="./ancestor::cei:physicalDesc">
                <xsl:if test="./node()">
                    <li>
                        <b>
                            <xrx:i18n>
                                <xrx:key>dimensions</xrx:key>
                                <xrx:default>Dimensions</xrx:default>
                            </xrx:i18n>
                            <xsl:text>:&#160;</xsl:text>
                        </b>
                        <xsl:apply-templates/>
                    </li>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="cei:arch | cei:institution">
        <xsl:value-of select="normalize-space(replace(., ',', ''))"/>
        <xsl:if test="following-sibling::*[1][. != '']">
            <xsl:text>, </xsl:text>
        </xsl:if>
        <!--<xsl:apply-templates />
    <br /> -->
    </xsl:template>
    <xsl:template match="cei:archFonds">
        <xsl:apply-templates/>
        <br/>
    </xsl:template>
    <xsl:template match="cei:settlement">
        <span>
            <xsl:value-of select="normalize-space(replace(., ',', ''))"/>
            <xsl:if test="following-sibling::*">
                <xsl:text>, </xsl:text>
            </xsl:if>
        </span>
    </xsl:template>
    <xsl:template match="cei:archFond">
        <xsl:value-of select="normalize-space(replace(., ',', ''))"/>
        <xsl:if test="following-sibling::*">
            <xsl:text>, </xsl:text>
        </xsl:if>
    </xsl:template>

    <!--  <xsl:template match="cei:idno">
    <xsl:apply-templates />
    <br />
  </xsl:template> -->

    <!-- issued -->
    <xsl:template match="cei:dateRange">
        <xsl:value-of select="text()"/>
    </xsl:template>
    <xsl:template match="cei:date">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="cei:placeName">
        <xsl:variable name="i18n">
            <xrx:i18n>
                <xrx:key>cei_placeName</xrx:key>
                <xrx:default>place name</xrx:default>
            </xrx:i18n>
        </xsl:variable>
        <span class="cei-placename" title="{$cei_placeName}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="cei:geogName">
        <xsl:variable name="i18n">
            <xrx:i18n>
                <xrx:key>cei_geogName</xrx:key>
                <xrx:default>geographical name</xrx:default>
            </xrx:i18n>
        </xsl:variable>
        <span class="cei-geogName" title="{$cei_geogName}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template name="issued">
        <xsl:apply-templates select="$cei//cei:issued/cei:dateRange"/>
        <xsl:apply-templates select="$cei//cei:issued/cei:date"/>
        <xsl:if test="$cei//cei:issued/cei:placeName/text()/normalize-space() != '' ">
            <xsl:if test="$cei//cei:issued/cei:dateRange | $cei//cei:issued/cei:date">
                <xsl:text>, </xsl:text>
            </xsl:if>
            <xsl:apply-templates select="$cei//cei:issued/cei:placeName"/>
        </xsl:if>
    </xsl:template>

    <!-- abstract -->
    <xsl:template name="abstract">
        <xsl:apply-templates select="$cei//cei:chDesc/cei:abstract"/>
    </xsl:template>
    <xsl:template match="cei:abstract">
        <xsl:apply-templates/>
    </xsl:template>
    <!--  <xsl:template match="cei:bibl">
    <xsl:apply-templates />
  </xsl:template>-->
    <xsl:template name="biblabstract">
        <xsl:apply-templates select="$cei//cei:sourceDesc/cei:sourceDescRegest/cei:bibl"/>
    </xsl:template>
    <xsl:template name="abstractnotes">
        <xsl:call-template name="hi">
            <xsl:with-param name="scope" select="$cei//cei:issued//cei:hi"/>
        </xsl:call-template>
        <xsl:call-template name="hi">
            <xsl:with-param name="scope" select="$cei//cei:abstract//cei:hi"/>
        </xsl:call-template>
    </xsl:template>

    <!-- decoDesc -->
    <xsl:template name="decoDesc">
        <div>
            <ul class="nostyle">
                <xsl:for-each select="//cei:decoDesc/cei:p">
                    <xsl:choose>
                        <xsl:when test="@n = 'Ekphrasis'">
                            <li>
                                <xsl:choose>
                                    <xsl:when test="preceding-sibling::cei:p[@n = 'Ekphrasis']">
                                        <xsl:attribute name="n">Ekphrasis</xsl:attribute>
                                        <xsl:apply-templates/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="n">Ekphrasis</xsl:attribute>
                                        <b>
                                            <span>
                                                <xrx:i18n>
                                                    <xrx:key>ekphrasis</xrx:key>
                                                    <xrx:default>Materielle Beschreibung</xrx:default>
                                                </xrx:i18n>
                                                <xsl:text>:&#160;</xsl:text>
                                            </span>
                                        </b>
                                        <br/>
                                        <xsl:apply-templates/>

                                    </xsl:otherwise>
                                </xsl:choose>
                            </li>
                        </xsl:when>
                        <xsl:when test="@n = 'Autorensigle'">
                            <xsl:if test="not(cei:index)">
                                <li class="autor">
                                    <xsl:attribute name="n">Autorensigle</xsl:attribute>
                                    <xsl:apply-templates/>
                                </li>
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test="@n = 'Stil und Einordnung'">
                            <li>
                                <xsl:choose>
                                    <xsl:when test="preceding-sibling::cei:p[@n = 'Stil und Einordnung']">
                                        <xsl:attribute name="n">Stil</xsl:attribute>
                                        <xsl:apply-templates/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="n">Stil</xsl:attribute>
                                        <b>
                                            <span>
                                                <xrx:i18n>
                                                    <xrx:key>stil</xrx:key>
                                                    <xrx:default>Stil und Einordnung</xrx:default>
                                                </xrx:i18n>
                                                <xsl:text>:&#160;</xsl:text>
                                            </span>
                                        </b>
                                        <br/>
                                        <xsl:apply-templates/>

                                    </xsl:otherwise>
                                </xsl:choose>
                            </li>
                        </xsl:when>
                        <xsl:otherwise>
                            <li>
                                <!-- <xsl:value-of select="text()"/> -->
                                <xsl:apply-templates/>
                            </li>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </ul>
        </div>

    </xsl:template>


    <!-- diplomaticAnalysis -->
    <xsl:template name="diplomaticAnalysis">
        <div class="p">
            <xsl:apply-templates select="$cei//cei:chDesc/cei:diplomaticAnalysis" mode="diplA"/>
            <xsl:if test="$cei//cei:lang_MOM/text() != ''">
                <br/>
                <br/>
                <b>
                    <xrx:i18n>
                        <xrx:key>lang</xrx:key>
                        <xrx:default>Language</xrx:default>
                    </xrx:i18n>
                </b>
                <xsl:text>:&#160;</xsl:text>
                <xsl:apply-templates select="$cei//cei:lang_MOM"/>
            </xsl:if>
            <xsl:if test="$cei//cei:note/node()">
                <br/>
                <br/>
                <b>
                    <xrx:i18n>
                        <xrx:key>notes</xrx:key>
                        <xrx:default>Notes</xrx:default>
                    </xrx:i18n>
                </b>
                <xsl:text>:&#160;</xsl:text>
                <xsl:apply-templates select="$cei//cei:note" mode="content"/>
            </xsl:if>
        </div>
    </xsl:template>
    <!-- handling notes (they are assumed to be notes by the editor -->
    <xsl:template match="cei:note[not(ancestor::cei:back)]">
        <!-- inline-note: display the reference to a note  -->
        <a id="backlink_{generate-id()}" class="fn-link" href="#{generate-id()}">
            <xsl:value-of select="count(preceding::cei:note[not(ancestor::cei:back)])+1"/>
        </a>
    </xsl:template>
    <xsl:template match="cei:note" priority="-1" mode="content">
        <!-- display the text of an inline-note -->
        <div class="note">
            <xsl:attribute name="id">
                <xsl:value-of select="generate-id()"/>
            </xsl:attribute>
            <a class="fn-link" href="#backlink_{generate-id()}">
                <xsl:value-of select="count(preceding::cei:note[not(ancestor::cei:back)])+1"/>
            </a>
            <xsl:text/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="cei:divNotes/cei:note" mode="content">
        <div class="note">
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <!-- bibliographic lists -->
    <xsl:template match="cei:listBiblEdition" mode="diplA">
        <div>
            <xsl:if test="./cei:bibl/node()">
                <b>
                    <xrx:i18n>
                        <xrx:key>editions</xrx:key>
                        <xrx:default>Editions</xrx:default>
                    </xrx:i18n>
                    <span>:&#160;</span>
                </b>
                <ul>
                    <xsl:for-each select="cei:bibl">
                        <xsl:call-template name="bibl"/>
                    </xsl:for-each>
                </ul>
            </xsl:if>
        </div>
    </xsl:template>
    <xsl:template match="cei:listBiblRegest" mode="diplA">
        <!--   <xsl:when test="preceding-sibling::cei:p[@n='Ekphrasis']">
              <xsl:attribute name="n">Ekphrasis</xsl:attribute>
              <xsl:apply-templates />
            </xsl:when> -->
        <div>
            <xsl:if test="./cei:bibl/node()">
                <xsl:choose>
                    <xsl:when test="preceding-sibling::cei:bibl">
                        <ul>
                            <xsl:for-each select="cei:bibl">
                                <xsl:call-template name="bibl"/>
                            </xsl:for-each>
                        </ul>
                    </xsl:when>
                    <xsl:otherwise>
                        <b>
                            <xrx:i18n>
                                <xrx:key>abstracts</xrx:key>
                                <xrx:default>Abstracts</xrx:default>
                            </xrx:i18n>
                            <span>:&#160;</span>
                        </b>
                        <ul>
                            <xsl:for-each select="cei:bibl">
                                <xsl:call-template name="bibl"/>
                            </xsl:for-each>
                        </ul>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </div>
    </xsl:template>
    <xsl:template match="cei:listBibl" mode="diplA">
        <div>
            <xsl:if test="./cei:bibl/node()">
                <xsl:choose>
                    <xsl:when test="preceding-sibling::cei:bibl">
                        <ul>
                            <xsl:for-each select="cei:bibl">
                                <xsl:call-template name="bibl"/>
                            </xsl:for-each>
                        </ul>
                    </xsl:when>
                    <xsl:otherwise>
                        <b>
                            <xrx:i18n>
                                <xrx:key>cei_listBibl</xrx:key>
                                <xrx:default>Bibliography</xrx:default>
                            </xrx:i18n>
                            <span>:&#160;</span>
                        </b>
                        <ul>
                            <xsl:for-each select="cei:bibl">
                                <xsl:call-template name="bibl"/>
                            </xsl:for-each>
                        </ul>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </div>
    </xsl:template>
    <xsl:template match="cei:listBiblErw" mode="diplA">
        <div>
            <xsl:if test="./cei:bibl/node()">
                <b>
                    <xrx:i18n>
                        <xrx:key>secondary-literature</xrx:key>
                        <xrx:default>Secondary Literature</xrx:default>
                    </xrx:i18n>
                    <span>:&#160;</span>
                </b>
                <ul>
                    <xsl:for-each select="cei:bibl">
                        <xsl:call-template name="bibl"/>
                    </xsl:for-each>
                </ul>
            </xsl:if>
        </div>
    </xsl:template>
    <xsl:template match="cei:listBiblFaksimile" mode="diplA">
        <div>
            <xsl:if test="./cei:bibl/node()">
                <b>
                    <xrx:i18n>
                        <xrx:key>facsimile</xrx:key>
                        <xrx:default>Facsimile</xrx:default>
                    </xrx:i18n>
                    <span>:&#160;</span>
                </b>
                <ul>
                    <xsl:for-each select="cei:bibl">
                        <xsl:call-template name="bibl"/>
                    </xsl:for-each>
                </ul>
            </xsl:if>
        </div>
    </xsl:template>
    <xsl:template match="cei:listBiblEdition">
        <xsl:choose>
            <xsl:when test="@type = 'regesta'">
                <xsl:copy-of select="$sitemap//xrx:*[@key = 'biblregesta']"/>
                <xsl:text>:&#160;</xsl:text>
                <br/>
                <p>
                    <ul>
                        <xsl:for-each select="cei:bibl">
                            <xsl:call-template name="bibl"/>
                        </xsl:for-each>
                    </ul>
                </p>
            </xsl:when>
            <xsl:when test="@type = 'facsimilia'">
                <xsl:copy-of select="$sitemap//xrx:*[@key = 'biblfacsimilia']"/>
                <xsl:text>:&#160;</xsl:text>
                <br/>
                <p>
                    <ul>
                        <xsl:for-each select="cei:bibl">
                            <xsl:call-template name="bibl"/>
                        </xsl:for-each>
                    </ul>
                </p>
            </xsl:when>
            <xsl:when test="@type = 'studies'">
                <xsl:copy-of select="$sitemap//xrx:*[@key = 'biblstudies']"/>
                <xsl:text>:&#160;</xsl:text>
                <br/>
                <p>
                    <ul>
                        <xsl:for-each select="cei:bibl">
                            <xsl:call-template name="bibl"/>
                        </xsl:for-each>
                    </ul>
                </p>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="bibl">
        <li>
            <xsl:apply-templates/>
        </li>
    </xsl:template>
    <xsl:template match="cei:p" mode="diplA">
        <xsl:if test="./node()">
            <div>
                <xsl:if test="count(preceding-sibling::cei:p) = 0">
                    <p class="localheading">
                        <b>
                            <xrx:i18n>
                                <xrx:key>comment</xrx:key>
                                <xrx:default>Comment</xrx:default>
                            </xrx:i18n>
                        </b>
                    </p>
                </xsl:if>
                <xsl:for-each select=".">
                    <xsl:if test="@n != ''">
                        <span class="localheading">
                            <b>
                                <xsl:value-of select="@n"/>
                                <xsl:text>:&#160;</xsl:text>
                            </b>
                        </span>
                    </xsl:if>
                    <xsl:apply-templates/>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template match="cei:quoteOriginaldatierung" mode="diplA">
        <xsl:if test="./node()">
            <p>
                <b>
                    <xrx:i18n>
                        <xrx:key>quoteDate</xrx:key>
                        <xrx:default>Original dating clause</xrx:default>
                    </xrx:i18n>
                </b>
                <xsl:text>:&#160;</xsl:text>
                <i>
                    <xsl:apply-templates/>
                </i>
            </p>
        </xsl:if>
    </xsl:template>

    <!-- tenor -->
    <xsl:template name="tenor">
        <xsl:apply-templates select="$cei//cei:body/cei:tenor"/>
    </xsl:template>
    <xsl:template match="cei:pTenor">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="cei:tenor">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template name="bibltenor">
        <!-- <div id="bibltenor"> -->
        <xrx:i18n>
            <xrx:key>source-fulltext</xrx:key>
            <xrx:default>Source Fulltext</xrx:default>
        </xrx:i18n>
        <xsl:text>:&#160;</xsl:text>
        <xsl:apply-templates select="$cei//cei:sourceDesc/cei:sourceDescVolltext/cei:bibl"/>
        <!-- </div> -->
    </xsl:template>
    <xsl:template name="tenornotes">
        <div class="note">
            <span style="color:white">x</span>
            <xsl:call-template name="hi">
                <xsl:with-param name="scope" select="$cei//cei:tenor//cei:hi"/>
            </xsl:call-template>
        </div>
    </xsl:template>

    <!-- <xsl:template match="cei:unclear">
    <span class="unclear" title="cei:unclear" style="border-bottom:1px black dotted;">
      <xsl:value-of select="."/>
    </span>
  </xsl:template>-->

    <!-- index persName -->
    <xsl:template name="persName">
        <xsl:for-each select="$cei//cei:persName">
            <xsl:sort select="."/>
            <xsl:if test="./node()">
                <li id="{./@key}">
                    <xsl:apply-templates select="." mode="index"/>
                </li>
                <ul class="inline">
                    <xsl:call-template name="language"/>
                    <xsl:call-template name="reg"/>
                    <xsl:call-template name="existent"/>
                    <xsl:call-template name="type"/>
                </ul>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="cei:persName[starts-with(@key,'http://')]" mode="index">
        <xsl:apply-templates/>
        <a href=".">
            <xrx:i18n>
                <xrx:key>key-external-information</xrx:key>
                <xrx:default>[Additional information (external)]</xrx:default>
            </xrx:i18n>
        </a>
    </xsl:template>
    <xsl:template match="cei:persName[@key]" priority="-1" mode="index">
        <xsl:apply-templates/>
        <!--
            ToDo: add service-call to getPersonInfo (when this is finished)
        <a href=".">
            <xrx:i18n>
                <xrx:key>key-internal-information</xrx:key>
                <xrx:default>[Additional information]</xrx:default>
            </xrx:i18n>
        </a>-->
    </xsl:template>
    <xsl:template name="sucheperson">
        <xsl:param name="len"/>
        <xsl:param name="key"/>
        <!--
            ToDo: This should be replaced by a service call
            <xsl:if test="$len > 0">
            <xsl:variable name="filename" select="tokenize($personfilelist, ' ')[$len]"/>
            <xsl:variable name="url" select="concat('/db/mom-data/metadata.person.public/', $filename)"/>
            <xsl:variable name="fileatomid" select="substring-after(document($url)/atom:entry/atom:id, '/person/')"/>
            <xsl:choose>
                <xsl:when test="document($url)/atom:entry[.//tei:person/@xml:id = $key]/atom:id = 'tag:www.monasterium.net,2011:/person/BischoefeAblaesse'">
                    <xsl:attribute name="value">true</xsl:attribute>
                    <xsl:attribute name="class">
                        <xsl:value-of select="$fileatomid"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="document($url)/atom:entry//tei:person/@xml:id = $key">
                            <xsl:attribute name="value">true</xsl:attribute>
                            <xsl:attribute name="class">
                                <xsl:value-of select="$fileatomid"/>
                            </xsl:attribute>
                            <xsl:value-of select="document($url)//atom:entry//tei:person[@xml:id = $key]/tei:persName"/>
                        </xsl:when>
                        <xsl:otherwise></xsl:otherwise>
                    </xsl:choose>

                    <xsl:variable name="newlen" select="$len - 1"/>
                    <xsl:call-template name="sucheperson">
                        <xsl:with-param name="len" select="$newlen"/>
                        <xsl:with-param name="key" select="$key"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>-->
    </xsl:template>

    <xsl:template name="language">
        <xsl:choose>
            <xsl:when test="./@lang">
                <li>
                    <xrx:i18n>
                        <xrx:key>lang</xrx:key>
                        <xrx:default>Language</xrx:default>
                    </xrx:i18n>
                    <xsl:text>:&#160;</xsl:text>
                    <xsl:value-of select="./@lang"/>
                </li>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="reg">
        <xsl:choose>
            <xsl:when test="./@reg">
                <li>
                    <xrx:i18n>
                        <xrx:key>regular-form</xrx:key>
                        <xrx:default>Regular Form</xrx:default>
                    </xrx:i18n>
                    <xsl:text>:&#160;</xsl:text>
                    <xsl:value-of select="./@reg"/>
                </li>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="type">
        <xsl:choose>
            <xsl:when test="./@type">
                <li>
                    <xrx:i18n>
                        <xrx:key>type</xrx:key>
                        <xrx:default>Type</xrx:default>
                    </xrx:i18n>
                    <xsl:text>:&#160;</xsl:text>
                    <xsl:value-of select="./@type"/>
                </li>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="existent">
        <xsl:choose>
            <xsl:when test="./@existent">
                <li>
                    <xrx:i18n>
                        <xrx:key>existent</xrx:key>
                        <xrx:default>Existent</xrx:default>
                    </xrx:i18n>
                    <xsl:text>:&#160;</xsl:text>
                    <xsl:value-of select="./@existent"/>
                </li>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="lemma">
        <xsl:param name="lm"/>
        <xsl:choose>
            <xsl:when test="./@lemma">
                <xsl:variable name="cv">
                    <xsl:choose>
                        <xsl:when test="xrx:getvocabularies(@indexName, '', $sprache)">

                            <xsl:text>true</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>false</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <li>
                    <xsl:attribute name="class">
                        <xsl:value-of select="@indexName"/>
                    </xsl:attribute>
                    <xsl:attribute name="lemma">
                        <xsl:value-of select="replace(./@lemma, '#', '')"/>
                    </xsl:attribute>
                    <xsl:attribute name="value">
                        <xsl:choose>
                            <xsl:when test="xrx:getvocabularies(@indexName, '', $sprache)">

                                <xsl:text>true</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>false</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:value-of select="./@type"/>
                    <xsl:choose>
                        <xsl:when test="./@sublemma">
                            <xsl:for-each-group select="current-group()" group-by="@sublemma">
                                <xsl:call-template name="sublemma">
                                    <xsl:with-param name="sub" select="current-grouping-key()"/>
                                </xsl:call-template>
                            </xsl:for-each-group>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="lem" select="@lemma"/>
                            <xsl:variable name="norm">
                                <xsl:value-of select="concat('#',upper-case($lem))"/>
                            </xsl:variable>
                            <xsl:choose>

                                <xsl:when test="xrx:getvocabularies(@indexName, '', $sprache)">
                                    <!-- der übersetzte Lemma wert kommt hier hin -->
                                    <xsl:value-of select="xrx:getvocabularies(@indexName, $norm, $sprache)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="@lemma"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <!--  Das verwirrt nur den user <xsl:if test="(compare(xrx:getvocabularies(@indexName, $norm, $sprache), .) = -1)">
                                <xsl:text>  </xsl:text>

                                <xsl:value-of select="."/>
                            </xsl:if> -->
                        </xsl:otherwise>
                    </xsl:choose>
                </li>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="sublemma">
        <xsl:param name="sub"/>
        <li>
            <xsl:value-of select="sub"/>
        </li>
    </xsl:template>
    <xsl:template name="text">
        <xsl:param name="txt"/>
        <li class="green">
            <xsl:value-of select="."/>
        </li>
    </xsl:template>

    <!-- index placeName -->
    <xsl:template name="placeName">
        <xsl:for-each select="$cei//cei:placeName">
            <xsl:sort select="."/>
            <xsl:if test="./node()">
                <li>
                    <xsl:apply-templates/>
                </li>
                <ul class="inline">
                    <xsl:call-template name="language"/>
                    <xsl:call-template name="reg"/>
                    <xsl:call-template name="existent"/>
                    <xsl:call-template name="type"/>
                </ul>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>


    <!-- index geogName -->
    <xsl:template name="geogName">
        <xsl:for-each select="$cei//cei:geogName">
            <xsl:sort select="."/>
            <xsl:if test="./node()">
                <li>
                    <xsl:apply-templates/>
                </li>
                <ul class="inline">
                    <xsl:call-template name="language"/>
                    <xsl:call-template name="reg"/>
                    <xsl:call-template name="existent"/>
                    <xsl:call-template name="type"/>
                </ul>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <!-- index -->
    <xsl:template name="item">

        <xsl:for-each-group select="current-group()" group-by="@lemma">
            <ul class="inline glossary">

                <!--  <xsl:call-template name="language" />
          <xsl:call-template name="reg" />
          <xsl:call-template name="existent" /> -->
                <xsl:call-template name="type"/>
                <xsl:call-template name="lemma">
                    <xsl:with-param name="lm" select="current-grouping-key()"/>
                </xsl:call-template>

            </ul>
        </xsl:for-each-group>
    </xsl:template>

    <xsl:template match="cei:index[@indexName = 'IllUrkGlossar']">
        <xsl:variable name="pm" select="replace(./@lemma, '#', '')"/>
        <xsl:variable name="url" select="concat('/mom/index/IllUrkGlossar/', $pm, '?pm=charter')"/>

        <a target="_blank">
            <xsl:attribute name="title">
                <xsl:value-of select="$url"/>
            </xsl:attribute>
            <xsl:attribute name="class">
                <xsl:text>glossaryInfo</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="href">
                <xsl:value-of select="$url"/>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </a>

    </xsl:template>

    <!-- how to cite -->
    <xsl:template name="howToCite">
        <p>
            <xsl:text>hello world</xsl:text>
        </p>
    </xsl:template>

    <!-- atom entry -->
    <xsl:template name="entry">
        <div class="greyp">
            <div id="versions">
                <ul class="nostyle">
                    <li>
                        <b>
                            <xsl:copy-of select="$sitemap//xrx:*[@key = 'author']"/>
                            <xsl:text>:&#160;</xsl:text>
                        </b>
                        <xsl:value-of select="$cei//atom:author/atom:name/text()"/>
                    </li>
                    <li>
                        <b>
                            <xsl:copy-of select="$sitemap//xrx:*[@key = 'updated']"/>
                            <xsl:text>:&#160;</xsl:text>
                        </b>
                        <xsl:value-of select="$cei//atom:updated/text()"/>
                    </li>
                    <li>
                        <b>
                            <xsl:copy-of select="$sitemap//xrx:*[@key = 'permalink']"/>
                            <xsl:text>:&#160;</xsl:text>
                        </b>
                        <br/>
                        <xsl:value-of select="$cei//atom:link/@atom:href"/>
                    </li>
                    <li>
                        <b>
                            <xsl:copy-of select="$sitemap//xrx:*[@key = 'urn']"/>
                            <xsl:text>:&#160;</xsl:text>
                        </b>
                        <br/>
                        <xsl:value-of select="$cei//atom:id/text()"/>
                    </li>
                </ul>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="exist:match">
        <span style="background:yellow">
            <xsl:apply-templates/>
        </span>
        <xsl:if test="./following-sibling::exist:match">
            <xsl:text>&#160;</xsl:text>
        </xsl:if>
    </xsl:template>

    <!-- copy SITEMAP -->
    <xsl:template match="@* | *" priority="-2">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
