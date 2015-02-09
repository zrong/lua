---  a progress bar
-- @author zrong(zengrog.net)
-- Creation 2014-01-14
local UIProgressBar = class("UIProgressBar", function()
    return display.newNode()
end)

UIProgressBar._ZORDER_BG 	= -100
UIProgressBar._ZORDER_FG 	= 0

function UIProgressBar:ctor(__options)
	makeUIControlWithoutEvent(self)
    self:setLayoutSizePolicy(display.FIXED_SIZE, display.FIXED_SIZE)

	self._bgFile = __options.bg
	self._fgFile = __options.fg
    self._fgFile2 = __options.fg2

    self._fgFlip = __options.fgFlip

	self._direction = (__options.direction == display.RIGHT_TO_LEFT and 
		display.RIGHT_TO_LEFT) or
		display.LEFT_TO_RIGHT

    self._fgAnchor = __options.fgAnchor or display.LEFT_BOTTOM

    self._paddingX = __options.paddingX or 0
    self._paddingY = __options.paddingY or 0

	self._maximum = __options.maxValue or 100
	self._minimum = __options.minValue or 0
    self._value = __options.value

    --self:setLayoutSize()
end

function UIProgressBar:getMaximum()
	return self._maximum
end

function UIProgressBar:setMaximum(__value)
	self._maximum = __value
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
	if __max then self._maximum = __max end
	if __min then self._minimum = __min end

    if self._value == __value then return self end

    self._progress:setPercentage((__value/self._maximum) * 100)

    if not self._fgFile2 then
        self._value = __value
        return self
    end

    if self._value >= self._maximum and __value < self._maximum then
        print("--progress action")
        transition.stopTarget(self._progress2)
        self._progress2:runAction(transition.sequence({
            CCShow:create(),
            CCProgressTo:create(3.3, ((__value+4)/self._maximum) * 100),
            --CCDelayTime:create(0.2),
            CCCallFunc:create(function()
                --print("aaaaaaaaaaaaaaaaaaaaaa")
                transition.stopTarget(self._progress2)
                --self._progress:setPercentage((__value/self._maximum) * 100)
                self._progress:runAction(CCShow:create())
            end),
            CCHide:create()
        }))

        self._value = __value
        return self
    end

    if __value >= self._maximum then
        print("--progress flash")
        self._progress:runAction(CCHide:create())

        self._progress2:runAction(CCShow:create())
        transition.stopTarget(self._progress2)
        local __action = transition.sequence({
            CCFadeOut:create(0.25),
            CCFadeIn:create(0.25),
            --CCCallFunc:create(function()
                --print("bbbbbbbbbbbbbbb")
            --end),
        })
        self._progress2:runAction(CCRepeatForever:create(__action))
        self._value = __value
        return self

        -- self._progress2:setPercentage((__value/self._maximum) * 100)
        -- transition.stopTarget(self)
        -- self:performWithDelay(function()
        --     self._progress2:setPercentage(1)
        -- end, 0.4)

        -- transition.stopTarget(self._progress2)
        -- self._progress2:runAction(transition.sequence({
        --     CCHide:create(),
        --     CCCallFunc:create(function()
        --         transition.stopTarget(self._progress2)
        --         self._progress2:runAction(transition.sequence({
        --             CCShow:create(),
        --             CCProgressTo:create(0.5, ((__value+4)/self._maximum) * 100),
        --             CCDelayTime:create(0.4),
        --             CCHide:create()
        --         }))
        --     end),
        --     CCShow:create()
        -- }))
    end
    --printf("setValue():%s, %s, %s", __value, self._maximum, (__value/self._maximum) * 100)

    --transition.stopTarget(self._progress)
    --self._progress:runAction(transition.sequence({
        --CCProgressTo:create(0.5, (__value/self._maximum) * 100)
    --}))

	return self
end

function UIProgressBar:setLayoutSize(__w, __h)
    --print("progressbar width:", __w,__h)

    self._bg = display.newScale9Sprite(self._bgFile)
        :addTo(self, UIProgressBar._ZORDER_BG)
        :align(display.LEFT_BOTTOM,0,0)
    self:setContentSize(self._bg:getContentSize())

    if not __w or not __h then
        local ww,hh = self._bg:getContentSize()
        __w = __w or ww
        __h = __h or hh
    end
    
    self:getComponent("components.ui.LayoutProtocol"):setLayoutSize(__w, __h)
    local width, height = self:getLayoutSize()
    local top, right, bottom, left = self:getLayoutPadding()
    width = width - left - right
    height = height - top - bottom
    --print("progressbar width:", width,height)

    self._bg:setContentSize(cc.size(width, height))
	self:setContentSize(cc.size(width, height))
    --self._fg:setContentSize(cc.size(width, height))

    self._fg, self._progress  = self:addFg(self._fgFile, width, height, 0)
    if self._fgFile2 then
        self._fg2, self._progress2  = self:addFg(self._fgFile2, width, height, gar(5))
    end

	return self
end

function UIProgressBar:addFg(__fgFile, __width, __height, __offsetX)
    local __fg = display.newSprite(__fgFile)
    if self._fgFlip then
        self._fg:setFlipX(true)
    end

    local __progress = cc.ProgressTimer:create(__fg)
    __progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)

    __progress:setBarChangeRate(cc.p(1,0))

    --self._progress:setReverseDirection(true)
    
    local __top = (__height - __progress:getContentSize().height - self._paddingY) / 2
    --print("fgprogress.width:", self._fg:getContentSize().width, self._progress:getContentSize().height, __top)
    self:addChild(__progress)


    if self._direction == display.LEFT_TO_RIGHT then
        __progress:setMidpoint(cc.p(0,3))

        __progress:setAnchorPoint(cc.p(0,0))
        --self._progress:setPosition(cc.p(self._paddingX,__top)
    else
        __progress:setMidpoint(cc.p(1,2))

        __progress:setAnchorPoint(cc.p(1,0))
        --self._progress:setPosition(cc.p(width - self._paddingX,__top)
    end

    if self._fgAnchor == display.RIGHT_BOTTOM then
        display.align(__progress, self._fgAnchor, __width - self._paddingX + __offsetX,__top)
    else
        display.align(__progress, self._fgAnchor, self._paddingX + __offsetX,__top)
    end

    __progress:setPercentage((self._value/self._maximum) * 100)

    return __fg, __progress
end

function UIProgressBar:align(align, x, y)
    display.align(self, align, x, y)
    return self
end

return UIProgressBar
