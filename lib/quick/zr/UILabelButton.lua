local UILabelButton = class("UILabelButton", function()
    return display.newNode()
end)

UILabelButton.CLICKED_EVENT = "CLICKED_EVENT"
UILabelButton.PRESSED_EVENT = "PRESSED_EVENT"
UILabelButton.RELEASE_EVENT = "RELEASE_EVENT"
UILabelButton.STATE_CHANGED_EVENT = "STATE_CHANGED_EVENT"

UILabelButton._MOVE_RANGE = 20
UILabelButton._startPos = nil

function UILabelButton:ctor(__options)
    self._fsm = {}
    cc.GameObject.extend(self._fsm)
        :addComponent("components.behavior.StateMachine")
        :exportMethods()
    self._fsm:setupState({
        initial = {state = "normal", event = "startup", defer = false},
        events = {
            {name = "disable", from = {"normal", "pressed"}, to = "disabled"},
            {name = "enable",  from = {"disabled"}, to = "normal"},
            {name = "press",   from = "normal",  to = "pressed"},
            {name = "release", from = "pressed", to = "normal"},
        },
        callbacks = {
            onchangestate = handler(self, self._onStateChange),
        }
    })

    makeEventDispatcher(self)
    self:setNodeEventEnabled(true)

    __options = __options or {}

    -- 按钮初始属性
    self.x = __options.x or 0    -- 可允许对某一个按钮进行绝对 x 定位，则后面的按钮会自动向后排列
    self.y = __options.y or 0    -- 可允许对某一个按钮进行绝对 y 定位，则后面的按钮会自动向后排列
    self.width = __options.w or 0
    self.height = __options.h or 0
    self.params = __options.params
    self.lv = __options.lv or 0
    self.jd = __options.jd or { 0, 0 }
    self.id = __options.id

    __options.font = __options.font or FontUtil.BODY
    __options.size = __options.size or FontUtil.S
    __options.color = __options.color or display.COLOR_WHITE
    __options.direction = __options.direction or display.LEFT_TO_RIGHT
    __options.spacing = __options.spacing or gar(10)

    self:size(self.width, self.height)
        :setBox(self.width, self.height)

    self.cx = self.width / 2
    self.cy = self.height / 2

    -- 图片中带 on/off 则表示是一个单独的 checkboxbutton
    self._checked = type(__options.checked) ~= nil and __options.checked or false
    if __options.images then
        if __options.images.on then
            self._images_on = __options.images.on
            self._images_off = __options.images.off

            self._sprite = display.newSprite(self._checked and self._images_on or self._images_off)
                :addTo(self)
                :align(display.CENTER, self.width / 2, self.height / 2)

            self._isCheckBoxButton = true
        else
            self._sprite = display.newSprite(__options.images)
                :addTo(self)
                :align(display.CENTER, self.width / 2, self.height / 2)
        end
    end

   if __options.text then
        self._label = ui.newLabel({
            text = __options.text,
            font = __options.font,
            size = __options.size,
            color = __options.color})
            :addTo(self)
            :align(display.CENTER, self.width / 2, self.height / 2)

        if __options.number then
            self._labelNumber = ui.newLabel({
                text = __options.number,
                font = FontUtil.BODY,
                size = FontUtil.SS,
                color = cc.c3b(253, 152, 14)})
                :addTo(self)
                :align(display.LEFT_CENTER, self._label:getX() + self._label:getW() / 2 + __options.spacing, self.height / 2 + gar(7))
        end
    end

    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self._onTouch))
    if type(__options.handler) == "function" then
        self._hanlder = __options.handler
        self:onClick(__options.handler)
    end

    self:layout(__options)
end

function UILabelButton:checked(__bool)
    -- 带了函数的才需要判断 checked 状态
    if self._hanlder then
        self._checked = __bool

        if __bool then
            if self._sprite then self._sprite:opacity(255) end
            if self._label then self._label:opacity(255) end
        else
            if self._sprite then self._sprite:opacity(96) end
            if self._label then self._label:opacity(96) end
        end
    end

    return self
end

function UILabelButton:isChecked()
    return self._checked
end

function UILabelButton:setNumber(__number)
    if self._labelNumber then self._labelNumber:text(__number) end
end

function UILabelButton:opacity(__opacity)
    if self._sprite then self._sprite:opacity(__opacity) end
    if self._label then self._label:opacity(__opacity) end

    return self
end

function UILabelButton:text(__text)
    self._label:text(__text)
    self:layout()

    return self
end

function UILabelButton:setWidth(__width)
    self._label:align(display.CENTER, __width / 2, self.height / 2)
    self:size(__width, self.height)
        :setBox(__width, self.height)
end

function UILabelButton:layout(__options)
    if self._sprite and self._label and #self._label:getString() > 0 then
        if __options.direction == display.LEFT_TO_RIGHT then
            -- 从左至右对齐
            self._sprite:align(display.LEFT_CENTER, 0, self.height / 2)
            self._label:align(display.LEFT_CENTER, self._sprite:getW() + __options.spacing, self.height / 2)
        else
            local __spriteH, __labelH = self._sprite:getContentSize().height, self._label:getContentSize().height
            local __contentH = __spriteH + __labelH
            local __offsetY = (self.height - __contentH) / 2

            self._sprite:align(display.BOTTOM_CENTER, self.width / 2, __offsetY + __options.spacing / 2 + __labelH)
            self._label:align(display.BOTTOM_CENTER, self.width / 2, __offsetY - __options.spacing / 2)
        end
    end

    return self
end

function UILabelButton:_onTouch(evt)
	local ename, ox, oy, px, py = evt.name, evt.x, evt.y, evt.prevX, evt.prevY
    --d('UILabelButton:_onTouch')
    --dump(evt)
    local __info = {
        name = ename,
        x = ox,
        y = oy,
        prevX = px,
        prevY = py 
    }

    if ename == "began" then
        UILabelButton._startPos = cc.p(ox, oy)
        --d('------------------- began 中调用 PRESSED_EVENT')
        self._fsm:doEvent("press")
        self:dispatchEvent({name = UILabelButton.PRESSED_EVENT, x = ox, y = oy})
        return true
    end

    if ename == "moved" then
        if self._fsm:canDoEvent("press") then
            --d('------------------- moved 中调用 PRESSED_EVENT')
            self._fsm:doEvent("press")
            self:dispatchEvent({name = UILabelButton.PRESSED_EVENT, x = ox, y = oy})
        end
    else
        if self._fsm:canDoEvent("release") then
            --d('------------------- ended 中调用 RELEASE_EVENT')
            self._fsm:doEvent("release")
            self:dispatchEvent({name = UILabelButton.RELEASE_EVENT, x = ox, y = oy})
        end
        if ename == "ended" and self:_checkTouchArea(ox, oy) then
            if self._isCheckBoxButton then
                self._checked = not self._checked
                self._sprite:removeSelf(true)

                self._sprite = display.newSprite(self._checked and self._images_on or self._images_off)
                    :addTo(self)
                    :align(display.CENTER, self.width / 2, self.height / 2)
            end
            --d('------------------- dispatchEvent CLICKED_EVENT 事件')
            self:dispatchEvent({name = UILabelButton.CLICKED_EVENT, x = ox, y = oy})

            audio.playSFX(audio.BTN_CLICK)
        end
    end
end

function UILabelButton:addHandler(__event, __hanlder)
    -- d('------------------- 添加了事件', vardump(__event))
    self:addEventListener(__event, __hanlder)
end

function UILabelButton:onClick(__hanlder)
    -- d('------------------------ 点击: onClick')
    self:setTouchEnabled(true)
    self:addHandler(UILabelButton.CLICKED_EVENT, __hanlder)
    return self
end

function UILabelButton:onPress(__hanlder)
    -- d('------------------------ 点击按下: onPress')
    self:addHandler(UILabelButton.PRESSED_EVENT, __hanlder)
    return self
end

function UILabelButton:onRelease(__hanlder)
    -- d('------------------------ 释放点击: onRelease')
    self:addHandler(UILabelButton.RELEASE_EVENT, __hanlder)
    return self
end

function UILabelButton:_onStateChange(__event)
    if self:isRunning() then
        -- d('------------ 状态转换', self._fsm:getState())
    end
end

function UILabelButton:_checkTouchArea(__x, __y)
    local __inBox = self:getCascadeBoundingBox():containsPoint(cc.p(__x, __y))
    local __inMoveRange =  math.abs(__x - UILabelButton._startPos.x) < UILabelButton._MOVE_RANGE and math.abs(__y - UILabelButton._startPos.y) < UILabelButton._MOVE_RANGE
    return __inBox and __inMoveRange
end

function UILabelButton:unbind()
    self:removeAllEventListeners()
    return self
end

function UILabelButton:setHandler(__hanlder)
    if type(__hanlder) == "function" then
        self._hanlder = __hanlder
        self:addHandler(UILabelButton.CLICKED_EVENT, __hanlder)
    end
    return self
end

function UILabelButton:getHandler()
    return self._hanlder
end

function UILabelButton:openAni(__delay)
    self:runAction(transition.sequence({
        CCDelayTime:create(__delay),
        CCCallFunc:create(function()
            self._sprite:fadeIn(0.5)
            self._label:fadeIn(0.5)
        end),
        CCDelayTime:create(0.5),
        CCCallFunc:create(function()
            self._sprite:fadeOut(0.5)
            self._label:fadeOut(0.5)
        end),
        CCDelayTime:create(0.5),
        CCCallFunc:create(function()
            self._sprite:fadeIn(0.5)
            self._label:fadeIn(0.5)
        end),
        CCDelayTime:create(0.5),
        CCCallFunc:create(function()
            self._sprite:fadeOut(0.5)
            self._label:fadeOut(0.5)
        end),
        CCDelayTime:create(0.5),
        CCCallFunc:create(function()
            self._sprite:fadeTo(0.5, 255)
            self._label:fadeTo(0.5, 255)
        end),
    }))

    return self
end

return UILabelButton
