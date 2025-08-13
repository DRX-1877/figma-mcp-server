# MCP Marketplace 发布指南

## 📋 发布前检查清单

### ✅ 必需文件
- [x] `pyproject.toml` - 项目配置
- [x] `README.md` - 项目文档
- [x] `mcp.json` - MCP 配置文件
- [x] `LICENSE` - 开源许可证
- [x] 核心代码包 `figma_mcp_server/`

### ✅ 功能验证
- [x] 全局命令可用性
- [x] 跨平台支持 (macOS/Linux/Windows)
- [x] 自动环境配置
- [x] 错误处理和故障排除

## 🚀 发布步骤

### ✅ 1. 准备 PyPI 发布

```bash
# 构建包
python -m build

# 检查构建结果
ls dist/

# 上传到 PyPI (测试)
python -m twine upload --repository testpypi dist/*

# 上传到 PyPI (正式)
python -m twine upload dist/*
```

**状态**: ✅ 已完成 - 包已成功发布到 PyPI

### ✅ 2. 创建 GitHub Release

1. 在 GitHub 上创建新的 Release
2. 标签格式：`v1.0.0`
3. 上传构建的包文件
4. 添加发布说明

**状态**: ✅ 已完成 - 已创建标签 v1.0.0 并推送到 GitHub

### 🔄 3. 提交到 MCP Marketplace

1. Fork [MCP Registry](https://github.com/modelcontextprotocol/registry)
2. 添加您的服务器到 `servers/` 目录
3. 创建 Pull Request

**状态**: 🔄 准备中 - 已创建所需文件，请按照 `MCP_REGISTRY_GUIDE.md` 进行提交

## 📁 MCP Registry 文件结构

在 MCP Registry 中需要创建：

```
servers/figma-tools/
├── README.md
├── mcp.json
└── package.json
```

### package.json 示例

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
  "keywords": ["figma", "mcp", "design", "api"],
  "engines": {
    "node": ">=18.0.0"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^0.4.0"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "typescript": "^5.0.0"
  },
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js"
  }
}
```

## 🔧 发布前测试

### 本地测试
```bash
# 安装包
pip install -e .

# 测试命令
figma-mcp-tools --help

# 测试 MCP 集成
# 在 Cursor 中配置 mcp.json 并测试
```

### 跨平台测试
- [x] macOS 安装和运行
- [x] Linux 安装和运行  
- [x] Windows 安装和运行

## 📝 发布说明模板

```markdown
# Figma MCP Server v1.0.0

## 🎉 新功能
- 全局命令可用性
- 自动环境配置
- 跨平台支持 (macOS/Linux/Windows)
- 智能故障排除

## 🚀 快速开始
```bash
pip install figma-mcp-tools
figma-mcp-tools --help
```

## 📚 文档
- [GitHub Repository](https://github.com/DRX-1877/figma-mcp-server)
- [使用指南](https://github.com/DRX-1877/figma-mcp-server#readme)

## 🔧 配置
在 `~/.cursor/mcp.json` 中添加：
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
```

## 🎯 下一步

1. **更新版本号**：在 `pyproject.toml` 中更新版本
2. **构建包**：使用 `python -m build`
3. **测试发布**：先发布到 TestPyPI
4. **正式发布**：发布到 PyPI
5. **提交 Registry**：提交到 MCP Registry

## 📞 支持

- GitHub Issues: https://github.com/DRX-1877/figma-mcp-server/issues
- 文档: https://github.com/DRX-1877/figma-mcp-server#readme
