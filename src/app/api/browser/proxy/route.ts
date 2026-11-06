import { NextRequest, NextResponse } from "next/server";

const DEFAULT_HOMEPAGE = `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>TI-84 Browser</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; background: #f4f7f6; color: #222; margin: 0; padding: 12px; max-width: 320px; }
    h1 { font-size: 16px; margin: 0 0 6px; color: #0066cc; }
    p { font-size: 11px; margin: 0 0 10px; color: #555; line-height: 1.4; }
    .grid { display: flex; flex-direction: column; gap: 6px; }
    a.card { display: block; background: #fff; border: 1px solid #d0d7de; border-radius: 6px; padding: 8px 10px; text-decoration: none; color: #0969da; font-weight: bold; font-size: 12px; }
    a.card:hover { background: #e8f0fe; border-color: #0969da; }
    .footer { margin-top: 14px; font-size: 10px; color: #888; text-align: center; }
  </style>
</head>
<body>
  <h1>🌐 TI-84 Web Portal</h1>
  <p>Click any link with your mouse cursor or type a URL:</p>
  <div class="grid">
    <a class="card" href="/api/browser/proxy?url=https%3A%2F%2Fen.wikipedia.org%2Fwiki%2FSpecial%3ARandom">🎲 Random Wikipedia</a>
    <a class="card" href="/api/browser/proxy?url=https%3A%2F%2Fnews.ycombinator.com">📰 Hacker News</a>
    <a class="card" href="/api/browser/proxy?url=https%3A%2F%2Fen.wikipedia.org%2Fwiki%2FTexas_Instruments">📐 TI History</a>
    <a class="card" href="/api/browser/proxy?url=https%3A%2F%2Fen.wikipedia.org%2Fwiki%2FDoom_(1993_video_game)">👾 DOOM (1993)</a>
    <a class="card" href="/api/browser/proxy?url=https%3A%2F%2Ftext.npr.org">📻 NPR Text News</a>
    <a class="card" href="/api/browser/proxy?url=https%3A%2F%2Fhtml5test.com">🧪 HTML5 Test</a>
  </div>
  <div class="footer">TI-84 Plus CE Remote Browser · WebUSB</div>
</body>
</html>`;

export async function GET(req: NextRequest) {
  const { searchParams } = new URL(req.url);
  const target = searchParams.get("url");

  if (!target || target === "about:blank" || target === "home") {
    return new NextResponse(DEFAULT_HOMEPAGE, {
      headers: { "Content-Type": "text/html; charset=utf-8" },
    });
  }

  let finalUrl = target;
  if (!/^https?:\/\//i.test(finalUrl)) {
    finalUrl = "https://" + finalUrl;
  }

  try {
    const res = await fetch(finalUrl, {
      headers: {
        "User-Agent":
          "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1",
        Accept: "text/html,application/xhtml+xml,application/xml;q=0.9,image/*,*/*;q=0.8",
      },
      redirect: "follow",
    });

    const contentType = res.headers.get("content-type") || "";

    // If it's an image or binary, stream directly with CORS allowed
    if (contentType.startsWith("image/") || contentType.startsWith("font/")) {
      const blob = await res.arrayBuffer();
      return new NextResponse(blob, {
        headers: {
          "Content-Type": contentType,
          "Access-Control-Allow-Origin": "*",
          "Cache-Control": "public, max-age=86400",
        },
      });
    }

    let html = await res.text();

    const baseTag = `<base href="${finalUrl}">`;
    const mobileStyle = `
      <style>
        html, body {
          max-width: 320px !important;
          margin: 0 auto !important;
          font-size: 13px !important;
          line-height: 1.4 !important;
          overflow-y: auto !important;
          scroll-behavior: auto !important;
        }
        img { max-width: 100% !important; height: auto !important; }
        header, nav, .header, .nav { max-width: 320px !important; }
      </style>
    `;

    // Rewrite all anchor links (relative or absolute) to route through proxy
    html = html.replace(/<a\s+([^>]*?)href=(?:["']([^"']+)["']|([^\s>]+))/gi, (match, before, quotedHref, bareHref) => {
      const rawHref = quotedHref || bareHref || "";
      if (!rawHref || rawHref.startsWith("#") || rawHref.startsWith("javascript:")) {
        return match;
      }
      try {
        const resolved = new URL(rawHref, finalUrl).toString();
        return `<a ${before}href="/api/browser/proxy?url=${encodeURIComponent(resolved)}"`;
      } catch {
        return match;
      }
    });

    // Rewrite image sources to proxy to prevent canvas cross-origin tainting
    html = html.replace(/<img\s+([^>]*?)src=(?:["']([^"']+)["']|([^\s>]+))/gi, (match, before, quotedSrc, bareSrc) => {
      const rawSrc = quotedSrc || bareSrc || "";
      if (!rawSrc || rawSrc.startsWith("data:")) return match;
      try {
        const resolved = new URL(rawSrc, finalUrl).toString();
        return `<img ${before}src="/api/browser/proxy?url=${encodeURIComponent(resolved)}"`;
      } catch {
        return match;
      }
    });

    if (html.includes("<head>")) {
      html = html.replace("<head>", `<head>${baseTag}${mobileStyle}`);
    } else if (html.includes("<html>")) {
      html = html.replace("<html>", `<html><head>${baseTag}${mobileStyle}</head>`);
    } else {
      html = `${baseTag}${mobileStyle}${html}`;
    }

    return new NextResponse(html, {
      headers: {
        "Content-Type": "text/html; charset=utf-8",
        "Access-Control-Allow-Origin": "*",
      },
    });
  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : String(err);
    const errorPage = `<!DOCTYPE html><html><body style="font-family:sans-serif;padding:16px;color:#c00;max-width:320px">
      <h3>Failed to load page</h3>
      <p style="font-size:12px;color:#555">${msg}</p>
      <a href="/api/browser/proxy?url=home" style="color:#0066cc;font-weight:bold">Return to Home</a>
    </body></html>`;
    return new NextResponse(errorPage, {
      status: 502,
      headers: { "Content-Type": "text/html; charset=utf-8" },
    });
  }
}
