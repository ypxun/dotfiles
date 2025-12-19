-- ~/.hammerspoon/init.lua

-- --- 1. 环境检测 ---
-- 虽然 Hammerspoon 仅限 macOS，但保留检测逻辑是一个好习惯
if not hs or not hs.application then
    print("Not running in Hammerspoon environment, skipping...")
    return
end

-- --- 2. 配置项 ---
local settingsKey = "app_input_prefs_v1"
local prefs = hs.settings.get(settingsKey) or {}
local delayOnActivate = 0.06
local blacklist = {
  ["org.hammerspoon.Hammerspoon"] = true,
}

local defaultChineseID = "com.tencent.inputmethod.wetype.pinyin"
local defaultEnglishID = "com.apple.keylayout.ABC"

local appInputMethod = {}

-- --- 3. 工具函数 ---
local function appKeyFromApp(appObject)
  if not appObject then return nil end
  local bid = appObject:bundleID()
  if bid and bid ~= "" then return bid end
  return appObject:name()
end

local function getExplicitMapping(appObject)
  if not appObject then return nil end
  local bid = appObject:bundleID()
  if bid and appInputMethod[bid] then return appInputMethod[bid] end
  local name = appObject:name()
  if name and appInputMethod[name] then return appInputMethod[name] end
  return nil
end

-- Hotkey: 查看当前 App 信息 (Ctrl+Cmd+.)
hs.hotkey.bind({'ctrl', 'cmd'}, ".", function()
    local win = hs.window.focusedWindow()
    local app = win and win:application()
    local appPath = app and app:path() or "(no app)"
    local appName = app and app:name() or "(no app)"
    local curIM = hs.keycodes.currentSourceID() or "(no im)"
    hs.pasteboard.setContents(appPath)
    hs.alert.show("App path: " .. appPath .. "\nApp name: " .. appName .. "\nIM source id: " .. curIM, hs.alert.defaultStyle, hs.screen.mainScreen(), 3)
end)

-- --- 4. 核心逻辑 (激活/失焦) ---
local function onActivated(appName, eventType, appObject)
  if not appObject then return end
  local key = appKeyFromApp(appObject)
  if not key or blacklist[key] then return end

  local explicit = getExplicitMapping(appObject)

  if explicit then
    local cur = hs.keycodes.currentSourceID()
    if not prefs[key] and cur and cur ~= "" then
      prefs[key] = cur
      hs.settings.set(settingsKey, prefs)
    end
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

  if prefs[key] then
    local target = prefs[key]
    hs.timer.doAfter(delayOnActivate, function()
      if target and target ~= hs.keycodes.currentSourceID() then
        hs.keycodes.currentSourceID(target)
      end
    end)
    return
  end
end

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

-- --- 5. 启动 Watcher ---
function applicationWatcher(appName, eventType, appObject)
  if eventType == hs.application.watcher.activated then
    onActivated(appName, eventType, appObject)
  elseif eventType == hs.application.watcher.deactivated then
    onDeactivated(appName, eventType, appObject)
  end
end

appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()

-- 调试提示 (启动 0.8s 后显示)
hs.timer.doAfter(0.8, function()
  hs.alert.show("Hammerspoon: IM Config Loaded", 1)
end)
