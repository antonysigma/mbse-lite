import esbuild from 'esbuild';
//import fs from 'node:fs'

const is_network_analysis_app = process.argv.includes('--network-app');

const result = await esbuild.build({
    logLevel: "info",
    entryPoints: [is_network_analysis_app ? "src/network-main.ts" : "src/respec-main.ts"],
    bundle: true,
    sourcemap: true,
    minify: true,
    outdir: "static/",
    target: [
        'chrome116',
    ],
    //metafile: true,
});

//fs.writeFileSync("meta.json", JSON.stringify(result.metafile));