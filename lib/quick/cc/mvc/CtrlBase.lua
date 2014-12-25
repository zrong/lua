--- CtrlBase is C in the MVC 
-- @author zrong
-- Creation: 2014-11-25

local CtrlBase = class("CtrlBase")

function CtrlBase:ctor(__view, __name, __parent)
	assert(__view, "Provide a legal __view please!")
	-- __view 一般是一个可视对象的实例，例如：CCNode/CCLayer/CCScene
    -- 但 __view 也可以是任何对象。例如可以对一个 service 或者一个 model 使用 ctrl
	self._view = __view
	self._name = __name or self.__cname
	self._parent = __parent
	self:_addParent()
	self:_registerEvents()
	printInfo("CtrlBase ctor, classname:%s, instancename:%s", self.__cname, self._name)
	printInfo("CtrlBase ctlr, self._view:", self._view, ",self._parent:", self._parent)
end

-- 所有注册的事件对象保存在 _eventProxy table 中。
function CtrlBase:_registerEvents()
	self._eventsProxy = {}
	return self
end

--- 通过 cc.EventProxy 来增加事件，这样方便批量销毁事件。
function CtrlBase:_addEvent(__dispatcher, __event, __handler, __self)
	local __proxy = self._eventsProxy[__dispatcher]
	if not __proxy then 
		__proxy = cc.EventProxy.new(__dispatcher, __self or self) 
		self._eventsProxy[__dispatcher] = __proxy
	end
    local selfHandler = nil
    if __self then
        selfHandler = handler(__self, __handler)
    else
        selfHandler = handler(self, __handler)
    end
	__proxy:addEventListener(__event, selfHandler)
	return self
end

function CtrlBase:_unregisterEvents()
	if self._eventsProxy then
		for __, __proxy in pairs(self._eventsProxy) do
			printInfo("|CtrlBase %s _unregisterEvents", self._name)
			__proxy:removeAllEventListeners()
			self._eventsProxy[__] = nil
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
