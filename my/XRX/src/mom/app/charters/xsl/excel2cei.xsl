<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.monasterium.net/NS/cei"
  xmlns:cei="http://www.monasterium.net/NS/cei" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  id="excel2cei" version="1.0">

  <!-- main template -->

  <xsl:template match="/excelSheet">
    <xsl:element name="cei:text">
      <xsl:attribute name="type">charter</xsl:attribute>
      <xsl:element name="cei:front">
        <xsl:call-template name="sourceDesc" />
      </xsl:element>
      <xsl:element name="cei:body">
        <xsl:call-template name="idno" />
        <xsl:call-template name="chDesc" />
        <xsl:call-template name="tenor" />
      </xsl:element>
      <xsl:element name="cei:back">
        <xsl:call-template name="persName" />
        <xsl:call-template name="placeName" />
        <xsl:call-template name="divNotes" />
        <xsl:call-template name="index" />
      </xsl:element>
    </xsl:element>
  </xsl:template>


  <!-- sourceDesc -->

  <xsl:template name="sourceDesc">
    <xsl:if test="Quelle_Regest/node()|Quelle_Volltext/node()">
      <xsl:element name="cei:sourceDesc">
        <xsl:if test="Quelle_Regest">
          <xsl:element name="cei:sourceDescRegest">
            <xsl:for-each select="Quelle_Regest">
              <xsl:element name="cei:bibl">
                <xsl:apply-templates select="./node()" />
              </xsl:element>
            </xsl:for-each>
          </xsl:element>
        </xsl:if>
        <xsl:if test="Quelle_Volltext/node()">
          <xsl:element name="cei:sourceDescVolltext">
            <xsl:for-each select="Quelle_Volltext">
              <xsl:element name="cei:bibl">
                <xsl:apply-templates select="./node()" />
              </xsl:element>
            </xsl:for-each>
          </xsl:element>
        </xsl:if>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <!-- idno -->

  <xsl:template name="idno">
    <xsl:for-each select="Signatur">
      <xsl:element name="cei:idno">
        <xsl:apply-templates select="./node()" />
      </xsl:element>
    </xsl:for-each>
  </xsl:template>


  <!-- chDesc -->

  <xsl:template name="chDesc">
    <xsl:element name="cei:chDesc">
      <xsl:call-template name="abstract" />
      <xsl:element name="cei:issued">
        <xsl:for-each select="Ausstellungsort">
          <xsl:element name="cei:placeName">
            <xsl:apply-templates select="./node()" />
          </xsl:element>
        </xsl:for-each>
        <xsl:if test="Einzeldatierung/node()">
          <xsl:element name="cei:date">
            <xsl:attribute name="value">
              <xsl:apply-templates select="Einzeldatierung/node()" />
            </xsl:attribute>
            <xsl:apply-templates select="Datierung_Text/node()" />
          </xsl:element>
        </xsl:if>
        <xsl:if test="Jahr/node()|Monat/node()|Tag/node()">
          <xsl:element name="cei:date">
            <xsl:attribute name="value">
              <xsl:apply-templates select="Jahr/node()" />
              <xsl:choose>
                <xsl:when test="string-length(Monat) = 2">
                  <xsl:apply-templates select="Monat/node()" />
                </xsl:when>
                <xsl:when test="string-length(Monat) = 1">
                  <xsl:text>0</xsl:text>
                  <xsl:apply-templates select="Monat/node()" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>99</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:choose>
                <xsl:when test="string-length(Tag) = 2">
                  <xsl:apply-templates select="Tag/node()" />
                </xsl:when>
                <xsl:when test="string-length(Tag) = 1">
                  <xsl:text>0</xsl:text>
                  <xsl:apply-templates select="Tag/node()" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>99</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="Datierung_Text/node()" />
          </xsl:element>
        </xsl:if>
        <xsl:if test="Zeitraum_von/node()|Zeitraum_bis/node()">
          <xsl:element name="cei:dateRange">
            <xsl:attribute name="from">
              <xsl:apply-templates select="Zeitraum_von/node()" />
            </xsl:attribute>
            <xsl:attribute name="to">
              <xsl:apply-templates select="Zeitraum_bis/node()" />
            </xsl:attribute>
            <xsl:apply-templates select="Datierung_Text/node()" />
          </xsl:element>
        </xsl:if>
        <xsl:if
          test="von_Jahr/node()|von_Monat/node()|von_Tag/node()|bis_Jahr/node()|bis_Monat/node()|bis_Tag/node()">
          <xsl:element name="cei:dateRange">
            <xsl:attribute name="from">
              <xsl:apply-templates select="von_Jahr/node()" />
              <xsl:choose>
                <xsl:when test="string-length(von_Monat) = 2">
                  <xsl:apply-templates select="von_Monat/node()" />
                </xsl:when>
                <xsl:when test="string-length(von_Monat) = 1">
                  <xsl:text>0</xsl:text>
                  <xsl:apply-templates select="von_Monat/node()" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>99</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:choose>
                <xsl:when test="string-length(von_Tag) = 2">
                  <xsl:apply-templates select="von_Tag/node()" />
                </xsl:when>
                <xsl:when test="string-length(von_Tag) = 1">
                  <xsl:text>0</xsl:text>
                  <xsl:apply-templates select="von_Tag/node()" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>99</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="to">
              <xsl:apply-templates select="bis_Jahr/node()" />
              <xsl:choose>
                <xsl:when test="string-length(bis_Monat) = 2">
                  <xsl:apply-templates select="bis_Monat/node()" />
                </xsl:when>
                <xsl:when test="string-length(bis_Monat) = 1">
                  <xsl:text>0</xsl:text>
                  <xsl:apply-templates select="bis_Monat/node()" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>99</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:choose>
                <xsl:when test="string-length(bis_Tag) = 2">
                  <xsl:apply-templates select="bis_Tag/node()" />
                </xsl:when>
                <xsl:when test="string-length(bis_Tag) = 1">
                  <xsl:text>0</xsl:text>
                  <xsl:apply-templates select="bis_Tag/node()" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>99</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="Datierung_Text/node()" />
          </xsl:element>
        </xsl:if>
        <!-- xsl:call-template name="date_sort"/ -->
      </xsl:element>
      <xsl:call-template name="witnessOrig" />
      <xsl:call-template name="witListPar" />
      <xsl:call-template name="diplomaticAnalysis" />
      <xsl:for-each select="Sprache">
        <xsl:element name="cei:lang_MOM">
          <xsl:apply-templates select="./node()" />
        </xsl:element>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>


  <xsl:template name="date_sort">
    <xsl:if test="Einzeldatierung/node()">
      <xsl:element name="cei:date_sort">
        <xsl:apply-templates select="Einzeldatierung/node()" />
      </xsl:element>
    </xsl:if>
    <xsl:if test="Jahr/node()|Monat/node()|Tag/node()">
      <xsl:element name="cei:date_sort">
        <xsl:apply-templates select="Jahr/node()" />
        <xsl:choose>
          <xsl:when test="string-length(Monat) = 2">
            <xsl:apply-templates select="Monat/node()" />
          </xsl:when>
          <xsl:when test="string-length(Monat) = 1">
            <xsl:text>0</xsl:text>
            <xsl:apply-templates select="Monat/node()" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>99</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="string-length(Tag) = 2">
            <xsl:apply-templates select="Tag/node()" />
          </xsl:when>
          <xsl:when test="string-length(Tag) = 1">
            <xsl:text>0</xsl:text>
            <xsl:apply-templates select="Tag/node()" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>99</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
    </xsl:if>
    <xsl:if test="Zeitraum_von/node()">
      <xsl:element name="cei:date_sort">
        <xsl:apply-templates select="Zeitraum_von/node()" />
      </xsl:element>
    </xsl:if>
    <xsl:if test="von_Jahr/node()|von_Monat/node()|von_Tag/node()">
      <xsl:element name="cei:date_sort">
        <xsl:apply-templates select="von_Jahr/node()" />
        <xsl:choose>
          <xsl:when test="string-length(von_Monat) = 2">
            <xsl:apply-templates select="von_Monat/node()" />
          </xsl:when>
          <xsl:when test="string-length(von_Monat) = 1">
            <xsl:text>0</xsl:text>
            <xsl:apply-templates select="von_Monat/node()" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>99</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="string-length(von_Tag) = 2">
            <xsl:apply-templates select="von_Tag/node()" />
          </xsl:when>
          <xsl:when test="string-length(von_Tag) = 1">
            <xsl:text>0</xsl:text>
            <xsl:apply-templates select="von_Tag/node()" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>99</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template name="witnessOrig">
    <xsl:element name="cei:witnessOrig">
      <xsl:for-each select="Bildname[text()]">
        <xsl:element name="cei:figure">
          <xsl:element name="cei:graphic">
            <xsl:attribute name="url">
                <xsl:apply-templates select="./node()" />
              </xsl:attribute>
          </xsl:element>
        </xsl:element>
      </xsl:for-each>
      <xsl:if test="Siegelbeschreibung/node()|Siegler/node()">
        <xsl:element name="cei:auth">
          <xsl:element name="cei:sealDesc">
            <xsl:apply-templates select="Siegelbeschreibung/node()" />
            <xsl:if test="Siegler">
              <xsl:element name="cei:seal">
                <xsl:for-each select="Siegler">
                  <xsl:element name="cei:sigillant">
                    <xsl:apply-templates select="./node()" />
                  </xsl:element>
                </xsl:for-each>
              </xsl:element>
            </xsl:if>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      <xsl:if test="Kanzleivermerke/node()">
        <xsl:element name="cei:nota">
          <xsl:apply-templates select="Kanzleivermerke/node()" />
        </xsl:element>
      </xsl:if>
      <xsl:if
        test="Standort/node()|Standort_Archiv/node()|Standort_Bestand/node()|Standort_Signatur/node()|interneID/node()|Link_zur_Urkunde/node()">
        <xsl:element name="cei:archIdentifier">
          <xsl:apply-templates select="Standort/node()" />
          <xsl:if test="Standort_Archiv/node()">
            <xsl:element name="cei:arch">
              <xsl:apply-templates select="Standort_Archiv/node()" />
            </xsl:element>
          </xsl:if>
          <xsl:if test="Standort_Bestand/node()">
            <xsl:element name="cei:archFond">
              <xsl:apply-templates select="Standort_Bestand/node()" />
            </xsl:element>
          </xsl:if>
          <xsl:if test="Standort_Signatur/node()|interneID/node()">
            <xsl:element name="cei:idno">
              <xsl:if test="interneID/node()">
                <xsl:attribute name="n">
                  <xsl:apply-templates select="interneID/node()" />
                </xsl:attribute>
              </xsl:if>
              <xsl:apply-templates select="Standort_Signatur/node()" />
            </xsl:element>
          </xsl:if>
          <xsl:if test="Alte_Signatur/node()">
            <xsl:element name="cei:altIdentifier">
              <xsl:apply-templates select="Alte_Signatur/node()" />
            </xsl:element>
          </xsl:if>
          <xsl:if test="Link_zur_Urkunde/node()">
            <xsl:element name="cei:ref">
              <xsl:attribute name="target">
                <xsl:apply-templates select="Link_zur_Urkunde/node()" />
              </xsl:attribute>
            </xsl:element>
          </xsl:if>
        </xsl:element>
      </xsl:if>
      <xsl:if test="Beschreibstoff/node()|Masse/node()|Zustand/node()">
        <xsl:element name="cei:physicalDesc">
          <xsl:if test="Beschreibstoff/node()">
            <xsl:element name="cei:material">
              <xsl:apply-templates select="Beschreibstoff/node()" />
            </xsl:element>
          </xsl:if>
          <xsl:if test="Masse/node()">
            <xsl:element name="cei:dimensions">
              <xsl:apply-templates select="Masse/node()" />
            </xsl:element>
          </xsl:if>
          <xsl:if test="Zustand/node()">
            <xsl:element name="cei:condition">
              <xsl:apply-templates select="Zustand/node()" />
            </xsl:element>
          </xsl:if>
        </xsl:element>
      </xsl:if>
      <xsl:if test="Notarielle_Beglaubigung/node()">
        <xsl:element name="cei:auth">
          <xsl:element name="cei:notariusDesc">
            <xsl:apply-templates select="Notarielle_Beglaubigung/node()" />
          </xsl:element>
        </xsl:element>
      </xsl:if>
      <xsl:if test="Ueberlieferung/node()">
        <xsl:element name="cei:traditioForm">
          <xsl:apply-templates select="Ueberlieferung/node()" />
        </xsl:element>
      </xsl:if>
      <xsl:if test="Original/node()">
        <xsl:if test="Original/text() = 'Ja'">
          <xsl:element name="cei:traditioForm">
            <xsl:text>orig.</xsl:text>
          </xsl:element>
        </xsl:if>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template name="witListPar">
    <xsl:element name="cei:witListPar">
      <xsl:if test="Insert/node()">
        <xsl:for-each select="Insert">
          <xsl:element name="cei:witness">
            <xsl:element name="cei:traditioForm">
              <xsl:text>ins. </xsl:text>
            </xsl:element>
            <xsl:apply-templates select="./node()" />
          </xsl:element>
        </xsl:for-each>
      </xsl:if>
      <xsl:if test="Weitere_Ueberlieferungen/node()">
        <xsl:for-each select="Weitere_Ueberlieferungen">
          <xsl:element name="cei:witness">
            <xsl:element name="cei:traditioForm">
              <xsl:text>cop. </xsl:text>
            </xsl:element>
            <xsl:apply-templates select="./node()" />
          </xsl:element>
        </xsl:for-each>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template name="diplomaticAnalysis">
    <xsl:element name="cei:diplomaticAnalysis">
      <xsl:if test="Originaldatierung/node()">
        <xsl:element name="cei:quoteOriginaldatierung">
          <xsl:apply-templates select="Originaldatierung/node()" />
        </xsl:element>
      </xsl:if>
      <xsl:if test="Literatur_allgemein/node()">
        <xsl:element name="cei:listBibl">
          <xsl:for-each select="Literatur_allgemein">
            <xsl:element name="cei:bibl">
              <xsl:value-of select="." />
            </xsl:element>
          </xsl:for-each>
        </xsl:element>
      </xsl:if>
      <xsl:if test="Editionen_Regesten/node()|Editionen/node()">
        <xsl:element name="cei:listBiblEdition">
          <xsl:for-each select="Editionen_Regesten">
            <xsl:element name="cei:bibl">
              <xsl:apply-templates select="./node()" />
            </xsl:element>
          </xsl:for-each>
          <xsl:for-each select="Editionen">
            <xsl:element name="cei:bibl">
              <xsl:apply-templates select="./node()" />
            </xsl:element>
          </xsl:for-each>
        </xsl:element>
      </xsl:if>
      <xsl:if test="Regesten/node()">
        <xsl:element name="cei:listBiblRegest">
          <xsl:for-each select="Regesten">
            <xsl:element name="cei:bibl">
              <xsl:apply-templates select="./node()" />
            </xsl:element>
          </xsl:for-each>
        </xsl:element>
      </xsl:if>
      <xsl:if test="Sekundaerliteratur/node()">
        <xsl:element name="cei:listBiblErw">
          <xsl:for-each select="Sekundaerliteratur">
            <xsl:element name="cei:bibl">
              <xsl:apply-templates select="./node()" />
            </xsl:element>
          </xsl:for-each>
        </xsl:element>
      </xsl:if>
      <xsl:if test="Abbildungen/node()">
        <xsl:element name="cei:listBiblFaksimile">
          <xsl:for-each select="Abbildungen">
            <xsl:element name="cei:bibl">
              <xsl:apply-templates select="./node()" />
            </xsl:element>
          </xsl:for-each>
        </xsl:element>
      </xsl:if>
      <xsl:if test="diplomatischer_Kommentar/node()">
        <xsl:for-each select="diplomatischer_Kommentar">
          <xsl:element name="cei:p">      
            <xsl:apply-templates select="./node()" />
          </xsl:element>
        </xsl:for-each>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template name="abstract">
    <xsl:if test="Regest/node()|Aussteller/node()|Empfaenger/node()">
      <xsl:element name="cei:abstract">
        <xsl:apply-templates select="Regest/node()" />
        <xsl:call-template name="issuer" />
        <xsl:call-template name="recipient" />
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template name="issuer">
    <xsl:if test="Aussteller/node()">
      <xsl:text> Aussteller: </xsl:text>
      <xsl:element name="cei:issuer">
        <xsl:apply-templates select="Aussteller/node()" />
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template name="recipient">
    <xsl:if test="Empfaenger/node()">
      <xsl:text> Empfänger: </xsl:text>
      <xsl:element name="cei:recipient">
        <xsl:apply-templates select="Empfaenger/node()" />
      </xsl:element>
    </xsl:if>
  </xsl:template>


  <!-- tenor -->

  <xsl:template name="tenor">
    <xsl:if test="Transkription/node()">
      <xsl:element name="cei:tenor">
        <xsl:apply-templates select="Transkription/node()" />
      </xsl:element>
    </xsl:if>
  </xsl:template>


  <!-- persName -->

  <xsl:template name="persName">
    <xsl:if test="Zeugen/node()|Personenindex/node()">
      <xsl:if test="Zeugen/node()">
        <xsl:for-each select="Zeugen">
          <xsl:element name="cei:persName">
            <xsl:attribute name="type">
              <xsl:text>Zeuge</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates select="./node()" />
          </xsl:element>
        </xsl:for-each>
      </xsl:if>
      <xsl:if test="Personenindex/node()">
        <xsl:for-each select="Personenindex">
          <xsl:element name="cei:persName">
            <xsl:apply-templates select="./node()" />
          </xsl:element>
        </xsl:for-each>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template name="placeName">
    <xsl:if test="Ortsindex/node()">
      <xsl:for-each select="Ortsindex">
        <xsl:element name="cei:placeName">
          <xsl:apply-templates select="./node()" />
        </xsl:element>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template name="index">
    <xsl:if test="Sachindex/node()">
      <xsl:for-each select="Sachindex">
        <xsl:element name="cei:index">
          <xsl:apply-templates select="./node()" />
        </xsl:element>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template name="divNotes">
    <xsl:if test="Fussnoten/node()">
      <xsl:element name="cei:divNotes">
        <xsl:for-each select="Fussnoten">
          <xsl:element name="cei:note">
            <xsl:apply-templates select="./node()" />
          </xsl:element>
        </xsl:for-each>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@*|*" priority="-2">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
