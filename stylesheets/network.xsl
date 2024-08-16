<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="html" indent="yes" />

<xsl:template match="/">
<html>
<head>
<title>Network visualization</title>

<link href="../static/network-main.css" rel="stylesheet"/>
<script>
window.plantuml_host = '<xsl:value-of select="mbse/@plantuml_host"/>/plantuml/svg/';
window.idef0svg_host = '<xsl:value-of select="mbse/@idef0svg_host"/>/svg/';

window.network_data = [
<!-- nodes -->
<xsl:apply-templates select="//*[@id]"/>
<!-- edges -->
<xsl:apply-templates select="//trace"/>
<xsl:apply-templates select="//test"/>
<xsl:apply-templates select="//interface" mode="link"/>
<xsl:apply-templates select="//function" mode="link"/>
];
</script>
<script src="../static/network-main.js"/>
</head>
<body>
<div id="topbar">
Reference: <a id="source_doc" href="./product_requirements_specifications.html" target="source_doc_tab">product_requirements_specifications.html</a>
</div>
<div class="grid">
    <div><img id="behavior" /></div>
    <div class="gutter-col gutter-col-1"></div>
    <div id="requirement">
  <xsl:apply-templates select="//performance/description"/>
  <xsl:apply-templates select="//constraint/description"/>
  <xsl:apply-templates select="//orig/description"/>
  <xsl:apply-templates select="//verification/description"/>
    </div>
    <div><img id="architecture" /></div>
    <div class="gutter-row gutter-row-1"></div>
    <div id="viewer"></div>
</div>
<div id="uml">
  <xsl:apply-templates select="//uml"/>
</div>
<div id="idef0">
  <xsl:apply-templates select="//idef0"/>
</div>
</body>
</html>
</xsl:template>

<xsl:template match="*[@id]">{group: 'nodes', data:
  {id: "<xsl:value-of select="@id"/>",
  label: "<xsl:value-of select="@id"/>: <xsl:value-of select="description/@brief"/>",
  group: "<xsl:value-of select="substring(@id,1,3)"/>",
  <xsl:if test="name() = 'usecase' or name() = 'architecture'">
	  physics: false,
  </xsl:if>
  }},
</xsl:template>

<xsl:template match="description">
<div id="{ ../@id }" class="hidden">
<h2><xsl:value-of select="../@id"/>: <xsl:value-of select="@brief"/></h2>
<span class="markdown"><xsl:value-of select="."/></span>
<span class="markdown">**Rationale**

<xsl:value-of select="../rationale"/></span>
</div>
</xsl:template>

<xsl:template match="uml|idef0">
<pre id="{../@id}"><xsl:apply-templates /></pre>
</xsl:template>

<!-- Generate use-case bubble, or activity block, or interface depending on the context. -->
<xsl:template match="this">
  <xsl:variable name="idref"><xsl:value-of select="@ref"/></xsl:variable>
  <xsl:variable name="label">[<xsl:value-of select="@ref"/>] <xsl:value-of select="//*[@id=$idref]/description/@brief"/></xsl:variable>
<xsl:choose>

<!-- Activity block -->
<xsl:when test="name(..) = 'uml' and name(../..) = 'behavior'">
<xsl:value-of select="@color"/>:<xsl:value-of select="$label"/>;</xsl:when>

<!-- Interface block -->
<xsl:when test="name(..) = 'uml' and name(../..) = 'architecture'">
  <xsl:choose>
    <xsl:when test="not(@type)">() "<xsl:value-of select="$label"/>"</xsl:when>
    <xsl:otherwise><xsl:value-of select="@type"/><xsl:text> </xsl:text><xsl:value-of select="$label"/></xsl:otherwise>
  </xsl:choose>
</xsl:when>

<!-- Use case bubble -->
<xsl:when test="name(..) = 'uml' and name(../..) = 'usecase'">(<xsl:value-of select="../../@id"/>: <xsl:value-of select="../../description/@brief"/>)</xsl:when>
<!-- otherwise, idef0 diagram. -->
<xsl:otherwise>
[<xsl:value-of select="$idref"/>: <xsl:value-of select="//description[../@id=$idref]/@brief"/>]</xsl:otherwise>
</xsl:choose>
</xsl:template>


<xsl:template match="trace|test">{group: 'edges', data:
  {source: "<xsl:value-of select="../@id"/>", target: "<xsl:value-of select="@ref"/>", arrows: 'to',}},
</xsl:template>

<xsl:template match="function" mode="link">{group: 'edges', data:
  {target: "<xsl:value-of select="@id"/>", source: "<xsl:value-of select="../@id"/>", arrows: 'from,to',}},
{group: 'edges', data:
  {source: "<xsl:value-of select="@id"/>", target: "<xsl:value-of select="../@id"/>", arrows: 'from,to', duplicate: true}},
</xsl:template>

<xsl:template match="interface" mode="link">{group: 'edges', data:
  {source: "<xsl:value-of select="@id"/>", target: "<xsl:value-of select="../@id"/>", arrows: 'from,to',}},
{group: 'edges', data:
  {target: "<xsl:value-of select="@id"/>", source: "<xsl:value-of select="../@id"/>", arrows: 'from,to', duplicate: true}},
</xsl:template>
</xsl:stylesheet>
