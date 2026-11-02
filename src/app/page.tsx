"use client";

import { useEffect, useRef, useState, useCallback } from "react";
import { WasmOpticalDecoder, DecodeResult, DetectedRoi } from "../lib/wasm";
import { WebAudioEngine, SFX_NAMES, SFX_ICONS } from "../lib/audio";

interface EventLogItem {
  id: number;
  time: string;
  sfxId: number;
  name: string;
  icon: string;
  pan: number;
  vol: number;
}

export default function OpticalReceiverPage() {
  const videoRef = useRef<HTMLVideoElement | null>(null);
  const canvasRef = useRef<HTMLCanvasElement | null>(null);
  const visualizerCanvasRef = useRef<HTMLCanvasElement | null>(null);

  const [starting, setStarting] = useState(false);
  const [audioLoading, setAudioLoading] = useState(false);
  const [error, setError] = useState("");
  const lastValidFrame = useRef(0);
  const [decoderReady, setDecoderReady] = useState(false);
  const [audioRunning, setAudioRunning] = useState(false);
  const [audioReady, setAudioReady] = useState(false);
  const [cameraActive, setCameraActive] = useState(false);
  const [devices, setDevices] = useState<MediaDeviceInfo[]>([]);
  const [selectedDeviceId, setSelectedDeviceId] = useState<string>("");

  const [isLocked, setIsLocked] = useState(false);
  const [aiAutoLockEnabled, setAiAutoLockEnabled] = useState(true);
  const [telemetry, setTelemetry] = useState<DecodeResult | null>(null);
  const [events, setEvents] = useState<EventLogItem[]>([]);
  const [volume, setVolume] = useState(0.85);

  // Region of Interest (ROI)
  const lastDetectedRoiRef = useRef<DetectedRoi | null>(null);
  const manualRoiRef = useRef({ x: 100, y: 80, w: 440, h: 20 });
  const isDraggingRef = useRef(false);
  const dragStartRef = useRef<{ x: number; y: number } | null>(null);

  const wasmDecoderRef = useRef<WasmOpticalDecoder | null>(null);
  const audioEngineRef = useRef<WebAudioEngine | null>(null);
  const animationFrameRef = useRef<number | null>(null);

  // Scanline animation timer
  const scanLinePosRef = useRef(0);

  // Initialize Rust WASM decoder and Web Audio engine
  useEffect(() => {
    const initWasmAndAudio = async () => {
      const decoder = new WasmOpticalDecoder();
      const decOk = await decoder.init();
      if (!decOk) setError("Rust decoder failed to load. Rebuild WASM and reload.");
      if (decOk) {
        wasmDecoderRef.current = decoder;
        setDecoderReady(true);
      }

      const audio = new WebAudioEngine();
      audioEngineRef.current = audio;

      if (navigator.mediaDevices && navigator.mediaDevices.enumerateDevices) {
        try {
          const allDevs = await navigator.mediaDevices.enumerateDevices();
          const videoDevs = allDevs.filter((d) => d.kind === "videoinput");
          setDevices(videoDevs);

        } catch (e) {
          console.warn("Could not enumerate camera devices:", e);
        }
      }
    };

    initWasmAndAudio();

    return () => {
      if (animationFrameRef.current) {
        cancelAnimationFrame(animationFrameRef.current);
      }
    };
  }, []);

  // Call getUserMedia directly from the tap; audio downloads must not block it.
  const startCamera = async (deviceId?: string) => {
    setError("");
    if (!window.isSecureContext) {
      setError("Camera needs HTTPS on iPhone. Open the HTTPS website, not a local network HTTP address.");
      return;
    }
    if (!navigator.mediaDevices?.getUserMedia) {
      setError("Camera access is unavailable here. Open this page directly in Safari and allow camera access.");
      return;
    }
    setStarting(true);
    const video = videoRef.current;
    if (!video) { setStarting(false); return; }
    const oldStream = video.srcObject as MediaStream | null;
    oldStream?.getTracks().forEach(track => track.stop());
    video.srcObject = null;
    setCameraActive(false);
    video.muted = true;
    video.playsInline = true;
    video.autoplay = true;

    // Start both permission request and audio unlock in the user gesture.
    const cameraRequest = navigator.mediaDevices.getUserMedia({
      audio: false,
      video: {
        ...(deviceId ? { deviceId: { exact: deviceId } } : { facingMode: { ideal: "environment" } }),
        width: { ideal: 1280 }, height: { ideal: 720 }, frameRate: { ideal: 30 },
      },
    });
    const audio = audioEngineRef.current;
    if (audio && !audioLoading) {
      setAudioLoading(true);
      const loading = audioReady ? audio.resumeContext().then(() => true) : audio.init();
      void loading.then(ok => {
        setAudioReady(ok);
        setAudioRunning(audio.running);
        audio.setVolume(volume);
        if (!ok) setError("Camera is ready, but sound loading failed. Tap Enable / test audio to retry.");
      }).catch(() => setError("Tap Enable / test audio to unlock sound."))
        .finally(() => setAudioLoading(false));
    }
    let stream: MediaStream | null = null;
    try {
      stream = await cameraRequest;
      video.srcObject = stream;
      await video.play();
      setCameraActive(true);
      const activeId = stream.getVideoTracks()[0]?.getSettings().deviceId;
      if (activeId) setSelectedDeviceId(activeId);
      void navigator.mediaDevices.enumerateDevices().then(all => {
        setDevices(all.filter(d => d.kind === "videoinput"));
      }).catch(() => {});
    } catch (err) {
      stream?.getTracks().forEach(track => track.stop());
      video.srcObject = null;
      const name = err instanceof Error ? err.name : "";
      setError(name === "NotAllowedError"
        ? "Camera permission was blocked. In Safari, open Website Settings → Camera → Allow, then tap Start Camera again. If opened inside another app, open this URL in Safari."
        : name === "NotFoundError" || name === "OverconstrainedError"
          ? "This camera is unavailable. Select Rear camera (automatic) and retry."
          : `Camera could not start: ${err instanceof Error ? err.message : String(err)}`);
    } finally {
      setStarting(false);
    }
  };

  const stopCamera = () => {
    if (videoRef.current && videoRef.current.srcObject) {
      const stream = videoRef.current.srcObject as MediaStream;
      stream.getTracks().forEach((t) => t.stop());
      videoRef.current.srcObject = null;
    }
    audioEngineRef.current?.reset();
    lastDetectedRoiRef.current = null;
    setTelemetry(null);
    setCameraActive(false);
    setIsLocked(false);
  };

  // Main real-time AI computer vision & audio loop
  const processFrame = useCallback(function processFrame() {
    if (!videoRef.current || !canvasRef.current || !wasmDecoderRef.current) {
      animationFrameRef.current = requestAnimationFrame(processFrame);
      return;
    }

    const video = videoRef.current;
    const canvas = canvasRef.current;
    const ctx = canvas.getContext("2d", { willReadFrequently: true });

    if (video.readyState >= HTMLMediaElement.HAVE_CURRENT_DATA && ctx) {
      if (canvas.width !== video.videoWidth || canvas.height !== video.videoHeight) {
        canvas.width = video.videoWidth || 640;
        canvas.height = video.videoHeight || 480;
        manualRoiRef.current = {
          x: Math.floor(canvas.width * 0.15),
          y: Math.floor(canvas.height * 0.12),
          w: Math.floor(canvas.width * 0.7),
          h: 18,
        };
      }

      // 1. Draw camera video to canvas
      ctx.drawImage(video, 0, 0, canvas.width, canvas.height);

      // 2. Fetch raw RGBA image data
      const imgData = ctx.getImageData(0, 0, canvas.width, canvas.height);

      let decodeResult: DecodeResult | null = null;
      let activeRoi = manualRoiRef.current;

      // 3. AI AUTO-LOCK SCREEN & BARCODE ENGINE (Rust WASM)
      if (aiAutoLockEnabled) {
        const aiOutput = wasmDecoderRef.current.aiAutoLock(
          imgData.data,
          canvas.width,
          canvas.height,
          lastDetectedRoiRef.current
        );

        if (aiOutput) {
          decodeResult = aiOutput.result;
          lastDetectedRoiRef.current = aiOutput.roi;
          activeRoi = {
            x: aiOutput.roi.barX,
            y: aiOutput.roi.barY,
            w: aiOutput.roi.barW,
            h: aiOutput.roi.barH,
          };
        }
      } else {
        // Manual mode
        decodeResult = wasmDecoderRef.current.decodeManualRoi(
          imgData.data,
          canvas.width,
          canvas.height,
          manualRoiRef.current
        );
      }

      setAudioRunning(Boolean(audioEngineRef.current?.running));
      const lockedNow = Boolean(decodeResult && decodeResult.validL0);
      setIsLocked(lockedNow);

      if (!lockedNow && performance.now() - lastValidFrame.current > 750) {
        audioEngineRef.current?.reset();
      }
      if (decodeResult && lockedNow) {
        lastValidFrame.current = performance.now();
        setTelemetry(decodeResult);

        // 4. Play audio in real time via Web Audio API
        if (audioEngineRef.current) {
          const triggeredSfx = audioEngineRef.current.processOpticalEvents(
            decodeResult.sfxMask,
            decodeResult.status,
            decodeResult.pan,
            decodeResult.volume,
            decodeResult.pitch
          );

          if (triggeredSfx.length > 0) {
            const nowStr = new Date().toLocaleTimeString();
            setEvents((prev) => [
              ...triggeredSfx.map((sfxId) => ({
                id: Date.now() + Math.random(),
                time: nowStr,
                sfxId,
                name: SFX_NAMES[sfxId] || "UNKNOWN",
                icon: SFX_ICONS[sfxId] || "🔊",
                pan: Math.round(((decodeResult!.pan - 7) / 7) * 100),
                vol: Math.round((decodeResult!.volume / 15) * 100),
              })),
              ...prev.slice(0, 24),
            ]);
          }
        }
      }

      // 5. Draw Cyberpunk AI HUD & Reticle
      ctx.save();

      // If AI detected or guiding the LCD screen bounding box:
      if (lastDetectedRoiRef.current && aiAutoLockEnabled) {
        const s = lastDetectedRoiRef.current;
        if (s.locked) {
          // Locked Screen Rectangle (Prominent Neon Cyan)
          ctx.strokeStyle = "rgba(0, 229, 255, 0.9)";
          ctx.lineWidth = 2;
          ctx.strokeRect(s.screenX, s.screenY, s.screenW, s.screenH);
          ctx.fillStyle = "rgba(0, 229, 255, 0.06)";
          ctx.fillRect(s.screenX, s.screenY, s.screenW, s.screenH);

          // Screen corner accents
          const scLen = 16;
          ctx.lineWidth = 3;
          ctx.strokeStyle = "#00e5ff";
          // TL
          ctx.beginPath(); ctx.moveTo(s.screenX, s.screenY + scLen); ctx.lineTo(s.screenX, s.screenY); ctx.lineTo(s.screenX + scLen, s.screenY); ctx.stroke();
          // TR
          ctx.beginPath(); ctx.moveTo(s.screenX + s.screenW - scLen, s.screenY); ctx.lineTo(s.screenX + s.screenW, s.screenY); ctx.lineTo(s.screenX + s.screenW, s.screenY + scLen); ctx.stroke();
          // BL
          ctx.beginPath(); ctx.moveTo(s.screenX, s.screenY + s.screenH - scLen); ctx.lineTo(s.screenX, s.screenY + s.screenH); ctx.lineTo(s.screenX + scLen, s.screenY + s.screenH); ctx.stroke();
          // BR
          ctx.beginPath(); ctx.moveTo(s.screenX + s.screenW - scLen, s.screenY + s.screenH); ctx.lineTo(s.screenX + s.screenW, s.screenY + s.screenH); ctx.lineTo(s.screenX + s.screenW, s.screenY + s.screenH - scLen); ctx.stroke();

          ctx.fillStyle = "#00e5ff";
          ctx.font = "bold 11px monospace";
          ctx.fillText("🖥️ BARCODE LOCKED / SCREEN ESTIMATE", s.screenX + 6, s.screenY > 20 ? s.screenY - 6 : s.screenY + 16);
        } else {
          // Guide rectangle when searching
          ctx.strokeStyle = "rgba(0, 229, 255, 0.3)";
          ctx.lineWidth = 1.5;
          ctx.setLineDash([6, 6]);
          ctx.strokeRect(s.screenX, s.screenY, s.screenW, s.screenH);
          ctx.setLineDash([]);
          ctx.fillStyle = "rgba(0, 229, 255, 0.6)";
          ctx.font = "11px monospace";
          ctx.fillText("ALIGN CALCULATOR SCREEN HERE (OR TAP TO SNAP)", s.screenX + 6, s.screenY > 20 ? s.screenY - 6 : s.screenY + 16);
        }
      }

      // Draw Optical Barcode Tracking Reticle (Top Scanlines)
      const rx = activeRoi.x;
      const ry = activeRoi.y;
      const rw = activeRoi.w;
      const rh = activeRoi.h;

      if (lockedNow) {
        // High-Tech Lock-on Reticle (Green)
        ctx.strokeStyle = "#00ff88";
        ctx.lineWidth = 2;
        ctx.fillStyle = "rgba(0, 255, 136, 0.22)";
        ctx.strokeRect(rx, ry, rw, rh);
        ctx.fillRect(rx, ry, rw, rh);

        // Corner brackets ┌ ┐ └ ┘
        const bLen = 10;
        ctx.lineWidth = 3;
        // TL
        ctx.beginPath(); ctx.moveTo(rx, ry + bLen); ctx.lineTo(rx, ry); ctx.lineTo(rx + bLen, ry); ctx.stroke();
        // TR
        ctx.beginPath(); ctx.moveTo(rx + rw - bLen, ry); ctx.lineTo(rx + rw, ry); ctx.lineTo(rx + rw, ry + bLen); ctx.stroke();
        // BL
        ctx.beginPath(); ctx.moveTo(rx, ry + rh - bLen); ctx.lineTo(rx, ry + rh); ctx.lineTo(rx + bLen, ry + rh); ctx.stroke();
        // BR
        ctx.beginPath(); ctx.moveTo(rx + rw - bLen, ry + rh); ctx.lineTo(rx + rw, ry + rh); ctx.lineTo(rx + rw, ry + rh - bLen); ctx.stroke();

        ctx.fillStyle = "#00ff88";
        ctx.font = "bold 12px monospace";
        ctx.fillText(`📡 OPTICAL AUDIO (TOP SCANLINES) - ${telemetry?.confidence ?? 100}%`, rx + 4, ry > 20 ? ry - 8 : ry + rh + 16);
      } else {
        // Searching / Scanning mode: Animated laser scanning line
        ctx.strokeStyle = "#ffaa00";
        ctx.lineWidth = 1.5;
        ctx.fillStyle = "rgba(255, 170, 0, 0.12)";
        ctx.strokeRect(rx, ry, rw, rh);
        ctx.fillRect(rx, ry, rw, rh);

        // Animated laser line
        scanLinePosRef.current = (scanLinePosRef.current + 3) % canvas.height;
        ctx.strokeStyle = "rgba(0, 216, 255, 0.35)";
        ctx.beginPath();
        ctx.moveTo(0, scanLinePosRef.current);
        ctx.lineTo(canvas.width, scanLinePosRef.current);
        ctx.stroke();

        ctx.fillStyle = "#ffaa00";
        ctx.font = "12px monospace";
        ctx.fillText("AI SCANNING TOP SCANLINES FOR OPTICAL BARCODE...", rx + 4, ry > 20 ? ry - 8 : ry + rh + 16);
      }

      ctx.restore();
    }

    // 6. Draw Audio Visualizer Oscilloscope
    if (audioEngineRef.current && audioEngineRef.current.analyser && visualizerCanvasRef.current) {
      const vCanvas = visualizerCanvasRef.current;
      const vCtx = vCanvas.getContext("2d");
      if (vCtx) {
        const bufferLength = audioEngineRef.current.analyser.frequencyBinCount;
        const dataArray = new Uint8Array(bufferLength);
        audioEngineRef.current.analyser.getByteTimeDomainData(dataArray);

        vCtx.fillStyle = "rgba(10, 11, 16, 0.4)";
        vCtx.fillRect(0, 0, vCanvas.width, vCanvas.height);

        vCtx.lineWidth = 2;
        vCtx.strokeStyle = isLocked ? "#00ff88" : "#00d8ff";
        vCtx.beginPath();

        const sliceWidth = (vCanvas.width * 1.0) / bufferLength;
        let vx = 0;

        for (let i = 0; i < bufferLength; i++) {
          const v = dataArray[i] / 128.0;
          const vy = (v * vCanvas.height) / 2;
          if (i === 0) vCtx.moveTo(vx, vy);
          else vCtx.lineTo(vx, vy);
          vx += sliceWidth;
        }

        vCtx.lineTo(vCanvas.width, vCanvas.height / 2);
        vCtx.stroke();
      }
    }

    animationFrameRef.current = requestAnimationFrame(processFrame);
  }, [isLocked, aiAutoLockEnabled, telemetry]);

  useEffect(() => {
    if (cameraActive) {
      animationFrameRef.current = requestAnimationFrame(processFrame);
    }
    return () => {
      if (animationFrameRef.current) {
        cancelAnimationFrame(animationFrameRef.current);
      }
    };
  }, [cameraActive, processFrame]);

  // Mouse handlers for manual ROI adjustment & tap-to-snap screen
  const handleMouseDown = (e: React.PointerEvent<HTMLCanvasElement>) => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const rect = canvas.getBoundingClientRect();
    const scaleX = canvas.width / rect.width;
    const scaleY = canvas.height / rect.height;
    const mouseX = (e.clientX - rect.left) * scaleX;
    const mouseY = (e.clientY - rect.top) * scaleY;

    if (aiAutoLockEnabled) {
      // Tap to snap candidate screen box around clicked location
      const sw = Math.floor(canvas.width * 0.65);
      const sh = Math.floor(sw * 0.75);
      const sx = Math.max(0, Math.floor(mouseX - sw / 2));
      const sy = Math.max(0, Math.floor(mouseY));
      lastDetectedRoiRef.current = {
        barX: sx,
        barY: sy,
        barW: sw,
        barH: Math.max(8, sh * 0.04),
        screenX: sx,
        screenY: sy,
        screenW: sw,
        screenH: sh,
        locked: true,
      };
      return;
    }

    isDraggingRef.current = true;
    dragStartRef.current = { x: mouseX, y: mouseY };
    manualRoiRef.current = { x: mouseX, y: mouseY, w: 20, h: 10 };
  };

  const handleMouseMove = (e: React.PointerEvent<HTMLCanvasElement>) => {
    if (aiAutoLockEnabled || !isDraggingRef.current || !dragStartRef.current || !canvasRef.current) return;
    const canvas = canvasRef.current;
    const rect = canvas.getBoundingClientRect();
    const scaleX = canvas.width / rect.width;
    const scaleY = canvas.height / rect.height;
    const mouseX = (e.clientX - rect.left) * scaleX;
    const mouseY = (e.clientY - rect.top) * scaleY;

    const x = Math.min(dragStartRef.current.x, mouseX);
    const y = Math.min(dragStartRef.current.y, mouseY);
    const w = Math.max(40, Math.abs(mouseX - dragStartRef.current.x));
    const h = Math.max(4, Math.abs(mouseY - dragStartRef.current.y));

    manualRoiRef.current = { x, y, w, h };
  };

  const handleMouseUp = () => {
    isDraggingRef.current = false;
  };

  return (
    <div style={{ maxWidth: 1400, margin: "0 auto", padding: "24px 20px" }}>
      {/* Header */}
      <header className="receiver-header" style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 24 }}>
        <div>
          <h1 style={{ fontSize: "1.75rem", fontWeight: 800, letterSpacing: "-0.02em", color: "#ffffff", margin: 0 }}>
            ⚡ DOOM84 <span style={{ color: "#00d8ff" }}>AI OPTICAL AUDIO RECEIVER</span>
          </h1>
          <p style={{ margin: "4px 0 0", color: "#7f8a9a", fontSize: "0.85rem" }}>
            Computer Vision Screen Lock-on Engine // Rust WebAssembly Demodulator
          </p>
        </div>

        <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
          {/* Auto-Lock Toggle */}
          <button
            className={`custom-btn ${aiAutoLockEnabled ? "active" : ""}`}
            onClick={() => setAiAutoLockEnabled(!aiAutoLockEnabled)}
            style={{ fontSize: "0.8rem", padding: "6px 14px" }}
          >
            {aiAutoLockEnabled ? "🤖 Auto-Lock: ON" : "✋ Manual ROI Mode"}
          </button>

          <div className={`status-pill ${isLocked ? "status-locked" : cameraActive ? "status-searching" : "status-idle"}`}>
            <span className={`status-dot ${isLocked ? "active" : cameraActive ? "searching" : ""}`} />
            {isLocked ? "TARGET ACQUIRED & LOCKED" : cameraActive ? "AI SEARCHING SCREEN..." : "CAMERA OFF"}
          </div>
        </div>
      </header>

      <section className="glass-panel" aria-live="polite" style={{ padding: 16, marginBottom: 20 }}>
        <div>{decoderReady ? "✓ Rust decoder ready" : "Loading Rust decoder…"} · {audioReady ? "✓ Audio loaded" : "Audio waiting for Start Camera"}</div>
        <div style={{ marginTop: 8 }}>
          {cameraActive ? "✓ Camera frames → " : "1. Start camera → "}
          {isLocked ? "✓ Screen top found → ✓ Scanning → ✓ Packet checksum OK → " : "Find screen top → Scanning for barcode → Waiting for valid packet → "}
          {isLocked && audioReady && audioRunning ? ((telemetry?.status ?? 0) & 2 ? "✓ Playing music" : "✓ Audio ready; music flag off") : "Playback waiting"}
        </div>
        <p style={{ marginBottom: 0, color: "#8b98ac" }}>Keep the screen level and fill the camera view. The two pixel rows at the very top must be sharp and visible. Manual mode: drag tightly around both barcode rows.</p>
        {error && <p role="alert" style={{ color: "#ff7777" }}>{error}</p>}
        <button className="custom-btn" disabled={audioLoading || !decoderReady} onClick={async () => {
          const audio = audioEngineRef.current;
          if (!audio) return;
          setAudioLoading(true);
          try {
            const ok = audioReady ? (await audio.resumeContext(), true) : await audio.init();
            setAudioReady(ok); setAudioRunning(audio.running);
            if (!ok) throw new Error("Sound files could not load. Tap to retry.");
            audio.setVolume(volume); audio.playSfx(1, 7, 15, 7);
          } catch (e) { setError(e instanceof Error ? e.message : String(e)); }
          finally { setAudioLoading(false); }
        }}>{audioLoading ? "Loading audio…" : "Enable / test audio"}</button>
      </section>

      {/* Main Grid: Camera View + Audio & Telemetry */}
      <div className="receiver-grid" style={{ display: "grid", gridTemplateColumns: "1.4fr 1fr", gap: 24 }}>
        {/* Left Column: Camera Feed & Tracking HUD */}
        <section className="glass-panel" style={{ overflow: "hidden" }}>
          <div className="glass-panel-header">
            <span style={{ fontWeight: 700, fontSize: "0.9rem", display: "flex", alignItems: "center", gap: 8 }}>
              📷 Live Camera Vision // AI Target Tracking
            </span>

            <div style={{ display: "flex", gap: 8 }}>
              <select
                value={selectedDeviceId}
                onChange={(e) => {
                  setSelectedDeviceId(e.target.value);
                  if (cameraActive) startCamera(e.target.value);
                }}
                style={{
                  background: "rgba(0,0,0,0.5)",
                  color: "#fff",
                  border: "1px solid rgba(255,255,255,0.15)",
                  borderRadius: 6,
                  padding: "4px 8px",
                  fontSize: "0.8rem",
                }}
              >
                <option value="">Rear camera (automatic)</option>
                {devices.map((d, idx) => (
                  <option key={d.deviceId || idx} value={d.deviceId}>
                    {d.label || `Camera ${idx + 1}`}
                  </option>
                ))}
              </select>

              {!cameraActive ? (
                <button className="custom-btn active" disabled={starting || !decoderReady} onClick={() => startCamera(selectedDeviceId)}>
                  {starting ? "Opening camera…" : "▶ Start Camera"}
                </button>
              ) : (
                <button className="custom-btn danger" onClick={stopCamera}>
                  ⏹ Stop
                </button>
              )}
            </div>
          </div>

          <div style={{ position: "relative", background: "#000", minHeight: 420, display: "flex", alignItems: "center", justifyContent: "center" }}>
            <video ref={videoRef} autoPlay playsInline muted aria-label="Camera preview" style={{ position: "absolute", inset: 0, width: "100%", height: "100%", objectFit: "contain" }} />

            <canvas
              ref={canvasRef}
              onPointerDown={(e) => { e.currentTarget.setPointerCapture(e.pointerId); handleMouseDown(e); }}
              onPointerMove={handleMouseMove}
              onPointerUp={handleMouseUp}
              onPointerCancel={handleMouseUp}
              style={{
                width: "100%",
                height: "auto",
                display: "block",
                position: "relative",
                touchAction: "none",
                cursor: aiAutoLockEnabled ? "default" : "crosshair",
              }}
            />

            {!cameraActive && (
              <div style={{ position: "absolute", textAlign: "center", color: "#6a778c" }}>
                <div style={{ fontSize: "2.8rem", marginBottom: 8 }}>🤖</div>
                <div style={{ fontWeight: 700, fontSize: "1.1rem", color: "#fff" }}>Optical scanner ready</div>
                <div style={{ fontSize: "0.85rem", marginTop: 6, color: "#8b98ac" }}>
                  Click &quot;Start Camera&quot; — The scanner will detect the calculator screen and lock onto the top optical bar!
                </div>
              </div>
            )}
          </div>

          {/* Quick Info Footer */}
          <div style={{ padding: "12px 18px", display: "flex", justifyContent: "space-between", alignItems: "center", borderTop: "1px solid rgba(255,255,255,0.05)" }}>
            <span style={{ fontSize: "0.75rem", color: "#7f8a9a" }}>
              {aiAutoLockEnabled
                ? "✨ AI Screen Auto-Lock is ACTIVE. Simply point your camera at the calculator or monitor screen!"
                : "✋ Manual mode: Click and drag across the top 2 rows of pixels to set scanner."}
            </span>
            <div style={{ display: "flex", gap: 8 }}>
              {aiAutoLockEnabled && (
                <button
                  className="custom-btn"
                  style={{ fontSize: "0.75rem", padding: "4px 10px" }}
                  onClick={() => {
                    lastDetectedRoiRef.current = null;
                  }}
                >
                  🔄 Reset AI Lock
                </button>
              )}
            </div>
          </div>
        </section>

        {/* Right Column: Audio Output & Telemetry */}
        <div style={{ display: "flex", flexDirection: "column", gap: 24 }}>
          {/* Audio Visualizer Card */}
          <section className="glass-panel">
            <div className="glass-panel-header">
              <span style={{ fontWeight: 700, fontSize: "0.9rem", display: "flex", alignItems: "center", gap: 8 }}>
                🔊 Web Audio Stream // Roland SC-55 E1M1
              </span>
              <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                <span style={{ fontSize: "0.75rem", color: "#7f8a9a" }}>VOL</span>
                <input
                  type="range"
                  min="0"
                  max="1"
                  step="0.05"
                  value={volume}
                  onChange={(e) => {
                    const v = parseFloat(e.target.value);
                    setVolume(v);
                    audioEngineRef.current?.setVolume(v);
                  }}
                  style={{ width: 80, accentColor: "#00ff88" }}
                />
              </div>
            </div>

            <div style={{ padding: "16px 18px" }}>
              <canvas
                ref={visualizerCanvasRef}
                width={400}
                height={90}
                style={{
                  width: "100%",
                  height: 90,
                  background: "rgba(0,0,0,0.5)",
                  borderRadius: 8,
                  display: "block",
                  border: "1px solid rgba(255,255,255,0.06)",
                }}
              />

              <div style={{ display: "flex", justifyContent: "space-between", marginTop: 10, fontSize: "0.8rem" }}>
                <span style={{ color: "#7f8a9a" }}>
                  Soundtrack: <b style={{ color: "#fff" }}>At Doom&apos;s Gate (D_E1M1)</b>
                </span>
                <span style={{ color: isLocked && telemetry && (telemetry.status & 2) ? "#00ff88" : "#7f8a9a" }}>
                  {isLocked && telemetry && (telemetry.status & 2) ? "▶ PLAYING (44.1 kHz)" : "⏸ PAUSED"}
                </span>
              </div>
            </div>
          </section>

          {/* Telemetry Dashboard */}
          <section className="glass-panel">
            <div className="glass-panel-header">
              <span style={{ fontWeight: 700, fontSize: "0.9rem" }}>📊 AI Vision & Optical Telemetry</span>
              <span style={{ fontSize: "0.75rem", color: "#00d8ff", fontFamily: "monospace" }}>
                {decoderReady ? "RUST WASM OPTIMIZED" : "INITIALIZING..."}
              </span>
            </div>

            <div style={{ padding: "16px 18px", display: "grid", gridTemplateColumns: "repeat(3, 1fr)", gap: 12 }}>
              <div className="telemetry-item">
                <div className="telemetry-label">AI Lock-on</div>
                <div className="telemetry-value" style={{ color: isLocked ? "#00ff88" : "#ffaa00", fontSize: "0.95rem" }}>
                  {isLocked ? "CHECKSUM OK" : "SEARCHING"}
                </div>
              </div>

              <div className="telemetry-item">
                <div className="telemetry-label">Sync Bytes</div>
                <div className="telemetry-value" style={{ color: isLocked ? "#00d8ff" : "#8b98ac", fontSize: "0.95rem" }}>
                  {isLocked ? "0xA5" : "WAITING"}
                </div>
              </div>

              <div className="telemetry-item">
                <div className="telemetry-label">Sequence</div>
                <div className="telemetry-value">#{telemetry?.sequence ?? 0}</div>
              </div>

              <div className="telemetry-item">
                <div className="telemetry-label">Spatial Pan</div>
                <div className="telemetry-value" style={{ fontSize: "0.95rem" }}>
                  {telemetry ? `${Math.round(((telemetry.pan - 7) / 7) * 100)}%` : "0%"}
                </div>
              </div>

              <div className="telemetry-item">
                <div className="telemetry-label">Distance Vol</div>
                <div className="telemetry-value" style={{ fontSize: "0.95rem" }}>
                  {telemetry ? `${Math.round((telemetry.volume / 15) * 100)}%` : "100%"}
                </div>
              </div>

              <div className="telemetry-item">
                <div className="telemetry-label">Pitch Shift</div>
                <div className="telemetry-value" style={{ fontSize: "0.95rem" }}>
                  {telemetry?.pitch === 7 ? "Normal" : `${telemetry?.pitch ?? 7}`}
                </div>
              </div>
            </div>
          </section>

          {/* Live Event Log */}
          <section className="glass-panel" style={{ flex: 1, minHeight: 180, display: "flex", flexDirection: "column" }}>
            <div className="glass-panel-header">
              <span style={{ fontWeight: 700, fontSize: "0.9rem" }}>🎯 Decoded Sound Events</span>
              <span style={{ fontSize: "0.75rem", color: "#7f8a9a" }}>{events.length} captured</span>
            </div>

            <div className="custom-scroll" style={{ padding: "10px 18px", flex: 1, overflowY: "auto", maxHeight: 180 }}>
              {events.length === 0 ? (
                <div style={{ color: "#505b6b", fontSize: "0.8rem", textAlign: "center", padding: "26px 0" }}>
                  Aim camera at Doom84 screen — events will stream live!
                </div>
              ) : (
                events.map((ev) => (
                  <div
                    key={ev.id}
                    style={{
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "space-between",
                      padding: "6px 0",
                      borderBottom: "1px solid rgba(255,255,255,0.04)",
                      fontSize: "0.8rem",
                    }}
                  >
                    <span style={{ display: "flex", alignItems: "center", gap: 8 }}>
                      <span>{ev.icon}</span>
                      <b style={{ color: "#fff" }}>SFX_{ev.name}</b>
                    </span>
                    <span style={{ color: "#7f8a9a", fontFamily: "monospace", fontSize: "0.75rem" }}>
                      Pan: {ev.pan > 0 ? `+${ev.pan}%` : `${ev.pan}%`} | Vol: {ev.vol}% | {ev.time}
                    </span>
                  </div>
                ))
              )}
            </div>
          </section>
        </div>
      </div>
    </div>
  );
}
