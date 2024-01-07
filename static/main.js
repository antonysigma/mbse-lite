/**
 * Remove the CC-SA public domain declaration. Replace the line with an explicit
 * copyright message.
 */
function changeCopyright(config, document) {
    $('.copyright').text('Copyright © ' + config.additionalCopyrightHolders + '.');
}

/**
 * Remove the W3C working draft watermark. Use the default white background.
 */
function removeW3CWatermark(config, document) {
    $('body').css('background', 'white');
}

function renderPlantUML(config, document) {
    $('.uml').each(function() {
        const alt = 'skin rose\n' + $(this).text();
        const src = plantuml_host + window.plantumlEncoder.encode(alt);
        $(this).replaceWith($('<img>').attr('src', src).attr('alt', alt));
    });
}

function renderIDEF0(config, document) {
    $('.idef0').each(function() {
        const alt = $(this).text();
        const src = idef0svg_host + window.plantumlEncoder.encode(alt);
        $(this).replaceWith($('<img>').attr('src', src).attr('alt', alt));
    });
}

function getRespecConfig(copyright_holder, local_biblio=null) {
    let config = {
            specStatus: 'unofficial',
            additionalCopyrightHolders: copyright_holder,
            preProcess: [renderPlantUML, renderIDEF0],
            postProcess: [changeCopyright, removeW3CWatermark],
            alternateFormats: [
                {label: 'XML', uri: './main.xml'},
            ],
        };

    if (local_biblio) {
        config.localBiblio = local_biblio;
    }

    return config;
}
