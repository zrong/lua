
local AppBase = class("AppBase")

AppBase.APP_ENTER_BACKGROUND_EVENT = "APP_ENTER_BACKGROUND_EVENT"
AppBase.APP_ENTER_FOREGROUND_EVENT = "APP_ENTER_FOREGROUND_EVENT"

function AppBase:ctor(appName, packageRoot)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

    self.name = appName
    self.packageRoot = packageRoot or appName

    --[[
    -- remove to Main App
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    local customListenerBg = cc.EventListenerCustom:create(AppBase.APP_ENTER_BACKGROUND_EVENT,
                                handler(self, self.onEnterBackground))
    eventDispatcher:addEventListenerWithFixedPriority(customListenerBg, 1)
    local customListenerFg = cc.EventListenerCustom:create(AppBase.APP_ENTER_FOREGROUND_EVENT,
                                handler(self, self.onEnterForeground))
    eventDispatcher:addEventListenerWithFixedPriority(customListenerFg, 1)
    ]]

    self.snapshots_ = {}

    -- set global app
    _G[self.name] = self
end

function AppBase:run()
end

function AppBase:exit()
    cc.Director:getInstance():endToLua()
    if device.platform == "windows" or device.platform == "mac" then
        os.exit()
    end
end

function AppBase:enterScene(sceneName, args, transitionType, time, more)
    local scene = self:ci(sceneName, args)
    display.replaceScene(scene, transitionType, time, more)
end

-- Import a class form this package
function AppBase:import(className)
    if not string.find(className, self.packageRoot .. '.') then
        className = self.packageRoot .. '.' .. className
    end
    return require(className)
end

--- Create Instance
function AppBase:ci(className, ...)
    return self:import(className).new(...)
end

function AppBase:makeLuaVMSnapshot()
    self.snapshots_[#self.snapshots_ + 1] = LuaStackSnapshot()
    while #self.snapshots_ > 2 do
        table.remove(self.snapshots_, 1)
    end

    return self
end

function AppBase:checkLuaVMLeaks()
    assert(#self.snapshots_ >= 2, "AppBase:checkLuaVMLeaks() - need least 2 snapshots")
    local s1 = self.snapshots_[1]
    local s2 = self.snapshots_[2]
    for k, v in pairs(s2) do
        if s1[k] == nil then
            print(k, v)
        end
    end

    return self
end

--[[
function AppBase:onEnterBackground()
    self:dispatchEvent({name = AppBase.APP_ENTER_BACKGROUND_EVENT})
end

function AppBase:onEnterForeground()
    self:dispatchEvent({name = AppBase.APP_ENTER_FOREGROUND_EVENT})
end
]]

return AppBase
