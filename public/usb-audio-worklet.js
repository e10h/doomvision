class UsbAudio extends AudioWorkletProcessor {
  constructor() {
    super();
    this.ring = new Float32Array(8192); this.read=0; this.write=0;
    this.rate=16000; this.phase=0; this.primed=false; this.underruns=0; this.dropped=0; this.frames=0;
    this.port.onmessage=({data})=>{
      if(data.rate!==this.rate) { this.read=this.write=0; this.phase=0; this.primed=false; this.rate=data.rate; }
      for(const v of data.pcm) this.ring[this.write++%8192]=v;
      const max=Math.round(this.rate*.2);
      if(this.write-this.read>max){const skip=this.write-this.read-max;this.read+=skip;this.dropped+=skip;}
    };
  }
  process(_, outputs) {
    const out=outputs[0]; if(!out?.length)return true;
    for(let i=0;i<out[0].length;i++) {
      let value=0;
      if(!this.primed && this.write-this.read>=this.rate*.064) this.primed=true;
      if(this.primed) {
        if(this.write-this.read<4){this.primed=false;this.underruns++;}
        else {
          const r=this.read, a=this.ring[r%8192], b=this.ring[(r+1)%8192], c=this.ring[(r+2)%8192], d=this.ring[(r+3)%8192], t=this.phase;
          value=Math.max(-1,Math.min(1,(-.5*a+1.5*b-1.5*c+.5*d)*t*t*t+(a-2.5*b+2*c-.5*d)*t*t+(-.5*a+.5*c)*t+b));
          this.phase+=this.rate/sampleRate;
          const step=Math.floor(this.phase);this.read+=step;this.phase-=step;
        }
      }
      for(const channel of out)channel[i]=value;
    }
    this.frames+=out[0].length;
    if(this.frames>=sampleRate/4){this.frames=0;this.port.postMessage({queued:Math.round((this.write-this.read)*1000/this.rate),underruns:this.underruns,dropped:this.dropped});}
    return true;
  }
}
registerProcessor('usb-audio',UsbAudio);
