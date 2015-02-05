--- a progress bar that use dot image to exhibit percentage.
-- @author zrong(zengrong.net)
-- Creation 2014-01-14

local UIProgressDot = class("UIProgressBar", function()
	return display.newNode()
end)

UIProgressDot._ZORDER_DOT 	= 0
UIProgressDot._ZORDER_DOT 	= 0

function UIProgressDot:ctor(__options)
	makeUIControl_(self)
    self:setLayoutSizePolicy(display.FIXED_SIZE, display.FIXED_SIZE)

	self._bgFile = __options.bg
	self._fgFile = __options.fg
	self._padding = __options.padding or 0
	self._amount = __options.amount or 5

	self._maximum = __options.max or 100
	self._minimum = __options.min or 0
	self._value = __options.value or self._maximum
	self._percent = self._value/(self._maximum-self._minimum)
	self:addScriptEventListener(cc.Event.ENTER_SCENE, function()
		--print("ENTER_SCENE")
		self:_updateImages()
	end)
end

function UIProgressDot:getValue()
	return self._value, self._maximum, self._minimum
end

function UIProgressDot:setValue(__value, __max, __min)
	self._value = __value
	if __max then self._maximum = __max end
	if __min then self._minimum = __min end
	self:_updateImages()
	return self
end

function UIProgressDot:getMaximum()
	return self._maximum
end

function UIProgressDot:setMaximum(__value)
	self._maximum = __value
	self:_updateImages()
	return self
end

function UIProgressDot:getMinimum()
	return self._minimum
end

function UIProgressDot:setMinimum(__value)
	self._minimum = __value
	self:_updateImages()
	return self
end

function UIProgressDot:_updateImages()
	local __lw, __lh = self:getLayoutSize()
	if self._value <= self._minimum then
		self._percent = 0
	else
		self._percent = self._value/(self._maximum-self._minimum)
	end
	local __fgDotNum = math.ceil(self._amount * self._percent)
	local __bgDotNum = self._amount - __fgDotNum

	printf("fg dot num:%d", __fgDotNum)
	printf("bg dot num:%d", __bgDotNum)
	
	if self._dots then
		for __, __dot in pairs(self._dots) do
			self:removeChild(__dot)
		end
	end
	self._dots = {}

	if self._fgFile then
		for i=1,__fgDotNum do
			self._dots[#self._dots+1] = display.newSprite(self._fgFile)
		end
	end
	if self._bgFile then
		for i=__fgDotNum+1,self._amount do
			self._dots[#self._dots+1] = display.newSprite(self._bgFile)
		end
	end
	for i=1,self._amount do
		local __dot = self._dots[i]
		if __dot then
			__dot:pos((i-1)*(__dot:getContentSize().width+self._padding), 0)
				:addTo(self, self._ORDER_DOT)
		end
	end
end

function UIProgressDot:setLayoutSize(__w, __h)
    self:getComponent("components.ui.LayoutProtocol"):setLayoutSize(__w, __h)
    local width, height = self:getLayoutSize()
    local top, right, bottom, left = self:getLayoutPadding()
    width = width - left - right
    height = height - top - bottom
	self:setContentSize(CCSize(width, height))
	self:_updateImages()
	return self
end

return UIProgressDot
