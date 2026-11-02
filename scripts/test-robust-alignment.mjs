import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import ts from 'typescript';
const source=ts.transpileModule(readFileSync(new URL('../src/lib/alignment.ts',import.meta.url),'utf8'),{compilerOptions:{target:ts.ScriptTarget.ES2022,module:ts.ModuleKind.ES2022}}).outputText;
const {drawAlignment,GRID_X,GRID_Y}=await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`);
const {instance:{exports:w}}=await WebAssembly.instantiate(readFileSync(new URL('../public/optical_decoder.wasm',import.meta.url)));
const packet=w.wasm_alloc(446),symbols=w.wasm_alloc(1920),quad=w.wasm_alloc(32),rectified=w.wasm_alloc(640*192*4),out=w.wasm_alloc(446),image=w.wasm_alloc(960*540*4);
const state=w.robust_new(),metrics=w.wasm_alloc(20);
const sample=readFileSync(new URL('../public/samples/never-gonna-give-you-up-30s.dva4',import.meta.url)).subarray(20*446,21*446);
new Uint8Array(w.memory.buffer).set(sample,packet);w.encode_robust_frame(packet,symbols);
const codes=new Uint8Array(w.memory.buffer,symbols,1920).slice(), palette=['#ff0000','#00ff00','#0000ff','#ffff00','#ffffff','#000000'];
const frame=new Uint8Array(384*160*4);
const ctx={fillStyle:'#ffffff',fillRect(x,y,width,height){const hex=this.fillStyle.slice(1),c=[parseInt(hex.slice(0,2),16),parseInt(hex.slice(2,4),16),parseInt(hex.slice(4,6),16),255];for(let yy=y;yy<y+height;yy++)for(let xx=x;xx<x+width;xx++)frame.set(c,(yy*384+xx)*4);}};
drawAlignment(ctx,1);
for(let y=0;y<24;y++)for(let x=0;x<80;x++){ctx.fillStyle=palette[codes[y*80+x]];ctx.fillRect(GRID_X+x*4,GRID_Y+y*4,4,4);}
function matrix(src,dst){const a=[];for(let i=0;i<4;i++){const[x,y]=src[i],[u,v]=dst[i];a.push([x,y,1,0,0,0,-u*x,-u*y,u],[0,0,0,x,y,1,-v*x,-v*y,v]);}for(let c=0;c<8;c++){let p=c;for(let r=c+1;r<8;r++)if(Math.abs(a[r][c])>Math.abs(a[p][c]))p=r;[a[c],a[p]]=[a[p],a[c]];const s=a[c][c];for(let j=c;j<9;j++)a[c][j]/=s;for(let r=0;r<8;r++)if(r!==c){const f=a[r][c];for(let j=c;j<9;j++)a[r][j]-=f*a[c][j];}}return a.map(r=>r[8]);}
function map(m,x,y){const d=m[6]*x+m[7]*y+1;return[(m[0]*x+m[1]*y+m[2])/d,(m[3]*x+m[4]*y+m[5])/d];}
const flat=[[80,130],[848,130],[848,450],[80,450]];
const rotated=flat.map(([x,y])=>{x-=480;y-=270;const a=.18;return[480+x*Math.cos(a)-y*Math.sin(a),270+x*Math.sin(a)+y*Math.cos(a)];});
const scenes=[['flat',flat,false],['rotation',rotated,false],['perspective',[[110,60],[840,95],[780,470],[160,430]],true],['mirrored',[[848,130],[80,130],[80,450],[848,450]],true],['blurred + noise',flat,true,true],['display gamut',flat,false,false,true]];
let flatPixels;
for(const [name,dst,tint,blur,gamut] of scenes){
 const m=matrix(dst,[[0,0],[384,0],[384,160],[0,160]]),pixels=new Uint8Array(960*540*4);
 for(let y=0;y<540;y++)for(let x=0;x<960;x++){
   const [u,v]=map(m,x+.5,y+.5);let color=[45,48,55,255];
   if(u>=0&&v>=0&&u<384&&v<160){const i=(Math.floor(v)*384+Math.floor(u))*4;color=Array.from(frame.subarray(i,i+4));}
   if(gamut){const k=palette.findIndex(hex=>{const rgb=[parseInt(hex.slice(1,3),16),parseInt(hex.slice(3,5),16),parseInt(hex.slice(5,7),16)];return rgb.every((v,c)=>v===color[c]);});if(k>=0)color=[...[[225,54,34],[118,248,88],[0,5,219],[255,252,98],[255,255,255],[0,0,0]][k],255];}
   if(tint)color=color.map((n,c)=>c===3?255:Math.round(n*[.7,.85,.6][c]+[18,12,25][c]));
   pixels.set(color,(y*960+x)*4);
 }
 if(name==='flat')flatPixels=pixels.slice();
 if(blur){const copy=pixels.slice();for(let y=1;y<539;y++)for(let x=1;x<959;x++)for(let c=0;c<3;c++){let sum=0;for(let dy=-1;dy<=1;dy++)for(let dx=-1;dx<=1;dx++)sum+=copy[((y+dy)*960+x+dx)*4+c];pixels[(y*960+x)*4+c]=Math.max(0,Math.min(255,Math.round(sum/9)+((x*13+y*17+c)%7-3)));}}
 new Uint8Array(w.memory.buffer).set(pixels,image);
 const found=w.locate_robust_grid(image,960,540,quad);
 assert.equal(found,4,`${name}: four finders and orientation identified (got ${found})`);
 assert.equal(w.rectify_robust_grid(image,960,540,quad,rectified),1);
 const ok=w.receive_robust_roi(state,rectified,640,192,0,0,640,192,out,metrics);
 assert.equal(ok,1,`${name}: perspective-corrected grid CRC`);
 assert.deepEqual(Buffer.from(new Uint8Array(w.memory.buffer,out,446)),sample);
 console.log(`${name}: four markers, orientation, perspective correction, and exact audio packet passed`);
}
for(let y=130;y<195;y++)for(let x=80;x<146;x++)flatPixels.set([45,48,55,255],(y*960+x)*4);
new Uint8Array(w.memory.buffer).set(flatPixels,image);
assert.notEqual(w.locate_robust_grid(image,960,540,quad),4,'occluded marker never claims alignment');
new Uint8Array(w.memory.buffer).fill(127,image,image+960*540*4);
assert.equal(w.locate_robust_grid(image,960,540,quad),0,'blank frame never locks');
if(process.argv[2]) {
 const pixels=readFileSync(process.argv[2]),iw=Number(process.argv[3]),ih=Number(process.argv[4]);
 assert.equal(pixels.length,iw*ih*4);const p=w.wasm_alloc(pixels.length);new Uint8Array(w.memory.buffer).set(pixels,p);
 assert.equal(w.locate_robust_grid(p,iw,ih,quad),4,'actual browser screenshot alignment');
 assert.equal(w.rectify_robust_grid(p,iw,ih,quad,rectified),1);
 assert.equal(w.receive_robust_roi(state,rectified,640,192,0,0,640,192,out,metrics),1,'actual screenshot packet CRC');
 assert.deepEqual(Buffer.from(new Uint8Array(w.memory.buffer,out,446)),readFileSync(new URL('../public/samples/never-gonna-give-you-up-30s.dva4',import.meta.url)).subarray(0,446));
 console.log('Actual browser screenshot: markers, rectification, and exact first audio packet passed.');
}
w.robust_free(state);console.log('Robust alignment tests passed.');
