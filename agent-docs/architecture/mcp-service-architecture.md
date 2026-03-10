# MCP Service Architecture

## 1. Identity

- **What it is:** A standalone TypeScript/Cloudflare Workers MCP server for the Commonware Library.
- **Purpose:** Provide version-pinned access to source code, crate metadata, repository overviews, and search results for AI clients.

## 2. Core Components

- `mcp/package.json` (scripts, dependencies): Defines the Node/TypeScript toolchain plus the local build, lint, test, and deploy commands.
- `mcp/wrangler.jsonc` (`CommonwareMCP`, `SEARCH_DB`, cron): Binds the Durable Object, D1 search database, base URL, and scheduled reindexing trigger.
- `mcp/migrations/0001_create_search_index.sql` (`files`, FTS tables, triggers, `versions`): Stores versioned file content and full-text search indexes in D1.
- `mcp/src/index.ts` (`CommonwareMCP`, tool registrations): Implements `get_file`, `search_code`, `list_versions`, `list_crates`, `get_crate_readme`, `get_overview`, and `list_files`.
- `mcp/src/utils.ts` (`parseSitemap`, `parseWorkspaceMembers`, `parseCrateInfo`): Parses sitemap and Cargo metadata into version and crate mappings.
- `mcp/integration-test.mjs` (`testCors`, `testServerInfo`, `testMcpTools`, `testLineNumberAlignment`): End-to-end verification for transport, indexing, and tool output alignment.
- `mcp/README.md` (Development, Deploy, Tools): Local setup, inspector usage, and deployment notes.
- `docs/makefile`, `docs/generate_sitemap.py`, `docs/mcp.html`: Produce the mirrored code index and provide a browser-based MCP client.

## 3. Execution Flow (LLM Retrieval Map)

- **1. Mirror content:** The docs pipeline mirrors tagged releases into `docs/code/<tag>/` and generates `sitemap.xml` plus `llms.txt`.
- **2. Index versions:** `CommonwareMCP` reads sitemap/version data and stores file bodies plus metadata in the D1 search database.
- **3. Serve tools:** The server exposes file retrieval, code search, version listing, crate listing, README retrieval, repository overview, and directory listing.
- **4. Verify locally:** `mcp/integration-test.mjs` triggers scheduled indexing, connects over Streamable HTTP, and checks CORS, server info, and tool outputs.

## 4. Design Rationale

Version pinning keeps retrieval aligned with a known repository snapshot instead of moving `main`. D1 full-text search reduces the need for ad hoc browsing, while crate metadata and README fetches give LLM clients enough context to navigate the workspace.
