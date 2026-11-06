"use client";

import Link from "next/link";
import { useEffect, useRef, useState } from "react";

type Device = {
  productName?: string;
  opened: boolean;
  configuration?: {
    interfaces: {
      interfaceNumber: number;
      alternates: {
        alternateSetting: number;
        interfaceClass: number;
        interfaceSubclass: number;
        interfaceProtocol: number;
      }[];
    }[];
  };
  open(): Promise<void>;
  close(): Promise<void>;
  selectConfiguration(n: number): Promise<void>;
  claimInterface(n: number): Promise<void>;
  selectAlternateInterface(n: number, alternate: number): Promise<void>;
  transferIn(endpoint: number, length: number): Promise<{ status: string; data?: DataView }>;
  transferOut(endpoint: number, data: BufferSource): Promise<{ status: string; bytesWritten?: number }>;
};

type Usb = {
  requestDevice(options: { filters: { vendorId: number; productId: number }[] }): Promise<Device>;
};

interface Message {
  role: "user" | "assistant" | "system";
  content: string;
  timestamp: string;
}

const MAGIC = [0x43, 0x47, 0x50, 0x54]; // "CGPT"
const PKT_PROMPT_START = 0x01;
const PKT_PROMPT_DATA = 0x02;
const PKT_CANCEL = 0x03;
const PKT_PING = 0x04;
const PKT_REPLY_START = 0x10;
const PKT_REPLY_CHUNK = 0x11;
const PKT_REPLY_END = 0x12;
const PKT_ERROR = 0x13;
const PKT_PONG = 0x14;

export default function AiPage() {
  const [status, setStatus] = useState("Ready to connect");
  const [connected, setConnected] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");
  const [deviceName, setDeviceName] = useState("");
  const [apiKey, setApiKey] = useState("");
  const [showKeyInput, setShowKeyInput] = useState(false);
  const [messages, setMessages] = useState<Message[]>([
    {
      role: "system",
      content: "CalcGPT initialized. Connect TI-84 Plus CE running CALCGPT to begin.",
      timestamp: "Ready",
    },
  ]);
  const [webInput, setWebInput] = useState("");
  const [transmitting, setTransmitting] = useState(false);

  const deviceRef = useRef<Device | null>(null);
  const activeRef = useRef(false);
  const promptBufferRef = useRef<string>("");
  const messagesEndRef = useRef<HTMLDivElement | null>(null);

  const apiKeyRef = useRef(apiKey);
  apiKeyRef.current = apiKey;

  const messagesRef = useRef(messages);
  messagesRef.current = messages;

  const handlePromptRef = useRef<(prompt: string) => Promise<void>>(null!);

  useEffect(() => {
    const saved = localStorage.getItem("calcgpt_gemini_key");
    if (saved) setApiKey(saved);
  }, []);

  const saveApiKey = (key: string) => {
    setApiKey(key);
    localStorage.setItem("calcgpt_gemini_key", key);
  };

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  const disconnect = async () => {
    activeRef.current = false;
    if (deviceRef.current?.opened) {
      try {
        await deviceRef.current.close();
      } catch {}
    }
    deviceRef.current = null;
    setConnected(false);
    setBusy(false);
    setStatus("Disconnected");
  };

  const sendPacket = async (type: number, seq: number, payload: Uint8Array) => {
    const dev = deviceRef.current;
    if (!dev || !dev.opened) return;

    const packet = new Uint8Array(64);
    packet.set(MAGIC, 0);
    packet[4] = type;
    packet[5] = seq & 0xff;
    packet[6] = payload.length & 0xff;
    packet[7] = (payload.length >> 8) & 0xff;
    packet.set(payload, 8);

    await dev.transferOut(2, packet); // Bulk OUT is Endpoint 2
  };

  const sendTextToCalculator = async (text: string, isError: boolean = false) => {
    setTransmitting(true);
    setStatus(isError ? "Sending error to calculator…" : "Streaming reply to calculator…");
    const encoder = new TextEncoder();
    const bytes = encoder.encode(text);
    const chunkSize = 56;
    const totalChunks = Math.ceil(bytes.length / chunkSize) || 1;

    try {
      if (isError) {
        await sendPacket(PKT_ERROR, 0, bytes.slice(0, chunkSize));
      } else {
        await sendPacket(PKT_REPLY_START, totalChunks, new Uint8Array([bytes.length & 0xff, (bytes.length >> 8) & 0xff]));

        for (let i = 0; i < totalChunks; i++) {
          const chunk = bytes.slice(i * chunkSize, (i + 1) * chunkSize);
          await sendPacket(PKT_REPLY_CHUNK, i, chunk);
          // Small pause so eZ80 calculator display can render smoothly
          await new Promise((r) => setTimeout(r, 12));
        }

        await sendPacket(PKT_REPLY_END, 0, new Uint8Array(0));
      }
    } catch (e) {
      console.error("USB send failed:", e);
    } finally {
      setTransmitting(false);
      setStatus("Connected · Ready for next prompt");
    }
  };

  const handlePromptFromCalculator = async (prompt: string) => {
    if (!prompt.trim()) return;

    const userMsg: Message = {
      role: "user",
      content: prompt,
      timestamp: new Date().toLocaleTimeString(),
    };
    setMessages((prev) => [...prev, userMsg]);
    setStatus("Calling Gemini 2.5 Flash…");

    const effectiveKey = (apiKeyRef.current || localStorage.getItem("calcgpt_gemini_key") || apiKey || "").trim();

    try {
      const res = await fetch("/api/chat", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          message: prompt,
          apiKey: effectiveKey || undefined,
          history: messagesRef.current
            .filter((m) => m.role === "user" || m.role === "assistant")
            .slice(-6),
        }),
      });

      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.error || `HTTP ${res.status}`);
      }

      const reply = data.reply || "(No reply received)";
      const aiMsg: Message = {
        role: "assistant",
        content: reply,
        timestamp: new Date().toLocaleTimeString(),
      };
      setMessages((prev) => [...prev, aiMsg]);

      // Stream to calculator
      await sendTextToCalculator(reply);
    } catch (e: unknown) {
      const err = e instanceof Error ? e.message : String(e);
      const errMsg: Message = {
        role: "system",
        content: `Error: ${err}`,
        timestamp: new Date().toLocaleTimeString(),
      };
      setMessages((prev) => [...prev, errMsg]);
      await sendTextToCalculator(err, true);
    }
  };

  handlePromptRef.current = handlePromptFromCalculator;

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

      // Find interface with subclass 0x44 (custom)
      const iface = device.configuration?.interfaces.find((i) =>
        i.alternates.some((a) => a.interfaceClass === 255 && a.interfaceSubclass === 0x44)
      );

      if (!iface) {
        throw new Error("No CalcGPT audio/data interface found. Ensure CALCGPT is running on the calculator.");
      }

      const alternate = iface.alternates.find(
        (a) => a.interfaceClass === 255 && a.interfaceSubclass === 0x44
      )!;

      try {
        await device.claimInterface(iface.interfaceNumber);
      } catch {
        throw new Error("Calculator USB is busy. Quit TI Connect CE (⌘Q), close other tabs, and re-plug cable.");
      }

      await device.selectAlternateInterface(iface.interfaceNumber, alternate.alternateSetting);

      activeRef.current = true;
      setConnected(true);
      setBusy(false);
      setStatus("Connected · Waiting for prompt from calculator");

      // Send initial PONG / Handshake
      await sendPacket(PKT_PONG, 0, new Uint8Array([1]));

      // Read loop on Endpoint 1 (Bulk IN)
      while (activeRef.current && device.opened) {
        const result = await device.transferIn(1, 64);
        if (result.status !== "ok" || !result.data) continue;

        const dv = result.data;
        if (dv.byteLength < 8) continue;

        // Check magic
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
        const textChunk = new TextDecoder().decode(payload);

        if (type === PKT_PROMPT_START) {
          promptBufferRef.current = textChunk;
        } else if (type === PKT_PROMPT_DATA) {
          promptBufferRef.current += textChunk;
        } else if (type === PKT_CANCEL) {
          setStatus("Prompt canceled by calculator");
          promptBufferRef.current = "";
        } else if (type === PKT_PING) {
          await sendPacket(PKT_PONG, 0, new Uint8Array(0));
        }

        // Check if prompt is ready (null-terminated or full line)
        if (type === PKT_PROMPT_START || type === PKT_PROMPT_DATA) {
          if (textChunk.includes("\n") || textChunk.includes("\0") || len < 56) {
            const prompt = promptBufferRef.current.replace(/[\0\r\n]+/g, " ").trim();
            promptBufferRef.current = "";
            if (prompt) {
              void handlePromptRef.current(prompt);
            }
          }
        }
      }
    } catch (e: unknown) {
      const msg = e instanceof Error ? e.message : String(e);
      if (e instanceof DOMException && e.name === "NotFoundError") {
        setError("No calculator was selected.");
      } else {
        setError(msg);
      }
      setStatus("Not connected");
      setConnected(false);
      setBusy(false);
    }
  };

  const handleWebSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!webInput.trim()) return;
    const p = webInput.trim();
    setWebInput("");
    void handlePromptFromCalculator(p);
  };

  return (
    <main
      style={{
        maxWidth: 1000,
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
              color: "#00ff88",
              background: "rgba(0, 255, 136, 0.12)",
              padding: "3px 8px",
              borderRadius: 4,
              fontWeight: 600,
            }}
          >
            CALCGPT · GEMINI AI
          </span>
        </div>

        <nav style={{ display: "flex", gap: 16, fontSize: 13 }}>
          <Link href="/" style={{ color: "#7f8a9a", textDecoration: "none" }}>
            Camera
          </Link>
          <Link href="/usb" style={{ color: "#7f8a9a", textDecoration: "none" }}>
            USB Audio
          </Link>
          <Link href="/ai" style={{ color: "#00ff88", textDecoration: "underline", fontWeight: 600 }}>
            CalcGPT
          </Link>
          <Link href="/browser" style={{ color: "#7f8a9a", textDecoration: "none" }}>
            Browser
          </Link>
        </nav>
      </header>

      {/* Intro */}
      <section style={{ margin: "40px 0 24px" }}>
        <h1 style={{ fontSize: "clamp(32px, 5vw, 46px)", fontWeight: 700, margin: "0 0 10px", letterSpacing: -1 }}>
          ChatGPT on your TI-84.
        </h1>
        <p style={{ color: "#9aada9", fontSize: 16, margin: 0, maxWidth: 680, lineHeight: 1.6 }}>
          Type queries on your TI-84 Plus CE keypad, transmit over WebUSB, and stream responses powered by Google
          Gemini 2.5 Flash back onto the calculator screen.
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
        </div>

        <div style={{ display: "flex", gap: 10 }}>
          <button
            onClick={() => setShowKeyInput(!showKeyInput)}
            style={{
              background: "transparent",
              border: "1px solid #365e4d",
              color: "#aec5bb",
              borderRadius: 8,
              padding: "10px 14px",
              fontSize: 13,
              cursor: "pointer",
            }}
          >
            {apiKey ? "🔑 Key Saved" : "🔑 Set Gemini API Key"}
          </button>

          <button
            onClick={connected ? disconnect : connect}
            disabled={busy || transmitting}
            style={{
              background: connected ? "#ff3344" : "#00ff88",
              color: connected ? "#fff" : "#092217",
              border: 0,
              borderRadius: 8,
              padding: "10px 18px",
              fontSize: 14,
              fontWeight: 600,
              cursor: "pointer",
            }}
          >
            {busy ? "Connecting…" : connected ? "Disconnect" : "Connect Calculator"}
          </button>
        </div>
      </div>

      {/* Optional API Key Input */}
      {showKeyInput && (
        <div
          style={{
            background: "#12171f",
            border: "1px solid #222d3d",
            borderRadius: 12,
            padding: 16,
            marginBottom: 20,
          }}
        >
          <label style={{ fontSize: 13, color: "#8b98ac", display: "block", marginBottom: 8 }}>
            Google Credential (Personal Gemini API Key <code>AIzaSy...</code> or Google Cloud Token <code>ya29...</code>):
          </label>
          <div style={{ display: "flex", gap: 8 }}>
            <input
              type="password"
              placeholder="AIzaSy... (Personal AI Studio) or ya29... (Google Cloud ADC token)"
              value={apiKey}
              onChange={(e) => saveApiKey(e.target.value)}
              style={{
                flex: 1,
                background: "#08090d",
                border: "1px solid #2a3547",
                borderRadius: 8,
                padding: "8px 12px",
                color: "#fff",
                fontSize: 14,
              }}
            />
            <button
              onClick={() => setShowKeyInput(false)}
              style={{
                background: "#1e293b",
                border: "1px solid #334155",
                color: "#e2e8f0",
                borderRadius: 8,
                padding: "8px 16px",
                cursor: "pointer",
              }}
            >
              Done
            </button>
          </div>
          <small style={{ color: "#64748b", marginTop: 6, display: "block", lineHeight: 1.5 }}>
            • <strong>Easiest / Free:</strong> Open <a href="https://aistudio.google.com/app/apikey" target="_blank" rel="noreferrer" style={{ color: "#00d8ff" }}>aistudio.google.com</a> under a personal <code>@gmail.com</code> account (API keys are blocked on enterprise/university accounts).<br/>
            • <strong>Google Cloud (ADC):</strong> In terminal run <code>gcloud auth application-default print-access-token</code> and paste the <code>ya29...</code> token here.
          </small>
        </div>
      )}

      {error && (
        <div
          style={{
            background: "#352318",
            border: "1px solid #83543a",
            color: "#ffcfab",
            padding: "12px 16px",
            borderRadius: 10,
            marginBottom: 20,
            fontSize: 14,
          }}
        >
          {error}
        </div>
      )}

      {/* Terminal / Live Chat View */}
      <div
        style={{
          background: "#08090d",
          border: "1px solid #1a2230",
          borderRadius: 16,
          overflow: "hidden",
          boxShadow: "0 20px 40px rgba(0,0,0,0.5)",
        }}
      >
        <div
          style={{
            background: "#0d131c",
            padding: "10px 16px",
            borderBottom: "1px solid #1a2230",
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
          }}
        >
          <span style={{ fontSize: 12, color: "#8b98ac", fontFamily: "monospace" }}>
            CALCGPT TERMINAL // 320x240 LCD EMULATION
          </span>
          <span style={{ fontSize: 11, color: "#00ff88" }}>
            {connected ? `CONNECTED (${deviceName})` : "STANDBY"}
          </span>
        </div>

        <div
          style={{
            padding: 20,
            minHeight: 320,
            maxHeight: 480,
            overflowY: "auto",
            display: "flex",
            flexDirection: "column",
            gap: 16,
            fontFamily: "monospace",
            fontSize: 14,
            lineHeight: 1.5,
          }}
        >
          {messages.map((m, idx) => (
            <div
              key={idx}
              style={{
                background:
                  m.role === "user"
                    ? "rgba(0, 216, 255, 0.08)"
                    : m.role === "assistant"
                    ? "rgba(0, 255, 136, 0.08)"
                    : "rgba(255, 255, 255, 0.04)",
                borderLeft:
                  m.role === "user"
                    ? "3px solid #00d8ff"
                    : m.role === "assistant"
                    ? "3px solid #00ff88"
                    : "3px solid #64748b",
                padding: "10px 14px",
                borderRadius: "0 8px 8px 0",
              }}
            >
              <div
                style={{
                  fontSize: 11,
                  color: m.role === "user" ? "#00d8ff" : m.role === "assistant" ? "#00ff88" : "#8b98ac",
                  marginBottom: 4,
                  display: "flex",
                  justifyContent: "space-between",
                }}
              >
                <span>{m.role === "user" ? "> TI-84 USER" : m.role === "assistant" ? "< GEMINI 2.5 FLASH" : "SYSTEM"}</span>
                <span style={{ opacity: 0.6 }}>{m.timestamp}</span>
              </div>
              <div style={{ whiteSpace: "pre-wrap", color: "#edf2f7" }}>{m.content}</div>
            </div>
          ))}
          <div ref={messagesEndRef} />
        </div>

        {/* Web Test Input Bar */}
        <form
          onSubmit={handleWebSubmit}
          style={{
            padding: "12px 16px",
            borderTop: "1px solid #1a2230",
            background: "#0c1117",
            display: "flex",
            gap: 8,
          }}
        >
          <input
            type="text"
            placeholder="Type a test message here (or type on your calculator keypad)..."
            value={webInput}
            onChange={(e) => setWebInput(e.target.value)}
            style={{
              flex: 1,
              background: "#08090d",
              border: "1px solid #1e293b",
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
              background: "#1e293b",
              border: "1px solid #334155",
              color: "#00ff88",
              borderRadius: 8,
              padding: "10px 18px",
              cursor: "pointer",
              fontWeight: 600,
            }}
          >
            Send
          </button>
        </form>
      </div>

      {/* Instructions & Binary Download */}
      <section style={{ marginTop: 32, fontSize: 13, color: "#8b98ac", lineHeight: 1.8 }}>
        <h3 style={{ color: "#edf2f7", fontSize: 15, margin: "0 0 8px" }}>Calculator Setup</h3>
        <ol style={{ paddingLeft: 20, margin: 0 }}>
          <li>
            Download <strong><a href="/downloads/CALCGPT.8xp" download style={{ color: "#00ff88" }}>CALCGPT.8xp ↗</a></strong> and transfer it to your calculator using TI Connect CE.
          </li>
          <li>Quit TI Connect CE completely (⌘Q) so it doesn't block the USB port.</li>
          <li>Run <code>prgmCALCGPT</code> on your calculator.</li>
          <li>Unplug and reconnect the USB data cable once while the program is running.</li>
          <li>Click <strong>Connect Calculator</strong> above and select the device.</li>
          <li>
            Hold your calculator sideways (screen on right, keypad on left):
            <div style={{ marginTop: 6, padding: "8px 12px", background: "#0a1318", border: "1px solid #1a2a30", borderRadius: 6, fontFamily: "monospace" }}>
              • Top row (<code>[0]</code>..<code>[WINDOW]</code>): <code>Q</code> to <code>P</code><br />
              • Mid row (<code>[.]</code>..<code>[DEL]</code>): <code>A</code> to <code>L</code><br />
              • Bot row (<code>[(-)]</code>..<code>[VARS]</code>): <code>Z</code> to <code>M</code><br />
              • Modifiers: <code>[+]</code> / <code>[ENTER]</code> = Shift, <code>[ZOOM]</code> = Delete, <code>[TRACE]</code> = Clear<br />
              • Spacebar: <code>[-]</code>, <code>[×]</code>, <code>[÷]</code>, <code>[^]</code>, <code>[CLEAR]</code><br />
              • Send: <code>[GRAPH]</code> | Exit: <code>[Y=]</code>
            </div>
          </li>
        </ol>
      </section>
    </main>
  );
}
