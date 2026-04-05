# Figma REST API Reference

Base URL: `https://api.figma.com/v1`

Auth header: `X-Figma-Token: <PERSONAL_ACCESS_TOKEN>`

## Endpoints Used by This Skill

### GET /me

Verify token validity. Returns user info.

### GET /files/{fileKey}

Fetch entire file structure.

| Param | Type | Description |
|-------|------|-------------|
| `depth` | query, number | Limit tree traversal depth |

### GET /files/{fileKey}/nodes?ids={nodeId}

Fetch specific node(s).

| Param | Type | Description |
|-------|------|-------------|
| `ids` | query, string | Comma-separated node IDs (`:` format) |
| `depth` | query, number | Limit tree traversal depth |

### GET /images/{fileKey}

Render nodes as images and return download URLs.

| Param | Type | Description |
|-------|------|-------------|
| `ids` | query, string | Comma-separated node IDs |
| `format` | query, string | `png`, `svg`, `jpg`, `pdf` |
| `scale` | query, number | Image scale (0.01–4, PNG/JPG only) |

Returns `{ "images": { "<nodeId>": "<url>" } }`.

### GET /files/{fileKey}/images

Get download URLs for image fills (raster images used as fills in the design).

Returns `{ "meta": { "images": { "<imageRef>": "<url>" } } }`.

## Simplified Node Schema

The `get-figma-data.py` script simplifies Figma API responses into:

```json
{
  "id": "445:1676",
  "name": "Frame Name",
  "type": "FRAME",
  "bounds": { "x": 0, "y": 0, "w": 1440, "h": 900 },
  "fills": [{ "type": "SOLID", "color": { "r": 1, "g": 1, "b": 1, "a": 1 } }],
  "strokes": [],
  "effects": [],
  "layoutMode": "VERTICAL",
  "itemSpacing": 16,
  "paddingLeft": 24,
  "children": [...]
}
```

Extracted properties: id, name, type, bounds, fills, strokes, effects, cornerRadius, opacity, layout (auto-layout mode, spacing, padding, alignment), constraints, componentId, componentProperties, text content and style.

## Rate Limits

Figma API rate limit: ~30 requests/minute per token. The scripts use single requests per invocation, but avoid rapid repeated calls on large files.
