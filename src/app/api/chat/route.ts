import { NextRequest, NextResponse } from "next/server";

const DEFAULT_SYSTEM_INSTRUCTION = `You are CalcGPT, an AI assistant running on a Texas Instruments TI-84 Plus CE graphing calculator via a WebUSB link.
Keep responses concise, clear, and direct. The calculator display is 320x240 pixels (around 38 characters per line) and supports plain ASCII text.
Avoid complex Markdown like tables, bold, italics, or headers; simple lists and line breaks work best.`;

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const { message, history = [], apiKey: clientKey, projectId: clientProject } = body;

    if (!message || typeof message !== "string") {
      return NextResponse.json({ error: "Missing or invalid prompt message" }, { status: 400 });
    }

    const keyOrToken = (clientKey || process.env.GEMINI_API_KEY || process.env.GOOGLE_ACCESS_TOKEN || "").trim();
    const isGoogleCloudToken = keyOrToken.startsWith("ya29.");
    const projectId = clientProject || process.env.GOOGLE_CLOUD_PROJECT || "intense-terra-512718-j7";
    const location = process.env.GOOGLE_CLOUD_LOCATION || "us-central1";

    if (!keyOrToken && !process.env.GOOGLE_APPLICATION_CREDENTIALS) {
      return NextResponse.json(
        {
          error:
            "No credential provided. Enter a Google AI Studio API key (AIzaSy...) from a personal account, or a Google Cloud Bearer token (ya29...).",
        },
        { status: 401 }
      );
    }

    let url: string;
    const headers: Record<string, string> = { "Content-Type": "application/json" };
    const model = process.env.GEMINI_MODEL || (isGoogleCloudToken ? "gemini-2.0-flash-001" : "gemini-2.5-flash");

    if (isGoogleCloudToken) {
      // Vertex AI / Google Cloud Agent Platform endpoint
      url = `https://${location}-aiplatform.googleapis.com/v1/projects/${projectId}/locations/${location}/publishers/google/models/${model}:generateContent`;
      headers["Authorization"] = `Bearer ${keyOrToken}`;
    } else {
      // Google AI Studio endpoint
      url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${keyOrToken}`;
    }

    const contents = [
      ...history.map((h: { role: string; content: string }) => ({
        role: h.role === "assistant" ? "model" : "user",
        parts: [{ text: h.content }],
      })),
      { role: "user", parts: [{ text: message }] },
    ];

    const response = await fetch(url, {
      method: "POST",
      headers,
      body: JSON.stringify({
        system_instruction: {
          parts: [{ text: DEFAULT_SYSTEM_INSTRUCTION }],
        },
        contents,
        generationConfig: {
          maxOutputTokens: 512,
          temperature: 0.7,
        },
      }),
    });

    if (!response.ok) {
      const errText = await response.text();
      let errMsg = `Gemini API error (${response.status})`;
      try {
        const errJson = JSON.parse(errText);
        if (errJson.error?.message) {
          errMsg = errJson.error.message;
        }
      } catch {
        errMsg = errText || errMsg;
      }
      return NextResponse.json({ error: errMsg }, { status: response.status });
    }

    const data = await response.json();
    const candidate = data.candidates?.[0];
    const replyText =
      candidate?.content?.parts?.map((p: { text?: string }) => p.text || "").join("") ||
      "(No response text)";

    return NextResponse.json({ reply: replyText });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : String(err);
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
