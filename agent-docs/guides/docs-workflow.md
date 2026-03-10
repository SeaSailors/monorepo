# Guide: Docs Site Maintenance & Deployment

This guide covers the common workflows for maintaining the Commonware documentation site and ensuring the source code mirror is up-to-date.

## Prerequisites

- **Pandoc**: Required for converting Markdown to HTML.
- **Python 3**: Required for sitemap and manifest generation.
- **GNU Make**: Orchestrates the build process.

## Common Workflows

### 1. Authoring New Documentation
1. Create or edit a Markdown file in `docs/` (e.g., `docs/blogs/my-new-post.md`).
2. Run the build command from the `docs/` directory:
   ```bash
   make markdown
   ```
3. Verify the generated `.html` file.

### 2. Updating the Source Code Mirror
The mirror is generated from git tags. To reflect new releases:
1. Ensure the new version is tagged in git (e.g., `git tag v0.0.66`).
2. Run the mirror target from the `docs/` directory:
   ```bash
   make mirror
   ```
   *Note: This will fetch tags from origin and extract the last 3 versions.*

### 3. Regenerating Manifests
If files are added or the mirror is updated, the sitemap must be refreshed:
1. Run the sitemap target from the `docs/` directory:
   ```bash
   make sitemap
   ```
   *This updates both `docs/sitemap.xml` and `docs/llms.txt`.*

### 4. Full Build for Deployment
To perform a complete build (mirror + sitemap):
```bash
make deploy
```

## Deployment Verification

The CI/CD pipeline (`.github/workflows/fast.yml`) includes a `Docs` job that verifies build stability:
- It runs `make` in the `docs/` directory.
- It fails if `git diff` shows any changes to tracked artifacts.

**Critical**: Always run `make deploy` and commit changes before pushing if you have modified documentation or added new release tags.

## Troubleshooting

- **Missing Files in Mirror**: Ensure the files are tracked by git in the respective tag and that the extension is included in `generate_sitemap.py`'s whitelist (`.rs`, `.md`, `.toml`).
- **Sitemap URLs**: The `generate_sitemap.py` script assumes the site is hosted at `https://commonware.xyz`. If the base URL changes, update `BASE_URL` in the script.
- **MathJax Rendering**: Ensure the `template.html` is properly referenced during the `pandoc` build.
