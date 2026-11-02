import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import ts from 'typescript';
const source=ts.transpileModule(readFileSync(new URL('../src/lib/color.ts',import.meta.url),'utf8'),{compilerOptions:{target:ts.ScriptTarget.ES2022,module:ts.ModuleKind.ES2022}}).outputText;
const { Assembly, crc32, makePacket, PAYLOAD }=await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`);
const {instance:{exports:w}}=await WebAssembly.instantiate(readFileSync(new URL('../public/optical_decoder.wasm',import.meta.url)));
const input=w.wasm_alloc(60), output=w.wasm_alloc(60), symbols=w.wasm_alloc(240), image=w.wasm_alloc(800*200*4);
const palette=[[255,0,0],[0,255,0],[0,0,255],[255,255,0],[255,255,255],[0,0,0]];
function roundtrip(packet,{scale=1,tint=false,damage=false}={}) {
  new Uint8Array(w.memory.buffer).set(packet,input);
  assert.equal(w.encode_color_packet(input,symbols),1);
  const codes=new Uint8Array(w.memory.buffer,symbols,240).slice();
  if(damage) codes[6]=(codes[6]+1)%6;
  const iw=800,ih=200,x0=17,y0=13,sw=320*scale,sh=24*scale;
  const rgba=new Uint8Array(iw*ih*4);
  for(let y=0;y<sh;y++) for(let x=0;x<sw;x++) {
    const row=Math.floor(y/(4*scale)),col=Math.floor(x/(8*scale));
    const rgb=palette[codes[row*40+col]].map((v,c)=>tint?Math.round(v*[.7,.85,.6][c]+[21,10,30][c]):v);
    rgba.set([...rgb,255],((y+y0)*iw+x+x0)*4);
  }
  new Uint8Array(w.memory.buffer).set(rgba,image);
  const ok=w.decode_color_roi(image,iw,ih,x0,y0,sw,sh,output);
  if(damage) {assert.equal(ok,0,'corruption rejected');return;}
  assert.equal(ok,1,'color packet decoded');
  const decoded=new Uint8Array(w.memory.buffer,output,60).slice();
  assert.deepEqual(decoded,packet);return decoded;
}
const arbitrary=Uint8Array.from({length:256},(_,i)=>i), arbitraryId=crc32(arbitrary);
for(let offset=0;offset<256;offset+=PAYLOAD) for(const scale of [.5,1,2]) {
  roundtrip(makePacket(arbitrary,offset,arbitraryId),{scale,tint:true});
}
roundtrip(makePacket(arbitrary,0,arbitraryId),{damage:true});
assert.equal(w.decode_color_roi(image,800,200,790,0,320,24,output),-1);
const sample=new Uint8Array(readFileSync(new URL('../public/samples/never-gonna-give-you-up-30s.mp3',import.meta.url)));
const id=crc32(sample), assembly=new Assembly();let reconstructed;
// Out of order, duplicated, and last partial packet, using actual MP3 bytes.
for(let offset=Math.floor((sample.length-1)/PAYLOAD)*PAYLOAD;offset>=0;offset-=PAYLOAD) {
  const decoded=roundtrip(makePacket(sample,offset,id),{tint:true});
  reconstructed=assembly.accept(decoded) || reconstructed;
  assembly.accept(decoded);
}
assert.deepEqual(reconstructed,sample);
const damaged=makePacket(arbitrary,0,arbitraryId);damaged[18]^=1;
assert.throws(()=>new Assembly().accept(damaged),/CRC/);
assert.throws(()=>assembly.accept(makePacket(arbitrary,0,arbitraryId)),/Different transfer/);
const sha=createHash('sha256').update(reconstructed).digest('hex');
console.log(`Color WASM: all byte values, 3 scales, color tint, corruption, bounds, duplicates and out-of-order passed.\nMusic reconstructed from ${assembly.total} optical packets: ${sample.length} bytes. SHA-256 ${sha}`);
