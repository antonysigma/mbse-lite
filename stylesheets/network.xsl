<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="html" indent="yes" />

<xsl:template match="/">
<html>
<head>
<title>Network visualization</title>

<script src="https://code.jquery.com/jquery.min.js"></script>
<script src=
"https://visjs.github.io/vis-network/standalone/umd/vis-network.min.js">
</script>

 <style type="text/css">
body {
        color: #d3d3d3;
        font: 12pt arial;
        background-color: #222222;
      }
    #viewer {
      width: 100%;
      height: 100%;
      border: 1px solid lightgray;
    }
  </style>
<script>

var network = null;

var nodes = [
<xsl:apply-templates select="//*[@id]"/>
];

level = {'org': 0, 'ucd': 1, 'sys': 3, 'fnc': 4, 'int': 5, 'pad': 6, 'ver': 7};

<![CDATA[
for (var i= 0; i < nodes.length; ++i) {
  var this_level = level[nodes[i].group]
  nodes[i]['level'] = this_level;

  if(this_level == 1 || this_level >= 6) {
    nodes[i]['mass'] = 5;
  }
}
]]>

var edges = [
<xsl:apply-templates select="//trace"/>
<xsl:apply-templates select="//test"/>
<xsl:apply-templates select="//interface" mode="link"/>
<xsl:apply-templates select="//function" mode="link"/>
];

function draw(data) {
    var options = {
        nodes: {
          shape: "dot",
          font: {
            color: "#ffffff",
          },
          borderWidth: 2,
        },
        edges: {
          width: 2,
        },
        //layout: {
        //    hierarchical: {
        //      direction: 'UD',
        //    },
        //  },
      };

    if (network == null) {
        network = new vis.Network(document.getElementById('viewer'), data, options);
    }
}

$(function () {
    draw({nodes: nodes, edges: edges});
})
    </script>
</head>
<body>
<div id="viewer"></div>
</body>
</html>
</xsl:template>

<xsl:template match="*">
  {id: "<xsl:value-of select="@id"/>",
  label: "<xsl:value-of select="@id"/>: <xsl:value-of select="description/@brief"/>",
  group: "<xsl:value-of select="substring(@id,1,3)"/>",
  },
</xsl:template>

<xsl:template match="trace|test">
  {from: "<xsl:value-of select="../@id"/>", to: "<xsl:value-of select="@ref"/>", arrows: 'to',},
</xsl:template>

<xsl:template match="interface|function" mode="link">
  {from: "<xsl:value-of select="@id"/>", to: "<xsl:value-of select="../@id"/>", arrows: 'from,to',},
</xsl:template>
</xsl:stylesheet>
