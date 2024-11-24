<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:include href="common.xsl"/>
<xsl:output method="html" indent="yes" />

<xsl:template match="/">
  <html>
  <head>
  <title>Use cases</title>
  <xsl:apply-templates select="." mode="scripts"/>
  </head>
  <body>
  <section id="abstract">
  <p>This is part 2 of the following series:</p>

  <ol>
  <li><a href="originating_requirements.html">Originating requirements</a></li>
  <li>Use cases (this document)</li>
  <li><a href="product_requirements_specifications.html">Product requirements specification</a></li>
  <li><a href="logical_and_physical_architecture.html">Logical and physical architecture</a></li>
  </ol>

  <p>The document captures the high-level use cases requested by the stakeholders.
  To contribute more contents, review and trace each item back to the Originating requirements.
  Then, elaborate further in the system-level specifications.</p>
  </section>

  <section class="introductory">
  <h2>How to use this document</h2>
<p>The document captures missing stakeholder requirements,
adds additional detail, and as a precursor to capturing engineering level requirements.
Well thought out use cases allow engineering level specifications,
especially functional behavior of the syste, to be created more efficiently.
The document also help identify various requirements categories that need to be detailed.</p>

<p>This document is shared with the stakeholders to gain alignment prior to further requirements definition
and analysis.</p>

<figure>
<img src="../static/v-model.png"/>
<figcaption>System engineering V-model.
Use cases helps capture missing high-level requirements.</figcaption>
</figure>

  </section>

<section id="tof"/>

  <xsl:for-each select="//usecase">
      <xsl:sort select="@id"/>
      <xsl:apply-templates select="."/>
  </xsl:for-each>
  </body>
  </html>
</xsl:template>

<xsl:template match="usecase">
    <xsl:variable name="title"><xsl:value-of select="@id"/>: <xsl:value-of select="description/@brief"/></xsl:variable>

    <section>
    <h2 id="{ @id }"><xsl:value-of select="$title"/></h2>
    <div data-format="markdown"><xsl:apply-templates select="description"/></div>

    <xsl:apply-templates select="uml">
      <xsl:with-param name="diagram_type">Use case</xsl:with-param>
    </xsl:apply-templates>

    <section>
    <h2 id="{ @id }-pre-conditions">Pre-conditions</h2>
    <ul>
    <xsl:apply-templates select="pre-condition"/>
    </ul>
    </section>

    <section>
    <h2 id="{ @id }-main-event-flow">Main event flow</h2>
    <ol>
    <xsl:apply-templates select="main-event"/>
    </ol>
    </section>

    <section>
    <h2 id="{ @id }-post-conditions">Post-conditions</h2>
    <ul>
    <xsl:apply-templates select="post-condition"/>
    </ul>
    </section>

    <section>
    <h2 id="{ @id }-alternate-flow">Alternate flow</h2>
    <ul>
    <xsl:apply-templates select="alternate-event"/>
    </ul>
    </section>

    <section>
    <h2 id="{ @id }-trace">Linked requirements</h2>
    <ul>
      <xsl:variable name="id"><xsl:value-of select="@id"/></xsl:variable>
      <xsl:apply-templates select="satisfies"/>
      <xsl:apply-templates select="//*[satisfies/@ref=$id]/description" mode="link"/>
    </ul>

    </section>

    </section>
</xsl:template>

<xsl:template match="satisfies">
    <xsl:variable name="idref"><xsl:value-of select="@ref"/></xsl:variable>
    <xsl:apply-templates select="//description[../@id=$idref]" mode="link"/>
</xsl:template>

<xsl:template match="pre-condition|main-event|post-condition|alternate-event">
<li><xsl:value-of select="text()"/></li>
</xsl:template>

<xsl:template match="description"><xsl:apply-templates/></xsl:template>

<xsl:template match="this">(<xsl:value-of select="../../@id"/>: <xsl:value-of select="../../description/@brief"/>)</xsl:template>

</xsl:stylesheet>
