---  a progress bar
-- @author zrong(zengrog.net)
-- Creation 2014-01-14
local UIProgressBar = class("UIProgressBar", function()
    return display.newNode()
end)

UIProgressBar._ZORDER_BG 	= -100
UIProgressBar._ZORDER_FG 	= 0

function UIProgressBar:ctor(__options)
	makeUIControl_(self)
    self:setLayoutSizePolicy(display.FIXED_SIZE, display.FIXED_SIZE)

	self._bgFile = __options.bg
	self._fgFile = __options.fg
	self._rect = __options.rect or CCRect(0,0,0,0)

	self._maximum = __options.max or 100
	self._minimum = __options.min or 0
	self._value = __options.value or self._maximum
	self._percent = self._value/(self._maximum-self._minimum)
	self._direction = (__options.direction == display.RIGHT_TO_LEFT and 
		display.RIGHT_TO_LEFT) or
		display.LEFT_TO_RIGHT
	--display.align(self, __options.align or display.LEFT_BOTTOM)

	self:addScriptEventListener(cc.Event.ENTER_SCENE, function()
		--print("ENTER_SCENE")
		self:_updateImages()
		self:_updatefg()
	end)
end

function UIProgressBar:getMaximum()
	return self._maximum
end

function UIProgressBar:setMaximum(__value)
	self._maximum = __value
	self:_updateImages()
	self:_updatefg()
	return self
end

function UIProgressBar:getMinimum()
	return self._minimum
end

function UIProgressBar:setMinimum(__value)
	self._minimum = __value
	self:_updateImages()
	self:_updatefg()
	return self
end

function UIProgressBar:getValue()
	return self._value, self._maximum, self._minimum
end

function UIProgressBar:setValue(__value, __max, __min)
	self._value = __value
	if __max then self._maximum = __max end
	if __min then self._minimum = __min end
	if __max or __min then
		self:_updateImages()
	end
	self:_updatefg()
	return self
end

function UIProgressBar:_updatefg()
	if self._value <= self._minimum then
		self._percent = 0
	else
		self._percent = self._value/(self._maximum-self._minimum)
	end
	if self._fg then
		local __size = self._rect.size
		local __newWidth = math.ceil(__size.width * self._percent)
		local __noClip = __newWidth > self._fgOriginalWidth
		-- the width of fg sprite must be greater than original image width, 
		-- otherwise the fg sprite will appear strange.
		if __noClip then
			local __newSize = CCSize(__newWidth, __size.height)
			self._fgSprite:setContentSize(__newSize)
		else
			local __x = (self._direction == display.RIGHT_TO_LEFT and self._fgOriginalWidth - __newWidth) or 0
			self._fg:setClippingRegion(CCRect(__x,0,__newWidth, __size.height))
		end
		if self._direction == display.RIGHT_TO_LEFT then
			self:_updatefgPos(__noClip)
		end
		--print("--- UIProgressBar.upatefg bar size:", __newWidth, self._fgOriginalWidth)
		--print("--- UIProgressBar.size, percent:", __size.width, self._percent)
	end
end

function UIProgressBar:_updatefgPos(__noClip)
	--print("updatefgpos rectsize:", self._rect.size.width)
	local __csize = self:getContentSize()
	local __fgsize = self._fgSprite:getContentSize()
	if self._direction == display.RIGHT_TO_LEFT then
		if not __noClip then return end
		self._fg:setPosition(
			self._rect.origin.x + (self._rect.size.width-__fgsize.width),
			self._rect.origin.y
			)
	else
		self._fg:setPosition(self._rect.origin)
	end
	--print("fg getContentSize size:", __csize.width, __csize.height)
	--print("fg rect size:", self._rect.size.width)
end

function UIProgressBar:_updateImages()
	--print("getLayerSize:", self:getLayoutSize())
	local __lw, __lh = self:getLayoutSize()
	if not self._bg and self._bgFile then 
		self._bg = display.newScale9Sprite(self._bgFile)
			:addTo(self, UIProgressBar._ZORDER_BG)
			:align(display.LEFT_BOTTOM,
			--:align((self._direction == display.LEFT_TO_RIGHT and display.LEFT_BOTTOM) or display.RIGHT_BOTTOM,
				0,0)
		if __lw == 0 and __lh == 0 then
			self:setContentSize(self._bg:getContentSize())
		end
	end
	if not self._fg and self._fgFile then 
		-- On account of a issue of scale9, the fg must be a CCClippingRegionNode
		self._fg = display.newClippingRegionNode(CCRect(0,0,0,0))
			--:align((self._direction == display.LEFT_TO_RIGHT and display.LEFT_BOTTOM) or display.RIGHT_BOTTOM,
			:align(display.LEFT_BOTTOM,
				0, 0)
			:addTo(self, UIProgressBar._ZORDER_FG)
		self._fgSprite = display.newScale9Sprite(self._fgFile)
			:align(display.LEFT_BOTTOM, 0,0)
			:addTo(self._fg)
		self._fgOriginalWidth = self._fgSprite:getOriginalSize().width
	end
	if self._bg then
		if __lw > 0 and __lh > 0 then
			self._bg:setContentSize(CCSize(__lw, __lh))
		end
	end
	if self._fg then
		local __csize = self:getContentSize()
		if self._rect.size.width == 0 then 
			self._rect.size.width = __csize.width - self._rect.origin.x
		end
		if self._rect.size.height == 0 then 
			self._rect.size.height = __csize.height - self._rect.origin.y
		end
		--- let the default display size is maximum.
		self._fg:setClippingRegion(CCRect(0,0,self._rect.size.width,self._rect.size.height))
		self:_updatefgPos()
		--print("fg getContentSize size:", __csize.width, __csize.height)
		--print("fg rect size:", self._rect.size.width)
	end
	--local __size = self:getContentSize()
	--print("getContentSize size:", __size.width, __size.height)
end

function UIProgressBar:setLayoutSize(__w, __h)
    self:getComponent("components.ui.LayoutProtocol"):setLayoutSize(__w, __h)
    local width, height = self:getLayoutSize()
    local top, right, bottom, left = self:getLayoutPadding()
    width = width - left - right
    height = height - top - bottom
	self:setContentSize(CCSize(width, height))
	self:_updateImages()
	return self
end

function UIProgressBar:align(align, x, y)
    display.align(self, align, x, y)
    return self
end

return UIProgressBar
