local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- 添加更多服务器
local servers = { 
  "html", 
  "cssls",
  "ts_ls"
}

local lspconfig = require "lspconfig"

-- 为基本服务器设置配置
for _, lsp in ipairs(servers) do
  if lsp == "ts_ls" then
    lspconfig[lsp].setup {
      capabilities = capabilities,  -- 添加这行
      settings = {
        -- 你的设置...
      }
    }
  else
    lspconfig[lsp].setup {
      capabilities = capabilities   -- 添加这行
    }
  end
end

-- Python 特殊配置
lspconfig.pyright.setup {
  capabilities = capabilities,      -- 添加这行
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
