#!/usr/bin/env python3
"""
Figma MCP Server
将Figma工具功能暴露为MCP工具，供AI助手调用
"""

import asyncio
import json
import os
import sys
from typing import Any, Dict, List, Optional
from pathlib import Path

# 导入我们的Figma工具类
from .figma_tree_extractor import FigmaTreeExtractor
from .figma_image_extractor import FigmaImageExtractor
from .figma_frame_extractor import FigmaFrameExtractor
from .figma_node_lister import FigmaNodeLister

# MCP相关导入
try:
    from mcp.server import Server
    from mcp.server.models import InitializationOptions
    from mcp.server.stdio import stdio_server
    from mcp.types import (
        CallToolRequest,
        CallToolResult,
        ListToolsRequest,
        ListToolsResult,
        Tool,
        TextContent,
        ImageContent,
        EmbeddedResource,
    )
except ImportError:
    print("请先安装MCP: pip install mcp")
    sys.exit(1)

# 创建MCP服务器
server = Server("figma-tools")

class FigmaMCPServer:
    def __init__(self):
        # 自动设置虚拟环境路径
        self.setup_environment()
        
        self.access_token = os.getenv("FIGMA_ACCESS_TOKEN")
        if not self.access_token:
            print("警告: 未设置 FIGMA_ACCESS_TOKEN 环境变量")
        
        self.tree_extractor = FigmaTreeExtractor(self.access_token) if self.access_token else None
        self.image_extractor = FigmaImageExtractor(self.access_token) if self.access_token else None
        self.frame_extractor = FigmaFrameExtractor(self.access_token) if self.access_token else None
        self.node_lister = FigmaNodeLister(self.access_token) if self.access_token else None
    
    def setup_environment(self):
        """设置环境，包括虚拟环境路径"""
        # 获取当前脚本所在目录
        script_dir = os.path.dirname(os.path.abspath(__file__))
        
        # 检查虚拟环境是否存在
        venv_path = os.path.join(script_dir, "figma_env")
        if os.path.exists(venv_path):
            # 添加虚拟环境的site-packages到Python路径
            if sys.platform == "win32":
                site_packages = os.path.join(venv_path, "Lib", "site-packages")
            else:
                site_packages = os.path.join(venv_path, "lib", "python3.10", "site-packages")
            
            if os.path.exists(site_packages):
                sys.path.insert(0, site_packages)
                print(f"已添加虚拟环境路径: {site_packages}")
        
        # 添加当前目录到Python路径
        if script_dir not in sys.path:
            sys.path.insert(0, script_dir)
    
    def get_node_name(self, tree_data: Dict[str, Any], node_id: str) -> str:
        """从树结构数据中获取节点名称"""
        try:
            if "nodes" in tree_data and node_id in tree_data["nodes"]:
                node_name = tree_data["nodes"][node_id].get("name", "")
                return node_name.replace(':', '_').replace('/', '_').replace('\\', '_').strip() or f"node_{node_id.replace(':', '_')}"
            return f"node_{node_id.replace(':', '_')}"
        except Exception:
            return f"node_{node_id.replace(':', '_')}"
    
    def organize_files(self, file_key: str, node_ids: str, node_name: str, tree_result: Dict, image_result: Dict) -> Dict[str, Any]:
        """整理文件到指定文件夹"""
        import shutil
        
        # 创建目标文件夹
        first_node_id = node_ids.split(",")[0]
        target_dir = f"{node_name}_{first_node_id}"
        os.makedirs(target_dir, exist_ok=True)
        
        result = {
            "target_dir": target_dir,
            "files": {}
        }
        
        # 保存树结构文件
        tree_file = f"{target_dir}/nodesinfo.json"
        with open(tree_file, 'w', encoding='utf-8') as f:
            json.dump(tree_result, f, indent=2, ensure_ascii=False)
        result["files"]["nodesinfo"] = tree_file
        
        # 处理图片文件
        if image_result and "images" in image_result:
            for node_id, image_info in image_result["images"].items():
                if image_info.get("status") == "success" and image_info.get("filename"):
                    # 移动图片文件到目标目录
                    old_path = image_info["filename"]
                    new_path = f"{target_dir}/{node_id}.{image_result.get('format', 'png')}"
                    if os.path.exists(old_path):
                        shutil.move(old_path, new_path)
                        result["files"]["image"] = new_path
        
        return result

# 创建Figma MCP服务器实例
figma_server = FigmaMCPServer()

@server.list_tools()
async def handle_list_tools() -> ListToolsResult:
    """列出可用的工具"""
    return ListToolsResult(
        tools=[
            Tool(
                name="extract_figma_tree",
                description="提取Figma节点的完整树结构信息",
                inputSchema={
                    "type": "object",
                    "properties": {
                        "file_key": {
                            "type": "string",
                            "description": "Figma文件的唯一标识符"
                        },
                        "node_ids": {
                            "type": "string", 
                            "description": "节点ID，多个用逗号分隔。使用 list_nodes_depth2 工具获取节点ID"
                        },
                        "depth": {
                            "type": "integer",
                            "description": "树结构深度，默认4",
                            "default": 4
                        }
                    },
                    "required": ["file_key", "node_ids"]
                }
            ),
            Tool(
                name="download_figma_images",
                description="下载Figma节点的图片",
                inputSchema={
                    "type": "object",
                    "properties": {
                        "file_key": {
                            "type": "string",
                            "description": "Figma文件的唯一标识符"
                        },
                        "node_ids": {
                            "type": "string",
                            "description": "节点ID，多个用逗号分隔。使用 list_nodes_depth2 工具获取节点ID"
                        },
                        "format": {
                            "type": "string",
                            "description": "图片格式：png, jpg, svg, pdf",
                            "default": "png"
                        },
                        "scale": {
                            "type": "number",
                            "description": "缩放比例：0.01-4",
                            "default": 1.0
                        }
                    },
                    "required": ["file_key", "node_ids"]
                }
            ),
            Tool(
                name="get_complete_node_data",
                description="获取Figma节点的完整数据（树结构+图片），并整理到文件夹。输出结构专为AI理解设计：nodesinfo.json提供结构化数据，图片文件提供视觉参考。⚠️ 注意：此工具会消耗大量API配额，建议先使用list_nodes_depth2获取节点ID",
                inputSchema={
                    "type": "object",
                    "properties": {
                        "file_key": {
                            "type": "string",
                            "description": "Figma文件的唯一标识符"
                        },
                        "node_ids": {
                            "type": "string",
                            "description": "节点ID，多个用逗号分隔。使用 list_nodes_depth2 工具获取节点ID"
                        },
                        "image_format": {
                            "type": "string",
                            "description": "图片格式：png, jpg, svg, pdf",
                            "default": "png"
                        },
                        "image_scale": {
                            "type": "number",
                            "description": "图片缩放比例：0.01-4",
                            "default": 1.0
                        },
                        "tree_depth": {
                            "type": "integer",
                            "description": "树结构深度",
                            "default": 4
                        }
                    },
                    "required": ["file_key", "node_ids"]
                }
            ),
            Tool(
                name="extract_frame_nodes",
                description="提取Figma文件中的Frame节点信息",
                inputSchema={
                    "type": "object",
                    "properties": {
                        "file_key": {
                            "type": "string",
                            "description": "Figma文件的唯一标识符"
                        },
                        "max_depth": {
                            "type": "integer",
                            "description": "最大深度，默认2",
                            "default": 2
                        }
                    },
                    "required": ["file_key"]
                }
            ),
            Tool(
                name="list_nodes_depth2",
                description="列出Figma文件中所有节点的ID和名称（深度限制为2），帮助用户找到需要的节点",
                inputSchema={
                    "type": "object",
                    "properties": {
                        "file_key": {
                            "type": "string",
                            "description": "Figma文件的唯一标识符"
                        },
                        "node_types": {
                            "type": "string",
                            "description": "要包含的节点类型，用逗号分隔（如：FRAME,COMPONENT,TEXT），留空表示所有类型",
                            "default": ""
                        }
                    },
                    "required": ["file_key"]
                }
            )
        ]
    )

@server.call_tool()
async def handle_call_tool(name: str, arguments: Dict[str, Any]) -> CallToolResult:
    """处理工具调用"""
    try:
        if name == "extract_figma_tree":
            return await handle_extract_tree(arguments)
        elif name == "download_figma_images":
            return await handle_download_images(arguments)
        elif name == "get_complete_node_data":
            return await handle_complete_data(arguments)
        elif name == "extract_frame_nodes":
            return await handle_extract_frames(arguments)
        elif name == "list_nodes_depth2":
            return await handle_list_nodes(arguments)
        else:
            return CallToolResult(
                content=[TextContent(type="text", text=f"未知工具: {name}")]
            )
    except Exception as e:
        return CallToolResult(
            content=[TextContent(type="text", text=f"执行工具时出错: {str(e)}")]
        )

async def handle_extract_tree(arguments: Dict[str, Any]) -> CallToolResult:
    """处理树结构提取"""
    file_key = arguments["file_key"]
    node_ids = arguments["node_ids"]
    depth = arguments.get("depth", 4)
    
    if not figma_server.tree_extractor:
        return CallToolResult(
            content=[TextContent(type="text", text="错误: 未设置 FIGMA_ACCESS_TOKEN")]
        )
    
    result = figma_server.tree_extractor.extract_tree(file_key, node_ids, depth)
    if not result:
        return CallToolResult(
            content=[TextContent(type="text", text="提取树结构失败")]
        )
    
    # 保存到文件
    output_file = f"specific_nodes_{file_key}.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(result, f, indent=2, ensure_ascii=False)
    
    return CallToolResult(
        content=[
            TextContent(
                type="text", 
                text=f"✅ 树结构提取成功！\n\n文件: {output_file}\n总节点数: {result['analysis']['total_nodes']}\n节点类型统计: {json.dumps(result['analysis']['node_counts'], ensure_ascii=False, indent=2)}"
            )
        ]
    )

async def handle_download_images(arguments: Dict[str, Any]) -> CallToolResult:
    """处理图片下载"""
    file_key = arguments["file_key"]
    node_ids = arguments["node_ids"]
    format = arguments.get("format", "png")
    scale = arguments.get("scale", 1.0)
    
    if not figma_server.image_extractor:
        return CallToolResult(
            content=[TextContent(type="text", text="错误: 未设置 FIGMA_ACCESS_TOKEN")]
        )
    
    result = figma_server.image_extractor.extract_images(file_key, node_ids, format, scale)
    if not result:
        return CallToolResult(
            content=[TextContent(type="text", text="下载图片失败")]
        )
    
    success_count = sum(1 for img in result["images"].values() if img.get("status") == "success")
    total_count = len(result["images"])
    
    return CallToolResult(
        content=[
            TextContent(
                type="text", 
                text=f"✅ 图片下载完成！\n\n成功下载: {success_count}/{total_count} 个图片\n格式: {format}\n缩放: {scale}\n图片保存在: images_{file_key}/"
            )
        ]
    )

async def handle_complete_data(arguments: Dict[str, Any]) -> CallToolResult:
    """处理完整数据获取"""
    file_key = arguments["file_key"]
    node_ids = arguments["node_ids"]
    image_format = arguments.get("image_format", "png")
    image_scale = arguments.get("image_scale", 1.0)
    tree_depth = arguments.get("tree_depth", 4)
    
    if not figma_server.tree_extractor or not figma_server.image_extractor:
        return CallToolResult(
            content=[TextContent(type="text", text="错误: 未设置 FIGMA_ACCESS_TOKEN")]
        )
    
    # 步骤1: 获取树结构
    tree_result = figma_server.tree_extractor.extract_tree(file_key, node_ids, tree_depth)
    if not tree_result:
        return CallToolResult(
            content=[TextContent(type="text", text="获取树结构失败")]
        )
    
    # 步骤2: 获取节点名称
    first_node_id = node_ids.split(",")[0]
    node_name = figma_server.get_node_name(tree_result, first_node_id)
    
    # 步骤3: 下载图片
    image_result = figma_server.image_extractor.extract_images(file_key, node_ids, image_format, image_scale)
    if not image_result:
        return CallToolResult(
            content=[TextContent(type="text", text="下载图片失败")]
        )
    
    # 步骤4: 整理文件
    organize_result = figma_server.organize_files(file_key, node_ids, node_name, tree_result, image_result)
    
    return CallToolResult(
        content=[
            TextContent(
                type="text", 
                text=f"✅ 完整数据获取成功！\n\n📁 输出文件夹: {organize_result['target_dir']}\n📊 总节点数: {tree_result['analysis']['total_nodes']}\n🖼️ 图片格式: {image_format}\n📏 缩放比例: {image_scale}\n\n包含文件:\n- nodesinfo.json (节点详细信息)\n- nodesstatus.json (节点统计信息)\n- image.json (图片信息)\n- summary.json (汇总信息)\n- 图片文件"
            )
        ]
    )

async def handle_extract_frames(arguments: Dict[str, Any]) -> CallToolResult:
    """处理Frame节点提取"""
    file_key = arguments["file_key"]
    max_depth = arguments.get("max_depth", 2)
    
    if not figma_server.frame_extractor:
        return CallToolResult(
            content=[TextContent(type="text", text="错误: 未设置 FIGMA_ACCESS_TOKEN")]
        )
    
    result = figma_server.frame_extractor.extract_frames(file_key, max_depth)
    if not result:
        return CallToolResult(
            content=[TextContent(type="text", text="提取Frame节点失败")]
        )
    
    frame_count = len(result["pages"])
    frame_ids = [page["pageInfo"]["frameId"] for page in result["pages"]]
    
    return CallToolResult(
        content=[
            TextContent(
                type="text", 
                text=f"✅ Frame节点提取成功！\n\n找到 {frame_count} 个Frame节点 (depth={max_depth}):\n" + "\n".join([f"- {page['pageInfo']['name']} (ID: {page['pageInfo']['frameId']})" for page in result["pages"]])
            )
        ]
    )

async def handle_list_nodes(arguments: Dict[str, Any]) -> CallToolResult:
    """处理节点列表获取"""
    file_key = arguments["file_key"]
    node_types = arguments.get("node_types", "")
    
    if not figma_server.node_lister:
        return CallToolResult(
            content=[TextContent(type="text", text="错误: 未设置 FIGMA_ACCESS_TOKEN")]
        )
    
    result = figma_server.node_lister.list_nodes(file_key, node_types, max_depth=2)
    if not result:
        return CallToolResult(
            content=[TextContent(type="text", text="获取节点列表失败")]
        )
    
    # 构建输出文本
    output_lines = [f"✅ 节点列表获取成功！\n"]
    output_lines.append(f"文件: {result['file_name']}")
    output_lines.append(f"总节点数: {result['total_nodes']} (depth=2)")
    
    if node_types:
        output_lines.append(f"过滤类型: {node_types}")
    
    output_lines.append("\n📋 节点列表:")
    
    # 按类型输出节点
    for node_type, nodes in result["nodes_by_type"].items():
        output_lines.append(f"\n📁 {node_type} ({len(nodes)} 个):")
        for node in nodes:
            indent = "  " * node["depth"]
            output_lines.append(f"{indent}- {node['name']} (ID: {node['id']})")
    
    return CallToolResult(
        content=[
            TextContent(
                type="text", 
                text="\n".join(output_lines)
            )
        ]
    )

async def main():
    """主函数"""
    # 检查环境变量
    if not os.getenv("FIGMA_ACCESS_TOKEN"):
        print("警告: 未设置 FIGMA_ACCESS_TOKEN 环境变量")
        print("请设置: export FIGMA_ACCESS_TOKEN='your_token_here'")
    
    # 启动MCP服务器
    async with stdio_server() as (read_stream, write_stream):
        await server.run(
            read_stream,
            write_stream,
            server.create_initialization_options(),
        )

if __name__ == "__main__":
    asyncio.run(main())
