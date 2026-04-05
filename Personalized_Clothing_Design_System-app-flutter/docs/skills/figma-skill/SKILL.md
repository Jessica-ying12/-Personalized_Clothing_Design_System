---
name: figma-skill
description: >
  MUST USE whenever a Figma URL (figma.com/design/*, figma.com/file/*, figma.com/proto/*)
  appears in user input — activate IMMEDIATELY, no confirmation needed.
  Also trigger on any mention of "Figma" with design/UI/implementation intent.
  Extracts design data (layout, styling, content, components) and downloads images
  via Figma REST API directly (bundled TypeScript scripts via npx tsx, no MCP server needed).
  Triggers: figma.com URL, ?node-id=, "Figma", "implement design", "get Figma data",
  "extract from Figma", "download Figma images", "这个Figma", "Figma里面".
---

# Figma Skill

Extract Figma design data and download images by calling the Figma REST API directly through bundled scripts.

## First-Use Gate (MANDATORY)

**On every activation, BEFORE doing anything else, check if `.env` exists in the skill root:**

1. Check if `.env` exists and contains a non-empty `FIGMA_API_KEY`.
2. **If YES** → skip to "Scripts" and proceed with user's request.
3. **If NO** → execute the setup flow:
   - Tell the user: "Figma Skill 尚未配置，需要先完成初始化。请提供你的 Figma API Key（在 https://help.figma.com/hc/en-us/articles/8085703771159-Manage-personal-access-tokens 创建）。"
   - Wait for user to provide the API key.
   - Run: `npx tsx scripts/setup-config.ts <API_KEY>`
   - This will: run connectivity test → if passed, save `.env`.
   - If the script exits with error → show the error, help user fix it, re-run.
   - **Do NOT proceed until setup completes successfully.**

## Scripts

All scripts read `FIGMA_API_KEY` from `.env` (or `FIGMA_API_KEY` env var).

### `get-figma-data.ts` — Fetch design data

```bash
npx tsx scripts/get-figma-data.ts --file-key <KEY> [--node-id <ID>] [--depth <N>] [--raw]
```

| Argument | Required | Description |
|----------|----------|-------------|
| `--file-key` | ✅ | Figma file key from URL |
| `--node-id` | ❌ | Specific node ID (format: `1234:5678` or `1234-5678`) |
| `--depth` | ❌ | Limit tree traversal depth |
| `--raw` | ❌ | Output raw Figma API response without simplification |

Returns simplified node tree (JSON) with: id, name, type, bounds, fills, strokes, effects, text content, layout properties, and component info.

### `download-figma-images.ts` — Download images

```bash
npx tsx scripts/download-figma-images.ts --file-key <KEY> --node-ids <ID1,ID2,...> --output-dir <DIR> [--format png|svg] [--scale 2]
```

| Argument | Required | Description |
|----------|----------|-------------|
| `--file-key` | ✅ | Figma file key |
| `--node-ids` | ✅ | Comma-separated node IDs |
| `--output-dir` | ✅ | Local directory to save images |
| `--format` | ❌ | `png` (default) or `svg` |
| `--scale` | ❌ | PNG export scale (default 2) |

### `test-figma-connection.ts` — Connectivity test

```bash
npx tsx scripts/test-figma-connection.ts <API_KEY>
```

Checks: Node.js version, npx, API key validity (`/v1/me`).

### `setup-config.ts` — Initialize configuration

```bash
npx tsx scripts/setup-config.ts <API_KEY>
```

Runs connectivity test → saves `.env` with the API key.

## Parsing Figma URLs

Extract parameters from Figma URLs before calling scripts:

- `figma.com/design/<fileKey>/<name>` → `--file-key <fileKey>`
- URL param `?node-id=445-1676` → convert `-` to `:` → `--node-id 445:1676`

## Typical Workflow

1. User pastes Figma link
2. Parse URL to extract `fileKey` and optional `nodeId`
3. Run `get-figma-data.ts` to fetch simplified design data
4. Use returned layout/style/content to generate code
5. If images are needed, run `download-figma-images.ts` with relevant node IDs

## Troubleshooting

**"FIGMA_API_KEY not set"** → Run `npx tsx scripts/setup-config.ts <KEY>` first.

**403 Forbidden** → Token expired or lacks permission. Regenerate at Figma account settings.

**Empty nodes** → Verify `nodeId` format. Use `--raw` flag to inspect the full API response.

**Timeout on large files** → Use `--node-id` to target specific frames. Use `--depth` to limit traversal.

For detailed Figma REST API reference, see [references/figma-api.md](references/figma-api.md).
