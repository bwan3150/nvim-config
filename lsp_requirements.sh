#!/usr/bin/env bash

set -e

# 颜色
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Installing LSP servers..."

# 1. 检查 Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}Error: Node.js is not installed!${NC}"
    echo -e "${YELLOW}Please install Node.js first:${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "  brew install node"
    else
        echo "  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -"
        echo "  sudo apt-get install -y nodejs"
    fi
    echo -e "${YELLOW}Or visit: https://nodejs.org${NC}"
    exit 1
fi

# 2. 安装 TypeScript 和 Pyright
echo "Installing TypeScript and Python LSP..."
npm install -g typescript typescript-language-server pyright

# 3. 安装 Rust Analyzer
echo "Installing rust-analyzer..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install rust-analyzer
else
    mkdir -p ~/.local/bin
    curl -L https://github.com/rust-lang/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz | gunzip -c - > ~/.local/bin/rust-analyzer
    chmod +x ~/.local/bin/rust-analyzer
fi

# 4. 安装 Lua Language Server
echo "Installing lua-language-server..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install lua-language-server
else
    # Linux 安装
    LUA_LS_VERSION="3.7.4"
    PLATFORM="linux-x64"
    mkdir -p ~/.local/bin
    cd /tmp
    wget "https://github.com/LuaLS/lua-language-server/releases/download/${LUA_LS_VERSION}/lua-language-server-${LUA_LS_VERSION}-${PLATFORM}.tar.gz"
    mkdir -p ~/.local/share/lua-language-server
    tar -xzf "lua-language-server-${LUA_LS_VERSION}-${PLATFORM}.tar.gz" -C ~/.local/share/lua-language-server
    ln -sf ~/.local/share/lua-language-server/bin/lua-language-server ~/.local/bin/lua-language-server
    rm "lua-language-server-${LUA_LS_VERSION}-${PLATFORM}.tar.gz"
fi

# 验证安装
echo -e "\n${GREEN}Checking installations:${NC}"
command -v tsserver &> /dev/null && echo -e "${GREEN}✓${NC} TypeScript" || echo -e "${RED}✗${NC} TypeScript"
command -v pyright &> /dev/null && echo -e "${GREEN}✓${NC} Python" || echo -e "${RED}✗${NC} Python"  
command -v rust-analyzer &> /dev/null && echo -e "${GREEN}✓${NC} Rust" || echo -e "${RED}✗${NC} Rust"
command -v lua-language-server &> /dev/null && echo -e "${GREEN}✓${NC} Lua" || echo -e "${RED}✗${NC} Lua"

echo -e "\n${GREEN}Done!${NC}"
echo "Make sure ~/.local/bin is in your PATH"
