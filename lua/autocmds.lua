require "nvchad.autocmds"

-- 自定义的 fcitx5 输入法切换
local previous_im = "keyboard-us"  -- 保存之前的输入法

local function get_current_im()
  if vim.fn.has("unix") == 1 and vim.fn.has("macunix") == 0 then
    -- Linux fcitx5
    local result = vim.fn.system("fcitx5-remote -n"):gsub("%s+", "")
    return result
  elseif vim.fn.has("macunix") == 1 then
    -- macOS
    local result = vim.fn.system("macism"):gsub("%s+", "")
    return result
  end
  return "keyboard-us"
end

local function switch_to_english()
  -- 保存当前输入法
  previous_im = get_current_im()

  if vim.fn.has("unix") == 1 and vim.fn.has("macunix") == 0 then
    -- Linux fcitx5
    vim.fn.system("fcitx5-remote -s keyboard-us")
  elseif vim.fn.has("macunix") == 1 then
    -- macOS
    vim.fn.system("macism com.apple.keylayout.ABC")
  end
end

local function restore_previous_im()
  if previous_im and previous_im ~= "keyboard-us" and previous_im ~= "com.apple.keylayout.ABC" then
    if vim.fn.has("unix") == 1 and vim.fn.has("macunix") == 0 then
      -- Linux fcitx5 - 恢复之前的输入法
      vim.fn.system("fcitx5-remote -s " .. previous_im)
    elseif vim.fn.has("macunix") == 1 then
      -- macOS - 恢复之前的输入法
      vim.fn.system("macism " .. previous_im)
    end
  end
end

-- 创建自动命令组
local augroup = vim.api.nvim_create_augroup("InputMethodSwitch", { clear = true })

-- 退出插入模式时切换到英文
vim.api.nvim_create_autocmd({ "InsertLeave", "CmdlineLeave" }, {
  group = augroup,
  callback = switch_to_english,
})

-- 进入插入模式时恢复之前的输入法
vim.api.nvim_create_autocmd("InsertEnter", {
  group = augroup,
  callback = restore_previous_im,
})

-- nvim 启动时切换到英文
vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup,
  callback = switch_to_english,
})
