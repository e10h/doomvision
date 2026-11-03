import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import vm from 'node:vm';
import {UsbPcmDecoder} from '../src/lib/usb-pcm.mjs';
function packet(seq,rate=16000){const bytes=new Uint8Array(272),v=new DataView(bytes.buffer);bytes.set([68,86,85,49]);v.setUint32(4,seq,true);v.setUint32(8,rate,true);v.setUint16(12,128,true);v.setUint16(14,1,true);for(let i=0;i<128;i++)v.setInt16(16+i*2,i*-100,true);return bytes;}
const gameBoy=packet(9);new DataView(gameBoy.buffer).setUint16(14,4,true);assert.equal(new UsbPcmDecoder().feed(gameBoy)[0].flags,4);
const decoder=new UsbPcmDecoder(),received=[];
const bad=packet(1);bad[12]=255;
for(const byte of new Uint8Array([...bad,...packet(7),...packet(8,8000)]))received.push(...decoder.feed(new Uint8Array([byte])));
assert.deepEqual(received.map(p=>p.sequence),[7,8]);assert.equal(received[0].pcm[127],-12700/32768);assert.equal(received[1].rate,8000);assert.ok(decoder.buffer.length<4);
let Processor;
vm.runInNewContext(readFileSync(new URL('../public/usb-audio-worklet.js',import.meta.url),'utf8'),{AudioWorkletProcessor:class{port={postMessage(){}}},sampleRate:48000,registerProcessor:(_,p)=>Processor=p});
const processor=new Processor();
const push=(count,rate=16000)=>processor.port.onmessage({data:{rate,pcm:new Float32Array(count).fill(.25)}});
push(1024);
for(let i=0;i<3750;i++){if(i%3===0)push(128);const output=new Float32Array(128);processor.process([],[[output]]);assert.ok(output.every(v=>Math.abs(v-.25)<1e-6));}
assert.equal(processor.underruns,0);assert.equal(processor.dropped,0);
push(10000);assert.ok(processor.dropped>0);assert.ok(processor.write-processor.read<=3200);
push(128,8000);assert.equal(processor.primed,false);assert.equal(processor.write-processor.read,128);
console.log('USB packet framing, 10-second 16kHz playback, bounded queue and rate-change tests passed.');
// Game Boy audio arrives in video-sized bursts; keep its queue primed while
// applying the DC filter offloaded from the calculator's sample loop.
const game=new Processor();
const feed=(n)=>game.port.onmessage({data:{rate:16000,flags:4,pcm:new Float32Array(n).fill(.25)}});
feed(2048);
let next=0,generated=0,stepIndex=0,lastOutput;
const waits=[16,25,70,35,60];
for(let frame=0;frame<480000;frame+=128){
  if(frame>=next){const target=Math.floor(frame/3);feed(target-generated);generated=target;next+=waits[stepIndex++%waits.length]*48;}
  lastOutput=new Float32Array(128);game.process([],[[lastOutput]]);
  assert.ok(lastOutput.every(Number.isFinite));
}
assert.equal(game.underruns,0);assert.equal(game.dropped,0);
assert.ok(lastOutput.every(v=>Math.abs(v)<.0001),'Game Boy DC was not filtered');
console.log('Game Boy 16–70 ms burst buffering and output DC rejection passed.');
assert.equal(new UsbPcmDecoder().feed(packet(90,4000))[0].rate,4000);
const low=new Processor();
const lowFeed=(n,rate=4000)=>low.port.onmessage({data:{rate,flags:4,pcm:new Float32Array(n).fill(.25)}});
lowFeed(512);
for(let i=0;i<3750;i++){if(i%12===0)lowFeed(128);low.process([],[[new Float32Array(128)]]);}
assert.equal(low.underruns,0);assert.equal(low.dropped,0);
low.port.onmessage({data:{reset:true}});assert.equal(low.primed,false);assert.equal(low.write-low.read,0);
lowFeed(1024,8000);low.process([],[[new Float32Array(128)]]);assert.equal(low.rate,8000);assert.equal(low.primed,true);
console.log('4 kHz steady playback and live quality reset/rate switching passed.');
