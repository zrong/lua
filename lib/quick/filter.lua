--- create some filters to build a FilteredSprite
-- @author zrong(zengrong.net)
-- Creation 2014-03-31

--------------------------------
-- @module filter

--[[--

滤镜功能

]]

local filter = {}

local FILTERS = {
-- colors
GRAY =          {cc.GrayFilter},                -- {r 0.299, g 0.587, b 0.114, a 0.0} or no parameters
RGB =           {cc.RGBFilter, 3, {1, 1, 1}},   -- {0.0~1.0, 0.0~1.0, 0.0~1.0}
HUE =           {cc.HueFilter, 1, {0}},         -- {-180~ 180} see photoshop
BRIGHTNESS =    {cc.BrightnessFilter, 1, {0}},  -- {-1.0~1.0}
SATURATION =    {cc.SaturationFilter, 1, {1}},  -- {0.0~2.0}
CONTRAST =      {cc.ContrastFilter, 1, {1}},    -- {0.0~4.0}
EXPOSURE =      {cc.ExposureFilter, 1, {0}},    -- {-10.0, 10.0}
GAMMA =         {cc.GammaFilter, 1, {1}},       -- {0.0, 3.0}
HAZE =          {cc.HazeFilter, 2, {0, 0}},     -- {distance -0.5~0.5, slope -0.5~0.5}
SEPIA =         {cc.SepiaFilter},               -- {no parameters}
-- blurs
GAUSSIAN_VBLUR =    {cc.GaussianVBlurFilter, 1, {0}},       -- {pixel}
GAUSSIAN_HBLUR =    {cc.GaussianHBlurFilter, 1, {0}},       -- {pixel}
ZOOM_BLUR =         {cc.ZoomBlurFilter, 3, {1, 0.5, 0.5}},  -- {size, centerX, centerY}
MOTION_BLUR =       {cc.MotionBlurFilter, 2, {1, 0}},       -- {size, angle}
-- others
SHARPEN =       {cc.SharpenFilter, 2, {0, 0}},  -- {sharpness, amount}
MASK =          {cc.MaskFilter, 1},             -- {DO NOT USE IT}
DROP_SHADOW =   {cc.DropShadowFilter, 1},       -- {DO NOT USE IT}
-- custom
CUSTOM = {cc.CustomFilter, 1}
}

local MULTI_FILTERS = {
GAUSSIAN_BLUR = {},
}

-- start --

--------------------------------
-- 创建一个滤镜效果，并返回 Filter 场景对象。
-- @function [parent=#filter] newFilter
-- @param string filterName 滤镜名称
-- @param table param
-- @return FilteredSprite#FilteredSprite ret (return value: cc.FilteredSprite)    Filter的子类

-- end --

function filter.newFilter(filterName, param)
    local filterData = FILTERS[filterName]
    assert(filterData, "filter.newFilter() - filter "..filterName.." is not found.")
    local cls, count, default = unpack(filterData)

    if "CUSTOM" == filterName then
        return cls:create(param)
    end

    local paramCount = (param and #param) or 0
    print("filter.newFilter:", paramCount, filterName, count)
    print("filter.newFilter param:", param)
    -- If count is nil, it means the Filter does not need a parameter.
    if count == nil then
        if paramCount == 0 then
            return cls:create()
        end
    elseif count == 0 then
        return cls:create()
    else
        if paramCount == 0 then
            return cls:create(unpack(default))
        end
        assert(paramCount == count, 
            string.format("filter.newFilter() - the parameters have a wrong amount! Expect %d, get %d.", 
            count, paramCount))
    end
    return cls:create(unpack(param))
end

-- start --

--------------------------------
-- 创建滤镜数组，并返回 Filter 的数组对象
-- @function [parent=#filter] newFilters
-- @param table __filterNames 滤镜名称数组
-- @param table __params 对应参数数组
-- @return table#table ret (return value: table)   Filter数组

-- end --

function filter.newFilters(__filterNames, __params)
    assert(#__filterNames == #__params, 
        "filter.newFilters() - Please ensure the filters and the parameters have the same amount.")
    local __filters = {} -- cc.Array:create()
    for i in ipairs(__filterNames) do
        table.insert(__filters, filter.newFilter(__filterNames[i], __params[i]))
        --__filters:addObject(filter.newFilter(__filterNames[i], __params[i]))
    end
    return __filters
end

return filter
