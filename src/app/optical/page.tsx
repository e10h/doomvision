"use client";
import {useEffect,useRef,useState,useMemo} from 'react';
import Link from 'next/link';
import {drawAlignment,GRID_X,GRID_Y,FRAME_WIDTH,FRAME_HEIGHT} from '../../lib/alignment';
import {BITRATES,FRAME_RATES,DEFAULT_SETTINGS,readSettings,autoFit,profile,LinkSettings,frameSamples} from '../../lib/profile';
import {monoPcm} from '../../lib/track';
import {COLORS,Roi,crc32} from '../../lib/color';
import {LiveCodec,LivePlayer} from '../../lib/live';

export default function LiveOptical() {
  const [settings,setSettings]=useState<LinkSettings>(DEFAULT_SETTINGS);
  const plan=useMemo(()=>profile(settings),[settings]);
  const [paramsReady,setParamsReady]=useState(false),[origin,setOrigin]=useState('');
  const [sourceBuffer,setSourceBuffer]=useState<AudioBuffer|null>(null),[duration,setDuration]=useState(0),[trackStatus,setTrackStatus]=useState('Full track not loaded');
  const sourceId=useRef(0);
  const lastCameraFrame=useRef<ImageData|null>(null);
  const [autoLock,setAutoLock]=useState(true);
  const [tracking,setTracking]=useState('Searching for four alignment markers');
  const [mode,setMode]=useState<'send'|'receive'>('send');
  const [ready,setReady]=useState(false),[error,setError]=useState('');
  const [data,setData]=useState<Uint8Array|null>(null),[sending,setSending]=useState(false),[frame,setFrame]=useState(0);
  const [camera,setCamera]=useState(false),[starting,setStarting]=useState(false);
  const [stats,setStats]=useState({valid:0,rejected:0,index:-1,played:0,late:0,audio:'off',playing:false,captures:0,corrected:0,confidence:0,fused:false,concealed:0,bufferMs:500,rebuffers:0,total:0});
  const codec=useRef<LiveCodec|null>(null),player=useRef<LivePlayer|null>(null);
  const strip=useRef<HTMLCanvasElement|null>(null),video=useRef<HTMLVideoElement|null>(null);
  const preview=useRef<HTMLCanvasElement|null>(null),scope=useRef<HTMLCanvasElement|null>(null);
  const stream=useRef<MediaStream|null>(null),crop=useRef<Roi|null>(null),drag=useRef<{x:number;y:number}|null>(null);
  useEffect(()=>{
    const p=new LivePlayer();player.current=p;
    Promise.resolve().then(()=>{const url=new URL(window.location.href);setSettings(readSettings(url.search));setMode(url.searchParams.get('receive')==='1'?'receive':'send');setOrigin(url.origin);setParamsReady(true);});
    return()=>{stream.current?.getTracks().forEach(t=>t.stop());p.dispose();};
  },[]);
  useEffect(()=>{
    if(!paramsReady)return;
    let active=true,current:LiveCodec|null=null;
    const prepare=async()=>{
      setReady(false);setData(null);
      if(!plan.fits){setTrackStatus('Grid too small for selected bitrate');return;}
      try{
        const c=await LiveCodec.create(plan);current=c;
        if(!active){c.dispose();return;}
        codec.current=c;setReady(true);setError('');
        if(!sourceBuffer){setTrackStatus('Full track not loaded');return;}
        setTrackStatus('Encoding the full track…');await new Promise(r=>setTimeout(r,0));
        const pcm=monoPcm(sourceBuffer,plan.sampleRate),total=Math.ceil(pcm.length*plan.fps/plan.sampleRate);
        if(total>65535)throw new Error('Track too long for this frame rate');
        const packets=new Uint8Array(total*plan.packetBytes),id=(sourceId.current^plan.sampleRate^plan.fps)>>>0;
        for(let i=0;i<total;i++){
          if(!active)return;
          const start=Math.floor(i*plan.sampleRate/plan.fps),count=frameSamples(plan.sampleRate,plan.fps,i);
          const samples=new Int16Array(count);samples.set(pcm.subarray(start,start+count));
          packets.set(c.encodeAudio(samples,id,i,total),i*plan.packetBytes);
          if(i%32===0)await new Promise(r=>setTimeout(r,0));
        }
        if(active){setData(packets);setTrackStatus('Full track ready');}
      }catch(e){if(active){setError(String(e));setReady(false);setTrackStatus('Preparation failed');}}
    };
    void prepare();return()=>{active=false;current?.dispose();if(codec.current===current)codec.current=null;};
  },[plan,paramsReady,sourceBuffer]);
  const stop=()=>{stream.current?.getTracks().forEach(t=>t.stop());stream.current=null;player.current?.reset();codec.current?.resetFusion();setCamera(false);};
  const apply=(s:LinkSettings)=>{stop();setSending(false);setData(null);setReady(false);setSettings(s);};
  const receiverUrl=origin+'/optical?'+new URLSearchParams({kbps:String(settings.kbps),fps:String(settings.fps),cols:String(settings.cols),rows:String(settings.rows),receive:'1'}).toString();
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
      drawAlignment(ctx);
      const symbols=codec.current.encode(data.subarray(index*plan.packetBytes,(index+1)*plan.packetBytes));
      for(let r=0;r<plan.rows;r++)for(let c=0;c<plan.cols;c++){ctx.fillStyle=COLORS[symbols[r*plan.cols+c]];const x=Math.round(c*960/plan.cols),y=Math.round(r*288/plan.rows);ctx.fillRect(GRID_X*3+x,GRID_Y*3+y,Math.round((c+1)*960/plan.cols)-x,Math.round((r+1)*288/plan.rows)-y);}
      setFrame(index);index=(index+1)%(data.length/plan.packetBytes);
    };
    draw();if(!sending)return;
    const timer=window.setInterval(draw,1000/plan.fps);return()=>clearInterval(timer);
  },[mode,data,sending,ready,plan]);
  useEffect(()=>{
    if(mode!=='receive' || !camera)return;
    let raf=0,last=0,ui=0,valid=0,rejected=0,index=-1,total=0,lastVideoTime=-1;
    const tick=(now:number)=>{
      raf=requestAnimationFrame(tick);if(now-last<30)return;last=now;
      const v=video.current,canvas=preview.current,c=codec.current,p=player.current;
      if(!v || !canvas || !c || !p || !v.videoWidth || v.readyState<2)return;
      if(v.currentTime===lastVideoTime)return;lastVideoTime=v.currentTime;
      if(canvas.width!==v.videoWidth || canvas.height!==v.videoHeight){canvas.width=v.videoWidth;canvas.height=v.videoHeight;}
      const ctx=canvas.getContext('2d',{willReadFrequently:true});if(!ctx)return;
      ctx.drawImage(v,0,0);
      if(!crop.current)crop.current={x:canvas.width*.05,y:canvas.height*.25,w:canvas.width*.9,h:canvas.width*.9*.3};
      const roi=crop.current;
      try{
        const pixels=ctx.getImageData(0,0,canvas.width,canvas.height);
        lastCameraFrame.current=pixels;
        const packet=autoLock?c.autoDecode(pixels):drag.current?null:c.decode(pixels,roi);
        if(packet){const block=c.audio(packet);valid++;index=block.index;total=block.total;p.push(block);}else rejected++;
      }catch(e){setError(String(e));}
      ctx.strokeStyle='#00ff88';ctx.lineWidth=2;
      if(autoLock && c.corners.length===8) {
        ctx.beginPath();for(let i=0;i<4;i++){const x=c.corners[2*i],y=c.corners[2*i+1];if(i)ctx.lineTo(x,y);else ctx.moveTo(x,y);}ctx.closePath();ctx.stroke();
      } else if(!autoLock) ctx.strokeRect(roi.x,roi.y,roi.w,roi.h);
      const osc=scope.current,oscCtx=osc?.getContext('2d');
      if(osc && oscCtx){const wave=p.waveform();oscCtx.fillStyle='#08090d';oscCtx.fillRect(0,0,osc.width,osc.height);oscCtx.strokeStyle='#00ff88';oscCtx.beginPath();wave.forEach((n,i)=>{const x=i*osc.width/wave.length,y=n/255*osc.height;if(i)oscCtx.lineTo(x,y);else oscCtx.moveTo(x,y);});oscCtx.stroke();}
      if(now-ui>200){ui=now;setTracking(c.stage);setStats({valid,rejected,index,played:p.played,late:p.late,audio:p.state,playing:p.playing,captures:c.captures,corrected:c.corrected,confidence:c.confidence,fused:c.fused,concealed:p.concealed,bufferMs:Math.round(p.latencySeconds*1000),rebuffers:p.rebuffers,total});}
    };
    raf=requestAnimationFrame(tick);return()=>cancelAnimationFrame(raf);
  },[mode,camera,autoLock,plan]);
  const point=(e:React.PointerEvent<HTMLCanvasElement>)=>{const b=e.currentTarget.getBoundingClientRect(),c=e.currentTarget;return{x:Math.max(0,Math.min(c.width-1,(e.clientX-b.left)*c.width/b.width)),y:Math.max(0,Math.min(c.height-1,(e.clientY-b.top)*c.height/b.height))};};
  return <main style={{maxWidth:1100,margin:'0 auto',padding:20}}>
    <Link href="/" style={{color:'#00d8ff'}}>← Doom receiver</Link>
    <h1 style={{fontSize:28,fontWeight:800,marginTop:20}}>Live six-color audio</h1>
    <p>Each verified packet carries {(1000/settings.fps).toFixed(0)} milliseconds of audio. A short adaptive buffer smooths playback; no full-file wait.</p>
    <div style={{display:'flex',gap:12,flexWrap:'wrap',margin:'20px 0'}}>
      <button className="custom-btn" onClick={()=>{stop();setMode('send');}}>Send on Mac</button>
      <button className="custom-btn" onClick={()=>{setSending(false);setMode('receive');}}>Receive + play on iPhone</button>
      <span>{!plan.fits?'Grid capacity insufficient':ready?'✓ Rust live decoder ready':'Loading Rust decoder…'}</span>
    </div>
    <section className="glass-panel" style={{padding:16,marginBottom:20}}>
      <h2>Audio rate and dot grid</h2>
      <div style={{display:'flex',gap:16,flexWrap:'wrap',alignItems:'center'}}>
        <label>Audio kbps <select value={settings.kbps} onChange={e=>apply(autoFit(Number(e.target.value),settings.fps))} style={{background:'#111',color:'white',padding:8}}>{BITRATES.map(n=><option key={n} value={n}>{n} kbps</option>)}</select></label>
        <label>Frames / second <select value={settings.fps} onChange={e=>apply(autoFit(settings.kbps,Number(e.target.value)))} style={{background:'#111',color:'white',padding:8}}>{FRAME_RATES.map(n=><option key={n}>{n}</option>)}</select></label>
        <label>Columns <input type="number" min={32} max={256} value={settings.cols} onChange={e=>{const v=e.target.valueAsNumber;if(Number.isFinite(v))apply({...settings,cols:Math.max(32,Math.min(256,Math.round(v)))});}} style={{width:76,background:'#111',padding:8}}/></label>
        <label>Rows <input type="number" min={8} max={128} value={settings.rows} onChange={e=>{const v=e.target.valueAsNumber;if(Number.isFinite(v))apply({...settings,rows:Math.max(8,Math.min(128,Math.round(v)))});}} style={{width:76,background:'#111',padding:8}}/></label>
        <button className="custom-btn" onClick={()=>apply(autoFit(settings.kbps,settings.fps))}>Auto-fit grid</button>
        <button className="custom-btn" onClick={()=>apply(autoFit(128,settings.fps))}>Set 128 kbps</button>
        <button className="custom-btn" onClick={()=>apply(autoFit(1,settings.fps))}>Set 1 kbps 😈</button>
        <button className="custom-btn" onClick={()=>apply(autoFit(24,8))}>Larger cells: 24 kbps test</button>
      </div>
      <p>{plan.dots.toLocaleString()} colored cells / frame ({settings.cols} × {settings.rows}) · up to {plan.audioBytes.toLocaleString()} audio bytes / frame · {plan.lanes} RS lanes · {plan.capacityBytes.toLocaleString()} / {plan.envelopeBytes.toLocaleString()} encoded bytes available / required.</p>
      {settings.kbps<=4 && <p>Extreme low-rate mode: {plan.sampleRate} samples/second, with sound limited to roughly {plan.sampleRate/2} Hz. The bitrate describes audio payload; error correction and framing add overhead.</p>}
      <p style={{color:plan.fits?'#00ff88':'#ff8888'}}>{plan.fits?'✓ Grid has enough capacity':'Grid too small — Auto-fit or increase columns / rows'}</p>
      <p>128 kbps at 8 fps auto-fits about 8,700 cells. This is {plan.sampleRate.toLocaleString()} Hz mono ADPCM; the source is a 128 kbps MP3, a different codec. More dots mean smaller camera targets; higher frame rates leave fewer captures to combine.</p>
      <button className="custom-btn" onClick={async()=>{try{await navigator.clipboard.writeText(receiverUrl);setTrackStatus('Matching receiver link copied');}catch{setError('Copy the receiver link shown below.');}}}>Copy matching receiver link</button>
      <p>Use the same settings on both devices. After changing them, restart transmission and reception.</p>
      <p style={{overflowWrap:'anywhere',fontSize:12}}><a href={receiverUrl} style={{color:'#00d8ff'}}>Open receiver with these settings</a></p>
    </section>
    {error && <p role="alert" style={{color:'#ff8888'}}>{error}</p>}
    {mode==='send'?<section className="glass-panel" style={{padding:20}}>
      <h2>Transmit the full track: I’ll Follow the Sun</h2>
      <button className="custom-btn" disabled={!ready || !plan.fits || trackStatus.startsWith('Loading') || trackStatus.startsWith('Encoding')} onClick={async()=>{
        try{setSending(false);setTrackStatus('Loading the full track…');const r=await fetch('/samples/ill-follow-the-sun.mp3');if(!r.ok)throw new Error(`Track HTTP ${r.status}`);const bytes=await r.arrayBuffer();sourceId.current=crc32(new Uint8Array(bytes));const context=new OfflineAudioContext(1,1,44100);const decoded=await context.decodeAudioData(bytes.slice(0));setDuration(decoded.duration);setSourceBuffer(decoded);setError('');}catch(e){setError(String(e));setTrackStatus('Track loading failed');}
      }}>Load / encode full track</button>
      <p role="status">{trackStatus}</p>
      <details><summary>Listen to the original source directly (not the optical receiver)</summary><audio controls preload="none" src="/samples/ill-follow-the-sun.mp3" style={{width:'100%'}}/></details>
      {data && <>
        <p>The Beatles · full track · {duration.toFixed(2)} seconds · {data.length/plan.packetBytes} packets · {plan.fps} fps · {settings.kbps} kbps ADPCM.</p>
        <canvas ref={strip} width={FRAME_WIDTH*3} height={FRAME_HEIGHT*3} aria-label="Live six-color audio strip" style={{width:'100%',height:'auto',display:'block',imageRendering:'pixelated',margin:'20px 0'}}/>
        <button className="custom-btn active" onClick={()=>setSending(s=>!s)}>{sending?'Pause':'Start live transmission'}</button>
        <p>Packet {frame+1} / {data.length/plan.packetBytes} · {(frame/settings.fps).toFixed(1)}s / {duration.toFixed(1)}s · {sending?'Transmitting full track; repeats after the last frame':'Paused; start transmission for the phone to hear music'}</p>
      </>}
      <p>The Mac displays data silently. Open this same page on the iPhone, choose Receive + play, and point its camera at the entire white panel, including all four corner markers. Keep the display bright, level, and awake.</p>
    </section>:<section className="glass-panel" style={{padding:20}}>
      <h2>Scan → decode → play</h2>
      <p>Auto-lock finds the four corner symbols and corrects the camera angle. Keep the entire white sender panel in view. Hearing a test beep confirms your speaker; music requires valid optical packets.</p>
      <div style={{display:'flex',gap:12,flexWrap:'wrap',marginBottom:16}}>
        <button className="custom-btn active" disabled={!ready || !plan.fits || starting} onClick={camera?stop:start}>{starting?'Opening…':camera?'Stop reception':'Start camera + audio'}</button>
        <button className="custom-btn" onClick={()=>enable(true)}>Enable audio / test beep</button>
        <button className="custom-btn" disabled={!camera} onClick={()=>{
          const frame=lastCameraFrame.current;if(!frame)return;
          const canvas=document.createElement('canvas');canvas.width=frame.width;canvas.height=frame.height;const ctx=canvas.getContext('2d');if(!ctx)return;ctx.putImageData(frame,0,0);
          canvas.toBlob(blob=>{if(!blob)return;const url=URL.createObjectURL(blob),a=document.createElement('a');a.href=url;a.download=`optical-${settings.kbps}k-${settings.fps}fps-${settings.cols}x${settings.rows}.png`;a.click();setTimeout(()=>URL.revokeObjectURL(url),2000);},'image/png');
        }}>Save diagnostic camera frame</button>
        <button className="custom-btn" onClick={()=>{drag.current=null;setAutoLock(v=>!v);}}>{autoLock?"Auto-lock ON":"Manual crop mode"}</button>
      </div>
      <div style={{position:'relative',background:'black',minHeight:180}}>
        <video ref={video} autoPlay playsInline muted style={{width:'100%',display:'block'}}/>
        <canvas ref={preview} style={{position:'absolute',inset:0,width:'100%',height:'100%',touchAction:'none'}} onPointerDown={e=>{if(autoLock)return;e.currentTarget.setPointerCapture(e.pointerId);drag.current=point(e);}} onPointerMove={e=>{if(autoLock || !drag.current)return;const a=drag.current,b=point(e);crop.current={x:Math.min(a.x,b.x),y:Math.min(a.y,b.y),w:Math.max(1,Math.abs(a.x-b.x)),h:Math.max(1,Math.abs(a.y-b.y))};}} onPointerUp={()=>{drag.current=null;}} onPointerCancel={()=>{drag.current=null;}}/>
      </div>
      <p role="status" style={{color:stats.playing?'#00ff88':'#ffaa00'}}>{!camera?'Camera stopped':!stats.valid?'Scanning: waiting for a verified audio packet':stats.audio!=='running'?'Audio paused — tap Enable audio':stats.playing?'Playing incoming optical audio':'Waiting for the next audio packet'}</p>
      <p role="status">{tracking}</p>
      {!autoLock && <p>Manual fallback: drag tightly around only the colored data grid, excluding the white border and corner markers.</p>}
      <p>{stats.valid} checksum-valid scans · {stats.played} audio blocks scheduled · {stats.rejected} rejected scans · {stats.late} late blocks · audio: {stats.audio}</p>
      <p>Capture combining: {stats.captures} observations of this frame{stats.fused?' · combined recovery':''} · color confidence {stats.confidence}% · FEC repaired {stats.corrected} bytes this scan.</p>
      <p>Playback: target buffer {stats.bufferMs} ms · {stats.concealed} concealed blocks · {stats.rebuffers} rebuffer events.</p>
      {stats.index>=0 && <p>Received music position: {(stats.index/settings.fps).toFixed(1)}s / {(stats.total/settings.fps).toFixed(1)}s</p>}
      <canvas ref={scope} width={640} height={80} aria-label="Decoded audio waveform" style={{width:'100%',height:80,background:'#08090d'}}/>
      <p>iPhone: raise media volume and check Control Center’s speaker route. If needed, turn Silent Mode off and tap Enable audio again.</p>
    </section>}
    <p style={{color:'#8b98ac',marginTop:20}}>Experimental configurable grid: {settings.cols} columns × {settings.rows} rows. Confidence-weighted same-frame combining, repeated CRC-protected IDs, interleaved Reed–Solomon correction, and packet CRC. {plan.sampleRate.toLocaleString()} Hz mono ADPCM, {settings.kbps} kbps of audio data. An adaptive 500–1500 ms target buffer and faded repetition smooth brief losses. Four alignment finders and colored orientation dots provide automatic perspective alignment; manual crop is available as a fallback.</p>
    <Link href="/optical/file" style={{color:'#00d8ff'}}>Previous byte-perfect MP3 file-transfer experiment →</Link>
  </main>;
}
