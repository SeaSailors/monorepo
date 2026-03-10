# Guide: MCP Development Workflow

This guide covers the common workflows for developing, testing, and deploying the Commonware MCP server.

## Prerequisites
- Node.js 18+
- Cloudflare Account + Wrangler CLI (`npm install -g wrangler`)
- Access to the `commonware.xyz` environment (for sitemap/mirror testing)

## Local Development

### 1. Environment Setup
Install dependencies and prepare the local database:
```bash
cd mcp
npm install
npx wrangler d1 migrations apply commonware-mcp-search --local
```

### 2. Start the Dev Server
```bash
npm run dev
```
The server runs at `http://localhost:8787`.

### 3. Populating the Index
Local instances start with an empty database. Trigger the indexing cron manually:
```bash
curl "http://localhost:8787/__scheduled?cron=*"
```
The Worker will parse `https://commonware.xyz/sitemap.xml` and begin downloading file contents to your local SQLite instance.

## Testing

### Unit Tests
Run Vitest for utility and parsing logic:
```bash
npm test
```

### Integration Tests
Verify the MCP protocol implementation over Streamable HTTP:
```bash
# Ensure dev server is running (npm run dev)
node integration-test.mjs
```

### Interactive Debugging
Use the MCP Inspector to manually invoke tools:
```bash
npx @modelcontextprotocol/inspector@latest
```
- Transport: **Streamable HTTP**
- URL: `http://localhost:8787`
- Mode: **Direct**

## Deployment

### 1. Database Creation (One-time)
```bash
npx wrangler d1 create commonware-mcp-search
# Copy the database_id into mcp/wrangler.jsonc
```

### 2. Schema Migration
```bash
npx wrangler d1 migrations apply commonware-mcp-search --remote
```

### 3. Deploy Worker
```bash
npm run deploy
```
The server will be live at `https://mcp.commonware.xyz`. Indexing will run automatically every 10 minutes via the configured `cron` trigger.

## Troubleshooting Indexing
If a new version is not appearing:
1. Verify the version tag (`v*`) exists in Git.
2. Ensure the `docs/` site has been deployed (this generates the sitemap and code mirror).
3. Check Cloudflare Worker logs: `npx wrangler tail`.
4. Manually trigger the cron (`scheduled` event) and watch for fetch errors.
