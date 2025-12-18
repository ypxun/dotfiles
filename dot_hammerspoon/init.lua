-- ~/.hammerspoon/init.lua
-- Hammerspoon script: 动态保存/恢复每个 App 的输入法偏好，并支持显式映射

-- 配置项
local settingsKey = "app_input_prefs_v1"   -- hs.settings 的键名（用于持久化）
local prefs = hs.settings.get(settingsKey) or {}  -- 存储 app -> inputSourceID
local delayOnActivate = 0.06  -- 激活时恢复输入源的延迟（秒），按需微调 0.03-0.12
local blacklist = {  -- 可选：不记录/不恢复的 bundle id 或 app 名
  ["org.hammerspoon.Hammerspoon"] = true,
  --["com.apple.SystemPreferences"] = true,
}

-- 你之前用的 ID（示例，按你实际需要改）
local defaultChineseID = "com.tencent.inputmethod.wetype.pinyin" -- 你原先用的微信拼音 id
local defaultEnglishID = "com.apple.keylayout.ABC"

-- 显式映射（如果你希望某些应用一激活就强制某种输入法）
-- key 可以是 bundle id（优先）或 app 名称（次之）
-- value 可以是字符串（inputSourceID）或函数（执行自定义逻辑）
 local appInputMethod = {
   -- 例：按你之前的写法（保留原始名称以兼容）
   -- 推荐加上常见 bundle id（更可靠）
--   ["com.microsoft.VSCode"] = defaultChineseID, -- 强制 VSCode 为英文（如果需要）
   --["com.apple.Safari"] = defaultEnglishID, -- 示例
}

-- Helper: 从 appObject 获取 key（优先 bundleID，再 name）
local function appKeyFromApp(appObject)
  if not appObject then return nil end
  local bid = appObject:bundleID()
  if bid and bid ~= "" then return bid end
  return appObject:name()
end

-- Helper: 查找显式映射（先按 bundleID，再按 name）
local function getExplicitMapping(appObject)
  if not appObject then return nil end
  local bid = appObject:bundleID()
  if bid and appInputMethod[bid] then return appInputMethod[bid] end
  local name = appObject:name()
  if name and appInputMethod[name] then return appInputMethod[name] end
  return nil
end

-- 显示应用信息的 hotkey（你原来的）
hs.hotkey.bind({'ctrl', 'cmd'}, ".", function()
    local win = hs.window.focusedWindow()
    local app = win and win:application()
    local appPath = app and app:path() or "(no app)"
    local appName = app and app:name() or "(no app)"
    local curIM = hs.keycodes.currentSourceID() or "(no im)"
    hs.pasteboard.setContents(appPath)
    hs.alert.show("App path: " .. appPath .. "\nApp name: " .. appName .. "\nIM source id: " .. curIM, hs.alert.defaultStyle, hs.screen.mainScreen(), 3)
end)

-- 手动设置中/英文的便捷函数（保留，如果你喜欢）
local function setChinese(id)
  if id == nil then id = defaultChineseID end
  hs.keycodes.currentSourceID(id)
end
local function setEnglish(id)
  if id == nil then id = defaultEnglishID end
  hs.keycodes.currentSourceID(id)
end

-- 激活时恢复偏好（或按显式映射强制）
local function onActivated(appName, eventType, appObject)
  if not appObject then return end
  local key = appKeyFromApp(appObject)
  if not key or blacklist[key] then return end

  local explicit = getExplicitMapping(appObject)

  -- 如果有显式映射，优先使用（强制设置）；但仍在 prefs 中确保有一个记录（便于后续恢复）
  if explicit then
    local cur = hs.keycodes.currentSourceID()
    if not prefs[key] and cur and cur ~= "" then
      prefs[key] = cur
      hs.settings.set(settingsKey, prefs)
    end

    -- 如果 mapping 是字符串（input id），直接切换；如果是函数，调用它
    if type(explicit) == "string" then
      hs.timer.doAfter(delayOnActivate, function()
        if explicit ~= hs.keycodes.currentSourceID() then
          hs.keycodes.currentSourceID(explicit)
        end
      end)
    elseif type(explicit) == "function" then
      hs.timer.doAfter(delayOnActivate, function() explicit() end)
    end
    return
  end

  -- 如果没有显式映射，但 prefs 里有记录，恢复之
  if prefs[key] then
    local target = prefs[key]
    hs.timer.doAfter(delayOnActivate, function()
      if target and target ~= hs.keycodes.currentSourceID() then
        hs.keycodes.currentSourceID(target)
      end
    end)
    return
  end

  -- 如果既没有显式映射也没有 prefs 记录：把当前输入源作为该 app 的初始偏好保存（不主动切换）
  local cur = hs.keycodes.currentSourceID()
  if cur and cur ~= "" then
    prefs[key] = cur
    hs.settings.set(settingsKey, prefs)
  end
end

-- 失去焦点时保存当前输入源到该 app 的 prefs（覆盖旧的）
local function onDeactivated(appName, eventType, appObject)
  if not appObject then return end
  local key = appKeyFromApp(appObject)
  if not key or blacklist[key] then return end

  local cur = hs.keycodes.currentSourceID()
  if cur and cur ~= "" then
    prefs[key] = cur
    hs.settings.set(settingsKey, prefs)
  end
end

-- 综合 watcher
function applicationWatcher(appName, eventType, appObject)
  if eventType == hs.application.watcher.activated then
    onActivated(appName, eventType, appObject)
  elseif eventType == hs.application.watcher.deactivated then
    onDeactivated(appName, eventType, appObject)
  end
end

appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()

-- 调试 hotkey：打印当前 prefs 到 alert（ctrl+alt+cmd+P）
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "P", function()
  hs.alert.show(hs.inspect(prefs), 3)
end)

-- 可选：在 Hammerspoon 启动时显示一个简短提示（方便确认脚本已生效）
hs.timer.doAfter(0.8, function()
  hs.alert.show("IM-autoPrefs loaded", 1)
end)
