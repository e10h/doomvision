import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import ts from 'typescript';
async function module(path){const code=ts.transpileModule(readFileSync(new URL(path,import.meta.url),'utf8'),{compilerOptions:{target:ts.ScriptTarget.ES2022,module:ts.ModuleKind.ES2022}}).outputText;return import(`data:text/javascript;base64,${Buffer.from(code).toString('base64')}`);}
const {LiveCodec}=await module('../src/lib/live.ts'),{profile}=await module('../src/lib/profile.ts');
const wasm=readFileSync(new URL('../public/optical_decoder.wasm',import.meta.url));globalThis.fetch=async()=>({ok:true,arrayBuffer:async()=>wasm.buffer.slice(wasm.byteOffset,wasm.byteOffset+wasm.byteLength)});
const p=profile({kbps:32,fps:8,cols:96,rows:29,colors:6});const encoder=await LiveCodec.create(p),decoder=await LiveCodec.create(p);
const colors=[[255,0,0],[0,255,0],[0,0,255],[255,255,0],[255,255,255],[0,0,0]];
function raster(symbols){const data=new Uint8ClampedArray(320*240*4).fill(255);function rect(x,y,w,h,c){for(let j=y;j<y+h;j++)for(let i=x;i<x+w;i++)data.set([...c,255],(j*320+i)*4);}
for(const [i,[x,y]]of [[13,14],[307,14],[307,224],[13,224]].entries()){rect(x-12,y-12,24,24,colors[5]);rect(x-8,y-8,16,16,colors[4]);rect(x-5,y-5,10,10,colors[5]);rect(x-3,(i<2?47:191)-3,6,6,colors[[0,1,2,3][i]]);}
for(let r=0;r<29;r++)for(let c=0;c<96;c++){const x=27+Math.floor((c*266+48)/96),x2=27+Math.floor(((c+1)*266+48)/96),y=40+Math.floor((r*158+14)/29),y2=40+Math.floor(((r+1)*158+14)/29);rect(x,y,x2-x,y2-y,colors[symbols[r*96+c]]);}return {width:320,height:240,data};}
let frame,expected;
for(let i=0;i<64;i++){const pcm=Int16Array.from({length:1000},(_,j)=>Math.round(Math.sin((i*1000+j)*.17)*22000));const packet=encoder.encodeAudio(pcm,1234,i,64),image=raster(encoder.encode(packet));const decoded=decoder.autoDecode(image,'ti84');assert(decoded,`frame ${i}: ${decoder.stage}`);assert.deepEqual(Buffer.from(decoded),Buffer.from(packet));assert.equal(decoder.audio(decoded).index,i);if(i===0){frame=image;expected=packet;}}
console.log('TI-84: all 64 native-size frames verify using dedicated geometry and maintained lock');
function matrix(src,dst){const a=[];for(let i=0;i<4;i++){const[x,y]=src[i],[u,v]=dst[i];a.push([x,y,1,0,0,0,-u*x,-u*y,u],[0,0,0,x,y,1,-v*x,-v*y,v]);}for(let c=0;c<8;c++){let p=c;for(let r=c+1;r<8;r++)if(Math.abs(a[r][c])>Math.abs(a[p][c]))p=r;[a[c],a[p]]=[a[p],a[c]];const s=a[c][c];for(let j=c;j<9;j++)a[c][j]/=s;for(let r=0;r<8;r++)if(r!==c){const f=a[r][c];for(let j=c;j<9;j++)a[r][j]-=f*a[c][j];}}return a.map(r=>r[8]);}
function map(m,x,y){const d=m[6]*x+m[7]*y+1;return[(m[0]*x+m[1]*y+m[2])/d,(m[3]*x+m[4]*y+m[5])/d];}

for(const [name,dst]of [['scaled',[[120,40],[760,40],[760,520],[120,520]]],['perspective',[[150,70],[760,40],[800,510],[100,470]]],['rotated',[[180,30],[800,100],[740,530],[120,460]]]]){
 const width=960,height=600,m=matrix(dst,[[0,0],[320,0],[320,240],[0,240]]),data=new Uint8ClampedArray(width*height*4);for(let y=0;y<height;y++)for(let x=0;x<width;x++){const [u,v]=map(m,x+.5,y+.5);const at=(y*width+x)*4;data.set([40,40,40,255],at);if(u>=0&&v>=0&&u<320&&v<240){const k=(Math.floor(v)*320+Math.floor(u))*4;data.set(frame.data.subarray(k,k+4),at);}}
 const c=await LiveCodec.create(p);const got=c.autoDecode({width,height,data},'ti84');assert(got,`${name}: ${c.stage}`);assert.deepEqual(Buffer.from(got),Buffer.from(expected));const forward=matrix([[0,0],[320,0],[320,240],[0,240]],dst);const selected=[[27,40],[293,40],[293,198],[27,198]].flatMap(([x,y])=>map(forward,x,y));const tapped=c.decodeTi84({width,height,data},selected);assert(tapped,`${name} manual corners: ${c.stage}`);assert.deepEqual(Buffer.from(tapped),Buffer.from(expected));c.dispose();console.log(`TI-84 ${name}: cold acquisition + exact packet verified`);
}
const blind={...frame,data:frame.data.slice()};for(let y=0;y<240;y++)for(let x=0;x<320;x++)if(y<40||y>=198||x<27||x>=293)blind.data.set([255,255,255,255],(y*320+x)*4);
const manual=await LiveCodec.create(p);assert.equal(manual.autoDecode(blind,'ti84'),null,'no finder lock when markers are removed');const picked=manual.decodeTi84(blind,[27,40,293,40,293,198,27,198]);assert(picked,manual.stage);assert.deepEqual(Buffer.from(picked),Buffer.from(expected));manual.dispose();console.log('TI-84: four selected corners decode exact audio with every marker removed');
const blank={width:320,height:240,data:new Uint8ClampedArray(320*240*4).fill(127)};assert.equal(decoder.autoDecode(blank,'ti84'),null,'lost screen must not replay stale payload');encoder.dispose();decoder.dispose();console.log('TI-84: missing screen rejected');
