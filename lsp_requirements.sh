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
if command -v rustup &> /dev/null; then
    rustup component add rust-analyzer
else
    echo -e "${RED}Warning: rustup not found, falling back to manual installation${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install rust-analyzer
    else
        mkdir -p ~/.local/bin
        curl -L https://github.com/rust-lang/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz | gunzip -c - > ~/.local/bin/rust-analyzer
        chmod +x ~/.local/bin/rust-analyzer
    fi
fi

# 4. 安装 Go Language Server (gopls)
echo "Installing gopls..."
if command -v go &> /dev/null; then
    go install golang.org/x/tools/gopls@latest
    echo -e "${GREEN}✓${NC} gopls installed via go install"
else
    echo -e "${YELLOW}Warning: Go not found. Installing gopls via npm...${NC}"
    npm install -g gopls
fi

# 5. 安装 Godot LSP (通过 Godot 编辑器内置)
echo "Configuring Godot LSP..."
echo -e "${YELLOW}Note: Godot LSP 服务器内置在 Godot 编辑器中${NC}"
echo -e "${YELLOW}请在 Godot 编辑器中启用 LSP:${NC}"
echo -e "  1. 打开 Godot 编辑器"
echo -e "  2. 进入 编辑器设置 -> 网络 -> 语言服务器"
echo -e "  3. 启用 '使用外部编辑器时启用语言服务器'"
echo -e "  4. 端口默认为 6005 (可在设置中修改)"
echo -e "${GREEN}✓${NC} Godot LSP 配置说明已显示"

# 6. 安装 Lua Language Server
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
command -v gopls &> /dev/null && echo -e "${GREEN}✓${NC} Go" || echo -e "${RED}✗${NC} Go"
command -v lua-language-server &> /dev/null && echo -e "${GREEN}✓${NC} Lua" || echo -e "${RED}✗${NC} Lua"
echo -e "${YELLOW}!${NC} Godot LSP 需要在 Godot 编辑器中手动启用"

echo -e "\n${GREEN}Done!${NC}"
echo "Make sure ~/.local/bin and ~/go/bin are in your PATH"
echo "For Go: export PATH=$PATH:~/go/bin"
