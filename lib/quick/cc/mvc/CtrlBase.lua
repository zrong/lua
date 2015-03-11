--- CtrlBase is C in the MVC 
-- @author zrong
-- Creation: 2014-11-25

local CtrlBase = class("CtrlBase")

function CtrlBase:ctor(view, name, parent)
    assert(view, "Provide a legal view please!")
    -- view 一般是一个可视对象的实例，例如：CCNode/CCLayer/CCScene
    -- 但 view 也可以是任何对象。例如可以对一个 service 或者一个 model 使用 ctrl
    self._view = view
    self._name = name or self.__cname
    self._parent = parent
    self:_addParent()
    self:_registerEvents()
    printInfo("CtrlBase ctor, classname:%s, instancename:%s", 
		tostring(self.__cname), tostring(self._name))
    printInfo("CtrlBase ctor, self._view:%s, self._parent:%s", 
		tostring(self._view), tostring(self._parent))
end

-- 所有注册的事件对象保存在 _eventProxy table 中。
function CtrlBase:_registerEvents()
    if not self._eventsProxy then self._eventsProxy = {} end
    return self
end

--- 通过 cc.EventProxy 来增加事件，这样方便批量销毁事件。
function CtrlBase:_addEvent(dispatcher, ename, asyncHandler, who)
    local proxy = self._eventsProxy[dispatcher]
    if not proxy then 
        proxy = cc.EventProxy.new(dispatcher,
            -- 对于非 Node 对象，不将其传给 proxy
            ((who and who.addNodeEventListener) and who) or nil) 
        self._eventsProxy[dispatcher] = proxy
    end
    local selfHandler = nil
    if who then
        selfHandler = handler(who, asyncHandler)
    else
        selfHandler = handler(self, asyncHandler)
    end
    proxy:addEventListener(ename, selfHandler)
    return self
end

function CtrlBase:_unregisterEvents()
    if self._eventsProxy then
        for key, proxy in pairs(self._eventsProxy) do
            printInfo("|CtrlBase %s _unregisterEvents", self._name)
            proxy:removeAllEventListeners()
            self._eventsProxy[key] = nil
        end
        self._eventsProxy = nil
    end
    return self
end

function CtrlBase:getView()
    return self._view
end

function CtrlBase:_addParent()
    return self
end

function CtrlBase:_removeParent()
    self._parent = nil
    return self
end

function CtrlBase:destroy()
    printInfo("|----CtrlBase %s destroy", self._name)
    printInfo("|_view:", self._view)
    if self._view and self._view.destroy then
        self._view:destroy()
    end
    self:_unregisterEvents()
    self:_removeParent()
    printInfo("|_view:", self._view)
    self._view = nil
    printInfo("|_view:", self._view)
    printInfo("|----CtrlBase %s destroy, done", self._name)
end

return CtrlBase
