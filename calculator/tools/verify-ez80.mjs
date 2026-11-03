import{readFileSync}from'node:fs';import assert from'node:assert/strict';import ts from'../../node_modules/typescript/lib/typescript.js';
const receiver=new URL('../../',import.meta.url);async function module(path){const code=ts.transpileModule(readFileSync(new URL(path,receiver),'utf8'),{compilerOptions:{target:ts.ScriptTarget.ES2022,module:ts.ModuleKind.ES2022}}).outputText;return import(`data:text/javascript;base64,${Buffer.from(code).toString('base64')}`);}
const{LiveCodec}=await module('src/lib/live.ts'),{profile}=await module('src/lib/profile.ts'),wasm=readFileSync(new URL('public/optical_decoder.wasm',receiver));globalThis.fetch=async()=>({ok:true,arrayBuffer:async()=>wasm.buffer.slice(wasm.byteOffset,wasm.byteOffset+wasm.byteLength)});const p=profile({kbps:32,fps:8,cols:96,rows:29,colors:6}),c=await LiveCodec.create(p),ref=await LiveCodec.create(p),dir=new URL('../bench-build/checks/',import.meta.url);
for(const name of ['voices1','voices8','silence','limits','ramp','random']){
 const pcm=readFileSync(new URL(name+'-pcm.bin',dir)),packet=readFileSync(new URL(name+'-packet.bin',dir)),ppm=readFileSync(new URL(name+'-frame.ppm',dir));
 const expected=ref.encodeAudio(new Int16Array(pcm.buffer.slice(pcm.byteOffset,pcm.byteOffset+pcm.byteLength)),0x50494e31,0,65535);assert.deepEqual(packet,Buffer.from(expected),name+': actual eZ80 ADPCM vs Rust');
 const rgb=ppm.subarray(Buffer.byteLength('P6\n320 240\n255\n')),data=new Uint8ClampedArray(320*240*4);for(let i=0;i<320*240;i++){data.set(rgb.subarray(i*3,i*3+3),i*4);data[i*4+3]=255;}
 const decoded=c.autoDecode({width:320,height:240,data},'ti84');assert(decoded,`${name}: ${c.stage}`);assert.deepEqual(Buffer.from(decoded),packet,name+': compiled assembly RS/base6/render');assert.equal(c.audio(decoded).samples.length,1000);console.log(`eZ80 ${name}: compiled assembly → image → Rust exact audio passed`);
}
c.dispose();ref.dispose();
