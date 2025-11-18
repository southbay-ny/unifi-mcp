# UniFi Network MCP

Read-only Model Context Protocol (MCP) server that exposes UniFi Network controller data (sites, devices, clients, alarms, sysinfo) to AI coding tools. This repo contains the TypeScript source, specs, and per-agent configuration snippets required to self-host the MCP.

## Prerequisites

- Node.js 20+
- npm 10+
- A UniFi Network controller (UDM/UDR/UXG or UniFi OS gateway)
- An Integration API key generated from **UniFi Network → Settings → System → Integrations**
- `git` and a POSIX shell (macOS/Linux)

## Configure & Build

1. Clone and install:
   ```bash
   git clone https://github.com/southbay-ny/unifi-network-mcp.git
   cd unifi-network-mcp/servers/unifi-network-mcp
   npm install
   ```
2. Export `UNIFI_TARGETS` (single or multiple controllers). Example:
   ```bash
   export UNIFI_TARGETS='[
     {
       "id": "home",
       "base_url": "https://<unifi_host>",
       "controller_type": "unifi_os",
       "default_site": "default",
       "auth": { "apiKey": "UNIFI_API_KEY", "headerName": "X-API-KEY" },
       "verify_ssl": false,
       "timeout_ms": 20000,
       "rate_limit_per_sec": 5
     }
   ]'
   ```

   Key fields:

   - **id**: Friendly name for this UniFi target (e.g. `home`, `lab`). Use this `id` as `targetId` in MCP tool calls when you have more than one controller.
   - **base_url**: The base URL of your UniFi controller (e.g. `https://<unifi_host>`). This is the same URL you use to access the UniFi Network UI.
   - **auth.apiKey**: `UNIFI_API_KEY` obtained from **UniFi Network → Settings → System → Integrations** for the Network Application.
   - **default_site**: Default site to use when a tool call does not specify `site`. Often `Default`; if your controller uses a different site name, check the Integration API **Sites** endpoint in the Network App.

   Multiple targets are supported:

   ```bash
   export UNIFI_TARGETS='[
     { "id": "home", "base_url": "https://<unifi_host_home>", "controller_type": "unifi_os", "default_site": "Default", "auth": { "apiKey": "UNIFI_API_KEY_HOME", "headerName": "X-API-KEY" }, "verify_ssl": false, "timeout_ms": 20000, "rate_limit_per_sec": 5 },
     { "id": "lab",  "base_url": "https://<unifi_host_lab>",  "controller_type": "unifi_os", "default_site": "Default", "auth": { "apiKey": "UNIFI_API_KEY_LAB",  "headerName": "X-API-KEY" }, "verify_ssl": false, "timeout_ms": 20000, "rate_limit_per_sec": 5 }
   ]'
   ```

   - When **one** target is configured, MCP tools can omit `targetId` and will automatically use that single target.
   - When **multiple** targets are configured, pass `targetId` (e.g. `home` or `lab`) in the MCP tool arguments so the server knows which controller to use.

   Example tool calls (multi-target):
   - List sites on `home` (default site):
     - Conceptual args: `{ "targetId": "home" }`
   - Get devices from `lab` / `Default` site:
     - Conceptual args: `{ "targetId": "lab", "site": "Default" }`
   - With Codex CLI, for example:
     ```bash
     codex exec "call get_devices with targetId lab and site Default" --skip-git-repo-check
     ```

3. Build once (emits `dist/` artifacts shared by every tool below):
   ```bash
   npm run build
   ```

## Quick Install from Release

```bash
curl -L https://github.com/southbay-ny/unifi-network-mcp/releases/download/v0.1.0/unifi-network-mcp-v0.1.0.tar.gz | tar -xz -C ~/.local/share/
cd ~/.local/share/unifi-network-mcp
cp .env.example .env
# Edit .env with your UNIFI_TARGETS
```

## Common runtime command

All quickstarts use the same launch script, which validates `UNIFI_TARGETS`, builds on demand, and starts the MCP on STDIO:
```bash
cd /path/to/unifi-network-mcp
./run-mcp.sh
```
Leave this process running while your IDE/CLI talks to the MCP.

## Tool-specific quickstarts

### Windsurf / Cascade (npx)
1. In Windsurf: **Plugins → Model Context Protocol → Add MCP Server → Local Command**.
2. Command: `npx`
3. Arguments: `-y unifi-network-mcp`
4. Add env var `UNIFI_TARGETS` in the dialog (paste the JSON string) if not globally exported:
   ```
   [{"id":"home","base_url":"https://<unifi_host>","controller_type":"unifi_os","default_site":"Default","auth":{"apiKey":"UNIFI_API_KEY","headerName":"X-API-KEY"},"verify_ssl":false,"timeout_ms":20000,"rate_limit_per_sec":5}]
   ```
5. Save; Windsurf will fetch the MCP from npm automatically and expose the tools under *My MCP Servers*.

### Cursor (npx)
1. Create/update `.cursor/mcp.config.json` in your repo:
   ```json
   {
     "servers": [
       {
         "name": "unifi-network",
         "command": "npx",
         "args": ["-y", "unifi-network-mcp"],
         "env": {
           "UNIFI_TARGETS": "[{\"id\":\"home\",\"base_url\":\"https://<unifi_host>\",\"controller_type\":\"unifi_os\",\"default_site\":\"Default\",\"auth\":{\"apiKey\":\"UNIFI_API_KEY\",\"headerName\":\"X-API-KEY\"},\"verify_ssl\":false,\"timeout_ms\":20000,\"rate_limit_per_sec\":5}]"
         }
       }
     ]
   }
   ```
2. Reload Cursor (Cmd+Shift+P → "Reload Window"). Cursor will `npx` the MCP whenever needed.

### Codex (npx-based install)
1. Add this block to `~/.codex/config.toml`:
   ```toml
   [mcp_servers.unifi-network-mcp]
       command = "npx"
       args = ["-y", "unifi-network-mcp"]
       [mcp_servers.unifi-network-mcp.env]
           UNIFI_TARGETS = '[{"id":"home","base_url":"https://<unifi_host>","controller_type":"unifi_os","default_site":"Default","auth":{"apiKey":"UNIFI_API_KEY","headerName":"X-API-KEY"},"verify_ssl":false,"timeout_ms":20000,"rate_limit_per_sec":5}]'
   ```
   *Tip:* replace `<API_KEY>` and any controller metadata with your own values. Codex will download + cache the MCP automatically on first launch.
2. From any repo, run `codex exec list_sites --skip-git-repo-check` to confirm connectivity.

### Gemini CLI (npx)
1. Install the Google `gemini` CLI (Early Access) and enable MCP support.
2. Create `~/.gemini/mcp.yaml`:
   ```yaml
   servers:
     - name: unifi-network
       command: npx
       args:
         - -y
         - unifi-network-mcp
       env:
         UNIFI_TARGETS: "[{\"id\":\"home\",\"base_url\":\"https://<unifi_host>\",\"controller_type\":\"unifi_os\",\"default_site\":\"Default\",\"auth\":{\"apiKey\":\"UNIFI_API_KEY\",\"headerName\":\"X-API-KEY\"},\"verify_ssl\":false,\"timeout_ms\":20000,\"rate_limit_per_sec\":5}]"
   ```
3. Run `gemini mcp servers list` to confirm, then `gemini chat --use-mcp unifi-network`.

### Amazon Q CLI (npx)
1. Install the Amazon Q developer preview CLI.
2. Edit `~/.aws/amazonq/mcp.json`:
   ```json
   {
     "servers": [
       {
         "name": "unifi-network",
         "command": "npx",
         "args": ["-y", "unifi-network-mcp"],
         "env": {
           "UNIFI_TARGETS": "[{\"id\":\"home\",\"base_url\":\"https://<unifi_host>\",\"controller_type\":\"unifi_os\",\"default_site\":\"Default\",\"auth\":{\"apiKey\":\"UNIFI_API_KEY\",\"headerName\":\"X-API-KEY\"},\"verify_ssl\":false,\"timeout_ms\":20000,\"rate_limit_per_sec\":5}]"
         }
       }
     ]
   }
   ```
3. Launch Q CLI with `amazon-q chat --mcp unifi-network`.

### Opencode
1. Create or edit `~/.config/opencode/opencode.json`:
   ```json
   {
     "$schema": "https://opencode.ai/config.json",
     "mcp": {
       "unifi-network-mcp": {
         "type": "local",
         "command": ["npx", "-y", "unifi-network-mcp"],
         "enabled": true,
         "environment": {
           "UNIFI_TARGETS": "[{\"id\":\"home\",\"base_url\":\"https://<unifi_host>\",\"controller_type\":\"unifi_os\",\"default_site\":\"Default\",\"auth\":{\"apiKey\":\"UNIFI_API_KEY\",\"headerName\":\"X-API-KEY\"},\"verify_ssl\":false,\"timeout_ms\":20000,\"rate_limit_per_sec\":5}]"
         }
       }
     }
   }
   ```
2. Restart Opencode or reload configuration; the `unifi-network-mcp` server will be available in chats.

### Claude Code (Anthropic VS Code extension)
1. Open VS Code **Settings (JSON)** (Command Palette → "Preferences: Open Settings (JSON)").
2. Add or merge the following under the `claude.mcpServers` key:
   ```json
   "claude.mcpServers": {
     "unifi-network-mcp": {
       "command": "npx",
       "args": ["-y", "unifi-network-mcp"],
       "env": {
         "UNIFI_TARGETS": "[{\"id\":\"home\",\"base_url\":\"https://<unifi_host>\",\"controller_type\":\"unifi_os\",\"default_site\":\"Default\",\"auth\":{\"apiKey\":\"UNIFI_API_KEY\",\"headerName\":\"X-API-KEY\"},\"verify_ssl\":false,\"timeout_ms\":20000,\"rate_limit_per_sec\":5}]"
       }
     }
   }
   ```
3. Reload VS Code. Claude Code will launch the MCP via npm; verify with `@mcp unifi-network-mcp list_sites` in a Claude chat.

For **Claude terminal / global config** (outside VS Code), add the server to `~/.claude/settings.json`:

```json
{
  "mcpServers": {
    "unifi-network-mcp": {
      "command": "npx",
      "args": ["-y", "unifi-network-mcp"],
      "env": {
        "UNIFI_TARGETS": "[{\"id\":\"home\",\"base_url\":\"https://<unifi_host>\",\"controller_type\":\"unifi_os\",\"default_site\":\"Default\",\"auth\":{\"apiKey\":\"UNIFI_API_KEY\",\"headerName\":\"X-API-KEY\"},\"verify_ssl\":false,\"timeout_ms\":20000,\"rate_limit_per_sec\":5}]"
      }
    }
  }
}
```

After saving, restart Claude terminal or Desktop; the `unifi-network-mcp` server will be available there as well.

### GitHub Copilot Chat (npx)
You can extend GitHub Copilot Chat with this MCP by adding a local server configuration in the same format documented by GitHub:

- **Per-repository (recommended)**: create a `.vscode/mcp.json` file in the root of your repo.
- **Global for VS Code**: add the same JSON to your user `settings.json` under Copilot's MCP configuration (see GitHub docs for exact key names).

Example `mcp.json` contents for this server:

```json
{
  "servers": {
    "unifi-network-mcp": {
      "command": "npx",
      "args": ["-y", "unifi-network-mcp"],
      "env": {
        "UNIFI_TARGETS": "[{\"id\":\"home\",\"base_url\":\"https://<unifi_host>\",\"controller_type\":\"unifi_os\",\"default_site\":\"Default\",\"auth\":{\"apiKey\":\"UNIFI_API_KEY\",\"headerName\":\"X-API-KEY\"},\"verify_ssl\":false,\"timeout_ms\":20000,\"rate_limit_per_sec\":5}]"
      }
    }
  }
}
```

This matches the **Local server configuration example** from the official GitHub Copilot MCP docs, but swaps in `unifi-network-mcp` and the UniFi-specific `UNIFI_TARGETS`.

## Verifying
- `npm run test:env` calls `list_sites` against every configured target and fails fast on TLS/auth errors.
- Individual tool smoke tests:
  ```bash
  codex exec get_sysinfo --skip-git-repo-check
  ```
  (Replace `codex` with Windsurf, Cursor, etc., per your IDE.)

## Distribution options

To share a prebuilt MCP without requiring every consumer to run `npm install`:
1. **GitHub release artifacts**
   - Run `npm run build` to populate `dist/`.
   - Package `dist/`, `node_modules/`, `run-mcp.sh`, and `package.json` into `unifi-network-mcp-<version>.tar.gz`.
   - Publish on GitHub Releases so others can download, set `UNIFI_TARGETS`, and run `./run-mcp.sh` without compiling TypeScript.
2. **GitHub Pages / raw static hosting**
   - Commit the tarball to a `releases/` branch and serve via GitHub Pages for simple `curl | tar` installs.
3. **Homebrew-style tap (optional)**
   - Create a formula that downloads the release tarball, verifies checksum, and places a wrapper script in `/usr/local/bin`.
4. **Container image** (if runtime isolation is desired)
   - Build a minimal Node 20 image with `dist/` copied in, expose STDIO via `docker run --entrypoint ./run-mcp.sh ...`.

Each approach keeps the project free to distribute (only prebuilt JS + shell script) while letting downstream users skip the TypeScript toolchain.

## Repository

- **GitHub**: https://github.com/southbay-ny/unifi-network-mcp
- **Latest Release**: https://github.com/southbay-ny/unifi-network-mcp/releases/latest
