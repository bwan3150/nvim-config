-- 添加更多服务器
local servers = { 
  "html", 
  "cssls"
}

local lspconfig = require "lspconfig"

-- 为基本服务器设置配置
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {}
end

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

-- JavaScript/TypeScript 特殊配置
lspconfig.ts_ls.setup {
  -- 可以添加特殊设置
}
