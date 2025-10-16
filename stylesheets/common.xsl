<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="reference">
  <xsl:variable name="idref"><xsl:value-of select="translate(../@id, '-', '')"/></xsl:variable>
<xsl:value-of select="$idref"/>: {
  title: "<xsl:value-of select="../description/@brief"/>",
  href: "<xsl:value-of select="@href"/>",
  publisher: "<xsl:value-of select="@publisher"/>",
},
</xsl:template>

<xsl:template match="/" mode="scripts">
  <style>
 <!-- Section number use pale color by default. -->
.secno {
  color: #ccc;
}
.secno-highlight {
  color: black;
}
 <!-- Remove the W3C working draft watermark. Use the default white background. -->
body {
  background: white;
}
  </style>
  <script src="https://www.w3.org/Tools/respec/respec-w3c" class="remove" defer="defer"/>
  <script src="https://cdn.rawgit.com/jmnote/plantuml-encoder/d133f316/dist/plantuml-encoder.min.js"></script>
  <script src="../static/main.js"></script>
  <script class="remove">
window.plantuml_host = '<xsl:value-of select="mbse/@plantuml_host"/>/plantuml/svg/';
window.idef0svg_host = '<xsl:value-of select="mbse/@idef0svg_host"/>/svg/';

const localBiblio = {
<xsl:apply-templates select="//document/reference"/>
};

window.respecConfig = getRespecConfig('<xsl:value-of select="mbse/@copyright"/>', localBiblio);
    </script>
</xsl:template>

<xsl:template match="description" mode="link">
  <xsl:variable name="hash">
    <xsl:choose>
      <xsl:when test="name(..) = 'interface'">./logical_and_physical_architecture.html#</xsl:when>
      <xsl:when test="name(..) = 'usecase'">./use_cases.html#</xsl:when>
      <xsl:when test="name(..) = 'orig'">./originating_requirements.html#</xsl:when>
      <xsl:otherwise>./product_requirements_specifications.html#</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

    <li><b>
<xsl:choose>
  <xsl:when test="name(..) = 'document'">
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

<xsl:template match="uml">
  <xsl:param name="diagram_type"/>
  <figure id="{ ../@id }-uml">
    <pre class="uml"><xsl:apply-templates/></pre>
    <figcaption><xsl:value-of select="$diagram_type"/> diagram "<xsl:value-of select="../@id"/>: <xsl:value-of select="../description/@brief"/>"</figcaption>
  </figure>
</xsl:template>

<xsl:template match="aside">
  <aside class="{ @class }"><xsl:value-of select="."/></aside>
</xsl:template>

</xsl:stylesheet>
