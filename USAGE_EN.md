# Figma MCP Server Usage Guide

> **Chinese Version**: [USAGE.md](USAGE.md)

## 🚀 Quick Start

### 1. Installation

```bash
# Clone the repository
git clone https://github.com/DRX-1877/figma-mcp-server.git
cd figma-mcp-server

# Run installation script
./install.sh
```

### 2. Set Figma Access Token

```bash
export FIGMA_ACCESS_TOKEN='your_token_here'
```

### 3. Start Server

```bash
./start.sh
```

## 📋 Usage Examples

### Example 1: List all nodes in a file

```bash
# Activate virtual environment
source figma-mcp-env/bin/activate

# List nodes
figma-mcp-server list-nodes your_figma_file_key
```

### Example 2: Extract complete data for specific nodes

```bash
# Extract single node
figma-mcp-server extract your_figma_file_key your_node_id

# Extract multiple nodes
figma-mcp-server extract your_figma_file_key node1,node2,node3
```

### Example 3: Specify image format and scaling

```bash
# Extract PNG format with 2x scaling
figma-mcp-server extract your_figma_file_key your_node_id --format png --scale 2

# Extract SVG format
figma-mcp-server extract your_figma_file_key your_node_id --format svg
```

## 🔧 MCP Integration

### Cursor Configuration

Add to `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "figma-tools": {
      "command": "/path/to/your/figma-mcp-env/bin/figma-mcp-server",
      "env": {
        "FIGMA_ACCESS_TOKEN": "your_token_here"
      }
    }
  }
}
```

**Note:** Replace `/path/to/your/` with the actual path to your installation directory.

### Other MCP Clients

Configuration:
- **Command**: `figma-mcp-server`
- **Environment Variable**: `FIGMA_ACCESS_TOKEN=your_token_here`

## 🛠️ Troubleshooting

### Common Issues

1. **Virtual environment not activated**
   ```bash
   source figma-mcp-env/bin/activate
   ```

2. **Figma token not set**
   ```bash
   export FIGMA_ACCESS_TOKEN='your_token_here'
   ```

3. **Permission issues**
   ```bash
   chmod +x install.sh start.sh
   ```

4. **Python version issues**
   ```bash
   python3 --version  # Ensure >= 3.10
   ```

5. **Global command not found**
   ```bash
   # If figma-mcp-server command is not found globally
   # Use the full path to the executable
   /path/to/your/figma-mcp-env/bin/figma-mcp-server
   ```

### Get Help

```bash
figma-mcp-server --help
```

## 📁 Output Structure

Extracted data will be saved in the following structure:

```
your_node_name_your_node_id_here/
├── nodesinfo.json    # Complete tree structure data
└── your_node_id_here.png  # Downloaded image file
```

## 💡 Best Practices

1. **List nodes first**: Use `list-nodes` to find the node IDs you need
2. **Batch processing**: Avoid extracting too many nodes at once
3. **Reasonable scaling**: Choose appropriate image scaling based on your needs
4. **Save token**: Add the token to your shell configuration file
5. **Use installation scripts**: Take advantage of the automated installation process
6. **Virtual environment**: Always activate the virtual environment before use

## 🔧 Installation Script Features

The installation scripts provide:
- ✅ **Automatic environment setup**: No manual configuration needed
- ✅ **Bilingual support**: Chinese and English installation prompts
- ✅ **Global command access**: Create symbolic links for easy access
- ✅ **PATH configuration**: Automatically configure environment variables
- ✅ **Error handling**: Comprehensive error checking and user guidance

## 🎯 Use Cases

### For Developers
- Extract Figma designs for code generation
- Analyze design structure and constraints
- Generate React/Vue/Angular components
- Visual verification of implemented designs

### For AI Assistants
- Provide structured design data to AI
- Enable design-to-code workflows
- Support iterative design analysis
- Facilitate visual comparison tasks
