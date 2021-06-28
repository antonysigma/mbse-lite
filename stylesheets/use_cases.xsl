<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="html" indent="yes" />

<xsl:template match="/">
  <html>
  <head>
  <title>Use cases</title>
  <script src="https://www.w3.org/Tools/respec/respec-w3c" class="remove" defer="defer"/>
<script src="https://code.jquery.com/jquery.min.js"></script>
<script src="https://cdn.rawgit.com/jmnote/plantuml-encoder/d133f316/dist/plantuml-encoder.min.js"></script>
  <script class="remove">
 const respecConfig = {
      specStatus: "unofficial",
      github: "Mango-Inc/mbse-lite",
      additionalCopyrightHolders: "<xsl:value-of select="mbse/@copyright"/>",
    };

$(function() {
$(".uml").each(function() {
    const alt = $(this).text();
    const src = "http://localhost:8000/plantuml/svg/" + window.plantumlEncoder.encode( alt );
    $(this).replaceWith($('&lt;img>').attr('src', src).attr('alt', alt));
});
$(".copyright").text("Copyright © <xsl:value-of select="mbse/@copyright"/>.");
$("body").css('background','white');
});
    </script>
  </head>
  <body>
  <section id="abstract">
  <p>This is part 2 of the following series:</p>

  <ol>
  <li><a href="originating_requirements.html">Originating requirements</a></li>
  <li>Use cases (this document)</li>
  <li><a href="product_requirements_specifications.html">Product requirements specification</a></li>
  <li><a href="physical_architecture.html">Physical architecture and interfaces</a></li>
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
    <p><xsl:apply-templates select="description"/></p>

    <figure id="{ @id-uml }">

    <pre class="uml">
    <xsl:apply-templates select="uml"/>
    </pre>

    <figcaption>Use case "<xsl:value-of select="$title"/>"</figcaption>
    </figure>

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
    <xsl:apply-templates select="trace"/>
    </section>

    </section>
</xsl:template>

<xsl:template match="trace">
    <xsl:variable name="idref"><xsl:value-of select="@ref"/></xsl:variable>
    <li>
    <xsl:apply-templates select="//description[../@id=$idref]" mode="link"/>
    </li>
</xsl:template>

<xsl:template match="description" mode="link">
<b>[<a>
<xsl:attribute name="href">
  <xsl:choose>
    <xsl:when test="name(..) = 'interface'">./physical_architecture.html#</xsl:when>
    <xsl:when test="name(..) = 'usecase'">./use_cases.html#</xsl:when>
    <xsl:otherwise>./product_requirements_specifications.html#</xsl:otherwise>
  </xsl:choose>
  <xsl:value-of select="../@id"/>
</xsl:attribute>
<xsl:value-of select="../@id"/></a>] <xsl:value-of select="@brief"/>:</b>
<xsl:value-of select="text()"/>
</xsl:template>

<xsl:template match="pre-condition|main-event|post-condition|alternate-event">
<li><xsl:value-of select="text()"/></li>
</xsl:template>

<xsl:template match="description"><xsl:apply-templates/></xsl:template>

<xsl:template match="aside">
  <aside class="{ @class }"><xsl:value-of select="."/></aside>
</xsl:template>

<xsl:template match="uml"><xsl:apply-templates/></xsl:template>

<xsl:template match="this">(<xsl:value-of select="../../@id"/>: <xsl:value-of select="../../description/@brief"/>)</xsl:template>

</xsl:stylesheet>
