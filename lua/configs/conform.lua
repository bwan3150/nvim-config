local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    
    -- JavaScript/TypeScript
    javascript = { "prettier" },
    typescript = { "prettier" },
    javascriptreact = { "prettier" },
    typescriptreact = { "prettier" },
    
    -- Python
    python = { "black" },
    
    -- Web
    css = { "prettier" },
    html = { "prettier" },
    json = { "prettier" },
    yaml = { "prettier" },
    markdown = { "prettier" },
  },

  -- 启用保存时格式化
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
