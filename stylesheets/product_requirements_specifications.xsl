<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="html" indent="yes" />
<xsl:key name="group_id" match="//categories" use="@group"/>

<xsl:template match="/">
  <html>
  <head>
  <title>Product requirements specification</title>
  <link rel="stylesheet" href="https://github.com/tabatkins/railroad-diagrams/raw/gh-pages/railroad.css"/>
  <script src="https://www.w3.org/Tools/respec/respec-w3c" class="remove" defer="defer"/>
  <script src="https://code.jquery.com/jquery.min.js"></script>
  <script src="https://cdn.rawgit.com/jmnote/plantuml-encoder/d133f316/dist/plantuml-encoder.min.js"></script>
  <script src="https://polyfill.io/v3/polyfill.min.js?features=es6"></script>
  <script id="MathJax-script" async="async" src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
  <script src="https://github.com/tabatkins/railroad-diagrams/raw/gh-pages/railroad.js"></script>
  <script src="../static/main.js"></script>
  <script class="remove">
const plantuml_host = '<xsl:value-of select="mbse/@plantuml_host"/>/plantuml/svg/';
const idef0svg_host = '<xsl:value-of select="mbse/@idef0svg_host"/>/svg/';

const localBiblio = {
<xsl:apply-templates select="//document/reference"/>
};

const respecConfig = getRespecConfig('<xsl:value-of select="mbse/@copyright"/>', localBiblio);
    </script>
  </head>
  <body>
  <section id="abstract">
  <p>This is part 3 of the following series:</p>

  <ol>
  <li><a href="originating_requirements.html">Originating requirements</a></li>
  <li><a href="use_cases.html">Use cases</a></li>
  <li>Product requirements specification (this document)</li>
  <li><a href="logical_and_physical_architecture.html">Logical and physical architecture</a></li>
  </ol>

  <p>The document refines the high-level requirements into system-level specifications.
  To contribute more contents, analyze and elaborate further the constraints, performances, and behaviors
  by the domain-specific knowledge (Mechanical / Electrical / Optical / Software).
  More importantly, suggest verification plans to test each one.</p>
  </section>

  <section class="introductory">
  <h2>How to use this document</h2>
<p>The document refines and analyzes the system-level requirements.
Since good system-level requirements aren’t complete unless they are testable,
verification is also planned. The goal of this phase is to provide the engineering team with the
inputs they need to architect the product.</p>

<figure>
<img src="../static/v-model.png"/>
<figcaption>System engineering V-model.
System Requirements refine and internalize the stakeholder needs in the engineering level,
and in turn can be verified by Verification Plans.</figcaption>
</figure>

<p>This is communicated via a Product Requirements Specification (PRS).
For ease of review, the PRS has been divided into three separate parts – the
Constraint Specification, the Functional Specification, and the Verification Plan.
A note on nomenclature – ‘system-level requirements’ are captured in the constraints specification items
and in the Behavior Diagrams/functions of the Functional Specifications.</p>

<p>The Constraint Specification contains constraints on the system such as physical characteristics and
the environment.
The Functional Specification includes the behavior and performance requirements.
The Verification Plan contains high level test planning, and traceability back to the system level
requirements.</p>

<figure>
<img src="../static/document-sources.png"/>
<figcaption>Documents are generated on-demand from a central System Model Database.
The contents of Product Requirement and Specifications (PRS) are gathered from
the system-level requirements and verifications plans.
All chapters can be traced back to the Originating requirements.</figcaption>
</figure>

<p>The main items used in this Constraint/Functional specification phase trace from the use cases developed in the previous phase.
Walking through the use cases step by step is a systematic method to decompose the relevant
requirements.</p>

<p>The verification item is used to plan verification activities at a high level. This allows the
stakeholders and engineers to agree on the depth and complexity of testing required. Knowing this,
testing schedules, cost, and equipment can be planned, and detailed test procedures written.</p>

<figure>
<img src="../static/trace-requirements.png"/>
<figcaption>System requirements and functions are decomposed from the use cases,
which in turn is verified by the Verification plans</figcaption>
</figure>

  </section>


<section id="tof"/>

<section>
<h2 id="constraints">Constraint specifications</h2>

<xsl:for-each select="//categories[generate-id() = generate-id(key('group_id', @group)[1])]">
<xsl:call-template name="constraints_by_group">
      <xsl:with-param name="group" select = "@group"/>
</xsl:call-template>
</xsl:for-each>

</section>

<section>
<h2 id="functional">Functional specifications</h2>
  <xsl:for-each select="//behavior">
      <xsl:sort select="substring-after(@id, '-')" data-type="number"/>
      <xsl:apply-templates select="."/>
  </xsl:for-each>
</section>

<section>
<h2 id="verification">Verification plan</h2>
  <xsl:for-each select="//verification">
      <xsl:sort select="substring-after(@id, '-')" data-type="number"/>
      <xsl:apply-templates select="."/>
  </xsl:for-each>
</section>

  </body>
  </html>
</xsl:template>

<xsl:template name = "constraints_by_group">
  <xsl:param name = "group"/>
  <section>
  <h2><xsl:value-of select="$group"/></h2>
  <xsl:for-each select="//*[(name() = 'constraint' or name() = 'performance') and categories/@group=$group]">
      <xsl:sort select="substring-after(@id,'-')" data-type="number"/>
      <xsl:apply-templates select="."/>
  </xsl:for-each>
  <xsl:apply-templates/>
  </section>
</xsl:template>

<xsl:template match="constraint|performance">
    <xsl:variable name="id"><xsl:value-of select="@id"/></xsl:variable>
    <section data-format="markdown">
    <h2 id="{ $id }"><xsl:value-of select="$id"/>: <xsl:value-of select="description/@brief"/></h2>

    <ul>
    <li><b>Allocation: </b> <xsl:value-of select="categories/@allocation"/></li>
    <li><b>Discipline: </b> <xsl:value-of select="categories/@discipline"/></li>
    </ul>

    <div><xsl:apply-templates select="description"/></div>

    <xsl:if test="rationale/text() != ''">
    <p><b>Rationale:</b> <xsl:value-of select="rationale"/></p>
    </xsl:if>

    <p>Satisfies:</p>
    <ul>
    <xsl:apply-templates select="satisfies"/>
    </ul>

    <p>Designs directly impacted by this:</p>
    <ul>
      <xsl:apply-templates select="//*[satisfies/@ref=$id]/description" mode="link"/>
    </ul>

    <p>Verification plans:</p>
    <ul>
    <xsl:apply-templates select="test"/>
    </ul>
    </section>
</xsl:template>

<xsl:template match="behavior">
  <section>
    <xsl:variable name="title"><xsl:value-of select="@id"/>: <xsl:value-of select="description/@brief"/></xsl:variable>
    <h2 id="{ @id }"><xsl:value-of select="$title"/></h2>
    <div data-format="markdown"><xsl:apply-templates select="description"/></div>

    <figure id="{ @id }-uml">
    <xsl:variable name="id"><xsl:value-of select="@id"/></xsl:variable>
    <xsl:apply-templates select="uml|idef0"/>
    </figure>

    <xsl:apply-templates select="function"/>
  </section>
</xsl:template>

<xsl:template match="function">
    <xsl:variable name="title"><xsl:value-of select="@id"/>: <xsl:value-of select="description/@brief"/></xsl:variable>

    <section>
    <h2 id="{ @id }"><xsl:value-of select="$title"/></h2>
    <div data-format="markdown"><xsl:apply-templates select="description"/></div>

    <p>Linked requirements:</p>
    <ul>
    <xsl:for-each select="satisfies">
      <xsl:apply-templates select="."/>

      <xsl:variable name="id_descendent"><xsl:value-of select="@ref"/></xsl:variable>
      <xsl:apply-templates select="//behavior[@id=$id_descendent]/function/satisfies"/>
    </xsl:for-each>
    </ul>
    </section>
</xsl:template>

<xsl:template match="verification">
    <xsl:variable name="id"><xsl:value-of select="@id"/></xsl:variable>
    <xsl:variable name="title"><xsl:value-of select="@id"/>: <xsl:value-of select="description/@brief"/></xsl:variable>

    <section data-format="markdown">
    <h2 id="{ @id }"><xsl:value-of select="$title"/></h2>

    <ul>
    <li><b>Allocation: </b> <xsl:value-of select="categories/@allocation"/></li>
    <li><b>Discipline: </b> <xsl:value-of select="categories/@discipline"/></li>
    </ul>

    <div><xsl:apply-templates select="description"/></div>

    <p>Linked requirements:</p>
    <ul>
      <xsl:apply-templates select="//*[test/@ref=$id]/description" mode="link"/>
    </ul>
    </section>
</xsl:template>

<xsl:template match="aside">
  <aside class="{ @class }"><xsl:value-of select="."/></aside>
</xsl:template>

<xsl:template match="figure">
  <figure>
    <img src="{ @src }"/>
    <figcaption><xsl:value-of select="."/></figcaption>
  </figure>
</xsl:template>

<xsl:template match="uml">
    <xsl:variable name="title"><xsl:value-of select="../@id"/>: <xsl:value-of select="../description/@brief"/></xsl:variable>
    <pre class="uml">
    <xsl:apply-templates/>
    </pre>

    <figcaption>Activity diagram "<xsl:value-of select="$title"/>"</figcaption>
</xsl:template>

<xsl:template match="idef0">
    <xsl:variable name="title"><xsl:value-of select="../@id"/>: <xsl:value-of select="../description/@brief"/></xsl:variable>
    <pre class="idef0">
    <xsl:apply-templates/>
    </pre>

    <figcaption>Flow diagram "<xsl:value-of select="$title"/>"</figcaption>
</xsl:template>

<xsl:template match="this">
  <xsl:variable name="idref"><xsl:value-of select="@ref"/></xsl:variable>
<xsl:choose>
<xsl:when test="name(..) = 'uml'">
<xsl:value-of select="@color"/>:[<xsl:value-of select="$idref"/>] <xsl:value-of select="//description[../@id=$idref]/@brief"/>;</xsl:when>
<!-- otherwise, idef0 diagram. -->
<xsl:otherwise>
[<xsl:value-of select="$idref"/>: <xsl:value-of select="//description[../@id=$idref]/@brief"/>]</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="satisfies|test">
    <xsl:variable name="idref"><xsl:value-of select="@ref"/></xsl:variable>
    <xsl:apply-templates select="//description[../@id=$idref]" mode="link"/>
</xsl:template>

<xsl:template match="reference">
  <xsl:variable name="idref"><xsl:value-of select="translate(../@id, '-', '')"/></xsl:variable>
<xsl:value-of select="$idref"/>: {
  title: "<xsl:value-of select="../description/@brief"/>",
  href: "<xsl:value-of select="@href"/>",
  publisher: "<xsl:value-of select="@publisher"/>",
},
</xsl:template>

<xsl:template match="description" mode="link">
  <xsl:variable name="hash">
    <xsl:choose>
      <xsl:when test="name(..) = 'interface'">./logical_and_physical_architecture.html#</xsl:when>
      <xsl:when test="name(..) = 'usecase'">./use_cases.html#</xsl:when>
      <xsl:otherwise>#</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

    <li><b>
<xsl:choose>
  <xsl:when test="../reference">
    <!-- External document reference -->
    [[<xsl:value-of select="translate(../@id, '-', '')"/>]]
  </xsl:when>
  <xsl:otherwise>
    <!-- Cross-reference -->
    [<a href="{ concat($hash, ../@id) }"><xsl:value-of select="../@id"/></a>]
  </xsl:otherwise>
</xsl:choose>
<xsl:value-of select="@brief"/>:</b>
<xsl:value-of select="text()"/>
    </li>
</xsl:template>

<xsl:template match="railroad">
  <script>
    <xsl:value-of select="."/>
  </script>
</xsl:template>

</xsl:stylesheet>
