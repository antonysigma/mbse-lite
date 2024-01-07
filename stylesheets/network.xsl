<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="html" indent="yes" />

<xsl:template match="/">
<html>
<head>
<title>Network visualization</title>

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
<script src="https://unpkg.com/jquery@3.6.0/dist/jquery.min.js"></script>
<script src="https://unpkg.com/cytoscape/dist/cytoscape.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/elkjs@0.7.0/lib/elk.bundled.js"></script>
<script src="https://unpkg.com/cytoscape-elk@2.2.0/dist/cytoscape-elk.js"></script>
<script>
const data = [
<!-- nodes -->
<xsl:apply-templates select="//*[@id]"/>
<!-- edges -->
<xsl:apply-templates select="//trace"/>
<xsl:apply-templates select="//test"/>
<xsl:apply-templates select="//interface" mode="link"/>
<xsl:apply-templates select="//function" mode="link"/>
];

function filterNodes(cy, id) {
  const selected = cy.$(id);
  const successors = selected.successors();
  const predecessors = selected.predecessors();

  successors.union(selected).union(predecessors).absoluteComplement().remove();
  selected.outgoers().select();
  selected.incomers().select();
}

// Query the URL for RESTful queries
// Reference: https://stackoverflow.com/a/901144
const urlQuery = new Proxy(new URLSearchParams(window.location.search), {
  get : (searchParams, prop) => searchParams.get(prop),
});

// Cytoscape.js visualization themes
const style = [
  {
    selector : 'node[label]',
    style : {
      'label' : 'data(label)',
      'font-size' : '8pt',
      'text-valign' : 'bottom',
      'text-halign' : 'right',
      'text-margin-x' : '4pt',
      'color' : '#d3d3d3',
    },
  },
  {
    selector : 'node[group="org"]',
    style : {
      'background-color' : 'lightblue',
    },
  },
  {
    selector : 'node[group="sys"]',
    style : {
      'background-color' : 'yellow',
    },
  },
  {
    selector : 'node[group="fnc"]',
    style : {
      'background-color' : 'pink',
    },
  },
  {
    selector : 'node[group="ver"]',
    style : {
      'background-color' : 'green',
    },
  },
  {
    selector : 'node[group="pad"],[group="iad"],[group="arc"]',
    style : {
      'background-color' : 'violet',
    },
  },
  {
    selector : 'node[group="int"]',
    style : {
      'background-color' : 'cornflowerblue',
    },
  },
  {
    selector : 'edge',
    style : {
      'curve-style' : 'taxi',
      'taxi-direction' : 'rightward',
      'width' : '1px',
      'target-arrow-shape' : 'triangle-backcurve',
      'arrow-scale' : 0.5,
    },
  },
];

const level = {
  'org' : 0,
  'ucd' : 1,
  'sys' : 3,
  'fnc' : 4,
  'int' : 5,
  'pad' : 6,
  'ver' : 7,
  'doc' : 8
};

$(function() {
  // Step 1: Compile the network graph from node and edge data.
  const cy = cytoscape({
    container : document.getElementById('viewer'),
    elements : data,
    style : style,
  });

  /* Step 2: If user wants to see a subset graph relevant to an specific
  node_id, process the graph to select all predecessors and successors of
  node_id. Eliminate others.

  TODO(Antony): limit up to 6-th degree of separations
  */
  const selected_nodeid = urlQuery.id;
  if (selected_nodeid) {
    filterNodes(cy, '#' + selected_nodeid);
  }
  cy.edges('[duplicate]').remove();

  /* Step 3: Arrange the items with ELK layout algorithm. */
  cy.layout({
      name : 'elk',
      elk : {
        'algorithm': 'layered',
        'elk.layered.spacing.edgeNodeBetweenLayers' : '60',
      },
    }).run();
});
</script>
</head>
<body>
<div id="viewer"></div>
</body>
</html>
</xsl:template>

<xsl:template match="*">{group: 'nodes', data:
  {id: "<xsl:value-of select="@id"/>",
  label: "<xsl:value-of select="@id"/>: <xsl:value-of select="description/@brief"/>",
  group: "<xsl:value-of select="substring(@id,1,3)"/>",
  <xsl:if test="name() = 'usecase' or name() = 'architecture'">
	  physics: false,
  </xsl:if>
  }},
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
