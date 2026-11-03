"use client";
import {useEffect,useRef,useState} from 'react';
import Link from 'next/link';
import {LiveCodec,LivePlayer} from '../../lib/live';
import {profile} from '../../lib/profile';
import type {Roi} from '../../lib/color';
const SETTINGS={kbps:32,fps:8,cols:96,rows:29,colors:6};
export default function Ti84Reader(){
 const video=useRef<HTMLVideoElement>(null),canvas=useRef<HTMLCanvasElement>(null);
 const codec=useRef<LiveCodec|null>(null),player=useRef<LivePlayer|null>(null),stream=useRef<MediaStream|null>(null);
 const manual=useRef<Roi|null>(null),drag=useRef<{x:number;y:number}|null>(null),generation=useRef(0);
 const [ready,setReady]=useState(false),[running,setRunning]=useState(false),[opening,setOpening]=useState(false),[error,setError]=useState(''),[cropMode,setCropMode]=useState(false);
 const [status,setStatus]=useState('Ready to scan'),[stats,setStats]=useState({valid:0,rejected:0,played:0,audio:'off',playing:false,index:-1});
 useEffect(()=>{const cancelPending=()=>{generation.current++;};let active=true;const p=new LivePlayer();player.current=p;let c:LiveCodec|null=null;
 void LiveCodec.create(profile(SETTINGS)).then(value=>{c=value;if(active){codec.current=value;setReady(true);}else value.dispose();}).catch(e=>{if(active)setError(String(e));});
 return()=>{active=false;cancelPending();stream.current?.getTracks().forEach(t=>t.stop());p.dispose();if(codec.current===c)codec.current=null;c?.dispose();};},[]);
 const stop=()=>{generation.current++;stream.current?.getTracks().forEach(t=>t.stop());stream.current=null;player.current?.reset();codec.current?.resetFusion();if(codec.current)codec.current.corners=[];setRunning(false);setOpening(false);};
 const start=async()=>{
 const token=++generation.current;setOpening(true);setError('');
 try{
 // AudioContext creation/resume must happen directly from the iPhone tap.
 await player.current?.enable();
 if(!window.isSecureContext||!navigator.mediaDevices?.getUserMedia)throw new Error('Camera needs HTTPS. Open this site directly in Safari and allow Camera.');
 const s=await navigator.mediaDevices.getUserMedia({audio:false,video:{facingMode:{ideal:'environment'},width:{ideal:1920},height:{ideal:1080},frameRate:{ideal:30}}});
 if(generation.current!==token){s.getTracks().forEach(t=>t.stop());return;}stream.current=s;
 if(!video.current){s.getTracks().forEach(t=>t.stop());return;}video.current.srcObject=s;await video.current.play();
 if(generation.current!==token)return;player.current?.reset();codec.current?.resetFusion();if(codec.current)codec.current.corners=[];manual.current=null;setRunning(true);
 }catch(e){if(generation.current===token){stream.current?.getTracks().forEach(t=>t.stop());stream.current=null;setError(String(e));}}finally{if(generation.current===token)setOpening(false);}
 };
 useEffect(()=>{if(!running)return;let raf=0,lastVideo=-1,ui=0,valid=0,rejected=0,index=-1;
 const tick=(now:number)=>{raf=requestAnimationFrame(tick);const v=video.current,view=canvas.current,c=codec.current,p=player.current;
 if(!v||!view||!c||!p||v.readyState<2||v.currentTime===lastVideo)return;lastVideo=v.currentTime;
 // Decode real camera pixels; CSS preview dimensions never become sample coordinates.
 if(view.width!==v.videoWidth||view.height!==v.videoHeight){view.width=v.videoWidth;view.height=v.videoHeight;}
 const ctx=view.getContext('2d',{willReadFrequently:true});if(!ctx)return;ctx.drawImage(v,0,0);
 try{const pixels=ctx.getImageData(0,0,view.width,view.height);const packet=drag.current?null:cropMode?(manual.current?c.decode(pixels,manual.current):null):c.autoDecode(pixels,'ti84');
 if(packet){const block=c.audio(packet);p.push(block);valid++;index=block.index;}else rejected++;
 }catch(e){setError(String(e));}
 ctx.strokeStyle='#00ff88';ctx.lineWidth=Math.max(2,view.width/500);
 if(cropMode&&manual.current){const r=manual.current;ctx.strokeRect(r.x,r.y,r.w,r.h);}else if(!cropMode&&c.corners.length===8){ctx.beginPath();for(let i=0;i<4;i++){if(i)ctx.lineTo(c.corners[i*2],c.corners[i*2+1]);else ctx.moveTo(c.corners[0],c.corners[1]);}ctx.closePath();ctx.stroke();}
 if(now-ui>200){ui=now;setStatus(cropMode&&!manual.current?'Drag around the colored grid only':c.stage);setStats({valid,rejected,index,played:p.played,audio:p.state,playing:p.playing});}
 };raf=requestAnimationFrame(tick);return()=>cancelAnimationFrame(raf);},[running,cropMode]);
 const point=(e:React.PointerEvent<HTMLCanvasElement>)=>{const b=e.currentTarget.getBoundingClientRect();return{x:Math.max(0,Math.min(e.currentTarget.width-1,(e.clientX-b.left)*e.currentTarget.width/b.width)),y:Math.max(0,Math.min(e.currentTarget.height-1,(e.clientY-b.top)*e.currentTarget.height/b.height))};};
 return <main style={{maxWidth:900,margin:'auto',padding:16}}>
 <Link href="/optical" style={{color:'#00d8ff'}}>← Optical audio</Link><h1 style={{fontSize:26,margin:'16px 0'}}>TI-84 Plus CE reader</h1>
 <p>32 kbps · 6 colors · 96 × 29 · 8 fps</p>
 <p>Run DVSUN8. Keep all four corner squares visible, then press 2nd on the calculator.</p>
 <div style={{display:'flex',flexWrap:'wrap',gap:10,margin:'16px 0'}}>
 <button className="custom-btn active" disabled={!ready||opening} onClick={running?stop:start}>{opening?'Opening camera…':running?'Stop':'Start camera + sound'}</button>
 <button className="custom-btn" disabled={!ready} onClick={async()=>{try{await player.current?.enable();player.current?.testTone();}catch(e){setError(String(e));}}}>Test sound</button>
 <button className="custom-btn" disabled={!running} onClick={()=>{manual.current=null;drag.current=null;codec.current?.resetFusion();if(codec.current)codec.current.corners=[];setCropMode(v=>!v);}}>{cropMode?'Use automatic lock':'Manual grid crop'}</button>
 </div>
 {error&&<p role="alert" style={{color:'#ff8888'}}>{error}</p>}
 <div style={{position:'relative',background:'#000',minHeight:160}}><video ref={video} autoPlay playsInline muted style={{width:'100%',display:'block'}}/><canvas ref={canvas} aria-label="TI-84 camera preview and grid selection" style={{position:'absolute',inset:0,width:'100%',height:'100%',touchAction:'none'}} onPointerDown={e=>{if(!cropMode)return;e.currentTarget.setPointerCapture(e.pointerId);drag.current=point(e);}} onPointerMove={e=>{if(!cropMode||!drag.current)return;const a=drag.current,b=point(e);manual.current={x:Math.min(a.x,b.x),y:Math.min(a.y,b.y),w:Math.max(1,Math.abs(a.x-b.x)),h:Math.max(1,Math.abs(a.y-b.y))};}} onPointerUp={()=>{drag.current=null;}} onPointerCancel={()=>{drag.current=null;}}/></div>
 <p role="status" style={{color:stats.playing?'#00ff88':'#ffaa00'}}>{!ready?'Loading decoder…':!running?'Camera stopped':stats.audio!=='running'?'Tap Test sound to enable audio':stats.playing?'Playing optical audio':stats.valid?'Buffering verified audio…':'Scanning for calculator…'}</p>
 <p role="status">{running?status:'Calculator geometry is preconfigured.'}</p>
 <p>{stats.valid} verified · {stats.rejected} rejected · {stats.played} scheduled{stats.index>=0?` · ${(stats.index/8).toFixed(1)}s`:''}</p>
 {cropMode&&<p>Drag tightly around the colored rectangle, including its calibration columns. Exclude corner markers and white margins.</p>}
 <p style={{fontSize:13,color:'#8b98ac'}}>Hold the phone steady and close enough to resolve individual cells. The green outline tracks the data grid. Only CRC-verified audio plays.</p>
 <a href="/downloads/DVSUN8.8xp" style={{color:'#00d8ff'}}>Download matching DVSUN8.8xp</a>
 </main>;
}
