import assert from'node:assert/strict';import{readFileSync}from'node:fs';import ts from'typescript';
async function module(path){const code=ts.transpileModule(readFileSync(new URL(path,import.meta.url),'utf8'),{compilerOptions:{target:ts.ScriptTarget.ES2022,module:ts.ModuleKind.ES2022}}).outputText;return import(`data:text/javascript;base64,${Buffer.from(code).toString('base64')}`);}
const{profile,autoFit,readSettings}=await module('../src/lib/profile.ts'),{LiveCodec}=await module('../src/lib/live.ts');
const wasm=readFileSync(new URL('../public/optical_decoder.wasm',import.meta.url));globalThis.fetch=async()=>({ok:true,arrayBuffer:async()=>wasm.buffer.slice(wasm.byteOffset,wasm.byteOffset+wasm.byteLength)});
const colors=[[255,0,0],[0,255,0],[0,0,255],[255,255,0],[255,255,255],[0,0,0]];
for(const kbps of[24,32,48,64,96,128])for(const fps of[4,8,16]){
 const p=profile(autoFit(kbps,fps));assert.ok(p.fits);assert.ok(p.symbols<=p.available);assert.ok(p.audioBytes*8*fps/1000>=kbps && p.audioBytes*8*fps/1000-kbps<=fps*4/1000+.0001);
 const c=await LiveCodec.create(p),pcm=Int16Array.from({length:p.samples},(_,i)=>Math.round(Math.sin(i*.2)*12000));const packet=c.encodeAudio(pcm,19,0,4),symbols=c.encode(packet),iw=p.cols*4,ih=p.rows*4,data=new Uint8ClampedArray(iw*ih*4);
 for(let y=0;y<ih;y++)for(let x=0;x<iw;x++){const rgb=colors[symbols[Math.floor(y/4)*p.cols+Math.floor(x/4)]].map((n,k)=>Math.round(n*[.8,.7,.9][k]+[10,18,12][k]));data.set([...rgb,255],(y*iw+x)*4);}
 const decoded=c.decode({width:iw,height:ih,data},{x:0,y:0,w:iw,h:ih});assert.ok(decoded,`${kbps}/${fps}: ${c.stage}`);assert.deepEqual(decoded,packet);const audio=c.audio(decoded);assert.equal(audio.samples.length,p.samples);assert.equal(audio.sampleRate,p.sampleRate);assert.equal(audio.samples.length/audio.sampleRate,1/fps);c.dispose();
}
// A dense-grid sampling offset can damage header cells while pilot colors
// remain readable. The receiver must refine sampling before requiring an ID.
{
 const p=profile(autoFit(128,8)),c=await LiveCodec.create(p),samples=new Int16Array(p.samples).fill(8000),packet=c.encodeAudio(samples,337,0,10),codes=c.encode(packet),width=p.cols*4,height=p.rows*4,data=new Uint8ClampedArray(width*height*4);
 for(let y=0;y<height;y++)for(let x=0;x<width;x++){const col=Math.floor(x/4),sourceCol=col<6?col:Math.min(p.cols-1,Math.floor((x+2)/4));data.set([...colors[codes[Math.floor(y/4)*p.cols+sourceCol]],255],(y*width+x)*4);}
 const{instance:{exports:w}}=await WebAssembly.instantiate(wasm),state=w.flex_new(p.cols,p.rows,p.lanes),image=w.wasm_alloc(data.length),out=w.wasm_alloc(p.packetBytes),metrics=w.wasm_alloc(20);new Uint8Array(w.memory.buffer).set(data,image);
 assert.equal(w.flex_receive(state,image,width,height,0,0,width,height,out,metrics),0);assert.equal(new Uint32Array(w.memory.buffer,metrics,5)[0],2,'unrefined sampling has unreadable protected ID');
 const recovered=c.decode({width,height,data},{x:0,y:0,w:width,h:height});assert.ok(recovered,'protected ID must be recoverable with sampling refinement: '+c.stage);assert.deepEqual(recovered,packet);w.flex_free(state);c.dispose();console.log('Protected-ID sampling regression passed.');
}
const p=profile(autoFit(128,8));assert.equal(p.dots,8736);assert.equal(p.audioBytes,2000);assert.equal(p.lanes,10);assert.equal(p.envelopeBytes,2580);
assert.equal(profile({...p,cols:80,rows:24}).fits,false);await assert.rejects(()=>LiveCodec.create(profile({...p,cols:80,rows:24})),/Grid too small/);assert.deepEqual(readSettings('?kbps=128&fps=8&cols=168&rows=52'),autoFit(128,8));
if(process.argv[2] && process.argv[2]!=='--screenshot'){
 const raw=readFileSync(process.argv[2]),samples=new Int16Array(raw.buffer.slice(raw.byteOffset,raw.byteOffset+raw.byteLength)),total=Math.ceil(samples.length/p.samples),c=await LiveCodec.create(p);let energy=0,noise=0;
 for(let i=0;i<total;i++){const block=new Int16Array(p.samples);block.set(samples.subarray(i*p.samples,(i+1)*p.samples));const packet=c.encodeAudio(block,87,i,total),decoded=c.audio(packet);assert.equal(decoded.index,i);assert.equal(decoded.total,total);for(let j=0;j<p.samples;j++){energy+=block[j]**2;noise+=(block[j]-decoded.samples[j]*32768)**2;}}
 console.log(`Full track: ${(samples.length/32000).toFixed(3)} seconds → ${total} frames (${(total/8).toFixed(3)} seconds incl. final padding), every audio block verified; SNR ${(10*Math.log10(energy/noise)).toFixed(1)} dB vs resampled source.`);c.dispose();
}
console.log(`18 bitrate/fps profiles round-tripped through actual Rust optical + audio codec. 128 kbps at 8 fps: ${p.cols}×${p.rows} = ${p.dots} cells, ${p.audioBytes} audio bytes/frame, ${p.envelopeBytes} protected bytes/frame.`);

if(process.argv[2]==='--screenshot'){
 const pixels=readFileSync(process.argv[3]),width=Number(process.argv[4]),height=Number(process.argv[5]);assert.equal(pixels.length,width*height*4);
 const codec=await LiveCodec.create(p),decoded=codec.autoDecode({width,height,data:new Uint8ClampedArray(pixels)});assert.ok(decoded,codec.stage);const audio=codec.audio(decoded);assert.equal(audio.index,0);assert.equal(audio.sampleRate,32000);assert.equal(audio.samples.length,4000);assert.equal(audio.total,871);codec.dispose();console.log('Browser-scaled 128 kbps screenshot: orientation, sampling-phase refinement, FEC, CRC, and full-track audio metadata passed.');
}
for(const fps of[4,8,16]){const s=autoFit(128,fps);console.log(`128 kbps @ ${fps} fps: ${s.cols} × ${s.rows} = ${s.cols*s.rows} cells/frame`);}
