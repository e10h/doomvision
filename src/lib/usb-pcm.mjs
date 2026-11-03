// DVU1 framing shared by the browser receiver and protocol regression tests.
export class UsbPcmDecoder {
  buffer = new Uint8Array(0);
  feed(bytes) {
    const joined = new Uint8Array(this.buffer.length + bytes.length);
    joined.set(this.buffer); joined.set(bytes, this.buffer.length);
    const packets = [];
    let offset = 0;
    while (offset + 4 <= joined.length) {
      if (joined[offset] !== 68 || joined[offset+1] !== 86 || joined[offset+2] !== 85 || joined[offset+3] !== 49) { offset++; continue; }
      if (joined.length-offset < 16) break;
      const view = new DataView(joined.buffer, offset);
      const rate = view.getUint32(8, true), count = view.getUint16(12, true), flags = view.getUint16(14, true);
      if (![8000,16000].includes(rate) || count !== 128 || (flags & ~7)) { offset++; continue; }
      if (joined.length-offset < 272) break;
      const pcm = new Float32Array(count);
      for (let i=0;i<count;i++) pcm[i] = view.getInt16(16+i*2,true)/32768;
      packets.push({sequence:view.getUint32(4,true), rate, flags, pcm});
      offset += 272;
    }
    this.buffer = joined.slice(offset);
    return packets;
  }
}
