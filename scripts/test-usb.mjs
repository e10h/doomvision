import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import vm from 'node:vm';
import {UsbPcmDecoder} from '../src/lib/usb-pcm.mjs';
function packet(seq,rate=16000){const bytes=new Uint8Array(272),v=new DataView(bytes.buffer);bytes.set([68,86,85,49]);v.setUint32(4,seq,true);v.setUint32(8,rate,true);v.setUint16(12,128,true);v.setUint16(14,1,true);for(let i=0;i<128;i++)v.setInt16(16+i*2,i*-100,true);return bytes;}
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
