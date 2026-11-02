import type { Roi } from './color';
export const LIVE_BYTES=446, LIVE_COLS=80, LIVE_ROWS=24, BLOCK_SECONDS=.125;
export class LiveCodec {
  private image=0;
  private imageSize=0;
  private quad=0;
  private rectified=0;
  private candidates=0;
  private failureCode=0;
  public stage='Searching for four alignment markers';
  public markers=0;
  public captures=0;
  public corrected=0;
  public confidence=0;
  public fused=false;
  private combiner=0;
  private metrics=0;
  public corners:number[]=[];
  private constructor(private w:WebAssembly.Exports,private packet:number,private symbols:number,private pcm:number) {}
  static async create() {
    const r=await fetch('/optical_decoder.wasm',{cache:'no-cache'});
    if(!r.ok) throw new Error(`Decoder HTTP ${r.status}`);
    const {instance:{exports:w}}=await WebAssembly.instantiate(await r.arrayBuffer(),{});
    if(typeof w.robust_alignment_candidates!=='function') throw new Error('Old decoder cached. Reload the website.');
    const alloc=w.wasm_alloc as (n:number)=>number;
    const codec=new LiveCodec(w,alloc(LIVE_BYTES),alloc(LIVE_COLS*LIVE_ROWS),alloc(1500));
    codec.combiner=(w.robust_new as ()=>number)();codec.metrics=alloc(20);return codec;
  }
  encode(packet:Uint8Array) {
    if(packet.length!==LIVE_BYTES)throw new Error('Invalid live packet length');
    const m=this.w.memory as WebAssembly.Memory;
    new Uint8Array(m.buffer).set(packet,this.packet);
    (this.w.encode_robust_frame as (...p:number[])=>number)(this.packet,this.symbols);
    return new Uint8Array(m.buffer,this.symbols,LIVE_COLS*LIVE_ROWS).slice();
  }
  audio(packet:Uint8Array) {
    if(packet.length!==LIVE_BYTES)throw new Error('Invalid live packet length');
    const m=this.w.memory as WebAssembly.Memory;
    new Uint8Array(m.buffer).set(packet,this.packet);
    if((this.w.decode_audio_v4 as (...p:number[])=>number)(this.packet,this.pcm)!==750)throw new Error('Invalid audio block');
    const samples=Float32Array.from(new Int16Array(m.buffer,this.pcm,750),v=>v/32768);
    const v=new DataView(packet.buffer,packet.byteOffset,packet.byteLength);
    return {samples,sampleRate:6000,id:v.getUint32(4,true),index:v.getUint32(8,true),total:v.getUint32(12,true)};
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
    return this.receive(this.image,data.width,data.height,roi);
  }
  resetFusion() {if(this.combiner)(this.w.robust_free as (p:number)=>void)(this.combiner);this.combiner=(this.w.robust_new as ()=>number)();}
  dispose() {if(this.combiner)(this.w.robust_free as (p:number)=>void)(this.combiner);this.combiner=0;}
  private receive(image:number,width:number,height:number,roi:Roi) {
    const ok=(this.w.receive_robust_roi as (...p:number[])=>number)(this.combiner,image,width,height,Math.round(roi.x),Math.round(roi.y),Math.round(roi.w),Math.round(roi.h),this.packet,this.metrics);
    const m=this.w.memory as WebAssembly.Memory;
    const metrics=new Uint32Array(m.buffer,this.metrics,5);
    this.failureCode=metrics[0];this.captures=metrics[1];this.corrected=metrics[2];this.confidence=metrics[3];this.fused=metrics[0]===5;
    this.stage=['Grid bounds invalid','Calibration colors blurred','Protected frame ID unreadable','Collecting same-frame captures; FEC / CRC not yet valid','Frame verified with Reed–Solomon + CRC','Combined captures verified with Reed–Solomon + CRC','Mixed frame IDs: capture rejected'][metrics[0]]??'Decode failed';
    return ok===1?new Uint8Array(m.buffer,this.packet,LIVE_BYTES).slice():null;
  }
  autoDecode(data:ImageData) {
    this.captures=0;this.corrected=0;this.confidence=0;this.fused=false;
    this.upload(data);
    if(!this.quad) {
      const alloc=this.w.wasm_alloc as (n:number)=>number;
      this.quad=alloc(32);this.rectified=alloc(640*192*4);this.candidates=alloc(256);
    }
    const found=(this.w.locate_robust_grid as (...p:number[])=>number)(this.image,data.width,data.height,this.quad);
    this.corners=[];
    this.markers=found===4?4:Math.max(0,found);
    if(found!==4) {
      this.stage=found===-2?'Square finders seen; checking panel geometry':'Searching for alignment markers ('+this.markers+'/4)';
      return null;
    }
    const count=(this.w.robust_alignment_candidates as (p:number)=>number)(this.candidates);
    const m=this.w.memory as WebAssembly.Memory;
    const candidates=Array.from(new Float32Array(m.buffer,this.candidates,count*8));
    let best:{rank:number;corners:number[];stage:string;captures:number;corrected:number;confidence:number;fused:boolean}|null=null;
    for(let i=0;i<count;i++) {
      const corners=candidates.slice(i*8,i*8+8);
      new Float32Array(m.buffer,this.quad,8).set(corners);
      const warped=(this.w.rectify_robust_grid as (...p:number[])=>number)(this.image,data.width,data.height,this.quad,this.rectified);
      if(warped!==1)continue;
      const packet=this.receive(this.rectified,640,192,{x:0,y:0,w:640,h:192});
      const rank=packet?100:this.failureCode===6?40:this.failureCode===3?30:this.failureCode===2?10:0;
      if(!best||rank>best.rank)best={rank,corners,stage:this.stage,captures:this.captures,corrected:this.corrected,confidence:this.confidence,fused:this.fused};
      if(packet){this.corners=corners;this.stage='✓ Markers + packet orientation verified → '+this.stage;return packet;}
      // A CRC-protected identity establishes orientation even while the body
      // needs further captures. Never use another orientation to pollute it.
      if(this.failureCode===3||this.failureCode===6)break;
    }
    if(best){this.corners=best.corners;this.stage='Four markers found → '+best.stage;this.captures=best.captures;this.corrected=best.corrected;this.confidence=best.confidence;this.fused=best.fused;}
    else this.stage='Four markers found; grid perspective could not be sampled';
    return null;
  }
}
export type AudioBlock=ReturnType<LiveCodec['audio']>;
export class LivePlayer {
  private ctx:AudioContext|null=null;
  private analyser:AnalyserNode|null=null;
  private sources=new Set<AudioBufferSourceNode>();
  private seen=new Set<number>();
  private pending=new Map<number,AudioBlock>();
  private stream:number|null=null;
  private epoch=0;
  private base=0;
  private highest=-1;
  private next=0;
  private end=0;
  private waiting=false;
  private missing=0;
  private lastGood:Float32Array|null=null;
  private lastRate=6000;
  private lastTail=0;
  private jitter=0;
  private arrivalIndex=-1;
  private arrivalTime=0;
  private timer:ReturnType<typeof setInterval>|null=null;
  public late=0;
  public played=0;
  public concealed=0;
  public rebuffers=0;
  public latencySeconds=.5;
  async enable() {
    const session=(navigator as Navigator & {audioSession?:{type:string}}).audioSession;
    if(session)try{session.type='playback';}catch{}
    if(!this.ctx || this.ctx.state==='closed') {
      this.ctx=new AudioContext();
      this.analyser=this.ctx.createAnalyser();this.analyser.fftSize=256;this.analyser.connect(this.ctx.destination);
    }
    if(this.ctx.state!=='running'){this.reset();await this.ctx.resume();}
    if(this.ctx.state!=='running')throw new Error('Audio paused. Tap Enable audio again in Safari.');
    if(this.timer===null)this.timer=setInterval(()=>this.pump(),25);
  }
  get state(){return this.ctx?.state??'off';}
  get playing(){return this.state==='running'&&!!this.ctx&&this.ctx.currentTime<this.end;}
  waveform(){const a=new Uint8Array(128).fill(128);this.analyser?.getByteTimeDomainData(a);return a;}
  testTone(){
    if(!this.ctx||!this.analyser)return;
    const o=this.ctx.createOscillator(),g=this.ctx.createGain();o.frequency.value=440;g.gain.value=.12;o.connect(g);g.connect(this.analyser);o.start();o.stop(this.ctx.currentTime+.2);o.onended=()=>{o.disconnect();g.disconnect();};
  }
  push(b:AudioBlock):boolean {
    if(!this.ctx||!this.analyser||this.ctx.state!=='running')return false;
    if(this.stream!==b.id){this.reset();this.stream=b.id;this.next=b.index;this.base=this.ctx.currentTime+this.latencySeconds-b.index*BLOCK_SECONDS;}
    let index=this.epoch*b.total+b.index;
    if(this.highest-index>b.total/2){this.epoch++;index+=b.total;}
    else if(index-this.highest>b.total/2&&this.epoch>0)index-=b.total;
    if(this.seen.has(index))return false;
    this.seen.add(index);
    if(this.seen.size>2048)for(const n of this.seen)if(n<this.highest-512)this.seen.delete(n);
    if(index<this.next){this.late++;return false;}
    if(this.arrivalIndex>=0&&index>this.arrivalIndex){const error=Math.abs(this.ctx.currentTime-this.arrivalTime-(index-this.arrivalIndex)*BLOCK_SECONDS);this.jitter=this.jitter*.9+error*.1;this.latencySeconds=Math.min(1.5,Math.max(.5,.5+4*this.jitter));}
    if(index>this.arrivalIndex){this.arrivalIndex=index;this.arrivalTime=this.ctx.currentTime;}
    this.pending.set(index,b);this.highest=Math.max(this.highest,index);
    if(this.waiting){for(const n of this.pending.keys())if(n<index)this.pending.delete(n);this.next=index;this.base=Math.max(this.ctx.currentTime,this.end)+this.latencySeconds-index*BLOCK_SECONDS;this.waiting=false;this.missing=0;}
    this.pump();return true;
  }
  // Keep only a short scheduling horizon so repaired/reordered blocks can arrive
  // during the jitter window, rather than prematurely filling their slots.
  pump(){
    if(!this.ctx||!this.analyser||this.stream===null||this.waiting||this.ctx.state!=='running')return;
    for(let guard=0;guard<12;guard++){
      const when=this.base+this.next*BLOCK_SECONDS;if(when>this.ctx.currentTime+.15)return;
      if(when<this.ctx.currentTime-.1){this.rebuffer();return;}
      const b=this.pending.get(this.next);
      let samples:Float32Array,rate:number;
      if(b){this.pending.delete(this.next);samples=b.samples;rate=b.sampleRate??4000;this.lastGood=samples;this.lastRate=rate;this.missing=0;this.played++;}
      else {
        if(!this.lastGood||this.missing>=3){this.rebuffer();return;}
        samples=this.lastGood.slice();rate=this.lastRate;
        const start=Math.max(0,1-this.missing/3),end=Math.max(0,1-(this.missing+1)/3);
        for(let i=0;i<samples.length;i++)samples[i]*=start+(end-start)*i/Math.max(1,samples.length-1);
        this.missing++;this.concealed++;
      }
      const buffer=this.ctx.createBuffer(1,Math.round(samples.length/rate*16000),16000),out=buffer.getChannelData(0);
      for(let i=0;i<out.length;i++){const p=i*rate/16000,j=Math.floor(p),f=p-j;out[i]=samples[j]*(1-f)+samples[Math.min(j+1,samples.length-1)]*f;if(i<48){const t=(i+1)/48;out[i]=this.lastTail*(1-t)+out[i]*t;}}
      this.lastTail=out[out.length-1];
      const source=this.ctx.createBufferSource();source.buffer=buffer;source.connect(this.analyser);this.sources.add(source);source.onended=()=>{this.sources.delete(source);source.disconnect();};
      const start=Math.max(this.ctx.currentTime+.005,when);source.start(start);this.end=start+BLOCK_SECONDS;this.next++;
    }
  }
  private rebuffer(){
    if(!this.ctx)return;
    this.waiting=true;this.rebuffers++;this.latencySeconds=Math.min(1.5,this.latencySeconds+.125);
    const available=Array.from(this.pending.keys()).filter(n=>n>=this.next).sort((a,b)=>a-b);
    if(available.length){this.next=available[0];this.base=Math.max(this.ctx.currentTime,this.end)+this.latencySeconds-this.next*BLOCK_SECONDS;this.waiting=false;this.missing=0;}
  }
  reset(){
    for(const s of this.sources){try{s.stop();}catch{}s.disconnect();}this.sources.clear();this.pending.clear();this.seen.clear();this.stream=null;this.epoch=0;this.highest=-1;this.end=0;this.waiting=false;this.missing=0;this.lastGood=null;this.lastTail=0;this.arrivalIndex=-1;this.jitter=0;this.latencySeconds=.5;this.played=0;this.late=0;this.concealed=0;this.rebuffers=0;
  }
  dispose(){if(this.timer!==null)clearInterval(this.timer);this.timer=null;this.reset();void this.ctx?.close();}
}
