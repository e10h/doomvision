"use client";
import { useEffect, useRef, useState } from 'react';
import Link from 'next/link';
import { Assembly, ColorCodec, COLORS, crc32, makePacket, PAYLOAD, Roi } from '../../../lib/color';

export default function OpticalDemo() {
  const [mode,setMode] = useState<'send'|'receive'>('send');
  const [ready,setReady] = useState(false), [error,setError] = useState('');
  const [name,setName] = useState('Never Gonna Give You Up · first 30 seconds');
  const [file,setFile] = useState<Uint8Array|null>(null);
  const [sending,setSending] = useState(false), [frame,setFrame] = useState(0), [fps,setFps] = useState(8);
  const [camera,setCamera] = useState(false), [starting,setStarting] = useState(false);
  const [progress,setProgress] = useState({ received:0,total:0, rejected:0 });
  const [result,setResult] = useState('');
  const [loop,setLoop] = useState(0);
  const codec = useRef<ColorCodec|null>(null), sender = useRef<HTMLCanvasElement|null>(null);
  const video = useRef<HTMLVideoElement|null>(null), preview = useRef<HTMLCanvasElement|null>(null);
  const stream = useRef<MediaStream|null>(null), assembly = useRef(new Assembly());
  const crop = useRef<Roi|null>(null), drag = useRef<{x:number;y:number}|null>(null);
  const outputUrl = useRef('');
  const count = file ? Math.ceil(file.length/PAYLOAD) : 0;

  useEffect(() => {
    let active = true;
    ColorCodec.create().then(c => { if (active) { codec.current=c; setReady(true); } }).catch(e=>setError(String(e)));
    return () => { active=false; stream.current?.getTracks().forEach(t=>t.stop()); if(outputUrl.current) URL.revokeObjectURL(outputUrl.current); };
  },[]);

  const stopCamera = () => { stream.current?.getTracks().forEach(t=>t.stop()); stream.current=null; setCamera(false); };
  const startCamera = async () => {
    setError(''); setStarting(true);
    try {
      if (!window.isSecureContext || !navigator.mediaDevices?.getUserMedia) throw new Error('Camera requires HTTPS. Open this URL directly in Safari.');
      stream.current?.getTracks().forEach(t=>t.stop());
      const s = await navigator.mediaDevices.getUserMedia({ audio:false, video:{ facingMode:{ideal:'environment'}, width:{ideal:1280},height:{ideal:720},frameRate:{ideal:30} } });
      stream.current=s;
      if (!video.current) { s.getTracks().forEach(t=>t.stop()); return; }
      video.current.muted=true; video.current.playsInline=true; video.current.srcObject=s;
      await video.current.play(); crop.current=null; setCamera(true);
    } catch(e) { stream.current?.getTracks().forEach(t=>t.stop()); setError(`${String(e)}. Allow camera access in Safari Website Settings, then retry.`); }
    finally { setStarting(false); }
  };

  // Each interval redraws only on packet boundaries. Repeat the entire file so
  // a receiver can collect missed packets without acknowledgements.
  useEffect(() => {
    if (!file || !codec.current || mode !== 'send') return;
    const id=crc32(file);
    let index=0, rounds=0;
    const draw = () => {
      const ctx=sender.current?.getContext('2d');
      if (!ctx || !codec.current) return;
      const symbols=codec.current.encode(makePacket(file,index*PAYLOAD,id));
      for(let r=0;r<6;r++) for(let c=0;c<40;c++) {
        ctx.fillStyle=COLORS[symbols[r*40+c]]; ctx.fillRect(c*24,r*12,24,12);
      }
      setFrame(index); setLoop(rounds);
      index++; if(index>=Math.ceil(file.length/PAYLOAD)) { index=0; rounds++; }
    };
    draw();
    if (!sending) return;
    const timer=window.setInterval(draw,1000/fps);
    return ()=>window.clearInterval(timer);
  },[file,sending,fps,mode,ready]);

  useEffect(() => {
    if(!camera || mode!=='receive') return;
    let raf=0, last=0, lastUi=0, rejected=0, done=false;
    const tick=(now:number) => {
      if(done) return;
      raf=requestAnimationFrame(tick);
      if(now-last<60) return; last=now;
      const v=video.current, canvas=preview.current, c=codec.current;
      if(!v || !canvas || !c || v.readyState<2 || !v.videoWidth) return;
      canvas.width=v.videoWidth; canvas.height=v.videoHeight;
      const ctx=canvas.getContext('2d',{willReadFrequently:true}); if(!ctx) return;
      ctx.drawImage(v,0,0);
      if(!crop.current) crop.current={x:canvas.width*.05,y:canvas.height*.25,w:canvas.width*.9,h:canvas.width*.9*.075};
      const roi=crop.current;
      try {
        const packet=c.decode(ctx.getImageData(0,0,canvas.width,canvas.height),roi);
        if(packet && !drag.current) {
          const bytes=assembly.current.accept(packet);
          if(bytes) {
            const url=URL.createObjectURL(new Blob([bytes.buffer as ArrayBuffer],{type:'audio/mpeg'}));
            if(outputUrl.current) URL.revokeObjectURL(outputUrl.current);
            outputUrl.current=url; setResult(url); done=true;
            setProgress({received:assembly.current.received,total:assembly.current.total,rejected});
            stream.current?.getTracks().forEach(t=>t.stop()); stream.current=null; setCamera(false);
          }
        } else { rejected++; }
      } catch(e) { setError(String(e)); done=true; }
      ctx.strokeStyle='#00ff88';ctx.lineWidth=2;ctx.strokeRect(roi.x,roi.y,roi.w,roi.h);
      if(now-lastUi>250 && !done) { lastUi=now; setProgress({received:assembly.current.received,total:assembly.current.total,rejected}); }
    };
    raf=requestAnimationFrame(tick);
    return ()=>cancelAnimationFrame(raf);
  },[camera,mode]);

  const point = (e:React.PointerEvent<HTMLCanvasElement>) => {
    const canvas=e.currentTarget,b=canvas.getBoundingClientRect();
    return {x:Math.max(0,Math.min(canvas.width-1,(e.clientX-b.left)*canvas.width/b.width)),y:Math.max(0,Math.min(canvas.height-1,(e.clientY-b.top)*canvas.height/b.height))};
  };
  const reset = () => { stopCamera(); assembly.current=new Assembly(); setProgress({received:0,total:0,rejected:0});setResult('');setError(''); if(outputUrl.current) {URL.revokeObjectURL(outputUrl.current);outputUrl.current='';} };
  return <main style={{maxWidth:1100,margin:'0 auto',padding:20}}>
    <Link href="/" style={{color:'#00d8ff'}}>← Doom receiver</Link>
    <h1 style={{fontSize:28,fontWeight:800,marginTop:20}}>Six colors. Actual audio bytes.</h1>
    <p>Send the first 30 seconds of your music through a camera. No sound IDs or receiver-side sample downloads.</p>
    <div style={{display:'flex',gap:12,margin:'20px 0',flexWrap:'wrap'}}>
      <button className="custom-btn" onClick={()=>{stopCamera();setMode('send');}}>Send on a screen</button>
      <button className="custom-btn" onClick={()=>{setSending(false);setMode('receive');}}>Receive on iPhone</button>
      <span>{ready?'✓ Rust color codec ready':'Loading Rust codec…'}</span>
    </div>
    {error && <p role="alert" style={{color:'#ff8888'}}>{error}</p>}
    {mode==='send' ? <section className="glass-panel" style={{padding:20}}>
      <h2>1. Prepare the sample</h2>
      <button className="custom-btn" disabled={!ready} onClick={async()=>{try{setSending(false);const r=await fetch('/samples/never-gonna-give-you-up-30s.mp3');if(!r.ok)throw new Error(`Sample HTTP ${r.status}`);setFile(new Uint8Array(await r.arrayBuffer()));setName('Never Gonna Give You Up · first 30 seconds');setError('');}catch(e){setError(String(e));}}}>Load 30-second sample</button>
      <p>Or choose an MP3 (up to 2 MB): <input aria-label="Choose MP3" type="file" accept="audio/mpeg,.mp3" onChange={async e=>{const f=e.target.files?.[0];if(!f)return;setSending(false);if(f.size>2_000_000){setError('Choose a file under 2 MB.');return;}setFile(new Uint8Array(await f.arrayBuffer()));setName(f.name);}}/></p>
      {file && <>
        <p>{name} · {file.length.toLocaleString()} bytes · {count} packets · {(count/fps/60).toFixed(1)} minutes per pass.</p>
        <h2>2. Display the strip</h2>
        <p>Keep this screen awake. On the phone, select Receive and drag tightly around the entire colored rectangle, including all six rows. Keep both devices level.</p>
        <canvas ref={sender} width={960} height={72} aria-label="Six-color data strip" style={{width:'100%',height:'auto',display:'block',imageRendering:'pixelated',margin:'20px 0'}}/>
        <div style={{display:'flex',gap:12,flexWrap:'wrap',alignItems:'center'}}>
          <button className="custom-btn active" onClick={()=>setSending(v=>!v)}>{sending?'Pause':'Start / restart transfer'}</button>
          <label>Packets / second <select value={fps} onChange={e=>{setSending(false);setFps(Number(e.target.value));}} style={{background:'#111',color:'white',padding:8}}>{[2,4,8].map(n=><option key={n}>{n}</option>)}</select></label>
          <span>Packet {frame+1} / {count} · pass {loop+1}</span>
        </div>
        <p>Passes repeat automatically. Missing or damaged packets are collected next pass. Pausing or changing speed restarts from packet one.</p>
      </>}
    </section> : <section className="glass-panel" style={{padding:20}}>
      <h2>Collect → verify → play</h2>
      <p>Point the rear camera at the sender. Drag from the strip’s top-left corner to its bottom-right corner to set the green crop. The receiver downloads no music file.</p>
      <div style={{display:'flex',gap:12,flexWrap:'wrap',marginBottom:16}}>
        <button className="custom-btn active" disabled={!ready || starting || !!result} onClick={camera?stopCamera:startCamera}>{starting?'Opening…':camera?'Stop camera':'Start rear camera'}</button>
        <button className="custom-btn" onClick={reset}>Reset transfer</button>
      </div>
      <div style={{position:'relative',background:'black',minHeight:180}}>
        <video ref={video} muted autoPlay playsInline style={{width:'100%',display:'block'}}/>
        <canvas ref={preview} style={{position:'absolute',inset:0,width:'100%',height:'100%',touchAction:'none'}} onPointerDown={e=>{e.currentTarget.setPointerCapture(e.pointerId);drag.current=point(e);}} onPointerMove={e=>{if(!drag.current)return;const p=point(e),a=drag.current;crop.current={x:Math.min(a.x,p.x),y:Math.min(a.y,p.y),w:Math.max(1,Math.abs(a.x-p.x)),h:Math.max(1,Math.abs(a.y-p.y))};}} onPointerUp={()=>{drag.current=null;}} onPointerCancel={()=>{drag.current=null;}}/>
      </div>
      <p role="status">{progress.received} / {progress.total || '?'} unique packets · {progress.rejected} scans without a valid packet</p>
      <progress aria-label="Transfer progress" value={progress.received} max={progress.total || 1} style={{width:'100%'}}/>
      {result ? <><p style={{color:'#00ff88'}}>✓ Complete file CRC verified. These are the bytes recovered from the camera.</p><audio controls src={result} style={{width:'100%'}}/><p><a href={result} download="optical-received.mp3">Download reconstructed MP3</a></p></> : <p>Playback unlocks only after every packet is received and the complete file checksum matches. If progress stalls, adjust the crop, focus, angle, or sender speed.</p>}
    </section>}
    <p style={{color:'#8b98ac',marginTop:20}}>Experimental 320 × 24 strip: 40 columns × 6 lanes. Red, green, blue, yellow, white, black. Each lane starts with six calibration cells. CRC-32 rejects damage; repeated passes recover missing packets. This prototype buffers the file before playback; it does not stream music in real time or correct perspective.</p>
  </main>;
}
