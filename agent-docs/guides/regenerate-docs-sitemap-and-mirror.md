# How to Regenerate the Docs Mirror and Sitemap

Use this when you need to rebuild the static docs HTML, versioned code mirror, and discovery files.

1. Change into `docs/` and make sure the repository has tags available locally, because `make mirror` reads the last three `v*` tags from the parent repo.
2. Run `make all` to regenerate `.html` pages, mirror source into `code/<tag>/`, and write `sitemap.xml` plus `llms.txt`.
3. If you only need the mirror and discovery files, run `make deploy` instead of `make all`.
4. Inspect `docs/code/`, `docs/sitemap.xml`, and `docs/llms.txt` to confirm the expected files were produced.
5. Verify the generated HTML by opening `docs/index.html` and other regenerated pages, or by checking `git diff --stat` for the expected updates.
6. Confirm the work is complete with `git diff --exit-code -- docs/*.html docs/sitemap.xml docs/llms.txt`; if you want to confirm the ignored mirror exists too, run `git status --short --ignored docs/code`.
