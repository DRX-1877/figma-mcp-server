# Figma 完整节点数据获取器

这个工具可以从Figma文件中提取完整的节点数据，包括树结构信息和图片。

## 功能

- **节点树结构提取** - 获取指定节点的完整树结构（depth=4）
- **图片下载** - 下载节点的图片文件
- **数据整理** - 将所有数据整理到以节点名称命名的文件夹中
- **多种格式支持** - 支持PNG、JPG、SVG、PDF格式的图片导出
- **MCP服务器** - 提供MCP接口，供AI助手调用

## 文件结构

```
├── figma_frame_extractor.py    # Frame节点提取器类
├── figma_tree_extractor.py     # 树结构提取器类
├── figma_image_extractor.py    # 图片提取器类
├── figma_mcp_server.py         # MCP服务器
├── get_complete_node_data.py   # 整合脚本（主要使用）
├── start_mcp_server.sh         # MCP服务器启动脚本
├── figma-mcp.json              # MCP配置文件
├── requirements.txt            # 依赖文件
└── pages/                      # 原始数据文件夹
```

## 安装

1. 创建并激活虚拟环境：
```bash
python3.10 -m venv figma_env
source figma_env/bin/activate
```

2. 安装依赖：
```bash
pip install --upgrade pip
pip install requests
pip install git+https://github.com/modelcontextprotocol/python-sdk.git
```

3. 获取Figma Access Token：
   - 登录Figma
   - 进入Settings > Account > Personal access tokens
   - 创建新的access token

## 使用方法

### 主要使用方式（推荐）

1. 设置环境变量：
```bash
export FIGMA_ACCESS_TOKEN='your_token_here'
```

2. 运行整合脚本：
```bash
# 基本用法
python3 get_complete_node_data.py your_figma_file_key_here your_node_id_here

# 指定图片格式和缩放
python3 get_complete_node_data.py your_figma_file_key_here your_node_id_here png 2

# 获取多个节点
python3 get_complete_node_data.py your_figma_file_key_here your_node_id_here,your_second_node_id_here png 1
```

### 单独使用各个类

```bash
# 提取Frame节点信息
python3 figma_frame_extractor.py your_figma_file_key_here

# 提取树结构
python3 figma_tree_extractor.py your_figma_file_key_here your_node_id_here

# 下载图片
python3 figma_image_extractor.py your_figma_file_key_here your_node_id_here png 1
```

### MCP服务器使用

1. 启动MCP服务器：
```bash
./start_mcp_server.sh
```

2. 在支持MCP的AI助手中配置：
   - 服务器名称：`figma-tools`
   - 命令：`python3`
   - 参数：`figma_mcp_server.py`
   - 环境变量：`FIGMA_ACCESS_TOKEN`

3. 可用的MCP工具：
   - `extract_figma_tree` - 提取节点树结构
   - `download_figma_images` - 下载节点图片
   - `get_complete_node_data` - 获取完整节点数据
   - `extract_frame_nodes` - 提取Frame节点

## 输出示例

```
=== Figma 完整节点数据获取器 ===
文件Key: your_figma_file_key_here
节点IDs: your_node_id_here
图片格式: png
缩放比例: 1.0

步骤1: 获取节点树结构...
步骤2: 获取节点图片...
步骤3: 整理文件...
步骤4: 创建汇总信息...

=== 完成 ===
所有文件已整理到文件夹: your_node_name_your_node_id_here
包含文件:
  - nodesinfo.json (节点详细信息)
  - nodesstatus.json (节点统计信息)
  - image.json (图片信息)
  - summary.json (汇总信息)
  - 图片文件: your_node_id_here.png
```

## 输出文件结构

生成的文件夹结构：
```
your_node_name_your_node_id_here/
├── nodesinfo.json    # 节点详细信息（完整树结构）
├── nodesstatus.json  # 节点统计信息（各类型节点数量）
├── image.json        # 图片信息（下载链接、状态等）
├── summary.json      # 汇总信息
└── your_node_id_here.png        # 图片文件
```

## 参数说明

### get_complete_node_data.py 参数
- `file_key` - Figma文件唯一标识符（必需）
- `node_ids` - 节点ID，多个用逗号分隔（可选，默认your_node_id_here）
- `format` - 图片格式：png, jpg, svg, pdf（可选，默认png）
- `scale` - 缩放比例：0.01-4（可选，默认1.0）

### MCP工具参数

#### extract_figma_tree
- `file_key` - Figma文件唯一标识符
- `node_ids` - 节点ID，多个用逗号分隔
- `depth` - 树结构深度，默认4

#### download_figma_images
- `file_key` - Figma文件唯一标识符
- `node_ids` - 节点ID，多个用逗号分隔
- `format` - 图片格式：png, jpg, svg, pdf
- `scale` - 缩放比例：0.01-4

#### get_complete_node_data
- `file_key` - Figma文件唯一标识符
- `node_ids` - 节点ID，多个用逗号分隔
- `image_format` - 图片格式
- `image_scale` - 图片缩放比例
- `tree_depth` - 树结构深度

### 图片格式选项
- `png` - PNG格式，适合网页使用
- `jpg` - JPG格式，文件较小
- `svg` - SVG格式，矢量图形
- `pdf` - PDF格式，适合打印

## 注意事项

- 需要对该Figma文件有访问权限
- Access token请妥善保管，不要泄露
- 图片下载可能需要一些时间，取决于图片大小和网络状况
- 文件夹名称格式：`节点名称_节点ID`
- 支持批量处理多个节点，但建议一次处理不超过10个节点
- MCP服务器需要Python 3.10或更高版本
