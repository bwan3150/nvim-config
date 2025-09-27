#!/usr/bin/env bash

set -e

# 颜色
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# LSP 服务器列表
declare -a lsp_options=(
    "TypeScript/JavaScript"
    "Python (Pyright)"
    "Rust (rust-analyzer)"
    "Go (gopls)"
    "Lua"
    "Godot (GDScript)"
)

# 选中的 LSP 服务器
declare -a selected=()
for _ in "${lsp_options[@]}"; do
    selected+=("false")
done

# 显示菜单
show_menu() {
    clear
    echo -e "${BOLD}${BLUE}选择要安装的 LSP 服务器${NC}"
    echo -e "${YELLOW}使用 ↑↓ 方向键移动，空格键选择/取消选择，Enter 确认${NC}\n"

    for i in "${!lsp_options[@]}"; do
        if [ "$i" -eq "$current_position" ]; then
            echo -n "> "
        else
            echo -n "  "
        fi

        if [ "${selected[$i]}" == "true" ]; then
            echo -e "${GREEN}[✓]${NC} ${lsp_options[$i]}"
        else
            echo -e "[ ] ${lsp_options[$i]}"
        fi
    done

    echo -e "\n${BOLD}按 Enter 开始安装，按 q 退出${NC}"
}

# 交互式选择
current_position=0
while true; do
    show_menu

    # 读取单个字符
    IFS= read -rsn1 key

    # 处理转义序列（方向键等特殊键）
    if [[ $key == $'\e' ]]; then
        # 尝试读取更多字符（非阻塞）
        read -rsn2 -t 0.001 rest || true
        key="${key}${rest}"

        # 处理方向键
        case "$key" in
            $'\e[A'|$'\e0A'|$'\eOA')  # 上箭头的不同编码
                ((current_position--)) || true
                if [ "$current_position" -lt 0 ]; then
                    current_position=$((${#lsp_options[@]} - 1))
                fi
                ;;
            $'\e[B'|$'\e0B'|$'\eOB')  # 下箭头的不同编码
                ((current_position++)) || true
                if [ "$current_position" -ge "${#lsp_options[@]}" ]; then
                    current_position=0
                fi
                ;;
            *)
                # 忽略其他转义序列
                continue
                ;;
        esac
    elif [[ -z "$key" ]]; then
        # Enter 键
        break
    else
        case "$key" in
            ' ')  # 空格键
                if [ "${selected[$current_position]}" == "true" ]; then
                    selected[$current_position]="false"
                else
                    selected[$current_position]="true"
                fi
                ;;
            q|Q)  # 退出
                echo -e "\n${YELLOW}安装已取消${NC}"
                exit 0
                ;;
            *)
                # 忽略其他按键
                continue
                ;;
        esac
    fi
done

# 检查是否有选中的项目
has_selection=false
for s in "${selected[@]}"; do
    if [ "$s" == "true" ]; then
        has_selection=true
        break
    fi
done

if [ "$has_selection" == "false" ]; then
    echo -e "\n${YELLOW}未选择任何 LSP 服务器，退出安装${NC}"
    exit 0
fi

clear
echo -e "${BOLD}${GREEN}开始安装选中的 LSP 服务器...${NC}\n"

# 安装函数
install_typescript() {
    echo -e "${BLUE}安装 TypeScript/JavaScript LSP...${NC}"
    if ! command -v node &> /dev/null; then
        echo -e "${RED}错误: Node.js 未安装!${NC}"
        echo -e "${YELLOW}请先安装 Node.js:${NC}"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo "  brew install node"
        else
            echo "  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -"
            echo "  sudo apt-get install -y nodejs"
        fi
        return 1
    fi
    npm install -g typescript typescript-language-server
    echo -e "${GREEN}✓ TypeScript/JavaScript LSP 安装完成${NC}\n"
}

install_python() {
    echo -e "${BLUE}安装 Python LSP (Pyright)...${NC}"
    if ! command -v node &> /dev/null; then
        echo -e "${RED}错误: Node.js 未安装! Pyright 需要 Node.js${NC}"
        return 1
    fi
    npm install -g pyright
    echo -e "${GREEN}✓ Python LSP 安装完成${NC}\n"
}

install_rust() {
    echo -e "${BLUE}安装 Rust Analyzer...${NC}"
    if command -v rustup &> /dev/null; then
        rustup component add rust-analyzer
    else
        echo -e "${YELLOW}警告: rustup 未找到，尝试其他安装方式${NC}"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install rust-analyzer
        else
            mkdir -p ~/.local/bin
            curl -L https://github.com/rust-lang/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz | gunzip -c - > ~/.local/bin/rust-analyzer
            chmod +x ~/.local/bin/rust-analyzer
        fi
    fi
    echo -e "${GREEN}✓ Rust Analyzer 安装完成${NC}\n"
}

install_go() {
    echo -e "${BLUE}安装 Go LSP (gopls)...${NC}"
    if ! command -v go &> /dev/null; then
        echo -e "${RED}错误: Go 未安装!${NC}"
        echo -e "${YELLOW}请先安装 Go 语言环境:${NC}"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo "  brew install go"
        else
            echo "  sudo apt install golang-go  # Debian/Ubuntu"
            echo "  或访问 https://golang.org/dl/ 下载安装"
        fi
        return 1
    fi

    go install golang.org/x/tools/gopls@latest
    # 检查 gopls 是否在 PATH 中
    if ! command -v gopls &> /dev/null; then
        if [ -f "$HOME/go/bin/gopls" ]; then
            echo -e "${YELLOW}gopls 已安装但不在 PATH 中，创建软链接...${NC}"
            mkdir -p ~/.local/bin
            ln -sf "$HOME/go/bin/gopls" ~/.local/bin/gopls
            echo -e "${GREEN}✓ gopls 软链接已创建${NC}"
        fi
    fi
    echo -e "${GREEN}✓ Go LSP 安装完成${NC}\n"
}

install_lua() {
    echo -e "${BLUE}安装 Lua Language Server...${NC}"
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
        cd - > /dev/null
    fi
    echo -e "${GREEN}✓ Lua Language Server 安装完成${NC}\n"
}

install_godot() {
    echo -e "${BLUE}配置 Godot LSP...${NC}"
    echo -e "${YELLOW}注意: Godot LSP 服务器内置在 Godot 编辑器中${NC}"
    echo -e "${YELLOW}请在 Godot 编辑器中启用 LSP:${NC}"
    echo -e "  1. 打开 Godot 编辑器"
    echo -e "  2. 进入 编辑器设置 -> 网络 -> 语言服务器"
    echo -e "  3. 启用 '使用外部编辑器时启用语言服务器'"
    echo -e "  4. 端口默认为 6005 (可在设置中修改)"
    echo -e "${GREEN}✓ Godot LSP 配置说明已显示${NC}\n"
}

# 执行安装
for i in "${!selected[@]}"; do
    if [ "${selected[$i]}" == "true" ]; then
        case "${lsp_options[$i]}" in
            "TypeScript/JavaScript")
                install_typescript || true
                ;;
            "Python (Pyright)")
                install_python || true
                ;;
            "Rust (rust-analyzer)")
                install_rust || true
                ;;
            "Go (gopls)")
                install_go || true
                ;;
            "Lua")
                install_lua || true
                ;;
            "Godot (GDScript)")
                install_godot || true
                ;;
        esac
    fi
done

# 验证安装结果
echo -e "${BOLD}${BLUE}验证安装结果:${NC}"
if [ "${selected[0]}" == "true" ]; then
    command -v tsserver &> /dev/null && echo -e "${GREEN}✓${NC} TypeScript" || echo -e "${RED}✗${NC} TypeScript"
fi
if [ "${selected[1]}" == "true" ]; then
    command -v pyright &> /dev/null && echo -e "${GREEN}✓${NC} Python" || echo -e "${RED}✗${NC} Python"
fi
if [ "${selected[2]}" == "true" ]; then
    command -v rust-analyzer &> /dev/null && echo -e "${GREEN}✓${NC} Rust" || echo -e "${RED}✗${NC} Rust"
fi
if [ "${selected[3]}" == "true" ]; then
    (command -v gopls &> /dev/null || [ -f "$HOME/.local/bin/gopls" ] || [ -f "$HOME/go/bin/gopls" ]) && echo -e "${GREEN}✓${NC} Go" || echo -e "${RED}✗${NC} Go"
fi
if [ "${selected[4]}" == "true" ]; then
    command -v lua-language-server &> /dev/null && echo -e "${GREEN}✓${NC} Lua" || echo -e "${RED}✗${NC} Lua"
fi
if [ "${selected[5]}" == "true" ]; then
    echo -e "${YELLOW}!${NC} Godot LSP 需要在 Godot 编辑器中手动启用"
fi

echo -e "\n${GREEN}安装完成!${NC}"
echo -e "${YELLOW}提示: 确保 ~/.local/bin 和 ~/go/bin 在你的 PATH 中${NC}"
echo -e "${YELLOW}对于 Go: export PATH=\$PATH:~/go/bin${NC}"
