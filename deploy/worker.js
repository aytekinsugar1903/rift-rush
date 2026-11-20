// Rift Rush: static game + daily leaderboard (D1). Stores only nickname + score.
// Abuse limits: 20 POST/day per hashed (IP+day) key; the key rotates daily and cannot be reversed.
// Nick ownership: the first device to post a nick owns it (only a hash of its random device id is stored),
// so nobody can overwrite another player's row. Runs shorter than MIN_DUR or longer than the level allows are refused.
const CORS = { "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Methods": "GET,POST,OPTIONS", "Access-Control-Allow-Headers": "Content-Type" };
const json = (d, s = 200) => new Response(JSON.stringify(d), { status: s, headers: { "Content-Type": "application/json; charset=utf-8", ...CORS } });
function trDay(offsetDays = 0) {
  const d = new Date(Date.now() + 3 * 3600e3 - offsetDays * 86400e3);
  return d.toISOString().slice(0, 10);
}
async function sha(s) {
  const b = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(s));
  return [...new Uint8Array(b)].slice(0, 12).map(x => x.toString(16).padStart(2, "0")).join("");
}
const NICK = /^[\p{L}\p{N}_ .\-]{2,16}$/u;
const OWNER = /^[0-9a-f]{32}$/;
const MIN_DUR = 5, MAX_DUR = 190; // daily level: 120 s + revive bonus
export default {
  async fetch(req, env) {
    const url = new URL(req.url);
    if (url.pathname.startsWith("/api/")) {
      if (req.method === "OPTIONS") return new Response(null, { headers: CORS });
      if (url.pathname === "/api/daily" && req.method === "GET") {
        const day = url.searchParams.get("day") || trDay();
        if (!/^\d{4}-\d{2}-\d{2}$/.test(day)) return json({ error: "day" }, 400);
        const r = await env.DB.prepare("SELECT nick, score FROM scores WHERE day=? ORDER BY score ASC, ts ASC LIMIT 50").bind(day).all();
        return json(r.results || []);
      }
      if (url.pathname === "/api/score" && req.method === "POST") {
        let b;
        try { b = await req.json(); } catch { return json({ error: "json" }, 400); }
        const day = String(b.day || ""), nick = String(b.nick || "").trim(), score = Number(b.score);
        if (day !== trDay() && day !== trDay(1)) return json({ error: "day" }, 400);
        if (!NICK.test(nick)) return json({ error: "nick" }, 400);
        if (!Number.isInteger(score) || score < 1 || score > 5000) return json({ error: "score" }, 400);
        const owner = String(b.owner || ""), dur = Number(b.dur);
        if (!OWNER.test(owner)) return json({ error: "owner" }, 400);
        if (!Number.isFinite(dur) || dur < MIN_DUR || dur > MAX_DUR) return json({ error: "dur" }, 400);
        const k = await sha((req.headers.get("CF-Connecting-IP") || "x") + "|" + day + "|rr");
        const rl = await env.DB.prepare("INSERT INTO rl(day,k,n) VALUES(?,?,1) ON CONFLICT(day,k) DO UPDATE SET n=n+1 RETURNING n").bind(day, k).first();
        if (rl && rl.n > 20) return json({ error: "limit" }, 429);
        const oh = await sha(owner + "|rr-owner");
        const key = nick.toLocaleLowerCase("tr");
        const own = await env.DB.prepare("INSERT INTO nicks(nick_key,owner) VALUES(?,?) ON CONFLICT(nick_key) DO UPDATE SET owner=owner RETURNING owner").bind(key, oh).first();
        if (!own || own.owner !== oh) return json({ error: "nick_taken" }, 409);
        await env.DB.prepare("INSERT INTO scores(day,nick,score,ts) VALUES(?,?,?,?) ON CONFLICT(day,nick) DO UPDATE SET score=MIN(score, excluded.score), ts=CASE WHEN excluded.score < score THEN excluded.ts ELSE ts END").bind(day, nick, score, Date.now()).run();
        return json({ ok: true });
      }
      return json({ error: "not found" }, 404);
    }
    if (url.pathname.endsWith("/index.wasm")) {
      const r = await env.ASSETS.fetch(new Request(new URL("/index.wasm.gz", url), req));
      return new Response(r.body, { status: r.status, encodeBody: "manual",
        headers: { "Content-Type": "application/wasm", "Content-Encoding": "gzip", "Cache-Control": "public, max-age=3600" } });
    }
    return env.ASSETS.fetch(req);
  }
};
