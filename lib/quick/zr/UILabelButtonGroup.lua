local UILabelButtonGroup = class("UILabelButtonGroup", function()
    return display.newNode()
end)

local UILabelButton = import('.UILabelButton')
UILabelButtonGroup.H = "horizontal"
UILabelButtonGroup.V = "vertical"

function UILabelButtonGroup:ctor(__options)
	__options = __options or {}

	-- print("===================== UILabelButtonGroup __options", vardump(__options))

	self.width = __options.width or display.width
	self.height = __options.height or display.height
	self.x = __options.x or 0
	self.y = __options.y or 0
	self.anchor = __options.anchor or display.LEFT_BOTTOM

	self._align = __options.align or UILabelButtonGroup.H

	if __options.bg then
		self.bg = display.newSprite(__options.bg):addTo(self, -1):align(display.LEFT_BOTTOM, 0, 0)
	end

	if type(__options.buttons) == "table" then
		self:addButtons(__options.buttons):layout()
	end

	if not self:stateChange() and type(__options.selectedIndex) == "number" then
		for _i, _button in ipairs(self._buttons) do
			if _i == __options.selectedIndex then
				_button:checked(true)
			else
				_button:checked(false)
			end
		end
	end

	-- print("===================================== self.width, self.height", self.width, self.height)
	-- print("===================================== self.x, self.y", self.x, self.y)
	
	self:size(self.width, self.height)
		:align(self.anchor, self.x, self.y)

	if not __options.noSlide then
		self:onSlide(function(__event)
			self:_sendEvent(__event)
		end, function(__event)
			self:_sendEvent(__event)
		end, function(__event)
		    self:_sendEvent(__event)
	    end, function(__event)
	    	self:_sendEvent(__event)
		end)
	end
end

function UILabelButtonGroup:stateChange()
	local __foundIndex = false
	
	for _i, _button in ipairs(self._buttons) do
		-- if _i == __options.selectedIndex then
		if _button.state == root.d.history.getState() then
			_button:checked(true)
			__foundIndex = true
		else
			_button:checked(false)
		end
	end

	return __foundIndex
end

function UILabelButtonGroup:_sendEvent(__event)
	print("=========== __event", __event.name)
	local __foundIndex = false
	for _i, _button in ipairs(self._buttons) do
		if _button:getHandler() then
			_button:_onTouch(__event.name, __event.x, __event.y)
		end
		if __event.name == "ended" then
			if _button:checkPoint(cc.p(__event.x, __event.y)) then
				__foundIndex = true
			end
		end
	end
	if __foundIndex then
		for _i, _button in ipairs(self._buttons) do
			if __event.name == "ended" then
				if _button:checkPoint(cc.p(__event.x, __event.y)) then
					_button:checked(true)
				else
					_button:checked(false)
				end
			end
		end
	end
end

function UILabelButtonGroup:addButtons(__buttons)
	self._buttons = {}
	for _, _option in ipairs(__buttons) do
		local _button = UILabelButton.new(_option)
		if _button ~= nil then
			_button.id = _
			_button.state = _option.state
			_button:setHandler(_option.func)
		    self._buttons[#self._buttons + 1] = _button:addTo(self)

		    _button.tips = lll.Tips.new({ nonumber = true })
		        :addTo(_button)
		        :pos(_button._label:getX() + _button._label:getW(), _button.height - gar(10))
		        :scale(0.5)
		end
	end

	return self
end

function UILabelButtonGroup:layout()
	local anchorPoint = (self._align == UILabelButtonGroup.H and display.LEFT_BOTTOM) or display.LEFT_TOP

	for _, _button in ipairs(self._buttons) do

		local x = _button.x
		local y = (anchorPoint == display.LEFT_BOTTOM and _button.y) or self.height

		if _ > 1 then
			local preButton = self._buttons[_ - 1]

			x = (_button.x > 0 and _button.x) or preButton:getPositionX()
			y = (_button.y > 0 and _button.y) or preButton:getPositionY()

			if anchorPoint == display.LEFT_BOTTOM then
				x = x + preButton:getW()	-- 取出前一个button的宽度计算x偏移量
			else
				y = y + preButton:getH()	-- 取出前一个button的高度计算y偏移量
			end
		end

		print("====================== x, y", x, y)

		_button:align(anchorPoint):pos(x, y):setTag(_)
	end

	return self
end

function UILabelButtonGroup:setLabel(__labels)
	for _, _s in ipairs(__labels) do
		self._buttons[_]._label:text(_s)
	end

	return self
end

function UILabelButtonGroup:setNumber(__labels)
	for _, _s in ipairs(__labels) do
		-- print('-----------------_, _s', _, _s)
		if not self._buttons[_] then break end
		self._buttons[_]:setNumber(_s)
	end

	return self
end

function UILabelButtonGroup:getItemByIndex(__index)
	return self._buttons[__index]
end

function UILabelButtonGroup:showTips(__index)
	return self._buttons[__index].tips:show()
end

function UILabelButtonGroup:hideTips(__index)
	return self._buttons[__index].tips:hide()
end

return UILabelButtonGroup
