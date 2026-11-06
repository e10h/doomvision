"use client";

import React, { useState, useRef, useEffect, useCallback } from "react";
import Link from "next/link";
import html2canvas from "html2canvas";

/* WebUSB Wire Constants */
const MAGIC = [0x42, 0x52, 0x4f, 0x57]; // "BROW"

const PKT_CLICK = 0x01;
const PKT_SCROLL = 0x02;
const PKT_NAV_URL = 0x03;
const PKT_NAV_BACK = 0x04;
const PKT_NAV_FORWARD = 0x05;
const PKT_NAV_RELOAD = 0x06;
const PKT_PING = 0x07;

const PKT_FRAME_START = 0x10;
const PKT_FRAME_DATA = 0x11;
const PKT_FRAME_END = 0x12;
const PKT_URL_UPDATE = 0x13;
const PKT_STATUS = 0x14;
const PKT_PONG = 0x15;

const SCREEN_W = 320;
const SCREEN_H = 240;

interface UsbDevice {
  productName?: string;
  opened: boolean;
  configuration?: {
    interfaces: Array<{
      interfaceNumber: number;
      alternates: Array<{
        interfaceClass: number;
        interfaceSubclass: number;
        alternateSetting: number;
      }>;
    }>;
  };
  open(): Promise<void>;
  close(): Promise<void>;
  selectConfiguration(configurationValue: number): Promise<void>;
  claimInterface(interfaceNumber: number): Promise<void>;
  selectAlternateInterface(interfaceNumber: number, alternateSetting: number): Promise<void>;
  transferIn(endpointNumber: number, length: number): Promise<{
    data?: DataView;
    status: string;
  }>;
  transferOut(endpointNumber: number, data: BufferSource): Promise<{
    bytesWritten: number;
    status: string;
  }>;
}

interface Usb {
  requestDevice(options: { filters: Array<{ vendorId: number; productId?: number }> }): Promise<UsbDevice>;
}

export default function BrowserPage() {
  const [connected, setConnected] = useState(false);
  const [busy, setBusy] = useState(false);
  const [status, setStatus] = useState("Not connected");
  const [error, setError] = useState("");
  const [deviceName, setDeviceName] = useState("");
  const [currentUrl, setCurrentUrl] = useState("home");
  const [inputUrl, setInputUrl] = useState("https://en.wikipedia.org");
  const [streaming, setStreaming] = useState(false);
  const [fps, setFps] = useState(0);

  const deviceRef = useRef<UsbDevice | null>(null);
  const activeRef = useRef(false);
  const iframeRef = useRef<HTMLIFrameElement | null>(null);
  const canvasRef = useRef<HTMLCanvasElement | null>(null);
  const previewCanvasRef = useRef<HTMLCanvasElement | null>(null);
  const frameCountRef = useRef(0);

  // Send packet to Calculator
  const sendPacket = useCallback(async (type: number, seq: number, payload: Uint8Array) => {
    const dev = deviceRef.current;
    if (!dev || !dev.opened) return;

    const packet = new Uint8Array(64);
    packet.set(MAGIC, 0);
    packet[4] = type;
    packet[5] = seq & 0xff;
    packet[6] = payload.length & 0xff;
    packet[7] = (payload.length >> 8) & 0xff;
    if (payload.length > 0) {
      packet.set(payload.subarray(0, 56), 8);
    }

    try {
      await dev.transferOut(2, packet); // Bulk OUT = Endpoint 2
    } catch (e) {
      console.warn("USB send packet failed:", e);
    }
  }, []);

  // Convert RGBA pixels to RGB332 palette indices
  const quantizeToRGB332 = (data: Uint8ClampedArray): Uint8Array => {
    const pixels = new Uint8Array(SCREEN_W * SCREEN_H);
    let p = 0;
    for (let i = 0; i < data.length; i += 4) {
      const r = (data[i] * 7) / 255;
      const g = (data[i + 1] * 7) / 255;
      const b = (data[i + 2] * 3) / 255;
      pixels[p++] = (Math.round(r) << 5) | (Math.round(g) << 2) | Math.round(b);
    }
    return pixels;
  };

  // Run-Length Encode pixel array into byte pairs [count, color]
  const encodeRLE = (pixels: Uint8Array): Uint8Array => {
    const spans: number[] = [];
    let i = 0;
    while (i < pixels.length) {
      const color = pixels[i];
      let run = 1;
      while (i + run < pixels.length && pixels[i + run] === color && run < 255) {
        run++;
      }
      spans.push(run, color);
      i += run;
    }
    return new Uint8Array(spans);
  };

  // Capture iframe and send frame over WebUSB
  const captureAndStreamFrame = useCallback(async () => {
    if (!iframeRef.current || !activeRef.current || streaming) return;

    const iframe = iframeRef.current;
    const doc = iframe.contentDocument;
    if (!doc || !doc.body) return;

    setStreaming(true);
    try {
      const canvas = await html2canvas(doc.body, {
        width: SCREEN_W,
        height: SCREEN_H,
        windowWidth: SCREEN_W,
        windowHeight: SCREEN_H,
        scale: 1,
        logging: false,
        useCORS: true,
        backgroundColor: "#ffffff",
      });

      const ctx = canvas.getContext("2d");
      if (!ctx) return;
      const imgData = ctx.getImageData(0, 0, SCREEN_W, SCREEN_H);

      // Mirror to preview canvas
      if (previewCanvasRef.current) {
        const prevCtx = previewCanvasRef.current.getContext("2d");
        prevCtx?.drawImage(canvas, 0, 0);
      }

      // Convert & RLE Compress
      const rgb332 = quantizeToRGB332(imgData.data);
      const rleData = encodeRLE(rgb332);

      // Send to Calculator
      await sendPacket(PKT_FRAME_START, 0, new Uint8Array(0));

      const chunkSize = 56;
      for (let i = 0; i < rleData.length; i += chunkSize) {
        const chunk = rleData.subarray(i, i + chunkSize);
        await sendPacket(PKT_FRAME_DATA, (i / chunkSize) & 0xff, chunk);
        await new Promise((r) => setTimeout(r, 4));
      }

      await sendPacket(PKT_FRAME_END, 0, new Uint8Array(0));

      frameCountRef.current++;
    } catch (e) {
      console.error("Frame capture error:", e);
    } finally {
      setStreaming(false);
    }
  }, [sendPacket, streaming]);

  // FPS ticker
  useEffect(() => {
    const timer = setInterval(() => {
      setFps(frameCountRef.current);
      frameCountRef.current = 0;
    }, 1000);
    return () => clearInterval(timer);
  }, []);

  // Handle calculator input commands
  const handleCalculatorCommand = useCallback(
    async (type: number, payload: Uint8Array) => {
      const iframe = iframeRef.current;
      const doc = iframe?.contentDocument;
      const win = iframe?.contentWindow;

      if (type === PKT_CLICK) {
        const x = payload[0] | (payload[1] << 8);
        const y = payload[2] | (payload[3] << 8);
        if (doc) {
          const el = doc.elementFromPoint(x, y);
          if (el) {
            (el as HTMLElement).click();
            // Re-capture after slight delay to allow navigation/hover
            setTimeout(() => {
              void captureAndStreamFrame();
            }, 300);
          }
        }
      } else if (type === PKT_SCROLL) {
        const view = new DataView(payload.buffer, payload.byteOffset, payload.byteLength);
        const delta = view.getInt16(0, true);
        if (win) {
          win.scrollBy({ top: delta, behavior: "auto" });
          setTimeout(() => {
            void captureAndStreamFrame();
          }, 50);
        }
      } else if (type === PKT_NAV_URL) {
        const urlStr = new TextDecoder().decode(payload).replace(/\0/g, "").trim();
        if (urlStr) {
          setCurrentUrl(urlStr);
          setInputUrl(urlStr);
        }
      } else if (type === PKT_NAV_BACK) {
        win?.history.back();
        setTimeout(() => void captureAndStreamFrame(), 300);
      } else if (type === PKT_NAV_FORWARD) {
        win?.history.forward();
        setTimeout(() => void captureAndStreamFrame(), 300);
      } else if (type === PKT_NAV_RELOAD) {
        win?.location.reload();
        setTimeout(() => void captureAndStreamFrame(), 300);
      } else if (type === PKT_PING) {
        await sendPacket(PKT_PONG, 0, new Uint8Array(0));
      }
    },
    [captureAndStreamFrame, sendPacket]
  );

  // Connect WebUSB
  const connect = async () => {
    const usb = (navigator as Navigator & { usb?: Usb }).usb;
    if (!usb) {
      setError("WebUSB is not supported in this browser. Please open in Google Chrome or Edge on desktop.");
      return;
    }

    setError("");
    setBusy(true);
    setStatus("Select TI-84 Plus CE in picker…");

    try {
      const device = await usb.requestDevice({
        filters: [{ vendorId: 0x0451, productId: 0xe008 }],
      });

      deviceRef.current = device;
      setDeviceName(device.productName || "TI-84 Plus CE");
      setStatus("Opening USB interface…");
      await device.open();

      if (!device.configuration) {
        await device.selectConfiguration(1);
      }

      // Find interface with subclass 0x45 (browser) or 0x44 (fallback)
      const iface = device.configuration?.interfaces.find((i) =>
        i.alternates.some((a) => a.interfaceClass === 255 && (a.interfaceSubclass === 0x45 || a.interfaceSubclass === 0x44))
      );

      if (!iface) {
        throw new Error("No BROWSER interface found. Ensure prgmBROWSER is running on the calculator.");
      }

      const alternate = iface.alternates[0];
      await device.claimInterface(iface.interfaceNumber);
      await device.selectAlternateInterface(iface.interfaceNumber, alternate.alternateSetting);

      activeRef.current = true;
      setConnected(true);
      setBusy(false);
      setStatus("Connected · Browser Online");

      // Send initial URL and page frame
      const urlBytes = new TextEncoder().encode(currentUrl);
      await sendPacket(PKT_URL_UPDATE, 0, urlBytes);
      setTimeout(() => void captureAndStreamFrame(), 500);

      // Read loop on Endpoint 1 (Bulk IN)
      while (activeRef.current && device.opened) {
        const result = await device.transferIn(1, 64);
        if (result.status !== "ok" || !result.data) continue;

        const dv = result.data;
        if (dv.byteLength < 8) continue;

        if (
          dv.getUint8(0) !== MAGIC[0] ||
          dv.getUint8(1) !== MAGIC[1] ||
          dv.getUint8(2) !== MAGIC[2] ||
          dv.getUint8(3) !== MAGIC[3]
        ) {
          continue;
        }

        const type = dv.getUint8(4);
        const len = dv.getUint8(6) | (dv.getUint8(7) << 8);
        const payload = new Uint8Array(dv.buffer, dv.byteOffset + 8, Math.min(len, dv.byteLength - 8));

        await handleCalculatorCommand(type, payload);
      }
    } catch (e: unknown) {
      const msg = e instanceof Error ? e.message : String(e);
      setError(msg);
      setStatus("Not connected");
      setConnected(false);
      setBusy(false);
    }
  };

  const disconnect = async () => {
    activeRef.current = false;
    if (deviceRef.current && deviceRef.current.opened) {
      try {
        await deviceRef.current.close();
      } catch (e) {
        console.warn("Close device:", e);
      }
    }
    deviceRef.current = null;
    setConnected(false);
    setStatus("Disconnected");
  };

  const handleNavigateSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!inputUrl.trim()) return;
    setCurrentUrl(inputUrl.trim());
  };

  return (
    <main
      style={{
        maxWidth: 1040,
        margin: "0 auto",
        padding: "32px 24px 70px",
        color: "#f0f4f8",
        fontFamily: "-apple-system, BlinkMacSystemFont, Segoe UI, Roboto, sans-serif",
      }}
    >
      {/* Header */}
      <header
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          borderBottom: "1px solid rgba(255, 255, 255, 0.08)",
          paddingBottom: 16,
        }}
      >
        <div style={{ display: "flex", alignItems: "center", gap: 14 }}>
          <Link
            href="/"
            style={{
              fontSize: 22,
              fontWeight: 700,
              color: "#edf9f3",
              textDecoration: "none",
              letterSpacing: -1,
            }}
          >
            doomvision
          </Link>
          <span
            style={{
              fontSize: 11,
              letterSpacing: 2,
              color: "#00d8ff",
              background: "rgba(0, 216, 255, 0.12)",
              padding: "3px 8px",
              borderRadius: 4,
              fontWeight: 600,
            }}
          >
            TI-84 WEB BROWSER
          </span>
        </div>

        <nav style={{ display: "flex", gap: 16, fontSize: 13 }}>
          <Link href="/" style={{ color: "#7f8a9a", textDecoration: "none" }}>
            Camera
          </Link>
          <Link href="/usb" style={{ color: "#7f8a9a", textDecoration: "none" }}>
            USB Audio
          </Link>
          <Link href="/ai" style={{ color: "#7f8a9a", textDecoration: "none" }}>
            CalcGPT
          </Link>
          <Link href="/browser" style={{ color: "#00d8ff", textDecoration: "underline", fontWeight: 600 }}>
            Browser
          </Link>
        </nav>
      </header>

      {/* Intro */}
      <section style={{ margin: "32px 0 20px" }}>
        <h1 style={{ fontSize: "clamp(28px, 4.5vw, 42px)", fontWeight: 700, margin: "0 0 10px", letterSpacing: -1 }}>
          The World Wide Web on your TI-84.
        </h1>
        <p style={{ color: "#9aada9", fontSize: 15, margin: 0, maxWidth: 680, lineHeight: 1.6 }}>
          A full graphical web browser running on the Texas Instruments TI-84 Plus CE color display. Control the mouse cursor
          with your arrow keys, click links, scroll pages, and browse anywhere through WebUSB.
        </p>
      </section>

      {/* Control Strip */}
      <div
        style={{
          background: "#0c171b",
          border: "1px solid #253b38",
          borderRadius: 16,
          padding: "16px 20px",
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          flexWrap: "wrap",
          gap: 12,
          marginBottom: 20,
        }}
      >
        <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
          <span
            style={{
              width: 8,
              height: 8,
              borderRadius: "50%",
              background: connected ? "#00ff88" : "#556461",
              boxShadow: connected ? "0 0 10px #00ff88" : "none",
            }}
          />
          <span style={{ fontSize: 14, color: "#c2d5ce" }}>{status}</span>
          {connected && (
            <span style={{ fontSize: 12, color: "#00d8ff", background: "#0a2630", padding: "2px 8px", borderRadius: 4 }}>
              {deviceName} · {fps} FPS
            </span>
          )}
        </div>

        <div style={{ display: "flex", gap: 10 }}>
          <button
            onClick={() => void captureAndStreamFrame()}
            disabled={!connected || streaming}
            style={{
              background: "#1e293b",
              border: "1px solid #334155",
              color: "#aec5bb",
              borderRadius: 8,
              padding: "10px 14px",
              fontSize: 13,
              cursor: connected ? "pointer" : "not-allowed",
            }}
          >
            🔄 Refresh Frame
          </button>

          <button
            onClick={connected ? disconnect : connect}
            disabled={busy}
            style={{
              background: connected ? "#ff3344" : "#00d8ff",
              color: connected ? "#fff" : "#051822",
              border: "none",
              borderRadius: 8,
              padding: "10px 20px",
              fontSize: 14,
              fontWeight: 600,
              cursor: busy ? "wait" : "pointer",
            }}
          >
            {busy ? "Connecting…" : connected ? "Disconnect" : "Connect Calculator"}
          </button>
        </div>
      </div>

      {error && (
        <div style={{ background: "rgba(255, 60, 60, 0.1)", border: "1px solid rgba(255, 60, 60, 0.3)", borderRadius: 10, padding: "12px 16px", color: "#ff8080", marginBottom: 20, fontSize: 14 }}>
          {error}
        </div>
      )}

      {/* URL Navigation Bar */}
      <form
        onSubmit={handleNavigateSubmit}
        style={{
          display: "flex",
          gap: 10,
          background: "#080c10",
          border: "1px solid #1a2736",
          borderRadius: 12,
          padding: 8,
          marginBottom: 20,
        }}
      >
        <input
          type="text"
          value={inputUrl}
          onChange={(e) => setInputUrl(e.target.value)}
          placeholder="Enter URL (e.g. https://en.wikipedia.org or https://news.ycombinator.com)..."
          style={{
            flex: 1,
            background: "#0e1520",
            border: "1px solid #203144",
            borderRadius: 8,
            padding: "10px 14px",
            color: "#fff",
            fontFamily: "monospace",
            fontSize: 13,
          }}
        />
        <button
          type="submit"
          style={{
            background: "#00d8ff",
            color: "#051822",
            border: "none",
            borderRadius: 8,
            padding: "10px 20px",
            fontSize: 13,
            fontWeight: 600,
            cursor: "pointer",
          }}
        >
          Navigate
        </button>
      </form>

      {/* Dual Viewports: Webview + Calculator LCD Mirror */}
      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 20, alignItems: "start" }}>
        {/* Left: Live Webview (Iframe) */}
        <div style={{ background: "#080c10", border: "1px solid #1a2736", borderRadius: 12, padding: 16 }}>
          <div style={{ fontSize: 12, color: "#8b98ac", marginBottom: 10, display: "flex", justifyContent: "space-between" }}>
            <span>🌐 Browser Viewport (320×240)</span>
            <span>{currentUrl}</span>
          </div>
          <iframe
            ref={iframeRef}
            src={`/api/browser/proxy?url=${encodeURIComponent(currentUrl)}`}
            onLoad={() => {
              setTimeout(() => void captureAndStreamFrame(), 500);
            }}
            style={{
              width: SCREEN_W,
              height: SCREEN_H,
              border: "1px solid #2a3547",
              borderRadius: 6,
              background: "#fff",
              display: "block",
            }}
          />
        </div>

        {/* Right: Calculator LCD Live Mirror */}
        <div style={{ background: "#080c10", border: "1px solid #1a2736", borderRadius: 12, padding: 16 }}>
          <div style={{ fontSize: 12, color: "#00d8ff", marginBottom: 10, display: "flex", justifyContent: "space-between" }}>
            <span>📟 Calculator LCD Stream (RGB332 Palette)</span>
            <span>{streaming ? "Streaming…" : "Idle"}</span>
          </div>
          <canvas
            ref={previewCanvasRef}
            width={SCREEN_W}
            height={SCREEN_H}
            style={{
              width: SCREEN_W,
              height: SCREEN_H,
              border: "1px solid #2a3547",
              borderRadius: 6,
              background: "#000",
              display: "block",
              imageRendering: "pixelated",
            }}
          />
        </div>
      </div>

      {/* Hidden processing canvas */}
      <canvas ref={canvasRef} width={SCREEN_W} height={SCREEN_H} style={{ display: "none" }} />

      {/* Calculator Setup & Key Guide */}
      <section style={{ marginTop: 32, fontSize: 13, color: "#8b98ac", lineHeight: 1.8 }}>
        <h3 style={{ color: "#edf2f7", fontSize: 16, margin: "0 0 10px" }}>Getting Started</h3>
        <ol style={{ paddingLeft: 20, margin: "0 0 16px" }}>
          <li>
            Download <strong><a href="/downloads/BROWSER.8xp" download style={{ color: "#00d8ff" }}>BROWSER.8xp ↗</a></strong> and send it to your calculator using TI Connect CE.
          </li>
          <li>Quit TI Connect CE (⌘Q) so the USB port is free.</li>
          <li>Run <code>prgmBROWSER</code> on your calculator.</li>
          <li>Click <strong>Connect Calculator</strong> above and select the device.</li>
        </ol>

        <h4 style={{ color: "#edf2f7", fontSize: 14, margin: "0 0 8px" }}>Calculator Controls:</h4>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10, maxWidth: 600, fontFamily: "monospace" }}>
          <div style={{ padding: "8px 12px", background: "#0a1318", border: "1px solid #1a2a30", borderRadius: 6 }}>
            • <code>[▲] [▼] [◀] [▶]</code> : Move Mouse<br />
            • <code>[ENTER]</code> or <code>[2nd]</code> : Left Click<br />
            • <code>[+]</code> / <code>[-]</code> : Scroll Page
          </div>
          <div style={{ padding: "8px 12px", background: "#0a1318", border: "1px solid #1a2a30", borderRadius: 6 }}>
            • <code>[WINDOW]</code> : Enter URL<br />
            • <code>[GRAPH]</code> : Back History<br />
            • <code>[TRACE]</code> : Forward History<br />
            • <code>[Y=]</code> : Quit to TI-OS
          </div>
        </div>
      </section>
    </main>
  );
}
