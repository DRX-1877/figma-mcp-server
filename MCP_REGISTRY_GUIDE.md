# MCP Registry 提交指南

## 📋 提交前准备

### 已完成的文件
- ✅ `mcp-registry-readme.md` - MCP Registry README
- ✅ `mcp-registry-package.json` - MCP Registry package.json
- ✅ `mcp.json` - MCP 配置文件

## 🚀 提交步骤

### 1. Fork MCP Registry
访问 https://github.com/modelcontextprotocol/registry 并点击 "Fork"

### 2. 克隆你的 Fork
```bash
git clone https://github.com/YOUR_USERNAME/registry.git
cd registry
```

### 3. 创建服务器目录
```bash
mkdir -p servers/figma-tools
```

### 4. 添加文件
将以下文件复制到 `servers/figma-tools/` 目录：

#### README.md
```bash
cp mcp-registry-readme.md servers/figma-tools/README.md
```

#### package.json
```bash
cp mcp-registry-package.json servers/figma-tools/package.json
```

#### mcp.json
```bash
cp mcp.json servers/figma-tools/mcp.json
```

### 5. 提交更改
```bash
git add servers/figma-tools/
git commit -m "feat: add figma-tools MCP server

- Add Figma integration MCP server
- Supports file access, image export, and component management
- Cross-platform support (macOS/Linux/Windows)
- Available on PyPI as figma-mcp-tools"
git push origin main
```

### 6. 创建 Pull Request
1. 访问你的 Fork 页面
2. 点击 "Compare & pull request"
3. 填写 PR 描述：

```markdown
## Figma Tools MCP Server

### Description
A Model Context Protocol (MCP) server for Figma integration that provides seamless access to Figma design files, components, and assets through AI assistants.

### Features
- 🔍 File Access: Browse and search Figma files
- 🖼️ Image Export: Extract images from Figma designs
- 📋 Component Management: Access and manage Figma components
- 💬 Comments: Read and post comments on Figma designs
- 🔧 Design Tokens: Extract design tokens and styles
- 🌐 Cross-platform: Works on macOS, Linux, and Windows

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
```

## 📝 文件内容

### servers/figma-tools/README.md
```markdown
# Figma Tools

A Model Context Protocol (MCP) server for Figma integration that provides seamless access to Figma design files, components, and assets through AI assistants.

## Features

- 🔍 **File Access**: Browse and search Figma files
- 🖼️ **Image Export**: Extract images from Figma designs
- 📋 **Component Management**: Access and manage Figma components
- 💬 **Comments**: Read and post comments on Figma designs
- 🔧 **Design Tokens**: Extract design tokens and styles
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
- "Show me the latest designs in my Figma project"
- "Extract all images from this Figma file"
- "What components are available in this design system?"
- "Add a comment to this design"

## Requirements

- Python 3.10+
- Figma access token
- MCP-compatible client (like Cursor, Claude Desktop, etc.)

## Documentation

- [GitHub Repository](https://github.com/DRX-1877/figma-mcp-server)
- [PyPI Package](https://pypi.org/project/figma-mcp-tools/)

## License

MIT License - see [LICENSE](https://github.com/DRX-1877/figma-mcp-server/blob/main/LICENSE) for details.
```

### servers/figma-tools/package.json
```json
{
  "name": "figma-tools",
  "description": "A Model Context Protocol (MCP) server for Figma integration",
  "version": "1.0.0",
  "author": "DRX-1877",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "https://github.com/DRX-1877/figma-mcp-server"
  },
  "keywords": ["figma", "mcp", "design", "api", "model-context-protocol"],
  "engines": {
    "python": ">=3.10"
  },
  "dependencies": {
    "figma-mcp-tools": "^1.0.0"
  },
  "scripts": {
    "install": "pip install figma-mcp-tools",
    "start": "figma-mcp-tools"
  },
  "mcp": {
    "command": "figma-mcp-tools",
    "env": {
      "FIGMA_ACCESS_TOKEN": "your_token_here"
    }
  }
}
```

### servers/figma-tools/mcp.json
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

## 🎯 下一步

1. 等待 PR 审核和合并
2. 一旦合并，你的服务器将出现在 MCP Marketplace
3. 用户可以通过 MCP 客户端发现和安装你的服务器

## 📞 支持

如果在提交过程中遇到问题，可以：
- 查看 [MCP Registry 文档](https://github.com/modelcontextprotocol/registry)
- 在 [MCP Discord](https://discord.gg/modelcontextprotocol) 寻求帮助
- 创建 [GitHub Issue](https://github.com/modelcontextprotocol/registry/issues)
