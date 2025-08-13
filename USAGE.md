# Figma MCP Server 使用指南

> **English Version**: [USAGE_EN.md](USAGE_EN.md)

## 🚀 快速开始

### 1. 安装

```bash
# 克隆项目
git clone https://github.com/DRX-1877/figma-mcp-server.git
cd figma-mcp-server

# 运行安装脚本
./install.sh
```

### 2. 设置 Figma 访问令牌

```bash
export FIGMA_ACCESS_TOKEN='your_token_here'
```

### 3. 启动服务器

```bash
./start.sh
```

## 📋 使用示例

### 示例 1：列出文件中的所有节点

```bash
# 激活虚拟环境
source figma-mcp-env/bin/activate

# 列出节点
figma-mcp-server list-nodes your_figma_file_key
```

### 示例 2：提取特定节点的完整数据

```bash
# 提取单个节点
figma-mcp-server extract your_figma_file_key your_node_id

# 提取多个节点
figma-mcp-server extract your_figma_file_key node1,node2,node3
```

### 示例 3：指定图片格式和缩放

```bash
# 提取 PNG 格式，2倍缩放
figma-mcp-server extract your_figma_file_key your_node_id --format png --scale 2

# 提取 SVG 格式
figma-mcp-server extract your_figma_file_key your_node_id --format svg
```

## 🔧 MCP 集成

### Cursor 配置

在 `~/.cursor/mcp.json` 中添加：

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

### 其他 MCP 客户端

配置命令：
- **命令**: `figma-mcp-server`
- **环境变量**: `FIGMA_ACCESS_TOKEN=your_token_here`

## 🛠️ 故障排除

### 常见问题

1. **虚拟环境未激活**
   ```bash
   source figma-mcp-env/bin/activate
   ```

2. **Figma 令牌未设置**
   ```bash
   export FIGMA_ACCESS_TOKEN='your_token_here'
   ```

3. **权限问题**
   ```bash
   chmod +x install.sh start.sh
   ```

4. **Python 版本问题**
   ```bash
   python3 --version  # 确保 >= 3.10
   ```

### 获取帮助

```bash
figma-mcp-server --help
```

## 📁 输出结构

提取的数据将保存在以下结构中：

```
your_node_name_your_node_id_here/
├── nodesinfo.json    # 完整的树结构数据
└── your_node_id_here.png  # 下载的图片文件
```

## 💡 最佳实践

1. **先列出节点**：使用 `list-nodes` 找到需要的节点 ID
2. **分批处理**：避免一次提取过多节点
3. **合理缩放**：根据需要选择合适的图片缩放比例
4. **保存令牌**：将令牌添加到 shell 配置文件中
