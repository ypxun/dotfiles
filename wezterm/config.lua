-- wezterm/config.lua
local wezterm = require 'wezterm'
local act = wezterm.action

-- --------------------------------------------------------------------
-- 1. 基础布局与显示
-- --------------------------------------------------------------------
config.initial_cols = 105
config.initial_rows = 28
config.font = wezterm.font_with_fallback({
    "JetBrainsMono Nerd Font",
    "JetBrains Mono",
})

config.window_decorations = 'RESIZE'
config.window_close_confirmation = 'NeverPrompt'

-- --------------------------------------------------------------------
-- 2. 主题自适应
-- --------------------------------------------------------------------
local function get_appearance()
  if wezterm.gui then return wezterm.gui.get_appearance() end
  return 'Dark'
end

local function scheme_for_appearance(appearance)
  -- 自动切换 Catppuccin 主题
  return appearance:find 'Dark' and 'Catppuccin Macchiato' or 'Catppuccin Latte'
end

config.color_scheme = scheme_for_appearance(get_appearance())

-- --------------------------------------------------------------------
-- 3. 按键绑定 (Tmux 风格)
-- --------------------------------------------------------------------
config.leader = { key = '\\', mods = 'CTRL', timeout_milliseconds = 100000 }
config.keys = {
  -- 1. 逃逸：按两次 Ctrl+w 发送原始 Ctrl+w 给应用 (比如在 Vim 里使用)
  { key = '\\', mods = 'LEADER|CTRL', action = act.SendKey { key = '\\', mods = 'CTRL' } },

  -- 2. 窗口分屏 (对齐 Tmux 默认键位)
  { key = '%', mods = 'LEADER|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '"', mods = 'LEADER|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'z', mods = 'LEADER',       action = act.TogglePaneZoomState },
  { key = 'x', mods = 'LEADER',       action = act.CloseCurrentPane { confirm = true } },

  -- 3. 窗格 (Pane) 导航与缩放 (HJKL 风格)
  { key = "h", mods = "LEADER",       action = act.ActivatePaneDirection "Left" },
  { key = "j", mods = "LEADER",       action = act.ActivatePaneDirection "Down" },
  { key = "k", mods = "LEADER",       action = act.ActivatePaneDirection "Up" },
  { key = "l", mods = "LEADER",       action = act.ActivatePaneDirection "Right" },
  { key = "H", mods = "LEADER|SHIFT", action = act.AdjustPaneSize { "Left", 5 } },
  { key = "J", mods = "LEADER|SHIFT", action = act.AdjustPaneSize { "Down", 5 } },
  { key = "K", mods = "LEADER|SHIFT", action = act.AdjustPaneSize { "Up", 5 } },
  { key = "L", mods = "LEADER|SHIFT", action = act.AdjustPaneSize { "Right", 5 } },

  -- 4. 标签页 (Tab) 管理
  { key = 'c', mods = 'LEADER',       action = act.SpawnTab 'CurrentPaneDomain' },
  { key = '&', mods = 'LEADER|SHIFT', action = act.CloseCurrentTab { confirm = true } },
  
  -- 修正后的 ActivateTab 语法 (索引从 0 开始)
  { key = '1', mods = 'LEADER',       action = act.ActivateTab(0) },
  { key = '2', mods = 'LEADER',       action = act.ActivateTab(1) },
  { key = '3', mods = 'LEADER',       action = act.ActivateTab(2) },
  { key = '4', mods = 'LEADER',       action = act.ActivateTab(3) },
  { key = '5', mods = 'LEADER',       action = act.ActivateTab(4) },
  { key = '6', mods = 'LEADER',       action = act.ActivateTab(5) },
  { key = '7', mods = 'LEADER',       action = act.ActivateTab(6) },
  { key = '8', mods = 'LEADER',       action = act.ActivateTab(7) },
  { key = '9', mods = 'LEADER',       action = act.ActivateTab(8) },

  -- 6. 字体缩放
  { key = '=', mods = 'LEADER',       action = act.IncreaseFontSize },
  { key = '-', mods = 'LEADER',       action = act.DecreaseFontSize },
  { key = '0', mods = 'LEADER',       action = act.ResetFontSize },
}

return config