import { readFileSync } from 'node:fs';
import assert from 'node:assert/strict';
const { instance: { exports: w } } = await WebAssembly.instantiate(readFileSync(new URL('../public/optical_decoder.wasm', import.meta.url)));
const byte = n => Array.from({length:8}, (_,i) => (n >> (7-i)) & 1);
const nibble = n => byte(n).slice(4);
const checksum = n => nibble((n & 15) ^ (n >> 4));
const l0 = [1,0,1,0,...byte(0xa5),...byte(37),1,0,0,0,0,0,0,0,0,1,0,0,...checksum(0xa5 ^ 37 ^ 1 ^ 2),0,1,0,1];
const l1 = [0,1,0,1,...byte(0x5a),...byte(91),...nibble(7),...nibble(3),...nibble(15),...checksum(0x5a ^ 91 ^ 0x73 ^ 15),1,0,1,0];
for (const [x,y,width] of [[0,0,320],[137,403,440],[41,77,680],[213,19,200]]) {
  const iw=960, ih=720, data=new Uint8Array(iw*ih*4);
  const rowHeight=Math.max(1,Math.round(width/320));
  for(let layer=0;layer<2;layer++) for(let dy=0;dy<rowHeight;dy++) for(let dx=0;dx<width;dx++) {
    const v=[l0,l1][layer][Math.floor(dx*40/width)] ? 235 : 20;
    const i=((y+layer*rowHeight+dy)*iw+x+dx)*4;
    data.set([v,v,v,255],i);
  }
  const p=w.wasm_alloc(data.length), out=w.wasm_alloc(40), result=w.wasm_alloc(32);
  new Uint8Array(w.memory.buffer).set(data,p);
  assert.equal(w.ai_auto_lock_screen(p,iw,ih,0,out,result),1,`lock ${x},${y},${width}`);
  const r=new DataView(w.memory.buffer,result,32);
  assert.equal(r.getUint8(0),1); assert.equal(r.getUint8(1),1,'adjacent second row');
  assert.equal(r.getUint8(2),37); assert.equal(r.getUint16(4,true),1);
  assert.equal(r.getUint8(6),91); assert.equal(r.getUint8(8),3);
  assert.equal(w.decode_optical_roi(p,iw,ih,950,0,100,4,result),0,'out of bounds is rejected');
  w.wasm_dealloc(p,data.length); w.wasm_dealloc(out,40); w.wasm_dealloc(result,32);
}
console.log('WASM: 4 packet positions/scales, both layers, payloads, and invalid ROI passed');
