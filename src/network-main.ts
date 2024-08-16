import './network-main.css';

import cytoscape from 'cytoscape';
import $ from 'jquery';
import {marked} from 'marked';
import {encode as plantumlEncode} from 'plantuml-encoder';
import Split from 'split-grid';
import {DataSet, Network} from 'vis-network/dist/vis-network.esm';

type node_t = {
    group: 'nodes',
    data: {
        id: string,
        label: string,
        group: string,
        physics?: boolean,
    }
};

type edge_t = {
    group: 'edges',
    data: {
        source: string,
        target: string,
        arrows: string,
        duplicate?: boolean,
    }
};

type network_t =
    {
        nodes: node_t[],
        edges: edge_t[],
    }

function filterNodes(cy: cytoscape, id: string) {
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
    get: (searchParams, prop) => searchParams.get(prop),
});

// Cytoscape.js visualization themes
const style = [
    {
        selector: 'node[label]',
        style: {
            'label': 'data(label)',
            'font-size': '8pt',
            'text-valign': 'center',
            'text-halign': 'right',
            'text-margin-x': '4pt',
            // 'color' : '#d3d3d3',
            'color': 'black',
        },
    },
    {
        selector: 'node[group="org"]',
        style: {
            'background-color': 'lightblue',
        },
    },
    {
        selector: 'node[group="sys"]',
        style: {
            'background-color': 'yellow',
        },
    },
    {
        selector: 'node[group="fnc"]',
        style: {
            'background-color': 'pink',
        },
    },
    {
        selector: 'node[group="ver"]',
        style: {
            'background-color': 'olivegreen',
        },
    },
    {
        selector: 'node[group="pad" || group="iad" || group="arc"]',
        style: {
            'background-color': 'violet',
        },
    },
    {
        selector: 'node[group="int"]',
        style: {
            'background-color': 'cornflowerblue',
        },
    },
    {
        selector: 'edge',
        style: {
            'curve-style': 'straight',
            'width': '2px',
            'target-arrow-shape': 'triangle-backcurve',
        },
    },
];

const level = {
    'org': 0,
    'ucd': 1,
    'sys': 3,
    'fnc': 4,
    'int': 5,
    'pad': 6,
    'ver': 7,
    'doc': 8,
};

const color = {
    'org': '#9bb8ff',
    'ucd': '#f2ff00',
    'sys': '#ffac00',
    'fnc': '#ff6b7e',
    'int': 'gray',
    'pad': '#dbb0f2',
    'iad': '#dbb0f2',
    'arc': '#dbb0f2',
    'ver': '#3df62c',
};

function draw(data) {
    const visjs_options = {
        nodes: {
            shape: 'dot',
            font: {
                color: 'black',
            },
            borderWidth: 2,
        },
        edges: {
            width: 2,
        },
    };

    return new Network(document.getElementById('viewer'), data, visjs_options);
}

function findReferenceDoc(node_id: string) {
    const tag = node_id.split('-')[0];
    switch (tag) {
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
        case 'iad':
            return 'logical_and_physical_architecture.html';
        default:
            return 'product_requirements_specifications.html';
    }
}

function setupPanels() {
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
}

function setupNetwork(data: network_t, plantuml_host: string, idef0svg_host: string) {
    // Step 1: Compile the network graph from node and edge data.
    const cy = cytoscape({
        elements: data,
        style: style,
        layout: {
            name: 'cose',
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
        var output_data = {from: data.source, to: data.target};
        if ('arrows' in data) {
            output_data['arrows'] = data.arrows;
        }

        return output_data;
    }));

    /* Step 4: Visualize the selected graph; arrange the graph with COSE-like (aka
    mass-spring interaction) layout. */
    const network = draw({nodes: filtered_nodes, edges: filtered_edges});

    /* Step 5: When user clicks a node, show the hyperlink to the specification document
     * for detailed description.
     */
    network.on('selectNode', (params) => {
        if (params.nodes.length === 1) {
            const node_id = filtered_nodes.get(params.nodes[0]).id;
            const url = `${findReferenceDoc(node_id)}#${node_id}`;
            $('#source_doc').attr('href', './' + url).text(url);

            var panel_id = '';
            switch (node_id.slice(0, 3)) {
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

            if (panel_id === '#requirement') {
                $('#requirement div').addClass('hidden');
                $('#' + node_id).removeClass('hidden');
                return;
            }

            const plantuml_node = $('#' + node_id);
            if (plantuml_node.length == 0) {
                return;
            }
            const is_plantuml = plantuml_node.parent('#uml').length;

            if (is_plantuml) {
                const plantuml_url =
                    plantuml_host + plantumlEncode('skin rose\n' + plantuml_node.text());
                $(panel_id).attr('src', plantuml_url);
                return;
            }

            // else idef0
            const idef02svg_url =
                idef0svg_host + plantumlEncode('skin rose\n' + plantuml_node.text());
            $(panel_id).attr('src', idef02svg_url);
        }
    });
}

$(() => {
    // Render markdown text
    for (let el of document.getElementsByClassName('markdown')) {
        const markdown_text = el.innerText;
        el.innerHTML = marked.parse(markdown_text);
    }


    setupPanels();
    setupNetwork(window.network_data, window.plantuml_host, window.idef0svg_host);
});