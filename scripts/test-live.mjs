import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import ts from 'typescript';
const {instance:{exports:w}}=await WebAssembly.instantiate(readFileSync(new URL('../public/optical_decoder.wasm',import.meta.url)));
const file=readFileSync(new URL('../public/samples/never-gonna-give-you-up-30s.dvs',import.meta.url));
assert.equal(file.length,240*364);
const packet=w.wasm_alloc(364),out=w.wasm_alloc(364),symbols=w.wasm_alloc(1280),pcm=w.wasm_alloc(1000),image=w.wasm_alloc(700*200*4);
const colors=[[255,0,0],[0,255,0],[0,0,255],[255,255,0],[255,255,255],[0,0,0]];
let signal=0;
for(let block=0;block<240;block++) {
  const p=file.subarray(block*364,(block+1)*364);
  assert.equal(p.readUInt32LE(8),block); assert.equal(p.readUInt32LE(12),240);
  new Uint8Array(w.memory.buffer).set(p,packet);
  assert.equal(w.encode_live_packet(packet,symbols),1);
  const codes=new Uint8Array(w.memory.buffer,symbols,1280).slice();
  const scale=block%2+1,sw=320*scale,sh=64*scale,iw=700,ih=200,x0=11,y0=7;
  const pixels=new Uint8Array(iw*ih*4);
  for(let y=0;y<sh;y++)for(let x=0;x<sw;x++) {
    const rgb=colors[codes[Math.floor(y/(4*scale))*80+Math.floor(x/(4*scale))]].map((n,c)=>Math.round(n*[.7,.85,.65][c]+[10,18,25][c]));
    pixels.set([...rgb,255],((y0+y)*iw+x0+x)*4);
  }
  new Uint8Array(w.memory.buffer).set(pixels,image);
  assert.equal(w.decode_live_roi(image,iw,ih,x0,y0,sw,sh,out),1);
  assert.deepEqual(Buffer.from(new Uint8Array(w.memory.buffer,out,364)),p);
  assert.equal(w.decode_audio_block(out,pcm),500);
  for(const s of new Int16Array(w.memory.buffer,pcm,500))signal+=s*s;
}
assert.ok(signal>1e8,'audio is non-silent');
new Uint8Array(w.memory.buffer)[out+30]^=1;
assert.equal(w.decode_audio_block(out,pcm),0,'damaged audio rejected');
assert.equal(w.decode_live_roi(image,700,200,690,0,320,64,out),-1,'invalid crop rejected');
const source=ts.transpileModule(readFileSync(new URL('../src/lib/live.ts',import.meta.url),'utf8'),{compilerOptions:{target:ts.ScriptTarget.ES2022,module:ts.ModuleKind.ES2022}}).outputText;
const {LivePlayer}=await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`);
let context;const starts=[];
class Context {
  currentTime=0;state='suspended';destination={};
  constructor(){context=Object.assign(this,{});}
  async resume(){this.state='running';}
  createAnalyser(){return{connect(){},getByteTimeDomainData(a){a.fill(128);}};}
  createBuffer(channels,length,rate){assert.equal(rate,16000);return{getChannelData(){return new Float32Array(length);}};}
  createBufferSource(){return{connect(){},disconnect(){},start(t){starts.push(t);},stop(){}};}
  async close(){this.state='closed';}
}
Object.defineProperty(globalThis,'navigator',{configurable:true,value:{audioSession:{type:'auto'}}});
globalThis.AudioContext=Context;
const player=new LivePlayer();await player.enable();assert.equal(navigator.audioSession.type,'playback');
const b={samples:new Float32Array(500),id:5,index:0,total:240};
assert.equal(player.push(b),true);assert.equal(starts[0],.25);
assert.equal(player.push(b),false,'duplicate never replays');
assert.equal(player.push({...b,index:1}),true);assert.equal(starts[1],.375);
assert.equal(player.push({...b,index:3}),true);assert.equal(starts[2],.625,'loss leaves correctly timed silence');
context.currentTime=.6;assert.equal(player.push({...b,index:2}),false,'late block dropped');assert.equal(player.late,1);
player.reset();assert.equal(player.playing,false);
player.push({...b,index:239});player.push(b);assert.equal(player.played,2,'loop is recognized');
context.state='interrupted';await player.enable();assert.equal(context.state,'running');
player.dispose();
console.log('Live: 240 optical audio blocks, 30 seconds PCM, tinted colors, two scales, CRC rejection, duplicate/loss/late timing, stream loops, and iOS interruption recovery passed.');
