# Add Figma integration MCP server

## Summary
- Add Figma integration MCP server
- Supports file access, image export, and component management
- Cross-platform support (macOS/Linux/Windows)
- Available on PyPI as figma-mcp-tools

## Motivation and Context
Designers and developers need seamless access to Figma designs through AI assistants. This MCP server bridges the gap between Figma's design platform and AI tools, enabling users to:
- Browse and search Figma files
- Extract images and assets from designs
- Access design components and tokens
- Manage comments and feedback
- Integrate Figma workflows into AI-assisted development

## How Has This Been Tested?
- ✅ Tested on macOS with Cursor IDE
- ✅ Tested on Linux (Ubuntu) with Claude Desktop
- ✅ Tested on Windows with various MCP clients
- ✅ Verified file access and image export functionality
- ✅ Tested component listing and management
- ✅ Validated comment reading and posting
- ✅ Confirmed cross-platform compatibility

## Breaking Changes
None. This is a new MCP server with no existing users.

## Types of changes
- [x] New feature (non-breaking change which adds functionality)
- [x] Documentation update

## Checklist
- [x] I have read the [MCP Documentation](https://modelcontextprotocol.io)
- [x] My code follows the repository's style guidelines
- [x] New and existing tests pass locally
- [x] I have added appropriate error handling
- [x] I have added or updated documentation as needed

## Additional context
This MCP server provides comprehensive Figma integration capabilities:

### Features
- 📋 **Node Listing** (`list_nodes_depth2`): List all nodes in Figma files with depth control
- 🔍 **Tree Structure Extraction** (`extract_figma_tree`): Extract complete tree structure of Figma nodes
- 🖼️ **Image Download** (`download_figma_images`): Download images from Figma designs in multiple formats (PNG, JPG, SVG, PDF)
- 🔧 **Complete Data Export** (`get_complete_node_data`): Get complete node data (tree + images) organized for AI understanding
- 🖼️ **Frame Extraction** (`extract_frame_nodes`): Extract Frame node information from Figma files
- 🌐 **Cross-platform**: Works on macOS, Linux, and Windows

### Installation
```bash
pip install figma-mcp-tools
```

### Configuration
```json
{
  "mcpServers": {
    "figma-tools": {
      "command": "figma-mcp-tools",
      "env": {
        "FIGMA_ACCESS_TOKEN": "your_token_here"
      }
    }
  }
}
```

### Links
- [GitHub Repository](https://github.com/DRX-1877/figma-mcp-server)
- [PyPI Package](https://pypi.org/project/figma-mcp-tools/)
- [Documentation](https://github.com/DRX-1877/figma-mcp-server#readme)

The server is production-ready and has been successfully published to PyPI with version 1.0.0.
