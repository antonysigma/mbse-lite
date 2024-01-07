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
<script type="module">
import 'https://unpkg.com/jquery@3.6.0/dist/jquery.min.js';
import cytoscape from 'https://unpkg.com/cytoscape@3.21.1/dist/cytoscape.esm.min.js';
import { Network } from 'https://unpkg.com/vis-network@9.1.2/standalone/esm/vis-network.min.js';

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
      'text-valign' : 'center',
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
      'background-color' : 'olivegreen',
    },
  },
  {
    selector : 'node[group="pad" || group="iad" || group="arc"]',
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
      'curve-style' : 'straight',
      'width' : '2px',
      'target-arrow-shape' : 'triangle-backcurve',
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

const color = {
  'org' : '#9bb8ff',
  'ucd' : '#f2ff00',
  'sys' : '#ffac00',
  'fnc' : '#ff6b7e',
  'int' : 'gray',
  'pad' : '#dbb0f2',
  'iad' : '#dbb0f2',
  'arc' : '#dbb0f2',
  'ver' : '#3df62c',
};

function draw(data) {
  const visjs_options = {
    nodes : {
      shape : "dot",
      font : {
        color : "#ffffff",
      },
      borderWidth : 2,
    },
    edges : {
      width : 2,
    },
  };

  return new Network(document.getElementById('viewer'), data, visjs_options);
}

$(function() {
  // Step 1: Compile the network graph from node and edge data.
  const cy = cytoscape({
    elements : data,
    style : style,
    layout : {
      name : 'cose',
    },
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

  /* Step 3: Convert the graph the the Visjs compatible format. The Visjs
  encodes edge metadata in the form of `from`, `to`, not `source`, `target`.
  Also, Visjs encodes bi-directional parallel edges as one edge item, not two.
  */

  // Export nodes
  const filtered_nodes = cy.nodes().map((ele) => {
    var data = ele.data();

    // Adjust gravity
    const this_level = level[data.group];
    data['level'] = this_level;
    data['color'] = color[data.group];

    if (this_level == 1 || this_level >= 6) {
      data['mass'] = 5;
    }

    return data;
  });

  // Export edges, omit bi-directional edges.
  const filtered_edges = cy.edges('[^duplicate]').map((ele) => {
    const data = ele.data();
    var output_data = {from : data.source, to : data.target};
    if ('arrows' in data) {
      output_data['arrows'] = data.arrows;
    }

    return output_data;
  });

  /* Step 4: Visualize the selected graph; arrange the graph with COSE-like (aka
  mass-spring interaction) layout. */
  draw({nodes : filtered_nodes, edges : filtered_edges});
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
