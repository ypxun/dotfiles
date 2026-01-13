-- =============================================================================
-- =             Input Method Specialist (VSCode Exception Mode)             =
-- =============================================================================

-- 使用局部表进行封装，确保代码整洁和对象持久化
local IM_Specialist = {}

-- --- 1. 配置中心 ---
IM_Specialist.config = {
    -- 你的 VSCode 的 Bundle ID
    vscode_bundle_id = "com.microsoft.VSCode",

    -- 除 VSCode 外，所有应用默认使用的输入法 (微信输入法)
    default_im = "im.rime.inputmethod.Squirrel.Hans",

    -- 事件响应延迟，防止与系统动画冲突，提高稳定性
    delay = 0.2,

    -- 黑名单：这些应用的输入法将永远不会被 Hammerspoon 触碰
    blacklist = {
        ["org.hammerspoon.Hammerspoon"] = true,
        ["com.apple.loginwindow"] = true,
        ["com.apple.ScreenSaver.Engine"] = true,
    },
}

-- --- 2. 核心逻辑 ---

-- 用于存放 application watcher 对象
IM_Specialist.watcher = nil

-- 启动监听器
function IM_Specialist:start()
    -- 如果已存在，先停止旧的
    if self.watcher then
        self:stop()
    end

    print("IM_Specialist: Starting...")

    self.watcher = hs.application.watcher.new(function(appName, eventType, appObject)
        -- 我们只关心应用的激活事件
        if eventType ~= hs.application.watcher.activated or not appObject then
            return
        end

        local bundleID = appObject:bundleID()

        -- 检查应用是否在黑名单中
        if not bundleID or self.config.blacklist[bundleID] then
            return
        end

        -- 核心判断逻辑
        if bundleID == self.config.vscode_bundle_id then
            -- 如果是 VSCode，Hammerspoon 不做任何干预
            -- print("IM_Specialist: VSCode activated, ignoring.") -- 可取消注释用于调试
            return
        else
            -- 如果是任何其他应用，准备切换到默认输入法
            local target_im = self.config.default_im

            -- 使用延迟执行来确保切换成功
            hs.timer.doAfter(self.config.delay, function()
                -- 在执行切换前，再次确认当前激活的应用仍是目标应用
                -- 这是为了防止用户快速切换应用导致输入法设置错误
                local current_app = hs.application.frontmostApplication()
                if current_app and current_app:bundleID() == bundleID then
                    -- 仅当当前输入法不是目标输入法时才执行切换，避免不必要的操作
                    if hs.keycodes.currentSourceID() ~= target_im then
                        hs.keycodes.currentSourceID(target_im)
                    end
                end
            end)
        end
    end)

    self.watcher:start()
    hs.alert.show("IM Specialist (VSCode Mode) Loaded", 0.5)
end

-- 停止监听器
function IM_Specialist:stop()
    if self.watcher then
        print("IM_Specialist: Stopping...")
        self.watcher:stop()
        self.watcher = nil
    end
end

-- --- 3. 启动模块 ---
IM_Specialist:start()

-- --- 4. 辅助工具 (强烈建议保留) ---

-- 快捷键：一键重载Hammerspoon配置
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
    hs.reload()
end)

-- hs.alert.show 会在重载后自动显示，无需额外代码

-- 快捷键：查看当前应用信息，方便获取其他应用的 Bundle ID
hs.hotkey.bind({'ctrl', 'cmd'}, ".", function()
    local app = hs.application.frontmostApplication()
    if not app then hs.alert.show("无法获取当前应用"); return end

    local app_bundle = app:bundleID() or "N/A"
    local cur_im = hs.keycodes.currentSourceID() or "N/A"
    local message = string.format("BundleID: %s\n\n当前输入法: %s", app_bundle, cur_im)

    hs.alert.show(message, 3)
    hs.pasteboard.setContents(app_bundle) -- 自动复制 Bundle ID 到剪贴板
end)