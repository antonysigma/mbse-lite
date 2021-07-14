<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="html" indent="yes" />

<xsl:template match="/">
  <html>
  <head>
  <title>Originating requirements</title>
  <script src="https://www.w3.org/Tools/respec/respec-w3c" class="remove" defer="defer"/>
  <script src="https://code.jquery.com/jquery.min.js"></script>
  <script class="remove">
function changeCopyright(config, document) {
    $('.copyright').text('Copyright © ' + config.additionalCopyrightHolders + '.');
}

function removeW3CWatermark(config, document) {
    $('body').css('background', 'white');
}

const respecConfig = {
    specStatus: 'unofficial',
    github: 'Mango-Inc/mbse-lite',
    additionalCopyrightHolders: '<xsl:value-of select="mbse/@copyright"/>',
    postProcess: [changeCopyright, removeW3CWatermark],
};
    </script>
  </head>
  <body>
  <section id="abstract">
  <p>This is part 1 of the following series:</p>

  <ol>
  <li>Originating requirements (this document)</li>
  <li><a href="use_cases.html">Use cases</a></li>
  <li><a href="product_requirements_specifications.html">Product requirements specification</a></li>
  <li><a href="physical_architecture.html">Physical architecture and interfaces</a></li>
  </ol>

  <p>The document catches all of the wish lists from all stackholders.
  To contribute more contents, review and link each item to the "internal" system model.</p>
  </section>

  <section class="introductory">
  <h2>How to use this document</h2>
<p>The document is created as a catch-all for capturing and sorting through all of
the supplied desires. Typically included are stakeholder requirements, user needs, and a myriad of
other inputs.</p>

<figure>
<img src="../static/v-model.png"/>
<figcaption>System engineering V-model.
Originating requirements captures the high-level requirements from all stakeholders.
Those will be internalized in the System-level requirements.</figcaption>
</figure>

<p>The first step is to import all of the input content into the MBSE database. Many MBSE tools have
a utility that can help with this step. Once the originating requirements have been captured within
the database, the requirements trace begins. Originating requirements can trace to use cases, system
requirements, and interfaces. These
items were selected to capture the behavior (use cases), constraints and performance (system
requirements), and interfaces (interfaces) which are typically contained in input documentation.
Each originating requirement is systematically considered, and then traced to relevant item(s).</p>

<p>Some originating requirements are not traced to anything or are traced to an item that doesn’t
exactly match – this is part of the requirements analysis process that determines which stakeholder
requirements take precedence, and which will not be included in the current project. During this
process, the lower level items do not need to be fully defined – that will occur in the next phase – in
some cases a placeholder for further definition is sufficient.</p>

<p>After the trace is complete, the Originating Requirements Trace document is output. This document
shows the originating requirement, and each item it has been traced to. All of the redundant,
contradictory, and impossible originating requirements are output along with those that are
logically traced. This creates the discussion when, for example, stakeholders see an originating
requirement for a red product traced to a system requirement for a blue product.</p>

<figure>
<img src="../static/trace-requirements.png"/>
<figcaption>Trace all system requirements and specifications back to the orignating requirements.</figcaption>
</figure>

<p>Once the trace has
been agreed to, the originating requirements are set aside, and the focus is solely on the system
requirements.
In certain industries, such as medical, the originating requirements will need to be
updated to ensure that they are coherent and traceable.</p>
  </section>

  <section id="tof"/>

  <xsl:for-each select="//orig">
    <xsl:sort select="@id"/>
    <xsl:apply-templates select="."/>
  </xsl:for-each>
  </body>
  </html>
</xsl:template>

<xsl:template match="orig">
    <section>
    <h2 id="{ @id }"><xsl:value-of select="@id"/>: <xsl:value-of select="description/@brief"/></h2>
    <xsl:value-of select="description"/>

    <xsl:if test="reference/@stakeholder != ''">
    <p>Requested by <xsl:value-of select="reference/@stakeholder"/> at
        <a href="{ reference }"><xsl:value-of select="reference"/></a></p>
    </xsl:if>

    <xsl:if test="trace">
    <p>Requirement internalized in:</p>
    <xsl:apply-templates select="trace"/>
    </xsl:if>

    </section>
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
    <xsl:when test="name(..) = 'interface'">./physical_architecture.html#</xsl:when>
    <xsl:when test="name(..) = 'usecase'">./use_cases.html#</xsl:when>
    <xsl:otherwise>./product_requirements_specifications.html#</xsl:otherwise>
  </xsl:choose>
  <xsl:value-of select="../@id"/>
</xsl:attribute>
<xsl:value-of select="../@id"/></a>] <xsl:value-of select="@brief"/>:</b>
<xsl:value-of select="text()"/>
    </li>
</xsl:template>

</xsl:stylesheet>
