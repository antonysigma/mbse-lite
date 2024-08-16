import esbuild from 'esbuild';
//import fs from 'node:fs'

const result = await esbuild.build({
    logLevel: "info",
    entryPoints: ["src/network-main.ts"],
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