# Docs Publishing Pipeline

## 1. Identity

- **What it is:** The static-site and artifact-generation pipeline that publishes the Commonware documentation site and LLM-friendly mirrors.
- **Purpose:** Keep public docs, versioned source mirrors, sitemap discovery, and the MCP landing page aligned.

## 2. Core Components

- `docs/makefile:1-42` (`markdown`, `mirror`, `sitemap`, `deploy`, `all`): Regenerates HTML pages, mirrors the last three release tags, and writes sitemap artifacts.
- `docs/generate_sitemap.py:1-117` (`get_versions`, `collect_html`, `collect_code`, `write_llms_txt`): Builds deterministic `sitemap.xml` and `llms.txt` from the docs tree and mirrored code.
- `docs/index.html:1-188` (site index): Public landing page for primitives, examples, and blog links.
- `docs/mcp.html:1-220` (MCP client page): Browser client and instructions for the MCP endpoint.
- `docs/_headers`: Sets content types for `/sitemap.xml`, `/llms.txt`, and mirrored source files.
- `docs/.gitignore`: Excludes generated mirror and sitemap artifacts from source control.

## 3. Execution Flow (LLM Retrieval Map)

- **1. Build pages:** `docs/makefile markdown` turns every markdown file into a sibling `.html` page using `template.html`.
- **2. Mirror versions:** `docs/makefile mirror` fetches the last three `v*` tags from the repo and archives them into `docs/code/<tag>/`.
- **3. Generate discovery files:** `docs/makefile sitemap` runs `docs/generate_sitemap.py`, which writes `sitemap.xml` and `llms.txt`.
- **4. Serve static assets:** Cloudflare Pages uses `_headers` to serve mirrored source and metadata files with text-friendly content types.
- **5. Feed retrieval:** The MCP service and browser MCP page rely on the versioned mirror and sitemap outputs for discovery.

## 4. Design Rationale

The site is built so both humans and LLM clients can discover the same source-of-truth artifacts. Versioned mirrors ensure retrieval stays aligned with release tags instead of unstable repository head state.
