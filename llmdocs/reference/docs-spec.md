# Reference: Documentation Build Specifications

This document defines the technical specifications for the documentation build system.

## Makefile Targets (`docs/makefile`)

| Target | Description | Dependencies |
|--------|-------------|--------------|
| `all` | Default target; builds markdown and sitemap. | `markdown`, `sitemap` |
| `markdown` | Converts `.md` to `.html`. | `template.html`, `pandoc` |
| `mirror` | Regenerates `docs/code/` from last 3 git tags. | `git`, `tar` |
| `sitemap` | Generates `sitemap.xml` and `llms.txt`. | `generate_sitemap.py` |
| `deploy` | Prepares site for deployment. | `mirror`, `sitemap` |
| `clean` | Removes generated code mirror. | N/A |

## File Whitelist for Code Mirror

Only files matching these extensions are included in the versioned sitemap (`generate_sitemap.py`):
- `.rs` (Rust source)
- `.md` (Markdown documentation)
- `.toml` (Project/Workspace configuration)

## Manifest Specifications

### sitemap.xml
- **Base URL**: `https://commonware.xyz`
- **Exclusions**: `docs/code/` is crawled, but URLs are transformed to the site root.
- **Extensions**: HTML files are listed without the `.html` extension (Cloudflare Pages clean URLs).

### llms.txt
- **Purpose**: High-level onboarding for Large Language Models.
- **Content**: Highlights versioned code access and the MCP server endpoint.

## Cloudflare Pages Configuration

The site behavior is influenced by `docs/_headers`:
- **Content-Type Overrides**: Ensures `/sitemap.xml`, `/robots.txt`, and `/llms.txt` are served with correct MIME types.
- **Source Code Serving**: Sets `text/plain` or appropriate types for `.rs` and `.toml` files in the code mirror.
