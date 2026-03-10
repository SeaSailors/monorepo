# Reference: MCP Tool API

The Commonware MCP server (`https://mcp.commonware.xyz`) exposes the following tools for AI clients.

## list_versions
List all repository versions currently indexed and available for retrieval.
- **Input**: None
- **Output**: Markdown list of version tags (e.g., `v0.0.64`).

## list_crates
List all crates in the workspace for a given version.
- **Arguments**:
  - `version` (optional): Version tag. Defaults to latest.
- **Output**: List of crate names, their repository paths, and descriptions parsed from `Cargo.toml`.

## list_files
List files within a crate or directory.
- **Arguments**:
  - `crate` (optional): Crate name (e.g., `commonware-p2p`) or directory path. If omitted, lists top-level directories.
  - `version` (optional): Version tag. Defaults to latest.
- **Output**: ASCII tree of files and directories.

## search_code
Perform ranked full-text search across source code.
- **Arguments**:
  - `query`: Search string.
  - `mode` (optional): `substring` (default, min 3 chars) or `word` (word/prefix matching).
  - `crate` (optional): Limit search to a specific crate.
  - `file_type` (optional): `rs` (default), `md`, `toml`, or `all`.
  - `version` (optional): Version tag.
  - `max_results` (optional): Number of results (default 10, max 50).
- **Output**: Ranked snippets with context and 0-indexed line numbers.

## get_file
Retrieve raw file content with line numbers.
- **Arguments**:
  - `path`: Repo-relative path (e.g., `consensus/src/lib.rs`).
  - `version` (optional): Version tag.
  - `start_line` (optional): 0-indexed start line (inclusive).
  - `end_line` (optional): 0-indexed end line (inclusive).
- **Output**: Markdown code block. Line numbers align with `search_code`.

## get_crate_readme
Fetch the primary documentation for a specific crate.
- **Arguments**:
  - `crate`: Full crate name (e.g., `commonware-cryptography`).
  - `version` (optional): Version tag.
- **Output**: Raw markdown of the crate's `README.md`.

## get_overview
Fetch the root repository README.
- **Input**: None
- **Output**: Detailed overview of repository structure and design principles.
