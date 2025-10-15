/**
 * Remove the CC-SA public domain declaration. Replace the line with an explicit
 * copyright message.
 */
function changeCopyright(config, document) {
    $('.copyright').text('Copyright © ' + config.additionalCopyrightHolders + '.');
}

function renderPlantUML(config, document) {
    $('.uml').each(function() {
        const alt = 'skin rose\n' + $(this).text();
        const src = plantuml_host + window.plantumlEncoder.encode(alt);
        $(this).replaceWith($('<img>').attr('src', src).attr('alt', alt));
    });
}

/** Replace all section numbering with the Requirement IDs. */
function labelSections(config, document) {
    document.querySelectorAll('.secno').forEach(el => {
        const next_node = el.nextSibling;
        if (!next_node) {
            return;
        }

        const match = next_node.textContent.match(/^(\w+-[\d\.]+):\s*(.*)$/);
        if (!match) {
            return;
        }
        el.textContent = match[1] + ' ';
        next_node.textContent = match[2];
        el.classList.add('secno-highlight');
    });
}

function renderIDEF0(config, document) {
    $('.idef0').each(function() {
        const alt = $(this).text();
        const src = idef0svg_host + window.plantumlEncoder.encode(alt);
        $(this).replaceWith($('<img>').attr('src', src).attr('alt', alt));
    });
}

function getLangURL(lang) {
    return `https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/es/languages/${lang}.min.js`;
}

async function loadLanguages() {
    const [hljs_script, ini, python, sql] = await Promise.all([
        import('https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/es/core.min.js'),
        import(getLangURL('ini')),
        import(getLangURL('python')),
        import(getLangURL('sql')),
    ]);

    window.hljs = hljs_script.default;
    hljs.registerLanguage('ini', ini.default);
    hljs.registerLanguage('python', python.default);
    hljs.registerLanguage('sql', sql.default);
}

function applyCustomLanguages() {
    for (const e of document.querySelectorAll('.ini, .python, .sql')) {
        window.hljs.highlightElement(e);
    }
}

function getRespecConfig(copyright_holder, local_biblio = null) {
    let config = {
        specStatus: 'unofficial',
        additionalCopyrightHolders: copyright_holder,
        preProcess: [
            renderPlantUML, renderIDEF0,
            // loadLanguages
        ],
        postProcess: [
            changeCopyright, labelSections,
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
}
