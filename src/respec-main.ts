import plantumlEncoder from 'plantuml-encoder';
import hljs from 'highlight.js/lib/core';
import python_language from 'highlight.js/lib/languages/python';
import ini_language from 'highlight.js/lib/languages/ini';
import sql_language from 'highlight.js/lib/languages/sql';

/**
 * Remove the CC-SA public domain declaration. Replace the line with an explicit
 * copyright message.
 */
function changeCopyright(config, _document) {
    document.querySelector('.copyright').textContent =
        `Copyright © ${config.additionalCopyrightHolders}.`;
}

function renderEncodedDiagrams(selector: string, host: string, prefix: string = '') {
    document.querySelectorAll(selector).forEach(el => {
        const alt = prefix + el.textContent;
        const src = host + plantumlEncoder.encode(alt);

        const img = document.createElement('img');
        img.src = src;
        img.alt = alt;

        el.replaceWith(img);
    });
}

function renderPlantUML(_config, _document) {
    renderEncodedDiagrams('.uml', window.plantuml_host, 'skin rose\n');
}
function renderIDEF0(_config, _document) {
    renderEncodedDiagrams('.idef0', window.idef0svg_host);
}

/** Replace all section numbering with the Requirement IDs. */
function labelSections(_config, _document) {
    document.querySelectorAll('.secno').forEach(el => {
        const next_node = el.nextSibling;
        if (!next_node) {
            return;
        }

        const match = next_node.textContent.match(/^(\w+-[\d.]+):\s*(.*)$/);
        if (!match) {
            return;
        }
        el.textContent = match[1] + ' ';
        next_node.textContent = match[2];
        el.classList.add('secno-highlight');
    });
};

window.loadLanguages = async () => {
    hljs.registerLanguage('ini', ini_language);
    hljs.registerLanguage('python', python_language);
    hljs.registerLanguage('sql', sql_language);
};

window.applyCustomLanguages =
    () => {
        for (const e of document.querySelectorAll('.ini, .python, .sql')) {
            hljs.highlightElement(e);
        }
    };

          window.getRespecConfig =
        (copyright_holder: string[], local_biblio: dict|null = null): dict => {
            let config = {
                specStatus: 'unofficial',
                additionalCopyrightHolders: copyright_holder,
                preProcess: [
                    renderPlantUML,
                    renderIDEF0,
                    // loadLanguages
                ],
                postProcess: [
                    changeCopyright,
                    labelSections,
                    // applyCustomLanguages,
                ],
                alternateFormats: [
                    {label: 'XML', uri: './main.xml'},
                ],
            };

            if (local_biblio) {
                config.localBiblio = local_biblio;
            }

            return config;
        };
