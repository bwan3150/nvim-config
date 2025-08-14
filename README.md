# Neovim Config

个人Neovim配置, 基于 [NvChad](https://github.com/NvChad/NvChad) 进行定制, 用于设备间同步

## 安装

### 前置

- Neovim >= 0.9.0
- Git
- [Nerd Font](https://www.nerdfonts.com/)
- ripgrep (用于 telescope 搜索)
- Node.js (用于某些 LSP 服务器)

### 步骤

1. 克隆：
```bash
git clone https://github.com/bwan3150/nvim-config.git ~/.config/nvim
```

2. 启动 Neovim：
```bash
nvim
```

Lazy.nvim 会自动安装所有插件。

## 结构

```
~/.config/nvim/
├── init.lua                 # 入口文件
├── lua/
│   ├── chadrc.lua          # NvChad 主题和 UI 配置
│   ├── options.lua         # Neovim 选项设置
│   ├── mappings.lua        # 按键映射
│   ├── autocmds.lua        # 自动命令
│   ├── configs/
│   │   ├── lspconfig.lua   # LSP 配置
│   │   ├── conform.lua     # 代码格式化配置
│   │   └── lazy.lua        # 插件管理器配置
│   └── plugins/
│       └── init.lua        # 插件列表和配置
└── lazy-lock.json          # 插件版本锁定文件
```

## 更新

要更新插件，在 Neovim 中运行：
```
:Lazy sync
```

## Credits

- [NvChad](https://github.com/NvChad/NvChad) - 提供基础配置框架
- [LazyVim](https://github.com/LazyVim/starter) - 配置结构设计
