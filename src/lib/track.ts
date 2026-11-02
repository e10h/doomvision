// Sender-only preparation. All decoded audio on the receiving phone comes from
// optical packets, never from this source download.
export function monoPcm(buffer:AudioBuffer,rate:number):Int16Array{
 const channels=Array.from({length:buffer.numberOfChannels},(_,i)=>buffer.getChannelData(i));
 const mono=new Float32Array(buffer.length);for(let i=0;i<mono.length;i++){let v=0;for(const c of channels)v+=c[i];mono[i]=v/channels.length;}
 const ratio=buffer.sampleRate/rate,cutoff=Math.min(1,1/ratio)*.92,taps=32,phases=256,kernels:Float32Array[]=[];
 for(let phase=0;phase<phases;phase++){const k=new Float32Array(taps);let sum=0;for(let t=0;t<taps;t++){const x=t-(taps/2-1)-phase/phases;const sinc=Math.abs(x)<1e-8?cutoff:Math.sin(Math.PI*cutoff*x)/(Math.PI*x);const window=.5+.5*Math.cos(Math.PI*x/(taps/2));k[t]=sinc*window;sum+=k[t];}for(let t=0;t<taps;t++)k[t]/=sum;kernels.push(k);}
 const out=new Int16Array(Math.ceil(buffer.duration*rate));
 for(let i=0;i<out.length;i++){const x=i*ratio,base=Math.floor(x),k=kernels[Math.min(255,Math.floor((x-base)*256))];let sum=0;for(let t=0;t<taps;t++)sum+=mono[Math.max(0,Math.min(mono.length-1,base+t-(taps/2-1)))]*k[t];out[i]=Math.round(Math.max(-1,Math.min(1,sum))*32767);}
 return out;
}
