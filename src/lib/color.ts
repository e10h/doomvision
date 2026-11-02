export const COLORS = ['#ff0000', '#00ff00', '#0000ff', '#ffff00', '#ffffff', '#000000'];
export const PAYLOAD = 40;
export type Roi = { x: number; y: number; w: number; h: number };
export function crc32(bytes: Uint8Array): number {
  let crc = 0xffffffff;
  for (const b of bytes) {
    crc ^= b;
    for (let i = 0; i < 8; i++) crc = (crc >>> 1) ^ ((crc & 1) ? 0xedb88320 : 0);
  }
  return (crc ^ 0xffffffff) >>> 0;
}
export function makePacket(file: Uint8Array, offset: number, id: number): Uint8Array {
  const packet = new Uint8Array(60), v = new DataView(packet.buffer);
  packet.set([68, 86, 67, 50]);
  v.setUint32(4, id, true); v.setUint32(8, offset, true); v.setUint32(12, file.length, true);
  packet.set(file.subarray(offset, offset + PAYLOAD), 16);
  v.setUint32(56, crc32(packet.subarray(0, 56)), true);
  return packet;
}
export class Assembly {
  private id: number | null = null;
  private data = new Uint8Array();
  private seen = new Set<number>();
  get received() { return this.seen.size; }
  get total() { return Math.ceil(this.data.length / PAYLOAD); }
  accept(packet: Uint8Array): Uint8Array | null {
    if (packet.length !== 60 || packet.slice(0,4).toString() !== '68,86,67,50') throw new Error('Invalid packet');
    const v = new DataView(packet.buffer, packet.byteOffset, packet.byteLength);
    if (crc32(packet.subarray(0,56)) !== v.getUint32(56,true)) throw new Error('Packet CRC failed');
    const id = v.getUint32(4,true), offset = v.getUint32(8,true), size = v.getUint32(12,true);
    if (!size || size > 2_000_000 || offset >= size || offset % PAYLOAD) throw new Error('Invalid packet bounds');
    if (this.id === null) { this.id = id; this.data = new Uint8Array(size); }
    if (this.id !== id || size !== this.data.length) throw new Error('Different transfer detected. Reset receiver before changing files.');
    this.data.set(packet.subarray(16,16+Math.min(PAYLOAD,size-offset)),offset);
    this.seen.add(offset);
    if (this.received !== this.total) return null;
    if (crc32(this.data) !== this.id) throw new Error('File CRC failed. Reset receiver and retry.');
    return this.data.slice();
  }
}
export class ColorCodec {
  private constructor(private w: WebAssembly.Exports, private image: number, private input: number, private output: number, private symbols: number) {}
  static async create() {
    const res = await fetch('/optical_decoder.wasm', { cache: 'no-cache' });
    if (!res.ok) throw new Error(`Rust decoder HTTP ${res.status}`);
    const { instance } = await WebAssembly.instantiate(await res.arrayBuffer(), {});
    const w = instance.exports, alloc = w.wasm_alloc as (n:number)=>number;
    if (typeof w.decode_color_roi !== 'function') throw new Error('Old decoder cached. Reload this page.');
    return new ColorCodec(w,0,alloc(60),alloc(60),alloc(240));
  }
  private imageSize = 0;
  encode(packet: Uint8Array): Uint8Array {
    const memory = this.w.memory as WebAssembly.Memory;
    new Uint8Array(memory.buffer).set(packet,this.input);
    (this.w.encode_color_packet as (p:number,q:number)=>number)(this.input,this.symbols);
    return new Uint8Array(memory.buffer,this.symbols,240).slice();
  }
  decode(data: ImageData, roi: Roi): Uint8Array | null {
    if (this.imageSize < data.data.length) {
      if (this.image) (this.w.wasm_dealloc as (p:number,n:number)=>void)(this.image,this.imageSize);
      this.imageSize = data.data.length;
      this.image = (this.w.wasm_alloc as (n:number)=>number)(this.imageSize);
    }
    const memory = this.w.memory as WebAssembly.Memory;
    new Uint8Array(memory.buffer).set(data.data,this.image);
    const ok = (this.w.decode_color_roi as (...args:number[])=>number)(this.image,data.width,data.height,Math.round(roi.x),Math.round(roi.y),Math.round(roi.w),Math.round(roi.h),this.output);
    return ok === 1 ? new Uint8Array(memory.buffer,this.output,60).slice() : null;
  }
}
