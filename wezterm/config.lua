-- wezterm/config.lua
local act = wezterm.action

-- 注意：此文件不定义 config，而是直接操作由模板注入的 config 对象
-- 同时它依赖由模板注入的 mod 变量

-- --------------------------------------------------------------------
-- 1. 基础布局与显示 (共用部分)
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
-- 2. 主题自适应 (共用函数)
-- --------------------------------------------------------------------
local function get_appearance()
  if wezterm.gui then return wezterm.gui.get_appearance() end
  return 'Dark'
end

local function scheme_for_appearance(appearance)
  return appearance:find 'Dark' and 'Catppuccin Macchiato' or 'Catppuccin Latte'
end

config.color_scheme = scheme_for_appearance(get_appearance())

-- --------------------------------------------------------------------
-- 3. 按键绑定 (共用键位，但 mods 使用动态注入的 mod)
-- --------------------------------------------------------------------
config.keys = {
    {
        key = 'w',
        mods = mod,
        action = act.CloseCurrentPane { confirm = false },
    },
    {
        key = 'd',
        mods = mod,
        action = act.SplitHorizontal { domain = 'CurrentPaneDomain' }
    },
    {
        key = 'd',
        mods = mod .. '|SHIFT',
        action = act.SplitVertical { domain = 'CurrentPaneDomain' }
    },
}

return config
