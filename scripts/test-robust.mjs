import assert from 'node:assert/strict';import{readFileSync}from'node:fs';
const{instance:{exports:w}}=await WebAssembly.instantiate(readFileSync(new URL('../public/optical_decoder.wasm',import.meta.url)));
const file=readFileSync(new URL('../public/samples/never-gonna-give-you-up-30s.dva4',import.meta.url));assert.equal(file.length,240*446);
const p=w.wasm_alloc(446),e=w.wasm_alloc(544),out=w.wasm_alloc(446),symbols=w.wasm_alloc(1920),image=w.wasm_alloc(320*96*4),metrics=w.wasm_alloc(20),pcm=w.wasm_alloc(1500);
const pos=i=>i<255?10+i:277+i-255;
function pack(packet){new Uint8Array(w.memory.buffer).set(packet,p);assert.equal(w.pack_robust_frame(p,e),1);return new Uint8Array(w.memory.buffer,e,544).slice();}
let signal=0;
for(let block=0;block<240;block++){
 const packet=file.subarray(block*446,(block+1)*446),env=pack(packet);
 // A 32-byte burst spreads into <=16 errors per interleaved codeword.
 for(let i=80;i<112;i++)env[pos(i)]^=0x79;
 new Uint8Array(w.memory.buffer).set(env,e);assert.equal(w.repair_robust_frame(e,out),33);
 assert.deepEqual(Buffer.from(new Uint8Array(w.memory.buffer,out,446)),packet);
 assert.equal(w.decode_audio_v4(out,pcm),750);for(const n of new Int16Array(w.memory.buffer,pcm,750))signal+=n*n;
}
assert.ok(signal>1e8);
const packet=file.subarray(0,446),original=pack(packet),palette=[[255,0,0],[0,255,0],[0,0,255],[255,255,0],[255,255,255],[0,0,0]];
function receive(env,state){new Uint8Array(w.memory.buffer).set(env,e);w.encode_robust_envelope(e,symbols);const codes=new Uint8Array(w.memory.buffer,symbols,1920).slice(),pixels=new Uint8Array(320*96*4);for(let y=0;y<96;y++)for(let x=0;x<320;x++)pixels.set([...palette[codes[Math.floor(y/4)*80+Math.floor(x/4)]],255],(y*320+x)*4);new Uint8Array(w.memory.buffer).set(pixels,image);const ok=w.receive_robust_roi(state,image,320,96,0,0,320,96,out,metrics);return{ok,m:Array.from(new Uint32Array(w.memory.buffer,metrics,5))};}
function damage(seed){const env=original.slice();for(let j=0;j<40;j++)env[pos(30+seed*50+j)]^=0x91;return env;}
const state=w.robust_new();let r;
for(let capture=0;capture<3;capture++){const env=damage(capture);new Uint8Array(w.memory.buffer).set(env,e);assert.equal(w.repair_robust_frame(e,out),0,'single capture exceeds RS capacity');r=receive(env,state);}
assert.equal(r.ok,1,'multiple noisy captures recover frame');assert.equal(r.m[0],5);assert.equal(r.m[1],3);assert.deepEqual(Buffer.from(new Uint8Array(w.memory.buffer,out,446)),packet);
const other=pack(file.subarray(446,892));const mixed=original.slice();mixed.set(other.subarray(267,277),267);assert.equal(receive(mixed,state).m[0],6,'rolling mixed frame ID rejected');
const fresh=w.robust_new();assert.equal(receive(damage(0),fresh).ok,0);receive(other,fresh);r=receive(damage(2),fresh);assert.equal(r.ok,0,'different frame identities never share votes');assert.equal(r.m[1],1);
const header=original.slice();header[0]^=7;header[268]^=8;header[536]^=9;r=receive(header,fresh);assert.equal(r.ok,1,'distributed header errors repaired by bit majority');
w.robust_free(state);w.robust_free(fresh);
console.log('Robust: all 240 six-kHz audio blocks, 32-byte burst correction, beyond-capacity rejection, multi-capture recovery, protected IDs, mixed-frame rejection, and cross-frame isolation passed.');
