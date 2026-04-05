import https from "https";
import http from "http";
import fs from "fs";
import path from "path";

const SKILL_DIR = path.resolve(path.dirname(new URL(import.meta.url).pathname), "..");

function loadApiKey(): string {
  if (process.env.FIGMA_API_KEY) return process.env.FIGMA_API_KEY;
  const envFile = path.join(SKILL_DIR, ".env");
  if (fs.existsSync(envFile)) {
    const match = fs.readFileSync(envFile, "utf-8").match(/^FIGMA_API_KEY=(.+)$/m);
    if (match) return match[1].trim().replace(/^["']|["']$/g, "");
  }
  return "";
}

function apiGet(endpoint: string, apiKey: string): Promise<any> {
  return new Promise((resolve, reject) => {
    https.get({
      hostname: "api.figma.com",
      path: `/v1${endpoint}`,
      headers: { "X-Figma-Token": apiKey },
    }, (res) => {
      let body = "";
      res.on("data", (chunk: Buffer) => { body += chunk.toString(); });
      res.on("end", () => {
        if (res.statusCode !== 200) {
          reject(new Error(`HTTP ${res.statusCode}: ${body}`));
          return;
        }
        try { resolve(JSON.parse(body)); }
        catch { reject(new Error(`Invalid JSON: ${body.slice(0, 200)}`)); }
      });
    }).on("error", reject);
  });
}

function downloadFile(url: string, dest: string): Promise<void> {
  return new Promise((resolve, reject) => {
    const client = url.startsWith("https") ? https : http;
    client.get(url, (res) => {
      if (res.statusCode === 301 || res.statusCode === 302) {
        if (res.headers.location) return downloadFile(res.headers.location, dest).then(resolve, reject);
        return reject(new Error(`Redirect without location`));
      }
      const ws = fs.createWriteStream(dest);
      res.pipe(ws);
      ws.on("finish", () => { ws.close(); resolve(); });
      ws.on("error", reject);
    }).on("error", reject);
  });
}

function parseArgs(argv: string[]) {
  const args: Record<string, string> = {};
  for (let i = 2; i < argv.length; i++) {
    const arg = argv[i];
    if (arg.startsWith("--") && i + 1 < argv.length) {
      args[arg.slice(2)] = argv[++i];
    }
  }
  return args;
}

async function main(): Promise<void> {
  const args = parseArgs(process.argv);
  const fileKey = args["file-key"];
  const nodeIdsRaw = args["node-ids"];
  const outputDir = args["output-dir"];
  const format = args["format"] || "png";
  const scale = parseFloat(args["scale"] || "2");

  if (!fileKey || !nodeIdsRaw || !outputDir) {
    console.error("用法: npx tsx scripts/download-figma-images.ts --file-key <KEY> --node-ids <ID1,ID2,...> --output-dir <DIR> [--format png|svg] [--scale 2]");
    process.exit(1);
  }

  const apiKey = loadApiKey();
  if (!apiKey) {
    console.error('FIGMA_API_KEY 未设置。请先运行: npx tsx scripts/setup-config.ts <KEY>');
    process.exit(1);
  }

  const nodeIds = nodeIdsRaw.split(",").map((id) => id.trim().replace(/-/g, ":"));
  let endpoint = `/images/${fileKey}?ids=${nodeIds.join(",")}&format=${format}`;
  if (format === "png") endpoint += `&scale=${scale}`;

  const result = await apiGet(endpoint, apiKey);
  const images: Record<string, string | null> = result.images || {};

  fs.mkdirSync(outputDir, { recursive: true });

  const downloaded: { nodeId: string; file: string; format: string }[] = [];

  for (const [nodeId, imgUrl] of Object.entries(images)) {
    if (!imgUrl) {
      console.error(`⚠️  No image URL for node ${nodeId}`);
      continue;
    }
    const safeName = nodeId.replace(/:/g, "-");
    const filename = `${safeName}.${format}`;
    const dest = path.join(outputDir, filename);
    try {
      await downloadFile(imgUrl, dest);
      downloaded.push({ nodeId, file: dest, format });
    } catch (e: any) {
      console.error(`⚠️  Failed to download node ${nodeId}: ${e.message}`);
    }
  }

  console.log(JSON.stringify({ downloaded, total: downloaded.length }, null, 2));
}

main().catch((e) => { console.error(e.message); process.exit(1); });
