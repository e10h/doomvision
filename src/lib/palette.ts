export const PALETTE_SIZES=[6,8,16,32,64,128,256,512,1024];
export const CALIBRATION=[[0,0,0],[255,0,0],[0,255,0],[255,255,0],[0,0,255],[255,0,255],[0,255,255],[255,255,255],[64,64,64],[128,128,128],[192,192,192]];
const LEGACY=[[255,0,0],[0,255,0],[0,0,255],[255,255,0],[255,255,255],[0,0,0]];
function grayDecode(g:number){let b=0;for(;g;g>>=1)b^=g;return b;}
export function paletteRgb(index:number,count:number):number[]{
 if(count===6)return LEGACY[index];if(index>=count)return CALIBRATION[index-count];
 const bits=Math.log2(count),sizes=[Math.ceil(bits/3),Math.floor((bits+1)/3),Math.floor(bits/3)];let offset=0;
 return sizes.map(n=>{const max=(1<<n)-1,level=grayDecode((index>>offset)&max);offset+=n;return Math.round(level/max*255);});
}
export function paletteCss(count:number){return Array.from({length:count===6?6:count+11},(_,i)=>`rgb(${paletteRgb(i,count).join(',')})`);}
