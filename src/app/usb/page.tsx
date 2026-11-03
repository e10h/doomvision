"use client";

import Link from "next/link";
import { useEffect, useRef, useState } from "react";
import { UsbPcmDecoder } from "../../lib/usb-pcm.mjs";
import styles from "./usb.module.css";

type Device = {
  productName?: string; opened: boolean;
  configuration?: { interfaces: { interfaceNumber: number; alternates: { alternateSetting: number; interfaceClass: number; interfaceSubclass: number; interfaceProtocol: number }[] }[] };
  open(): Promise<void>; close(): Promise<void>; selectConfiguration(n: number): Promise<void>;
  claimInterface(n: number): Promise<void>; selectAlternateInterface(n: number, alternate: number): Promise<void>;
  controlTransferOut(setup:{requestType:"vendor";recipient:"device";request:number;value:number;index:number}):Promise<{status:string}>;
  transferIn(endpoint: number, length: number): Promise<{status: string; data?: DataView}>;
};
type Usb = { requestDevice(options: {filters: {vendorId: number; productId: number}[]}): Promise<Device> };
type Session = { active: boolean; device?: Device; context: AudioContext; node?: AudioWorkletNode; animation?: number; expectedRate?:number; warmUntil:number; playbackStarted:boolean };

export default function UsbReceiver() {
  const [status,setStatus]=useState("Ready to connect");
  const [connected,setConnected]=useState(false), [busy,setBusy]=useState(false);
  const [error,setError]=useState("");
  const [deviceName,setDeviceName]=useState("");
  const [quality,setQuality]=useState(4000),[qualityBusy,setQualityBusy]=useState(false);
  const [stats,setStats]=useState({chunks:0,rate:quality,mode:"Piano",queued:0,underruns:0,dropped:0,pps:0,missing:0});
  const canvas=useRef<HTMLCanvasElement>(null), session=useRef<Session|null>(null);
  function cleanup(s: Session) {
    s.active=false; if(s.animation)cancelAnimationFrame(s.animation);
    s.node?.disconnect(); void s.context.close().catch(()=>{});
    if(s.device?.opened)void s.device.close().catch(()=>{});
    if(session.current===s)session.current=null;
  }
  useEffect(()=>()=>{if(session.current)cleanup(session.current);},[]);
  function disconnect(){const s=session.current;if(s)cleanup(s);setConnected(false);setBusy(false);setStatus("Disconnected");}
  async function connect() {
    const usb=(navigator as Navigator & {usb?:Usb}).usb;
    if(!usb){setError("Open this page in Chrome or Edge on your Mac. USB access needs localhost or HTTPS.");return;}
    setError("");setDeviceName("");setBusy(true);setStatus("Select your calculator");
    setStats({chunks:0,rate:quality,mode:"Piano",queued:0,underruns:0,dropped:0,pps:0,missing:0});
    const context=new AudioContext();
    const s: Session={active:true,context,warmUntil:0,playbackStarted:false};session.current=s;
    // Both calls originate in the button gesture: audio unlock and USB picker.
    const resume=context.resume();
    try {
      const chosen=usb.requestDevice({filters:[{vendorId:0x0451,productId:0xe008}]});
      await resume;
      const device=await chosen;s.device=device;setDeviceName(device.productName??"Calculator");
      if(!s.active){cleanup(s);return;}
      if(/^TI-Boy CE PCM[12345]$/.test(device.productName??""))throw Error(`The calculator is still running ${device.productName}. Transfer TIBUSB6 and TBUSB006, exit the old program, then run TIBUSB6 and reconnect its cable.`);
      if(!/^(Doomvision PCM[56]|TI-Boy CE PCM6)$/.test(device.productName??""))throw Error("Run DVUSB6 or TIBUSB6, reconnect the cable, then select its PCM audio device.");
      setStatus("Opening calculator…");
      await device.open();
      if(!device.configuration)await device.selectConfiguration(1);
      const iface=device.configuration?.interfaces.find(i=>i.alternates.some(a=>a.interfaceClass===255&&a.interfaceSubclass===0x44&&a.interfaceProtocol===1));
      if(!iface)throw Error("No Doomvision audio interface. Run DVUSB6 and reconnect the cable.");
      const alternate=iface.alternates.find(a=>a.interfaceClass===255&&a.interfaceSubclass===0x44&&a.interfaceProtocol===1)!;
      try { await device.claimInterface(iface.interfaceNumber); }
      catch { throw Error("Calculator USB is busy. Quit TI Connect CE with ⌘Q, close other USB receiver tabs, then unplug and reconnect the cable while the game stays running."); }
      await device.selectAlternateInterface(iface.interfaceNumber,alternate.alternateSetting);
      if(device.productName==='TI-Boy CE PCM6'){await requestQuality(device,quality);s.expectedRate=quality;}
      await context.audioWorklet.addModule('/usb-audio-worklet.js');
      if(!s.active){cleanup(s);return;}
      const node=new AudioWorkletNode(context,'usb-audio',{numberOfInputs:0,numberOfOutputs:1,outputChannelCount:[1]});s.node=node;
      const analyser=context.createAnalyser();analyser.fftSize=2048;node.connect(analyser);analyser.connect(context.destination);
      node.port.onmessage=({data})=>{if(s.active){setStats(prev=>({...prev,...data}));if(s.playbackStarted)setStatus(data.playing?"Streaming audio":"Buffering audio");}};
      const wave=new Float32Array(analyser.fftSize);
      function draw(){if(!s.active)return;const el=canvas.current,ctx=el?.getContext('2d');if(el&&ctx){const ratio=window.devicePixelRatio||1,w=el.clientWidth,h=el.clientHeight;if(el.width!==w*ratio||el.height!==h*ratio){el.width=w*ratio;el.height=h*ratio;}ctx.setTransform(ratio,0,0,ratio,0,0);ctx.clearRect(0,0,w,h);ctx.strokeStyle='#253c3b';ctx.beginPath();ctx.moveTo(0,h/2);ctx.lineTo(w,h/2);ctx.stroke();analyser.getFloatTimeDomainData(wave);ctx.strokeStyle='#83f6be';ctx.lineWidth=1.5;ctx.beginPath();wave.forEach((v,i)=>{const x=i*w/(wave.length-1),y=h/2-v*h*.43;if(i)ctx.lineTo(x,y);else ctx.moveTo(x,y);});ctx.stroke();}s.animation=requestAnimationFrame(draw);}
      draw();s.warmUntil=performance.now()+(s.expectedRate?500:0);setBusy(false);setConnected(true);setStatus(s.expectedRate?"Synchronizing audio":"Connected · waiting for audio");
      const decoder=new UsbPcmDecoder();let last:number|undefined,chunks=0,report=0,rateStart=performance.now(),rateChunks=0,pps=0,missing=0;
      while(s.active){
        const result=await device.transferIn(1,272);
        if(!s.active)break;
        if(result.status!=="ok")throw Error(`USB transfer ${result.status}. Reconnect the calculator and try again.`);
        if(!result.data)continue;
        for(const packet of decoder.feed(new Uint8Array(result.data.buffer,result.data.byteOffset,result.data.byteLength))){
          if(last===packet.sequence)continue;
          if(performance.now()<s.warmUntil||(s.expectedRate!==undefined&&packet.rate!==s.expectedRate)){last=packet.sequence;continue;}
          if(!s.playbackStarted){s.playbackStarted=true;last=undefined;missing=0;chunks=0;rateChunks=0;rateStart=performance.now();setStatus("Buffering audio");}
          if(last!==undefined){const gap=(packet.sequence-last-1)>>>0;if(gap<100000)missing+=gap;}last=packet.sequence;
          node.port.postMessage({pcm:packet.pcm,rate:packet.rate,flags:packet.flags},[packet.pcm.buffer]);chunks++;
          const elapsed=performance.now()-rateStart;if(elapsed>=1000){pps=Math.round((chunks-rateChunks)*1000/elapsed);rateStart=performance.now();rateChunks=chunks;}
          if(performance.now()-report>250||chunks===1){setStats(prev=>({...prev,chunks,pps,missing,rate:packet.rate,mode:packet.flags&4?"Game Boy":packet.flags&1?"Piano":packet.flags&2?"Paused":"Rick clip"}));report=performance.now();}
        }
      }
    } catch(e) {
      if(s.active){const message=e instanceof Error?e.message:String(e);setError(e instanceof DOMException&&e.name==='NotFoundError'?"No device selected. Click Connect calculator to try again.":message);setStatus("Not connected");setConnected(false);setBusy(false);}
    } finally {cleanup(s);}
  }
  async function requestQuality(device:Device,rate:number){
    const result=await device.controlTransferOut({requestType:"vendor",recipient:"device",request:0x51,value:rate,index:0});
    if(result.status!=="ok")throw Error("The calculator could not change audio quality.");
  }
  async function changeQuality(rate:number){
    if(rate!==4000){setError("This firmware currently supports the verified Fast 4 kHz setting.");return;}
    const previous=quality;setQuality(rate);const s=session.current;
    if(!s?.active||s.device?.productName!=="TI-Boy CE PCM6"){setStats(prev=>({...prev,rate,chunks:0,pps:0}));return;}
    setQualityBusy(true);setError("");s.expectedRate=rate;s.warmUntil=performance.now()+500;s.playbackStarted=false;
    s.node?.port.postMessage({reset:true});setStatus("Changing audio quality…");
    try{await requestQuality(s.device,rate);}catch(e){s.expectedRate=previous;s.warmUntil=0;setQuality(previous);setError(e instanceof Error?e.message:String(e));}
    finally{setQualityBusy(false);}
  }
  return <main className={styles.page}>
    <header className={styles.header}><Link href="/">doomvision</Link><span>USB AUDIO</span></header>
    <section className={styles.intro}><div className={styles.eyebrow}>CALCULATOR → SPEAKERS</div><h1>Hear your calculator.</h1><p>Run DVUSB6 or TI-Boy USB on your TI-84 Plus CE, plug it into your Mac, and connect.</p></section>
    <section className={styles.panel}>
      <div className={styles.toolbar}><span role="status"><i className={connected?styles.live:styles.dot}/>{status}</span><button onClick={connected?disconnect:connect} disabled={busy}>{busy?"Connecting…":connected?"Disconnect":"Connect calculator"}</button></div>
      {(!connected||deviceName.startsWith("TI-Boy"))&&<label className={styles.quality}>Game Boy audio quality <select aria-label="Game Boy audio quality" value={quality} disabled={busy||qualityBusy} onChange={e=>void changeQuality(Number(e.target.value))}><option value={4000}>Fast · 4 kHz</option><option value={8000} disabled>Balanced · 8 kHz (not yet verified)</option><option value={16000} disabled>High · 16 kHz (not yet verified)</option></select><small>Lower rates leave more CPU time for gameplay.</small></label>}
      <canvas ref={canvas} className={styles.wave} aria-label="Live waveform of the calculator audio playing through your speakers"/>
      <div className={styles.stats}>{deviceName&&<span>{deviceName}</span>}<span>{connected?stats.mode:"Live waveform"}</span><span>{stats.rate/1000} kHz · mono</span><span>{stats.chunks.toLocaleString()} chunks · {stats.pps}/s · target {Math.round(stats.rate/128)}/s</span><span>{stats.queued} ms buffered</span></div>
    </section>
    {error&&<p role="alert" className={styles.error}>{error}</p>}
    <p className={styles.hint}>Choose <strong>Doomvision PCM6</strong> or <strong>TI-Boy CE PCM6</strong> in the device picker. Use Chrome or Edge on Mac.<br/>Close TI Connect CE and the native receiver first. DVUSB6: Y= switches piano / clip. TI-Boy: use the game’s controls.</p>
    {(connected||stats.chunks>0)&&<p className={styles.health}>{stats.underruns} audio underruns · {stats.dropped} dropped samples · {stats.missing} missing USB chunks</p>}
    <a className={styles.download} href="/downloads/DVUSB6.8xp">Download DVUSB6 ↗</a>{" · "}
    <a className={styles.download} href="/downloads/TBAUD6.8xg">Download TI-Boy USB prototype ↗</a>
  </main>;
}
