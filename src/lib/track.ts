// Sender-only preparation; receiver audio comes solely from optical packets.
function resample(input:Float32Array,inputRate:number,rate:number,length:number):Float32Array{
 const ratio=inputRate/rate,cutoff=Math.min(1,1/ratio)*.92,taps=32,phases=256,kernels:Float32Array[]=[];
 for(let phase=0;phase<phases;phase++){const k=new Float32Array(taps);let sum=0;for(let t=0;t<taps;t++){const x=t-(taps/2-1)-phase/phases,sinc=Math.abs(x)<1e-8?cutoff:Math.sin(Math.PI*cutoff*x)/(Math.PI*x),window=.5+.5*Math.cos(Math.PI*x/(taps/2));k[t]=sinc*window;sum+=k[t];}for(let t=0;t<taps;t++)k[t]/=sum;kernels.push(k);}
 const out=new Float32Array(length);
 for(let i=0;i<length;i++){const x=i*ratio,base=Math.floor(x),k=kernels[Math.min(255,Math.floor((x-base)*256))];let sum=0;for(let t=0;t<taps;t++)sum+=input[Math.max(0,Math.min(input.length-1,base+t-(taps/2-1)))]*k[t];out[i]=sum;}
 return out;
}
export function monoPcm(buffer:AudioBuffer,rate:number):Int16Array{
 const channels=Array.from({length:buffer.numberOfChannels},(_,i)=>buffer.getChannelData(i));
 let mono:Float32Array=new Float32Array(buffer.length);for(let i=0;i<mono.length;i++){let v=0;for(const c of channels)v+=c[i];mono[i]=v/channels.length;}
 // Cascaded half-rate stages keep the anti-alias filter effective even when
 // reducing 44.1 kHz source audio all the way to 250 samples/second.
 let currentRate=buffer.sampleRate;
 while(currentRate/rate>2){const next=currentRate/2;mono=resample(mono,currentRate,next,Math.ceil(mono.length/2));currentRate=next;}
 const filtered=resample(mono,currentRate,rate,Math.ceil(buffer.duration*rate));
 return Int16Array.from(filtered,v=>Math.round(Math.max(-1,Math.min(1,v))*32767));
}
