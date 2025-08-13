# Figma Tools

A Model Context Protocol (MCP) server for Figma integration that provides seamless access to Figma design files, components, and assets through AI assistants.

## Features

- 📋 **Node Listing** (`list_nodes_depth2`): List all nodes in Figma files with depth control
- 🔍 **Tree Structure Extraction** (`extract_figma_tree`): Extract complete tree structure of Figma nodes
- 🖼️ **Image Download** (`download_figma_images`): Download images from Figma designs in multiple formats (PNG, JPG, SVG, PDF)
- 🔧 **Complete Data Export** (`get_complete_node_data`): Get complete node data (tree + images) organized for AI understanding
- 🖼️ **Frame Extraction** (`extract_frame_nodes`): Extract Frame node information from Figma files
- 🌐 **Cross-platform**: Works on macOS, Linux, and Windows

## Quick Start

### Installation

```bash
pip install figma-mcp-tools
```

### Configuration

1. Get your Figma access token from [Figma Settings](https://www.figma.com/settings)
2. Add the server to your MCP configuration:

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

### Usage

Once configured, you can use commands like:
- "Extract the tree structure of this Figma file"
- "Download all images from these nodes as PNG"
- "List all Frame nodes in this design file"
- "Get complete data for these components including images"
- "Show me all nodes in this Figma file"

## Requirements

- Python 3.10+
- Figma access token
- MCP-compatible client (like Cursor, Claude Desktop, etc.)

## Documentation

- [GitHub Repository](https://github.com/DRX-1877/figma-mcp-server)
- [PyPI Package](https://pypi.org/project/figma-mcp-tools/)

## License

MIT License - see [LICENSE](https://github.com/DRX-1877/figma-mcp-server/blob/main/LICENSE) for details.
