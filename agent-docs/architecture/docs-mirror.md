# Architecture: Docs Site & Code Mirror

Commonware's documentation infrastructure is a dual-purpose system that serves both human-readable content and a machine-accessible repository mirror for the Model Context Protocol (MCP) server.

## Overview

The system consists of three main components:
1. **Static Site (`docs/`)**: Authored content and build automation.
2. **Code Mirror (`docs/code/`)**: Versioned snapshots of the repository source code.
3. **Discovery Manifests**: `sitemap.xml` and `llms.txt` for machine discovery.

## Data Flow

```
[ Git Tags ] -> [ docs/makefile ] -> [ docs/code/<tag>/ ]
                               |
                               v
                       [ generate_sitemap.py ] -> [ sitemap.xml ]
                               |               -> [ llms.txt ]
                               v
                       [ Cloudflare Pages ] <- [ MCP Server ]
```

## Component Details

### Static Site Generation
- **Markdown Processing**: Documentation (blogs, deep dives) is authored in Markdown within `docs/`.
- **Pandoc Integration**: A `makefile` uses `pandoc` with a unified `template.html` to convert Markdown to standalone HTML pages with MathJax support.
- **Assets**: CSS, JS, and images are served as static assets.

### Code Mirror Generation
- **Versioning**: The system tracks the last 3 semver-compliant git tags (`v*`).
- **Archive Extraction**: For each tracked tag, `git archive` extracts a snapshot of the repository into `docs/code/<tag>/`.
- **Filtering**: The mirror specifically includes source files (`.rs`, `.toml`) and documentation (`.md`).

### Machine Discovery (sitemap.xml & llms.txt)
- **Sitemap**: A Python script (`generate_sitemap.py`) crawls the `docs/` directory and the generated `code/` mirror to produce a comprehensive `sitemap.xml`. This enables the MCP server to discover versioned files.
- **llms.txt**: Provides an LLM-optimized entry point for the repository, advertising the availability of the MCP server and key architectural concepts.

## MCP Server Integration

The documentation site serves as the "source of truth" for the MCP server (`mcp/`):
- **Indexing**: The MCP server periodically fetches `sitemap.xml` to discover new versions and files.
- **Retrieval**: MCP tools like `get_file` and `search_code` retrieve content directly from the `docs/code/<tag>/` mirror.
- **Independence**: The MCP server (Node/Cloudflare Worker) does not require a Rust toolchain; it operates entirely on the static artifacts published by the docs site.
