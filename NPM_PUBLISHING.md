# Publishing to npm Registry

This is the **recommended** distribution method for the UniFi Network MCP. It provides native integration with all MCP-compatible tools.

## Why npm?

✅ **Native support** - Built into Node.js, works everywhere  
✅ **Automatic versioning** - npm handles version management  
✅ **Simple configuration** - Just use `npx` in your MCP config  
✅ **Industry standard** - How most Node.js MCPs are distributed  
✅ **No custom scripts** - No need for auto-install wrappers  

## Publishing Steps

### 1. Login to npm
```bash
npm login
# Enter your npm credentials
```

### 2. Build and publish
```bash
cd servers/unifi-network-mcp
npm run build
npm publish
```

That's it! The package is now available at: `https://www.npmjs.com/package/unifi-network-mcp`

## Usage After Publishing

### For End Users

**Install and run**:
```bash
npx unifi-network-mcp
```

**Or install globally**:
```bash
npm install -g unifi-network-mcp
unifi-network-mcp
```

### Configuration Examples

#### Codex
```toml
[mcp_servers.unifi-network-mcp]
    command = "npx"
    args = ["-y", "unifi-network-mcp"]
    [mcp_servers.unifi-network-mcp.env]
        UNIFI_TARGETS = '[...]'
```

#### OpenCode
```json
{
  "mcp": {
    "unifi-network": {
      "type": "local",
      "command": ["npx", "-y", "unifi-network-mcp"],
      "environment": {
        "UNIFI_TARGETS": "[...]"
      }
    }
  }
}
```

#### Windsurf
- **Command**: `npx`
- **Args**: `-y unifi-network-mcp`
- **Environment**: `UNIFI_TARGETS=[...]`

#### Cursor
```json
{
  "servers": [{
    "name": "unifi-network",
    "command": "npx",
    "args": ["-y", "unifi-network-mcp"],
    "env": { "UNIFI_TARGETS": "[...]" }
  }]
}
```

## Version Management

### Publish a new version
```bash
# Update version in package.json
npm version patch  # 0.1.0 -> 0.1.1
npm version minor  # 0.1.0 -> 0.2.0
npm version major  # 0.1.0 -> 1.0.0

# Publish
npm publish
```

### Users can pin versions
```bash
# Always latest
npx unifi-network-mcp

# Specific version
npx unifi-network-mcp@0.1.0

# Version range
npx unifi-network-mcp@^0.1.0
```

## Comparison: npm vs GitHub Releases

| Feature | npm | GitHub Releases |
|---------|-----|-----------------|
| **Installation** | `npx unifi-network-mcp` | Download tarball + extract |
| **Updates** | `npx` always gets latest | Manual download |
| **Caching** | Automatic (npm cache) | Manual |
| **Configuration** | `command = "npx"` | `command = "/path/to/script"` |
| **Discovery** | Listed on npmjs.com | GitHub only |
| **Version pinning** | `@version` syntax | Manual tag selection |
| **Industry standard** | ✅ Yes | ❌ No (for Node packages) |

## Automation with GitHub Actions

Update `.github/workflows/release.yml` to auto-publish to npm:

```yaml
- name: Publish to npm
  working-directory: servers/unifi-network-mcp
  run: |
    echo "//registry.npmjs.org/:_authToken=${{ secrets.NPM_TOKEN }}" > ~/.npmrc
    npm publish
  env:
    NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
```

Add `NPM_TOKEN` to GitHub secrets with your npm access token.

## Testing Before Publishing

```bash
# Test local installation
cd servers/unifi-network-mcp
npm pack
npm install -g ./unifi-network-mcp-0.1.0.tgz

# Test it works
unifi-network-mcp
```

## After Publishing

Update documentation to use npm installation:

**README.md**:
```markdown
## Installation

```bash
npx unifi-network-mcp
```

Or install globally:
```bash
npm install -g unifi-network-mcp
```
\```
```

This is **much simpler** than GitHub releases for end users!
