# How to Run the MCP Service Locally

A concise path for bringing up the Commonware MCP server on localhost and checking that indexing and tool calls work end to end.

1. Change into the MCP project and install dependencies:
   `cd mcp && npm install`
2. Apply the local D1 schema so the search index exists:
   `npx wrangler d1 migrations apply commonware-mcp-search --local`
3. Start the development server:
   `npm run dev`
4. In a second terminal, trigger scheduled indexing and wait for data to appear:
   `curl "http://localhost:8787/__scheduled?cron=*"`
5. Open the MCP inspector or another MCP client and connect with Streamable HTTP:
   `npx @modelcontextprotocol/inspector@latest`, then use `http://localhost:8787` and Direct mode.
6. Call `list_versions`, `search_code`, and `get_file` from the inspector to confirm the server is serving indexed content.
7. Final verification: run the integration script against localhost and expect it to finish with `✓ All integration tests passed!`
   `MCP_URL=http://localhost:8787 node integration-test.mjs`
