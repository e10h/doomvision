// Input is 6 kHz mono signed 16-bit little-endian PCM (750-sample blocks).
import {readFileSync,writeFileSync} from 'node:fs';
import {createHash} from 'node:crypto';
const raw=readFileSync(process.argv[2]), total=raw.length/1500;
if(!Number.isInteger(total) || !total) throw new Error('PCM must contain whole 750-sample blocks');
const {instance:{exports:w}}=await WebAssembly.instantiate(readFileSync(new URL('../public/optical_decoder.wasm',import.meta.url)));
const input=w.wasm_alloc(1500),packet=w.wasm_alloc(446),output=w.wasm_alloc(1500);
const id=createHash('sha256').update(raw).digest().readUInt32LE(0),stream=Buffer.alloc(total*446);
let energy=0,noise=0;
for(let block=0;block<total;block++) {
  new Uint8Array(w.memory.buffer).set(raw.subarray(block*1500,block*1500+1500),input);
  if(w.encode_audio_v4(input,750,id,block,total,packet)!==1)throw new Error('Audio encode failed');
  stream.set(new Uint8Array(w.memory.buffer,packet,446),block*446);
  if(w.decode_audio_v4(packet,output)!==750)throw new Error('Audio decode failed');
  const decoded=new Int16Array(w.memory.buffer,output,750);
  for(let i=0;i<750;i++){const original=raw.readInt16LE(block*1500+i*2);energy+=original**2;noise+=(original-decoded[i])**2;}
}
writeFileSync(process.argv[3],stream);
console.log(`${total} live blocks, ${total/8} seconds, ${stream.length} bytes; ADPCM SNR ${(10*Math.log10(energy/noise)).toFixed(1)} dB relative to 6 kHz source.`);
