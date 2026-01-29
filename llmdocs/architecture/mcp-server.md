# Architecture: MCP Server

The Commonware MCP (Model Context Protocol) server provides a machine-readable interface to the repository's source code and documentation. It enables LLMs to fetch version-pinned code, search for patterns, and explore crate metadata without manual file traversal.

## Component Overview

The system is built on the Cloudflare stack and couples tightly with the static documentation site.

### 1. External Dependencies (Docs Site)
The MCP server does not have direct access to the Git repository. Instead, it relies on artifacts published by the `docs/` build pipeline:
- Sitemap: `https://commonware.xyz/sitemap.xml` (lists all available versions and files).
- Code Mirror: `https://commonware.xyz/code/<version>/<path>` (raw file contents).

### 2. Cloudflare Worker (Compute)
- Entrypoint: `mcp/src/index.ts`.
- Runtime: Cloudflare Workers with `McpAgent` (from Cloudflare Agents SDK).
- Transport: Streamable HTTP (supporting SSE for real-time tool execution).

### 3. Durable Objects (Session Management)
- Binding: `MCP`.
- Responsibility: Maintains persistent state for MCP client sessions, ensuring consistent tool execution and resource handling.

### 4. Cloudflare D1 (Database)
- Binding: `SEARCH_DB`.
- Tables:
  - `versions`: Tracks successfully indexed semver tags (v*).
  - `files`: Stores `(version, path, content)` for indexed source files.
- Search Engine: SQLite FTS5 with two virtual tables:
  - `files_fts_substring`: Uses `trigram` tokenizer for literal substring queries (min 3 chars).
  - `files_fts_word`: Uses `unicode61` tokenizer for word and prefix matching.

### 5. Indexing Pipeline (Cron)
- Trigger: Periodic `scheduled` event (every 10 minutes).
- Workflow:
  1. Fetch and parse the remote `sitemap.xml`.
  2. Identify the newest version in the sitemap not yet present in D1.
  3. Batch-fetch file contents from the code mirror.
  4. Upsert files into D1 (triggering FTS re-indexing).
  5. Prune versions removed from the sitemap.
- Note: To avoid Worker timeouts, only one version is indexed or pruned per scheduled run.

## Data Flow: Code Search

1. Client (e.g., Claude) calls `search_code(query="BLS", mode="substring")`.
2. Worker receives request and identifies the latest indexed version.
3. Worker executes a FTS5 `MATCH` query against `files_fts_substring`.
4. Results are ranked by `bm25()`.
5. For each match, the Worker extracts non-overlapping snippets with 5 lines of context.
6. Worker returns formatted markdown containing snippets and file paths.

## Data Flow: File Retrieval

1. Client calls `get_file(path="cryptography/src/lib.rs", start_line=10, end_line=50)`.
2. Worker fetches the raw file from the static mirror (`commonware.xyz/code/...`).
3. Worker slices the content to the requested line range.
4. Worker injects 0-indexed line numbers (aligning with `search_code` output).
5. Worker returns the block wrapped in a markdown code fence.
