# Figma MCP Server

A Model Context Protocol (MCP) server for Figma integration, allowing AI assistants to interact with Figma files and extract design data.

## Features

- 🔍 **Extract Figma Tree Structure** - Get complete node hierarchy and metadata
- 🖼️ **Download Figma Images** - Export nodes as PNG, JPG, SVG, or PDF
- 📊 **Frame Node Analysis** - Extract and analyze Frame nodes
- 📁 **Organized Output** - Automatically organize extracted data into folders
- 🔧 **MCP Integration** - Seamless integration with MCP-compatible AI assistants

## Installation

### From PyPI (Recommended)

```bash
pip install figma-mcp-server
```

### From Source

```bash
git clone https://github.com/yourusername/figma-mcp-server.git
cd figma-mcp-server
pip install -e .
```

## Setup

1. **Get Figma Access Token**
   - Go to [Figma Settings > Account > Personal access tokens](https://www.figma.com/settings)
   - Create a new access token
   - Copy the token

2. **Set Environment Variable**
   ```bash
   # macOS/Linux
   export FIGMA_ACCESS_TOKEN='your_token_here'
   
   # Windows
   set FIGMA_ACCESS_TOKEN=your_token_here
   ```

## Usage

### Command Line

```bash
figma-mcp-server
```

### MCP Configuration

Add to your MCP configuration file (e.g., `~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "figma-tools": {
      "command": "figma-mcp-server",
      "env": {
        "FIGMA_ACCESS_TOKEN": "your_token_here"
      }
    }
  }
}
```

## Available Tools

### 1. extract_figma_tree
Extract complete tree structure of Figma nodes
- **Parameters**:
  - `file_key`: Figma file unique identifier
  - `node_ids`: Node IDs, comma-separated
  - `depth`: Tree depth (default: 4)

### 2. download_figma_images
Download images of Figma nodes
- **Parameters**:
  - `file_key`: Figma file unique identifier
  - `node_ids`: Node IDs, comma-separated
  - `format`: Image format (png, jpg, svg, pdf)
  - `scale`: Scale factor (0.01-4)

### 3. get_complete_node_data
Get complete node data (tree + images) and organize into folders
- **Parameters**:
  - `file_key`: Figma file unique identifier
  - `node_ids`: Node IDs, comma-separated
  - `image_format`: Image format
  - `image_scale`: Image scale factor
  - `tree_depth`: Tree depth

### 4. extract_frame_nodes
Extract Frame node information from Figma files
- **Parameters**:
  - `file_key`: Figma file unique identifier
  - `max_depth`: Maximum depth (default: 2)

## Example Usage

```python
# Example: Extract tree structure
{
  "file_key": "5F45MIt6BVWBIZCEkA0do3",
  "node_ids": "1:498",
  "depth": 4
}

# Example: Download images
{
  "file_key": "5F45MIt6BVWBIZCEkA0do3",
  "node_ids": "1:498",
  "format": "png",
  "scale": 2.0
}
```

## Development

### Setup Development Environment

```bash
git clone https://github.com/yourusername/figma-mcp-server.git
cd figma-mcp-server
pip install -e ".[dev]"
```

### Run Tests

```bash
pytest
```

### Code Formatting

```bash
black figma_mcp_server/
```

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## Support

- 📖 [Documentation](https://github.com/yourusername/figma-mcp-server#readme)
- 🐛 [Bug Reports](https://github.com/yourusername/figma-mcp-server/issues)
- 💬 [Discussions](https://github.com/yourusername/figma-mcp-server/discussions)

## Changelog

### 1.0.0
- Initial release
- Basic Figma tree extraction
- Image download functionality
- Frame node analysis
- MCP server integration
