import { NextRequest, NextResponse } from "next/server";

const DEFAULT_HOMEPAGE = `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>TI-84 Browser Home</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; background: #f4f7f6; color: #222; margin: 0; padding: 14px; }
    h1 { font-size: 18px; margin: 0 0 8px; color: #0066cc; }
    p { font-size: 12px; margin: 0 0 12px; color: #555; }
    .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }
    a.card { display: block; background: #fff; border: 1px solid #d0d7de; border-radius: 6px; padding: 10px; text-decoration: none; color: #0969da; font-weight: bold; font-size: 13px; }
    a.card:hover { background: #e8f0fe; border-color: #0969da; }
    .footer { margin-top: 16px; font-size: 11px; color: #888; }
  </style>
</head>
<body>
  <h1>🌐 TI-84 Web Portal</h1>
  <p>Select a quick site or enter any URL on your calculator:</p>
  <div class="grid">
    <a class="card" href="https://en.wikipedia.org/wiki/Special:Random">🎲 Random Wikipedia</a>
    <a class="card" href="https://news.ycombinator.com">📰 Hacker News</a>
    <a class="card" href="https://en.wikipedia.org/wiki/Texas_Instruments">📐 TI History</a>
    <a class="card" href="https://wttr.in">☀️ Live Weather</a>
    <a class="card" href="https://en.wikipedia.org/wiki/Doom_(1993_video_game)">👾 DOOM (1993)</a>
    <a class="card" href="https://text.npr.org">📻 NPR News</a>
  </div>
  <div class="footer">TI-84 Plus CE Remote Browser · Powered by WebUSB</div>
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
          "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        Accept: "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
      },
      redirect: "follow",
    });

    const contentType = res.headers.get("content-type") || "";

    // If it's an image, forward it directly
    if (contentType.startsWith("image/")) {
      const blob = await res.arrayBuffer();
      return new NextResponse(blob, {
        headers: { "Content-Type": contentType },
      });
    }

    let html = await res.text();

    // Inject base tag for relative assets
    const baseTag = `<base href="${finalUrl}">`;
    if (html.includes("<head>")) {
      html = html.replace("<head>", `<head>${baseTag}`);
    } else if (html.includes("<html>")) {
      html = html.replace("<html>", `<html><head>${baseTag}</head>`);
    } else {
      html = `${baseTag}${html}`;
    }

    // Inject link rewriting and navigation interceptor script
    const interceptScript = `
      <script>
        document.addEventListener('click', function(e) {
          const a = e.target.closest('a');
          if (a && a.href) {
            e.preventDefault();
            window.location.href = '/api/browser/proxy?url=' + encodeURIComponent(a.href);
          }
        }, true);
      </script>
    `;
    html += interceptScript;

    return new NextResponse(html, {
      headers: {
        "Content-Type": "text/html; charset=utf-8",
        // Strip framing restrictions
        "Access-Control-Allow-Origin": "*",
      },
    });
  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : String(err);
    const errorPage = `<!DOCTYPE html><html><body style="font-family:sans-serif;padding:20px;color:#c00">
      <h2>Failed to load page</h2>
      <p>Error: ${msg}</p>
      <a href="/api/browser/proxy?url=home">Return to Home</a>
    </body></html>`;
    return new NextResponse(errorPage, {
      status: 502,
      headers: { "Content-Type": "text/html; charset=utf-8" },
    });
  }
}
