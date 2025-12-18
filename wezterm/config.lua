-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()
local act = wezterm.action
-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 40

-- or, changing the font size and color scheme.
config.font = wezterm.font('MesloLGS NF')
config.font_size = 13

-- wezterm.gui is not available to the mux server, so take care to
-- do something reasonable when this config is evaluated by the mux
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

-- 去除标题栏
config.window_decorations = 'RESIZE'


-- 关闭窗口环境触发的确认提示（ NeverPrompt / AlwaysPrompt ）
config.window_close_confirmation = 'NeverPrompt'

--按键绑定
config.keys = {
    {
        key = 'w',
        mods = 'CMD',
        action = act.CloseCurrentPane { confirm = false },
    },
    {
        key = 'd',
        mods = 'CMD',
        action = act.SplitHorizontal { domain = 'CurrentPaneDomain' }
    },
    {
        key = 'd',
        mods = 'CMD|SHIFT',
        action = act.SplitVertical { domain = 'CurrentPaneDomain' }
    },
}


-- Finally, return the configuration to wezterm:
return config
