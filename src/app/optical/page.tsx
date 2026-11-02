"use client";
import {useEffect,useRef,useState} from 'react';
import Link from 'next/link';
import {COLORS,Roi} from '../../lib/color';
import {LiveCodec,LivePlayer,LIVE_BYTES,LIVE_COLS,LIVE_ROWS} from '../../lib/live';

export default function LiveOptical() {
  const [mode,setMode]=useState<'send'|'receive'>('send');
  const [ready,setReady]=useState(false),[error,setError]=useState('');
  const [data,setData]=useState<Uint8Array|null>(null),[sending,setSending]=useState(false),[frame,setFrame]=useState(0);
  const [camera,setCamera]=useState(false),[starting,setStarting]=useState(false);
  const [stats,setStats]=useState({valid:0,rejected:0,index:-1,played:0,late:0,audio:'off',playing:false});
  const codec=useRef<LiveCodec|null>(null),player=useRef<LivePlayer|null>(null);
  const strip=useRef<HTMLCanvasElement|null>(null),video=useRef<HTMLVideoElement|null>(null);
  const preview=useRef<HTMLCanvasElement|null>(null),scope=useRef<HTMLCanvasElement|null>(null);
  const stream=useRef<MediaStream|null>(null),crop=useRef<Roi|null>(null),drag=useRef<{x:number;y:number}|null>(null);
  useEffect(()=>{
    let active=true; const p=new LivePlayer();player.current=p;
    LiveCodec.create().then(c=>{if(active){codec.current=c;setReady(true);}}).catch(e=>setError(String(e)));
    return()=>{active=false;stream.current?.getTracks().forEach(t=>t.stop());p.dispose();};
  },[]);
  const stop=()=>{stream.current?.getTracks().forEach(t=>t.stop());stream.current=null;player.current?.reset();setCamera(false);};
  const enable=async(test=false)=>{try{await player.current?.enable();if(test)player.current?.testTone();setStats(s=>({...s,audio:player.current?.state??'off'}));}catch(e){setError(String(e));}};
  const start=async()=>{
    setStarting(true);setError('');
    // Unlock sound from the tap, before camera permission creates an async gap.
    void enable();
    try{
      if(!window.isSecureContext || !navigator.mediaDevices?.getUserMedia)throw new Error('Open the HTTPS site directly in Safari and allow Camera.');
      stream.current?.getTracks().forEach(t=>t.stop());player.current?.reset();
      const s=await navigator.mediaDevices.getUserMedia({audio:false,video:{facingMode:{ideal:'environment'},width:{ideal:1280},height:{ideal:720},frameRate:{ideal:30}}});
      stream.current=s;
      if(!video.current){s.getTracks().forEach(t=>t.stop());return;}
      video.current.muted=true;video.current.playsInline=true;video.current.srcObject=s;
      await video.current.play();crop.current=null;setCamera(true);
    }catch(e){stream.current?.getTracks().forEach(t=>t.stop());setError(`${String(e)} Check Safari Website Settings → Camera → Allow.`);}
    finally{setStarting(false);}
  };
  useEffect(()=>{
    if(mode!=='send' || !data || !codec.current)return;
    let index=0;
    const draw=()=>{
      const ctx=strip.current?.getContext('2d');if(!ctx || !codec.current)return;
      const symbols=codec.current.encode(data.subarray(index*LIVE_BYTES,(index+1)*LIVE_BYTES));
      for(let r=0;r<LIVE_ROWS;r++)for(let c=0;c<LIVE_COLS;c++){ctx.fillStyle=COLORS[symbols[r*LIVE_COLS+c]];ctx.fillRect(c*12,r*12,12,12);}
      setFrame(index);index=(index+1)%(data.length/LIVE_BYTES);
    };
    draw();if(!sending)return;
    const timer=window.setInterval(draw,125);return()=>clearInterval(timer);
  },[mode,data,sending,ready]);
  useEffect(()=>{
    if(mode!=='receive' || !camera)return;
    let raf=0,last=0,ui=0,valid=0,rejected=0,index=-1;
    const tick=(now:number)=>{
      raf=requestAnimationFrame(tick);if(now-last<45)return;last=now;
      const v=video.current,canvas=preview.current,c=codec.current,p=player.current;
      if(!v || !canvas || !c || !p || !v.videoWidth || v.readyState<2)return;
      if(canvas.width!==v.videoWidth || canvas.height!==v.videoHeight){canvas.width=v.videoWidth;canvas.height=v.videoHeight;}
      const ctx=canvas.getContext('2d',{willReadFrequently:true});if(!ctx)return;
      ctx.drawImage(v,0,0);
      if(!crop.current)crop.current={x:canvas.width*.05,y:canvas.height*.25,w:canvas.width*.9,h:canvas.width*.9*.2};
      const roi=crop.current;
      try{
        const packet=drag.current?null:c.decode(ctx.getImageData(0,0,canvas.width,canvas.height),roi);
        if(packet){const block=c.audio(packet);valid++;index=block.index;p.push(block);}else rejected++;
      }catch(e){setError(String(e));}
      ctx.strokeStyle='#00ff88';ctx.lineWidth=2;ctx.strokeRect(roi.x,roi.y,roi.w,roi.h);
      const osc=scope.current,oscCtx=osc?.getContext('2d');
      if(osc && oscCtx){const wave=p.waveform();oscCtx.fillStyle='#08090d';oscCtx.fillRect(0,0,osc.width,osc.height);oscCtx.strokeStyle='#00ff88';oscCtx.beginPath();wave.forEach((n,i)=>{const x=i*osc.width/wave.length,y=n/255*osc.height;if(i)oscCtx.lineTo(x,y);else oscCtx.moveTo(x,y);});oscCtx.stroke();}
      if(now-ui>200){ui=now;setStats({valid,rejected,index,played:p.played,late:p.late,audio:p.state,playing:p.playing});}
    };
    raf=requestAnimationFrame(tick);return()=>cancelAnimationFrame(raf);
  },[mode,camera]);
  const point=(e:React.PointerEvent<HTMLCanvasElement>)=>{const b=e.currentTarget.getBoundingClientRect(),c=e.currentTarget;return{x:Math.max(0,Math.min(c.width-1,(e.clientX-b.left)*c.width/b.width)),y:Math.max(0,Math.min(c.height-1,(e.clientY-b.top)*c.height/b.height))};};
  return <main style={{maxWidth:1100,margin:'0 auto',padding:20}}>
    <Link href="/" style={{color:'#00d8ff'}}>← Doom receiver</Link>
    <h1 style={{fontSize:28,fontWeight:800,marginTop:20}}>Live six-color audio</h1>
    <p>Each verified packet becomes 125 milliseconds of sound immediately. No full-file wait.</p>
    <div style={{display:'flex',gap:12,flexWrap:'wrap',margin:'20px 0'}}>
      <button className="custom-btn" onClick={()=>{stop();setMode('send');}}>Send on Mac</button>
      <button className="custom-btn" onClick={()=>{setSending(false);setMode('receive');}}>Receive + play on iPhone</button>
      <span>{ready?'✓ Rust live decoder ready':'Loading Rust decoder…'}</span>
    </div>
    {error && <p role="alert" style={{color:'#ff8888'}}>{error}</p>}
    {mode==='send'?<section className="glass-panel" style={{padding:20}}>
      <h2>Transmit the 30-second sample</h2>
      <button className="custom-btn" disabled={!ready} onClick={async()=>{try{setSending(false);const r=await fetch('/samples/never-gonna-give-you-up-30s.dvs');if(!r.ok)throw new Error(`Sample HTTP ${r.status}`);const b=new Uint8Array(await r.arrayBuffer());if(!b.length || b.length%LIVE_BYTES)throw new Error('Invalid sample stream');setData(b);setError('');}catch(e){setError(String(e));}}}>Load 30-second live sample</button>
      {data && <>
        <p>Rick Astley · first 30 seconds · 240 independent audio packets · 8 packets / second.</p>
        <canvas ref={strip} width={960} height={192} aria-label="Live six-color audio strip" style={{width:'100%',height:'auto',display:'block',imageRendering:'pixelated',margin:'20px 0'}}/>
        <button className="custom-btn active" onClick={()=>setSending(s=>!s)}>{sending?'Pause':'Start live transmission'}</button>
        <p>Packet {frame+1} / {data.length/LIVE_BYTES} · {(frame/8).toFixed(1)}s / 30s · {sending?'Transmitting; repeats every 30 seconds':'Paused; start transmission for the phone to hear music'}</p>
      </>}
      <p>The Mac displays data silently. Open this same page on the iPhone, choose Receive + play, and point its camera at the entire rectangle. Keep the display bright, level, and awake.</p>
    </section>:<section className="glass-panel" style={{padding:20}}>
      <h2>Scan → decode → play</h2>
      <p>Drag tightly from the colored rectangle’s top-left to bottom-right corner. Include all 16 rows. Hearing a test beep confirms your speaker; music requires valid optical packets.</p>
      <div style={{display:'flex',gap:12,flexWrap:'wrap',marginBottom:16}}>
        <button className="custom-btn active" disabled={!ready || starting} onClick={camera?stop:start}>{starting?'Opening…':camera?'Stop reception':'Start camera + audio'}</button>
        <button className="custom-btn" onClick={()=>enable(true)}>Enable audio / test beep</button>
      </div>
      <div style={{position:'relative',background:'black',minHeight:180}}>
        <video ref={video} autoPlay playsInline muted style={{width:'100%',display:'block'}}/>
        <canvas ref={preview} style={{position:'absolute',inset:0,width:'100%',height:'100%',touchAction:'none'}} onPointerDown={e=>{e.currentTarget.setPointerCapture(e.pointerId);drag.current=point(e);}} onPointerMove={e=>{if(!drag.current)return;const a=drag.current,b=point(e);crop.current={x:Math.min(a.x,b.x),y:Math.min(a.y,b.y),w:Math.max(1,Math.abs(a.x-b.x)),h:Math.max(1,Math.abs(a.y-b.y))};}} onPointerUp={()=>{drag.current=null;}} onPointerCancel={()=>{drag.current=null;}}/>
      </div>
      <p role="status" style={{color:stats.playing?'#00ff88':'#ffaa00'}}>{!camera?'Camera stopped':!stats.valid?'Scanning: no valid packets yet — adjust the green crop':stats.audio!=='running'?'Audio paused — tap Enable audio':stats.playing?'Playing incoming optical audio':'Waiting for the next audio packet'}</p>
      <p>{stats.valid} checksum-valid scans · {stats.played} audio blocks scheduled · {stats.rejected} rejected scans · {stats.late} late blocks · audio: {stats.audio}</p>
      {stats.index>=0 && <p>Received music position: {(stats.index/8).toFixed(1)}s / 30s</p>}
      <canvas ref={scope} width={640} height={80} aria-label="Decoded audio waveform" style={{width:'100%',height:80,background:'#08090d'}}/>
      <p>iPhone: raise media volume and check Control Center’s speaker route. If needed, turn Silent Mode off and tap Enable audio again.</p>
    </section>}
    <p style={{color:'#8b98ac',marginTop:20}}>Experimental 320 × 64 strip: 80 columns × 16 lanes, six colors, per-lane calibration, CRC-32, and independent Rust ADPCM decoding. 4 kHz mono audio is intentionally low fidelity. A 250 ms buffer smooths timing; missing packets make brief gaps. Manual alignment is required.</p>
    <Link href="/optical/file" style={{color:'#00d8ff'}}>Previous byte-perfect MP3 file-transfer experiment →</Link>
  </main>;
}
