return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },
  
  -- 修复 NvChad colorify 的 LSP 错误
  {
    "NvChad/ui",
    config = function()
      -- 延迟加载并修复 colorify  -- 修复 NvChad colorify 的 LSP 错误
  {
    "NvChad/ui",
    config = function()
      -- 延迟加载并修复 colorify
      vim.defer_fn(function()
        local ok, colorify = pcall(require, "nvchad.colorify")
        if ok then
          -- 重写有问题的函数
          local original_lsp_var = colorify.lsp_var
          colorify.lsp_var = function(bufnr, ...)
            -- 确保 bufnr 是数字
            local buf = type(bufnr) == "number" and bufnr or vim.api.nvim_get_current_buf()
            return original_lsp_var(buf, ...)
          end
        end
      end, 100)
    end,
  },
      vim.defer_fn(function()
        local ok, colorify = pcall(require, "nvchad.colorify")
        if ok then
          -- 重写有问题的函数
          local original_lsp_var = colorify.lsp_var
          colorify.lsp_var = function(bufnr, ...)
            -- 确保 bufnr 是数字
            local buf = type(bufnr) == "number" and bufnr or vim.api.nvim_get_current_buf()
            return original_lsp_var(buf, ...)
          end
        end
      end, 100)
    end,
  },

  -- 添加这个 nvim-cmp 配置来修复错误
  {
    "hrsh7th/nvim-cmp",
    opts = function()
      local cmp = require "cmp"
      return {
        completion = {
          autocomplete = false,  -- 临时禁用自动完成避免错误
        },
        mapping = {
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.close(),
          ["<CR>"] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
          },
        },
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "nvim_lua" },
          { name = "path" },
        },
      }
    end,
  },
  
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        "lua", "vim", "vimdoc", "html", "css",
        "javascript", "typescript", "python", "c", "cpp", "json", "bash"
      },
      highlight = { enable = true },
      indent = { enable = true },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "macchiato",
        transparent_background = true,
        integrations = {
          nvimtree = true,
          treesitter = true,
          native_lsp = { enabled = true },
        },
      })
      vim.cmd.colorscheme "catppuccin-macchiato"
    end,
  },
}
