require("nvchad.configs.lspconfig").defaults()

-- 添加更多服务器
local servers = { 
  "html", 
  "cssls", 
  "ts_ls",        -- TypeScript/JavaScript
  "pyright"       -- Python
}

vim.lsp.enable(servers)

-- 如果需要特殊配置，可以这样：
local lspconfig = require "lspconfig"

-- Python 特殊配置
lspconfig.pyright.setup {
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "workspace",
        useLibraryCodeForTypes = true,
      },
    },
  },
}

-- JavaScript/TypeScript 特殊配置（可选）
lspconfig.ts_ls.setup {
  -- 可以添加特殊设置
}
