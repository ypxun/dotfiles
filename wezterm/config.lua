local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local act = wezterm.action

-- --------------------------------------------------------------------
-- 1. 环境识别变量
-- --------------------------------------------------------------------
local is_windows = wezterm.target_triple:find("windows") ~= nil
local is_mac = wezterm.target_triple:find("apple") ~= nil

-- --------------------------------------------------------------------
-- 2. 基础布局与显示
-- --------------------------------------------------------------------
config.initial_cols = 120
config.initial_rows = 40
-- 更加严谨的跨平台字体匹配
-- local font_name = is_mac and "JetBrainsMono Nerd Font" or "MesloLGS Nerd Font"

config.font = wezterm.font_with_fallback({
  "JetBrainsMono Nerd Font",         -- 根据平台自动选择最准确的名字
  "JetBrains Mono",  -- 保底
})
config.font_size = is_mac and 13 or 11 -- Mac 用 13，Win 用 11 视觉上更接近

-- 去除标题栏 (Mac 下 RESIZE 很漂亮，Windows 下可能需要视情况调整)
config.window_decorations = 'RESIZE'
config.window_close_confirmation = 'NeverPrompt'

-- --------------------------------------------------------------------
-- 3. 主题自适应逻辑
-- --------------------------------------------------------------------
function get_appearance()
  if wezterm.gui then
    return wezterm.gui.get_appearance()
  end
  return 'Dark'
end

function scheme_for_appearance(appearance)
  if appearance:find 'Dark' then
    return 'BlulocoDark'
  else
    return 'BlulocoLight'
  end
end

config.color_scheme = scheme_for_appearance(get_appearance())

-- --------------------------------------------------------------------
-- 4. 按键绑定 (关键兼容性处理)
-- --------------------------------------------------------------------
local mod = is_mac and 'CMD' or 'ALT' -- Windows 下将 CMD 操作映射到 ALT 键

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
        mods = mod .. '|SHIFT', -- 拼接 CMD|SHIFT 或 ALT|SHIFT
        action = act.SplitVertical { domain = 'CurrentPaneDomain' }
    },
}

-- --------------------------------------------------------------------
-- 5. Windows 专有设置 (如默认启动 WSL)
-- --------------------------------------------------------------------
if is_windows then
  config.default_prog = { 'wsl.exe', '-d', 'Arch', '--cd', '~' }
  config.launch_menu = {
        {
            label = 'Arch Linux (Default)',
            args = { 'wsl.exe', '-d', 'Arch', '--cd', '~' },
        },
        {
            label = 'Debian WSL',
            args = { 'wsl.exe', '-d', 'debian', '--cd', '~' },
        },
        {
            label = 'PowerShell 7',
            args = { 'pwsh.exe' },
        }
    }

end

return config
