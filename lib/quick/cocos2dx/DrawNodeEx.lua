--[[

Copyright (c) 2011-2014 chukong-inc.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

]]

--[[--

]]

local c = cc
local DrawNode = c.DrawNode

local drawPolygon = DrawNode.drawPolygon
function DrawNode:drawPolygon(points, params)
    local segments = #points
    local fillColor = cc.c4f(1,1,1,1)
    local borderWidth  = 0
    local borderColor  = cc.c4f(0,0,0,1)
    if params then
        if params.fillColor then fillColor = params.fillColor end
        if params.borderWidth then borderWidth = params.borderWidth end
        if params.borderColor then borderColor = params.borderColor end
    end
    drawPolygon(self, points, #points, fillColor, borderWidth, borderColor)
    return self
end

local drawDot = DrawNode.drawDot
function DrawNode:drawDot(point, radius, color)
    drawDot(self, point, radius, color)
    return self
end

local drawCircle = DrawNode.drawCircle
function DrawNode:drawCircle(center, radius, angle, segments, drawLineToCenter, color)
    drawCircle(self, center, radius, angle, segments, drawLineToCenter, color)
    return self
end

local drawSolidCircle = DrawNode.drawSolidCircle
function DrawNode:drawSolidCircle(center, radius, angle, segments, color)
    drawSolidCircle(self, center, radius, angle, segments, color)
    return self
end

-- 绘制一个矩形边框
-- @param orig 左下角坐标 cc.p
-- @param dest 右上角坐标 cc.p
-- @param color cc.c4f
local drawRect = DrawNode.drawRect
function DrawNode:drawRect(orig, dest, color)
    drawRect(self, orig, dest, color)
    return self
end

-- 绘制一个矩形填充
-- @param orig 左下角坐标 cc.p
-- @param dest 右上角坐标 cc.p
-- @param color cc.c4f
local drawSolidRect = DrawNode.drawSolidRect
function DrawNode:drawSolidRect(orig, dest, color)
	drawSolidRect(self, orig, dest, color)
	self:setContentSize(cc.size(dest.x-orig.x, dest.y-orig.y))
	return self
end

-- 绘制一根线
-- @param orig 起始点坐标 cc.p
-- @param dest 结束点坐标 cc.p
-- @param color cc.c4f
local drawLine = DrawNode.drawLine
function DrawNode:drawLine(orig, dest, color)
	drawLine(self, orig, dest, color)
	return self
end

-- 绘制一根可以设置粗细的线
-- @param from 起始点坐标 cc.p
-- @param to 结束点坐标 cc.p
-- @param radius number
-- @param color cc.c4f
local drawSegment = DrawNode.drawSegment
function DrawNode:drawSegment(from, to, radius, color)
	drawSegment(self, from, to, radius, color)
	return self
end

local clear = DrawNode.clear
function DrawNode:clear()
    clear(self)
    return self
end
