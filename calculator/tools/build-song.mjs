import{readFileSync,writeFileSync,mkdirSync}from'node:fs';import{createHash}from'node:crypto';import ts from'../../node_modules/typescript/lib/typescript.js';
const root=new URL('../',import.meta.url); // calculator/
const receiver=new URL('../../',import.meta.url);
async function module(path){const code=ts.transpileModule(readFileSync(new URL(path,receiver),'utf8'),{compilerOptions:{target:ts.ScriptTarget.ES2022,module:ts.ModuleKind.ES2022}}).outputText;return import(`data:text/javascript;base64,${Buffer.from(code).toString('base64')}`);}
const{LiveCodec}=await module('src/lib/live.ts'),{profile,autoFit,frameSamples}=await module('src/lib/profile.ts'),{paletteRgb}=await module('src/lib/palette.ts');
const wasm=readFileSync(new URL('public/optical_decoder.wasm',receiver));globalThis.fetch=async()=>({ok:true,arrayBuffer:async()=>wasm.buffer.slice(wasm.byteOffset,wasm.byteOffset+wasm.byteLength)});
const p=profile(autoFit(32,8,16)),raw=readFileSync(process.argv[2]),samples=new Int16Array(raw.buffer.slice(raw.byteOffset,raw.byteOffset+raw.byteLength)),count=Math.ceil(samples.length*p.fps/p.sampleRate),c=await LiveCodec.create(p);
const id=createHash('sha256').update(raw).digest().readUInt32LE(0),frames=new Uint8Array(count*p.envelopeBytes),packets=new Uint8Array(count*p.packetBytes),perBank=Math.floor(60000/p.envelopeBytes),banks=Math.ceil(count/perBank);
for(let frame=0;frame<count;frame++){
 const n=frameSamples(p.sampleRate,p.fps,frame),block=new Int16Array(n),start=Math.floor(frame*p.sampleRate/p.fps);block.set(samples.subarray(start,start+n));const packet=c.encodeAudio(block,id,frame,count);packets.set(packet,frame*p.packetBytes);const codes=c.encode(packet);
 for(let i=0;i<p.envelopeBytes*2;i++){const row=Math.floor(i/(p.cols-p.pilots)),col=p.pilots+i%(p.cols-p.pilots);frames[frame*p.envelopeBytes+Math.floor(i/2)]|=codes[row*p.cols+col]<<((i%2)*4);}
}
mkdirSync(new URL('assets/',root),{recursive:true});mkdirSync(new URL('src/',root),{recursive:true});
const names=[],sizes=[];
for(let bank=0;bank<banks;bank++){const name='DVS32'+String(bank).padStart(2,'0'),bytes=frames.slice(bank*perBank*p.envelopeBytes,Math.min(frames.length,(bank+1)*perBank*p.envelopeBytes));names.push(name);sizes.push(bytes.length);writeFileSync(new URL(`assets/${name}.bin`,root),bytes);}
const rgb=Array.from({length:p.colors+p.pilots},(_,i)=>paletteRgb(i,p.colors));
writeFileSync(new URL('src/song.h',root),`/* Generated from the full supplied recording; do not edit. */\n#ifndef SONG_H\n#define SONG_H\n#include <stdint.h>\n#define SONG_FRAMES ${count}\n#define SONG_FPS ${p.fps}\n#define SONG_COLS ${p.cols}\n#define SONG_ROWS ${p.rows}\n#define SONG_PILOTS ${p.pilots}\n#define SONG_FRAME_BYTES ${p.envelopeBytes}\n#define SONG_BANK_FRAMES ${perBank}\n#define SONG_BANKS ${banks}\nstatic const char song_names[SONG_BANKS][9]={${names.map(n=>JSON.stringify(n)).join(',')}};\nstatic const unsigned int song_sizes[SONG_BANKS]={${sizes.join(',')}};\nstatic const uint8_t song_rgb[${rgb.length}][3]={${rgb.map(c=>'{'+c.join(',')+'}').join(',')}};\n#endif\n`);
writeFileSync(new URL('assets/song-frames.bin',root),frames);writeFileSync(new URL('assets/song-packets.bin',root),packets);writeFileSync(new URL('assets/profile.json',root),JSON.stringify({...p,frameCount:count,bankFrames:perBank,banks,names,sizes,sourceSeconds:samples.length/p.sampleRate},null,2));c.dispose();
console.log(`Full song: ${samples.length/p.sampleRate}s, ${count} frames, ${p.kbps} kbps / ${p.colors} colors / ${p.cols}x${p.rows}, ${frames.length} bytes in ${banks} banks.`);
