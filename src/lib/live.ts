import type { Roi } from './color';
export const LIVE_BYTES=364, LIVE_COLS=80, LIVE_ROWS=16, BLOCK_SECONDS=.125;
export class LiveCodec {
  private image=0;
  private imageSize=0;
  private quad=0;
  private rectified=0;
  public stage='Searching for four alignment markers';
  public markers=0;
  public corners:number[]=[];
  private constructor(private w:WebAssembly.Exports,private packet:number,private symbols:number,private pcm:number) {}
  static async create() {
    const r=await fetch('/optical_decoder.wasm',{cache:'no-cache'});
    if(!r.ok) throw new Error(`Decoder HTTP ${r.status}`);
    const {instance:{exports:w}}=await WebAssembly.instantiate(await r.arrayBuffer(),{});
    if(typeof w.locate_live_grid!=='function') throw new Error('Old decoder cached. Reload the website.');
    const alloc=w.wasm_alloc as (n:number)=>number;
    return new LiveCodec(w,alloc(LIVE_BYTES),alloc(LIVE_COLS*LIVE_ROWS),alloc(1000));
  }
  encode(packet:Uint8Array) {
    if(packet.length!==LIVE_BYTES)throw new Error('Invalid live packet length');
    const m=this.w.memory as WebAssembly.Memory;
    new Uint8Array(m.buffer).set(packet,this.packet);
    (this.w.encode_live_packet as (...p:number[])=>number)(this.packet,this.symbols);
    return new Uint8Array(m.buffer,this.symbols,LIVE_COLS*LIVE_ROWS).slice();
  }
  audio(packet:Uint8Array) {
    if(packet.length!==LIVE_BYTES)throw new Error('Invalid live packet length');
    const m=this.w.memory as WebAssembly.Memory;
    new Uint8Array(m.buffer).set(packet,this.packet);
    if((this.w.decode_audio_block as (...p:number[])=>number)(this.packet,this.pcm)!==500)throw new Error('Invalid audio block');
    const samples=Float32Array.from(new Int16Array(m.buffer,this.pcm,500),v=>v/32768);
    const v=new DataView(packet.buffer,packet.byteOffset,packet.byteLength);
    return {samples,id:v.getUint32(4,true),index:v.getUint32(8,true),total:v.getUint32(12,true)};
  }
  private upload(data:ImageData) {
    if(this.imageSize<data.data.length) {
      if(this.image)(this.w.wasm_dealloc as (...p:number[])=>void)(this.image,this.imageSize);
      this.imageSize=data.data.length;
      this.image=(this.w.wasm_alloc as (n:number)=>number)(this.imageSize);
    }
    new Uint8Array((this.w.memory as WebAssembly.Memory).buffer).set(data.data,this.image);
  }
  decode(data:ImageData,roi:Roi) {
    this.upload(data);
    this.corners=[];
    const ok=(this.w.decode_live_roi as (...p:number[])=>number)(this.image,data.width,data.height,Math.round(roi.x),Math.round(roi.y),Math.round(roi.w),Math.round(roi.h),this.packet);
    this.stage=ok===1?'Packet CRC OK': 'Manual crop: color or checksum failed';
    return ok===1?new Uint8Array((this.w.memory as WebAssembly.Memory).buffer,this.packet,LIVE_BYTES).slice():null;
  }
  autoDecode(data:ImageData) {
    this.upload(data);
    if(!this.quad) {
      const alloc=this.w.wasm_alloc as (n:number)=>number;
      this.quad=alloc(32);this.rectified=alloc(640*128*4);
    }
    const found=(this.w.locate_live_grid as (...p:number[])=>number)(this.image,data.width,data.height,this.quad);
    this.corners=[];
    this.markers=found===4?4:Math.max(0,found);
    if(found!==4) {
      this.stage=found===-2?'Finder candidates found; checking colored orientation dots':'Searching for alignment markers ('+this.markers+'/4)';
      return null;
    }
    const m=this.w.memory as WebAssembly.Memory;
    this.corners=Array.from(new Float32Array(m.buffer,this.quad,8));
    const warped=(this.w.rectify_live_grid as (...p:number[])=>number)(this.image,data.width,data.height,this.quad,this.rectified);
    if(warped!==1){this.stage='Markers found; perspective correction failed';return null;}
    const ok=(this.w.decode_live_roi as (...p:number[])=>number)(this.rectified,640,128,0,0,640,128,this.packet);
    const why=['','Grid outside image','Calibration colors blurred or indistinguishable','Cell colors ambiguous: improve focus / reduce glare','Symbol errors: hold steady','Packet header mismatch','Packet CRC failed: motion, refresh, or color errors','Packet CRC OK'][(this.w.last_color_stage as ()=>number)()] ?? 'Decode failed';
    this.stage='✓ Markers locked → perspective corrected → '+why;
    return ok===1?new Uint8Array(m.buffer,this.packet,LIVE_BYTES).slice():null;
  }
}
export type AudioBlock=ReturnType<LiveCodec['audio']>;
export class LivePlayer {
  private ctx:AudioContext|null=null;
  private analyser:AnalyserNode|null=null;
  private sources=new Set<AudioBufferSourceNode>();
  private seen=new Set<number>();
  private stream:number|null=null;
  private base=0;
  private highest=-1;
  private end=0;
  public late=0;
  public played=0;
  async enable() {
    const session=(navigator as Navigator & {audioSession?:{type:string}}).audioSession;
    if(session)try{session.type='playback';}catch{}
    if(!this.ctx || this.ctx.state==='closed') {
      this.ctx=new AudioContext();
      this.analyser=this.ctx.createAnalyser(); this.analyser.fftSize=256;
      this.analyser.connect(this.ctx.destination);
    }
    if(this.ctx.state!=='running'){this.reset();await this.ctx.resume();}
    if(this.ctx.state!=='running')throw new Error('Audio paused. Tap Enable audio again in Safari.');
  }
  get state() {return this.ctx?.state ?? 'off';}
  get playing() {return this.state==='running' && !!this.ctx && this.ctx.currentTime<this.end;}
  waveform() {const a=new Uint8Array(128).fill(128);this.analyser?.getByteTimeDomainData(a);return a;}
  testTone() {
    if(!this.ctx || !this.analyser)return;
    const o=this.ctx.createOscillator(),gain=this.ctx.createGain();
    o.frequency.value=440;gain.gain.value=.12;o.connect(gain);gain.connect(this.analyser);
    o.start();o.stop(this.ctx.currentTime+.2);o.onended=()=>{o.disconnect();gain.disconnect();};
  }
  push(b:AudioBlock):boolean {
    if(!this.ctx || !this.analyser || this.ctx.state!=='running')return false;
    const wrap=b.index<this.highest-b.total/2;
    if(this.stream!==b.id || wrap) {
      this.seen.clear();this.stream=b.id;this.highest=-1;
      this.base=Math.max(this.ctx.currentTime+.25,this.end)-b.index*BLOCK_SECONDS;
    }
    if(this.seen.has(b.index))return false;
    this.seen.add(b.index);this.highest=Math.max(this.highest,b.index);
    const when=this.base+b.index*BLOCK_SECONDS;
    if(when<this.ctx.currentTime) {this.late++;return false;}
    // AudioBuffer requires supported sample rates. Upsample 4 kHz PCM to 16 kHz.
    const buffer=this.ctx.createBuffer(1,b.samples.length*4,16000),out=buffer.getChannelData(0);
    for(let i=0;i<out.length;i++) {const p=i/4,j=Math.floor(p),f=p-j;out[i]=b.samples[j]*(1-f)+b.samples[Math.min(j+1,b.samples.length-1)]*f;}
    const source=this.ctx.createBufferSource();source.buffer=buffer;source.connect(this.analyser);
    this.sources.add(source);source.onended=()=>{this.sources.delete(source);source.disconnect();};
    source.start(when);this.end=Math.max(this.end,when+BLOCK_SECONDS);this.played++;return true;
  }
  reset() {
    for(const s of this.sources){try{s.stop();}catch{}s.disconnect();}
    this.sources.clear();this.seen.clear();this.stream=null;this.highest=-1;this.end=0;this.played=0;this.late=0;
  }
  dispose() {this.reset();void this.ctx?.close();}
}
