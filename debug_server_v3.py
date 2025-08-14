#!/usr/bin/env python3
"""
调试服务器响应 v3
添加更详细的日志和错误处理
"""

import os
import sys
import json
import asyncio
import subprocess
import threading
import time
import signal
from pathlib import Path

# 添加项目路径
project_root = Path(__file__).parent
sys.path.insert(0, str(project_root))

class DebugServerV3:
    """调试服务器 v3"""
    
    def __init__(self, server_command: str, env: dict):
        self.server_command = server_command
        self.env = env
        self.process = None
        self.stderr_output = []
        self.stdout_output = []
        self.request_count = 0
    
    async def start_server(self):
        """启动服务器"""
        print(f"🚀 启动服务器: {self.server_command}")
        
        self.process = subprocess.Popen(
            self.server_command.split(),
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=self.env,
            text=True,
            bufsize=1
        )
        
        print(f"✅ 服务器进程已启动 (PID: {self.process.pid})")
        
        # 启动日志监听线程
        self.stderr_thread = threading.Thread(target=self._capture_stderr)
        self.stderr_thread.daemon = True
        self.stderr_thread.start()
        
        self.stdout_thread = threading.Thread(target=self._capture_stdout)
        self.stdout_thread.daemon = True
        self.stdout_thread.start()
    
    def _capture_stderr(self):
        """捕获 stderr"""
        while self.process and self.process.poll() is None:
            try:
                line = self.process.stderr.readline()
                if line:
                    self.stderr_output.append(line.strip())
                    print(f"🔍 stderr: {line.strip()}")
            except Exception as e:
                print(f"❌ stderr 捕获错误: {e}")
                break
    
    def _capture_stdout(self):
        """捕获 stdout"""
        while self.process and self.process.poll() is None:
            try:
                line = self.process.stdout.readline()
                if line:
                    self.stdout_output.append(line.strip())
                    print(f"📤 stdout: {line.strip()}")
            except Exception as e:
                print(f"❌ stdout 捕获错误: {e}")
                break
    
    def send_request(self, request: dict, timeout: float = 10.0) -> dict:
        """发送请求"""
        self.request_count += 1
        request_str = json.dumps(request) + "\n"
        print(f"\n📤 发送请求 #{self.request_count}:")
        print(json.dumps(request, indent=2))
        
        try:
            # 发送请求
            self.process.stdin.write(request_str)
            self.process.stdin.flush()
            
            # 等待响应
            start_time = time.time()
            while time.time() - start_time < timeout:
                # 检查进程是否还在运行
                if self.process.poll() is not None:
                    print(f"❌ 服务器进程已退出 (exit code: {self.process.returncode})")
                    return {"error": {"code": -1, "message": "Server process exited"}}
                
                # 检查是否有新的 stdout 输出
                if len(self.stdout_output) > 0:
                    response_line = self.stdout_output.pop(0)
                    try:
                        response = json.loads(response_line)
                        print(f"\n📥 收到响应 #{self.request_count}:")
                        print(json.dumps(response, indent=2))
                        return response
                    except json.JSONDecodeError:
                        print(f"❌ 无法解析响应: {response_line}")
                        continue
                time.sleep(0.1)
            
            print(f"⏰ 请求 #{self.request_count} 超时 ({timeout}秒)")
            return {"error": {"code": -1, "message": "Request timeout"}}
            
        except Exception as e:
            print(f"❌ 发送请求 #{self.request_count} 失败: {e}")
            return {"error": {"code": -1, "message": str(e)}}
    
    async def stop_server(self):
        """停止服务器"""
        if self.process:
            print(f"\n🛑 停止服务器进程 (PID: {self.process.pid})...")
            self.process.terminate()
            try:
                self.process.wait(timeout=5)
                print("✅ 服务器已停止")
            except subprocess.TimeoutExpired:
                print("⚠️  强制停止服务器")
                self.process.kill()
                self.process.wait()

async def main():
    """主函数"""
    print("🔍 调试服务器响应 v3")
    print("=" * 60)
    
    # 检查环境变量
    access_token = os.getenv("FIGMA_ACCESS_TOKEN")
    if not access_token:
        print("❌ 错误: 未设置 FIGMA_ACCESS_TOKEN 环境变量")
        return
    
    print(f"✅ Figma 访问令牌已设置: {access_token[:10]}...{access_token[-4:]}")
    
    # 获取服务器命令路径
    server_command = "figma-mcp-tools"
    
    try:
        result = subprocess.run(["which", server_command], capture_output=True, text=True)
        if result.returncode == 0:
            server_command = result.stdout.strip()
            print(f"✅ 找到服务器命令: {server_command}")
        else:
            print(f"❌ 找不到服务器命令: {server_command}")
            return
    except Exception as e:
        print(f"❌ 检查服务器命令失败: {e}")
        return
    
    # 创建调试器
    env = os.environ.copy()
    env["FIGMA_ACCESS_TOKEN"] = access_token
    debugger = DebugServerV3(server_command, env)
    
    try:
        # 启动服务器
        await debugger.start_server()
        
        # 等待服务器启动
        await asyncio.sleep(2)
        
        # 检查服务器进程状态
        if debugger.process.poll() is not None:
            print(f"❌ 服务器进程已退出 (exit code: {debugger.process.returncode})")
            return
        
        # 发送初始化请求
        init_request = {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "initialize",
            "params": {
                "protocolVersion": "2024-11-05",
                "capabilities": {
                    "tools": {
                        "listChanged": False
                    }
                },
                "clientInfo": {
                    "name": "debug-client-v3",
                    "version": "1.0.0"
                }
            }
        }
        
        response = debugger.send_request(init_request, timeout=15.0)
        
        if "error" in response:
            print(f"❌ 初始化失败: {response['error']}")
            return
        
        print("✅ 初始化成功")
        
        # 发送初始化完成通知
        init_notification = {
            "jsonrpc": "2.0",
            "method": "notifications/initialized",
            "params": {}
        }
        
        print("📤 发送初始化完成通知...")
        response = debugger.send_request(init_notification, timeout=5.0)
        print("✅ 初始化完成通知已发送")
        
        # 等待一下再发送下一个请求
        await asyncio.sleep(1)
        
        # 发送工具列表请求
        tools_request = {
            "jsonrpc": "2.0",
            "id": 2,
            "method": "tools/list",
            "params": {}
        }
        
        response = debugger.send_request(tools_request, timeout=15.0)
        
        if "error" in response:
            print(f"❌ 获取工具列表失败: {response['error']}")
        else:
            result = response.get("result", {})
            tools = result.get("tools", [])
            print(f"\n🎉 成功获取到 {len(tools)} 个工具:")
            for i, tool in enumerate(tools, 1):
                print(f"   {i}. {tool['name']}: {tool.get('title', 'N/A')}")
            
            # 测试工具调用
            await asyncio.sleep(1)
            
            # 测试节点列表工具
            print(f"\n🧪 测试工具调用: list_nodes_depth2")
            list_request = {
                "jsonrpc": "2.0",
                "id": 3,
                "method": "tools/call",
                "params": {
                    "name": "list_nodes_depth2",
                    "arguments": {
                        "file_key": "5F45MIt6BVWBIZCEkA0do3",
                        "node_types": ""
                    }
                }
            }
            
            response = debugger.send_request(list_request, timeout=30.0)
            if "error" in response:
                print(f"❌ 节点列表工具调用失败: {response['error']}")
            else:
                print(f"✅ 节点列表工具调用成功")
                result = response.get("result", {})
                content = result.get("content", [])
                if content and len(content) > 0:
                    text_content = content[0].get("text", "")
                    print(f"📄 响应内容: {text_content[:200]}...")
            
            # 测试框架提取工具
            await asyncio.sleep(1)
            print(f"\n🧪 测试工具调用: extract_frame_nodes")
            frame_request = {
                "jsonrpc": "2.0",
                "id": 4,
                "method": "tools/call",
                "params": {
                    "name": "extract_frame_nodes",
                    "arguments": {
                        "file_key": "5F45MIt6BVWBIZCEkA0do3",
                        "max_depth": 2
                    }
                }
            }
            
            response = debugger.send_request(frame_request, timeout=30.0)
            if "error" in response:
                print(f"❌ 框架提取工具调用失败: {response['error']}")
            else:
                print(f"✅ 框架提取工具调用成功")
                result = response.get("result", {})
                content = result.get("content", [])
                if content and len(content) > 0:
                    text_content = content[0].get("text", "")
                    print(f"📄 响应内容: {text_content[:200]}...")
            
            # 测试完整数据获取工具
            await asyncio.sleep(1)
            print(f"\n🧪 测试工具调用: get_complete_node_data")
            complete_request = {
                "jsonrpc": "2.0",
                "id": 5,
                "method": "tools/call",
                "params": {
                    "name": "get_complete_node_data",
                    "arguments": {
                        "file_key": "5F45MIt6BVWBIZCEkA0do3",
                        "node_ids": "0:0,0:1",
                        "image_format": "png",
                        "image_scale": 1.0,
                        "tree_depth": 3
                    }
                }
            }
            
            response = debugger.send_request(complete_request, timeout=60.0)
            if "error" in response:
                print(f"❌ 完整数据获取工具调用失败: {response['error']}")
            else:
                print(f"✅ 完整数据获取工具调用成功")
                result = response.get("result", {})
                content = result.get("content", [])
                if content and len(content) > 0:
                    text_content = content[0].get("text", "")
                    print(f"📄 响应内容: {text_content[:200]}...")
        
    except Exception as e:
        print(f"❌ 调试过程中出错: {e}")
        import traceback
        traceback.print_exc()
    
    finally:
        # 停止服务器
        await debugger.stop_server()
        
        # 显示所有日志
        print(f"\n📋 完整日志:")
        print("stderr:")
        for log in debugger.stderr_output:
            print(f"   {log}")
        print("stdout:")
        for log in debugger.stdout_output:
            print(f"   {log}")

if __name__ == "__main__":
    asyncio.run(main())
