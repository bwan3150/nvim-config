vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    vim.g.nvchad_colorify = false
  end,
  once = true,
})

local lspconfig = require("lspconfig")
local nvlsp = require("nvchad.configs.lspconfig")

-- TypeScript/JavaScript
lspconfig.ts_ls.setup {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
}

-- Python (支持 conda 环境)
local function get_python_path()
  -- 优先使用 conda 环境
  local conda_prefix = os.getenv("CONDA_PREFIX")
  if conda_prefix then
    return conda_prefix .. "/bin/python"
  end
  -- 其次使用虚拟环境
  local venv = os.getenv("VIRTUAL_ENV")
  if venv then
    return venv .. "/bin/python"
  end
  -- 最后回退到系统 Python
  return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
end

lspconfig.pyright.setup {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  settings = {
    python = {
      pythonPath = get_python_path(),
    },
  },
}

-- Rust
lspconfig.rust_analyzer.setup {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        loadOutDirsFromCheck = true,
      },
      procMacro = {
        enable = true,
      },
    },
  },
}

-- Lua (为 Neovim 配置优化)
lspconfig.lua_ls.setup {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
}

-- Go
lspconfig.gopls.setup {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
      gofumpt = true,
      usePlaceholders = true,
      completeUnimported = true,
    },
  },
}

-- Godot (GDScript)
lspconfig.gdscript.setup {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  -- Godot LSP 默认端口为 6005
  -- 需要在 Godot 编辑器中启用 LSP 服务器
  -- 项目设置 -> 网络 -> 语言服务器 -> 启用
  cmd = { "nc", "localhost", "6005" },
}
