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
function DrawNode:drawCircle(radius, params)
    local fillColor = nil
    if params then
        if params.fillColor then fillColor = params.fillColor end
    end
    drawCircle(self, cc.p(0,0), radius, 360, 30, true, fillColor)
    return self
end

local drawRect = DrawNode.drawRect
function DrawNode:drawRect(rect, params)
    local fillColor = nil
    if params then
        if params.fillColor then fillColor = params.fillColor end
    end
    local x,y,w,h = rect.x, rect.y, rect.w, rect.h
    local lb = cc.p(x,y)
    local lt = cc.p(x,y+h)
    local rt = cc.p(x+w,y+h)
    local rb = cc.p(x+w,y)
    drawRect(self, lb, lt, rt, rb, fillColor)
    return self
end

local clear = DrawNode.clear
function DrawNode:clear()
    clear(self)
    return self
end
