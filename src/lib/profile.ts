export type LinkSettings={kbps:number;fps:number;cols:number;rows:number;colors?:number};
export const BITRATES=[1,2,4,8,12,16,24,32,48,64,96,128];
export const PALETTES=[6,8,16,32,64,128,256,512,1024];
export const FRAME_RATES=[4,8,16];
export function profile(s:LinkSettings){
 const colors=s.colors??6,pilots=colors===6?6:11,bits=colors===6?0:Math.log2(colors);
 if(!PALETTES.includes(colors)||!BITRATES.includes(s.kbps)||!FRAME_RATES.includes(s.fps)||!Number.isInteger(s.cols)||!Number.isInteger(s.rows)||s.cols<32||s.cols>256||s.rows<8||s.rows>128)throw new Error('Unsupported link settings');
 const sampleRate=s.kbps*250,samples=Math.ceil(sampleRate/s.fps),audioBytes=Math.ceil(samples/2),lanes=Math.ceil((audioBytes+30)/223),laneData=lanes===1?audioBytes+30:223,packetBytes=lanes*laneData,envelopeBytes=Math.ceil((lanes*(laneData+32)+30)/4)*4;
 const symbols=colors===6?envelopeBytes/4*13:Math.ceil(envelopeBytes*8/bits),available=(s.cols-pilots)*s.rows,capacityBytes=colors===6?Math.floor(available/13)*4:Math.floor(available*bits/8);
 return{...s,colors,pilots,bits,bitsPerCell:colors===6?32/13:bits,sampleRate,samples,audioBytes,lanes,laneData,packetBytes,envelopeBytes,symbols,available,capacityBytes,dots:s.cols*s.rows,fits:available>=symbols&&lanes<=32};
}
export function autoFit(kbps:number,fps:number,colors=6):LinkSettings{
 let best:LinkSettings|null=null,score=Infinity;
 for(let cols=32;cols<=256;cols+=8)for(let rows=8;rows<=128;rows++){
  const s={kbps,fps,cols,rows,colors},p=profile(s);if(!p.fits)continue;
  const cost=p.dots*(1+.2*Math.abs(Math.log((cols/rows)/(320/96))));if(cost<score){score=cost;best=s;}
 }
 if(!best)throw new Error('No supported grid can fit this rate');return best;
}
export const DEFAULT_SETTINGS=autoFit(128,8);
export function readSettings(search:string):LinkSettings{
 const p=new URLSearchParams(search),kbps=Number(p.get('kbps')??128),fps=Number(p.get('fps')??8),colors=Number(p.get('colors')??6);
 try{const fit=autoFit(kbps,fps,colors),s={kbps,fps,colors,cols:Number(p.get('cols')??fit.cols),rows:Number(p.get('rows')??fit.rows)};profile(s);return s;}catch{return DEFAULT_SETTINGS;}
}

export function frameSamples(rate:number,fps:number,index:number){return Math.floor((index+1)*rate/fps)-Math.floor(index*rate/fps);}
