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
        /* color: #d3d3d3; */
        font: 12pt arial;
        /* background-color: #222222; */
      }
#viewer {
      border: 1px solid lightgray;
    }
a {
        /* color: #d3d3d3; */
}
.grid {
    height: 80%;
    display: grid;
    grid-template-rows: 1fr 10px 1fr;
    grid-template-columns: 1fr 10px 1fr;
}
.grid > div {
  overflow: scroll;
}

.gutter-col {
    grid-row: 1/-1;
    cursor: col-resize;
}

.gutter-col-1 {
    grid-column: 2;
}

.gutter-row {
    grid-column: 1/-1;
    cursor: row-resize;
}

.gutter-row-1 {
    grid-row: 2;
}
#uml pre, #idef0 pre, .hidden {
  display: none;
}
img {
  display: block;
  margin-left: auto;
  margin-right: auto;
}
  </style>
<script src="https://cdn.rawgit.com/jmnote/plantuml-encoder/d133f316/dist/plantuml-encoder.min.js"></script>
<script type="module">
import 'https://unpkg.com/jquery@3.6.0/dist/jquery.min.js';
import cytoscape from 'https://unpkg.com/cytoscape@3.21.1/dist/cytoscape.esm.min.js';
import { Network, DataSet } from 'https://unpkg.com/vis-network@9.1.2/standalone/esm/vis-network.min.js';
import Split from 'https://www.unpkg.com/split-grid@1.0.11/dist/split-grid.mjs';

const plantuml_host = '<xsl:value-of select="mbse/@plantuml_host"/>/plantuml/svg/';

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
      // 'color' : '#d3d3d3',
      'color' : 'black',
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
        color : 'black',
      },
      borderWidth : 2,
    },
    edges : {
      width : 2,
    },
  };

  return new Network(document.getElementById('viewer'), data, visjs_options);
}

function findReferenceDoc(node_id) {
  const tag = node_id.split('-')[0];
  switch(tag) {
    case 'org':
    return 'originating_requirements.html';
    case 'ucd':
    return 'use_cases.html';
    case 'sys':
    case 'fnc':
    case 'ver':
    return 'product_requirements_specifications.html';
    case 'int':
    case 'pad':
    return 'logical_and_physical_architecture.html';
    default:
    return 'product_requirements_specifications.html';
  }
}

$(() => {
Split({
    columnGutters: [{
        track: 1,
        element: document.querySelector('.gutter-col-1'),
    }],
    rowGutters: [{
        track: 1,
        element: document.querySelector('.gutter-row-1'),
    }]
})
});

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
  const filtered_nodes = new DataSet(cy.nodes().map((ele) => {
    var data = ele.data();

    // Adjust gravity
    const this_level = level[data.group];
    data['level'] = this_level;
    data['color'] = color[data.group];

    if (this_level == 1 || this_level >= 6) {
      data['mass'] = 5;
    }

    return data;
  }));

  // Export edges, omit bi-directional edges.
  const filtered_edges = new DataSet(cy.edges('[^duplicate]').map((ele) => {
    const data = ele.data();
    var output_data = {from : data.source, to : data.target};
    if ('arrows' in data) {
      output_data['arrows'] = data.arrows;
    }

    return output_data;
  }));

  /* Step 4: Visualize the selected graph; arrange the graph with COSE-like (aka
  mass-spring interaction) layout. */
  const network = draw({nodes : filtered_nodes, edges : filtered_edges});

  /* Step 5: When user clicks a node, show the hyperlink to the specification document
   * for detailed description.
   */
  network.on('selectNode', (params) => {
    if (params.nodes.length === 1) {
      const node_id = filtered_nodes.get(params.nodes[0]).id;
      const url = `${findReferenceDoc(node_id)}#${node_id}`;
      $('#source_doc').attr('href', './' + url).text(url);

      var panel_id = '';
      switch(node_id.slice(0, 3)) {
        case 'fnc':
          panel_id = '#behavior';
          break;
        case 'sys':
        case 'org':
        case 'ver':
          panel_id = '#requirement';
          break;
        default:
          panel_id = '#architecture';
      }

      if(panel_id === '#requirement') {
        $('#requirement div').addClass('hidden');
        $('#' + node_id).removeClass('hidden');
        return;
      }

      const plantuml_node = $('#' + node_id);
      if (plantuml_node.length == 0) { return; }
      const plantuml_url = plantuml_host + window.plantumlEncoder.encode('skin rose\n' + plantuml_node.text());
      $(panel_id).attr('src', plantuml_url);
    }
  });
});

</script>
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
<pre><xsl:value-of select="."/></pre>
<p>Rationale: "<xsl:value-of select="../rationale"/>"</p>
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
