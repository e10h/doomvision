// Input is 4 kHz mono signed 16-bit little-endian PCM (500-sample blocks).
import {readFileSync,writeFileSync} from 'node:fs';
import {createHash} from 'node:crypto';
const raw=readFileSync(process.argv[2]), total=raw.length/1000;
if(!Number.isInteger(total) || !total) throw new Error('PCM must contain whole 500-sample blocks');
const {instance:{exports:w}}=await WebAssembly.instantiate(readFileSync(new URL('../public/optical_decoder.wasm',import.meta.url)));
const input=w.wasm_alloc(1000),packet=w.wasm_alloc(364),output=w.wasm_alloc(1000);
const id=createHash('sha256').update(raw).digest().readUInt32LE(0),stream=Buffer.alloc(total*364);
let energy=0,noise=0;
for(let block=0;block<total;block++) {
  new Uint8Array(w.memory.buffer).set(raw.subarray(block*1000,block*1000+1000),input);
  if(w.encode_audio_block(input,500,id,block,total,packet)!==1)throw new Error('Audio encode failed');
  stream.set(new Uint8Array(w.memory.buffer,packet,364),block*364);
  if(w.decode_audio_block(packet,output)!==500)throw new Error('Audio decode failed');
  const decoded=new Int16Array(w.memory.buffer,output,500);
  for(let i=0;i<500;i++){const original=raw.readInt16LE(block*1000+i*2);energy+=original**2;noise+=(original-decoded[i])**2;}
}
writeFileSync(process.argv[3],stream);
console.log(`${total} live blocks, ${total/8} seconds, ${stream.length} bytes; ADPCM SNR ${(10*Math.log10(energy/noise)).toFixed(1)} dB relative to 4 kHz source.`);
