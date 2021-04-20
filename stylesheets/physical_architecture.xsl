<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="html" indent="yes" />

<xsl:template match="/">
  <html>
  <head>
  <title>Physical architecture and interfaces</title>
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
  <p>This is part 4 of the following series:</p>

  <ol>
  <li><a href="originating_requirements.html">Originating requirements</a></li>
  <li><a href="use_cases.html">Use cases</a></li>
  <li><a href="product_requirements_specifications.html">Product requirements specification</a></li>
  <li>Physical architecture and interfaces (this document)</li>
  </ol>

  <p>The document refines the high-level requirements into system-level specifications.
  To contribute more contents, identify all external interfaces and describe all properties
  that meets the system-level specifications:
   mechanical / optical / electrical / softrware.
  Remove all internal interfaces.</p>
  </section>

  <section class="introductory">
  <h2>How to use this document</h2>
<p>This document follows the Product Requirement Specifications (PRS),
where the interfaces linking various sub-systems are captured.</p>


<p>There are also lower level internal interfaces; these are often the
interfaces that are owned by a single engineer (e.g. the electrical interfaces found on a single circuit
board). These lower level interfaces are not given a number and description, are not turned into
requirements, and instead are captured in lower level specifications and design documentation.</p>

<figure>
<img src="../static/v-model.png"/>
<figcaption>System engineering V-model.
Component-level designs are captured following the system-level specifications.</figcaption>
</figure>

<p>Similar to defining use cases, the process of capturing the architecture via a
Physical Architectual Diagram is helpful to ensure that the interfaces are identified.
For particularly complicated interfaces, the descriptions above can reference a more detailed
document (such as a mechanical interface drawing, electrical pinout, firmware/software
communication protocol, etc.).
</p>

<figure>
<img src="../static/trace-requirements.png"/>
<figcaption>Interface specifications are traced back to the Originating Requirements,
and are verified by the Verification Plans.
The Physical Architecture Diagram (PAD) links all external interfaces with the corresponding
internal components of the system.</figcaption>
</figure>

  </section>

<section id="tof"/>

<xsl:apply-templates select="//architecture"/>
  </body>
  </html>
</xsl:template>

<xsl:template match="architecture">
    <xsl:variable name="title"><xsl:value-of select="@id"/>: <xsl:value-of select="description/@brief"/></xsl:variable>

    <section>
    <h2 id="{ @id }"><xsl:value-of select="$title"/></h2>
    <p><xsl:value-of select="description"/></p>

    <figure id="{ @id }-uml">

    <pre class="uml">
    <xsl:apply-templates select="uml"/>
    </pre>

    <figcaption>Component diagram "<xsl:value-of select="$title"/>"</figcaption>
    </figure>

    <xsl:apply-templates select="interface"/>

    </section>
</xsl:template>

<xsl:template match="interface">
    <xsl:variable name="id"><xsl:value-of select="@id"/></xsl:variable>
    <xsl:variable name="title"><xsl:value-of select="@id"/>: <xsl:value-of select="description/@brief"/></xsl:variable>

    <section class="markdown">
    <h2 id="{ $id }"><xsl:value-of select="$title"/></h2>
    <p><xsl:value-of select="description"/></p>

    <p>Implements:</p>
    <ul>
      <xsl:apply-templates select="//description[../trace/@ref=$id]" mode="link"/>
    </ul>

    <xsl:if test="mechanical">
    <section class="markdown">
    <h3 id="{ @id }-mechanical-descriptions">Mechanical description</h3>
    <ul>
    <xsl:apply-templates select="mechanical"/>
    </ul>
    </section>
    </xsl:if>

    <xsl:if test="optical">
    <section class="markdown">
    <h3 id="{ @id }-optical-descriptions">Optical description</h3>
    <ul>
    <xsl:apply-templates select="optical"/>
    </ul>
    </section>
    </xsl:if>

    <xsl:if test="electrical">
    <section class="markdown">
    <h3 id="{ @id }-electrical-descriptions">Electrical descriptions</h3>
    <ul>
    <xsl:apply-templates select="electrical"/>
    </ul>
    </section>
    </xsl:if>

    <xsl:if test="software">
    <section class="markdown">
    <h3 id="{ @id }-software-descriptions">Software / firmware descriptions</h3>
    <ul>
    <xsl:apply-templates select="software"/>
    </ul>
    </section>
    </xsl:if>
    </section>
</xsl:template>

<xsl:template match="orig">
<xsl:apply-templates select="description" mode="link"/>
<ul>
<xsl:apply-templates select="trace" mode="link"/>
</ul>
</xsl:template>

<xsl:template match="trace">
<xsl:variable name="idref"><xsl:value-of select="@ref"/></xsl:variable>
<xsl:apply-templates select="//description[../@id=$idref]" mode="link"/>
</xsl:template>

<xsl:template match="description" mode="link">
    <li>
<b>[<a>
<xsl:attribute name="href">
  <xsl:choose>
    <xsl:when test="name(..) = 'interface'">#</xsl:when>
    <xsl:when test="name(..) = 'usecase'">./use_cases.html#</xsl:when>
    <xsl:when test="name(..) = 'orig'">./originating_requirements.html#</xsl:when>
    <xsl:otherwise>./product_requirements_specifications.html#</xsl:otherwise>
  </xsl:choose>
  <xsl:value-of select="../@id"/>
</xsl:attribute>
<xsl:value-of select="../@id"/></a>] <xsl:value-of select="@brief"/>:</b>
<xsl:value-of select="text()"/>
    </li>
</xsl:template>

<xsl:template match="mechanical|electrical|software">
<li><xsl:value-of select="text()"/></li>
</xsl:template>

<xsl:template match="uml"><xsl:apply-templates/></xsl:template>

<xsl:template match="this">
<xsl:variable name="idref"><xsl:value-of select="@ref"/></xsl:variable>() "[<xsl:value-of select="@ref"/>] <xsl:value-of select="//*[@id=$idref]/description/@brief"/>"</xsl:template>

</xsl:stylesheet>
