import assert from'node:assert/strict';import{readFileSync}from'node:fs';import ts from'typescript';
async function module(path){const code=ts.transpileModule(readFileSync(new URL(path,import.meta.url),'utf8'),{compilerOptions:{target:ts.ScriptTarget.ES2022,module:ts.ModuleKind.ES2022}}).outputText;return import(`data:text/javascript;base64,${Buffer.from(code).toString('base64')}`);}
const{profile,autoFit,PALETTES}=await module('../src/lib/profile.ts'),{paletteRgb}=await module('../src/lib/palette.ts'),{LiveCodec}=await module('../src/lib/live.ts');
const wasm=readFileSync(new URL('../public/optical_decoder.wasm',import.meta.url));globalThis.fetch=async()=>({ok:true,arrayBuffer:async()=>wasm.buffer.slice(wasm.byteOffset,wasm.byteOffset+wasm.byteLength)});
function camera(rgb,noise,x,y){const q=rgb.map(v=>255*(v/255)**1.25),matrix=[[.72,.08,.03],[.04,.78,.04],[.03,.06,.74]],black=[10,15,18];return matrix.map((r,c)=>Math.max(0,Math.min(255,Math.round(black[c]+r.reduce((s,a,k)=>s+a*q[k],0)+(noise?((x*17+y*31+c*13)%5-2):0)))));}
function image(p,codes,distort=false,edit){const width=p.cols*6,height=p.rows*6,data=new Uint8ClampedArray(width*height*4);for(let y=0;y<height;y++)for(let x=0;x<width;x++){const row=Math.floor(y/6),col=Math.floor(x/6);let code=codes[row*p.cols+col];if(edit)code=edit(code,row,col);let rgb=paletteRgb(code,p.colors);if(distort==='encoded'){const linear=rgb.map(n=>(n/255)**2.2),a=[[.75,.08,.04],[.04,.78,.05],[.03,.06,.76]];rgb=a.map(r=>Math.round(255*Math.max(0,Math.min(1,.001+r.reduce((sum,v,k)=>sum+v*linear[k],0)))**(1/2.2)));}else if(distort)rgb=camera(rgb,true,x,y);data.set([...rgb,255],(y*width+x)*4);}return{width,height,data};}
for(const colors of PALETTES){
 const p=profile(autoFit(128,8,colors)),codec=await LiveCodec.create(p),samples=Int16Array.from({length:p.samples},(_,i)=>Math.round(Math.sin(i*.13)*10000)),packet=codec.encodeAudio(samples,25,0,240),codes=codec.encode(packet);
 for(const distorted of[false,true]){codec.resetFusion();const im=image(p,codes,distorted),decoded=codec.decode(im,{x:0,y:0,w:im.width,h:im.height});assert.ok(decoded,`${colors} colors / distortion=${distorted}: ${codec.stage}`);assert.deepEqual(decoded,packet);}
 console.log(`${colors} colors: ${p.cols}×${p.rows}=${p.dots} cells, ${p.bitsPerCell.toFixed(2)} data bits/cell; exact and gamma/crosstalk/noise passed`);codec.dispose();
}
// Every single observation has too many wrong symbols for RS. Their disjoint
// damage can be recovered by accumulating soft bit evidence from the same ID.
{
 const p=profile(autoFit(1,8,64)),codec=await LiveCodec.create(p),packet=codec.encodeAudio(new Int16Array(31).fill(6000),77,0,871),codes=codec.encode(packet),copies=[0,Math.floor((p.envelopeBytes-10)/2),p.envelopeBytes-10];
 const eligible=[];for(let i=0;i<p.symbols;i++){const start=i*p.bits,end=Math.min(start+p.bits,p.envelopeBytes*8);if(!copies.some(c=>start<(c+10)*8&&end>c*8))eligible.push(i);}
 let last;for(let capture=0;capture<3;capture++){const targets=new Set(eligible.filter((_,i)=>i%3===capture));const im=image(p,codes,false,(code,row,col)=>col>=p.pilots&&targets.has(row*(p.cols-p.pilots)+col-p.pilots)?code^1:code);const fresh=await LiveCodec.create(p);assert.equal(fresh.decode(im,{x:0,y:0,w:im.width,h:im.height}),null,'single damaged color capture must fail');fresh.dispose();last=codec.decode(im,{x:0,y:0,w:im.width,h:im.height});}
 assert.ok(last,'soft same-frame bit evidence recovers packet');assert.deepEqual(last,packet);assert.equal(codec.fused,true);codec.dispose();console.log('Probabilistic bit fusion recovered three individually uncorrectable color captures.');
}
// High-order constellations trade color spacing for area. Under the same
// tile-level distortion, 8 colors can survive while 1024 must reject, not play
// unchecked bytes. Calibration pilots remain intact in this experiment.
for(const count of[8,1024]){
 const p=profile(autoFit(128,8,count)),codec=await LiveCodec.create(p),packet=codec.encodeAudio(new Int16Array(p.samples).fill(7000),82,0,10),codes=codec.encode(packet),im=image(p,codes,true);
 for(let y=0;y<im.height;y++)for(let x=0;x<im.width;x++){const col=Math.floor(x/6);if(col<p.pilots)continue;for(let c=0;c<3;c++){const delta=((col*19+Math.floor(y/6)*13+c*7)%41)-20;const index=(y*im.width+x)*4+c;im.data[index]=Math.max(0,Math.min(255,im.data[index]+delta));}}
 const decoded=codec.decode(im,{x:0,y:0,w:im.width,h:im.height});if(count===8){assert.ok(decoded);assert.deepEqual(decoded,packet);}else assert.equal(decoded,null,'1024-color excessive-noise frame rejected');codec.dispose();
}
console.log('Noise tradeoff: 8 colors recovered; 1024 colors rejected the excessive-noise frame without bypassing CRC.');
// Every palette at both low and high transport sizes and each supported frame
// rate uses the same sender / decoder wrappers as the web UI.
for(const count of PALETTES.filter(n=>n!==6))for(const kbps of[1,24,128])for(const fps of[4,8,16]){
 const p=profile(autoFit(kbps,fps,count)),codec=await LiveCodec.create(p),n=Math.floor(p.sampleRate/fps),packet=codec.encodeAudio(new Int16Array(n).fill(8000),93,0,10),codes=codec.encode(packet),im=image(p,codes,true),decoded=codec.decode(im,{x:0,y:0,w:im.width,h:im.height});assert.ok(decoded,`${count}/${kbps}/${fps}: ${codec.stage}`);assert.deepEqual(decoded,packet);codec.dispose();
}
console.log('72 additional palette/rate/fps combinations passed.');

{
 const p=profile(autoFit(1,8,64)),codec=await LiveCodec.create(p),samples=new Int16Array(31).fill(6000),a=codec.encodeAudio(samples,29,0,871),b=codec.encodeAudio(samples,29,1,871),ca=codec.encode(a),cb=codec.encode(b),middle=Math.floor((p.envelopeBytes-10)/2)*8;
 const im=image(p,ca,false,(code,row,col)=>{if(col<p.pilots)return code;const i=(row*(p.cols-p.pilots)+col-p.pilots)*p.bits;return i<middle+80&&i+p.bits>middle?cb[row*p.cols+col]:code;});
 assert.equal(codec.decode(im,{x:0,y:0,w:im.width,h:im.height}),null);assert.match(codec.stage,/Mixed frame IDs/);codec.dispose();
}
for(const count of PALETTES){const rgb=Array.from({length:count},(_,i)=>paletteRgb(i,count).join(','));assert.equal(new Set(rgb).size,count,'palette has exactly the advertised number of distinct data colors');}
console.log('Palette uniqueness and mixed-frame ID rejection passed.');

for(const count of[8,16,64,256,1024]){
 const p=profile(autoFit(128,8,count)),c=await LiveCodec.create(p),packet=c.encodeAudio(new Int16Array(p.samples).fill(7000),98,0,10),im=image(p,c.encode(packet),'encoded'),decoded=c.decode(im,{x:0,y:0,w:im.width,h:im.height});assert.ok(decoded,`${count}: separate display/camera transfer fit: ${c.stage}`);assert.deepEqual(decoded,packet);c.dispose();
}
console.log('Separate display/camera transfer-function calibration passed.');
if(process.argv[2]==='--screenshot'){
 const pixels=readFileSync(process.argv[3]),width=Number(process.argv[4]),height=Number(process.argv[5]),p=profile(autoFit(Number(process.argv[6]),Number(process.argv[7]),Number(process.argv[8])));assert.equal(pixels.length,width*height*4);const c=await LiveCodec.create(p),packet=c.autoDecode({width,height,data:new Uint8ClampedArray(pixels)});assert.ok(packet,c.stage);const b=c.audio(packet);assert.equal(b.index,0);assert.equal(b.total,871);assert.equal(b.sampleRate,p.sampleRate);console.log(`Actual browser ${p.colors}-color frame: protected ID, RS, CRC, and full-track audio metadata passed (${c.corrected} repaired bytes).`);c.dispose();
}
