-- =============================================================================
-- =             Input Method Specialist (Per-App Mode)                        =
-- =============================================================================

local IM_Specialist = {}

-- --- 1. 配置中心 ---
IM_Specialist.config = {
    -- 不干预的应用（保持你上次手动选的输入法）
    ignore = {
        ["com.microsoft.VSCode"] = true,
    },

    -- 默认输入法（双拼）
    default_im = "com.apple.inputmethod.SCIM.Shuangpin",

    -- 英文输入源（ABC）
    english_im = "com.apple.keylayout.ABC",

    -- 需要默认英文的应用 (Bundle ID -> true)
    english_apps = {
        ["com.github.wez.wezterm"]    = true,  -- WezTerm
        ["com.apple.Terminal"]        = true,  -- 系统终端
    },

    delay = 0.2,

    -- 黑名单：永远不触碰
    blacklist = {
        ["org.hammerspoon.Hammerspoon"] = true,
        ["com.apple.loginwindow"] = true,
        ["com.apple.ScreenSaver.Engine"] = true,
    },
}

-- --- 2. 核心逻辑 ---
IM_Specialist.watcher = nil

function IM_Specialist:targetIM(bundleID)
    if self.config.ignore[bundleID] then
        return nil
    end
    if self.config.english_apps[bundleID] then
        return self.config.english_im
    end
    return self.config.default_im
end

function IM_Specialist:start()
    if self.watcher then
        self:stop()
    end

    print("IM_Specialist: Starting...")

    self.watcher = hs.application.watcher.new(function(appName, eventType, appObject)
        if eventType ~= hs.application.watcher.activated or not appObject then
            return
        end

        local bundleID = appObject:bundleID()
        if not bundleID or self.config.blacklist[bundleID] then
            return
        end

        local target_im = self:targetIM(bundleID)
        if not target_im then
            return
        end

        hs.timer.doAfter(self.config.delay, function()
            local current_app = hs.application.frontmostApplication()
            if current_app and current_app:bundleID() == bundleID then
                if hs.keycodes.currentSourceID() ~= target_im then
                    hs.keycodes.currentSourceID(target_im)
                end
            end
        end)
    end)

    self.watcher:start()
    hs.alert.show("IM Specialist Loaded", 0.5)
end

function IM_Specialist:stop()
    if self.watcher then
        print("IM_Specialist: Stopping...")
        self.watcher:stop()
        self.watcher = nil
    end
end

-- --- 3. 启动模块 ---
IM_Specialist:start()

-- --- 4. 辅助工具 ---

-- 重载配置
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
    hs.reload()
end)

-- 查看当前应用信息，并复制 Bundle ID
hs.hotkey.bind({'ctrl', 'cmd'}, ".", function()
    local app = hs.application.frontmostApplication()
    if not app then hs.alert.show("无法获取当前应用"); return end

    local app_bundle = app:bundleID() or "N/A"
    local cur_im = hs.keycodes.currentSourceID() or "N/A"
    local message = string.format("BundleID: %s\n\n当前输入法: %s", app_bundle, cur_im)

    hs.alert.show(message, 3)
    hs.pasteboard.setContents(app_bundle)
end)
