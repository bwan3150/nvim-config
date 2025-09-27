return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },
  
  -- 修复 nvim-cmp 配置来解决 LSP 错误
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
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      defaults = {
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden",        -- 搜索隐藏文件
          "--no-ignore",     -- 不遵循 .gitignore
        },
      },
    pickers = {
      find_files = {
        find_command = { "rg", "--files", "--hidden", "--no-ignore" },
      },
    },
  },
},

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        "lua", "vim", "vimdoc", "html", "css",
        "javascript", "typescript", "python", "c", "cpp", "json", "bash",
        "markdown", "markdown_inline"  -- 添加 markdown 支持 LSP hover 文档
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

  -- In-editor markdown rendering
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = { "markdown" },
    config = function()
      require("render-markdown").setup({
        -- Configuration for rendering
        code = {
          enabled = true,
          sign = false,
          style = "full",
          position = "left",
          language_pad = 0,
          disable_background = { "diff" },
        },
        heading = {
          enabled = true,
          sign = true,
          position = "overlay",
          icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
          signs = { "󰫎 " },
          width = "full",
          left_pad = 0,
          right_pad = 0,
          min_width = 0,
          border = false,
          border_prefix = false,
          above = "▄",
          below = "▀",
        },
        bullet = {
          enabled = true,
          icons = { "●", "○", "◆", "◇" },
          left_pad = 0,
          right_pad = 0,
        },
        checkbox = {
          enabled = true,
          unchecked = {
            icon = "󰄱 ",
            highlight = "RenderMarkdownUnchecked",
          },
          checked = {
            icon = "󰱒 ",
            highlight = "RenderMarkdownChecked",
          },
          custom = {
            todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
          },
        },
        quote = {
          enabled = true,
          icon = "▋",
          repeat_linebreak = false,
        },
        table = {
          enabled = true,
          style = "full",
          cell = "padded",
          min_width = 0,
          border = {
            "┌", "┬", "┐",
            "├", "┼", "┤",
            "└", "┴", "┘",
            "│", "─",
          },
        },
      })
    end,
  },

  -- Image display in neovim
  {
    "3rd/image.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    lazy = false, -- 不延迟加载
    priority = 100, -- 确保早期加载
    config = function()
      local image = require("image")
      image.setup({
        backend = "kitty", -- 支持 kitty, ueberzug, chafa 等终端
        integrations = {
          markdown = {
            enabled = true,
            clear_in_insert_mode = false,
            download_remote_images = true,
            only_render_image_at_cursor = false,
            filetypes = { "markdown", "vimwiki" },
          },
          neorg = {
            enabled = true,
            clear_in_insert_mode = false,
            download_remote_images = true,
            only_render_image_at_cursor = false,
            filetypes = { "norg" },
          },
        },
        max_width = nil,
        max_height = nil,
        max_width_window_percentage = nil,
        max_height_window_percentage = 50,
        window_overlap_clear_enabled = false,
        window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
        editor_only_render_when_focused = false,
        tmux_show_only_in_active_window = false,
        hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.svg" },
      })

      -- 延迟启用图片显示，确保插件完全加载
      vim.defer_fn(function()
        image.enable()
      end, 100)

      -- 创建自动命令组
      local augroup = vim.api.nvim_create_augroup("ImageNvim", { clear = true })

      -- 为所有支持的文件类型添加自动命令
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        group = augroup,
        pattern = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.svg" },
        callback = function(args)
          vim.defer_fn(function()
            if image.is_enabled() then
              image.hijack_buffer(args.buf)
            else
              image.enable()
              vim.defer_fn(function()
                image.hijack_buffer(args.buf)
              end, 50)
            end
          end, 50)
        end,
      })

      -- 为 markdown 文件添加额外处理
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        group = augroup,
        pattern = { "*.md", "*.markdown" },
        callback = function()
          vim.defer_fn(function()
            if not image.is_enabled() then
              image.enable()
            end
          end, 100)
        end,
      })
    end,
  },
}
