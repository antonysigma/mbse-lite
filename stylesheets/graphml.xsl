<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="xml" indent="yes" />

<xsl:template match="/">
  <graphml>
    <graph id="mbse_graph" edgedefault="directed">
      <!-- nodes -->
      <xsl:apply-templates select="//*[@id]"/>

      <!-- edges -->
      <xsl:apply-templates select="//trace"/>
    </graph>
  </graphml>
</xsl:template>

<xsl:template match="*">
  <node id="{ @id }"/>
</xsl:template>

<xsl:template match="trace">
  <edge source="{ ../@id }" target="{ @ref }"/>
</xsl:template>
</xsl:stylesheet>
