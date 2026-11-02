export type LinkSettings={kbps:number;fps:number;cols:number;rows:number};
export const BITRATES=[24,32,48,64,96,128];
export const FRAME_RATES=[4,8,16];
export function profile(s:LinkSettings){
 if(!BITRATES.includes(s.kbps)||!FRAME_RATES.includes(s.fps)||!Number.isInteger(s.cols)||!Number.isInteger(s.rows)||s.cols<32||s.cols>256||s.rows<8||s.rows>128)throw new Error('Unsupported link settings');
 const sampleRate=s.kbps*250,samples=sampleRate/s.fps,audioBytes=Math.ceil(samples/2),lanes=Math.ceil((audioBytes+30)/223),packetBytes=lanes*223,envelopeBytes=Math.ceil((lanes*255+30)/4)*4;
 const symbols=envelopeBytes/4*13,available=(s.cols-6)*s.rows,capacityBytes=Math.floor(available/13)*4;
 return{...s,sampleRate,samples,audioBytes,lanes,packetBytes,envelopeBytes,symbols,available,capacityBytes,dots:s.cols*s.rows,fits:available>=symbols&&lanes<=32};
}
export function autoFit(kbps:number,fps:number):LinkSettings{
 let best:LinkSettings|null=null,score=Infinity;
 for(let cols=32;cols<=256;cols+=8)for(let rows=8;rows<=128;rows++){
  const s={kbps,fps,cols,rows},p=profile(s);if(!p.fits)continue;
  const cost=p.dots*(1+.2*Math.abs(Math.log((cols/rows)/(320/96))));if(cost<score){score=cost;best=s;}
 }
 if(!best)throw new Error('No supported grid can fit this rate');return best;
}
export const DEFAULT_SETTINGS=autoFit(128,8);
export function readSettings(search:string):LinkSettings{
 const p=new URLSearchParams(search),kbps=Number(p.get('kbps')??128),fps=Number(p.get('fps')??8);
 try{const fit=autoFit(kbps,fps),s={kbps,fps,cols:Number(p.get('cols')??fit.cols),rows:Number(p.get('rows')??fit.rows)};profile(s);return s;}catch{return DEFAULT_SETTINGS;}
}
