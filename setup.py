#!/usr/bin/env python3
"""
Figma MCP Server Setup
"""

from setuptools import setup, find_packages
import os

# 读取README文件
def read_readme():
    with open("README.md", "r", encoding="utf-8") as fh:
        return fh.read()

# 读取requirements文件
def read_requirements():
    with open("requirements.txt", "r", encoding="utf-8") as fh:
        return [line.strip() for line in fh if line.strip() and not line.startswith("#")]

setup(
    name="figma-mcp-server",
    version="1.0.0",
    author="Your Name",
    author_email="your.email@example.com",
    description="A Model Context Protocol (MCP) server for Figma integration",
    long_description=read_readme(),
    long_description_content_type="text/markdown",
    url="https://github.com/yourusername/figma-mcp-server",
    packages=find_packages(),
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Programming Language :: Python :: 3.12",
    ],
    python_requires=">=3.10",
    install_requires=read_requirements(),
    entry_points={
        "console_scripts": [
            "figma-mcp-server=figma_mcp_server.cli:main",
        ],
    },
    include_package_data=True,
    package_data={
        "figma_mcp_server": ["*.json"],
    },
    keywords="figma, mcp, model-context-protocol, design, api",
    project_urls={
        "Bug Reports": "https://github.com/yourusername/figma-mcp-server/issues",
        "Source": "https://github.com/yourusername/figma-mcp-server",
        "Documentation": "https://github.com/yourusername/figma-mcp-server#readme",
    },
)
