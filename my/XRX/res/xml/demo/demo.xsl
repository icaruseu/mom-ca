<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xrx="http://www.monasterium.net/NS/xrx" xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:demo="http://www.monasterium.net/NS/demo">
  <xsl:import href="../src/agent/xrx2html.xsl"/>
  <xsl:output method="html" encoding="UTF-8" indent="yes"/>
  <xsl:variable name="filename" select="/xhtml:div/@data-filename"/>
  <xsl:variable name="relativepath" select="/xhtml:div/@data-relativepath"/>

  <xsl:template match="/">
    <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
    <html>
      <head>
        <meta charset="utf-8"/>
        <title>XRX++ - A JavaScript Library for Native and Visual in-Browser XML Editing.</title>
        <script>
          <xsl:attribute name="src">
            <xsl:value-of select="$relativepath"/>
            <xsl:text>lib/codemirror/lib/codemirror.js</xsl:text>
          </xsl:attribute>
        </script>
        <script>
          <xsl:attribute name="src">
            <xsl:value-of select="$relativepath"/>
            <xsl:text>lib/codemirror/mode/javascript/javascript.js</xsl:text>
          </xsl:attribute>
        </script>
        <link rel="stylesheet" type="text/css">
          <xsl:attribute name="href">
            <xsl:value-of select="$relativepath"/>
            <xsl:text>lib/codemirror/lib/codemirror.css</xsl:text>
          </xsl:attribute>
        </link>
        <script>
          <xsl:attribute name="src">
            <xsl:value-of select="$relativepath"/>
            <xsl:text>lib/closure-library/closure/goog/base.js</xsl:text>
          </xsl:attribute>
        </script>
        <script>
          <xsl:attribute name="src">
            <xsl:value-of select="$relativepath"/>
            <xsl:text>src/deps.js</xsl:text>
          </xsl:attribute>
        </script>
        <script>
          goog.require('goog.dom');
          goog.require('goog.dom.forms');
          goog.require('goog.userAgent.product');
          goog.require('client');
          goog.require('xrx');
        </script>
        <link rel="stylesheet" type="text/css">
          <xsl:attribute name="href">
            <xsl:value-of select="$relativepath"/>
            <xsl:text>src/view/default.css</xsl:text>
          </xsl:attribute>
        </link>
        <link rel="stylesheet" type="text/css">
          <xsl:attribute name="href">
            <xsl:value-of select="$relativepath"/>
            <xsl:text>demo/demo.css</xsl:text>
          </xsl:attribute>
        </link>
      </head>
      <body>
        <div class="left">
          <h1>
            <a>
              <xsl:attribute name="href">
                <xsl:value-of select="$relativepath"/>
                <xsl:text>index.xml</xsl:text>
              </xsl:attribute>
              <xrx:text>XRX++</xrx:text>
            </a>
          </h1>
          <i>A JavaScript Library for Native and Visual in-Browser XML Editing</i>
          <div style="height: 3em"><span>&#160;</span></div>
          <h3>Demo Applications</h3>
          <ul class="nostyle">
            <li>
              <a>
                <xsl:attribute name="href">
                  <xsl:value-of select="$relativepath"/>
                  <xsl:text>demo/xml-cursor.xml</xsl:text>
                </xsl:attribute>
                <xsl:if test="$filename = 'xml-cursor.xml'">
                  <xsl:attribute name="class">active</xsl:attribute>
                </xsl:if>
                <xsl:text>XML Cursor</xsl:text>
              </a>
            </li>
            <li>
              <a>
                <xsl:attribute name="href">
                  <xsl:value-of select="$relativepath"/>
                  <xsl:text>demo/model-view-controller.xml</xsl:text>
                </xsl:attribute>
                <xsl:if test="$filename = 'model-view-controller.xml'">
                  <xsl:attribute name="class">active</xsl:attribute>
                </xsl:if>
                <xsl:text>XML Model-View-Controller</xsl:text>
              </a>
            </li>
            <li>
              <a>
                <xsl:attribute name="href">
                  <xsl:value-of select="$relativepath"/>
                  <xsl:text>demo/drag-and-drop.xml</xsl:text>
                </xsl:attribute>
                <xsl:if test="$filename = 'drag-and-drop.xml'">
                  <xsl:attribute name="class">active</xsl:attribute>
                </xsl:if>
                <xsl:text>Edit XML with Drag and Drop</xsl:text>
              </a>
            </li>
            <li>
              <a>
                <xsl:attribute name="href">
                  <xsl:value-of select="$relativepath"/>
                  <xsl:text>demo/wysiwym-xml-authoring.xml</xsl:text>
                </xsl:attribute>
                <xsl:if test="$filename = 'wysiwym-xml-authoring.xml'">
                  <xsl:attribute name="class">active</xsl:attribute>
                </xsl:if>
                <xsl:text>WYSIWYM XML Authoring</xsl:text>
              </a>
            </li>
            <li>
              <a>
                <xsl:attribute name="href">
                  <xsl:value-of select="$relativepath"/>
                  <xsl:text>demo/undo-redo-history.xml</xsl:text>
                </xsl:attribute>
                <xsl:if test="$filename = 'undo-redo-history.xml'">
                  <xsl:attribute name="class">active</xsl:attribute>
                </xsl:if>
                <xsl:text>Undo Redo XML History</xsl:text>
              </a>
            </li>
            <li>
              <a>
                <xsl:attribute name="href">
                  <xsl:value-of select="$relativepath"/>
                  <xsl:text>demo/real-time-editing.xml</xsl:text>
                </xsl:attribute>
                <xsl:if test="$filename = 'real-time-editing.xml'">
                  <xsl:attribute name="class">active</xsl:attribute>
                </xsl:if>
                <xsl:text>Collaborative Real-Time XML Editing</xsl:text>
              </a>
            </li>
            <li>
              <a>
                <xsl:attribute name="href">
                  <xsl:value-of select="$relativepath"/>
                  <xsl:text>demo/large-document-support.xml</xsl:text>
                </xsl:attribute>
                <xsl:if test="$filename = 'large-document-support.xml'">
                  <xsl:attribute name="class">active</xsl:attribute>
                </xsl:if>
                <xsl:text>Large Document Support</xsl:text>
              </a>
            </li>
          </ul>
          <h3>User's Guide</h3>
          <ul class="nostyle">
            <li>
              <a>
                <xsl:attribute name="href">
                  <xsl:value-of select="$relativepath"/>
                  <xsl:text>demo/getting-started.xml</xsl:text>
                </xsl:attribute>
                <xsl:if test="$filename = 'getting-started.xml'">
                  <xsl:attribute name="class">active</xsl:attribute>
                </xsl:if>
                <xsl:text>Getting Started</xsl:text>
              </a>
            </li>
            <li>
              <a>
                <xsl:attribute name="href">
                  <xsl:value-of select="$relativepath"/>
                  <xsl:text>demo/basic-controls.xml</xsl:text>
                </xsl:attribute>
                <xsl:if test="$filename = 'basic-controls.xml'">
                  <xsl:attribute name="class">active</xsl:attribute>
                </xsl:if>
                <xsl:text>Basic Controls</xsl:text>
              </a>
            </li>
            <li>
              <a>
                <xsl:attribute name="href">
                  <xsl:value-of select="$relativepath"/>
                  <xsl:text>demo/textual-ui-controls.xml</xsl:text>
                </xsl:attribute>
                <xsl:if test="$filename = 'textual-ui-controls.xml'">
                  <xsl:attribute name="class">active</xsl:attribute>
                </xsl:if>
                <xsl:text>Textual UI Controls</xsl:text>
              </a>
            </li>
            <li>
              <a>
                <xsl:attribute name="href">
                  <xsl:value-of select="$relativepath"/>
                  <xsl:text>demo/xpath-function-reference.xml</xsl:text>
                </xsl:attribute>
                <xsl:if test="$filename = 'xpath-function-reference.xml'">
                  <xsl:attribute name="class">active</xsl:attribute>
                </xsl:if>
                <xsl:text>XPath Function Reference</xsl:text>
              </a>
            </li>
          </ul>
          <h3>Developer's Guide</h3>
          <ul class="nostyle">
            <li>
              <a>
                <xsl:attribute name="href">
                  <xsl:value-of select="$relativepath"/>
                  <xsl:text>doc/custom-xpath-functions.html</xsl:text>
                </xsl:attribute>
                <xsl:text>Custom Controls</xsl:text>
              </a>
            </li>
            <li>
              <a>
                <xsl:attribute name="href">
                  <xsl:value-of select="$relativepath"/>
                  <xsl:text>doc/custom-controls.html</xsl:text>
                </xsl:attribute>
                <xsl:text>Custom XPath Functions</xsl:text>
              </a>
            </li>
            <li>
              <a>
                <xsl:attribute name="href">
                  <xsl:value-of select="$relativepath"/>
                  <xsl:text>doc/index.html</xsl:text>
                </xsl:attribute>
                <xsl:text>API Reference</xsl:text>
              </a>
            </li>
            <li>
              <a>
                <xsl:attribute name="href">
                  <xsl:value-of select="$relativepath"/>
                  <xsl:text>src/alltests.html</xsl:text>
                </xsl:attribute>
                <xsl:text>Unit Tests</xsl:text>
              </a>
            </li>
          </ul>        
        </div>
        <div class="main">
          <xsl:apply-templates/>
        </div>
        <script type="text/javascript">
          client.install();
        </script>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="demo:header">
    <h2>
      <xsl:apply-templates/>
    </h2>
  </xsl:template>

  <xsl:template match="demo:heading">
    <h3>
      <xsl:apply-templates/>
    </h3>
  </xsl:template>

  <xsl:template match="demo:app">
    <div class="demo">
      <div class="demo-source">
        <xsl:apply-templates/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="demo:mvc">
    <div class="demo-view-model">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="demo:view">
    <div class="demo-view">
      <span class="view-label">View: </span>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="demo:model">
    <div class="demo-model">
      <span class="model-label">Model: </span>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="demo:source">
    <!--div class="source-heading">Source: </div-->
    <textarea class="demo-source" readonly="readonly">
      <xsl:copy-of select="@rows"/>
      <xsl:apply-templates/>
    </textarea>
  </xsl:template>
  
  <xsl:template match="demo:try-it-out-link">
    <p>
      <a>
        <xsl:attribute name="href">
          <xsl:value-of select="@href"/>
        </xsl:attribute>
        <xsl:text>Try it yourself &gt;&gt;</xsl:text>
      </a>
    </p>
  </xsl:template>

</xsl:stylesheet>
