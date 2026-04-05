import https from "https";
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

interface SimplifiedNode {
  id: string;
  name: string;
  type: string;
  [key: string]: any;
}

function simplifyNode(node: any, maxDepth?: number, depth = 0): SimplifiedNode {
  const result: SimplifiedNode = {
    id: node.id,
    name: node.name,
    type: node.type,
  };

  const bbox = node.absoluteBoundingBox;
  if (bbox) result.bounds = { x: bbox.x, y: bbox.y, w: bbox.width, h: bbox.height };

  if (node.type === "TEXT") {
    result.characters = node.characters || "";
    const s = node.style;
    if (s) {
      result.textStyle = Object.fromEntries(
        ["fontFamily", "fontSize", "fontWeight", "lineHeightPx", "letterSpacing", "textAlignHorizontal"]
          .filter((k) => k in s).map((k) => [k, s[k]])
      );
    }
  }

  const fills = (node.fills || []).filter((f: any) => f.visible !== false);
  if (fills.length) {
    result.fills = fills.map((f: any) =>
      Object.fromEntries(["type", "color", "opacity", "imageRef", "scaleMode"].filter((k) => k in f).map((k) => [k, f[k]]))
    );
  }

  const strokes = (node.strokes || []).filter((s: any) => s.visible !== false);
  if (strokes.length) {
    result.strokes = strokes.map((s: any) =>
      Object.fromEntries(["type", "color", "opacity"].filter((k) => k in s).map((k) => [k, s[k]]))
    );
    if (node.strokeWeight) result.strokeWeight = node.strokeWeight;
  }

  const effects = (node.effects || []).filter((e: any) => e.visible !== false);
  if (effects.length) {
    result.effects = effects.map((e: any) =>
      Object.fromEntries(["type", "radius", "offset", "color", "spread"].filter((k) => k in e).map((k) => [k, e[k]]))
    );
  }

  for (const prop of [
    "cornerRadius", "opacity", "layoutMode", "itemSpacing",
    "paddingLeft", "paddingRight", "paddingTop", "paddingBottom",
    "primaryAxisAlignItems", "counterAxisAlignItems",
    "layoutGrow", "layoutAlign", "constraints",
    "componentId", "componentProperties",
  ]) {
    if (prop in node) result[prop] = node[prop];
  }

  const children: any[] = node.children || [];
  if (children.length && (maxDepth === undefined || depth < maxDepth)) {
    result.children = children.map((c) => simplifyNode(c, maxDepth, depth + 1));
  } else if (children.length) {
    result.childCount = children.length;
  }

  return result;
}

function parseArgs(argv: string[]) {
  const args: Record<string, string | boolean> = {};
  for (let i = 2; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === "--raw") { args.raw = true; continue; }
    if (arg.startsWith("--") && i + 1 < argv.length) {
      args[arg.slice(2)] = argv[++i];
    }
  }
  return args;
}

async function main(): Promise<void> {
  const args = parseArgs(process.argv);
  const fileKey = args["file-key"] as string;
  const nodeId = args["node-id"] as string | undefined;
  const depth = args["depth"] ? parseInt(args["depth"] as string, 10) : undefined;
  const raw = !!args.raw;

  if (!fileKey) {
    console.error("用法: npx tsx scripts/get-figma-data.ts --file-key <KEY> [--node-id <ID>] [--depth <N>] [--raw]");
    process.exit(1);
  }

  const apiKey = loadApiKey();
  if (!apiKey) {
    console.error('FIGMA_API_KEY 未设置。请先运行: npx tsx scripts/setup-config.ts <KEY>');
    process.exit(1);
  }

  let output: any;

  if (nodeId) {
    const nid = nodeId.replace(/-/g, ":");
    let endpoint = `/files/${fileKey}/nodes?ids=${nid}`;
    if (depth) endpoint += `&depth=${depth}`;
    const data = await apiGet(endpoint, apiKey);
    if (raw) {
      output = data;
    } else {
      const nodes = data.nodes || {};
      output = {
        fileName: data.name || "",
        nodes: Object.values(nodes)
          .filter((v: any) => v?.document)
          .map((v: any) => simplifyNode(v.document, depth)),
      };
    }
  } else {
    let endpoint = `/files/${fileKey}`;
    if (depth) endpoint += `?depth=${depth}`;
    const data = await apiGet(endpoint, apiKey);
    if (raw) {
      output = data;
    } else {
      output = {
        fileName: data.name || "",
        lastModified: data.lastModified || "",
        nodes: (data.document?.children || []).map((c: any) => simplifyNode(c, depth)),
      };
    }
  }

  console.log(JSON.stringify(output, null, 2));
}

main().catch((e) => { console.error(e.message); process.exit(1); });
