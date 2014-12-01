<xsl:stylesheet xmlns:atom="http://www.w3.org/2005/Atom"
  xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xrx="http://www.monasterium.net/NS/xrx" xmlns:cei="http://www.monasterium.net/NS/cei" id="cei2html"
  xmlns:xhtml="http://www.w3.org/1999/xhtml" version="1.0"
  xmlns="http://www.w3.org/1999/xhtml">
  <xsl:strip-space elements="*" />
  <xsl:variable name="sitemap" select="/xhtml:page/xhtml:div"/>
  <xsl:variable name="cei" select="/xhtml:page//cei:text" />
  
  <xsl:template match="/">
    <xsl:apply-templates select="$sitemap" />
  </xsl:template>
  <xsl:param name="image-base-uri" />

  <!-- calling main templates to insert CEI content into the sitemap -->
  <xsl:template match="xhtml:insert-idno">
    <span>
      <xsl:value-of select="$cei//cei:body/cei:idno/text()" />
    </span>
  </xsl:template>
  <xsl:template match="xhtml:insert-imageselect">
    <xsl:call-template name="imageselect" />
  </xsl:template>
  <xsl:template match="insert-image">
    <xsl:choose>
      <xsl:when test="count($cei//cei:witnessOrig/cei:figure/cei:graphic) &gt; 0">
        <xsl:call-template name="image" />
      </xsl:when>
      <xsl:otherwise>
        <div class="no-graphic">
          <xrx:i18n><xrx:key>no-graphic-available</xrx:key><xrx:default>No graphic available</xrx:default></xrx:i18n>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="xhtml:insert-witnesselect">
    <xsl:choose>
      <xsl:when test="count($cei//cei:witList/cei:witness) &gt; 0">
        <xsl:call-template name="witnesselect">
          <xsl:with-param name="witList" select="$cei//cei:witList/cei:witness" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise />
    </xsl:choose>
  </xsl:template>
  <xsl:template match="xhtml:insert-witList">
    <xsl:param name="count" select="count($cei//cei:witList/cei:witness)" />
    <xsl:for-each select="$cei//cei:witnessOrig|$cei//cei:witListPar/cei:witness">
      <xsl:sort select="." />
      <xsl:call-template name="witness">
        <xsl:with-param name="num" select="position()" />
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>
  <xsl:template match="xhtml:insert-issued">
    <xsl:choose>
      <xsl:when test="$cei//cei:issued//text() != ''">
        <div id="issued">
          <xsl:call-template name="issued" />
        </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>&#160;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="xhtml:insert-abstract">
    <xsl:choose>
      <xsl:when test="$cei//cei:chDesc/cei:abstract/text() != ''">
        <xsl:call-template name="abstract" />
      </xsl:when>
      <xsl:otherwise>
        <div class="p">
          <xsl:text>&#160;</xsl:text>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="xhtml:insert-biblabstract">
    <xsl:choose>
      <xsl:when test="$cei//cei:sourceDesc/cei:sourceDescRegest/cei:bibl != ''">
        <div id="biblabstract">
          <xrx:i18n><xrx:key>source-regest</xrx:key><xrx:default>Source Regest</xrx:default></xrx:i18n>
          <xsl:text>:&#160;</xsl:text>
          <xsl:call-template name="biblabstract" />
        </div>
      </xsl:when>
      <xsl:when test="$cei//cei:chDesc/cei:abstract/text() != ''">
        <xsl:text>&#160;</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="xhtml:insert-abstractnotes">
    <xsl:choose>
      <xsl:when test="count($cei//cei:abstract//cei:hi) &gt; 0">
        <div class="note">
          <div class="line">x</div>
          <xsl:call-template name="abstractnotes" />
        </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>&#160;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="xhtml:insert-diplomaticAnalysis">
    <xsl:call-template name="diplomaticAnalysis" />
  </xsl:template>
  <xsl:template match="xhtml:insert-tenor">
    <xsl:choose>
      <xsl:when test="$cei//cei:body/cei:tenor//text() != ''">
        <xsl:call-template name="tenor" />
      </xsl:when>
      <xsl:otherwise>
        <div class="p">&#160;</div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="xhtml:insert-bibltenor">
    <xsl:choose>
      <xsl:when test="$cei//cei:sourceDesc/cei:sourceDescVolltext/cei:bibl">
        <xsl:call-template name="bibltenor" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="xhtml:insert-tenornotes">
    <xsl:if test="count($cei//cei:tenor//cei:hi) &gt; 0">
      <div class="line">x</div>
      <xsl:call-template name="tenornotes" />
    </xsl:if>
  </xsl:template>
  <xsl:template match="xhtml:insert-persName">
    <xsl:choose>
      <xsl:when test="count($cei//cei:persName/node()) &gt; 0">
        <div id="persName">
          <b>
            <xrx:i18n><xrx:key>persons</xrx:key><xrx:default>Persons</xrx:default></xrx:i18n>
          </b>
          <ul>
            <xsl:call-template name="persName" />
          </ul>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>&#160;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="xhtml:insert-placeName">
    <xsl:choose>
      <xsl:when test="count($cei//cei:placeName/node()) &gt; 0">
        <div id="placeName">
          <b>
            <xrx:i18n><xrx:key>places</xrx:key><xrx:default>Places</xrx:default></xrx:i18n>
          </b>
          <ul>
            <xsl:call-template name="placeName" />
          </ul>
        </div>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="xhtml:insert-item">
    <xsl:choose>
      <xsl:when test="count($cei//cei:index/node()) &gt; 0">
        <div id="item">
          <b>
            <xrx:i18n><xrx:key>items</xrx:key><xrx:default>Items</xrx:default></xrx:i18n>
          </b>
          <ul>
            <xsl:call-template name="item" />
          </ul>
        </div>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="xhtml:insert-dummy" />
  <xsl:template name="message">
    <xsl:param name="message" />
    <xsl:element name="{concat('xrx:', $message/@form)}">
      <xsl:attribute name="key"><xsl:value-of select="$message/@key" /></xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="insert-entry">
    <xsl:call-template name="entry" />
  </xsl:template>
  
  <xsl:template match="xhtml:insert-howToCite">
    <xsl:call-template name="howToCite" />
  </xsl:template>

  <!-- imageselect -->
  <xsl:template name="imageselect">
    <xsl:for-each select="$cei//cei:witnessOrig//cei:graphic/@url">
      <xsl:sort select="." order="ascending" />
      <span>
        <a href="javascript:changeImage('{concat($image-base-uri, .)}')">
          <xsl:value-of select="position()" />
        </a>
        <xsl:text>&#160;</xsl:text>
      </span>
    </xsl:for-each>
  </xsl:template>
  <xsl:template name="image">
    <xsl:for-each select="$cei//cei:witnessOrig/cei:figure/cei:graphic/@url">
      <xsl:sort select="." order="ascending" />
      <xsl:if test="position() = 1">
        <a>
          <xsl:attribute name="href"><xsl:value-of select="concat($image-base-uri, .)" /></xsl:attribute>
          <xsl:element name="img">
            <xsl:attribute name="id"><xsl:text>img</xsl:text></xsl:attribute>
            <xsl:attribute name="src">
              <xsl:value-of select="$image-base-uri" />
              <xsl:value-of select="." />
            </xsl:attribute>
            <xsl:attribute name="name"><xsl:text>image</xsl:text></xsl:attribute>
            <xsl:attribute name="title"><xsl:value-of select="." /></xsl:attribute>
          </xsl:element>
        </a>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- witnesselect -->
  <xsl:template name="witnesselect">
    <xsl:param name="num" select="1" />
    <xsl:param name="witList" />
    <xsl:variable name="count" select="count($witList)" />
    <xsl:choose>
      <xsl:when test="$num &lt;= $count">
        <xsl:element name="a">
          <xsl:attribute name="href"><xsl:text>javascript:showHideDiv('</xsl:text><xsl:value-of select="concat('wit', $num)" /><xsl:text>')</xsl:text></xsl:attribute>
          <xsl:attribute name="class">dark-green</xsl:attribute>
          <xsl:value-of select="$num" />
          &#160;
        </xsl:element>
        <xsl:call-template name="witnesselect">
          <xsl:with-param name="witList" select="$witList" />
          <xsl:with-param name="num" select="$num+1" />
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- notes -->
  <xsl:template name="hi">
    <xsl:param name="scope" />
    <xsl:param name="num" select="1" />
    <xsl:variable name="count" select="count($scope)" />
    <xsl:for-each select="$cei//cei:back//cei:hi">
      <xsl:if test="$scope[$num] = .">
        <sup>
          <xsl:value-of select="$scope[$num]" />
        </sup>
        <xsl:value-of select="./following-sibling::text()" />
        <xsl:if test="./following-sibling::cei:quote">
          <i>
            <xsl:value-of select="./following-sibling::cei:quote" />
          </i>
        </xsl:if>
        <br />
      </xsl:if>
    </xsl:for-each>
    <xsl:choose>
      <xsl:when test="$num &lt;= $count">
        <xsl:call-template name="hi">
          <xsl:with-param name="scope" select="$scope" />
          <xsl:with-param name="num" select="$num+1" />
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- cei matching -->
  <xsl:template match="cei:quote">
    <i>
      <xsl:apply-templates />
    </i>
  </xsl:template>
  <xsl:template match="cei:foreign">
    <i>
      <xsl:apply-templates />
    </i>
  </xsl:template>
  <xsl:template match="cei:hi">
    <xsl:choose>
      <xsl:when test="@rend = 'sup'">
        <sup>
          <xsl:apply-templates />
        </sup>
      </xsl:when>
      <xsl:when test="@rend = 'italics'">
        <i>
          <xsl:apply-templates />
        </i>
      </xsl:when>      
      <xsl:otherwise>
        <span style="background-color:#E6E6E6">
          <xsl:attribute name="title">
             <xsl:value-of select="@rend"/>
          </xsl:attribute>
          <xsl:apply-templates />
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="cei:p">
    <xsl:choose>
      <xsl:when test="./ancestor::cei:physicalDesc">
        <xsl:apply-templates />
      </xsl:when>
      <xsl:otherwise>
        <p>
          <xsl:apply-templates />
        </p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="cei:sup">
   <sup>
     <xsl:apply-templates/>
   </sup>
  </xsl:template>
  <xsl:template match="cei:tenor//cei:lb">
    <span class="cei-lb">&#160;||</span><br/>
  </xsl:template>
  <xsl:template match="cei:lb">
    <br/>
  </xsl:template>
  
  <!-- common elements -->
  <xsl:template match="cei:ref">
    <xsl:element name="a">
      <xsl:attribute name="href">
        <xsl:value-of select="./@target"/>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="starts-with(./@target, '#')">
          <xsl:if test="./@type='footnote'">
            <xsl:attribute name="class">
              <xsl:text>fn-link</xsl:text>              
            </xsl:attribute>
            <xsl:attribute name="id">
              <xsl:text>ref</xsl:text>
              <xsl:value-of select="substring-after(./@target, '#')" />
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
  <xsl:template match="cei:ref[@type='bibliography']">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="cei:persName">
    <span class="cei-persname">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  <xsl:template match="cei:issuer">
    <span class="cei-issuer">
    <xsl:apply-templates/>
    </span>
  </xsl:template>
  <xsl:template match="cei:recipient">
    <span class="cei-recipient">
    <xsl:apply-templates/>
    </span>
  </xsl:template>
  <xsl:template match="cei:index">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="cei:measure">
    <span class="cei-measure">
      <xsl:apply-templates />
    </span>
  </xsl:template>
  
  <xsl:template match="cei:pb">
    <span class="cei-pb">
      <xsl:apply-templates />
    </span>
  </xsl:template>
  
  <xsl:template match="cei:handshift">
    <span class="cei-handshift">
      <xsl:apply-templates />
    </span>
  </xsl:template>
  
  <xsl:template match="cei:add">
    <span class="cei-add">
      <xsl:apply-templates />
    </span>
  </xsl:template>
  

  <!-- witness -->
  <xsl:template name="witness">
    <xsl:param name="num" />
    <xsl:element name="div">
      <xsl:attribute name="class">p</xsl:attribute>
      <xsl:attribute name="id"><xsl:value-of select="concat('wit', $num)" /></xsl:attribute>
      <div class="witness-text" name="wit">
        <span class="num">
          <xsl:value-of select="$num" />
        </span>
        <br />
        <xsl:call-template name="traditioForm" />
        <ul class="nostyle">
          <li>
            <xsl:if test="./cei:archIdentifier/node()">
              <b>
                <xrx:i18n><xrx:key>actual-repository</xrx:key><xrx:default>Actual Repository</xrx:default></xrx:i18n>
                <span>:&#160;</span>
              </b>
            </xsl:if>
            <xsl:if test="./cei:archIdentifier/child::text()">
              <li>
                <xsl:value-of select="./cei:archIdentifier/child::text()" />
              </li>
            </xsl:if>
          </li>
          <ul>
            <xsl:if test="./cei:archIdentifier/cei:arch/node()">
              <li>
                <span>
                  <xrx:i18n><xrx:key>archive</xrx:key><xrx:default>Archive</xrx:default></xrx:i18n>
                  <span>:&#160;</span>
                </span>
                <xsl:value-of select="./cei:archIdentifier/cei:arch" />
              </li>
            </xsl:if>
            <xsl:if test="./cei:archIdentifier/cei:archFond/node()">
              <li>
                <span>
                  <xrx:i18n><xrx:key>fond</xrx:key><xrx:default>Fond</xrx:default></xrx:i18n>
                  <span>:&#160;</span>
                </span>
                <xsl:value-of select="./cei:archIdentifier/cei:archFond" />
              </li>
            </xsl:if>
            <xsl:if test="./cei:archIdentifier/cei:idno/node()">
              <li>
                <span>
                  <xrx:i18n><xrx:key>signature</xrx:key><xrx:default>Signature</xrx:default></xrx:i18n>
                  <span>:&#160;</span>
                </span>
                <xsl:value-of select="./cei:archIdentifier/cei:idno" />
              </li>
            </xsl:if>
            <xsl:if test="./cei:archIdentifier/cei:altIdentifier/node()">
              <li>
                <span>
                  <xrx:i18n><xrx:key>old-signature</xrx:key><xrx:default>Old Signature</xrx:default></xrx:i18n>
                  <span>:&#160;</span>
                </span>
                <xsl:value-of select="./cei:archIdentifier/cei:altIdentifier" />
              </li>
            </xsl:if>
            <xsl:if test="./cei:archIdentifier/cei:idno/@n">
              <li>
                <span>
                  <xrx:i18n><xrx:key>internal-signature</xrx:key><xrx:default>Internal Signature</xrx:default></xrx:i18n>
                  <span>:&#160;</span>
                </span>
                <xsl:value-of select="./cei:archIdentifier/cei:idno/@n" />
              </li>
            </xsl:if>
            <xsl:if test="./cei:archIdentifier/cei:ref/@target">
              <li style="list-style:none">
                <a target="_blank">
                  <xsl:attribute name="href">
                    <xsl:value-of select="./cei:archIdentifier/cei:ref/@target" />
                  </xsl:attribute>
                  <xrx:i18n><xrx:key>charter-on-archives-website</xrx:key><xrx:default>Charter on the archive's website</xrx:default></xrx:i18n>
                </a>
              </li>
            </xsl:if>
          </ul><br/>
          <xsl:choose>
            <xsl:when test="./cei:auth/cei:sealDesc/cei:seal/cei:sigillant/text() !=''">
              <li>
                <b>
                  <xrx:i18n><xrx:key>sigillant</xrx:key><xrx:default>Sigillant</xrx:default></xrx:i18n>
                  <span>:&#160;</span>
                </b>
                <xsl:for-each select="./cei:auth/cei:sealDesc/cei:seal/cei:sigillant">
                  <xsl:apply-templates select="." />
                  <xsl:if test="position() != last()">
                    <xsl:text>,</xsl:text>
                  </xsl:if>
                </xsl:for-each>
              </li>
            </xsl:when>
          </xsl:choose>
          <xsl:choose>
            <xsl:when test="./cei:auth/cei:sealDesc/text() !=''">
              <li>
                <b>
                  <xrx:i18n><xrx:key>sealDescription</xrx:key><xrx:default>Seal</xrx:default></xrx:i18n>
                  <span>:&#160;</span>
                </b>
                <xsl:apply-templates select="./cei:auth/cei:sealDesc" />
                <xsl:apply-templates select="./cei:auth/cei:sealDesc/cei:dimensions" />
              </li>
            </xsl:when>
          </xsl:choose>
          <xsl:choose>
            <xsl:when test="count(./cei:auth/cei:notariusDesc/node()) &gt; 0">
              <li>
                <b>
                  <xrx:i18n><xrx:key>notarius-description</xrx:key><xrx:default>Notarius Description</xrx:default></xrx:i18n>
                  <span>:&#160;</span>
                </b>
                <xsl:apply-templates select="./cei:auth/cei:notariusDesc" />
              </li>
            </xsl:when>
          </xsl:choose>
          <xsl:apply-templates select="./cei:physicalDesc" />
          <xsl:choose>
            <xsl:when test="./cei:nota/text() != ''">
              <li>
                <b>
                  <xrx:i18n><xrx:key>note</xrx:key><xrx:default>Nota</xrx:default></xrx:i18n>
                  <span>:&#160;</span>
                </b>
                <xsl:for-each select="./cei:nota">
                  <xsl:apply-templates />
                </xsl:for-each>
              </li>
            </xsl:when>
          </xsl:choose>
          <xsl:choose>
            <xsl:when test="count(./cei:figure/cei:graphic) &gt; 0">
              <b>
                <xrx:i18n><xrx:key>graphics</xrx:key><xrx:default>Graphics</xrx:default></xrx:i18n>
                <xsl:text>:&#160;</xsl:text>
              </b>
              <div>
                <xsl:for-each select="./cei:figure/cei:graphic/@url">
                  <xsl:sort select="." />
                    <xsl:element name="a">
                      <xsl:attribute name="href">
                        <xsl:text>javascript:changeGraphic('wit</xsl:text>
                        <xsl:value-of select="$num"/>
                        <xsl:text>', '</xsl:text>
                        <xsl:if test="not(contains(., '/'))">
                         <xsl:value-of select="$image-base-uri" />
                        </xsl:if>
                        <xsl:value-of select="." />
                        <xsl:text>')</xsl:text>
                      </xsl:attribute>
                      <xsl:text>&#160;(</xsl:text>
                      <xsl:value-of select="position()" />
                      <xsl:text>)&#160;</xsl:text>
                    </xsl:element>
                </xsl:for-each>
              </div>
            </xsl:when>
          </xsl:choose>
        </ul>
      </div>
      <xsl:choose>
        <xsl:when test="count(./cei:figure/cei:graphic) != 0">
          <div class="witness-graphic">
            <xsl:for-each select="cei:figure/cei:graphic/@url">
              <xsl:sort select="." />
              <xsl:if test="position() = 1">
                <xsl:element name="img">
                  <xsl:attribute name="src">
                   <xsl:if test="not(contains(., '/'))">
                     <xsl:value-of select="$image-base-uri" />
                   </xsl:if>
                   <xsl:value-of select="." />
                  </xsl:attribute>
                  <xsl:attribute name="name">
                   <xsl:text>wit</xsl:text>
                   <xsl:value-of select="$num"/>
                  </xsl:attribute>
                  <xsl:attribute name="id"><xsl:text>graphic</xsl:text></xsl:attribute>
                  <xsl:attribute name="title">
                    <xsl:value-of select="." />
                  </xsl:attribute>
                </xsl:element>
              </xsl:if>
            </xsl:for-each>
          </div>
        </xsl:when>
        <xsl:otherwise>
          <div class="no-graphic">
            <xsl:copy-of select="$sitemap//xrx:*[@key='noGraphicAvailable']" />
          </div>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>
  <xsl:template match="cei:physicalDesc">
   <xsl:apply-templates/>
  </xsl:template>
  <xsl:template name="traditioForm">
    <xsl:apply-templates select="./cei:traditioForm" />
    <br />
    <xsl:apply-templates select="./child::text()" />
  </xsl:template>
  <xsl:template match="cei:material">
    <xsl:if test="./node()">
	    <li>
	      <b>
	        <xrx:i18n><xrx:key>material</xrx:key><xrx:default>Material</xrx:default></xrx:i18n>
	        <xsl:text>:&#160;</xsl:text>
	      </b>
	      <xsl:apply-templates />
	    </li>
	  </xsl:if>
  </xsl:template>
  <xsl:template match="cei:condition">
    <xsl:if test="./node()">
	    <li>
	      <b>
	        <xrx:i18n><xrx:key>condition</xrx:key><xrx:default>Condition</xrx:default></xrx:i18n>
	        <xsl:text>:&#160;</xsl:text>
	      </b>
	      <xsl:apply-templates />
	    </li>
	  </xsl:if>
  </xsl:template>
  <xsl:template match="cei:dimensions">
    <xsl:choose>
      <xsl:when test="./ancestor::cei:physicalDesc">
        <xsl:if test="./node()">
	        <li>
	          <b>
	            <xrx:i18n><xrx:key>dimensions</xrx:key><xrx:default>Dimensions</xrx:default></xrx:i18n>
	            <xsl:text>:&#160;</xsl:text>
	          </b>
	          <xsl:apply-templates />
	        </li>
	      </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="cei:arch">
    <xsl:apply-templates />
    <br />
  </xsl:template>
  <xsl:template match="cei:archFonds">
    <xsl:apply-templates />
    <br />
  </xsl:template>
  <xsl:template match="cei:idno">
    <xsl:apply-templates />
    <br />
  </xsl:template>

  <!-- issued -->
  <xsl:template match="cei:dateRange">
    <xsl:value-of select="text()" />
  </xsl:template>
  <xsl:template match="cei:date">
    <xsl:apply-templates />
  </xsl:template>
  <xsl:template match="cei:placeName">
    <span class="cei-placename">
      <xsl:apply-templates />
    </span>
  </xsl:template>
  <xsl:template name="issued">
    <xsl:apply-templates select="$cei//cei:issued/cei:dateRange" />
    <xsl:apply-templates select="$cei//cei:issued/cei:date" />
    <xsl:if test="$cei//cei:issued/cei:placeName">
      <xsl:if test="$cei//cei:issued/cei:dateRange|$cei//cei:issued/cei:date">
        <xsl:text>, </xsl:text>
      </xsl:if>
      <xsl:apply-templates select="$cei//cei:issued/cei:placeName" />
    </xsl:if>
  </xsl:template>

  <!-- abstract -->
  <xsl:template name="abstract">
    <xsl:apply-templates select="$cei//cei:chDesc/cei:abstract" />
  </xsl:template>
  <xsl:template match="cei:abstract">
    <xsl:apply-templates />
  </xsl:template>
  <xsl:template match="cei:bibl">
    <xsl:apply-templates />
  </xsl:template>
  <xsl:template name="biblabstract">
    <xsl:apply-templates select="$cei//cei:sourceDesc/cei:sourceDescRegest/cei:bibl" />
  </xsl:template>
  <xsl:template name="abstractnotes">
    <xsl:call-template name="hi">
      <xsl:with-param name="scope" select="$cei//cei:issued//cei:hi" />
    </xsl:call-template>
    <xsl:call-template name="hi">
      <xsl:with-param name="scope" select="$cei//cei:abstract//cei:hi" />
    </xsl:call-template>
  </xsl:template>

  <!-- diplomaticAnalysis -->
  <xsl:template name="diplomaticAnalysis">
    <div class="p">
      <xsl:apply-templates select="$cei//cei:chDesc/cei:diplomaticAnalysis" mode="diplA" />
      <xsl:if test="$cei//cei:lang_MOM/text() != ''">
        <br />
        <br />
        <b>
          <xrx:i18n><xrx:key>lang</xrx:key><xrx:default>Language</xrx:default></xrx:i18n>
        </b>
        <xsl:text>:&#160;</xsl:text>
        <xsl:apply-templates select="$cei//cei:lang_MOM" />
      </xsl:if>
      <xsl:if test="$cei//cei:divNotes/cei:note/node()">
        <br />
        <br />
        <b>
          <xrx:i18n><xrx:key>notes</xrx:key><xrx:default>Notes</xrx:default></xrx:i18n>
        </b>
        <xsl:text>:&#160;</xsl:text>
          <xsl:apply-templates select="$cei//cei:divNotes/cei:note"/>
      </xsl:if>
    </div>
  </xsl:template>
  <xsl:template match="cei:divNotes/cei:note">
    <div class="note">
          <xsl:if test="@id">
            <xsl:attribute name="id" select="@id" />
          </xsl:if>
          <xsl:apply-templates/>
          <xsl:if test="position() != last()">
            <xsl:text>,&#160;</xsl:text>
          </xsl:if>
    </div>
  </xsl:template>
  <xsl:template match="cei:listBiblEdition" mode="diplA">
    <div>
      <xsl:if test="./cei:bibl/node()">
	      <b>
	        <xrx:i18n><xrx:key>editions</xrx:key><xrx:default>Editions</xrx:default></xrx:i18n>
	        <span>:&#160;</span>
	      </b>
	      <ul>
	        <xsl:for-each select="cei:bibl">
	          <xsl:call-template name="bibl" />
	        </xsl:for-each>
	      </ul>
	    </xsl:if>
    </div>
  </xsl:template>
  <xsl:template match="cei:listBiblRegest" mode="diplA">
    <div>
      <xsl:if test="./cei:bibl/node()">
	      <b>
	        <xrx:i18n><xrx:key>abstracts</xrx:key><xrx:default>Abstracts</xrx:default></xrx:i18n>
	        <span>:&#160;</span>
	      </b>
	      <ul>
	        <xsl:for-each select="cei:bibl">
	          <xsl:call-template name="bibl" />
	        </xsl:for-each>
	      </ul>
	    </xsl:if>
    </div>
  </xsl:template>
  <xsl:template match="cei:listBibl" mode="diplA">
    <div>
      <xsl:if test="./cei:bibl/node()">
	      <b>
	        <xrx:i18n><xrx:key>references</xrx:key><xrx:default>References</xrx:default></xrx:i18n>
	        <span>:&#160;</span>
	      </b>
	      <ul>
	        <xsl:for-each select="cei:bibl">
	          <xsl:call-template name="bibl" />
	        </xsl:for-each>
	      </ul>
	    </xsl:if>
    </div>
  </xsl:template>
  <xsl:template match="cei:listBiblErw" mode="diplA">
    <div>
      <xsl:if test="./cei:bibl/node()">
	      <b>
	        <xrx:i18n><xrx:key>secondary-literature</xrx:key><xrx:default>Secondary Literature</xrx:default></xrx:i18n>
	        <span>:&#160;</span>
	      </b>
	      <ul>
	        <xsl:for-each select="cei:bibl">
	          <xsl:call-template name="bibl" />
	        </xsl:for-each>
	      </ul>
	    </xsl:if>
    </div>
  </xsl:template>
  <xsl:template match="cei:listBiblFaksimile" mode="diplA">
    <div>
      <xsl:if test="./cei:bibl/node()">
	      <b>
	        <xrx:i18n><xrx:key>facsimile</xrx:key><xrx:default>Facsimile</xrx:default></xrx:i18n>
	        <span>:&#160;</span>
	      </b>
	      <ul>
	        <xsl:for-each select="cei:bibl">
	          <xsl:call-template name="bibl" />
	        </xsl:for-each>
	      </ul>
	    </xsl:if>
    </div>
  </xsl:template>
  <xsl:template match="cei:listBiblEdition">
    <xsl:choose>
      <xsl:when test="@type = 'regesta'">
        <xsl:copy-of select="$sitemap//xrx:*[@key='biblregesta']" />
        <xsl:text>:&#160;</xsl:text>
        <br />
        <p>
          <ul>
            <xsl:for-each select="cei:bibl">
              <xsl:call-template name="bibl" />
            </xsl:for-each>
          </ul>
        </p>
      </xsl:when>
      <xsl:when test="@type = 'facsimilia'">
        <xsl:copy-of select="$sitemap//xrx:*[@key='biblfacsimilia']" />
        <xsl:text>:&#160;</xsl:text>
        <br />
        <p>
          <ul>
            <xsl:for-each select="cei:bibl">
              <xsl:call-template name="bibl" />
            </xsl:for-each>
          </ul>
        </p>
      </xsl:when>
      <xsl:when test="@type = 'studies'">
        <xsl:copy-of select="$sitemap//xrx:*[@key='biblstudies']" />
        <xsl:text>:&#160;</xsl:text>
        <br />
        <p>
          <ul>
            <xsl:for-each select="cei:bibl">
              <xsl:call-template name="bibl" />
            </xsl:for-each>
          </ul>
        </p>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="bibl">
    <li>
      <xsl:apply-templates />
    </li>
  </xsl:template>
  <xsl:template match="cei:p" mode="diplA">
    <xsl:if test="./node()">
	    <div>
	      <xrx:i18n><xrx:key>comment</xrx:key><xrx:default>Comment</xrx:default></xrx:i18n>
	      <xsl:text>:&#160;</xsl:text>
	      <xsl:for-each select=".">
	        <xsl:apply-templates />
	      </xsl:for-each>
	    </div>
	  </xsl:if>
  </xsl:template>
  <xsl:template match="cei:quoteOriginaldatierung" mode="diplA">
    <xsl:if test="./node()">
	    <p>
	      <b>
	        <xrx:i18n><xrx:key>quote</xrx:key><xrx:default>Quote</xrx:default></xrx:i18n>
	      </b>
	      <xsl:text>:&#160;</xsl:text>
	      <i>
	        <xsl:apply-templates />
	      </i>
	    </p>
	  </xsl:if>
  </xsl:template>

  <!-- tenor -->
  <xsl:template name="tenor">
      <xsl:apply-templates select="$cei//cei:body/cei:tenor" />
  </xsl:template>
  <xsl:template match="cei:pTenor">
    <p>
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  <xsl:template match="cei:tenor">
    <xsl:apply-templates />
  </xsl:template>
  <xsl:template name="bibltenor">
    <div id="bibltenor">
      <xrx:i18n><xrx:key>source-fulltext</xrx:key><xrx:default>Source Fulltext</xrx:default></xrx:i18n>
      <xsl:text>:&#160;</xsl:text>
      <xsl:apply-templates select="$cei//cei:sourceDesc/cei:sourceDescVolltext/cei:bibl" />
    </div>
  </xsl:template>
  <xsl:template name="tenornotes">
    <div class="note">
      <span style="color:white">x</span>
      <xsl:call-template name="hi">
        <xsl:with-param name="scope" select="$cei//cei:tenor//cei:hi" />
      </xsl:call-template>
    </div>
  </xsl:template>

  <!-- index persName -->
  <xsl:template name="persName">
    <xsl:for-each select="$cei//cei:persName">
      <xsl:sort select="."/>
      <xsl:if test="./node()">
	      <li>
	        <xsl:apply-templates/>
	      </li>
	      <ul class="inline">
	        <xsl:call-template name="lang" />
	        <xsl:call-template name="reg" />
	        <xsl:call-template name="existent" />
	        <xsl:call-template name="type" />
	      </ul>
	    </xsl:if>
    </xsl:for-each>
  </xsl:template>
  <xsl:template name="lang">
    <xsl:choose>
      <xsl:when test="./@lang">
        <li>
          <xrx:i18n><xrx:key>lang</xrx:key><xrx:default>Language</xrx:default></xrx:i18n>
          <xsl:text>:&#160;</xsl:text>
          <xsl:value-of select="./@lang" />
        </li>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="reg">
    <xsl:choose>
      <xsl:when test="./@reg">
        <li>
          <xrx:i18n><xrx:key>regular-form</xrx:key><xrx:default>Regular Form</xrx:default></xrx:i18n>
          <xsl:text>:&#160;</xsl:text>
          <xsl:value-of select="./@reg" />
        </li>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="type">
    <xsl:choose>
      <xsl:when test="./@type">
        <li>
          <xrx:i18n><xrx:key>type</xrx:key><xrx:default>Type</xrx:default></xrx:i18n>
          <xsl:text>:&#160;</xsl:text>
          <xsl:value-of select="./@type" />
        </li>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="existent">
    <xsl:choose>
      <xsl:when test="./@existent">
        <li>
          <xrx:i18n><xrx:key>existent</xrx:key><xrx:default>Existent</xrx:default></xrx:i18n>
          <xsl:text>:&#160;</xsl:text>
          <xsl:value-of select="./@existent" />
        </li>
      </xsl:when>
    </xsl:choose>
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
	        <xsl:call-template name="lang" />
	        <xsl:call-template name="reg" />
	        <xsl:call-template name="existent" />
	        <xsl:call-template name="type" />
	      </ul>
	    </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- index -->
  <xsl:template name="item">
  <xsl:for-each-group select="$cei//cei:index" group-by="@type">
        <xsl:sort select="@type"/>
        <xsl:for-each select="$cei//cei:index">
      <xsl:sort select="."/>
      <xsl:if test="./node()">
	      <li>
	        <xsl:apply-templates/>
	      </li>
	      <ul class="inline">
	        <xsl:call-template name="lang" />
	        <xsl:call-template name="reg" />
	        <xsl:call-template name="existent" />
	        <xsl:call-template name="type" />
	      </ul>
	    </xsl:if>
    </xsl:for-each>
    </xsl:for-each-group>  
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
              <xsl:copy-of select="$sitemap//xrx:*[@key='author']" />
              <xsl:text>:&#160;</xsl:text>
            </b>
            <xsl:value-of select="$cei//atom:author/atom:name/text()" />
          </li>
          <li>
            <b>
              <xsl:copy-of select="$sitemap//xrx:*[@key='updated']" />
              <xsl:text>:&#160;</xsl:text>
            </b>
            <xsl:value-of select="$cei//atom:updated/text()" />
          </li>
          <li>
            <b>
              <xsl:copy-of select="$sitemap//xrx:*[@key='permalink']" />
              <xsl:text>:&#160;</xsl:text>
            </b>
            <br />
            <xsl:value-of select="$cei//atom:link/@atom:href" />
          </li>
          <li>
            <b>
              <xsl:copy-of select="$sitemap//xrx:*[@key='urn']" />
              <xsl:text>:&#160;</xsl:text>
            </b>
            <br />
            <xsl:value-of select="$cei//atom:id/text()" />
          </li>
        </ul>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="exist:match">
    <span style="background:yellow">
      <xsl:apply-templates />
    </span>
    <xsl:if test="./following-sibling::exist:match">
      <xsl:text>&#160;</xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- copy SITEMAP -->
  <xsl:template match="@*|*" priority="-2">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>