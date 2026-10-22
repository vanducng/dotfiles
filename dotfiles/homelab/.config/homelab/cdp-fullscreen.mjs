// Put the CDP Chrome window into true fullscreen once it is up.
// GNOME/Wayland ignores --start-fullscreen when Chrome restores a maximized window.
const port = process.env.CDP_PORT ?? "9222";
const base = `http://127.0.0.1:${port}`;
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function cdp(wsUrl, method, params = {}) {
  const ws = new WebSocket(wsUrl);
  // Chrome can restart mid-call; reject on close or after 5s so the retry loop keeps going.
  const timer = setTimeout(() => ws.close(), 5000);
  try {
    await new Promise((res, rej) => { ws.onopen = res; ws.onerror = rej; ws.onclose = rej; });
    return await new Promise((res, rej) => {
      ws.onclose = () => rej(new Error(`${method}: socket closed`));
      ws.onmessage = (e) => { const m = JSON.parse(e.data); if (m.id === 1) m.error ? rej(new Error(m.error.message)) : res(m.result); };
      ws.send(JSON.stringify({ id: 1, method, params }));
    });
  } finally {
    clearTimeout(timer);
    ws.close();
  }
}

// Re-apply until the page really fills the screen for 10s: Chrome can report windowState
// "fullscreen" while GNOME still shows it maximized under the top bar.
const fillsScreen = (page) =>
  cdp(page.webSocketDebuggerUrl, "Runtime.evaluate", { expression: "innerHeight >= screen.height && innerWidth >= screen.width", returnByValue: true })
    .then((r) => r.result.value === true);

let held = 0;
for (let i = 0; i < 120; i++) {
  try {
    const { webSocketDebuggerUrl: ws } = await (await fetch(`${base}/json/version`)).json();
    const page = (await (await fetch(`${base}/json/list`)).json()).find((t) => t.type === "page" && t.title && t.title !== "about:blank");
    if (page) {
      if (await fillsScreen(page)) {
        if (++held >= 10) { console.log(`cdp-fullscreen: ${page.title} fills the screen`); process.exit(0); }
      } else {
        held = 0;
        const { windowId } = await cdp(ws, "Browser.getWindowForTarget", { targetId: page.id });
        await cdp(ws, "Browser.setWindowBounds", { windowId, bounds: { windowState: "normal" } });
        await sleep(800);
        await cdp(ws, "Browser.setWindowBounds", { windowId, bounds: { windowState: "fullscreen" } });
        await sleep(1500);
      }
    }
  } catch {}
  await sleep(1000);
}
console.error("cdp-fullscreen: could not keep the window fullscreen");
process.exit(1);
